note
	description: "[
				Variables/field related to the current request.
			]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_REQUEST_VARIABLES

inherit
	HASH_TABLE [STRING_32, STRING_32]

create
	make,
	make_from_urlencoded

feature -- Initialization

	make_from_urlencoded (a_content: STRING; decoding: BOOLEAN)
		do
			make (a_content.occurrences ('&') + 1)
			import_urlencoded (a_content, decoding)
		end

feature -- Import urlencoded

	import_urlencoded (a_content: STRING; decoding: BOOLEAN)
			-- Import `a_content'
		local
			n, p, i, j: INTEGER
			s: STRING
			l_name,l_value: STRING_32
		do
			n := a_content.count
			if n > 0 then
				from
					p := 1
				until
					p = 0
				loop
					i := a_content.index_of ('&', p)
					if i = 0 then
						s := a_content.substring (p, n)
						p := 0
					else
						s := a_content.substring (p, i - 1)
						p := i + 1
					end
					if not s.is_empty then
						j := s.index_of ('=', 1)
						if j > 0 then
							l_name := s.substring (1, j - 1)
							l_value := s.substring (j + 1, s.count)
							if decoding then
								l_name := string_routines.string_url_decoded (l_name)
								l_value := string_routines.string_url_decoded (l_value)
							end
							force (l_value, l_name)
						end
					end
				end
			end
		end


feature {NONE} -- Implementation

	string_routines: HTTP_STRING_ROUTINES
		once
			create Result
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
