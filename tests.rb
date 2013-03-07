#!/usr/bin/ruby

require "test/unit"
require 'webmock/test_unit'
require 'fakefs'
require_relative "helpers"
require_relative "wrapper"
require_relative "shortcuts"


class FakeFSTestCase < Test::Unit::TestCase

  def create_settings_file(content)
    FileUtils.mkdir_p File.expand_path("~")
    path = File.expand_path("~/.arcrc")
    File.open(path, 'w') do |f|
      f << content
    end
  end

  def setup
    FakeFS.activate!
  end

  def teardown
    FakeFS.deactivate!
  end
end

class HelperFunctionsTest < FakeFSTestCase

  def test_hash_generation_correct
    token = 'test_token'
    cert = 'test_cert'
    expected_hash = '1068245b9f827538620547a8d9cc0ce28450227c'
    actual_hash = generate_hash token, cert
    assert_equal actual_hash, expected_hash
  end

  def test_phabricator_request_body_has_required_args
    data = {'some' => 'data'}
    body = get_phabricator_request_body data
    assert_equal body.include?('params'), true
    assert_equal body.include?('output'), true
    assert_equal body.include?('host'), true
  end

  def test_post_request_sends_given_request_body
    url = 'http://www.example.com/'
    request_body_hash = {"test_body_key"=>"test_body_value"}
    stub_request(:post, url).with(:body => request_body_hash)
    make_post_request url, request_body_hash
  end

  def test_post_request_sends_given_headers
    url = 'http://www.example.com/'
    headers = {"test_header"=>"test_header_value"}
    stub_request(:post, url).with(:headers => headers)
    make_post_request url, {}, headers
  end

  def test_post_request_handles_basic_auth_correctly
    auth_url = "http://user:pass@www.example.com/"
    stub_request(:post, auth_url)
    make_post_request auth_url
  end

  def test_used_username_from_arcrc
    username = 'test_user'
    create_settings_file "{\"hosts\":{\"http://test_host.com\":{\"user\":\"#{username}\"}}}"
    assert get_username_from_arc_settings.eql? username
  end
end


class WrapperFunctionsTest < FakeFSTestCase
  def test_make_api_call_makes_auth_call_then_call_to_correct_address
    host = 'http://test.phabricator.com/api/'
    api_method_name = 'conduit.ping'
    create_settings_file "{\"hosts\":{\"#{host}\":{\"cert\":\"12345\"}}}"
    auth_response_data = {'result' => {'sessionKey'=>'1', 'connectionID'=>'2'}}.to_json
    stub_request(:post, "#{host}conduit.connect").to_return(:body => auth_response_data)  # auth request
    stub_request(:post, "#{host}#{api_method_name}").to_return(:body => {'result'=>'OK'}.to_json)  # call to api method
    make_api_call api_method_name
  end
end

class ShortcutsFunctionsTest < FakeFSTestCase
  def test_get_commit_status
    host = 'http://test.phabricator.com/api/'
    create_settings_file "{\"hosts\":{\"#{host}\":{\"cert\":\"12345\"}}}"
    auth_response_data = {'result' => {'sessionKey'=>'1', 'connectionID'=>'2'}}.to_json
    getcommits_data = {'result' => {'rPRJ12345'=> {'commitPHID'=>'PHID12345'}}}.to_json
    query_data = {'result' => [{'status' => 'accepted'}]}.to_json
    stub_request(:post, "#{host}conduit.connect").to_return(:body => auth_response_data)
    stub_request(:post, "#{host}diffusion.getcommits").to_return(:body => getcommits_data)
    stub_request(:post, "#{host}audit.query").to_return(:body => query_data)
    status = get_commit_status 'PRJ', '12345'
    assert status.eql? 'accepted'
  end
end
