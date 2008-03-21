ETQWStats is a Ruby Binding for analyzing statistic files of Enemy Territory: Quake Wars.

You can save a snapshot of your current statistics to your hard disk.
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
	