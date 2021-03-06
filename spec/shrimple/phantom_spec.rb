
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
    phantom.stop

    expect(File).not_to exist(path)
    expect(phantom.stdout).to eq "done.\n"
  end

  it "times out when running in the foreground" do
    s = Shrimple.new(executable: ['sleep', '10'], timeout: 0)
    expect {
      phantom = s.render('/dev/null')
    }.to raise_exception(Shrimple::TimedOut)
  end

  it "times out when running in the background" do
    s = Shrimple.new(executable: ['sleep', '10'], background: true, timeout: 0)
    phantom = s.render('/dev/null')
    Shrimple.processes.wait_next
    expect(phantom.timed_out?).to eq true
    expect(phantom.killed?).to eq true
    expect(phantom.success?).to eq false
  end

  it "can call multiple callbacks from the same renderer" do
    success = 0
    failure = 0
    s = Shrimple.new(executable: ['cat'])
    s.onSuccess = Proc.new { |result| success += 1 }
    s.onError = Proc.new { |result| failure += 1 }
    s.render('/dev/null')
    s.render('/dev/null')
    s.render('/dev/null')
    s.render('/dev/null')
    expect(success).to eq 4
    expect(failure).to eq 0
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

