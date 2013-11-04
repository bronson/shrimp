#encoding: UTF-8

require File.dirname(File.expand_path(__FILE__)) + '/../lib/shrimple'

def valid_pdf(io)
  case io
    when File
      io.read[0...4] == "%PDF"
    when String
      io[0...4] == "%PDF" || File.open(io).read[0...4] == "%PDF"
  end
end

def testfile
  File.expand_path('../test_file.html', __FILE__)
end

# to test: PhantomJS failures

describe Shrimple do
  it "automatically finds the executable and renderer" do
    s =  Shrimple.new
    expect(File.executable? s.executable).to be true
    expect(File.exists? s.renderer).to be true
  end

  it "can be told the executable and renderer" do
    # these don't need to be real executables since they're never called
    s = Shrimple.new(executable: '/bin/sh', renderer: testfile)
    expect(s.executable).to eq '/bin/sh'
    expect(s.renderer).to eq testfile
  end

  it "calls the right basic command line" do
    s = Shrimple.new
    s.should_receive(:shell).with(s.executable, s.renderer, '-input', 'infile', '-output', 'outfile')
    s.run 'infile', 'outfile'
  end

  it "passes options" do
    s = Shrimple.new(executable: '/bin/sh', renderer: testfile, orientation: 'landscape')
    s.options['render_time'] = 55000
    s.should_receive(:shell).with('/bin/sh', testfile, '-input', 'infile', '-output', 'outfile',
      '-orientation', 'landscape', '-render_time', '55000', '-zoom', '0.25' )
    s.run 'infile', 'outfile', zoom: 0.25
  end

  it "renders a pdf" do
    outfile = '/tmp/shrimple-test-output.pdf'
    File.delete(outfile) if File.exists?(outfile)
    s = Shrimple.new
    s.run testfile, outfile
    expect(File.exists? outfile).to eq true
    expect(valid_pdf(File.new(outfile))).to eq true
  end

  it "renders a png" do
  end
end
