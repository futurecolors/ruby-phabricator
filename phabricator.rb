#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require_relative "wrapper"
require_relative "shortcuts"


puts get_commit_status 'PAT', 'd26e6e20'
puts get_commit_status 'PAT', '209a3ffa991169db6f273a3eedfb5f7ad735430b'
