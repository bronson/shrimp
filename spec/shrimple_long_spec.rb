require 'spec_helper'

# this file contains the time-consuming tests that, in theory, don't really
# test anything other than PhantomJS.

def pdf_valid?(io)
  # quick & dirty check
  case io
    when File
      io.read[0...4] == "%PDF"
    when String
      io[0...4] == "%PDF" || File.open(io).read[0...4] == "%PDF"
  end
end


def prepare_file outfile
  File.delete(outfile) if File.exists?(outfile)
  outfile
end


# TODO: test a render.js that doesn't compile
# TODO: test PhantomJS failures

describe Shrimple do
  it "echoes its arguments" do
    s = Shrimple.new(renderer: 'spec/parse_and_print_stdin.js')
    output = s.render
    result = JSON.parse(output.stdout)
    expect(result['renderer']).to eq 'spec/parse_and_print_stdin.js'
    expect(result['processed']).to be_true   # added by the phantom script
    expect(output.stderr).to eq ""
  end


  # well I give up.  can't find an item settable by --config that I can read in js.  :(
  # https://github.com/ariya/phantomjs/issues/12265
  #
  # it "sets a command-line arg" do
  #   s = Shrimple.new
  #   s.config.loadImages = false
  #   s.config.autoLoadImages = false
  #   s.renderer = 'render_max_disk_cache.js'
  #   s.render
  # end

  it "renders text to a string" do
    s = Shrimple.new
    result = s.render_text('file://' + example_html)
    output = result.stdout   # TODO: get rid of this line
    expect(output).to eq "Hello World!\n"
  end

  it "renders a gif to memory" do
    pending
  end

  it "renders a pdf to a file" do
    pending
    outfile = prepare_file('/tmp/shrimple-test-output.pdf')
    s = Shrimple.new
    s.render_pdf "file://#{example_html}", to: outfile
    expect(File.exists? outfile).to eq true
    expect(pdf_valid?(File.new(outfile))).to eq true
  end

  it "renders a png to a file" do
    pending
    # TODO: set the size of the png, then verify the size when done
    outfile = prepare_file('/tmp/shrimple-test-output.png')
    s = Shrimple.new
    p = s.render_png "file://#{example_html}", output: outfile
    expect(File.exists? outfile).to eq true
  end
end
