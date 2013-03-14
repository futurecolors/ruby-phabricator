# Phabricator Conduit API wrapper.
# Sample usage:
# make_api_call method_address='diffusion.getcommits', data={"commits" => ["rPATc58eef262b497647bdec510c2ca2dcbd15f9d4e5"]}

require_relative "helpers"


def auth(username, settings_file_name)
  # Makes auth request, parses response and returns auth data.
  settings = get_arc_settings settings_file_name
  cert = settings['hosts'].values[0]['cert']
  token = "%.8f" % Time.now.to_f
  kwargs = get_auth_kwargs username, settings_file_name
  data = get_phabricator_request_body kwargs
  host = get_host_from_arc_settings settings_file_name
  resp = make_phabricator_request 'conduit.connect', host, data
  return {
    '__conduit__' => {
      'sessionKey' => resp['result']['sessionKey'],
      'connectionID' => resp['result']['connectionID'],
    },
  }
end

def make_phabricator_request(method_address, host, data={})
  # Sends request to Phabricator API and parses response.
  headers = {
    'User-Agent' => 'ruby-phabricator/0.1',
    'Content-Type' => 'application/x-www-form-urlencoded',
  }
  response =  make_post_request "#{host}#{method_address}", data, headers
  return JSON.parse response.body
end

def make_api_call(method_address, settings_file_name, data={}, auth_data=nil)
  # Sends request to Phabricator API and parses response.
  # Makes auth request if no auth_data provided.
# check_arc_settings settings_file_name
  kwargs = auth_data || auth(get_username_from_arc_settings(settings_file_name), settings_file_name)
  kwargs.merge! data
  result_data = get_phabricator_request_body kwargs
  host = get_host_from_arc_settings settings_file_name
  return make_phabricator_request method_address, host, result_data
end
