note
	description: "Summary description for {HTTPD_DOWNLOAD_RESPONSE}."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPD_DOWNLOAD_RESPONSE

inherit
	HTTPD_FILE_RESPONSE
		redefine
			prepare
		end

create
	make

feature {NONE} -- Initialization

	prepare
		do
			headers.put_content_type_with_name ("application/force-download", base_name)
			Precursor
		end

end
