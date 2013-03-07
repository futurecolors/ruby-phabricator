# Phabricator Conduit API wrapper.
# Before use make sure you have valid ~/.arcrc file.
# Sample usage:
# make_api_call method_address='diffusion.getcommits', data={"commits" => ["rPATc58eef262b497647bdec510c2ca2dcbd15f9d4e5"]}

require_relative "helpers"


def auth(username)
  # Makes auth request, parses response and returns auth data.
  settings = get_arc_settings
  cert = settings['hosts'].values[0]['cert']
  token = "%.8f" % Time.now.to_f
  kwargs = get_auth_kwargs username
  data = get_phabricator_request_body kwargs
  resp = make_phabricator_request 'conduit.connect', data
  return {
    '__conduit__' => {
      'sessionKey' => resp['result']['sessionKey'],
      'connectionID' => resp['result']['connectionID'],
    },
  }
end

def make_phabricator_request(method_address, data={})
  # Sends request to Phabricator API and parses response.
  host = get_host_from_arc_settings
  headers = {
    'User-Agent' => 'ruby-phabricator/0.1',
    'Content-Type' => 'application/x-www-form-urlencoded',
  }
  response =  make_post_request "#{host}#{method_address}", data, headers
  return JSON.parse response.body
end

def make_api_call(method_address, data={}, auth_data=nil)
  # Sends request to Phabricator API and parses response.
  # Makes auth request if no auth_data provided.
  check_arc_settings
  kwargs = auth_data || auth(get_username_from_arc_settings)
  kwargs.merge! data
  result_data = get_phabricator_request_body kwargs
  return make_phabricator_request method_address, result_data
end
