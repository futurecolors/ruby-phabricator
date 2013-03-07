#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require_relative "wrapper"
require_relative "shortcuts"
require 'optparse'
require 'json'

# puts get_commit_status 'PAT', 'd26e6e20'
# puts get_commit_status 'PAT', '209a3ffa991169db6f273a3eedfb5f7ad735430b'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: phabricator.rb [-d={...}] <API_METHOD_NAME>\n" +
                "Example: phabricator.rb --data='{\"name\": \"TEST_PRJ\"}' arcanist.projectinfo"
  opts.on('-d', '--data <DATA>', "Data that will be sended to method in JSON format") do |d|
    options[:data] = d
  end
end

optparse.parse!

if ARGV.empty?
  puts 'Specify Phabricator API method name.'
  exit
elsif ARGV.length > 1
  puts 'Specify exactly one Phabricator API method name.'
  exit
end

method_name = ARGV[0]
data = JSON.parse(options[:data] || "{}")
puts make_api_call method_name, data
