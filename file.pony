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
