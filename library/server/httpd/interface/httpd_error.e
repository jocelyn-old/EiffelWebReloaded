note
	description: "Summary description for {HTTPD_ERROR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_ERROR

inherit
	ERROR

	HTTP_STATUS_CODE_MESSAGES

create
	make

feature {NONE} -- Initialization

	make (a_code: INTEGER)
		do
			code := a_code
			name := "HTTP Error"
			if attached http_status_code_message (a_code) as m then
				name := m
			end
		end

feature -- Access

	code: INTEGER

	name: STRING

	message: detachable STRING_32

feature -- Element change

	set_message (m: like message)
			-- Set `message' to `m'
		require
			m_attached: m /= Void
		do
			message := m
		end

feature -- Visitor

	process (a_visitor: ERROR_VISITOR)
			-- Process Current using `a_visitor'.
		do
			a_visitor.process_error (Current)
		end

end
