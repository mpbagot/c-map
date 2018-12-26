actor Main
  new create(env: Env) =>
    // Initialise the GTK application
    var app = GtkApplication("org.rest_ashore.cmap", env)

    var callback = @g_callback_cast(addressof this.init_workspace)
    app.register_callback("activate", callback, app)

    // This call locks up this thread
    // Actors should be forked before this spot in the code
    app.run(env)

  fun @init_workspace(app: Pointer[_GtkApplication] val, user_data: Any ref) =>
    // TODO The window layouts need to be loaded from a file
    // TODO Project files store layout and take priority
    // TODO but a global workspace layout is also stored

    try
      var app_pony: GtkApplication = user_data as GtkApplication
      var builder: UILoader = UILoader(app_pony.environment)
      try
        // Load the pre-loaded project file from the config here
        builder.load_ui_from_string(app_pony.config.ui_string as String)?
      else
        // TODO remove this once window layout loading is done
        GtkWindow(app_pony, WindowType.application(), "C-MAP", [I32(1024); I32(576)]).show_window()
        GtkWindow(app_pony, WindowType.toplevel(), "Toplevel Test", [I32(1024); I32(576)]).show_window()

        // Load the default program layout here
        //builder.load_ui_from_file("default.ui")
      end
    end
