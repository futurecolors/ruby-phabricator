ruby-phabricator
================

[![Build Status](https://travis-ci.org/Melevir/ruby-phabricator.png)](https://travis-ci.org/Melevir/ruby-phabricator)

Phabricator API Wrapper for Ruby.

# Installation

1. [Install Phabricator Arcanist] (http://www.phabricator.com/docs/phabricator/article/Arcanist_User_Guide.html#installing-arcanist).
2. Launch `arc install-certificate` and follow instructions. You must have `~/.arcrc` after this step.
3. Clone this repo with `$ git clone git@github.com:Melevir/ruby-phabricator.git`.

# Usage

## In Ruby code

In your code import `wrapper.rb` and use Phabricator API with `make_api_call` method. For example:
```ruby
    commits = ["rPRJc58eef262b497647bdec510c2ca2dcbd15f9d4e5",]
    commit_info = make_api_call 'diffusion.getcommits', {"commits" => commits}
    commit_message = commit_info['result'].values[0]['commitMessage']
    puts commit_message
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

## Installing gems required for testing

```
gem install webmock
gem install fakefs
```

* [Webmock](https://github.com/bblimke/webmock) used for mocking HTTP requests in tests.
* [FakeFS](https://github.com/defunkt/fakefs) used for mocking FileSystem (`~/.arcrc` file).

## Todo

* Shortcut for getting status of list of commits in one request.
* Handling error messages from API.
