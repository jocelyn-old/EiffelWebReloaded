note
	description : "Objects that represent an log tracer"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	FILE_LOGGER

inherit
	LOGGER
		redefine
			close
		end

create
	make,
	make_with_filename

feature {NONE} -- Initialization

	make (f: FILE)
		do
			name := f.name
			file := f
		end

	make_with_filename (fn: STRING)
		do
			name := fn
			file := Void
		end

	file: detachable FILE

feature -- Access

	name: STRING

	log_size: INTEGER
		local
			f: FILE
		do
			create {RAW_FILE} f.make (name)
			Result := f.count
		end

	log (a_level: INTEGER; m: STRING)
		local
			f: like file
			b: BOOLEAN
		do
			f := file
			if f = Void then
				b := True
				create {PLAIN_TEXT_FILE} f.make_open_append (name)
			end
			f.put_string (m)
			f.put_string ("%N")
			f.flush
			if b then
				f.close
			end
		end

	close
		do
			Precursor
			if attached file as f and then not f.is_closed then
				f.close
			end
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
