note
	description: "Summary description for {APP_ORDERS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APP_ORDERS
inherit
	APP_REQUEST_HANDLER
		redefine
			initialize
		end
	SHARED_DATABASE_API
	SHARED_EJSON
	REFACTORING_HELPER
create
	make

feature {NONE} -- Initialization

	make (a_path: like path)
		do
			path := a_path
			description := "testing"
			initialize
		end

	initialize
		do
			Precursor
			enable_request_method_get
			enable_request_method_post
			enable_request_method_put
			enable_request_method_delete
			enable_format_json
		end

feature {NONE} -- Access: Implementation

feature -- Access

	authentication_required: BOOLEAN = False

feature -- Execution

	execute_application (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			l_date : DATE_TIME
		do
				if henv.request_method.same_string ({REST_REQUEST_METHOD_CONSTANTS}.method_post_name) then
					pre_process_post (henv, a_format, a_args)
				elseif henv.request_method.same_string ({REST_REQUEST_METHOD_CONSTANTS}.method_get_name)  then
					pre_process_get (henv, a_format, a_args)
				elseif henv.request_method.same_string ({REST_REQUEST_METHOD_CONSTANTS}.method_put_name)  then
					pre_process_put (henv, a_format, a_args)
				elseif henv.request_method.same_string ({REST_REQUEST_METHOD_CONSTANTS}.method_delete_name)  then
					pre_process_delete (henv, a_format, a_args)
				else
					handle_method_not_supported_response(henv)
				end
		end


feature -- process POST		
	pre_process_post (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: detachable REST_RESPONSE
		do
			if attached henv.orig_path_info as orig_path_info then
				if is_valid_uri ({REST_REQUEST_METHOD_CONSTANTS}.method_post_name, orig_path_info) then
					process_post (henv, a_format, a_args)
				else
					handle_method_not_supported_response (henv)
				end
			end
		end

	process_post (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: detachable REST_RESPONSE
			l_values: HASH_TABLE [STRING_32, STRING]
			l_missings: LINKED_LIST [STRING]
			l_full: BOOLEAN
			l_post: STRING
			l_location :  STRING
			l_order : detachable ORDER
			jv : detachable JSON_VALUE
		do
				fixme ("TODO handle an Internal Server Error")
				fixme ("Refactor the code, create new abstractions")
				fixme ("Add Header Date to the response")
				if henv.content_length > 0 then
					henv.input.read_stream (henv.content_length)
					l_post := henv.input.last_string
					l_order := extract_order_request(l_post)
					fixme ("TODO move to a service method")
					if  l_order /= Void then
						save_order( l_order)
						create rep.make (path)
						rep.headers.put_status (rep.headers.created)
						rep.headers.put_content_type_application_json
						if attached henv.http_host as host then
							l_location := "http://"+host + path + "/" + l_order.id
							rep.headers.add_header ("Location:"+ l_location)
						end
						jv ?= json.value (l_order)
						if jv /= Void then
							rep.set_message (jv.representation)
						end
						henv.output.put_string (rep.string)
						rep.recycle
					else
						handle_bad_request_response(l_post +"%N is not a valid ORDER",henv.output)
					end
				else
					handle_bad_request_response("Bad request, content_lenght empty",henv.output)
				end
		end

feature -- process GET
	pre_process_get (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: detachable REST_RESPONSE
		do
			if attached henv.orig_path_info as orig_path_info then
				if is_valid_uri ({REST_REQUEST_METHOD_CONSTANTS}.method_get_name, orig_path_info) then
					process_get (henv, a_format, a_args)
				else
					handle_method_not_supported_response (henv)
				end
			end
		end

	process_get (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: detachable REST_RESPONSE
			l_values: HASH_TABLE [STRING_32, STRING]
			l_missings: LINKED_LIST [STRING]
			l_full: BOOLEAN
			l_post: STRING
			joc : JSON_ORDER_CONVERTER
			parser : JSON_PARSER
			l_order : detachable ORDER
			jv : detachable JSON_VALUE
			l_location, id :  STRING
			uri : LIST[STRING]
		do
				fixme ("TODO handle error conditions")
				if  attached henv.orig_path_info as orig_path then
					uri := orig_path.split ('/')
					id := uri.at (3)
					create joc.make
					json.add_converter(joc)
					if db_access.orders.has_key (id) then
						l_order := db_access.orders.item (id)
						jv ?= json.value (l_order)
						if attached jv as j then
							create rep.make (path)
							rep.headers.put_status (rep.headers.ok)
							rep.headers.put_content_type_application_json
							rep.set_message (j.representation)
							henv.output.put_string (rep.string)
							rep.recycle
						end
					else
						handle_resource_not_found_response ("The following resource"+ orig_path+ " is not found ", henv.output)
					end
				end


		end

feature -- Process PUT
	pre_process_put (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: detachable REST_RESPONSE
		do
			if attached henv.orig_path_info as orig_path_info then
				if is_valid_uri ({REST_REQUEST_METHOD_CONSTANTS}.method_put_name, orig_path_info) then
					process_put (henv, a_format, a_args)
				else
					handle_method_not_supported_response (henv)
				end
			end
		end

	process_put (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: detachable REST_RESPONSE
			l_values: HASH_TABLE [STRING_32, STRING]
			l_missings: LINKED_LIST [STRING]
			l_full: BOOLEAN
			l_post: STRING
			l_location :  STRING
			l_order : detachable ORDER
			jv : detachable JSON_VALUE
		do
				fixme ("TODO handle an Internal Server Error")
				fixme ("Refactor the code, create new abstractions")
				fixme ("Add Header Date to the response")
				fixme ("Put implememntation is wrong!!!!")
				if henv.content_length > 0 then
					henv.input.read_stream (henv.content_length)
					l_post := henv.input.last_string
					l_order := extract_order_request(l_post)
					fixme ("TODO move to a service method")
					if  l_order /= Void and then db_access.orders.has_key (l_order.id) then
						update_order( l_order)
						create rep.make (path)
						rep.headers.put_status (rep.headers.created)
						rep.headers.put_content_type_application_json
						if attached henv.http_host as host then
							l_location := "http://"+host + path + "/" + l_order.id
							rep.headers.add_header ("Location:"+ l_location)
						end
						jv ?= json.value (l_order)
						if jv /= Void then
							rep.set_message (jv.representation)
						end
						henv.output.put_string (rep.string)
						rep.recycle
					else
						handle_bad_request_response(l_post +"%N is not a valid ORDER, maybe the order does not exist in the system",henv.output)
					end
				else
					handle_bad_request_response("Bad request, content_lenght empty",henv.output)
				end
		end

feature -- process DELETE
	pre_process_delete (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: detachable REST_RESPONSE
		do
			if attached henv.orig_path_info as orig_path_info then
				if is_valid_uri ({REST_REQUEST_METHOD_CONSTANTS}.method_delete_name, orig_path_info) then
					process_delete (henv, a_format, a_args)
				else
					handle_method_not_supported_response (henv)
				end
			end
		end

	process_delete (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		local
			rep: detachable REST_RESPONSE
			l_values: HASH_TABLE [STRING_32, STRING]
			uri: LIST [STRING]
			l_full: BOOLEAN
			id: STRING
			l_location :  STRING
			l_order : detachable ORDER
			jv : detachable JSON_VALUE
		do
				fixme ("TODO handle an Internal Server Error")
				fixme ("Refactor the code, create new abstractions")
				fixme ("Add Header Date to the response")
				if  attached henv.orig_path_info as orig_path then
					uri := orig_path.split ('/')
					id := uri.at (3)
					if  db_access.orders.has_key (id) then
						delete_order( id)
						create rep.make (path)
						rep.headers.put_status (rep.headers.no_content)
						rep.headers.put_content_type_application_json
						henv.output.put_string (rep.string)
						rep.recycle
					else
						handle_resource_not_found_response (orig_path + " not found in this server", henv.output)
					end
				end
		end

feature -- URI validation
	is_valid_uri (method: STRING actual_uri:STRING) : BOOLEAN
		-- Validate if actual_uri is a valid tempalte,
		-- for the corresponding method
		local
			l_uri: LIST[STRING]
		do
			if method.same_string ({REST_REQUEST_METHOD_CONSTANTS}.method_post_name) then
				if actual_uri.same_string (post_template_uri) then
					Result := True
				end
			else
				-- the uri should be "/order/{uri_id}"
				-- and the {uri_id} should be a number
				l_uri :=  actual_uri.split ('/')
				if l_uri.count = 3 and then l_uri.at (2).same_string ("order") and then l_uri.at (3).is_number_sequence then
					Result := True
		    	end
			end
		end

	post_template_uri : STRING = "/order"

feature -- Implementation

	save_order ( an_order : ORDER)
		-- save the order to the repository
		local
			i : INTEGER
		do
				from
					i := 1
				until
					not db_access.orders.has_key ((db_access.orders.count + i).out)
				loop
					i := i + 1
				end
				an_order.set_id ((db_access.orders.count + i).out)
				db_access.orders.force (an_order, an_order.id)
		end

	update_order ( an_order : ORDER)
		-- update the order to the repository
		do
				db_access.orders.force (an_order, an_order.id)
		end

	delete_order ( an_order : STRING)
		-- update the order to the repository
		do
				db_access.orders.remove (an_order)
		end

	extract_order_request (l_post : STRING) : detachable ORDER
		-- extract an object Order from the request, or Void
		-- if the request is invalid
		local
			joc : JSON_ORDER_CONVERTER
			parser : JSON_PARSER
			l_order : detachable ORDER
			jv : detachable JSON_VALUE
		do
			create joc.make
			json.add_converter(joc)
			create parser.make_parser (l_post)
			jv ?= parser.parse
			if jv /= Void and parser.is_parsed then
				l_order ?= json.object (jv, "ORDER")
				Result :=  l_order
			end
		end


	handle_bad_request_response (a_description:STRING; an_output: HTTPD_SERVER_OUTPUT )
		local
			rep: detachable REST_RESPONSE
		do
					create rep.make (path)
					rep.headers.put_status (rep.headers.bad_request)
					rep.headers.put_content_type_application_json
					rep.set_message (a_description)
					an_output.put_string (rep.string)
					rep.recycle
		end


	handle_resource_not_found_response (a_description:STRING; an_output: HTTPD_SERVER_OUTPUT )
		local
			rep: detachable REST_RESPONSE
		do
					create rep.make (path)
					rep.headers.put_status (rep.headers.not_found)
					rep.headers.put_content_type_application_json
					rep.set_message (a_description)
					an_output.put_string (rep.string)
					rep.recycle
		end


	handle_method_not_supported_response (henv :REST_ENVIRONMENT)
		local
			rep: detachable REST_RESPONSE
		do
					create rep.make (path)
					rep.headers.put_status (rep.headers.method_not_allowed)
					rep.headers.put_content_type_application_json
					henv.output.put_string (rep.string)
					rep.recycle
		end
end
