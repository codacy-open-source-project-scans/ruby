# frozen_string_literal: false
require 'test/unit'

class TestClone < Test::Unit::TestCase
  module M001; end
  module M002; end
  module M003; include M002; end
  module M002; include M001; end
  module M003; include M002; end

  def test_clone
    foo = Object.new
    def foo.test
      "test"
    end
    bar = foo.clone
    def bar.test2
      "test2"
    end

    assert_equal("test2", bar.test2)
    assert_equal("test", bar.test)
    assert_equal("test", foo.test)

    assert_raise(NoMethodError) {foo.test2}

    assert_equal([M003, M002, M001], M003.ancestors)
  end

  def test_frozen_properties_retained_on_clone
    obj = Object.new.freeze
    cloned_obj = obj.clone

    assert_predicate(obj, :frozen?)
    assert_predicate(cloned_obj, :frozen?)
  end

  def test_ivar_retained_on_clone
    obj = Object.new
    obj.instance_variable_set(:@a, 1)
    cloned_obj = obj.clone

    assert_equal(obj.instance_variable_get(:@a), 1)
    assert_equal(cloned_obj.instance_variable_get(:@a), 1)
  end

  def test_ivars_retained_on_extended_obj_clone
    ivars = { :@a => 1, :@b => 2, :@c => 3, :@d => 4 }
    obj = Object.new
    ivars.each do |ivar_name, val|
      obj.instance_variable_set(ivar_name, val)
    end

    cloned_obj = obj.clone

    ivars.each do |ivar_name, val|
      assert_equal(obj.instance_variable_get(ivar_name), val)
      assert_equal(cloned_obj.instance_variable_get(ivar_name), val)
    end
  end

  def test_frozen_properties_and_ivars_retained_on_clone_with_ivar
    obj = Object.new
    obj.instance_variable_set(:@a, 1)
    obj.freeze

    cloned_obj = obj.clone

    assert_predicate(obj, :frozen?)
    assert_equal(obj.instance_variable_get(:@a), 1)

    assert_predicate(cloned_obj, :frozen?)
    assert_equal(cloned_obj.instance_variable_get(:@a), 1)
  end

  def test_proc_obj_id_flag_reset
    # [Bug #20250]
    proc = Proc.new { }
    proc.object_id
    proc.clone.object_id # Would crash with RUBY_DEBUG=1
  end

  def test_user_flags
    assert_separately([], <<-EOS)
      #
      class Array
        undef initialize_copy
        def initialize_copy(*); end
      end
      x = [1, 2, 3].clone
      assert_equal [], x, '[Bug #14847]'
    EOS

    assert_separately([], <<-EOS)
      #
      class Array
        undef initialize_copy
        def initialize_copy(*); end
      end
      x = [1,2,3,4,5,6,7][1..-2].clone
      x.push(1,1,1,1,1)
      assert_equal [1, 1, 1, 1, 1], x, '[Bug #14847]'
    EOS

    assert_separately([], <<-EOS)
      #
      class Hash
        undef initialize_copy
        def initialize_copy(*); end
      end
      h = {}
      h.default_proc = proc { raise }
      h = h.clone
      assert_equal nil, h[:not_exist], '[Bug #14847]'
    EOS
  end
end
