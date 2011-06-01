note
	description: "Summary description for {APP_ACCOUNT_VERIFY_CREDENTIAL}."
	date: "$Date$"
	revision: "$Revision$"

class
	APP_ACCOUNT_VERIFY_CREDENTIAL

inherit
	APP_REQUEST_HANDLER
		redefine
			initialize
		end

create
	make

feature {NONE} -- Initialization

	make (a_path: STRING)
		do
			path := a_path
			description := "Verify credentials"
			initialize
		end

	initialize
		do
			Precursor
			enable_request_method_get
			enable_format_json
			enable_format_xml
			enable_format_text
		end

feature -- Access

	authentication_required: BOOLEAN = True

feature -- Execution

	execute_application (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			l_full: BOOLEAN
			rep: detachable REST_RESPONSE
			l_login: STRING_8
			s: STRING
		do
			if henv.authenticated then
				l_full := attached henv.variables_get.variable ("details") as v and then v.is_case_insensitive_equal ("true")
				if attached henv.authenticated_login as log then
					l_login := log.as_string_8
					create rep.make (path)

					create s.make_empty
					inspect format_id (a_format)
					when {REST_FORMAT_CONSTANTS}.json then
						rep.headers.put_content_type_text_plain
						s.append_string ("{ %"login%": %"" + l_login + "%" }%N")
					when {REST_FORMAT_CONSTANTS}.xml then
						rep.headers.put_content_type_text_xml
						s.append_string ("<login>" + l_login + "</login>%N")
					when {REST_FORMAT_CONSTANTS}.text then -- Default
						rep.headers.put_content_type_text_plain
						s.append_string ("login: " + l_login + "%N")
					else
					end
					if not s.is_empty then
						rep.set_message (s)
						henv.output.put_string (rep.string)
					end
					rep.recycle
				else
					process_error (henv, "User/password unknown", a_format)
				end
			else
				process_error (henv, "Authentication rejected", a_format)
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
