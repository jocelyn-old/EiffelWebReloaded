note
	description: "Summary description for {HTTPD_AUTHENTICATION_DATA}."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTPD_AUTHENTICATION_DATA

feature -- Access

	authenticated: BOOLEAN
			-- Authenticated
		deferred
		end

	identifier: STRING_GENERAL
			-- Identifier
		deferred
		end

invariant
	authenticated implies identifier /= Void

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

end -- class HTTPD_AUTHENTICATION_DATA

