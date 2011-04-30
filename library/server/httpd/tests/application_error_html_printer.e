note
	description: "Summary description for {APPLICATION_ERROR_VISITOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION_ERROR_HTML_PRINTER

inherit
	ERROR_ITERATOR
		redefine
			process_error
		end

create
	make

feature {NONE} -- Initialization

	make (b: like buffer)
		do
			buffer := b
		end

feature -- Access

	buffer: STRING

feature -- Access

	process_error (e: ERROR)
		local
			buf: like buffer
		do
			buf := buffer
			buf.append_string ("<div class=%"error%">")
			buf.append_string ("<span class=%"name%">" + e.name + "</span>")
			buf.append_string ("<span class=%"code%"> (" + e.code.out + ")</span>")
			if attached e.message as m then
				buf.append_string (": <span class=%"message%">" + m + "</span>")
			end
			buf.append_string ("</div>%N")
		end

end
