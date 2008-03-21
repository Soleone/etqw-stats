require 'lib/init'

if $0 == __FILE__
	ETQWStats::CliClient.new(ARGV).start
	#dir = File.expand_path(File.join(APP_DIR, '..', '..', 'tmp'))
	#puts "Looking in   #{dir}"
	#puts "Newest file: #{ETQWStats::CliClient.new.newest_history_file(dir)}"
end