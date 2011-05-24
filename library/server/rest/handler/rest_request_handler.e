note
	description: "Summary description for {REST_REQUEST_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	REST_REQUEST_HANDLER

feature {NONE} -- Initialization

	initialize
			-- Initialize various attributes
		do
			create {LINKED_LIST [like parameters.item]} parameters.make
			set_format_located_before_parameters
		end

feature -- Access

	path: STRING
			-- Associated path (path info part of url)

	authentication_required: BOOLEAN
			-- Is authentication required
			-- might depend on the request environment
			-- or the associated resources
		deferred
		end

	description: detachable STRING
			-- Optional description

	parameters: LIST [attached like parameter]
			-- Parameters information

feature -- Access

	output: HTTPD_SERVER_OUTPUT
			-- Output
		deferred
		end

feature -- Access: Format

	supported_request_method_names: LIST [STRING]
			-- Support request method such as GET, POST, ...
		do
			create {LINKED_LIST [STRING]} Result.make
			if method_get_supported then
				Result.extend (request_method_constants.method_get_name)
			end
			if method_post_supported then
				Result.extend (request_method_constants.method_post_name)
			end
			if method_put_supported then
				Result.extend (request_method_constants.method_put_name)
			end
			if method_delete_supported then
				Result.extend (request_method_constants.method_delete_name)
			end
			if method_head_supported then
				Result.extend (request_method_constants.method_head_name)
			end
		end

	supported_format_names: LIST [STRING]
			-- Support request format result such as json, xml, ...
		do
			create {LINKED_LIST [STRING]} Result.make
			Result.compare_objects
			if format_json_supported then
				Result.extend (format_constants.json_name)
			end
			if format_xml_supported then
				Result.extend (format_constants.xml_name)
			end
			if format_text_supported then
				Result.extend (format_constants.text_name)
			end
			if format_html_supported then
				Result.extend (format_constants.html_name)
			end
			if format_rss_supported then
				Result.extend (format_constants.rss_name)
			end
			if format_atom_supported then
				Result.extend (format_constants.atom_name)
			end
		end

	default_format_name: detachable STRING
		do
			if attached supported_format_names as lst and then not lst.is_empty then
				Result := lst.first
			end
		end

	format_located_after_parameters: BOOLEAN
			--| path = app-path/parameters{.format}	
		do
			Result := format_path_location = opt_format_located_after_parameters
		end

	format_located_before_parameters: BOOLEAN
			--| path = app-path{.format}/parameters
		do
			Result := format_path_location = opt_format_located_before_parameters
		end

	set_format_located_after_parameters
		do
			format_path_location := opt_format_located_before_parameters
		end

	set_format_located_before_parameters
		do
			format_path_location := opt_format_located_before_parameters
		end

feature {NONE} -- Format path location

	format_path_location: INTEGER

	opt_format_located_before_parameters: INTEGER = 1

	opt_format_located_after_parameters: INTEGER = 2

