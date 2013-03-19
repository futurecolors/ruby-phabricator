require_relative "wrapper"


def get_commit_status project_sid, commit_ids, settings_file_name
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
  commit_phids = get_commit_phids commit_sids, settings_file_name
  commit_statuses = get_commit_status_by_phids commit_phids[0], settings_file_name
  result = {}
  if not commit_statuses.nil?
  commit_phids[1].each{|e|
    s = e[0]
    p = e[1]
    u = e[2]
  result[s] = {}
  result[s]['url'] = u
  if commit_statuses[p].nil?
    result[s]['status'] = 'in_progress'
  else
    if commit_statuses[p].include? 'accepted'
	result[s]['status'] = 'accepted'
    elsif commit_statuses[p].include? 'concerned'
	result[s]['status'] = 'conserned'
    else
	result[s]['status'] = 'in_progress'
   end
  end
  }
  end
  return result
end

def get_commit_phids(commit_sids, settings_file_name)
  res = make_api_call 'diffusion.getcommits', settings_file_name, data={"commits" => commit_sids}
  return [res['result'].values.map{|v| v['commitPHID']}, res['result'].keys.map{|k| [k, res['result'][k]? res['result'][k]['commitPHID'] : 'no_phid', res['result'][k]['uri']] }]
end

def get_commit_status_by_phids(commit_phids, settings_file_name)
  res = make_api_call 'audit.query', settings_file_name, data={"commitPHIDs" => commit_phids}
  result = {}
  res['result'].map{|r|
     if result.include? r['commitPHID']
	result[r['commitPHID']].push(r['status'])
     else
	result[r['commitPHID']] = [r['status'], ]
     end
  }
  return result
end

def get_commit_sids(project_sid, commit_ids)
  return commit_ids.map{|id| "r#{project_sid}#{id}"}
end

