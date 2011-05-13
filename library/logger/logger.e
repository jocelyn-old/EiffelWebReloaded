note
	description : "Objects that represent an log tracer"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	LOGGER

feature -- Access

	log (a_level: INTEGER; m: STRING)
		deferred
		end

	logf (a_level: INTEGER; fmt: STRING; args: ARRAY [detachable ANY])
			-- Log message formatted with arguments
			-- replace $1 with first value from args ... and so on
		local
			s,num: STRING
			i,j,n,low: INTEGER
			c: CHARACTER
		do
			if args.count > 0 then
				from
					i := 1
					n := fmt.count
					create s.make (n)
					create num.make_empty
					low := args.lower
				until
					i > n
				loop
					c := fmt[i]
					inspect c
					when '$' then
						from
							j := 1
						until
							i+j > n or else not fmt[i+j].is_digit
						loop
							num.extend (fmt[i+j])
							i := i + 1
						end
						if num.count > 0 then
							i := i + j - 1
							j := num.to_integer - low + 1
							if args.valid_index (j) then
								if attached args[j] as v then
									s.append (v.out)
								else
									s.append ("Void")
								end
							else
								s.extend (c)
								s.append (num)
							end
							num.wipe_out
						else
							s.extend (c)
						end
					else
						s.extend (c)
					end
					i := i + 1
				end
			else
				s := fmt
			end
			log (a_level, s)
		end

	close
		do
		end

note
	copyright: "Copyright (c) 1984-2011, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
