# Fires off a PhantomJS process, feeds it, and keeps track of the results.

require 'open3'
require 'json'
require 'tempfile'
require 'thread_safe'


class Shrimple
  # an array of the currently running PhantomJS processes
  def self.processes
    @processes ||= ThreadSafe::Array.new
  end

  class Process
    # runs cmd, passes instr on its stdin, and fills outio and
    # errio with the command's output.
    def initialize cmd, instr, outio, errio
      @chin, @chout, @cherr, @child = Open3.popen3(*cmd)
      @chout.binmode
      @thrin  = Thread.new { flush(instr, @chin) }
      @throut = Thread.new { drain(@chout, outio) }
      @threrr = Thread.new { drain(@cherr, errio) }
      Shrimple.processes.push(self)
    end

    def inspect
      "#<Thing:0x%08x>" % (object_id * 2)
    end

    # writes the string to the file, then closes it
    def flush instr, io
      begin
        @chin.write(instr);
      rescue Errno::EPIPE
        # child was killed, no big deal
      ensure
        @chin.close rescue Errno::EPIPE  # jruby bails if you try to close a broken pipe
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
        # child was killed, no problem
      ensure
        io.close
        file.close
        finished?
      end
    end

    # returns true if the command is done, false if there's still IO pending
    def finished?
      if @chout.closed? && @cherr.closed? && @chin.closed?
        Shrimple.processes.delete(self)
        return true
      end
    end

    # Terminates the rendering process and closes the streams.
    # Pass the "KILL" signal to kill the Phantom process immediately and hard.
    def kill signal="TERM"
      ::Process.kill(signal, @child.pid)
      wait_for_threads  # ensure threads are finished before returning so all files are closed
    end

    # blocks until the PhantomJS process is finished. raises an exception if it failed.
    def wait
      wait_for_threads
      val = @child.value
      unless val.success?
        raise RenderingError.new("PhantomJS returned #{val.inspect}")
      end
    end

    def wait_for_threads
      @thrin.join
      @throut.join
      @threrr.join
    end
  end
end
