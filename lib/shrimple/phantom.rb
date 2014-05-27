# Adds a pleasant API on top of Shrimple::Process

require 'shrimple/process'
require 'stringio'

class Shrimple
  class PhantomError < StandardError; end
  class TimedOut < StandardError; end

  class Phantom < Process
    attr_reader :options, :config

    def initialize options
      @options = options
      @onSuccess = options.delete(:onSuccess)
      @onError = options.delete(:onError)

      # write the file required by phantom's --config option
      if options[:config]
        @config = Tempfile.new(File.basename(options[:output] || 'shrimple') + '.config')
        @config.write(options[:config].to_json)
        @config.close
      end

      # create the ios to supply input and read output
      @stdin  = new_io(options[:stdin] || StringIO.new(options.to_json))
      @stdout = new_io(options[:output], 'wb')
      @stderr = new_io(options[:stderr], 'wt')

      if options[:debug]
        # hm, should this be replaced with methods?  or maybe a superclass?
        $stderr.puts "COMMAND: #{command_line}"
        $stderr.puts "STDIN: #{options.to_json}"
      end

      super(command_line, @stdin, @stdout, @stderr, options[:timeout])
    end

    # blocks until the PhantomJS process is finished. raises an exception if it failed.
    def wait
      _cleanup
      unless @child.value.success?
        raise Shrimple::TimedOut.new if timed_out?
        raise Shrimple::PhantomError.new("PhantomJS returned #{@child.value.exitstatus}: #{stderr}")
      end
    end

    def stdout
      read_io @stdout
    end

    def stderr
      read_io @stderr
    end


    # called when process is terminated.  Probably called from another thread so be threadsafe.
    # will probably be called multiple times
    def _cleanup
      super
      if @config
        @config.unlink
        @config = nil
      end

      proc = (success? ? @onSuccess : @onError)
      @onSuccess = @onError = nil     # ensure we don't call callback multiple times
      proc.call(self) if proc
    end


  private
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

    # pass a filepath, an IO object or equivlanet, or nil to create an empty StringIO ready for data.
    def new_io name, *opt
      if name
        if name.kind_of? String
          return File.open(name, *opt)
        else
          name
        end
      else
        StringIO.new
      end
    end

    def read_io io
      if io.kind_of?(StringIO)
        # can't rewind because then writes go to wrong place
        io.string
      else
        io.rewind
        io.read
      end
    end
  end
end

