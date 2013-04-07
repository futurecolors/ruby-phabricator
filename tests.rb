# Turn on coveralls. Must be on top.
require 'coveralls'
Coveralls.wear!

require "test/unit"
require 'webmock/test_unit'
require 'fakefs/safe'
require_relative "helpers"
require_relative "wrapper"
require_relative "shortcuts"


class FakeFSTestCase < Test::Unit::TestCase

  def create_settings_file(content)
    FileUtils.mkdir_p File.expand_path("~")
    @settings_path = File.expand_path("~/.arcrc")
    File.open(@settings_path, 'w') do |f|
      f << content
    end
  end

  def remove_settings_file_if_exists
    path = File.expand_path("~/.arcrc")
    if File.file? path
      File.delete path
    end
  end

  def setup
    FakeFS.activate!
    remove_settings_file_if_exists
  end

  def teardown
    FakeFS.deactivate!
  end
end


class FakeFSTestCaseWithHelpers < FakeFSTestCase

  def assert_raise_message(types, matcher, message = nil, &block)
    args = [types].flatten + [message]
    exception = assert_raise(*args, &block)
    assert_match matcher, exception.message, message
  end
end

class HelperFunctionsTest < FakeFSTestCaseWithHelpers

  def test_hash_generation_correct
    token = 'test_token'
    cert = 'test_cert'
    expected_hash = '1068245b9f827538620547a8d9cc0ce28450227c'
    actual_hash = generate_hash token, cert
    assert_equal actual_hash, expected_hash
  end

  def test_make_http_request_raises_error_on_wrong_method
    assert_raise_message RuntimeError, 'Bad method' do
      make_http_request 'put', 'http://example.com/'
    end
  end

  def test_make_http_request_makes_get_requests
    url = 'http://www.example.com/'
    stub_request(:get, url)
    make_http_request 'get', url
  end

  def test_make_http_request_makes_get_requests
    url = 'http://www.example.com/'
    stub_request(:get, url)
    make_get_request url
  end

  def test_check_arc_settings_raiss_error_when_no_hosts_in_arcrc_file
    create_settings_file "{}"
    assert_raise RuntimeError do
      check_arc_settings
    end
  end

  def test_check_arc_settings_raiss_error_when_more_than_one_host_in_arcrc_file
    create_settings_file "{\"hosts\":{\"host1\":{},\"host2\":{}}}"
    assert_raise RuntimeError do
      check_arc_settings
    end
  end

  def test_get_arc_settings_raises_error_when_wrong_file_passed
    fake_settings_filename = '/home/user/fakerc'
    assert_raise_message RuntimeError, "No #{fake_settings_filename} file found" do
      get_arc_settings fake_settings_filename
    end
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

  def test_get_result_commit_status_returns_correct_data
    test_data = {
      nil => 'in_progress',
      ['in_progress', ] => 'in_progress',
      ['accepted', 'is_progress', ] => 'accepted',
      ['conserned', 'in_progress', ] => 'conserned',
      ['accepted', 'conserned', ] => 'conserned',
    }
    test_data.each{|input, expected_output|
      actual_output = get_result_commit_status input
      assert_equal actual_output, expected_output
    }
  end
end


class WrapperFunctionsTest < FakeFSTestCaseWithHelpers
  def test_make_api_call_makes_auth_call_then_call_to_correct_address
    host = 'http://test.phabricator.com/api/'
    api_method_name = 'conduit.ping'
    create_settings_file "{\"hosts\":{\"#{host}\":{\"cert\":\"12345\"}}}"
    auth_response_data = {'result' => {'sessionKey'=>'1', 'connectionID'=>'2'}, 'error_code'=>''}.to_json
    stub_request(:post, "#{host}conduit.connect").to_return(:body => auth_response_data)  # auth request
    stub_request(:post, "#{host}#{api_method_name}").to_return(:body => {'result'=>'OK', 'error_code'=>''}.to_json)  # call to api method
    make_api_call api_method_name, @settings_path
  end
  def test_make_api_call_raises_exception_when_phabricator_returns_error
    host = 'http://test.phabricator.com/api/'
    api_method_name = 'conduit.ping'
    create_settings_file "{\"hosts\":{\"#{host}\":{\"cert\":\"12345\"}}}"
    auth_response_data = {'result' => {'sessionKey'=>'1', 'connectionID'=>'2'}, 'error_code'=>''}.to_json
    stub_request(:post, "#{host}conduit.connect").to_return(:body => auth_response_data)  # auth request
    stub_request(:post, "#{host}#{api_method_name}").to_return(:body => {'result'=>'', 'error_code'=>'WTF', 'error_info'=>'Something went wrong'}.to_json)  # call to api method with error
    assert_raise_message RuntimeError, "Conduit method #{api_method_name} returned following error: WTF - Something went wrong." do
      make_api_call api_method_name, @settings_path
    end
  end
end

class ShortcutsFunctionsTest < FakeFSTestCaseWithHelpers
  def setup
    @host = 'http://test.phabricator.com/api/'
  end

  def test_get_commit_status
    create_settings_file "{\"hosts\":{\"#{@host}\":{\"cert\":\"12345\"}}}"
    auth_response_data = {'result' => {'sessionKey'=>'1', 'connectionID'=>'2'}, 'error_code'=>''}.to_json
    getcommits_data = {'result' => {'rPRJ12345'=> {'commitPHID'=>'PHID12345'}}, 'error_code'=>''}.to_json
    query_data = {'result' => [{'commitPHID' => 'PHID12345', 'status' => 'accepted'}], 'error_code'=>''}.to_json
    stub_request(:post, "#{@host}conduit.connect").to_return(:body => auth_response_data)
    stub_request(:post, "#{@host}diffusion.getcommits").to_return(:body => getcommits_data)
    stub_request(:post, "#{@host}audit.query").to_return(:body => query_data)
    statuses = get_commit_status 'PRJ', '12345', @settings_path
    assert statuses['rPRJ12345']['status'].eql? 'accepted'
  end
  def test_get_commit_status_raises_no_exceptions
    create_settings_file "{\"hosts\":{\"#{@host}\":{\"cert\":\"12345\"}}}"
    auth_response_data = {'result' => {'sessionKey'=>'1', 'connectionID'=>'2'}, 'error_code'=>''}.to_json
    getcommits_data = {'result' => {'rPRJ12345'=> {'commitPHID'=>'PHID12345'}}, 'error_code'=>''}.to_json
    query_data = {'result' => '', 'error_code'=>'WTF', 'error_info'=>'Something went wrong'}.to_json
    stub_request(:post, "#{@host}conduit.connect").to_return(:body => auth_response_data)
    stub_request(:post, "#{@host}diffusion.getcommits").to_return(:body => getcommits_data)
    stub_request(:post, "#{@host}audit.query").to_return(:body => query_data)
    statuses = get_commit_status 'PRJ', '12345', @settings_path
    assert statuses.eql?({})
  end

  def test_get_commit_status_by_phids_works_if_api_returned_multiple_info_about_commit
    commit_phid = 'PHID12345'
    query_data = {'result' => [
                                {'commitPHID' => commit_phid, 'status' => 'accepted'},
                                {'commitPHID' => commit_phid, 'status' => 'concerned'},
                              ], 'error_code'=>''}.to_json
    stub_request(:post, "#{@host}audit.query").to_return(:body => query_data)
    res = get_commit_status_by_phids commit_phid, @settings_path
    assert_equal res, {commit_phid => ['accepted', 'concerned', ]}
  end
end
