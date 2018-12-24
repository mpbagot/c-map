class GtkApplication

  var _windows: Array[GtkWindow]
  var _cpointer: Pointer[_GtkApplication] val

  var config: Config

  new create(org_name: String, env: Env) =>
    _cpointer = recover val
      @gtk_application_new(org_name.cstring(), 0)
    end

    _windows = []
    // Load the config (and project file if required) from the environment args
    config = Config(env)

  fun get_pointer(): Pointer[_GtkApplication] val =>
    _cpointer

  fun cast_to_g_app(): Pointer[_GApplication] val =>
    @g_application_cast(this.get_pointer())

  fun ref set_config(new_config: Config): None =>
    this.config = new_config

  fun register_callback(callback_event: String, callback: _GCallback, data: Any) =>
    // Register the activate function as a callback for app startup
    @g_signal_connect_generic(this.get_pointer(), callback_event.cstring(), callback, data)

  fun ref add_window(window: GtkWindow ref) =>
    _windows.push(window)

  fun run(env: Env): U8 =>
    // Run the program
    var status: U8 = @g_application_run[U8](this.cast_to_g_app(), env.args.size(), env.args.cpointer())
    // Clear memory afterwards
    @g_object_unref[None](this.get_pointer())
    // Return the status integer
    status

class GtkWindow

  var title: String
  var size: Array[I32]

  var window: Pointer[_GtkWidget]

  new create(app: GtkApplication, win_title: String, win_size: Array[I32]) =>
    title = win_title
    size = win_size

    // Call the GTK library to make a new window for the application
    window = @gtk_application_window_new[Pointer[_GtkWidget]](app.get_pointer())
    // Set the title
    @gtk_window_set_title[None](@gtk_window_cast(window), title.cstring())
    // Set the window size
    try
      @gtk_window_set_default_size[None](@gtk_window_cast(window), size.apply(0)?, size.apply(1)?)
    end

    // Notify the application about the new window
    app.add_window(this)

  fun show_window() =>
    // Make it visible
    @gtk_widget_show_all[None](window)
