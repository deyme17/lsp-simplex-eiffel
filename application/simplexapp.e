note
    description: "SimplexEiffel application root class"

class
    SIMPLEXAPP

inherit
    ARGUMENTS_32

create
    make

feature {NONE} -- init

    make
        local
            args: COMMAND_ARGS
            file_path: STRING
        do
            create args.make

            -- input
            if attached args.input_file as f then
                file_path := f.to_string_8
                if args.verbose_mode then
                    print ("# Input file provided: " + file_path + "%N")
                    print ("# (Ensure file content is piped if IO reading fails)%N")
                end
            end

            -- integer vs real flag
            if args.use_integer then
                run_integer_solver (args)
            else
                run_real_solver (args)
            end

        rescue
            if attached {EXCEPTIONS} current as e then
                print ("[FATAL ERROR] Simplex Crashed: ")
                if attached e.exception_trace as trace then
                    print (trace)
                end
            end
        end

feature {NONE} -- solvers

	run_real_solver (args: COMMAND_ARGS)
        local
            ctx: SIMPLEX_CONTEXT [REAL_NUMBER]
            io_parser: SIMPLEX_IO [REAL_NUMBER]
            solver: SIMPLEX_SOLVER [REAL_NUMBER]
        do
            if args.verbose_mode then
                print ("# Running SimplexM (REAL mode)%N")
            end

            create ctx.make
            create io_parser.make (ctx, args.separator, args.debug_mode)

            if io_parser.read_from_stdin then
                create solver.make (ctx, args.verbose_mode)

                solver.solve

                if args.verbose_mode then
                    print ("# max value for function " + ctx.v.out + " (real version)%N")
                    print ("# Status: " + solver.status + "%N")
                    print ("# Iterations: " + solver.iterations.out + "%N")
                else
                    print (ctx.v.out + "%N")
                end
            else
                print ("[ERROR] Failed to read input data.%N")
            end
        end

    run_integer_solver (args: COMMAND_ARGS)
        local
            ctx: SIMPLEX_CONTEXT [INTEGER_NUMBER]
            io_parser: SIMPLEX_IO [INTEGER_NUMBER]
            solver: SIMPLEX_SOLVER [INTEGER_NUMBER]
        do
            if args.verbose_mode then
                print ("# Running SimplexM (INTEGER mode)%N")
            end

            create ctx.make
            create io_parser.make (ctx, args.separator, args.debug_mode)

            if io_parser.read_from_stdin then
                create solver.make (ctx, args.verbose_mode)

                solver.solve

                if args.verbose_mode then
                    print ("# max value for function " + ctx.v.out + " (integer version)%N")
                    print ("# Status: " + solver.status + "%N")
                else
                    print (ctx.v.out + "%N")
                end
            else
                print ("[ERROR] Failed to read input data.%N")
            end
        end

end
