note
	description : "Error list iterator"
	date        : "$Date$"
	revision    : "$Revision$"

class
	ERROR_ITERATOR

inherit
	ERROR_VISITOR

feature -- Access

	process_error (e: ERROR)
		do
		end

	process_custom (e: ERROR_CUSTOM)
		do
			process_error (e)
		end

	process_group (g: ERROR_GROUP)
		do
			if attached g.sub_errors as err then
				from
					err.start
				until
					err.after
				loop
					process_error (err.item)
					err.forth
				end
			end
		end

end
