note
	description: "Summary description for {HTTPD_RESPONSE}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTPD_RESPONSE

feature {NONE} -- Initialization

	initialize
		do
			create headers.make
		end

feature -- Recycle

	recycle
		do
			headers.recycle
		end

feature -- Access

	headers: HTTPD_HEADER

feature -- Query

	string: STRING
			-- String representation of the response
		deferred
		ensure
			result_attached: Result /= Void
		end

	send (output: HTTPD_SERVER_OUTPUT)
		do
			output.put_string (string)
		end

invariant
	header_attached: headers /= Void

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
