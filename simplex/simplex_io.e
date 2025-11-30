note
    description: "Input/Output for SimplexM: read problem from STDIN"

class
    SIMPLEX_IO [T -> REAL_NUMBER create default_create, make end]

inherit
    EXCEPTIONS
        redefine
            out
        end

create
    make

feature {NONE} -- constructor
    make (a_context: SIMPLEX_CONTEXT [T]; a_separator: CHARACTER; a_debug: BOOLEAN)
        do
            context := a_context
            separator := a_separator
            debug_mode := a_debug
            line_number := 0
            create last_line.make_empty
        end

feature -- getters
    context: SIMPLEX_CONTEXT [T]
    separator: CHARACTER
    debug_mode: BOOLEAN
    line_number: INTEGER

feature -- operations
    read_from_stdin: BOOLEAN
        local
            l_line: STRING
            l_fields: LIST [STRING]
            l_A_row: HASH_TABLE [T, INTEGER]
            l_b: T
            i: INTEGER
            temp_m: INTEGER
        do
            Result := True
            line_number := 0

            -- 1. read c vector
            if not read_line then
                Result := False
            else
                l_line := last_line
                l_fields := l_line.split (separator)
                clean_fields (l_fields)

                if l_fields.is_empty then
                    log_error ("Empty objective line")
                    Result := False
                else
                    context.set_dimensions (0, l_fields.count)
                    across 1 |..| l_fields.count as ic loop
                        context.c.put (parse_value (l_fields[ic.item]), ic.item)
                        context.N.extend (ic.item)
                    end
                end
            end

            -- 2. read A and b
            if Result then
                temp_m := 0
                from i := 1 until not read_line or not Result loop
                    l_line := last_line
                    l_fields := l_line.split (separator)
                    clean_fields (l_fields)

                    if not l_fields.is_empty then
                        if l_fields.count /= context.num_variables + 1 then
                            log_error ("Row " + i.out + ": expected " + (context.num_variables + 1).out + " values, got " + l_fields.count.out)
                            Result := False
                        else
                            create l_A_row.make (5)
                            across 1 |..| context.num_variables as j loop
                                l_A_row.put (parse_value (l_fields[j.item]), j.item)
                            end
                            l_b := parse_value (l_fields[l_fields.count])

                            if i = 1 then context.set_dimensions (0, context.num_variables) end

                            temp_m := temp_m + 1
                            context.A.put (l_A_row, context.num_variables + temp_m)
                            context.b_values.put (l_b, context.num_variables + temp_m)
                            context.B.extend (context.num_variables + temp_m)
                        end
                        i := i + 1
                    end
                end
            end

            -- finalize
            if Result then
                context.set_dimensions (temp_m, context.num_variables)
                context.enable_invariants
            end
        end

feature {NONE} -- implementation
    last_line: STRING

	read_line: BOOLEAN
        local
            l_line: STRING
            done: BOOLEAN
        do
            from
                done := False
                Result := False
            until
                done
            loop
                io.read_line

                if io.input.end_of_file and (io.last_string = Void or else io.last_string.is_empty) then
                    done := True
                    Result := False
                elseif io.last_string = Void then
                    done := True
                    Result := False
                else
                    line_number := line_number + 1
                    l_line := io.last_string.twin
                    l_line.left_adjust
                    l_line.right_adjust

                    if not l_line.is_empty and then not l_line.starts_with ("#") then
                        last_line := l_line
                        Result := True
                        done := True
                    elseif io.input.end_of_file then
                        done := True
                        Result := False
                    end
                end
            end
        end

    clean_fields (fields: LIST [STRING])
            -- remove empty strings and trim whitespace
        do
            from fields.start until fields.after loop
                fields.item.left_adjust
                fields.item.right_adjust
                if fields.item.is_empty then
                    fields.remove
                else
                    fields.forth
                end
            end
        end

    parse_value (s: STRING): T
        local
            l_double: REAL_64
        do
            if s.is_double then
                l_double := s.to_double
                create Result.make (l_double)
            else
                print ("[FATAL ERROR] Input value '" + s + "' is not a number.%N")
                die (1)
                create Result.default_create -- unreachable, just for compiler
            end
        end

    log_error (msg: STRING)
        do
            print ("[ERROR] Line " + line_number.out + ": " + msg + "%N")
        end

feature -- print
    out: STRING
        do
            Result := "SIMPLEX_IO[sep='" + separator.out + "', debug=" + debug_mode.out + "]"
        end

end
