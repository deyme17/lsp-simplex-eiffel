note
    description: "Context for simplex algorithm: all data structures in one place"

class
    SIMPLEX_CONTEXT [T -> REAL_NUMBER create default_create end]

create
    make

feature {NONE} -- constructor
    make
        local
            default_t: T
        do
            create c.make (10)
            create b_values.make (10)
            create A.make (10)
            create B.make (10)
            create N.make (10)
            create default_t
            create x.make_filled (default_t, 1, 0)
            v := make_zero
        ensure
            c_attached: c /= Void
            b_attached: b_values /= Void
            A_attached: A /= Void
            B_attached: B /= Void
            N_attached: N /= Void
            x_attached: x /= Void
            v_attached: v /= Void
        end

feature -- factory
	make_zero: T
	        do
	            create Result
	        ensure
	            result_attached: Result /= Void
	            result_is_zero: Result.value = 0.0
	        end

feature -- dimensions
    num_constraints: INTEGER 							-- number of constraints (basic variables)
    num_variables: INTEGER 								-- number of original variables (nonbasic at start)

feature -- objective function
    c: HASH_TABLE [T, INTEGER] 							-- c[j]: coefficient of nonbasic variable j
    v: T                        						-- current value of objective function

feature -- constraints
    b_values: HASH_TABLE [T, INTEGER] 					-- b[i]: value of basic variable i
    A: HASH_TABLE [HASH_TABLE [T, INTEGER], INTEGER] 	-- A[i][j]: coefficient of nonbasic j in constraint i

feature -- basis and nonbasis
    B: ARRAYED_LIST [INTEGER] 							-- list of basic variable indices (size = num_constraints)
    N: ARRAYED_LIST [INTEGER] 							-- list of nonbasic variable indices (size = num_variables)

feature -- solution
    x: ARRAY [T]

feature -- setters

    set_dimensions (a_m, a_n: INTEGER)
            -- set num_constraints and num_variables, resize x
        require
            positive_m: a_m >= 0
            positive_n: a_n >= 0
        local
            default_t: T
        do
            num_constraints := a_m
            num_variables := a_n
            create default_t
            create x.make_filled (make_zero, 1, num_variables + num_constraints)
        ensure
            m_set: num_constraints = a_m
            n_set: num_variables = a_n
            x_size: x.count = num_variables + num_constraints
            x_lower: x.lower = 1
            x_upper: x.upper = num_variables + num_constraints
        end

    reset
            -- clear data
        local
            default_t: T
        do
            c.wipe_out
            b_values.wipe_out
            A.wipe_out
            B.wipe_out
            N.wipe_out
            num_constraints := 0
            num_variables := 0
            create default_t
            v := make_zero
            create x.make_empty
        ensure
            c_empty: c.is_empty
            b_empty: b_values.is_empty
            A_empty: A.is_empty
            B_empty: B.is_empty
            N_empty: N.is_empty
            m_zero: num_constraints = 0
            n_zero: num_variables = 0
            x_empty: x.is_empty
        end

	set_v (new_v: T)
            -- update objective function value
        do
            v := new_v
        ensure
            v_set: v = new_v
        end

feature -- helpers

    is_valid_index (idx: INTEGER): BOOLEAN
        do
            Result := idx >= 1 and idx <= num_variables + num_constraints
        end

    is_basic (idx: INTEGER): BOOLEAN
        do
            Result := B.has (idx)
        end

    is_nonbasic (idx: INTEGER): BOOLEAN
        do
            Result := N.has (idx)
        end

invariant
    non_negative_dimensions: num_constraints >= 0 and num_variables >= 0
--    c_count_matches_n: c.count = num_variables
--    b_count_matches_m: b_values.count = num_constraints
--    A_count_matches_m: A.count = num_constraints
--    B_count_matches_m: B.count = num_constraints
--    N_count_matches_n: N.count = num_variables
    x_size_matches_total: x.count = num_variables + num_constraints
    x_lower_is_one: x.lower = 1
--    basis_and_nonbasis_disjoint:
--        across B as bi all not N.has (bi.item) end
--    basis_and_nonbasis_cover_all:
--        across 1 |..| (num_variables + num_constraints) as i all B.has (i.item) or N.has (i.item) end
--	all_b_non_negative:
--	    across B as bi all
--	        b_values.has (bi.item) and then
--	        attached b_values[bi.item] as val and then
--	        not (val < make_zero)
--	    end

end
