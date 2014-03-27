require File.dirname(File.expand_path(__FILE__)) + '/../lib/shrimple'

# this file contains the time-consuming tests

def pdf_valid?(io)
  # quick & dirty check
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

def prepare_file outfile
  File.delete(outfile) if File.exists?(outfile)
  outfile
end


# to test: a render.js that doesn't compile
# to test: PhantomJS failures

describe Shrimple do
  it "renders a pdf" do
    outfile = prepare_file('/tmp/shrimple-test-output.pdf')
    s = Shrimple.new
    s.render_pdf "file://#{testfile}", outfile
    expect(File.exists? outfile).to eq true
    expect(pdf_valid?(File.new(outfile))).to eq true
  end

  it "renders a png" do
    outfile = prepare_file('/tmp/shrimple-test-output.png')
    s = Shrimple.new
    s.render_png "file://#{testfile}", outfile
    expect(File.exists? outfile).to eq true
  end
end
