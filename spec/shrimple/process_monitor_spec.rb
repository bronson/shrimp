require 'spec_helper'


# the other Shrimple specs exercise this class pretty well
# it would take a lot of mocking and stubbing to do it here too.


describe Shrimple::ProcessMonitor do
  it "will add a process" do
    processes = Shrimple::ProcessMonitor.new(1)
    # this should not raise an exception
    # not using expect(...).not_to raise_exception since that eats all raised expections.
    processes._add(Object.new)
  end

  it "won't launch too many processes" do
    processes = Shrimple::ProcessMonitor.new(0)
    expect { processes._add(Object.new) }.to raise_exception(Shrimple::TooManyProcessesError)
  end

  it "can disable the process counter" do
    processes = Shrimple::ProcessMonitor.new(-1)
    processes._add(Object.new)
  end

  it "counts and kills multiple processes" do
    expect(Shrimple.processes.count).to eq 0
    process = Shrimple::Process.new(['sleep', '20'], StringIO.new, StringIO.new, StringIO.new)
    process = Shrimple::Process.new(['sleep', '20'], StringIO.new, StringIO.new, StringIO.new)
    process = Shrimple::Process.new(['sleep', '20'], StringIO.new, StringIO.new, StringIO.new)
    process = Shrimple::Process.new(['sleep', '20'], StringIO.new, StringIO.new, StringIO.new)
    expect(Shrimple.processes.count).to eq 4
    Shrimple.processes.first.kill
    expect(Shrimple.processes.count).to eq 3
    # can't use Array#each since calling delete in the block causes it to screw up
    Shrimple.processes.kill_all
    expect(Shrimple.processes.count).to eq 0
  end

  it "waits for multiple processes" do
    expect(Shrimple.processes.count).to eq 0
    # these sleep durations might be too small, depends on machine load and scheduling.
    # if you're seeing threads finishing in the wrong order, try increasing them 10X.
    process1 = Shrimple::Process.new(['sleep', '.3'], StringIO.new, StringIO.new, StringIO.new)
    process2 = Shrimple::Process.new(['sleep', '.1'], StringIO.new, StringIO.new, StringIO.new)
    process3 = Shrimple::Process.new(['sleep', '.2'], StringIO.new, StringIO.new, StringIO.new)
    expect(Shrimple.processes.count).to eq 3

    child = Shrimple.processes.wait_next
    expect(child).to eq process2
    expect(child.finished?).to eq true
    expect(child.success?).to eq true
    expect(Shrimple.processes.count).to eq 2

    child = Shrimple.processes.wait_next
    expect(child).to eq process3
    expect(Shrimple.processes.count).to eq 1

    child = Shrimple.processes.wait_next
    expect(child).to eq process1
    expect(Shrimple.processes.count).to eq 0
  end

  it "handles waiting for zero processes" do
    expect {
      child = Shrimple.processes.wait_next
    }.to raise_exception(ThreadsWait::ErrNoWaitingThread)
  end

  it "can find a process" do
    processes = Shrimple::ProcessMonitor.new(-1)
    object = Object.new
    processes._add(object)
    result = processes.find { |o| o == object }
    expect(result).to eq object
  end
end
