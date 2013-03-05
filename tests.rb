#!/usr/bin/ruby

require "test/unit"
require_relative "helpers"

class HelperFunctionsTest < Test::Unit::TestCase
  def test_make_http_request_method_case_insensitive
    res1 = make_http_request('get', 'http://www.google.com/')
    res2 = make_http_request('GET', 'http://www.google.com/')
    assert_equal(res1.body, res2.body)
  end
end
