use "files"
use "json"

class ProjectFile
  """
  ProjectFile is a basic class to control creating, loading and saving C-MAP
  projects to disk.
  """

  new create(config: Config, filepath: FilePath) =>
    """
    Create a new blank project file.
    """

    U8(0)

  new load(config: Config, filepath: FilePath) =>
    """
    Load an existing project file, creating a blank file if unavailable.
    """
    // TODO Unzip the file, parse the JSON config, and load everything into
    U8(0)

class UILoader
  """
  UILoader is a wrapper class for GTKBuilder.
  """

  var builder: Pointer[_GtkBuilder]
  var env: Env
  var app: GtkApplication

  new create(application: GtkApplication) =>
    """
    Initialise a new UILoader with no elements.
    """
    builder = @gtk_builder_new()
    env = application.environment
    app = application

  new from_string(ui_string: String, application: GtkApplication) =>
    """
    Initialise a new UILoader with the elements as parsed from a UI description string.
    """
    env = application.environment
    app = application
    builder = @gtk_builder_new_from_string(ui_string.cstring(), ui_string.size())

  fun ref load_ui_from_string(ui_str: String): None ? =>
    """
    Load a GTK UI from a description string.
    Errors if a syntax error is found in `ui_str`.
    """
    var err: Pointer[_GError] = Pointer[_GError]

    if @gtk_builder_add_from_string[U8](builder, ui_str.cstring(), addressof err) == U8(0) then
      env.out.print("[WARNING] Syntax error with ui_str. UI elements were not loaded.")
      error
    end

  fun ref load_ui_from_file(filename: String): None ? =>
    """
    Load a GTK UI from a .ui description file.
    Errors if file does not exist, or if a syntax error is found.
    """
    var err: Pointer[_GError] = Pointer[_GError]

    if @gtk_builder_add_from_file(builder, filename.cstring(), addressof err) == U8(0) then
      env.out.print("Error loading file: " + filename)
      error
    else
      var i: U8 = 0
      var window: Pointer[_GObject] = @gtk_builder_get_object(builder, "window".cstring())
      repeat
        // Create and show the window
        var ptr = @gtk_widget_cast(window)
        var w: GtkWindow = GtkWindow.from_pointer(app, ptr)
        w.show_window()

        window = @gtk_builder_get_object(builder, ("window" + i.string()).cstring())
        i = i + 1
      until window.is_null() end
      @gtk_builder_connect_signals(builder, None)
    end

  fun ref get_object(object_id: String): Pointer[_GObject] =>
    """
    Get an object with `object_id` from the elements loaded by this UILoader.
    """
    @gtk_builder_get_object(builder, object_id.cstring())
