require_relative "wrapper"
require_relative "helpers"


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
  begin
    commit_sids = get_commit_sids project_sid, commit_ids
    commit_phids = get_commit_phids commit_sids, settings_file_name
    commit_statuses = get_commit_status_by_phids commit_phids[0], settings_file_name
  rescue Exception => e
    # Do not throw exception if somethings went wrong - we're just helper plugin, isn't it?
    print_exceprion_trace e
    commit_statuses = nil
  end

  result = {}
  if not commit_statuses.nil?
  commit_phids[1].each{|e|
    s = e[0]  #FIXME: WTF? Make this clear
    p = e[1]
    u = e[2]
    result[s] = {}
    result[s]['url'] = u
    result[s]['status'] = get_result_commit_status commit_statuses[p]
  }
  end
  return result
end

def print_exceprion_trace e
    puts e.message
    JSON.parse(e.backtrace.inspect).each{|line| puts line }
end

def get_commit_phids(commit_sids, settings_file_name)
  res = make_api_call 'diffusion.getcommits', settings_file_name, data={"commits" => commit_sids}
  return [res['result'].values.map{|v| v['commitPHID']}, res['result'].keys.map{|k|
            [k, res['result'][k]? res['result'][k]['commitPHID'] : 'no_phid', res['result'][k]['uri']]
          }]
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

def get_commits_branches project_sid, commit_ids, settings_file_name, login, auth_cookie_value
  result = {}
  headers = {
    'Cookie' => "phusr=#{login}; phsid=#{auth_cookie_value}"
  }
  commit_ids.each{|commit_id|
    host = get_host_from_arc_settings settings_file_name
    host = host[0, host.length - 4]  # stripping 'api/' suffix
    branches_url = "#{host}diffusion/#{project_sid}/commit/#{commit_id}/branches/"
    branches_response = make_get_request(branches_url, {}, headers).body
    branches = get_branches_from_raw_data branches_response
    commit_sid = get_commit_sids(project_sid, [commit_id])[0]
    result[commit_sid] = branches
  }
  return result
end

def get_base_repositiry_url project_sid, settings_file_name
  host = get_host_from_arc_settings settings_file_name
  host = host[0, host.length - 4]  # stripping 'api/' suffix
  return "#{host}diffusion/#{project_sid}/browse/"
end
