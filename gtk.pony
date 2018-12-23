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
use "path:./"
use "lib:gtkhelp"

use @gtk_application_new[Pointer[_GtkApplication]](application_id: Pointer[U8] tag, flags: U8)
use @gtk_application_window_new[Pointer[_GtkWidget]](app: Pointer[_GtkApplication] val)
use @g_signal_connect_generic[None](instance: Pointer[_GtkApplication] val, detailed_signal: Pointer[U8] tag, c_handler: _GCallback, data: U8)

use @g_application_cast[Pointer[_GApplication] val](app: Pointer[_GtkApplication] val)
use @g_callback_cast[_GCallback](func: @{(Pointer[_GtkApplication] val, U8): None})
use @gtk_window_cast[Pointer[_GtkWindow]](window: Pointer[_GtkWidget])

primitive _GtkApplication
primitive _GtkWidget
primitive _GtkWindow

primitive _GApplication

primitive _GType
primitive _GTypeInstance

primitive _GCallback


class GtkApplication

  var windows: Array[GtkWindow]
  var cpointer: Pointer[_GtkApplication] val

  new create(org_name: String) =>
    cpointer = recover val
      @gtk_application_new(org_name.cstring(), 0)
    end
    windows = []

  fun get_pointer(): Pointer[_GtkApplication] val =>
    cpointer

  fun cast_to_g_app(): Pointer[_GApplication] val =>
    @g_application_cast(this.get_pointer())

  fun register_callback(callback_event: String, callback: _GCallback, data: U8) =>
    // Register the activate function as a callback for app startup
    @g_signal_connect_generic(this.get_pointer(), callback_event.cstring(), callback, data)

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

  new create(app: Pointer[_GtkApplication] val, win_title: String, win_size: Array[I32]) =>
    title = win_title
    size = win_size

    var app_cast = @g_application_cast(app)

    // Call the GTK library to make a new window for the application
    var window = @gtk_application_window_new[Pointer[_GtkWidget]](app)
    // Set the title
    @gtk_window_set_title[None](@gtk_window_cast(window), title.cstring())
    // Set the window size
    try
      @gtk_window_set_default_size[None](@gtk_window_cast(window), size.apply(0)?, size.apply(1)?)
    end
    // Make it visible
    @gtk_widget_show_all[None](window)
