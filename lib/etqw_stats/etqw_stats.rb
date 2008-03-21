# Analyzes the statistics file (which is available as an RSS feed) of an Enemy Territory: Quake Wars account.
# Compare your XP, kills, etc. between different sessions of your career.
module ETQWStats
	BASE_URL = "http://stats.enemyterritory.com/profile/"
	
	# Parse a string containing an XML instance and return a new UserStats instance
	def self.parse(xml)
		Parser.new.parse(xml)
	end
	
	# Parse XML from a URL or file location and return a new UserStats instance
	def self.parse_from(url)
		Parser.new.parse_from(url)
	end
	
	# Get the current XML feed of the +username+ from the server and return a new UserStats instance
	def self.for(username)
		self.parse_from(url_for_user(username))
	end 
	
	# Automatically decides if a username or file-location is supplied
	# TODO: don't just decide skip the username if it contains a . or /
	def self.get(username_or_url)
		unless username_or_url =~ /[\.\/]/
			self.for(username_or_url)
		else
			self.parse_from(username_or_url)
		end
	end
	
	# Just downloads the XML-file and returns it's content as a string
	def self.download_for_user(name)
		open(url_for_user(name)).readlines.join("\n")
	end
	
	# Calculates the difference between two et:qw sessions and returns it as a UserStats object
	def self.make_diff(newer_xml_file, older_xml_file)	
		newer, older = newer_xml_file, older_xml_file
		newer_stats, older_stats = ETQWStats.get(newer), ETQWStats.get(older)
		return newer_stats - older_stats
	end
	
	private
	def self.url_for_user(name)
		BASE_URL + name.to_s + '?xml=true'
	end
end	
