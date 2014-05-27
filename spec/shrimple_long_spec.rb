require 'spec_helper'
require 'dimensions'

# this file contains the time-consuming tests that shell out to phantomjs


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
  # TODO: there MUST be a better way of handling file output in rspec
  # (can't mock file ops because the output is coming from phantomjs)
  File.delete(outfile) if File.exists?(outfile)
  return '/tmp/' + outfile
end


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
    result = s.render_text("file://#{example_html}")
    output = result.stdout   # TODO: get rid of this line
    expect(output).to eq "Hello World!\n"
  end

  it "renders text to a file" do
    outfile = prepare_file('shrimple-test-output.txt')
    s = Shrimple.new
    s.render_text("file://#{example_html}", to: outfile)
    output = File.read(outfile)
    expect(output).to eq "Hello World!\n"
    File.delete(outfile)
  end

  it "renders html to a string" do
    s = Shrimple.new
    result = s.render_html("file://#{example_html}")
    output = result.stdout   # TODO: get rid of this line
    expect(output).to include "<h1>Hello World!</h1>"
  end

  it "handles a missing file" do
    # also ensures failures's stderr appears in the exception
    s = Shrimple.new
    expect {
      s.render_text("file://this-does-not-exist")
    }.to raise_exception(/Unable to load.*this-does-not-exist/)
  end

  it "handles phantomjs complaining about a missing render script" do
    s = Shrimple.new(renderer: 'this-does-not-exist')
    expect {
      s.render_text("file://#{example_html}")
    }.to raise_exception(/Can't open 'this-does-not-exist'/)
  end

  # # it's hopeless: https://github.com/ariya/phantomjs/issues/10687
  #
  # it "handles a syntax error in a render script" do
  #   s = Shrimple.new(renderer: 'spec/syntax_error.js')
  #   expect {
  #     s.render_text("file://#{example_html}")
  #   }.to raise_exception(/Can't open 'this-does-not-exist'/)
  # end

  it "supports a debugging mode" do
    # isn't there a better way of resetting global variables in rspec?
    olderr = $stderr
    begin
      $stderr = StringIO.new
      s = Shrimple.new(debug: true)
      s.render_text("file://#{example_html}")

      expect($stderr.string).to match /^COMMAND: \[.*phantomjs.*render.js"\]/
      expect($stderr.string).to match /^STDIN: {.*"debug":true.*}/
    ensure
      $stderr = olderr
    end
  end

  it "renders a pdf to a file" do
    outfile = prepare_file('shrimple-test-output.pdf')
    s = Shrimple.new(to: outfile)
    s.render_pdf "file://#{example_html}"
    expect(File.exists? outfile).to eq true
    expect(pdf_valid?(File.new(outfile))).to eq true
  end

  it "renders a png to a file" do
    outfile = prepare_file('shrimple-test-output.png')
    s = Shrimple.new
    p = s.render_png "file://#{example_html}", output: outfile

    expect(File.exists? outfile).to eq true
    dimensions = Dimensions.dimensions(outfile)
    expect(dimensions[0]).to eq 400   # phantomjs default width
    expect(dimensions[1]).to eq 300   # phantomjs default height

    # when dimensions allows reading the filetype, add that check here
    # https://github.com/cleanio/dimensions/commit/c61ad05c354feb1063bfbdc97c1ec5456c9ad43a
  end

  it "renders a png to a stream" do
    s = Shrimple.new(page: {viewportSize: { width: 555, height: 555 }} )
    s.page.zoomFactor = 0.75
    output = s.render_png "file://#{example_html}"

    # todo: would be great if we could attach Dimensions straight to the io object reading the results
    # instead of needing to flush the result to a memory buffer and wrapping that in a new stringio
    dimensions = Dimensions(StringIO.new(output.stdout))    
    expect(dimensions.width).to eq 555
    expect(dimensions.height).to eq 555
  end

  it "renders a jpeg to a file" do
    outfile = prepare_file('shrimple-test-output.jpg')
    s = Shrimple.new
    s.page.viewportSize = { width: 320, height: 240 }
    s.output = outfile
    output = s.render_jpeg "file://#{example_html}"

    expect(File.exists? outfile).to eq true
    dimensions = Dimensions.dimensions(outfile)
    expect(dimensions[0]).to eq 320
    expect(dimensions[1]).to eq 240
  end

  it "renders a gif to memory" do
    s = Shrimple.new
    s.page.viewportSize = { width: 213, height: 214 }
    output = s.render_gif "file://#{example_html}"

    dimensions = Dimensions(StringIO.new(output.stdout))    
    expect(dimensions.width).to eq 213
    expect(dimensions.height).to eq 214
  end
end
