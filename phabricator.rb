#!/usr/bin/ruby

require_relative "helpers"


def get_commit_status(project_sid, commit_id)
  auth_token = get_auth_token()
  commit_sid = get_commit_sid project_sid, commit_id
  commit_phid = get_commit_phid commit_sid
  commit_status = get_commit_status_by_phid commit_phid
  return commit_status
end

def get_auth_token()
  return 'test_token'
end

def get_commit_phid(commit_sid)
  return 'test_phid'
end

def get_commit_status_by_phid(commit_phid)
  return 'accepted'
end

def get_commit_sid(project_sid, commit_id)
  return "r#{project_sid}#{commit_id}"
end

puts get_commit_status 'prj', '123'
