# Fires off a child process, feeds it, and keeps track of the results.

require 'open3'
require 'json'
require 'tempfile'
require 'thread_safe'

# todo: extract process counting into a mixin?
# todo: extract timing into a mixin?

class Shrimple
  class Process
    attr_reader :start_time, :stop_time  # start and finish times of Phantom process

    # runs cmd, passes instr on its stdin, and fills outio and
    # errio with the command's output.
    def initialize cmd, inio, outio, errio
      @start_time = Time.now
      @chin, @chout, @cherr, @child = Open3.popen3(*cmd)
      @chout.binmode

      @thrin  = Thread.new { drain(inio, @chin) }
      @throut = Thread.new { drain(@chout, outio) }
      @threrr = Thread.new { drain(@cherr, errio) }

      # ensure cleanup is called when the child exits.
      # (seems strange I can't just call @child.atexit { cleanup } )
      @thrchild = Thread.new { @child.join; cleanup }
      Shrimple.processes.add(self)
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
        writer.close
      end
    end

    # returns true if the phantom process has exited and cleaned up
    def finished?
      @stop_time != nil
    end

    # ennsure all threads have exited to prevent synchronization errors
    # if the phantom process is truly stuck, this might block forever
    def wait_for_the_end
      puts "waiting thrin #{@child.pid}"
      @thrin.join
      puts "waiting throut #{@child.pid}"
      @throut.join
      puts "waiting threrr #{@child.pid}"
      @threrr.join
      puts "waiting child #{@child.pid}"
      @child.join
      # [@thrin, @throut, @threrr, @child].each { |th| puts "waiting #{th}"; th.join }
      puts "waiting thrchild #{@child.pid}"
      @thrchild.join unless Thread.current == @thrchild
      puts "wait done #{@child.pid}"
    end

    # called from thread context so must synchronize.  may be called multiple times.
    def cleanup
      puts "waiting to clean up"
      wait_for_the_end
      puts "continuing cleanup"
      puts "setting stop time"
      @stop_time ||= Time.now
      puts "deleting self"
      Shrimple.processes.remove(self)
      puts "cleanup done #{@child.pid}"
    end

    # kill-o-zaps the rendering process and waits until it's sure it's truly gone
    def kill seconds_until_panic=2
      if @child.alive?
        puts "sending kill to #{@child.pid}"
        ::Process.kill("TERM", @child.pid)
      end
      puts "first kill done #{@child.pid}"
      if !@child.join(seconds_until_panic)
        puts "needs second kill"
        ::Process.kill("KILL", @child.pid) if @child.alive?
      end
      @thrchild.join
    end

    # blocks until the PhantomJS process is finished. raises an exception if it failed.
    def wait
      cleanup
      unless @child.value.success?
        raise RenderingError.new("PhantomJS returned #{@child.value.inspect}")
      end
    end
  end
end
