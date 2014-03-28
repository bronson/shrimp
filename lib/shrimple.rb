# Keeps track of options and calls the render script

# TODO: just send options as json on stdin
# TODO: return pdf as binary string instead of a file?
# TODO: documentation!
# TODO: restore cookie functionality.

require 'tempfile'

class Shrimple
  class NoExecutableError < StandardError; end
  class RenderingError < StandardError; end

  attr_accessor :executable, :renderer, :options


  RenderScript = File.expand_path('../render.js', __FILE__)
  
  def self.default_executable
    (defined?(Bundler::GemfileError) ? `bundle exec which phantomjs` : `which phantomjs`).chomp
  end

  def initialize options = {}
    defaults = {
      format: 'A4'
    }

    @executable = options.delete(:executable) || self.class.default_executable
    File.exists?(@executable) or raise NoExecutableError.new "No Executable Error: PhantomJS executable not found at #{@executable}.\n"
    @renderer = options.delete(:renderer) || RenderScript
    File.exists?(@renderer) or raise NoExecutableError.new "No Executable Error: render script not found at #{@renderer}.\n"
    @options = defaults.merge(options)
  end

  def render_pdf src, dst, options={}
    render src, dst, options.merge(output_format: 'pdf')
  end

  def render_png src, dst, option={}
    render src, dst, options.merge(output_format: 'png')
  end

  # generates and runs a phantomjs command
  def render src, dst, options={}
    cmdline = command(src, dst, options)
    execute(cmdline, options)
  end

# semi-private

  def execute cmd, options
    logfile = options[:logfile] || Tempfile.new('shrimple.log')
    pid = spawn(*cmd, out: logfile.path, err: :out)
    phantom = Shrimple::Phantom.new(logfile, pid)
    return options[:background] ? phantom.detach : phantom.wait
  end

  # returns the command line that will invoke phantomjs
  def command src, dst, options
    opts = {input: src, output: dst}.merge(@options).merge(options)

    # remove options consumed by the execute method
    opts.delete(:background)
    opts.delete(:logfile)

    arg_list = opts.map {|key, value| ["-#{key}", value.to_s] }.flatten
    [executable, renderer, *arg_list]
  end
end


class Shrimple::Phantom
  attr_accessor :outfile, :pid

  def initialize outfile, pid
    @outfile,@pid = outfile,pid
  end

  def cleanup
    outfile.unlink
  end

  # returns all the output produced by the PhantomJS process.
  def output
    outfile.rewind
    outfile.read
  end

  # detach returns immediately, requiring the caller to collect the result and then
  # call cleanup (or a tempfile will be leaked).  Called when the background option is true.
  def deatach
    Process.detach(pid)
    return self
  end

  # wait blocks until PhantomJS is done, then cleans up.
  # It raises an error if Phantom failed.  Called when the background option is false.
  def wait
    Process.wait(pid)
    outstr = output
    cleanup

    unless $?.success?
      raise RenderingError.new("Rendering Error: #{cmd.join(' ')} returned #{$?.exitstatus}: #{outstr}")
    end

    true # no better return value?
  end
end
