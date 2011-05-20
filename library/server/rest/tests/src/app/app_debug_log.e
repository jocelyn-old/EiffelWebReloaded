note
	description: "Summary description for APP_DEBUG_LOG."
	date: "$Date$"
	revision: "$Revision$"

class
	APP_DEBUG_LOG

inherit
	APP_REQUEST_HANDLER
		redefine
			initialize,
			hidden
		end

create
	make

feature {NONE} -- Initialization

	make (a_path: STRING; a_output: like output)
		do
			path := a_path
			output := a_output
			description := "Logs "
			initialize
		end

	initialize
		do
			Precursor
			enable_request_method_get
			enable_format_text
		end

feature {NONE} -- Access: Implementation

	output: HTTPD_SERVER_OUTPUT

feature -- Access

	authentication_required: BOOLEAN = False

feature -- Execution

	hidden (henv: REST_ENVIRONMENT): BOOLEAN
			-- Do we hide this application in service publishing
		do
			Result := not henv.authenticated
		end

	execute_application (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			h: HTTPD_HEADER
			s: detachable STRING
			sh_logger: SHARED_LOGGER
			f: RAW_FILE
		do
			create h.make
			h.put_content_type_text_plain

			create sh_logger

			create s.make_empty
			s.append_string ("Logs: ")
			if a_args /= Void and then a_args.same_string ("reset") then
				if attached {FILE_LOGGER} sh_logger.logger as l_file_logger then
					create f.make (l_file_logger.name)
					if f.exists and then f.is_writable then
						f.open_write
						f.close
						s.append_string (" wiped out%N")
						h.put_redirection (url (henv, Void, False), {HTTP_STATUS_CODE}.temp_redirect)
					else
						s.append_string (" no write access%N")
					end
				else
					s.append_string (" not a file log%N")
				end
				h.put_content_length (s.count)
				output.put_string (h.string)
			else
				if attached {FILE_LOGGER} sh_logger.logger as l_file_logger then
					s.append_string ("%N-----------------------------------%N")
					s.append_string (l_file_logger.name)
					s.append_string ("-----------------------------------%N")
					h.put_content_length (s.count + l_file_logger.log_size)
					output.put_string (h.string)
					output.put_file_content (l_file_logger.name)
				else
					s.append_string ("none%N")
					h.put_content_length (s.count)
					output.put_string (h.string)
				end
			end

			h.recycle
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
