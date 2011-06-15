note
	description: "Summary description for {APP_DOC_HTML_PAGE_HEAD}."
	date: "$Date$"
	revision: "$Revision$"

class
	APP_DOC_HTML_PAGE_HEAD

inherit
	REST_API_DOCUMENTATION_HTML_PAGE_HEAD
		redefine
			initialize
		end

create
	make

feature {NONE} -- Initialization

	initialize
		do
			Precursor
			--| Define your own style ..
			style := "[
				body {margin: 30px;}
				a { text-decoration: none; }
				h1 { padding: 10px; border: solid 2px #000; background-color: #009; color: #fff;}
				div.api { padding: 5px; margin-bottom: 10px;} 
				div.api .api-description { padding: 5px 5px 5px 0px; font-style: italic; color: #090;} 
				div.api div.inner { padding-left: 40px;} 
				div.api h2>a { color: #009; text-decoration: none;} 
				div.api a.api-format { color: #009; text-decoration: none;} 
				div.api a.api-format.selected { padding: 0 4px 0 4px; color: #009; text-decoration: none; border: solid 1px #99c; background-color: #eeeeff;} 
				div.api>h2 { margin: 2px; padding: 2px 2px 2px 10px; display: inline-block; border: dotted 1px #cce; width: 100%; color: #009; background-color: #E7F3F8; text-decoration: none; font-weight: bold; font-size: 120%;} 
				div.api span.note { font-style: italic;}
			]"
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
