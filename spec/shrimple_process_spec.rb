require 'spec_helper'

# run this to ensure there are no deadlock / process synchronization problems:
#    while rspec spec/shrimple_process_spec.rb ; do echo -n ; done

describe Shrimple::Process do
  let(:chout) { StringIO.new }
  let(:cherr) { StringIO.new }

  it "has a working drain method" do
    instr = 'x' * 1024 * 1024   # at least 1 MB of data
    process = Shrimple::Process.new('cat', instr, chout, cherr)
    process.wait
    expect(chout.string).to eq instr
    expect(process.finished?).to be_true
  end

  it "waits until a sleeping command is finished" do
    expect(Shrimple.processes.size).to eq 0

    elapsed = time do
      # echo -n doesn't work here because of platform variations
      # and for some reason jruby requires the explicit subshell; mri launches it automatically
      process = Shrimple::Process.new('/bin/sh -c "sleep 0.1 && printf done."', 'instr', chout, cherr)
      expect(Shrimple.processes.size).to eq 1
      process.wait
      expect(chout.string).to eq 'done.'
      expect(process.finished?).to be_true
    end

    expect(elapsed).to be >= 0.1
    expect(Shrimple.processes.size).to eq 0
    expect(chout.closed_read?).to be_true
    expect(cherr.closed_read?).to be_true
  end

  it "has a working kill method" do
    elapsed = time do
      process = Shrimple::Process.new(['sleep', '0.1'], 'instr', chout, cherr)
      process.kill
      expect(process.finished?).to be_true
    end

    expect(elapsed).to be < 0.1
    expect(chout.closed_read?).to be_true
    expect(cherr.closed_read?).to be_true
  end

  it "handles invalid commands" do
    expect {
      process = Shrimple::Process.new(['ThisCmdDoes.Not.Exist.'], 'instr', chout, cherr)
    }.to raise_error(/[Nn]o such file/)
  end

  it "counts multiple processes" do
    expect(Shrimple.processes.size).to eq 0
    process = Shrimple::Process.new(['sleep', '20'], 'instr', StringIO.new, StringIO.new)
    process = Shrimple::Process.new(['sleep', '20'], 'instr', StringIO.new, StringIO.new)
    process = Shrimple::Process.new(['sleep', '20'], 'instr', StringIO.new, StringIO.new)
    process = Shrimple::Process.new(['sleep', '20'], 'instr', StringIO.new, StringIO.new)
    expect(Shrimple.processes.size).to eq 4
    Shrimple.processes.first.kill
    expect(Shrimple.processes.size).to eq 3
    # can't use Array#each since calling delete in the block causes it to screw up
    Shrimple.processes.first.kill until Shrimple.processes.empty?
    expect(Shrimple.processes.size).to eq 0
  end
end
