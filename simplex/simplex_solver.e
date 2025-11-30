note
    description: "Main algorithm loop"

class
    SIMPLEX_SOLVER [T -> REAL_NUMBER create default_create, make, make_from_integer end]

create
    make

feature {NONE} -- init

    make (a_context: SIMPLEX_CONTEXT [T]; a_verbose: BOOLEAN)
        do
            context := a_context
            verbose := a_verbose
            create pivot_engine
            status := "Not Started"
            iterations := 0
        ensure
            context_set: context = a_context
        end

feature -- getters
    context: SIMPLEX_CONTEXT [T]
    status: STRING
    iterations: INTEGER
    verbose: BOOLEAN

    pivot_engine: SIMPLEX_PIVOT [T]

	feature -- SOLVER

	    solve
	            -- Run the Simplex algorithm
	        local
	            entering_var: INTEGER
	            leaving_var: INTEGER
	            finished: BOOLEAN
	        do
	            from
	                iterations := 0
	                finished := False
	                status := "Running"
	                log ("%N=== STARTING SIMPLEX (" + ({T}).name + ") ===")
	                print_tableau
	            until
	                finished
	            loop
	                iterations := iterations + 1
	                log ("%N[Step " + iterations.out + "]")

	                -- 1. find entering var (max c_j > 0)
	                entering_var := find_entering_variable

	                if entering_var = 0 then
	                    status := "Optimal"
	                    finished := True
	                    log ("Result: OPTIMAL solution found.")
	                else
	                    if attached context.c [entering_var] as c_val then
	                        log ("  > Entering Variable: x" + entering_var.out + " (coeff: " + c_val.out + ")")
	                    end

	                    -- 2. find leaving var
	                    leaving_var := find_leaving_variable (entering_var)

	                    if leaving_var = 0 then
	                        status := "Unbounded"
	                        finished := True
	                        log ("Result: UNBOUNDED (no limiting constraint).")
	                    else
	                        log ("  > Leaving Variable:  x" + leaving_var.out)

	                        -- 3. pivot
	                        pivot_engine.pivot (context, leaving_var, entering_var)

	                        print_tableau
	                    end
	                end

	                -- max iter
	                if iterations > 1000 then
	                    status := "Timeout"
	                    finished := True
	                    log ("Result: TIMEOUT (Possible cycling due to precision errors).")
	                end
	            end
	            log ("=== FINISHED ===")
	        end

feature {NONE} -- implementation

    find_entering_variable: INTEGER
        local
            max_c: REAL_64
            j: INTEGER
            val: REAL_64
        do
            Result := 0
            max_c := 1.0e-8

            -- log if verbose
            across context.N as n_cursor loop
                j := n_cursor.item
                if attached context.c [j] as c_val then
                    val := c_val.value
                    if val > max_c then
                        max_c := val
                        Result := j
                    end
                end
            end
        end

    find_leaving_variable (entering_col: INTEGER): INTEGER
        local
            min_ratio: REAL_64
            current_ratio: REAL_64
            i: INTEGER
            best_i: INTEGER
            a_val: REAL_64
            b_val: REAL_64
        do
            best_i := 0
            min_ratio := {REAL_64}.max_value

            across context.B as b_cursor loop
                i := b_cursor.item
                if attached context.A [i] as row and then attached row [entering_col] as a_obj then
                    a_val := a_obj.value
                    if a_val > 1.0e-8 then
                        if attached context.b_values [i] as b_obj then
                            b_val := b_obj.value
                            current_ratio := b_val / a_val

                            if current_ratio < min_ratio then
                                min_ratio := current_ratio
                                best_i := i
                            end
                        end
                    end
                end
            end
            Result := best_i
        end

    log (msg: STRING)
        do
            if verbose then
                print (msg + "%N")
            end
        end

	print_tableau
        local
            s: STRING
        do
            if verbose then
                print ("  State: v=" + context.v.out + "%N")

                -- basis
                create s.make_from_string ("  Basis B: {")
                across context.B as b loop
                    if attached context.b_values[b.item] as val then
                        s.append (b.item.out + "=" + val.out + " ")
                    end
                end
                s.append ("}")
                print (s + "%N")

                -- non-basis
                create s.make_from_string ("  Non-Basis N: {")
                across context.N as n loop
                    if attached context.c[n.item] as val then
                        s.append (n.item.out + "(c=" + val.out + ") ")
                    end
                end
                s.append ("}")
                print (s + "%N")
            end
        end

end
