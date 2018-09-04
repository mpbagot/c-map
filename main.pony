use "lib:gtk-3"
use "lib:gobject-2.0"
use "lib:cairo-gobject"
use "lib:glib-2.0"
use "lib:gdk-3"
use "lib:pangocairo-1.0"
use "lib:pango-1.0"
use "lib:atk-1.0"
use "lib:cairo"
use "lib:gdk_pixbuf-2.0"
use "lib:gio-2.0"
use "path:/home/mitchell/build/test/"
use "lib:gtkhelp"

use "lib:OpenCL"


use @gtk_application_new[Pointer[_GtkApplication]](application_id: Pointer[U8] tag, flags: U8)
use @gtk_application_window_new[Pointer[_GtkWidget]](app: Pointer[_GtkApplication])
use @g_signal_connect_generic[None](instance: Pointer[_GtkApplication] tag, detailed_signal: Pointer[U8] tag, c_handler: _GCallback, data: U8)

use @g_application_cast[Pointer[_GApplication]](app: Pointer[_GtkApplication])
use @g_callback_cast[_GCallback](func: @{(Pointer[_GtkApplication], U8): None})
use @gtk_window_cast[Pointer[_GtkWindow]](window: Pointer[_GtkWidget])

primitive _GtkApplication
primitive _GtkWidget
primitive _GtkWindow

primitive _GApplication

primitive _GType
primitive _GTypeInstance

primitive _GCallback

actor Main
  new create(env: Env) =>
    env.out.print("Starting GTK+ Window...")
    var status: U8 = 0

    var app = @gtk_application_new("org.rest_ashore.cmap".cstring(), 0)
    var app_cast = @g_application_cast(app)
    var callback = @g_callback_cast(addressof this.activate)
    @g_signal_connect_generic(app, "activate".cstring(), callback, U8(0))
    status = @g_application_run[U8](app_cast, env.args.size(), env.args.cpointer())
    @g_object_unref[None](app)

    // TODO Why does this second cast throw a warning?
    var app_cast2 = @g_application_cast(app)

    status

  fun @activate(app: Pointer[_GtkApplication], user_data: U8) =>
    var app_cast = @g_application_cast(app)
    var window = @gtk_application_window_new[Pointer[_GtkWidget]](app)
    @gtk_window_set_title[None](@gtk_window_cast(window), "C-MAP".cstring())
    @gtk_window_set_default_size[None](@gtk_window_cast(window), I32(1024), I32(576))
    @gtk_widget_show_all[None](window)

    None
