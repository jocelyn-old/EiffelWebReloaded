note
	description: "Summary description for {HTTP_FILE_SYSTEM_UTILITIES}."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_FILE_SYSTEM_UTILITIES

feature -- Access

	filesize (fn: STRING): INTEGER
			-- Size of the file `fn'.
		local
			f: RAW_FILE
		do
			create f.make (fn)
			if f.exists then
				Result := f.count
			end
		end

	file_extension (fn: STRING): STRING
			-- Extension of file `fn'.
		local
			p: INTEGER
		do
			p := fn.last_index_of ('.', fn.count)
			if p > 0 then
				Result := fn.substring (p + 1, fn.count)
			else
				Result := ""
			end
		end

	basename (fn: STRING): STRING
			-- Basename of `fn'.
		local
			p: INTEGER
		do
			p := fn.last_index_of ((create {OPERATING_ENVIRONMENT}).Directory_separator, fn.count)
			if p > 0 then
				Result := fn.substring (p + 1, fn.count)
			else
				Result := fn
			end
		end

	dirname (fn: STRING): STRING
			-- Dirname of `fn'.	
		local
			p: INTEGER
		do
			p := fn.last_index_of ((create {OPERATING_ENVIRONMENT}).Directory_separator, fn.count)
			if p > 0 then
				Result := fn.substring (1, p - 1)
			else
				Result := ""
			end
		end

feature -- Content-type related

	content_type_by_extension (ext: STRING): STRING
			-- Content type associated with extension `ext'.
		local
			e: STRING
		do
			e := ext.as_lower
			if e.same_string ("pdf") then
      			Result := "application/pdf"
      		elseif e.same_string ("exe") then
      			Result := "application/octet-stream"
      		elseif e.same_string ("exe") then
				Result := "application/octet-stream"
      		elseif e.same_string ("zip") then
				Result := "application/zip"
      		elseif e.same_string ("doc") then
				Result := "application/msword"
      		elseif e.same_string ("xls") then
				Result := "application/vnd.ms-excel"
      		elseif e.same_string ("ppt") then
				Result := "application/vnd.ms-powerpoint"
      		elseif e.same_string ("gif") then
				Result := "image/gif"
      		elseif e.same_string ("png") then
				Result := "image/png"
      		elseif e.same_string ("jpg") or e.same_string ("jpeg") then
				Result := "image/jpg"
      		else
				Result := "application/force-download"
			end
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
