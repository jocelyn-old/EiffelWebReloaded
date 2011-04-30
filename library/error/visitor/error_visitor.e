note
	description : "Objects to visit an ERROR"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	ERROR_VISITOR

feature -- Access

	process_error (e: ERROR)
		deferred
		end

	process_custom (e: ERROR_CUSTOM)
		deferred
		end

	process_group (g: ERROR_GROUP)
		deferred
		end

end
