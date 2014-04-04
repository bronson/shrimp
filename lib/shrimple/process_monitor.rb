# keeps track of running Shrimple processes


class Shrimple
  class TooManyProcessesError < StandardError; end

  class ProcessMonitor
    attr_accessor :max_processes

    # pass 0 to disable max_processes
    def initialize(max_processes=20)
      @mutex ||= Mutex.new
      @processes ||= []
      @max_processes = max_processes
    end

    def add process
      @mutex.synchronize do
        if @max_processes >= 0 && @processes.count >= @max_processes
          raise Shrimple::TooManyProcessesError.new("launched process #{@processes.count+1} of #{@max_processes} maximum")
        end
        @processes.push process
      end
    end

    def remove process
      @mutex.synchronize do
        @processes.delete process
      end
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
  end
end
