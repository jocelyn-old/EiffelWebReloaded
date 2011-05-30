note
	description: "Summary description for REQUEST_AGENT_HANDLER."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_REQUEST_AGENT_HANDLER

inherit
	REST_REQUEST_HANDLER

create
	make

feature -- Initialization

	make (act: like action; p: like path)
		do
			set_path (p)
			action := act
			initialize
		end

feature -- Access

	action: PROCEDURE [ANY, TUPLE [env: REST_ENVIRONMENT; format: detachable STRING; args: detachable STRING]]

	authentication_required: BOOLEAN assign set_authentication_required

feature -- Element change

	set_authentication_required (b: like authentication_required)
		do
			authentication_required := b
		end

feature -- Execution

	execute_application (henv: REST_ENVIRONMENT; a_format: detachable STRING; a_args: detachable STRING)
		do
			action.call ([henv, a_format, a_args])
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
