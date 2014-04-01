# Adds a pleasant API on top of Shrimple::Process


require 'shrimple/process'

class Shrimple
  class Phantom < Process
    attr_reader :options, :config

    def initialize options
      @options = options

      # write the file required by phantom's --config option
      if options[:config]
        @config = Tempfile.new(File.basename(options[:output] || 'shrimple') + '.config')
        @config.write(options[:config].to_json)
        @config.close
      end

      # create the ios to supply input and read output
      @stdin  = new_io(options[:input] || options)
      @stdout = new_io(options[:output], 'wb')
      @stderr = new_io(options[:stderr], 'wt')

      super(command_line, @stdin, @stdout, @stderr)
    end

    def command_line
      if @options[:executable].kind_of? Array 
        # if executable is an array then we assume it contains all necessary args (so :renderer is ignored)
        command = @options[:executable]
      else
        command = [@options[:executable]]
        command << "--config=#{@config.path}" if @config
        command << @options[:renderer]
      end
    end

    # pass a filepath, an IO object, or some JSON to output, or nil for empty StringIO ready for data.
    def new_io name, *opt
      if name
        if name.kind_of? String
          return File.open(name, *opt)
        elsif name.kind_of?(IO) || name.kind_of?(StringIO)
          name # it's already an IO
        else
          StringIO.new(options.to_json)
        end
      end

      StringIO.new
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
      if @config
        @config.unlink
        @config = nil
      end

      super
    end

    def stdout
      read_io @stdout
    end

    def stderr
      read_io @stderr
    end
  end
end

