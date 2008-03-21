module ETQWStats
	class Parser
		def parse_from(location)
			parse(open(location))
		end
		
		def parse(xml)
			stats = UserStats.new
			doc = Hpricot::XML(xml)
			# get user info
			infos = doc.at :user_info
			params = UserInfo::ATTRIBUTES.map do |param|
				infos[param]
			end
			stats.user_info = UserInfo.new(*params)
			
			# get totals
			total = doc.at :total
			params = Totals::ATTRIBUTES.map do |param|
				total[param]		
			end
			stats.totals = Totals.new(*params)
			
			# get all badges as Ruby objects
			(doc/'badges').each do |badges|
				badge = Badge.new(badges[:category], badges[:level])
				(badges/'tasks').each do |tasks|
					badge.task tasks[:id], tasks[:total], tasks[:value]
				end
				stats.badges << badge
			end
			return stats
		end
	end
end