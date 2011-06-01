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

	execute_application (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: detachable REST_RESPONSE
			s: STRING
			ht: HASH_TABLE_ITERATION_CURSOR [STRING_GENERAL, STRING_GENERAL]
		do
			if a_args /= Void and then not a_args.is_empty then
				if a_args.same_string ("crash") then
					rep := Void
					(create {DEVELOPER_EXCEPTION}).raise
				elseif a_args.starts_with ("env") then
					create rep.make (path)
					create s.make_empty
					ht := henv.variables.new_cursor
					if a_format = Void or else a_format.same_string ("html") then
						rep.headers.put_content_type_text_html
						from
							ht.start
						until
							ht.after
						loop
							s.append_string ("<li><strong>" + ht.key.as_string_8 + "</strong> = " + ht.item.as_string_8 + "</li>%N")
							ht.forth
						end
					elseif a_format.same_string ("json") then
						rep.headers.put_content_type_application_json
						s.append ("{ %"application%": %""+ path +"%" ")
						from
							ht.start
						until
							ht.after
						loop
							s.append_string (",%"" + ht.key.as_string_8 + "%": %"" + ht.item.as_string_8 + "%"%N")
							ht.forth
						end
						s.append ("}%N")
					elseif a_format.same_string ("xml") then
						rep.headers.put_content_type_text_xml
						s.append ("<application name=%""+ path +"%">")
						from
							ht.start
						until
							ht.after
						loop
							s.append_string ("<variable name=%"" + ht.key.as_string_8 + "%">" + ht.item.as_string_8 + "</variable>%N")
							ht.forth
						end
						s.append ("</application>%N")
					else
						rep.headers.put_content_type_text_plain
						from
							ht.start
						until
							ht.after
						loop
							s.append_string (ht.key.as_string_8 + " = " + ht.item.as_string_8 + "%N")
							ht.forth
						end
					end
					rep.set_message (s)
				else
				end
			end
			if rep = Void then
				create rep.make (path)
				rep.headers.put_content_type_text_html
				create s.make_empty
				s.append_string ("test")
				if attached henv.environment_variable ("REQUEST_COUNT") as l_request_count then
					s.append_string ("(request_count="+ l_request_count +")<br/>%N")
				end
				s.append ("%N Try <a href=%"http://" + henv.script_absolute_url (henv.path_info + "/env") + "%">/test/env</a> to display all variables <br/>%N")
				s.append ("%N Try <a href=%"http://" + henv.script_absolute_url (henv.path_info + ".json/env") + "%">/test.json/env</a> to display all variables in JSON <br/>%N")
				s.append ("%N Try <a href=%"http://" + henv.script_absolute_url (henv.path_info + ".json/env") + "%">/test.xml/env</a> to display all variables in XML <br/>%N")
				s.append ("%N Try <a href=%"http://" + henv.script_absolute_url (henv.path_info + ".json/env") + "%">/test.html/env</a> to display all variables in HTML<br/>%N")
				s.append ("%N Try <a href=%"http://" + henv.script_absolute_url (henv.path_info + "/crash") + "%">/crash</a> to demonstrate exception trace <br/>%N")

				if attached henv.http_authorization_login_password as t then
					s.append_string ("Check login=" + t.login + "<br/>%N")
				end
				if henv.authenticated and then attached henv.authenticated_login as l_login then
					s.append_string ("Authenticated: login=" + l_login.as_string_8 + "<br/>%N")
				end

				s.append_string ("<br/>script_url(%"" + henv.path_info + "%")=" + henv.script_url (henv.path_info) + "%N")

				rep.set_message (s)
			end

			henv.output.put_string (rep.string)
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