feature -- Execution

	execute (henv: REST_ENVIRONMENT)
			-- Execute request handler	
		local
			l_format, l_args: detachable STRING
		do
			if attached execution_information (henv) as l_info then
				l_format := l_info.format
				l_args := l_info.arguments
			end
			if authentication_required and then not henv.authenticated then
				execute_unauthorized (henv, l_format, l_args)
			else
				execute_application (henv, l_format, l_args)
			end
		end

	execute_unauthorized (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			h: HTTPD_HEADER
		do
			create h.make
			h.put_status ({HTTP_STATUS_CODE}.unauthorized)
			h.put_header ("WWW-Authenticate: Basic realm=%"Eiffel auth%"")
			output.put_string (h.string)
			h.recycle
		end

	execute_application (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
			-- Execute request handler with `a_format' ad `a_args'
		deferred
		end

feature -- Execution: report

	execution_information (henv: REST_ENVIRONMENT): detachable TUPLE [format: detachable STRING; arguments: detachable STRING]
			-- Execution information related to the request
		do
			Result := path_information (henv.path_info)
		end

	path_information (a_rq_path: STRING): detachable TUPLE [format: detachable STRING; arguments: detachable STRING]
			-- Information related to `a_path'
		local
			l_rq_path: STRING
			i,p,n: INTEGER
			l_format, l_args: detachable STRING
		do
			l_rq_path := a_rq_path
			if l_rq_path.count > 0 and then l_rq_path[1] /= '/' then
				l_rq_path := "/" + l_rq_path
			end
			n := l_rq_path.count
			i := path.count + 1

			if format_located_before_parameters then
					--| path = app-path{.format}/parameters

				if l_rq_path.valid_index (i) and then l_rq_path[i] = '.' then
					p := l_rq_path.index_of ('/', i + 1)
					if p = 0 then
						p := n + 1
					else
						l_args := l_rq_path.substring (p + 1, n)
					end
					l_format := l_rq_path.substring (i + 1, p - 1)
				elseif n > i then
					check l_rq_path[i] = '/' end
					l_args := l_rq_path.substring (i + 1, n)
				end
			elseif format_located_after_parameters then
					--| path = app-path/parameters{.format}

				p := l_rq_path.last_index_of ('.', n)
				if p > i then
					l_format := l_rq_path.substring (p + 1, n)
					l_args := l_rq_path.substring (i, p - 1)
				elseif n > i then
					check l_rq_path[i] = '/' end
					l_format := Void
					l_args := l_rq_path.substring (i + 1, n)
				end
			end
			if l_format /= Void or l_args /= Void then
				Result := [l_format, l_args]
			end
		end

	url (henv: REST_ENVIRONMENT; args: detachable STRING; abs: BOOLEAN): STRING
			-- Associated url based on `path' and `args'
			-- if `abs' then return absolute url
		local
			s: detachable STRING
		do
			s := args
			if s /= Void and then s.count > 0 then
				if s[1] /= '/' then
					s := path + "/" + s
				else
					s := path + s
				end
			else
				s := path
			end
			if abs then
				Result := henv.script_absolute_url (s)
			else
				Result := henv.script_url (s)
			end
		ensure
			result_attached: Result /= Void
		end

	hidden (henv: REST_ENVIRONMENT): BOOLEAN
			-- Do we hide this application in service publishing
		do
			--| By default: False
		end

feature -- Access: parameters

	parameter (n: STRING): detachable REST_REQUEST_HANDLER_PARAMETER
			-- Parameter's object for `n'.	
		require
			n_not_empty: n /= Void and then not n.is_empty
		local
			params: like parameters
		do
			from
				params := parameters
				params.start
			until
				Result /= Void or params.after
			loop
				Result := params.item
				if not n.same_string (Result.name) then
					Result := Void
					params.forth
				end
			end
		ensure
			result_valid: Result /= Void implies n.same_string (Result.name)
		end

	parameter_value (n: STRING; henv: REST_ENVIRONMENT): detachable STRING_32
			-- Parameter's value for `n'.
		do
			if method_get_supported then
				Result := henv.variables_get.variable (n)
			end
			if Result = Void and method_post_supported then
				Result := henv.variables_post.variable (n)
			end
		end

feature -- Analyze: parameters

	analyze_parameters (results: HASH_TABLE [STRING_32, STRING]; missings: LIST [STRING]; henv: REST_ENVIRONMENT)
			-- Analyze parameters from `henv', and return in `results' the table of known parameters
			-- return in `missings' the required parameters which are missing if any
		require
			results_attached: results /= Void
			missing_attached: missings /= Void
		local
			params: like parameters
			param: like parameter
		do
			from
				params := parameters
				params.start
			until
				params.after
			loop
				param := params.item
				if attached parameter_value (param.name, henv) as v then
					results.put (v, param.name)
				elseif not param.optional then
					missings.force (param.name)
				end
				params.forth
			end
		end

feature -- Element change

	set_path (a_path: like path)
		require
			a_path_valid: a_path.count > 1 and then a_path[1] = '/'
		do
			path := a_path.string
		end

	set_description (s: like description)
			-- Set `description' to `s'
		do
			description := s
		end

feature {NONE} -- Implementation

	supported_request_methods: INTEGER
			-- Support request method such as GET, POST, ...

	supported_formats: INTEGER
			-- Support request format result such as json, xml, ...

feature {NONE} -- Status report

	format_id_supported (a_id: INTEGER): BOOLEAN
		do
			Result := (supported_formats & a_id) = a_id
		end

	format_name_supported (n: STRING): BOOLEAN
			-- Is format `n' supported?
		do
			Result := format_id_supported (format_constants.format_id (n))
		end

	format_constants: REST_FORMAT_CONSTANTS
		once
			create Result
		end

feature {NONE} -- Status report

	request_method_id_supported (a_id: INTEGER): BOOLEAN
		do
			Result := (supported_request_methods & a_id) = a_id
		end

	request_method_name_supported (n: STRING): BOOLEAN
			-- Is request method `n' supported?
		do
			Result := request_method_id_supported (request_method_constants.method_id (n))
		end

	request_method_constants: REST_REQUEST_METHOD_CONSTANTS
		once
			create Result
		end

feature -- Status report		

	format_json_supported: BOOLEAN
		do
			Result := format_id_supported ({REST_FORMAT_CONSTANTS}.json)
		end

	format_xml_supported: BOOLEAN
		do
			Result := format_id_supported ({REST_FORMAT_CONSTANTS}.xml)
		end

	format_text_supported: BOOLEAN
		do
			Result := format_id_supported ({REST_FORMAT_CONSTANTS}.text)
		end

	format_html_supported: BOOLEAN
		do
			Result := format_id_supported ({REST_FORMAT_CONSTANTS}.html)
		end

	format_rss_supported: BOOLEAN
		do
			Result := format_id_supported ({REST_FORMAT_CONSTANTS}.rss)
		end

	format_atom_supported: BOOLEAN
		do
			Result := format_id_supported ({REST_FORMAT_CONSTANTS}.atom)
		end

	method_get_supported: BOOLEAN
		do
			Result := request_method_id_supported ({REST_REQUEST_METHOD_CONSTANTS}.method_get)
		end

	method_post_supported: BOOLEAN
		do
			Result := request_method_id_supported ({REST_REQUEST_METHOD_CONSTANTS}.method_post)
		end

	method_put_supported: BOOLEAN
		do
			Result := request_method_id_supported ({REST_REQUEST_METHOD_CONSTANTS}.method_put)
		end

	method_delete_supported: BOOLEAN
		do
			Result := request_method_id_supported ({REST_REQUEST_METHOD_CONSTANTS}.method_delete)
		end

	method_head_supported: BOOLEAN
		do
			Result := request_method_id_supported ({REST_REQUEST_METHOD_CONSTANTS}.method_head)
		end

feature -- Element change: parameters

	add_parameter (n: STRING; d: detachable STRING; opt: BOOLEAN; a_type: detachable STRING)
		local
			p: like parameter
		do
			create p.make (n, opt)
			p.description := d
			p.type := a_type
			parameters.extend (p)
		end

	add_boolean_parameter (n: STRING; d: detachable STRING; opt: BOOLEAN)
		do
			add_parameter (n, d, opt, "boolean")
		end

	add_integer_parameter (n: STRING; d: detachable STRING; opt: BOOLEAN)
		do
			add_parameter (n, d, opt, "integer")
		end

	add_string_parameter (n: STRING; d: detachable STRING; opt: BOOLEAN)
		do
			add_parameter (n, d, opt, "string")
		end

feature -- Element change: request methods		

	reset_supported_request_methods
		do
			supported_request_methods := 0
		end

	enable_request_method_get
		do
			enable_request_method ({REST_REQUEST_METHOD_CONSTANTS}.method_get)
		end

	enable_request_method_post
		do
			enable_request_method ({REST_REQUEST_METHOD_CONSTANTS}.method_post)
		end

	enable_request_method_put
		do
			enable_request_method ({REST_REQUEST_METHOD_CONSTANTS}.method_put)
		end

	enable_request_method_delete
		do
			enable_request_method ({REST_REQUEST_METHOD_CONSTANTS}.method_delete)
		end

	enable_request_method_head
		do
			enable_request_method ({REST_REQUEST_METHOD_CONSTANTS}.method_head)
		end

	enable_request_method (m: INTEGER)
		do
			supported_request_methods := supported_request_methods | m
		end

feature -- Element change: formats

	reset_supported_formats
		do
			supported_formats := 0
		end

	enable_format_json
		do
			enable_format ({REST_FORMAT_CONSTANTS}.json)
		end

	enable_format_xml
		do
			enable_format ({REST_FORMAT_CONSTANTS}.xml)
		end

	enable_format_text
		do
			enable_format ({REST_FORMAT_CONSTANTS}.text)
		end

	enable_format_html
		do
			enable_format ({REST_FORMAT_CONSTANTS}.html)
		end

	enable_format (f: INTEGER)
		do
			supported_formats := supported_formats | f
		end

invariant
	path_starts_by_slash: path[1] = '/'

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
