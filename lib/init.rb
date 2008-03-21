# adds the current dir to the ruby classpath
APP_DIR = File.join(File.dirname(__FILE__), 'etqw_stats')

#puts APP_DIR
$:.unshift APP_DIR

# require gems and standard lib
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'net/http'

# require all ruby files in etqw_stats directory
#puts APP_DIR
Dir[APP_DIR + '/*'].each { |file| Object.send(:require, file) if /\.rb$/ =~ file }

