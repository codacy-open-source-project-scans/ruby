require_relative '../../spec_helper'

describe "ENV.slice" do
  before :each do
    @saved_foo = ENV["foo"]
    @saved_bar = ENV["bar"]
    ENV["foo"] = "0"
    ENV["bar"] = "1"
  end

  after :each do
    ENV["foo"] = @saved_foo
    ENV["bar"] = @saved_bar
  end

  it "returns a hash of the given environment variable names and their values" do
    ENV.slice("foo", "bar").should == {"foo" => "0", "bar" => "1"}
  end

  it "ignores each String that is not an environment variable name" do
    ENV.slice("foo", "boo", "bar").should == {"foo" => "0", "bar" => "1"}
  end

  it "returns the values for the keys coerced with #to_str, but keeps the original objects as result keys" do
    foo = mock('key 1')
    foo.should_receive(:to_str).and_return("foo")
    boo = mock('key 2')
    boo.should_receive(:to_str).and_return("boo")
    bar = mock('key 3')
    bar.should_receive(:to_str).and_return("bar")
    ENV.slice(foo, boo, bar).should == {foo => "0", bar => "1"}
  end

  it "raises TypeError if any argument is not a String and does not respond to #to_str" do
    -> { ENV.slice(Object.new) }.should raise_error(TypeError, "no implicit conversion of Object into String")
  end
end
