# Adds a pleasant API on top of Shrimple::Process

require 'shrimple/process'

class Shrimple
  class Phantom < Process
    def initialize options
      @config = Tempfile.new(File.basename(options.output || 'shrimple') + '.config')
      @config.write(options.config.to_json)
      @config.close

      @options = StringIO.new(options.to_json)
      @output = StringIO.new
      @log = StringIO.new

      command = options.executable, "--config=#{@config.path}", options.renderer
      super(command, @options, @output, @log)
    end

    # called when process is terminated.  Probably called from another thread so be threadsafe.
    def cleanup
      @config.unlink
      super
    end
  end
end

