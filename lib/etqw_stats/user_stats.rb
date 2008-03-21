module ETQWStats
	class UserStats
		attr_accessor :user_info, :badges, :totals
		
		def initialize
			@badges = []
		end
		
		def to_s
			stats = @user_info.to_s << "\n\n"
			@badges.each do |badge|
				stats << badge.to_s
			end	
			stats << "\n\n" << @totals.to_s
		end
		
		def self.parse(url)
			ETQWStats.parse(url)
		end
		
		def -(other)
			unless self.user_info.username == other.user_info.username
				raise "Can only subtract UserStats of the same username!"
			end
			diff = UserStats.new
			# make a diff on the totals
			diff.totals = @totals - other.totals
			# make a diff on the user_info
			diff.user_info = @user_info - other.user_info
			# make a diff on all badges
			@badges.size.times do |i|
				badge_diff = @badges[i] - other.badges[i]
				diff.badges << badge_diff
			end
			return diff
		end
	end
	
	class UserInfo
		ATTRIBUTES = %w{username updated_at country rank id military_rank }
		
		attr_reader :username, :updated_at, :country, :rank, :id, :military_rank
		
		def initialize(username, updated_at, country, rank, id, military_rank)
		 	@username, @country, @rank, @id, @military_rank = 
		 		username, country, rank.to_i, id, military_rank
		 	@updated_at = updated_at.is_a?(Time) ? updated_at : Time.parse(updated_at)
		end
		
		def to_s
			"#{@username} last updated at #{updated_at.hour}:#{updated_at.min} - #{updated_at.day}.#{updated_at.month}.#{updated_at.year}"
		end
		
		def ==(other)
			ATTRIBUTES.each do |attribute|
				unless self.send(attribute) == other.send(attribute)
					return false
				end
			end
			return true
		end
	
		def -(other)
			raise "Can only subtract a UserInfo of the same username!" unless self.username == other.username
			diff = DiffUserInfo.new(@username, @updated_at, @country, @rank, @id, @military_rank)
			diff.time_difference = (@updated_at.to_i - other.updated_at.to_i) / 60
			diff.promoted = @military_rank != other.military_rank
			diff.rank_increase = other.rank - @rank
			return diff
		end
	end
	
	class DiffUserInfo < UserInfo
		attr_accessor :time_difference, :promoted, :rank_increase
		
		def to_s
			string = super << "\n" << "#{@time_difference} minutes between sessions.\n"
			if @rank_increase != 0
				string << "Rank " << (@rank_increase > 0 ? 'increased' : 'decreased')  << " by " << 
					@rank_increase.abs.to_s << "\n"
			end
			if @promoted
				string << "You have since then been promoted to #{@military_rank}"
			end
			return string
		end
	end
	
	class Totals
		ATTRIBUTES = %w{time_played kills deaths xp accuracy }
		ATTRIBUTES.each { |attribute| attr_reader attribute }
		#attr_reader :time_played, :kills, :deaths, :xp, :accuracy
		
		def initialize(time_played, kills, deaths, xp, accuracy)
			@time_played, @kills, @deaths, @xp, @accuracy = 
				time_played.to_i, kills.to_i, deaths.to_i, xp.to_f, accuracy.to_f
		end
		
		def to_s
			"Time played:      #{"%0.2f" % (@time_played.to_f / 60 / 60)} hours\n" <<
			"Total XP:         #{"%0.0f" % @xp.to_f}\n" <<
			"Kills / Death:    #{@kills} / #{@deaths} (#{"%0.2f" % (@kills.to_f / @deaths.to_f)})\n" <<
			"Accuracy overall: #{"%0.2f" % @accuracy.to_f}"
		end
		
		def -(other)
			params = ATTRIBUTES.map do |attribute|
				self.send(attribute) - other.send(attribute)
			end
			diff = DiffTotals.new(*params)
		end
	end
	
	class DiffTotals < Totals
		def to_s
			"Time played since then: #{"%0.2f" % (@time_played.to_f / 60 / 60)} hours\n" <<
			"XP gained:              #{"%0.0f" % @xp.to_f}\n" <<
			"Kills / Death:          #{@kills} / #{@deaths} (#{"%0.2f" % (@kills.to_f / @deaths.to_f)})\n" <<
			"Accuracy " << (@accuracy >= 0 ? 'increased' : 'decreased')  << " by:  " << ("%0.2f" % @accuracy.abs)
		end
	end
	
	class Badge
		attr_reader :category, :level, :tasks
		
		def initialize(category, level, &block)
			@category, @level = category, level.to_i
			@tasks = []
			instance_eval &block if block_given?
		end
		
		def task(id, total, value)
			@tasks << {:id => id.to_i, :total => total.to_f, :value => value.to_f}
		end
		
		def to_s
			return '' if tasks_empty?
			string = "\n#{category.capitalize} Level #{level}"
			tasks.each do |task|
				string << "\n  #{task_to_s(task)}"
			end
			return string
		end
		
		def task_to_s(hash)
			"[#{hash[:id]}] #{ "%0.2f" % hash[:value]} / #{hash[:total]} "
		end
		
		def tasks_empty?
			@tasks.each do |task|
				return false if task[:value] > 0
			end
			return true
		end
		
		def ==(other)
			equal_category?(other) && self.tasks == other.tasks
		end
		
		def equal_category?(other)
			self.category == other.category && self.level == other.level
		end
		
		def eql?(other); self == other; end
		
		def -(other)
			raise "Can only subtract badges of the same category!" unless equal_category?(other)
			diff = DiffBadge.new(category, level)
			@tasks.size.times do |i|
				value_diff = @tasks[i][:value] - other.tasks[i][:value]
				diff.task @tasks[i][:id], @tasks[i][:total], value_diff
			end
			return diff
		end
		
	end
	
	class DiffBadge < Badge
		def task_to_s(hash)
			if hash[:value] == 0
				''
			else
				super
			end
		end
	end	
end