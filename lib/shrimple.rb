# Keeps track of options and calls phantoimjs to run the render script.

# TODO: clean up helpers
# TODO: return pdf/png/etc as binary string instead of a file?
# TODO: support for renderBase64?
# TODO: support for injectjs?   http://phantomjs.org/tips-and-tricks.html
# TODO: include lots of info about page load in logfile
# TODO: documentation!

require 'hashie/mash'
require 'shrimple/process'
require 'shrimple/default_config'


class Shrimple
  class NoExecutableError < StandardError; end
  class RenderingError < StandardError; end


  attr_accessor :options

  def method_missing name, *args, &block
    options.send(name, *args, &block)
  end


  def self.default_renderer
    File.expand_path('../render.js', __FILE__)
  end
  
  def self.default_executable
    (defined?(Bundler::GemfileError) ? `bundle exec which phantomjs` : `which phantomjs`).chomp
  end



  def initialize opts={}
    @options = Hashie::Mash.new(Shrimple::DefaultConfig)
    @options.deep_merge!(opts)
    self.executable ||= self.class.default_executable
    self.renderer ||= self.class.default_renderer
  end


  def render_pdf src, dst, opts={}
    defaults = {
      output_format: 'pdf',
      paperSize: Shrimple::DefaultPageSize
    }

    render src, dst, Hashie::Mash.new(defaults).deep_merge!(opts)
  end

  def render_png src, dst, opts={}
    defaults = {
      output_format: 'png',
      paperSize: Shrimple::DefaultImageSize
    }

    render src, dst, Hashie::Mash.new(defaults).deep_merge!(opts)
  end

  def render_jpeg src, dst, opts={}
    defaults = {
      output_format: 'jpeg',
      paperSize: Shrimple::DefaultImageSize
    }

    render src, dst, Hashie::Mash.new(defaults).deep_merge!(opts)
  end

  def render_gif src, dst, opts={}
    defaults = {
      output_format: 'gif',
      paperSize: Shrimple::DefaultImageSize
    }

    render src, dst, Hashie::Mash.new(defaults).deep_merge!(opts)
  end

  def render src, dst, opts={}
    self.class.execute options.deep_merge(opts).deep_merge!(input: src, output: dst)
  end


  # opts contains the full list of options so it's already merged with self.options.
  # it might be overwritten so, if you care, dup it before calling this function.
  def self.execute opts
    File.exists?(opts.executable) or raise NoExecutableError.new "PhantomJS executable not found at #{executable}.\n"
    File.exists?(opts.renderer) or raise NoExecutableError.new "PhantomJS render script not found at #{renderer}.\n"

    opts.logfile ||= Tempfile.new("#{opts.output}.log").path

    puts "LOGFILE: #{opts.logfile}"

    config = Tempfile.new(opts.output + '.config')
    config.write(opts.config.to_json)
    config.close

    pid = IO.popen([opts.executable, "--config=#{config.path}", opts.renderer], out: opts.logfile, err: :out) do |child|
      child.write(opts.to_json)
    end
    phantom = Shrimple::Process.new(logfile, configfile, pid)
    return options[:background] ? phantom.detach : phantom.wait
  end
end
