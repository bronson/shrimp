# Keeps track of options and calls phantoimjs to run the render script.

# TODO: add a header and footer to the page, printheaderfooter.coffee
# TODO: support for injectjs?   http://phantomjs.org/tips-and-tricks.html
#       and maybe page.evaluate(function() { document.body.bgColor = 'white'; });
# TODO: add a hard timeout.  remove any other timeouts because who cares?
# TODO: add onResourceTimeout: https://github.com/onlyurei/phantomjs/commit/fa5a3504070f86a99f11469a3b7eb17a0b005ef7
# TODO: add cookiefile support?
# TODO: wow --config=file sucks.  maybe add a way to specify cmdline args again?
#       either that or fix phantomjs...  https://github.com/ariya/phantomjs/issues/12265 https://github.com/ariya/phantomjs/issues/11775
# TODO: test that page.customHeaders appear in the network requests (how....?)

# maybe:
# TODO: add an exit reason to Process?  :completed, :killed, :timeout?
# TODO: support casperjs?
# TODO: fill in both "can read partial" tests
# TODO: include lots of info about page load in logfile
# TODO: documentation!  probably using sdoc or yard?
# TODO: possible to test margins?  printmargins.coffee


require 'hashie/mash'
require 'shrimple/phantom'
require 'shrimple/default_config'


class Shrimple
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


  # might be time to allow method_missing to handle these helpers...
  def render_pdf src, *opts
    render src, {render: {format: 'pdf'}}, *opts
  end

  def render_png src, *opts
    render src, {render: {format: 'png'}}, *opts
  end

  def render_jpeg src, *opts
    render src, {render: {format: 'jpeg'}}, *opts
  end

  def render_gif src, *opts
    render src, {render: {format: 'gif'}}, *opts
  end

  def render_html src, *opts
    render src, {render: {format: 'html'}}, *opts
  end

  def render_text src, *opts
    render src, {render: {format: 'text'}}, *opts
  end



  def render src={}, *opts
    full_opts = get_full_options(src, *opts)
    phantom = Shrimple::Phantom.new(full_opts)
    phantom.wait unless full_opts[:background]
    phantom
  end

  def get_full_options src, *opts
    full_opts = Shrimple.deep_dup(options)
    full_opts.deep_merge!(src) if src && src.kind_of?(Hash)
    opts.each { |opt| full_opts.deep_merge!(opt) }
    full_opts.merge!(input: src) if src && !src.kind_of?(Hash)
    full_opts.merge!(output: full_opts.delete(:to)) if full_opts[:to]
    self.class.compact!(full_opts)
    full_opts
  end


  # how are these not a part of Hash?
  def self.compact! hash
    hash.delete_if { |k,v| v.nil? or (v.is_a?(Hash) && compact!(v).empty?) or (v.respond_to?('empty?') && v.empty?) }
  end

  def self.deep_dup hash
    Marshal.load(Marshal.dump(hash))
  end


  def self.processes
    @processes ||= Shrimple::ProcessMonitor.new
  end

  def self.default_renderer
    File.expand_path('../render.js', __FILE__)
  end
  
  def self.default_executable
    (defined?(Bundler::GemfileError) ? `bundle exec which phantomjs` : `which phantomjs`).chomp
  end
end
