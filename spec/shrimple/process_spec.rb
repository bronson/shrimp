require 'spec_helper'

# run this to ensure there are no deadlock / process synchronization problems:
#    while rspec spec/shrimple_process_spec.rb ; do echo -n ; done

describe Shrimple::Process do
  let(:chin)  { StringIO.new('small instring') }
  let(:chout) { StringIO.new }
  let(:cherr) { StringIO.new }

  it "has a working drain method" do
    bigin = StringIO.new('x' * 1024 * 1024) # at least 1 MB of data to test drain loop
    process = Shrimple::Process.new('cat', bigin, chout, cherr)
    process.wait
    expect(chout.string).to eq bigin.string
    expect(process.finished?).to be_true
  end

  it "waits until a sleeping command is finished" do
    # pile a bunch of checks into this test so we only have to sleep once
    expect(Shrimple.processes.count).to eq 0
    claimed = nil

    elapsed = time do
      # echo -n doesn't work here because of platform variations
      # and for some reason jruby requires the explicit subshell; mri launches it automatically
      process = Shrimple::Process.new('/bin/sh -c "sleep 0.1 && printf done."', chin, chout, cherr)
      expect(Shrimple.processes.count).to eq 1
      process.wait
      expect(process.start_time).not_to eq nil
      expect(process.stop_time).not_to eq nil
      claimed = process.stop_time - process.start_time
      expect(chout.string).to eq 'done.'
      expect(process.finished?).to be_true
    end

    # ensure process elapsed time is in the ballpark
    expect(elapsed).to be >= 0.1
    expect(claimed).to be >= 0.1
    expect(claimed).to be <= elapsed

    expect(Shrimple.processes.count).to eq 0
    expect(chout.closed_read?).to be_true
    expect(cherr.closed_read?).to be_true
  end

  it "has a working kill method" do
    elapsed = time do
      process = Shrimple::Process.new(['sleep', '0.1'], chin, chout, cherr)
      process.kill
      expect(process.finished?).to be_true
    end

    expect(elapsed).to be < 0.1
    expect(chout.closed_read?).to be_true
    expect(cherr.closed_read?).to be_true
  end

  it "handles invalid commands" do
    expect {
      expect(Shrimple.processes.count).to eq 0
      process = Shrimple::Process.new(['ThisCmdDoes.Not.Exist.'], chin, chout, cherr)
      raise "we shouldn't get here"
    }.to raise_error(/[Nn]o such file/)
    expect(Shrimple.processes.count).to eq 0
  end

  it "counts multiple processes" do
    expect(Shrimple.processes.count).to eq 0
    process = Shrimple::Process.new(['sleep', '20'], StringIO.new, StringIO.new, StringIO.new)
    process = Shrimple::Process.new(['sleep', '20'], StringIO.new, StringIO.new, StringIO.new)
    process = Shrimple::Process.new(['sleep', '20'], StringIO.new, StringIO.new, StringIO.new)
    process = Shrimple::Process.new(['sleep', '20'], StringIO.new, StringIO.new, StringIO.new)
    expect(Shrimple.processes.count).to eq 4
    puts "and hezza"
    Shrimple.processes.first.kill
    puts "GOT HERE"
    expect(Shrimple.processes.count).to eq 3
    puts "and here"
    # can't use Array#each since calling delete in the block causes it to screw up
    Shrimple.processes.kill_all
    puts "and here"
    expect(Shrimple.processes.count).to eq 0
  end
end
