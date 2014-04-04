require File.dirname(File.expand_path(__FILE__)) + '/../lib/shrimple'

module Helpers
  # returns the example HTML that should be passed to phantomjs
  def example_html
    File.expand_path('../test_file.html', __FILE__)
  end

  # Returns the number of seconds the block took to execute
  # (is there no built-in way to do this??)
  # TODO: clean this up
  def time &block
   start = Time.now
   result = block.call
   finish = Time.now
   finish - start
  end
end


RSpec.configure do |config|
  config.include Helpers

  # if a failing test left phantom js processes hanging around, kill them
  config.after(:each) do
    Shrimple.processes.kill_all
  end
end


