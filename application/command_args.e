note
    description: "Command‑line arguments parser for SimplexEiffel"

class
    COMMAND_ARGS

inherit
    ARGUMENTS_32
    EXCEPTIONS

create
    make

feature {NONE} -- init

    make
        local
            i: INTEGER
            arg: STRING_32
        do
            -- default values
            separator := ' '
            debug_mode := False
            verbose_mode := False
            use_integer := False
            input_file := Void

            from i := 1
            until i > argument_count
            loop
                arg := argument (i)

                if arg.is_case_insensitive_equal ("-h") or arg.is_case_insensitive_equal ("--help") then
                    show_help
                    die (0)
                elseif arg.is_case_insensitive_equal ("-d") or arg.is_case_insensitive_equal ("--debug") then
                    debug_mode := True
                elseif arg.is_case_insensitive_equal ("-v") or arg.is_case_insensitive_equal ("--verbose") then
                    verbose_mode := True
                elseif arg.is_case_insensitive_equal ("-i") or arg.is_case_insensitive_equal ("--integer") then
                    use_integer := True
                elseif arg.is_case_insensitive_equal ("-s") or arg.is_case_insensitive_equal ("--separator") then
                    i := i + 1
                    if i <= argument_count then
                        separator := argument (i).to_string_8.item (1)
                    else
                        print ("[ERROR] Missing argument for --separator%N")
                        show_help
                        die (1)
                    end
                elseif arg.starts_with ("-") then
                    print ("[ERROR] Unknown option: " + arg.to_string_8 + "%N")
                    show_help
                    die (1)
                else
                    -- first non‑option argument = input file
                    if input_file = Void then
                        input_file := arg
                    else
                        print ("[WARN] Ignoring extra argument: " + arg.to_string_8 + "%N")
                    end
                end
                i := i + 1
            end
        end

feature -- getters

    separator: CHARACTER
    debug_mode: BOOLEAN
    verbose_mode: BOOLEAN
    use_integer: BOOLEAN
    input_file: detachable STRING_32

feature {NONE}

    show_help
        do
            print ("%
                %SimplexEiffel – Linear Programming solver%N%
                %Usage: simplex_app [options] [input_file]%N%
                %Options:%N%
                %  -h, --help        show this help%N%
                %  -d, --debug       enable debug output%N%
                %  -v, --verbose     enable verbose output%N%
                %  -i, --integer     use integer arithmetic (rounding)%N%
                %  -s, --separator C use character C as field separator (default space)%N%
                %If no input_file is given – data are read from STDIN.%N%
                %")
        end

end
