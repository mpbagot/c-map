use "files"

class GtkApplication
  """
  GtkApplication wraps various functions of the GtkApplication C type.
  It also provides functions to set the config, and save the current layout to
  a .ui description file.
  """

  var _windows: Array[GtkWindow]
  var _cpointer: Pointer[_GtkApplication] tag
  var environment: Env

  var config: Config

  var _saved: Bool = true

  new create(org_name: String, env: Env) ? =>
    """
    Create a new GtkApplication, initialised with no windows, and a config as
    loaded from the given environment.
    """
    _cpointer = recover tag
      @gtk_application_new(org_name.cstring(), 0)
    end

    environment = env

    _windows = []
    // Load the config (and project file if required) from the environment args
    config = Config(env)?

  fun get_pointer(): Pointer[_GtkApplication] tag =>
    """
    Return a pointer to the underlying GtkApplication object.
    """
    _cpointer

  fun cast_to_g_app(): Pointer[_GApplication] tag =>
    """
    Return a pointer to this GtkApplication, cast as a GApplication.
    """
    @g_application_cast(_cpointer)

  fun ref set_config(new_config: Config): None =>
    """
    Set the program configuration.
    """
    config = new_config

  fun register_callback(callback_event: String, callback: _GCallback, data: Any) =>
    """
    Register a function callback to be run when required.
    """
    // Register the activate function as a callback for app startup
    @g_signal_connect_generic(_cpointer, callback_event.cstring(), callback, data)

  fun ref add_window(window: GtkWindow ref) =>
    """
    Add a new window to the application.
    """
    @gtk_application_add_window(_cpointer, window.get_pointer())
    _windows.push(window)

  fun ref mark_as_need_save() =>
    """
    Mark the program as needing to be saved,
    adjusting the titles of all windows.
    """
    if _saved then
      for window in _windows.values() do
        window.set_title(window.get_title().add(" *"))
      end
    end
    _saved = false

  fun ref save_to_ui_file(filename: String): None =>
    """
    Save the current application and window layout as a UI description file.
    """
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
    """
    Get a UI description string representing the current window and element layout
    of the application.
    """
    ""

  fun run(env: (Env | None)): U8 =>
    """
    Run the application, passing thread control to Gtk.
    """
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
  """
  GtkWindow is a wrapper class for the GtkWindow C type.
  It exposes the most common functions for window interaction from the Gtk library.
  """

  var _cpointer: Pointer[_GtkWindow] tag

  var title: String
  var size: Array[I32]

  var window: Pointer[_GtkWidget]

  new create(app: GtkApplication, win_type: U8, win_title: String, win_size: Array[I32]) =>
    """
    Create a new GtkWindow, as a top-level element of `app`, with the given title and size.
    """
    title = win_title
    size = win_size

    window =
    if win_type == WindowType.application() then
      // Call the GTK library to make a new window for the application
      @gtk_application_window_new(app.get_pointer())
    else
      @gtk_window_new(win_type)
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

  new from_pointer(app: GtkApplication, ptr: Pointer[_GtkWidget]) =>
    // Set up pointers
    window = ptr
    _cpointer = @gtk_window_cast(window)

    // Get the window size
    var w: I32 = 0
    var h: I32 = 0
    @gtk_window_get_size[None](_cpointer, addressof w, addressof h)
    // And set it
    size = [w; h]
    try
      @gtk_window_set_default_size[None](_cpointer, size.apply(0)?, size.apply(1)?)
    end

    // Get the window title
    title = recover String.copy_cstring(@gtk_window_get_title[Pointer[U8]](_cpointer)) end

    // Notify the application about the new window
    app.add_window(this)

  fun show_window() =>
    """
    Show the window.
    """
    // Make it visible
    @gtk_widget_show_all[None](window)

  fun move(x: U16, y: U16) =>
    """
    Move the window to the given x and y, with (0, 0) representing the top left of the screen.
    """
    @gtk_window_move[None](window, x, y)

  fun bring_to_top() =>
    """
    Bring this window to focus, above other windows and programs.
    """
    @gtk_window_present[None](window)

  fun get_pointer(): Pointer[_GtkWindow] tag =>
    """
    Get the pointer to the underlying GtkWindow object.
    """
    _cpointer

  fun get_title(): String =>
    """
    Get the current window title.
    """
    title

  fun ref set_title(new_title: String) =>
    """
    Set the window title.
    """
    title = new_title
    @gtk_window_set_title[None](_cpointer, title.cstring())

  fun get_screen(): Pointer[_GdkScreen] =>
    """
    Get the hardware screen which this window is on.
    This can change due to multiple workspaces, or multi-monitor setups.
    """
    @gtk_window_get_screen[Pointer[_GdkScreen]](window)

  fun set_screen(screen: Pointer[_GdkScreen]) =>
    """
    Set the screen which this window is on.
    """
    @gtk_window_set_screen[None](window, screen)
