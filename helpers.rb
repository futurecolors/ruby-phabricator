require 'net/http'
require 'json'
require 'digest/sha1'


def make_http_request(method, url, data={}, headers={})
  method.downcase!
  if not ['get', 'post'].include? method
    raise 'Bad method'
  end
  url = URI.parse url
  if method.eql? 'get'
    req = Net::HTTP::Get.new url.path, headers
  elsif method.eql? 'post'
    req = Net::HTTP::Post.new url.path, headers
    req.set_form_data data
  end
#  req.basic_auth http_auth_user, http_auth_pwd
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  return res
end

def make_get_request(url, data={}, headers={})
  return make_http_request 'get', url, data, headers
end

def make_post_request(url, data={}, headers={})
  return make_http_request 'post', url, data, headers
end

def get_arc_settings(settings_file_name=nil)
  settings_file_name ||= File.expand_path("~/.arcrc")
  return JSON.parse(File.read settings_file_name)
end

def get_username_from_arc_settings
  settings = get_arc_settings
  return settings['hosts'].values[0]['user']
end

def get_host_from_arc_settings
  settings = get_arc_settings
  return settings['hosts'].keys[0]
end

def check_arc_settings
  # Checks if .arcrc has hosts. If there are more than one host, shows message.
  settings = get_arc_settings
  if not settings.include? 'hosts'
    puts "ERROR: Your .arcrc file has no info about host or doesn't exists. Install arc and run install-certificate."
  elsif settings['hosts'].keys.length > 1
    puts "ERROR: Your .arcrc file has more than one host. Comment out hosts you don't need"
  end
end

def generate_hash(token, cert)
  return Digest::SHA1.hexdigest token + cert
end

def get_phabricator_request_body(data={})
  return {
    'params' => data.to_json,
    'output' => 'json',
    'host' => 'http:/localhost',
  }
end

def get_auth_kwargs(username)
  settings = get_arc_settings
  cert = settings['hosts'].values[0]['cert']
  token = "%.8f" % Time.now.to_f
  return {
    'authToken' => token,
    'authSignat' => generate_hash(token, cert),
    'user' => username,
  }
end
