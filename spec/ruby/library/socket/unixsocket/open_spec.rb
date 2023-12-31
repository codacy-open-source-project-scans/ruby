require_relative '../spec_helper'
require_relative '../fixtures/classes'
require_relative 'shared/new'

with_feature :unix_socket do
  describe "UNIXSocket.open" do
    it_behaves_like :unixsocket_new, :open
  end

  describe "UNIXSocket.open" do
    before :each do
      @path = SocketSpecs.socket_path
      @server = UNIXServer.open(@path)
    end

    after :each do
      @server.close
      SocketSpecs.rm_socket @path
    end

    it "opens a unix socket on the specified file and yields it to the block" do
      UNIXSocket.open(@path) do |client|
        client.addr[0].should == "AF_UNIX"
        client.should_not.closed?
      end
    end
  end
end
