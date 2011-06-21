note
	description: "Summary description for {APP_DOC_HTML_PAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APP_DOC_HTML_PAGE

inherit
	REST_API_DOCUMENTATION_HTML_PAGE
		redefine
			head
		end

create
	make

feature -- Access

	head: APP_DOC_HTML_PAGE_HEAD

;note
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
