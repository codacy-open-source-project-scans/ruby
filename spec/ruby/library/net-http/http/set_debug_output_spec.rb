require_relative '../../../spec_helper'
require 'net/http'
require "stringio"
require_relative 'fixtures/http_server'

describe "Net::HTTP#set_debug_output when passed io" do
  before :each do
    NetHTTPSpecs.start_server
    @http = Net::HTTP.new("localhost", NetHTTPSpecs.port)
  end

  after :each do
    @http.finish if @http.started?
    NetHTTPSpecs.stop_server
  end

  it "sets the passed io as output stream for debugging" do
    io = StringIO.new

    @http.set_debug_output(io)
    @http.start
    io.string.should_not be_empty
    size = io.string.size

    @http.get("/")
    io.string.size.should > size
  end

  it "outputs a warning when the connection has already been started" do
    @http.start
    -> { @http.set_debug_output(StringIO.new) }.should complain(/Net::HTTP#set_debug_output called after HTTP started/)
  end
end
