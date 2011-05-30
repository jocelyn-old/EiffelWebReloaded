note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	NET_REST_SERVICE_API

inherit
	REST_SERVICE_API
		redefine
			internal_api_call
		end

feature {NONE} -- Implementation

	internal_api_call (a_api_url: STRING; a_require_credentials: BOOLEAN; a_http_post: BOOLEAN): STRING
			-- REST API call for `a_api_url' with `a_require_credentials' and `a_http_post'
		local
			rest_prot: REST_HTTP_PROTOCOL
			l_url: STRING
		do
			l_url := a_api_url.string
			if attached application_source as l_app_src then
				append_parameters_to_url (l_url, <<["source", l_app_src]>>)
			end

			create rest_prot.make (create {HTTP_URL}.make (l_url))
			if attached username as u and attached password as p then
				rest_prot.set_username (u)
				rest_prot.set_password (p)
			end
			rest_prot.open
			rest_prot.initiate_transfer
			http_status := 0
			from
				create Result.make (rest_prot.count)
			until
				not rest_prot.is_packet_pending
			loop
				rest_prot.read
				if attached rest_prot.last_packet as pkt then
					Result.append (pkt)
				end
			end
			rest_prot.close
			last_api_call := l_url
		end

;note
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
