require 'spec_helper'

# we use timing to determine if reads blocked or not.  this might be
# an issue on heavily loaded machines.   is there a better way?

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
    elapsed = time do
      # echo -n doesn't work here because of platform variations
      process = Shrimple::Process.new('sleep 0.1 && printf done.', 'instr', chout, cherr)
      process.wait
      expect(chout.string).to eq 'done.'
      expect(process.finished?).to be_true
    end

    expect(elapsed).to be >= 0.1
    expect(chout.closed_read?).to be_true
    expect(cherr.closed_read?).to be_true
  end

  it "has a working cancel method" do
    elapsed = time do
      process = Shrimple::Process.new(['sleep', '0.1'], 'instr', chout, cherr)
      process.cancel
      expect(process.finished?).to be_true
    end

    expect(elapsed).to be < 0.1
    expect(chout.closed_read?).to be_true
    expect(cherr.closed_read?).to be_true
  end

  it "handles invalid commands" do
    expect {
      process = Shrimple::Process.new(['ThisCmdDoes.Not.Exist.'], 'instr', chout, cherr)
    }.to raise_error(Errno::ENOENT)
  end
end
