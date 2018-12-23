use "files"

class ProjectLoader
  fun load_project(config: Config, filepath: FilePath): File =>
    // TODO What is the structure for the project files?
    File.open(filepath)
