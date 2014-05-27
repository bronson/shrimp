# keeps track of running Shrimple processes

require 'thwait'


class Shrimple
  class TooManyProcessesError < StandardError; end

  class ProcessMonitor
    attr_accessor :max_processes

    # pass 0 to disable max_processes
    def initialize(max_processes=20)
      @mutex ||= Mutex.new
      @processes ||= []   # TODO: convert this to a hash by child thread?
      @max_processes = max_processes
    end

    def first
      @mutex.synchronize do
        @processes.first
      end
    end

    def count
      @mutex.synchronize do
        @processes.count
      end
    end

    def kill_all
      first.kill until @processes.empty?
    end

    # blocks until any child process returns (unless nonblock is true)
    # raises an exception if no processes are running, or if called nonblocking
    # and no processes have finished (see ThreadsWait#next_wait for details).
    def wait_next nonblock=nil
      # we wait on child threads since calling waitpid would produce a race condition.

      threads = {}
      @processes.each { |p|
        threads[p._child_thread] = p
      }

      thread = ThreadsWait.new(threads.keys).next_wait(nonblock)
      process = threads[thread]
      process._cleanup # otherwise process will be in an indeterminite state
      process
    end


    def _add process
      @mutex.synchronize do
        if @max_processes >= 0 && @processes.count >= @max_processes
          raise Shrimple::TooManyProcessesError.new("launched process #{@processes.count+1} of #{@max_processes} maximum")
        end
        @processes.push process
      end
    end

    def _remove process
      @mutex.synchronize do
        @processes.delete process
      end
    end
  end
end
