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

  new create(envir: Env) =>
    """
    Initialise a new UILoader with no elements.
    """
    builder = @gtk_builder_new()
    env = envir

  new from_string(ui_string: String, envir: Env) =>
    """
    Initialise a new UILoader with the elements as parsed from a UI description string.
    """
    env = envir
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
    end

  fun ref get_object(object_id: String): Pointer[_GObject] =>
    """
    Get an object with `object_id` from the elements loaded by this UILoader.
    """
    @gtk_builder_get_object(builder, object_id.cstring())
