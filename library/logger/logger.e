note
	description : "Objects that represent an log tracer"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	LOGGER

feature -- Access

	log (a_level: INTEGER; m: STRING)
		deferred
		end

	close
		do
		end

end
