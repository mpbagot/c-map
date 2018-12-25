use "files"

class ProjectLoader
  fun load_project(config: Config, filepath: FilePath): File =>
    // TODO What is the structure for the project files?
    File.open(filepath)

class UILoader

  var builder: Pointer[_GtkBuilder]
  var env: Env

  new create(envir: Env) =>
    builder = @gtk_builder_new()
    env = envir

  new from_string(ui_string: String, envir: Env) =>
    env = envir
    builder = @gtk_builder_new_from_string(ui_string.cstring(), ui_string.size())

  fun ref load_ui_from_file(filename: String): None ? =>
    var err: Pointer[_GError] = @g_error_new_for_pony()

    if @gtk_builder_add_from_file(builder, filename.cstring(), addressof err) == U8(0) then
      env.out.print("Error loading file: " + filename)
      error
    end

  fun ref get_object(object_id: String): Pointer[_GObject] =>
    @gtk_builder_get_object(builder, object_id.cstring())
