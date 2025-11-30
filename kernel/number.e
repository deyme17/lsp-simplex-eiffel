note
	description: "Abstract numeric type - base for all number implementations"

deferred class
	NUMBER

inherit
    ANY
        redefine
            out,
            is_equal
        end

feature
	value: REAL_64
		deferred
		end

feature -- comparison

	is_less alias "<" (other: NUMBER): BOOLEAN
		require
			other_exists: other /= Void
		do
			Result := value < other.value
		ensure
			definition: Result = (value < other.value)
		end

	is_greater alias ">" (other: NUMBER): BOOLEAN
		require
			other_exists: other /= Void
		do
			Result := value > other.value
		ensure
			definition: Result = (value > other.value)
		end

	is_equal (other: like Current): BOOLEAN
		do
			if attached other as o then
				Result := value = o.value
			end
		end

feature -- arithmetic

	plus alias "+" (other: NUMBER): like Current
		require
			other_exists: other /= Void
		deferred
		ensure
			not_void: Result /= Void
			commutative: (Result.value - (value + other.value)).abs < 0.0001
		end

	minus alias "-" (other: NUMBER): like Current
		require
			other_exists: other /= Void
		deferred
		ensure
			not_void: Result /= Void
			correct_math: (Result.value - (value - other.value)).abs < 0.0001
		end

	product alias "*" (other: NUMBER): like Current
		require
			other_exists: other /= Void
		deferred
		ensure
			not_void: Result /= Void
			correct_math: (Result.value - (value * other.value)).abs < 0.0001
		end

	quotient alias "/" (other: NUMBER): like Current
		require
			other_exists: other /= Void
			not_zero: other.value /= 0.0
		deferred
		ensure
			not_void: Result /= Void
			correct_division: (Result.value - (value / other.value)).abs < 0.0001
		end

feature -- converting

	to_double: REAL_64
		do
			Result := value
		ensure
			same_value: Result = value
		end

	to_integer: INTEGER
		do
			Result := value.truncated_to_integer
		end

	to_string: STRING
		do
			create Result.make_from_string (value.out)
		ensure
			not_empty: not Result.is_empty
		end

feature -- print

	out: STRING
		do
			Result := to_string
		end

end
