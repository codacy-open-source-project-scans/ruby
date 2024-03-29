begin
  require 'win32ole'
rescue LoadError
end

if defined?(WIN32OLE)
  module AvailableOLE
    module_function

    def sysmon_available?
      WIN32OLE::Type.new('System Monitor Control', 'SystemMonitor')
      true
    rescue
      false
    end

    def ado_available?
      WIN32OLE.new('ADODB.Connection')
      true
    rescue
      false
    end

    def msxml_available?
      !WIN32OLE::TypeLib.typelibs.find { |t| t.name.start_with?('Microsoft XML') }.nil?
    end

    def event_param
      method = if msxml_available?
                 typelib = WIN32OLE::TypeLib.typelibs.find { |t| t.name.start_with?('Microsoft XML') }
                 ole_type = WIN32OLE::Type.new(typelib.name, 'IVBSAXContentHandler')
                 WIN32OLE::Method.new(ole_type, 'startElement')
               elsif ado_available?
                 typelib = WIN32OLE.new('ADODB.Connection').ole_typelib
                 ole_type = WIN32OLE::Type.new(typelib.name, 'Connection')
                 WIN32OLE::Method.new(ole_type, 'WillConnect')
               end
      method && method.params[0]
    end
  end
end
