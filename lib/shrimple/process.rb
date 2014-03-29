# Fires off a PhantomJS process and keeps track of the results

require 'open3'
require 'json'
require 'tempfile'


class Shrimple
  class Process
    @@processes = {}

    # runs cmd, passes stdin, and waits for all stdout or stderr.
    def initialize cmd, instr, outio, errio
      @chin, @chout, @cherr, @child = Open3.popen3(*cmd)
      @chout.binmode
      @thrin  = Thread.new { flush(instr, @chin) }
      @throut = Thread.new { drain(@chout, outio) }
      @threrr = Thread.new { drain(@cherr, errio) }

      # TODO: add thread synchronized counting
      # @@processes[self.hash] = self
    end

    def flush instr, io
      begin
        @chin.write(instr);
        @chin.close_write
      rescue IOError
        # chin was closed
      end
    end

    # reads every last drop, then closes both files
    def drain io, file
      begin
        # randomly chosen buffer size
        loop { file.write(io.readpartial(256*1024)) }
      rescue EOFError
        io.close_read
      rescue IOError
        # io is already closed
      ensure
        file.close
      end
    end

    # returns true if the command is done, false if there's still IO pending
    def finished?
      @chout.closed? && @cherr.closed? && @chin.closed?
    end

    # kills the rendering process and closes the streams
    def cancel
      # IOError gets thrown if stream is already closed
      @chin.close_write rescue IOError
      @chout.close_read rescue IOError
      @cherr.close_read rescue IOError
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
