note
	description: "Summary description for {HTTPD_HEADER}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_HEADER

inherit
	HTTP_STATUS_CODE_MESSAGES

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize current
		do
			create {ARRAYED_LIST [STRING]} headers.make (3)
		end


feature -- Recycle

	recycle
		do
			headers.wipe_out
		end

feature -- Access

	headers: LIST [STRING]
			-- Header's lines

	string: STRING
			-- String representation of the headers
		local
			l_headers: like headers
		do
			create Result.make (32)
			l_headers := headers
			if l_headers.is_empty then
				put_content_type_text_html
			else
				from
					l_headers.start
				until
					l_headers.after
				loop
					append_line_to (l_headers.item, Result)
					l_headers.forth
				end
			end
			append_end_of_line_to (Result)
		end

feature -- Header change: general

	add_header (h: STRING)
		do
			headers.force (h)
		end

	put_header (h: STRING)
			-- Add header `h' or replace existing header of same header name
		do
			put_header_by_name (header_name (h), h)
		end

feature -- Content related header

	put_content_type (t: STRING)
		do
			put_header ("Content-type: " + t)
		end

	add_content_type (t: STRING)
			-- same as `put_content_type', but allow multiple definition of "Content-Type"
		do
			put_header ("Content-type: " + t)
		end

	put_content_type_with_name (t: STRING; n: STRING)
		do
			put_header ("Content-type: " + t + "; name=%"" + n + "%"")
		end

	add_content_type_with_name (t: STRING; n: STRING)
			-- same as `put_content_type_with_name', but allow multiple definition of "Content-Type"	
		do
			add_header ("Content-type: " + t + "; name=%"" + n + "%"")
		end

	put_content_type_text_css				do put_content_type ("text/css") end
	put_content_type_text_csv				do put_content_type ("text/csv") end
	put_content_type_text_html				do put_content_type ("text/html") end
	put_content_type_text_javascript		do put_content_type ("text/javascript") end
	put_content_type_text_plain				do put_content_type ("text/plain") end
	put_content_type_text_xml				do put_content_type ("text/xml") end

	put_content_type_application_json		do put_content_type ("application/json") end
	put_content_type_application_javascript	do put_content_type ("application/javascript") end
	put_content_type_application_zip		do put_content_type ("application/zip")	end

	put_content_type_image_gif				do put_content_type ("image/gif") end
	put_content_type_image_png				do put_content_type ("image/png") end
	put_content_type_image_jpg				do put_content_type ("image/jpg") end
	put_content_type_image_svg_xml			do put_content_type ("image/svg+xml") end

	put_content_type_message_http			do put_content_type ("message/http") end

	put_content_type_multipart_mixed		do put_content_type ("multipart/mixed") end
	put_content_type_multipart_alternative	do put_content_type ("multipart/alternative") end
	put_content_type_multipart_related		do put_content_type ("multipart/related") end
	put_content_type_multipart_form_data	do put_content_type ("multipart/form-data") end
	put_content_type_multipart_signed		do put_content_type ("multipart/signed") end
	put_content_type_multipart_encrypted	do put_content_type ("multipart/encrypted") end


	put_content_length (n: INTEGER)
		do
			put_header ("Content-Length: " + n.out)
		end

	put_content_transfer_encoding (a_mechanism: STRING)
			-- Put "Content-Transfer-Encoding" header with for instance "binary"
			--|   encoding := "Content-Transfer-Encoding" ":" mechanism
			--|
			--|   mechanism :=     "7bit"  ;  case-insensitive
			--|                  / "quoted-printable"
			--|                  / "base64"
			--|                  / "8bit"
			--|                  / "binary"
			--|                  / x-token

		do
			put_header ("Content-Transfer-Encoding: " + a_mechanism)
		end

	put_content_disposition (a_type: STRING; a_params: detachable STRING)
			-- Put "Content-Disposition" header
			--| See RFC2183
			--|     disposition := "Content-Disposition" ":"
			--|                    disposition-type
			--|                    *(";" disposition-parm)
			--|     disposition-type := "inline"
			--|                       / "attachment"
			--|                       / extension-token
			--|                       ; values are not case-sensitive
			--|     disposition-parm := filename-parm
			--|                       / creation-date-parm
			--|                       / modification-date-parm
			--|                       / read-date-parm
			--|                       / size-parm
			--|                       / parameter
			--|     filename-parm := "filename" "=" value
			--|     creation-date-parm := "creation-date" "=" quoted-date-time
			--|     modification-date-parm := "modification-date" "=" quoted-date-time
			--|     read-date-parm := "read-date" "=" quoted-date-time
			--|     size-parm := "size" "=" 1*DIGIT
			--|     quoted-date-time := quoted-string
			--|                      ; contents MUST be an RFC 822 `date-time'
			--|                      ; numeric timezones (+HHMM or -HHMM) MUST be used
		do
			if a_params /= Void then
				put_header ("Content-Disposition: " + a_type + "; " + a_params)
			else
				put_header ("Content-Disposition: " + a_type)
			end
		end

