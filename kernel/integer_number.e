note
	description: "Integer numbers with rounding - the LSP violation experiment"
	warning: "This class VIOLATES contracts from REAL_NUMBER parent!"
	purpose: "Research tool to demonstrate Design by Contract catches semantic bugs"

class
	INTEGER_NUMBER

inherit
	REAL_NUMBER
		redefine
			plus, minus, product, quotient,
			negative, absolute,
			make, make_from_integer, default_create,
			out, debug_output, is_equal
		end

create
	make,
	make_from_integer,
	default_create

feature {NONE} -- constructors

	make (v: REAL_64)
		do
			internal_value := round_value(v)
		ensure then
			is_integer: internal_value = internal_value.truncated_to_integer.to_double
		end

	make_from_integer (i: INTEGER)
		do
			internal_value := i.to_double
		ensure then
			exact_integer: internal_value = i
		end

	default_create
		do
			internal_value := 0.0
		end

feature -- arithmetic

	plus alias "+" (other: NUMBER): INTEGER_NUMBER
		do
			create Result.make(value + round_value(other.value))
		end

	minus alias "-" (other: NUMBER): INTEGER_NUMBER
		do
			create Result.make(value - round_value(other.value))
		end

	product alias "*" (other: NUMBER): INTEGER_NUMBER
			-- !!! double rounding !!!
		do
			create Result.make(value * round_value(other.value))
		end

	quotient alias "/" (other: NUMBER): INTEGER_NUMBER
			-- !!! double rounding !!
		do
			create Result.make(round_value(value / round_value(other.value)))
		end

feature -- unary operations
	negative alias "-": INTEGER_NUMBER
		do
			create Result.make(-value)
		end

	absolute: INTEGER_NUMBER
		do
			create Result.make(value.abs)
		end

feature -- comparison
	is_equal (other: like Current): BOOLEAN
		do
			if attached other as o then
				Result := value = o.value  -- exact match for integers
			end
		end

feature -- rounding modes
	set_rounding_mode (mode: INTEGER)
			-- 0: to_even (banker's), 1: away_from_zero, 2: toward_zero, 3: toward_negative, 4: toward_positive
		require
			valid_mode: mode >= 0 and mode <= 4
		do
			rounding_mode := mode
		ensure
			mode_set: rounding_mode = mode
		end

	rounding_mode: INTEGER

feature -- output
	out: STRING
		do
			Result := value.truncated_to_integer.out
		end

	debug_output: STRING
		do
			create Result.make_from_string("INT(")
			Result.append(value.truncated_to_integer.out)
			Result.append(")")
		end

feature {NONE} -- implementation
	round_value (v: REAL_64): REAL_64
	    do
	        inspect rounding_mode
	        when 0 then
	            Result := v.rounded
	        when 1 then
	            if v >= 0 then
	                debug
		                Result := (v + 0.5).floor
	                end
	            else
	                Result := (v - 0.5).ceiling
	            end
	        when 2 then
	            Result := v.truncated_to_integer
	        when 3 then
	            Result := v.floor
	        when 4 then
	            Result := v.ceiling
	        else
	            Result := v.rounded
	        end
	    ensure
	        is_integer: Result = Result.truncated_to_integer
	    end

invariant
    always_integer: internal_value = internal_value.truncated_to_integer

end
