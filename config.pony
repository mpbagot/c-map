use "files"
use "options"

class Config

  var project_file: (ProjectFile | None) = None
  var ui_string: (String | None) = None

  new create(env: Env) =>
    let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end
    var options = Options(env.args.slice(1, env.args.size(), 1))

    // TODO What config options are available?
    options
      .add("headless")
      .add("help")

    for option in options do
      match option
      | ("headless", let arg: None) => env.out.print("headless arg seen")
      | let err: ParseError => err.report(env.out); env.out.print("Use --help to list options.")
      end
    end

    for arg in options.remaining().values() do
      if not arg.at("-", 0) then
        var valarg = recover val
          arg.clone()
        end
        // Argument is a project file name
        try
          var filepath: FilePath = FilePath(env.root as AmbientAuth, valarg, caps)?

          if not filepath.exists() then
            env.out.print("[WARNING] Project file \"" + valarg + "\" couldn't be loaded.")
          else
            env.out.print("[NOTE] Loading project file: " + valarg)
            project_file = ProjectFile.load(this, filepath)
          end
        end
      end
    end

  fun usage(env: Env) =>
    env.out.print("C-MAP Configuration Argument Options:")
