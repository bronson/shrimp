# Fires off a PhantomJS process and keeps track of the results

class Shrimple
  class Process
    attr_accessor :outfile, :configfile, :pid

    def initialize outfile, configfile, pid
      @outfile, @configfile, @pid = outfile, configfile, pid
    end

    def cleanup
      outfile.unlink
      configfile.unlink
    end

    # returns all the output produced by the PhantomJS process.
    def output
      outfile.rewind
      outfile.read
    end

    # detach returns immediately, requiring the caller to collect the result and then
    # call cleanup (or a tempfile will be leaked).  Called when the background option is true.
    def deatach
      Process.detach(pid)
      return self
    end

    # wait blocks until PhantomJS is done, then cleans up.
    # It raises an error if Phantom failed.  Called when the background option is false.
    def wait
      Process.wait(pid)
      outstr = output
      cleanup

      unless $?.success?
        raise RenderingError.new("Rendering Error: #{cmd.join(' ')} returned #{$?.exitstatus}: #{outstr}")
      end

      true # no better return value?
    end
  end
end
