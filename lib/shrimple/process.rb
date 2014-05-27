# Fires off a child process, feeds it, and keeps track of the results.

require 'open3'
require 'json'
require 'tempfile'
require 'shrimple/process_monitor'


class Shrimple
  class Process
    attr_reader :start_time, :stop_time  # start and finish times of Phantom process

    # runs cmd, passes instr on its stdin, and fills outio and
    # errio with the command's output.
    def initialize cmd, inio, outio, errio, timeout=nil
      @start_time = Time.now
      @chin, @chout, @cherr, @child = Open3.popen3(*cmd)

      Shrimple.processes.add(self)
      @chout.binmode

      @killed = false
      @timed_out = false

      @thrin  = Thread.new { drain(inio, @chin) }
      @throut = Thread.new { drain(@chout, outio) }
      @threrr = Thread.new { drain(@cherr, errio) }
      # ensure cleanup is called when the child exits. (strange it requires a whole new thread...?)
      @thrchild = Thread.new { outatime unless @child.join(timeout); cleanup }
    end

    # reads every last drop, then closes both files
    # called from thread context so you must synchronize any external accesses
    def drain reader, writer
      begin
        # randomly chosen buffer size
        loop { writer.write(reader.readpartial(256*1024)) }
      rescue EOFError
        # not an error
        # puts "EOF STDOUT" if reader == @chout
        # puts "EOF STDERR" if reader == @cherr
        # puts "EOF STDIN #{reader}" if writer == @chin
      rescue Errno::EPIPE
        # child was killed, no problem
      ensure
        reader.close
        writer.close rescue Errno::EPIPE
      end
    end


    def finished?
      @stop_time != nil
    end

    # returns false if the process hasn't finished yet
    def success?
      finished? && @child.value.success? ? true : false
    end

    def killed?
      @killed
    end

    def timed_out?
      @timed_out
    end


    # ennsure all threads have exited to prevent synchronization errors
    # if the phantom process is truly stuck, this might block forever
    def wait_for_the_end
      [@thrin, @throut, @threrr, @child].each(&:join)
      @thrchild.join unless Thread.current == @thrchild
    end

    # called from thread context so must synchronize.  may be called multiple times.
    def cleanup
      wait_for_the_end
      @stop_time ||= Time.now
      Shrimple.processes.remove(self)
    end

    # kill-o-zaps the rendering process and waits until it's sure it's truly gone
    def kill seconds_until_panic=2
      @killed = true
      if @child.alive?
        ::Process.kill("TERM", @child.pid)
      end
      if !@child.join(seconds_until_panic)
        ::Process.kill("KILL", @child.pid) if @child.alive?
      end
      @thrchild.join unless Thread.current == @thrchild
    end

    def outatime
      @timed_out = true
      kill
    end

    # blocks until the PhantomJS process is finished. raises an exception if it failed.
    def wait
      cleanup
    end

    # only meant to be used by the ProcessMonitor
    def _child_thread
      @child
    end
  end
end
