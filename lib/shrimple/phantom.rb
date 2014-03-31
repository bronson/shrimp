# Adds a pleasant API on top of Shrimple::Process


require 'shrimple/process'

class Shrimple
  class Phantom < Process
    def initialize options
      @options = options

      # write the file required by phantom's --config option
      unless options.config
        @config = Tempfile.new(File.basename(options.output || 'shrimple') + '.config')
        @config.write(options.config.to_json)
        @config.close
      end

      @stdin  = StringIO.new(options.to_json)
      @stdout = new_io(options.output, 'wb')
      @stderr = new_io(options.stderr, 'wt')

      command = [options.executable]
      command << "--config=#{@config.path}" if @config
      command << options.renderer

      super(command, @stdin, @stdout, @stderr)
    end

    def new_io name, *opt
      if name
        File.open(name, *opt)
      else
        StringIO.new
      end
    end

    def read_io io
      if io.kind_of?(StringIO)
        # can't rewind because then writes would go to wrong place
        io.string
      else
        io.rewind
        io.read
      end
    end

    # called when process is terminated.  Probably called from another thread so be threadsafe.
    def cleanup
      @config.unlink
      super
    end

    def stderr
      puts "READING #{@stderr}"
      read_io @stderr
    end
  end
end

