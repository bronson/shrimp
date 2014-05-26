require 'spec_helper'


# the other Shrimple specs exercise this class pretty well
# it would take a lot of mocking and stubbing to do it here too.


describe Shrimple::ProcessMonitor do
  it "will add a process" do
    processes = Shrimple::ProcessMonitor.new(1)
    # this should not raise an exception
    # not using expect(...).not_to raise_exception since that eats all raised expections.
    processes.add(Object.new)
  end

  it "won't launch too many processes" do
    processes = Shrimple::ProcessMonitor.new(0)
    expect { processes.add(Object.new) }.to raise_exception(Shrimple::TooManyProcessesError)
  end

  it "can disable the process counter" do
    processes = Shrimple::ProcessMonitor.new(-1)
    processes.add(Object.new)
  end
end
