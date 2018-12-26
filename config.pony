use "files"

class Config

  var project_file: (File | None) = None
  var ui_string: (String | None) = None

  new create(env: Env) =>
    let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end

    for arg in env.args.slice(1, env.args.size(), 1).values() do
      if arg.at("--", 0) then
        // Argument is a config option
        // TODO What config options are available?
        U8(0)
      else
        // Argument is a project file name
        try
          var filepath = FilePath(env.root as AmbientAuth, arg, caps)?

          if not filepath.exists() then
            env.out.print("[WARNING] Project File couldn't be loaded.")
          else
            env.out.print("[NOTE] Loading project file: " + arg)
            project_file = ProjectLoader.load_project(this, filepath)
          end
        end
      end
    end
