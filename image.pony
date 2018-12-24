
primitive InterpolationTypes
  fun nearest(): U8 => 0
  fun tiles(): U8 => 1
  fun bilinear(): U8 => 2
  fun hyper(): U8 => 3

class Image

  var base_pixbuf: Pointer[_GdkPixbuf]
  var current_pixbuf: Pointer[_GdkPixbuf]
  var size_x: U16 = 0
  var size_y: U16 = 0
  var interp_type: U8 = InterpolationTypes.nearest()

  new create(filename: String) =>
    var err: Pointer[_GError] = @g_error_new_for_pony()
    // Try to load the file width and height into size_x and size_y
    @gdk_pixbuf_get_file_info(filename.cstring(), addressof size_x, addressof size_y)
    // Load the base image into a pixbuf and create the current_pixbuf
    base_pixbuf = @gdk_pixbuf_new_from_file(filename.cstring(), addressof err)
    current_pixbuf = @gdk_pixbuf_scale_simple(base_pixbuf, size_x, size_y, interp_type)

  fun ref scale(size: Array[U16]): Pointer[_GdkPixbuf] ? =>
    size_x = size.apply(0)?
    size_y = size.apply(1)?
    current_pixbuf = @gdk_pixbuf_scale_simple(base_pixbuf, size_x, size_y, interp_type)
