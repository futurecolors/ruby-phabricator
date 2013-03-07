#!/usr/bin/ruby

require "test/unit"
require_relative "helpers"

class HelperFunctionsTest < Test::Unit::TestCase
#  def test_make_http_request_method_case_insensitive
#    res1 = make_http_request('get', 'http://www.google.com/')
#    res2 = make_http_request('GET', 'http://www.google.com/')
#    assert_equal(res1.body, res2.body)
#  end
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

end
