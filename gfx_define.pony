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
use @gtk_builder_new[Pointer[_GtkBuilder]]()
use @gtk_builder_new_from_string[Pointer[_GtkBuilder]](string: Pointer[U8] tag, len: USize)
use @g_error_new_for_pony[Pointer[_GError]]()

use @g_signal_connect_generic[None](instance: Pointer[_GtkApplication] val, signal_name: Pointer[U8] tag, c_handler: _GCallback, data: Any)
use @g_signal_connect[None](obj: Pointer[_GObject], signal_name: Pointer[U8] tag, c_handler: _GCallback, data: Any)

use @g_application_cast[Pointer[_GApplication] val](app: Pointer[_GtkApplication] val)
use @g_callback_cast[_GCallback](func: @{(Pointer[_GtkApplication] val, Any ref): None})
use @gtk_window_cast[Pointer[_GtkWindow]](window: Pointer[_GtkWidget])

use @gdk_pixbuf_new_from_file[Pointer[_GdkPixbuf]](filename: Pointer[U8] tag, err: Pointer[Pointer[_GError]])
use @gdk_pixbuf_scale_simple[Pointer[_GdkPixbuf]](src: Pointer[_GdkPixbuf], dest_width: U16, dest_height: U16, interp_type: U8)
use @gdk_pixbuf_get_file_info[Pointer[_GdkPixbufFormat]](filename: Pointer[U8] tag, width: Pointer[U16], height: Pointer[U16])

use @gtk_builder_add_from_file[U8](builder: Pointer[_GtkBuilder], filename: Pointer[U8] tag, err: Pointer[Pointer[_GError]])
use @gtk_builder_get_object[Pointer[_GObject]](builder: Pointer[_GtkBuilder], object_id: Pointer[U8] tag)

primitive _GtkApplication
primitive _GtkWidget
primitive _GtkWindow
primitive _GtkBuilder

primitive _GdkPixbuf
primitive _GdkPixbufFormat

primitive _GApplication
primitive _GObject

primitive _GType
primitive _GTypeInstance

primitive _GCallback
primitive _GError
