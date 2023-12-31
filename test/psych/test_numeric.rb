# frozen_string_literal: true
require_relative 'helper'
begin
  require 'bigdecimal'
rescue LoadError
end

module Psych
  ###
  # Test numerics from YAML spec:
  # http://yaml.org/type/float.html
  # http://yaml.org/type/int.html
  class TestNumeric < TestCase
    def setup
      @old_debug = $DEBUG
      $DEBUG = true
    end

    def teardown
      $DEBUG = @old_debug
    end

    def test_load_float_with_dot
      assert_equal 1.0, Psych.load('--- 1.')
    end

    def test_non_float_with_0
      str = Psych.load('--- 090')
      assert_equal '090', str
    end

    def test_big_decimal_tag
      decimal = BigDecimal("12.34")
      assert_match "!ruby/object:BigDecimal", Psych.dump(decimal)
    end if defined?(BigDecimal)

    def test_big_decimal_round_trip
      decimal = BigDecimal("12.34")
      $DEBUG = false
      assert_cycle decimal
    end if defined?(BigDecimal)

    def test_does_not_attempt_numeric
      str = Psych.load('--- 4 roses')
      assert_equal '4 roses', str
      str = Psych.load('--- 1.1.1')
      assert_equal '1.1.1', str
    end

    # This behavior is not to YML spec, but is kept for backwards compatibility
    def test_string_with_commas
      number = Psych.load('--- 12,34,56')
      assert_equal 123456, number
    end

    def test_string_with_commas_with_strict_integer
      str = Psych.load('--- 12,34,56', strict_integer: true)
      assert_equal '12,34,56', str
    end
  end
end
