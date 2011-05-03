note
	description : "Objects that represent an log tracer"
	date        : "$Date$"
	revision    : "$Revision$"

class
	CONSOLE_LOGGER

inherit
	LOGGER

feature -- Access

	log (a_level: INTEGER; m: STRING)
		do
			io.put_string (m)
			io.put_string ("%N")
		end

end
