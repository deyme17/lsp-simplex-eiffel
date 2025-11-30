note
	description: "Real numbers - precise floating-point arithmetic (IEEE 754)"

class
	REAL_NUMBER

inherit
	NUMBER
		redefine
			default_create,
			out,
			is_equal
		end

create
	make,
	make_from_integer,
	default_create

feature {NONE} -- constructor

	make (v: REAL_64)
		do
			internal_value := v
		ensure
			value_set: value = v
		end

	make_from_integer (i: INTEGER)
		do
			internal_value := i.to_double
		ensure
			correct_conversion: value = i.to_double
		end

	default_create
		do
			internal_value := 0.0
		ensure then
			is_zero: value = 0.0
		end

feature
	value: REAL_64
		do
			Result := internal_value
		end

feature -- arithmetic

	plus alias "+" (other: NUMBER): REAL_NUMBER
		do
			create Result.make (value + other.value)
		ensure then
			exact_sum: (Result.value - (value + other.value)).abs < 0.000001
		end

	minus alias "-" (other: NUMBER): REAL_NUMBER
		do
			create Result.make (value - other.value)
		ensure then
			exact_difference: (Result.value - (value - other.value)).abs < 0.000001
		end

	product alias "*" (other: NUMBER): REAL_NUMBER
		do
			create Result.make (value * other.value)
		ensure then
			exact_product: (Result.value - (value * other.value)).abs < 0.000001
		end

	quotient alias "/" (other: NUMBER): REAL_NUMBER
		do
			create Result.make (value / other.value)
		ensure then
			exact_division: (Result.value - (value / other.value)).abs < 0.000001
			inverse_holds: ((Result.value * other.value) - value).abs < 0.001
		end

feature -- unary operations

	negative alias "-": REAL_NUMBER
		do
			create Result.make (-value)
		ensure
			correct_negation: Result.value = -value
		end

	absolute: REAL_NUMBER
		do
			create Result.make (value.abs)
		ensure
			non_negative: Result.value >= 0
			correct_for_positive: value >= 0 implies Result.value = value
			correct_for_negative: value < 0 implies Result.value = -value
		end

feature -- comparison
	is_equal (other: like Current): BOOLEAN
	    do
	        if attached other as o then
	            Result := (value - o.value).abs < 0.0000001
	        end
	    ensure then
	        symmetry: (other /= Void implies (Result = other.is_equal (Current)))
	    end

feature -- converting
	rounded: INTEGER_NUMBER
		local
			rounded_value: REAL_64
		do
			rounded_value := value.rounded
			create Result.make (rounded_value.truncated_to_integer)
		ensure
			close_to_original: (Result.value - value).abs <= 0.5
		end

feature -- print
	out: STRING
	    do
	        Result := value.out
	    ensure then
	        not_void: Result /= Void
	    end

	debug_output: STRING
			-- detailed printing for debugging
		do
			create Result.make_from_string ("REAL(")
			Result.append (value.out)
			Result.append (")")
		ensure
			not_empty: not Result.is_empty
		end

feature {NONE} -- implementation
	internal_value: REAL_64

end
