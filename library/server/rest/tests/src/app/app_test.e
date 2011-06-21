note
	description: "Summary description for {APP_TEST}."
	date: "$Date$"
	revision: "$Revision$"

class
	APP_TEST

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
			description := "Return a simple test output "
			initialize
		end

	initialize
		do
			Precursor
			enable_request_method_get
			enable_format_text
		end

feature -- Access

	authentication_required: BOOLEAN = False

feature -- Execution

	execute_application (ctx: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: REST_RESPONSE
			s: STRING
		do
			create rep.make (path)
			rep.headers.put_content_type_text_plain
			create s.make_empty
			s.append_string ("test")
			if attached ctx.environment_variable ("REQUEST_COUNT") as l_request_count then
				s.append_string ("(request_count="+ l_request_count +")%N")
			end

			if a_args /= Void and then not a_args.is_empty then
				s.append_string (" arguments=" + a_args)
				if a_args.same_string ("crash") then
					(create {DEVELOPER_EXCEPTION}).raise
				elseif a_args.starts_with ("env") then
					s.append_string ("%N%NAll variables:")
					s.append (string_hash_table_string_string (ctx.variables.new_cursor))
					s.append_string ("<br/>script_url(%"" + ctx.path_info + "%")=" + ctx.script_url (ctx.path_info) + "%N")
					if attached ctx.http_authorization_login_password as t then
						s.append_string ("Check login=" + t.login + "<br/>%N")
					end
					if ctx.authenticated and then attached ctx.authenticated_login as l_login then
						s.append_string ("Authenticated: login=" + l_login.as_string_8 + "<br/>%N")
					end
				end
			else
				s.append ("%N Try " + ctx.script_absolute_url (ctx.path_info + "/env") + " to display all variables%N")
				s.append ("%N Try " + ctx.script_absolute_url (ctx.path_info + "/crash") + " to demonstrate exception trace%N")
			end
			rep.set_message (s)
			rep.compute
			ctx.output.put_string (rep.string)
			rep.recycle
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
