class Cmap
  var config: Config
  var app: GtkApplication

  new create(application: GtkApplication, conf: Config) =>
    config = conf
    app = application

actor Main
  new create(env: Env) =>
    // Initialise the GTK application
    var app = GtkApplication("org.rest_ashore.cmap", env)

    // Try to load the config, and fail out if an error occurs
    let conf = try
      Config(env)?
    else
      env.exitcode(-1)
      return
    end

    // Store the data into a wrapper class for use in the callback
    let cmap = Cmap(app, conf)

    // TODO This callback is required, but should be integrated into app.run so that it's nicely separated
    var callback = @g_callback_activate_cast(addressof this.init_workspace)
    app.register_callback("activate", callback, cmap)

    // This call locks up this thread
    // Actors should be forked before this spot in the code
    app.run(None)

  fun @init_workspace(app: Pointer[_GtkApplication] tag, user_data: Any ref) =>
    // TODO The window layouts need to be loaded from a file
    // TODO Project files store layout and take priority
    // TODO but a global workspace layout is also stored

    try
      var cmap: Cmap = user_data as Cmap
      var app_pony: GtkApplication = cmap.app
      var conf: Config = cmap.config

      var builder: UILoader = UILoader(app_pony)
      try
        let str = conf.ui_string as String
        if str != "" then
          // Load the pre-loaded project file from the config here
          builder.load_ui_from_string(str)?
        else
          try
            // Load the default program layout here
            @printf[None]("Loading default UI...\n".cstring())
            builder.load_ui_from_file("default.ui")?
            @printf[None]("Default UI loaded.\n".cstring())
          else
            @printf[None]("[ERROR] Default UI file not found!\n".cstring())
            return
          end
        end
      else
        // TODO Do something so that the application doesn't immediately exit
        @printf[None]("Running in headless mode\n".cstring())
      end
    end
