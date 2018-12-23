//use "lib:OpenCL"

actor Main
  new create(env: Env) =>
    var app = GtkApplication("org.rest_ashore.cmap")

    var callback = @g_callback_cast(addressof this.activate)
    app.register_callback("activate", callback, U8(0))

    // This call locks up this thread
    // Actors should be forked before this spot in the code
    app.run(env)

  fun @activate(app: Pointer[_GtkApplication] val, user_data: U8) =>
    GtkWindow(app, "C-MAP", [I32(1024); I32(576)])

    None
