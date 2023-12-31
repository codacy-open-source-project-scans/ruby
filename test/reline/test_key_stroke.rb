require_relative 'helper'

class Reline::KeyStroke::Test < Reline::TestCase
  using Module.new {
    refine Array do
      def as_s
        join
      end

      def to_keys
        map{ |b| Reline::Key.new(b, b, false) }
      end
    end
  }

  def test_match_status
    config = Reline::Config.new
    {
      'a' => 'xx',
      'ab' => 'y',
      'abc' => 'z',
      'x' => 'rr'
    }.each_pair do |key, func|
      config.add_default_key_binding(key.bytes, func.bytes)
    end
    stroke = Reline::KeyStroke.new(config)
    assert_equal(:matching, stroke.match_status("a".bytes))
    assert_equal(:matching, stroke.match_status("ab".bytes))
    assert_equal(:matched, stroke.match_status("abc".bytes))
    assert_equal(:matched, stroke.match_status("abz".bytes))
    assert_equal(:matched, stroke.match_status("abx".bytes))
    assert_equal(:matched, stroke.match_status("ac".bytes))
    assert_equal(:matched, stroke.match_status("aa".bytes))
    assert_equal(:matched, stroke.match_status("x".bytes))
    assert_equal(:unmatched, stroke.match_status("m".bytes))
    assert_equal(:matched, stroke.match_status("abzwabk".bytes))
  end

  def test_match_unknown
    config = Reline::Config.new
    config.add_default_key_binding("\e[9abc".bytes, 'x')
    stroke = Reline::KeyStroke.new(config)
    sequences = [
      "\e[9abc",
      "\e[9d",
      "\e[A", # Up
      "\e[1;1R", # Cursor position report
      "\e[15~", # F5
      "\eOP", # F1
      "\e\e[A" # Option+Up
    ]
    sequences.each do |seq|
      assert_equal(:matched, stroke.match_status(seq.bytes))
      (1...seq.size).each do |i|
        assert_equal(:matching, stroke.match_status(seq.bytes.take(i)))
      end
    end
  end

  def test_expand
    config = Reline::Config.new
    {
      'abc' => '123',
    }.each_pair do |key, func|
      config.add_default_key_binding(key.bytes, func.bytes)
    end
    stroke = Reline::KeyStroke.new(config)
    assert_equal('123'.bytes, stroke.expand('abc'.bytes))
    # CSI sequence
    assert_equal([:ed_unassigned] + 'bc'.bytes, stroke.expand("\e[1;2;3;4;5abc".bytes))
    assert_equal([:ed_unassigned] + 'BC'.bytes, stroke.expand("\e\e[ABC".bytes))
    # SS3 sequence
    assert_equal([:ed_unassigned] + 'QR'.bytes, stroke.expand("\eOPQR".bytes))
  end

  def test_oneshot_key_bindings
    config = Reline::Config.new
    {
      'abc' => '123',
    }.each_pair do |key, func|
      config.add_default_key_binding(key.bytes, func.bytes)
    end
    stroke = Reline::KeyStroke.new(config)
    assert_equal(:unmatched, stroke.match_status('zzz'.bytes))
    assert_equal(:matched, stroke.match_status('abc'.bytes))
  end

  def test_with_reline_key
    config = Reline::Config.new
    {
      [
        Reline::Key.new(100, 228, true), # Alt+d
        Reline::Key.new(97, 97, false) # a
      ] => 'abc',
      [195, 164] => 'def'
    }.each_pair do |key, func|
      config.add_oneshot_key_binding(key, func.bytes)
    end
    stroke = Reline::KeyStroke.new(config)
    assert_equal(:unmatched, stroke.match_status('da'.bytes))
    assert_equal(:matched, stroke.match_status("\M-da".bytes))
    assert_equal(:unmatched, stroke.match_status([32, 195, 164]))
    assert_equal(:matched, stroke.match_status([195, 164]))
  end
end
