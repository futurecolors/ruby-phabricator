require_relative "wrapper"


def get_commit_status project_sid, commit_id
  commit_sid = get_commit_sid project_sid, commit_id
  commit_phid = get_commit_phid commit_sid
  commit_status = get_commit_status_by_phid commit_phid
  return commit_status
end

def get_commit_phid(commit_sid)
  res = make_api_call 'diffusion.getcommits', data={"commits" => [commit_sid,]}
  return res['result'].values[0]['commitPHID']
end

def get_commit_status_by_phid(commit_phid)
  res = make_api_call 'audit.query', data={"commitPHIDs" => [commit_phid,]}
  return res['result'][0]['status']
end

def get_commit_sid(project_sid, commit_id)
  return "r#{project_sid}#{commit_id}"
end

