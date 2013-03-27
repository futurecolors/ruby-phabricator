#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require_relative "wrapper"
require_relative "shortcuts"
require 'optparse'
require 'json'

options = {}

#def get_commit_status project_sid, commit_ids, settings_file_name

#puts get_commit_status 'belonika', ['95d8837efebaca7b8b6f860e4cb58fd6884af580', 'c17bf3cadfb6f562d770b0dd37bfa5fd6211f4df'], '/home/melevir/.arcrc'
#puts get_commit_status 'BELONIKA', ['95d8837e', 'c17bf3ca'], '/home/melevir/.arcrc'
puts get_commit_status 'BELONIKA', ['95d8837e', 'c17bf3ca'], '/home/melevir/fake_arcrc'

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
