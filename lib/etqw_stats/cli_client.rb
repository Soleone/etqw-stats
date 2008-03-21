module ETQWStats
	
CONSOLE_HELP = <<-END_OF_HELP

Shows you statistics of your Enemy Territory: Quake Wars account.

You can also save a snapshot of your current statistics to your hard disk.
This way you can compare different dates, to tell on which days you were better
than others.

For example, if you compare today with yesterday, you'll' see how many XP you 
gained yesterday, and how many kills you made with what weapon, what classes
and vehicles you used, etc..

  Usage Examples:
  ---------------
  1. Show current Stats for user:
     etqw_stats USERNAME
  
  2. Show difference between two sessions:
     etqw_stats USERNAME OLDER_STATS_FILE
  
  3. Download the current stats for user:
     etqw_stats download soleone d:/
     
  4. Compare current stats with last downloaded one
     etqw_stats lastsession soleone d:/
	
END_OF_HELP

	# Command Line Client for basic usage
	class CliClient
		
		# initialize with command line arguments (ARGV)
		def initialize(args=nil)
			@args = args
		end
		
		def start
			case @args.size
			when 0
				puts CONSOLE_HELP
			when 1
				stats = ETQWStats.get(@args[0])
			# not really used at the moment
			when 2
				stats = ETQWStats.make_diff(@args[0], @args[1])
			when 3
				if (@args[0].downcase == 'download')
					xml = ETQWStats.download_for_user(@args[1])
					new_file_name = File.expand_path(File.join(@args[2], filename_for_stats(xml)))
					File.open(new_file_name, 'w') do |file|
						file.write(xml)
					end
					puts "Finished downloading of profile for player #{@args[1]} to #{new_file_name}"
				elsif (@args[0].downcase == 'lastsession')
					last_file = newest_history_file(@args[2])
					stats = ETQWStats.make_diff(@args[1], last_file)
				else
					puts "Example: (download the current stats for user)\netqw_stats download MyName d:/my_name.xml"
				end
			end
			puts stats.to_s
		end
		
	private
		def newest_history_file(directory)
			all_files = File.join(File.expand_path(directory), '/*')
			sorted = Dir[all_files].sort_by do |file|
				File.ctime(file)
			end
			sorted.last
		end
		
		def filename_for_stats(xml)
			user_info = ETQWStats.parse(xml).user_info
			time = user_info.updated_at
			time.strftime("%m-%d-%Y-%H_%M-#{user_info.username}.xml")
		end
	end
end