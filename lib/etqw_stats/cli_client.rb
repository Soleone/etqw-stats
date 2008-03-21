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
     etqw_stats show USERNAME

  2. Download the current stats for user:
     etqw_stats download soleone
     
  3. Show difference between two sessions:
     etqw_stats compare USERNAME OLDER_STATS_FILE
  
  4. Compare current stats with last downloaded one
     etqw_stats lastsession soleone
  
  5. Compare the second last downloaded session with the session before
     etqw_stats session 2
	
END_OF_HELP

	# Command Line Client for basic usage
	class CliClient
		
		# initialize with command line arguments (ARGV)
		def initialize(args=nil)
			@args = args
		end
		
		def start
			command = @args[0]
			case @args.size
			when 0
				puts CONSOLE_HELP
			when 1..4
				target_dir = @args[2] || 'history'
				if (@args[0].downcase == 'show')
					stats = ETQWStats.get(@args[1])
				elsif (@args[0].downcase == 'download')
					xml = ETQWStats.download_for_user(@args[1])
					new_file_name = File.expand_path(File.join(target_dir, filename_for_stats(xml)))
					File.open(new_file_name, 'w') do |file|
						file.write(xml)
					end
					puts "Finished downloading of profile for player #{@args[1]} to #{new_file_name}"
				else
					# compare actual stats from web to last downloaded one
					if (command.downcase == "lastsession")
						older_file = history_file_newest(target_dir)
						newer_file = @args[1] || name_from_history_file(older_file)
					# compare two neighbouring downloaded stats sessions
					elsif (command.downcase == "session")
						count = @args[1].to_i || 1
						newer_file = history_file_at(target_dir, count)
						older_file = history_file_at(target_dir, 1 + count)
						puts "Comparing these two statistics:\n \"#{older_file}\"\n -> \n\"#{newer_file}\""
					elsif (command.downcase == 'compare')
						newer_file, older_file = @args[1], target_dir
					else
						return "Wrong command issued.\nTry etqw_stats download USERNAME"
					end
					stats = ETQWStats.make_diff(newer_file, older_file)
				end
			end
			puts stats.to_s
		end
		
	private
		def history_file_newest(directory)
			history_file_at(directory, 1)
		end
		
		def history_file_at(directory, position_beginning_at_end)
			all_files = File.join(File.expand_path(directory), '/*')
			sorted = Dir[all_files].sort_by do |file|
				File.ctime(file)
			end
			sorted[-position_beginning_at_end]
		end
		
		def filename_for_stats(xml)
			user_info = ETQWStats.parse(xml).user_info
			time = user_info.updated_at
			time.strftime("%m-%d-%Y-%H_%M-#{user_info.username}.xml")
		end
		
		def name_from_history_file(filename)
			/-\d\d_\d\d-([^\.]+)\.xml$/ =~ filename
			return $1
		end
	end
end