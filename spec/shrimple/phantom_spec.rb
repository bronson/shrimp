
require 'spec_helper'

describe Shrimple::Phantom do
  it "doesn't create a config file if no options are set" do
    s = Shrimple.new(executable: ['sleep', '1'], background: true)

    phantom = s.render('/dev/null')
    expect(phantom.config).to eq nil
    phantom.kill

    expect(phantom.config).to eq nil
    expect(phantom.stdout).to eq ""
    expect(phantom.stderr).to eq ""
  end

  it "creates a config file when there are config options and cleans on kill" do
    s = Shrimple.new(executable: ['sleep', '1'], background: true)
    s.config.ignoreSslErrors = true

    phantom = s.render('infile')
    expect(phantom.config).to be_a Tempfile
    path = phantom.config.path
    expect(File).to exist(path)
    config = File.read(path)
    phantom.kill

    expect(phantom.config).to eq nil
    expect(File).not_to exist(path)
    expect(JSON.parse(config)).to eq ({'ignoreSslErrors' => true})
    expect(phantom.stdout).to eq ""
    expect(phantom.stdout).to eq ""
    expect(phantom.stderr).to eq ""
  end

  it "cleans up the config file when exiting normally" do
    s = Shrimple.new(executable: ['/bin/cat'], background: true)
    s.config.ignoreSslErrors = true

    rd,wr = IO.pipe
    phantom = s.render(stdin: rd)

    expect(phantom.config).to be_a Tempfile
    path = phantom.config.path
    expect(File).to exist(path)
    wr.write("done.\n")
    wr.close
    phantom.wait

    expect(phantom.config).to eq nil
    expect(File).not_to exist(path)
    expect(phantom.stdout).to eq "done.\n"
  end

  it "can read partial string contents while writing" do
    # ensure writes still go on the end of the buffer after reading
    # pending
  end

  it "can read partial file contents while writing" do
    # ensure writes still go on the end of the buffer after reading
    # pending
  end
end

