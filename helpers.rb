require 'net/http'


def make_http_request(method, url, data={})
  method.downcase!
  if not ['get', 'post'].include? method
    raise 'Bad method'
  end
  url = URI.parse(url)
  if method.eql? 'get'
    req = Net::HTTP::Get.new(url.path)
  elsif method.eql? 'post'
    req = Net::HTTP::Post.new(url.path)
  end
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  return res
end

def make_get_request(url, data={})
  return make_http_request('get', url, data)
end

def make_post_request(url, data={})
  return make_http_request('post', url, data)
end
