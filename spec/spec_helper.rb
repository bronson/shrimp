require File.dirname(File.expand_path(__FILE__)) + '/../lib/shrimple'


# returns the example HTML that should be passed to phantomjs
def example_html
  File.expand_path('../test_file.html', __FILE__)
end
