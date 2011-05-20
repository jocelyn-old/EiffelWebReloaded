note
	description: "Summary description for {APP_API_DOCUMENTATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APP_API_DOCUMENTATION

inherit
	REST_API_DOCUMENTATION
		redefine
			new_html_page
		end

create
	make

feature -- Execution

	new_html_page: APP_DOC_HTML_PAGE
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
