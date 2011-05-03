note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	SHARED_LOGGER

feature -- Access

	logger: LOGGER
		do
			Result := logger_cell.item
		end

	logger_cell: CELL [LOGGER]
		once
			create Result.put (create {CONSOLE_LOGGER})
		end

end
