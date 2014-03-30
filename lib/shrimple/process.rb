# Fires off a PhantomJS process and keeps track of the results

require 'open3'
require 'json'
require 'tempfile'


class Shrimple
  class RunningProcesses
    # just a thread-safe hash to keep track of running processes
    def initialize
      @lock = Mutex.new
      @list = {}
    end

    def size
      @lock.synchronize { @list.size }
    end

    def all
      @lock.synchronize { @list.values }
    end

    def add proc
      @lock.synchronize { @list[proc.hash] = proc }
    end

    def remove proc
      @lock.synchronize { @list.delete(proc.hash) }
    end
  end


  class Process
    @@processes = RunningProcesses.new

    def self.running
      @@processes.all
    end

    def self.count
      @@processes.size
    end



    # runs cmd, passes instr on its stdin, and fills outio and
    # errio with the command's output.
    def initialize cmd, instr, outio, errio
      @chin, @chout, @cherr, @child = Open3.popen3(*cmd)
      @chout.binmode
      @thrin  = Thread.new { flush(instr, @chin) }
      @throut = Thread.new { drain(@chout, outio) }
      @threrr = Thread.new { drain(@cherr, errio) }
      @@processes.add(self)
    end

    def flush instr, io
      begin
        @chin.write(instr);
      # rescue IOError
        # chin was closed
      rescue Errno::EPIPE
        # child was killed
      ensure
        @chin.close_write
        finished?
      end
    end

    # reads every last drop, then closes both files
    def drain io, file
      begin
        # randomly chosen buffer size
        loop { file.write(io.readpartial(256*1024)) }
      rescue EOFError
        # not an error
      rescue Errno::EPIPE
        # child was killed
      ensure
        io.close_read
        file.close
        finished?
      end
    end

    # returns true if the command is done, false if there's still IO pending
    def finished?
      done = @chout.closed? && @cherr.closed? && @chin.closed?
      @@processes.remove(self) if done
      done
    end

    # Terminates the rendering process and closes the streams.
    # Pass the "KILL" signal to kill the Phantom process hard.
    def kill signal="TERM"
      # IOError gets thrown if stream is already closed
      ::Process.kill(signal, @child.pid)
      wait_for_threads  # ensure threads are finished before returning so all files are closed
    end

    # blocks until the PhantomJS process is finished. raises an exception if it failed.
    def wait
      wait_for_threads
      unless @child.value.success?
        raise RenderingError.new("Rendering Error: #{cmd.join(' ')} returned #{@child.value}: #{outstr}")
      end
    end

    def wait_for_threads
      @thrin.join
      @throut.join
      @threrr.join
    end
  end
end