feature -- Status, ...

	put_status (a_code: INTEGER)
		local
			h: STRING
		do
			create h.make (10)
			h.append_string ("Status: ")
			h.append_integer (a_code)
			h.append_character (' ')
			if attached http_status_code_message (a_code) as l_status_message then
				h.append_string (l_status_message)
			end
			put_header (h)
		end

	put_expires (n: INTEGER)
		do
			put_header ("Expires: " + n.out)
		end

	put_cache_control (s: STRING)
			-- `s' could be for instance "no-cache, must-revalidate"
		do
			put_header ("Cache-Control: " + s)
		end

	put_pragma (s: STRING)
		do
			put_header ("Pragma: " + s)
		end

	put_pragma_no_cache
		do
			put_pragma ("no-cache")
		end

feature -- Redirection

	put_redirection (a_location: STRING; a_code: INTEGER)
		do
			if a_code > 0 then
				put_status (a_code)
			else
				put_status (302) -- Found
			end
			put_header ("Location: " + a_location)
		end

	put_refresh (a_location: STRING; a_timeout: INTEGER; a_code: INTEGER)
		do
			if a_code > 0 then
				put_status (a_code)
			else
				put_status (200) -- Ok
			end
			put_header ("Refresh: "+ a_timeout.out + "; url=" + a_location)
		end

feature -- Cookie

	put_cookie (key, value: STRING_8; expiration, path, domain, secure: detachable STRING_8)
			-- Set a cookie on the client's machine
			-- with key 'key' and value 'value'.
		require
			make_sense: (key /= Void and value /= Void) and then (not key.is_empty and not value.is_empty)
		local
			s: STRING
		do
			s := "Set-Cookie:" + key + "=" + value
			if expiration /= Void then
				s.append (";expires=" + expiration)
			end
			if path /= Void then
				s.append (";path=" + path)
			end
			if domain /= Void then
				s.append (";domain=" + domain)
			end
			if secure /= Void then
				s.append (";secure=" + secure)
			end
			add_header (s)
		end

feature {NONE} -- Implementation: Header

	put_header_by_name (n: detachable STRING; h: STRING)
			-- Add header `h' or replace existing header of same header name `n'
		require
			h_has_name_n: (n /= Void and attached header_name (h) as hn) implies n.same_string (hn)
		local
			l_headers: like headers
		do
			if n /= Void then
				from
					l_headers := headers
					l_headers.start
				until
					l_headers.after or l_headers.item.starts_with (n)
				loop
					l_headers.forth
				end
				if not l_headers.after then
					l_headers.replace (h)
				else
					add_header (h)
				end
			else
				add_header (h)
			end
		end

	header_name (h: STRING): detachable STRING
			-- If any, header's name with colon
			--| ex: for "Foo-bar: something", this will return "Foo-bar:"
		local
			i,n: INTEGER
			c: CHARACTER
		do
			from
				i := 1
				n := h.count
				create Result.make (10)
			until
				i > n or c = ':' or Result = Void
			loop
				c := h[i]
				inspect c
				when ':' then
					Result.extend (c)
				when '-', 'a' .. 'z', 'A' .. 'Z' then
					Result.extend (c)
				else
					Result := Void
				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	append_line_to (s, h: STRING)
		do
			h.append_string (s)
			append_end_of_line_to (h)
		end

	append_end_of_line_to (h: like string)
		do
			h.append_character ('%R')
			h.append_character ('%N')
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
