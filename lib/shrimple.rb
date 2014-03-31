# Keeps track of options and calls phantoimjs to run the render script.

# TODO: clean up helpers
# TODO: return pdf/png/etc as binary string instead of a file?
# TODO: support for renderBase64?
# TODO: support for injectjs?   http://phantomjs.org/tips-and-tricks.html
# TODO: return page text?
# TODO: add a hard timeout
# TODO: add an exit reason to Process?  :completed, :killed, :timeout?
# TODO: use indifferent access for options hash
# TODO: support casperjs?
# TODO: include lots of info about page load in logfile
# TODO: documentation!

require 'hashie/mash'
require 'shrimple/phantom'
require 'shrimple/default_config'


class Shrimple
  class NoExecutableError < StandardError; end
  class RenderingError < StandardError; end


  attr_accessor :options

  # allows setting config options directly on this object
  def method_missing name, *args, &block
    options.send(name, *args, &block)
  end


  def initialize opts={}
    @options = Hashie::Mash.new(Shrimple::DefaultConfig)
    @options.deep_merge!(opts)
    self.executable ||= self.class.default_executable
    self.renderer ||= self.class.default_renderer
  end


  def render_pdf src, dst=:undefined, opts={}
    defaults = {
      output_format: 'pdf',
      paperSize: Shrimple::DefaultPageSize
    }

    render src, dst, Hashie::Mash.new(defaults).deep_merge!(opts)
  end

  def render_png src, dst=:undefined, opts={}
    defaults = {
      output_format: 'png',
      paperSize: Shrimple::DefaultImageSize
    }

    render src, dst, Hashie::Mash.new(defaults).deep_merge!(opts)
  end

  def render_jpeg src, dst=:undefined, opts={}
    defaults = {
      output_format: 'jpeg',
      paperSize: Shrimple::DefaultImageSize
    }

    render src, dst, Hashie::Mash.new(defaults).deep_merge!(opts)
  end

  def render_gif src, dst=:undefined, opts={}
    defaults = {
      output_format: 'gif',
      paperSize: Shrimple::DefaultImageSize
    }

    render src, dst, Hashie::Mash.new(defaults).deep_merge!(opts)
  end

  def render src, dst=:undefined, opts={}
    full_opts = options.deep_merge(opts).merge!(input: src)
    full_opts.merge!(output: dst) unless dst == :undefined
    self.class.execute(self.class.compact(full_opts))
  end


  # how is this not a part of the standard library?
  def self.compact hash
    hash.delete_if { |k,v| v.nil? or (v.is_a?(Hash) && compact(v).empty?) or (v.respond_to?('empty?') && v.empty?) }
  end

  def self.default_renderer
    File.expand_path('../render.js', __FILE__)
  end
  
  def self.default_executable
    (defined?(Bundler::GemfileError) ? `bundle exec which phantomjs` : `which phantomjs`).chomp
  end

  # opts contains the full list of options so it's already merged with self.options.
  # it might be overwritten so, if you care, dup it before calling this function.
  def self.execute opts
    phantom = Shrimple::Phantom.new(opts)
    phantom.wait if opts[:background]
    phantom
  end
end
