note
    description: "Performs the Pivot algebraic transformation"

class
    SIMPLEX_PIVOT [T -> REAL_NUMBER create default_create, make, make_from_integer end]

feature -- operation
    pivot (ctx: SIMPLEX_CONTEXT [T]; leaving_var: INTEGER; entering_var: INTEGER)
        require
            valid_leaving: ctx.is_basic (leaving_var)
            valid_entering: ctx.is_nonbasic (entering_var)
        local
            pivot_val: T
            old_row_b: T
            factor: T
            new_val: T
            one: T

            l_leaving_row: HASH_TABLE [T, INTEGER]
            l_current_row: HASH_TABLE [T, INTEGER]

            i, j: INTEGER
        do
        	ctx.disable_invariants

            -- 1. constants
            create one.make_from_integer (1)

            -- 2. access to pivot row
            check attached ctx.A [leaving_var] as r then
                l_leaving_row := r
            end

            check attached l_leaving_row [entering_var] as p then
                pivot_val := p
            end

            check attached ctx.b_values [leaving_var] as b then
                old_row_b := b
            end

            -- 3. update objective func
            if attached ctx.c [entering_var] as c_e then
                factor := c_e
                ctx.set_v (to_t (ctx.v + (factor * old_row_b / pivot_val)))

                debug
                    check
                        inv_obj_val: (ctx.v - (factor * old_row_b / pivot_val)).value.abs < 0.001
                    end
                end

                -- update reduced costs (c)
                across ctx.N as n_cursor loop
                    j := n_cursor.item
                    if j /= entering_var then
                        if attached ctx.c [j] as c_j and attached l_leaving_row [j] as a_lj then
                             new_val := to_t (c_j - (factor * a_lj / pivot_val))
                             ctx.c.force (new_val, j)
                        end
                    end
                end

                -- cost for leaving var
                ctx.c.force (to_t (ctx.make_zero - (factor / pivot_val)), leaving_var)
                ctx.c.remove (entering_var)
            end


            -- 4. update constraints
            across ctx.B as b_cursor loop
                i := b_cursor.item
                if i /= leaving_var then
                    check attached ctx.A [i] as r then l_current_row := r end

                    if attached l_current_row [entering_var] as a_ie then
                        factor := a_ie

                        -- b_i' = b_i - factor * (b_l / pivot)
                        if attached ctx.b_values [i] as b_i then
                            new_val := to_t (b_i - (factor * old_row_b / pivot_val))
                            ctx.b_values.force (new_val, i)
                        end

                        -- update coeffs
                        across ctx.N as n_cursor loop
                            j := n_cursor.item
                            if j /= entering_var then
                                if attached l_current_row [j] as a_ij and attached l_leaving_row [j] as a_lj then
                                    new_val := to_t (a_ij - (factor * a_lj / pivot_val))
                                    l_current_row.force (new_val, j)
                                end
                            end
                        end

                        -- update coeff for leaving var
                        l_current_row.force (to_t (ctx.make_zero - (factor / pivot_val)), leaving_var)
                        l_current_row.remove (entering_var)
                    end
                end
            end


            -- 5. update the pivot row
            ctx.b_values.force (to_t (old_row_b / pivot_val), entering_var)

            -- transform coeffs: a_ej = a_lj / pivot
            across ctx.N as n_cursor loop
                j := n_cursor.item
                if j /= entering_var then
                    if attached l_leaving_row [j] as a_lj then
                        l_leaving_row.force (to_t (a_lj / pivot_val), j)
                    end
                end
            end

            -- leaving var coeff = 1 / pivot
            l_leaving_row.force (to_t (one / pivot_val), leaving_var)
            l_leaving_row.remove (entering_var)


            -- 6. update context
            if leaving_var /= entering_var then
                ctx.A.put (l_leaving_row, entering_var)
                ctx.A.remove (leaving_var)
                ctx.b_values.remove (leaving_var)
            end

            -- 7. update sets B and N
			ctx.B.start
			ctx.B.prune (leaving_var)
			ctx.B.extend (entering_var)

			ctx.N.start
			ctx.N.prune (entering_var)
			ctx.N.extend (leaving_var)

			ctx.enable_invariants

        ensure
            basis_swapped: ctx.is_basic (entering_var) and ctx.is_nonbasic (leaving_var)
            feasible: across ctx.B as b all
                attached ctx.b_values [b.item] as val and then val.value >= -0.00001
            end
        end

feature {NONE} -- helpers
    to_t (n: NUMBER): T
        do
            create Result.make (n.value)
        end

end
