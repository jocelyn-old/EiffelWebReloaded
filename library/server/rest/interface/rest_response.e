note
	description: "Summary description for {REST_RESPONSE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_RESPONSE

inherit
	HTTPD_RESPONSE

create
	make

feature {NONE} -- Initialization

	make (a_api: like api)
		do
			api := a_api
			initialize
		end

feature -- Access

	api: STRING
			-- Associated api query string.

	message: detachable STRING_8
			-- Associated message to send with the response.

feature -- Element change

	set_message (m: like message)
			-- Set `message' to `m'
		do
			message := m
			if m /= Void then
				headers.put_content_length (m.count)
			else
				headers.put_content_length (0)
			end
		end

	append_message (m: attached like message)
			-- Append message `m' to current `message' value
			-- create `message' is Void
		require
			m_not_empty: m /= Void and then not m.is_empty
		do
			if attached message as msg then
				msg.append (m)
			else
				set_message (m.string)
			end
		end

	append_message_file_content (fn: STRING)
			-- Append file content from `fn' to the response
			--| To use with care.
			--| You should avoid using this for big or binary content ...
		local
			f: RAW_FILE
		do
			create f.make (fn)
			if f.exists and then f.is_readable then
				f.open_read
				from
				until
					f.exhausted
				loop
					f.read_stream (1024)
					append_message (f.last_string)
				end
				f.close
			end
		end

feature -- Output

	compute
			-- Compute the string output
		local
			s: STRING
		do
			create s.make_from_string (headers.string)
			if attached message as m then
				s.append_string (m)
			end
			internal_string := s
		end

	string: STRING
		local
			o: like internal_string
		do
			o := internal_string
			if o = Void then
				compute
				o := internal_string
				if o = Void then
					check output_computed: False end
					create o.make_empty
				end
			end
			Result := o
		end

feature {NONE} -- Implementation: output

	internal_string: detachable like string

;note
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
