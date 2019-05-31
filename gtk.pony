use "files"

class GtkApplication

  var _windows: Array[GtkWindow]
  var _cpointer: Pointer[_GtkApplication] tag
  var environment: Env

  var config: Config

  var _saved: Bool = true

  new create(org_name: String, env: Env) ? =>
    _cpointer = recover tag
      @gtk_application_new(org_name.cstring(), 0)
    end

    environment = env

    _windows = []
    // Load the config (and project file if required) from the environment args
    config = Config(env)?

  fun get_pointer(): Pointer[_GtkApplication] tag =>
    _cpointer

  fun cast_to_g_app(): Pointer[_GApplication] tag =>
    @g_application_cast(_cpointer)

  fun ref set_config(new_config: Config): None =>
    this.config = new_config

  fun register_callback(callback_event: String, callback: _GCallback, data: Any) =>
    // Register the activate function as a callback for app startup
    @g_signal_connect_generic(_cpointer, callback_event.cstring(), callback, data)

  fun ref add_window(window: GtkWindow ref) =>
    @gtk_application_add_window(_cpointer, window.get_pointer())
    _windows.push(window)

  fun ref mark_as_need_save() =>
    if _saved then
      for window in _windows.values() do
        window.set_title(window.get_title() + " *")
      end
    end
    _saved = false

  fun ref save_to_ui_file(filename: String): None =>
    var ui_string = get_ui_string()
    try
      // Set up file permissions
      let caps = recover val
        FileCaps.>set(FileRead).>set(FileStat).>set(FileWrite).>set(FileSync).>set(FileCreate)
      end
      // Try to open the file
      var filepath: FilePath = FilePath(environment.root as AmbientAuth, filename, caps)?
      var file = File(filepath)
      // Write the layout string
      file.write(ui_string)
      // Sync, save, and close
      file.sync()
      file.dispose()
    else
      environment.out.print("[ERROR] File Error. Are permissions correct?")
    end
    None

  fun ref get_ui_string(): String =>
    ""

  fun run(env: (Env | None)): U8 =>
    var status: U8 = 0

    try
      var env2 = env as Env
      // Run the program
      status = @g_application_run[U8](cast_to_g_app(), env2.args.size(), env2.args.cpointer())
    else
      // Run the program
      status = @g_application_run[U8](cast_to_g_app(), U8(0), Array[String]())
    end

    // Clear memory afterwards
    @g_object_unref[None](get_pointer())

    // Return the status integer
    status

class GtkWindow

  var _cpointer: Pointer[_GtkWindow] tag

  var title: String
  var size: Array[I32]

  var env: Env

  var window: Pointer[_GtkWidget]

  new create(app: GtkApplication, win_type: U8, win_title: String, win_size: Array[I32]) =>
    title = win_title
    size = win_size
    env = app.environment

    if win_type == WindowType.application() then
      // Call the GTK library to make a new window for the application
      window = @gtk_application_window_new(app.get_pointer())
    else
      window = @gtk_window_new(win_type)
    end

    _cpointer = @gtk_window_cast(window)

    // Set the title
    set_title(title)
    // Set the window size
    try
      @gtk_window_set_default_size[None](_cpointer, size.apply(0)?, size.apply(1)?)
    end

    // Notify the application about the new window
    app.add_window(this)

  fun show_window() =>
    // Make it visible
    @gtk_widget_show_all[None](window)

  fun move(x: U16, y: U16) =>
    @gtk_window_move[None](window, x, y)

  fun bring_to_top() =>
    @gtk_window_present[None](window)

  fun get_pointer(): Pointer[_GtkWindow] tag =>
    _cpointer

  fun get_title(): String =>
    title

  fun ref set_title(new_title: String) =>
    title = new_title
    @gtk_window_set_title[None](_cpointer, title.cstring())

  fun get_screen(): Pointer[_GdkScreen] =>
    @gtk_window_get_screen[Pointer[_GdkScreen]](window)

  fun set_screen(screen: Pointer[_GdkScreen]) =>
    @gtk_window_set_screen[None](window, screen)
