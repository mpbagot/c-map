use "files"
use "cli"

class Config

  var project_file: (ProjectFile | None) = None
  var ui_string: (String | None) = None

  new create(env: Env) ? =>
    let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end

    // TODO What config options are available?
    let cli_spec =
      try
        CommandSpec.leaf("c-map", "program description here", [
            OptionSpec.bool("headless", "Run C-MAP without a graphical interface.", 'H', false)
          ], [
            ArgSpec.string_seq("files", "The list of project files to open.")
            ])?.>add_help()?
      else
        env.out.print("Please send this to the developer:")
        env.out.print("CommandSpec creation in config.pony failed.")
        env.exitcode(-1)
        error
      end

    let cmd =
      match CommandParser(cli_spec).parse(env.args, env.vars)
      | let c: Command => c
      | let ch: CommandHelp =>
        ch.print_help(env.out)
        env.exitcode(0)
        error
      | let se: SyntaxError =>
        env.out.print(se.string())
        env.exitcode(1)
        error
      end

    if cmd.option("headless").bool() then
      env.out.print("headless arg seen")
    end

    for arg in cmd.arg("files").string_seq().values() do
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
