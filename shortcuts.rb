require_relative "wrapper"


def get_commit_status project_sid, commit_ids
  # Gets statuses of commits in given projects.
  # commit_ids can be list or single id.
  # Sample usage:
  #   get_commit_status 'PRJ', 'd26e6e20'
  #   get_commit_status 'PRJ', 'd26e6e20126006d60ce3cb2024f53330b8bc8329'
  #   get_commit_status 'PRJ', ['209a3ffa991169db6f273a3eedfb5f7ad735430b', 'd26e6e20126006d60ce3cb2024f53330b8bc8329']

  if not commit_ids.kind_of? Array
    commit_ids = [commit_ids]
  end
  commit_sids = get_commit_sids project_sid, commit_ids
  commit_phids = get_commit_phids commit_sids
  commit_statuses = get_commit_status_by_phids commit_phids
  return commit_statuses
end

def get_commit_phids(commit_sids)
  res = make_api_call 'diffusion.getcommits', data={"commits" => commit_sids}
  return res['result'].values.map{|v| v['commitPHID']}
end

def get_commit_status_by_phids(commit_phids)
  res = make_api_call 'audit.query', data={"commitPHIDs" => commit_phids}
  return res['result'].map{|r| r['status']}
end

def get_commit_sids(project_sid, commit_ids)
  return commit_ids.map{|id| "r#{project_sid}#{id}"}
end

