note
    description: "Context for simplex algorithm."

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

            use_invariants := False
        ensure
            not_loaded: not use_invariants
        end

feature -- factory
    make_zero: T
        do
            create Result
        end

feature -- state flags
    use_invariants: BOOLEAN

feature -- dimensions
    num_constraints: INTEGER
    num_variables: INTEGER

feature -- objective function
    c: HASH_TABLE [T, INTEGER]
    v: T

feature -- constraints
    b_values: HASH_TABLE [T, INTEGER]
    A: HASH_TABLE [HASH_TABLE [T, INTEGER], INTEGER]

feature -- basis and nonbasis
    B: ARRAYED_LIST [INTEGER]
    N: ARRAYED_LIST [INTEGER]

feature -- solution
    x: ARRAY [T]

feature -- setters

    enable_invariants
        do
            use_invariants := True
        end

	disable_invariants
        do
            use_invariants := False
        end

    set_dimensions (a_m, a_n: INTEGER)
        local
            default_t: T
        do
            num_constraints := a_m
            num_variables := a_n
            create default_t
            create x.make_filled (make_zero, 1, num_variables + num_constraints)

            use_invariants := False
        end

    reset
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

            use_invariants := False
        end

    set_v (new_v: T)
        do
            v := new_v
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
    x_size_matches_total: x.count = num_variables + num_constraints
    c_count_matches_n:
        use_invariants implies c.count = num_variables
    b_count_matches_m:
        use_invariants implies b_values.count = num_constraints
    A_count_matches_m:
        use_invariants implies A.count = num_constraints
    B_count_matches_m:
        use_invariants implies B.count = num_constraints
    N_count_matches_n:
        use_invariants implies N.count = num_variables
    basis_and_nonbasis_disjoint:
        use_invariants implies (across B as bi all not N.has (bi.item) end)
    basis_and_nonbasis_cover_all:
        use_invariants implies (across 1 |..| (num_variables + num_constraints) as i all B.has (i.item) or N.has (i.item) end)
	all_b_non_negative:
	    use_invariants implies
	        (across B as bi all
	            (attached b_values[bi.item] as bv and then bv.value >= -0.0001)
	        end)

end
