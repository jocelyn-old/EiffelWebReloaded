note
	description: "Summary description for {HTTPD_FILE_RESPONSE}."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_FILE_RESPONSE

inherit
	HTTPD_RESPONSE
		redefine
			send
		end

	HTTP_FILE_SYSTEM_UTILITIES

create
	make

feature {NONE} -- Initialization

	make (a_filename: STRING)
		do
			file_name := a_filename
			base_name := basename (a_filename)
			initialize
			prepare
		end

	prepare
		local
			h: like headers
			bfn: STRING
		do
			h := headers
			bfn := base_name

			h.put_content_type_with_name (content_type_by_extension (file_extension (bfn)), bfn)
			h.put_content_transfer_encoding ("binary")
			h.put_content_length (filesize (file_name))
			h.put_content_disposition ("attachment", "filename=%""+ bfn +"%"")
			h.put_expires (0)
			h.put_cache_control ("no-cache, must-revalidate")
			h.put_pragma_no_cache
		end

feature -- Access

	file_name: STRING

	base_name: STRING

feature -- Query

	string: STRING
			-- String representation of the response
		do
			Result := headers.string
			--TODO append the file's content ...
		end

	send (output: HTTPD_SERVER_OUTPUT)
		do
			output.put_string (headers.string)
			output.put_file_content (file_name)
		end

end
