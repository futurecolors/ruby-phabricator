ruby-phabricator
================

Phabricator API Wrapper for Ruby.

# Installation

1. [Install Phabricator Arcanist] (http://www.phabricator.com/docs/phabricator/article/Arcanist_User_Guide.html#installing-arcanist)
2. Launch `arc install-certificate` and follow instructions. You must have `~/.arcrc` after this step.
3. Clone this repo with `git clone git@github.com:Melevir/ruby-phabricator.git`

# Usage

In your code import `wrapper.rb` and use Phabricator API with `make_api_call` method. For example:
```ruby
    commits = ["rPATc58eef262b497647bdec510c2ca2dcbd15f9d4e5",]
    commit_info = make_api_call 'diffusion.getcommits', {"commits" => commits}
    commit_message = commit_info['result'].values[0]['commitMessage']
    puts commit_message
```
