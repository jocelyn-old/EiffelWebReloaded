note
	description : "Null error visitor"
	date        : "$Date$"
	revision    : "$Revision$"

class
	ERROR_NULL_VISITOR

inherit
	ERROR_VISITOR

feature -- Access

	process_error (e: ERROR)
		do
		end

	process_custom (e: ERROR_CUSTOM)
		do
		end

	process_group (g: ERROR_GROUP)
		do
		end

end
