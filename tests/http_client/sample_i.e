note
	description: "Summary description for {SAMPLE_I}."
	author: "Jocelyn Fiat"
	date: "$Date: 2010-12-16 14:13:34 +0100 (jeu., 16 déc. 2010) $"
	revision: "$Revision: 63 $"

deferred class
	SAMPLE_I

inherit
	REFACTORING_HELPER

--create
--	make,
--	make_with_source

feature {NONE} -- Initialization

	make (a_username, a_password: detachable STRING)
		deferred
		end

	make_with_source (a_username, a_password: detachable STRING; a_source: STRING)
		deferred
		end

feature -- Sample: Help Methods

	test: detachable STRING
			--Returns the string "ok" in the requested format with a 200 OK HTTP status code.			
			-- URL: http://.../sample/api/test.format
			--Formats: xml, json
			--Method(s): GET			
		deferred
		end

note
	copyright: "Copyright (c) 1984-2011, Eiffel Software and others"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
