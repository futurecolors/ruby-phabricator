ruby-phabricator
================

[![Build Status](https://travis-ci.org/Melevir/ruby-phabricator.png)](https://travis-ci.org/Melevir/ruby-phabricator)
[![Coverage Status](https://coveralls.io/repos/Melevir/ruby-phabricator/badge.png?branch=master)](https://coveralls.io/r/Melevir/ruby-phabricator)

Phabricator API Wrapper for Ruby.

# Installation

1. [Install Phabricator Arcanist] (http://www.phabricator.com/docs/phabricator/article/Arcanist_User_Guide.html#installing-arcanist).
2. Launch `arc install-certificate` and follow instructions. You must have `~/.arcrc` after this step.
3. Clone this repo with `$ git clone git@github.com:Melevir/ruby-phabricator.git`.

# Usage

## In Ruby code

### Direct API request

In your code import `wrapper.rb` and use Phabricator API with `make_api_call` method. For example:
```ruby
    commits = ["rPRJc58eef262b497647bdec510c2ca2dcbd15f9d4e5",]
    commit_info = make_api_call 'diffusion.getcommits', {"commits" => commits}
    commit_message = commit_info['result'].values[0]['commitMessage']
    puts commit_message
```

### Using shortcuts

Shortcuts are sets of commnds that covers most usual user cases.

Now there is only one shortcut:

#### get_commit_status

Returns statuses and phabricator urls of given commit.

Usage:
```ruby
    require 'ruby-phabricator/shortcuts.rb'

    project_sid = 'MYPRJ'  # Phabricator project slug
    changesets = [
        'de21b90bfac6cf0cf71593d5b2feca05131b1f88', 
        'ebc0730753794f6266e94f3329d693adb71ab583'
    ]  # commit's hashes, which statuses you need
    arcrc_path = File.expand_path('./.arcrc')  # Path to .arcrc file
    data = get_commit_status project_sid, changesets, arcrc_path
    commit1_status = data['de21b90bfac6cf0cf71593d5b2feca05131b1f88']['status']  # string representation of commit's status, e.g. 'accepted' or 'concerned'
    commit2_url = data['ebc0730753794f6266e94f3329d693adb71ab583']['url']  # url to phabricator's page of the commit
```

## In bash

`phabricator.rb` provides command-line interface to `make_api_call` method. Sample usage:
```
    $ cd /somewhere/ruby-phabricator/
    $ ruby ./phabricator.rb conduit.ping
    {"result"=>"dev", "error_code"=>nil, "error_info"=>nil}
    $ ruby ./phabricator.rb --data='{"name": "PRJ"}' arcanist.projectinfo
    {"result"=>nil, "error_code"=>"ERR-BAD-ARCANIST-PROJECT", "error_info"=>"No such project exists."}
```

# For contributors

## Todo

* Handling error messages from API.
* More shortcut functions
