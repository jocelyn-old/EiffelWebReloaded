note
	description : "Objects that ..."
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	APP_REQUEST_HANDLER

inherit
	REST_REQUEST_HANDLER

feature -- Basic operation

	process_error (ctx: REST_REQUEST_CONTEXT; m: STRING; a_format_name: detachable STRING)
		local
			rep: REST_RESPONSE
			s: STRING
		do
			create rep.make ("Error")
			rep.headers.put_status ({HTTP_STATUS_CODE}.expectation_failed)
			rep.headers.put_content_type_text_plain
			create s.make_empty
			s.append_string ("Error: " + m)
			rep.set_message (s)
			ctx.output.put_string (rep.string)
			rep.recycle
		end

feature {NONE} -- Implementation

	string_hash_table_string_string (ht: HASH_TABLE_ITERATION_CURSOR [STRING_GENERAL, STRING_GENERAL]): STRING_8
		do
			from
				create Result.make (100)
				ht.start
			until
				ht.after
			loop
				Result.append_string ("<li><strong>" + ht.key.as_string_8 + "</strong> = " + ht.item.as_string_8 + "</li>%N")
				ht.forth
			end
		end

feature -- Helpers

	format_id (s: detachable STRING): INTEGER
		do
			Result := {REST_FORMAT_CONSTANTS}.text
			if s /= Void then
				Result := format_constants.format_id (s)
			end
		end

	exit_with_code (a_code: INTEGER)
		do
			(create {EXCEPTIONS}).die (a_code)
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
