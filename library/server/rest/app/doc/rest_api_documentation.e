note
	description: "Summary description for {REST_API_DOCUMENTATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_API_DOCUMENTATION

inherit
	REST_REQUEST_HANDLER

create
	make

feature {NONE} -- Initialization

	make (a_path: STRING; a_handler_manager: like handler_manager)
		do
			path := a_path
			handler_manager := a_handler_manager
			description := "Technical documention for the API"
			initialize
		end

feature {NONE} -- Access: Implementation

	handler_manager: REST_REQUEST_HANDLER_MANAGER

feature -- Access

	authentication_required: BOOLEAN = False

feature -- Execution

	execute_application (ctx: REST_REQUEST_CONTEXT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: like new_html_page
			s: STRING
			rq: detachable REST_REQUEST_HANDLER
			l_dft_format_name: detachable STRING
			hdl_cursor: like handler_manager.new_cursor
		do
			rep := new_html_page
			rep.headers.put_content_type_text_html
			create s.make_empty

			if a_args /= Void and then not a_args.is_empty then
				rq := handler_manager.handler_by_path (a_args)
				if rq = Void then
					rq := handler_manager.smart_handler_by_path (a_args)
					if attached {REST_REQUEST_GROUP_HANDLER} rq as grp then
						rq := grp.handlers.handler_by_path (a_args)
					end
				end
				if
					rq /= Void and then
					attached rq.path_information (a_args) as l_info
				then
					l_dft_format_name := l_info.format
				end
			end


			if rq /= Void then
				rep.set_big_title ("API: Technical documentation for ["+ rq.path +"]")

				s.append_string ("<div class=%"api%">")
				s.append_string ("<h2 class=%"api-name%" >")
				s.append_string ("<a href=%"" + url (ctx, Void, False) + "%">.. Show all features ..</a>")
				s.append_string ("</h2></div>%N")

				process_request_handler_doc (rq, s, ctx, a_format, l_dft_format_name)
			else
				rep.set_big_title ("API: Technical documentation")

				from
					hdl_cursor := handler_manager.new_cursor
				until
					hdl_cursor.after
				loop
					rq := hdl_cursor.item
					rep.add_shortcut (rq.path)
					s.append ("<a name=%"" + rep.last_added_shortcut + "%"/>")
					process_request_handler_doc (rq, s, ctx, a_format, Void)
					hdl_cursor.forth
				end
			end
			rep.set_body (s)
			rep.compute
			ctx.output.put_string (rep.string)
			rep.recycle
		end

	process_request_handler_doc (rq: REST_REQUEST_HANDLER; s: STRING; ctx: REST_REQUEST_CONTEXT; a_format: detachable STRING; a_dft_format: detachable STRING)
		local
			l_dft_format_name: detachable STRING
		do
			if a_dft_format /= Void then
				if rq.supported_format_names.has (a_dft_format) then
					l_dft_format_name := a_dft_format
				end
			end

			s.append_string ("<div class=%"api%">")
			s.append_string ("<h2 class=%"api-name%" ><a href=%""+ url (ctx, rq.path, False) +"%">"+ rq.path +"</a></h2>")
			s.append_string ("<div class=%"inner%">")
			if rq.hidden (ctx) then
				s.append_string ("<div class=%"api-description%">This feature is hidden</div>%N")
			else
				if attached rq.description as desc then
					s.append_string ("<div class=%"api-description%">" + desc + "</div>")
				end
				if attached {REST_REQUEST_GROUP_HANDLER} rq as grp then
					s.append_string ("<div class=%"api-format%">Handler: <strong>")
					if attached grp.handlers.new_cursor as l_handlers_cursor then
						from

						until
							l_handlers_cursor.after
						loop
							s.append_string (" ")
							s.append_string ("<a class=%"api-handler%" href=%"")
							s.append_string (url (ctx, l_handlers_cursor.item.path, False))
							s.append_string ("%">"+ l_handlers_cursor.item.path +"</a>")
							l_handlers_cursor.forth
						end
					end
					s.append_string ("</strong></div>")
				end
				if attached rq.supported_format_names as l_formats and then not l_formats.is_empty then
					s.append_string ("<div class=%"api-format%">Supported formats: <strong>")
					if attached l_formats.new_cursor as l_formats_cursor then
						from

						until
							l_formats_cursor.after
						loop
							s.append_string (" ")
							s.append_string ("<a class=%"api-name api-format")
							if l_formats_cursor.item ~ l_dft_format_name then
								s.append_string (" selected")
							end
							s.append_string ("%" href=%"" + url (ctx, rq.path, False) + "." + l_formats_cursor.item + "%">"+ l_formats_cursor.item +"</a>")
							l_formats_cursor.forth
						end
					end
					s.append_string ("</strong></div>")
				end
				if attached rq.supported_request_method_names as l_methods and then not l_methods.is_empty then
					s.append_string ("<div class=%"api-method%">Supported request methods: <strong>")
					if attached l_methods.new_cursor as l_methods_cursor then
						from

						until
							l_methods_cursor.after
						loop
							s.append_string (" ")
							s.append_string (l_methods_cursor.item)
							l_methods_cursor.forth
						end
					end
					s.append_string ("</strong></div>")
				end
				s.append_string ("<div class=%"api-auth%">Authentication required: <strong>" + rq.authentication_required.out + "</strong></div>")
				if attached rq.uri_parameters as l_uri_params and then not l_uri_params.is_empty then
					s.append_string ("<div class=%"api-uri-template%">URI Template: ")
					s.append_string (rq.path)
					if attached l_uri_params.new_cursor as l_uri_params_cursor then
						from

						until
							l_uri_params_cursor.after
						loop
							if attached l_uri_params_cursor.item as l_uri_param then
								s.append_string ("/<strong>" + l_uri_param.name + "</strong>")
								s.append_string ("/<em>{" + l_uri_param.name + "}</em>")
							end
							l_uri_params_cursor.forth
						end
					end
					s.append_string ("</div>%N")
				end
				if attached rq.parameters as l_params and then not l_params.is_empty then
					s.append_string ("<div class=%"api-params%">Parameters: ")

						--| show form only if we have a default format
					if l_dft_format_name = Void then
						s.append_string ("<span class=%"note%">to test the parameter(s), please first select a supported format.</span>%N")
					else
						if rq.method_post_supported then
							s.append_string ("<form id=%""+ rq.path +"%" method=%"POST%" action=%"" + ctx.script_url (rq.path) + "." + l_dft_format_name + "%">%N")
						else
							s.append_string ("<form id=%""+ rq.path +"%" method=%"GET%" action=%"" + ctx.script_url (rq.path) + "." + l_dft_format_name + "%">%N")
						end
					end
					s.append_string ("<ul>")
					if attached l_params.new_cursor as l_params_cursor then
						from

						until
							l_params_cursor.after
						loop
							if attached l_params_cursor.item as l_param then
								s.append_string ("<li><strong>" + l_param.name + "</strong>")
								if l_param.optional then
									s.append_string (" <em>(Optional)</em>")
								end
								if attached l_param.description as l_param_desc then
									s.append_string (": <em>" + l_param_desc + "</em>")
								end
								if l_dft_format_name /= Void then
									s.append (" <input name=%"" + l_param.name + "%" type=%"text%" />")
								end
								s.append_string ("</li>")
							end
							l_params_cursor.forth
						end
					end

					if l_dft_format_name /= Void then
						s.append_string ("<input type=%"submit%" value=%"Test "+ rq.path + "." + l_dft_format_name + "%"/>")
						s.append_string ("</form>")
					end
					s.append_string ("</ul></div>")
				else
					if l_dft_format_name /= Void then
						s.append_string ("<a class=%"api-name%" href=%"" + ctx.script_url (rq.path + "." + l_dft_format_name) + "%">Test "+ rq.path  + "." + l_dft_format_name + "</a>")
					else
						s.append_string ("<a class=%"api-name%" href=%"" + ctx.script_url (rq.path) + "%">Test "+ rq.path +"</a>")
					end
				end
				s.append_string ("</div>%N")
			end
			s.append_string ("</div>%N") -- inner
		end

feature -- Access

	new_html_page: REST_API_DOCUMENTATION_HTML_PAGE
		do
			create Result.make (path)
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
