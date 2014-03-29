# Shrimple

Use PhantomJS to generate PDFs from URLs or local files.
This is meant to be a small, transparent, do-one-thing-well PhantomJS interface.
It was extracted from [Shrimp](https://github.com/k1w1/shrimp).


## Installation

Add this line to your application's Gemfile:

    gem 'shrimple', git: 'https://github.com/bronson/shrimple'

And then execute:

    $ bundle

### PhantomJS

    See http://phantomjs.org/download.html


## Usage

```ruby
require 'shrimple'
Shrimple.new.render_pdf('http://be.com', '/tmp/output.pdf', margin: '1cm')
```


## Configuration

Fairly t  Options specified
later override those specified earlier.

```ruby
  s = Shrimple.new(orientation: 'landscape')    # pass options to the constructor
  s.options[:zoom] = 0.25    # set an option any time after the object is created
  s.render_pdf(src, dst, output_format: 'gif')  # or supply right to the renderer
```

Note that src must be a URL.  Use `file://test_file.html`
to specify a file on the local filesystem.


### Options

- background: if true, the PhantomJS process will be spawned in the background
  and Ruby execution will resume immediatley.

- execuatable: a path to the phantomjs exectuable to use.  Shrimple searches
  pretty hard for installed phantomjs executables so there's usually no need
  to specify this.

- renderer: the render.js script to pass to Phantom.  Probably only useful for testing.

Plus all the PhantomJS command-line options, in JSON notation (`proxyType` instead of `--proxy-type`): 
https://github.com/ariya/phantomjs/wiki/API-Reference#command-line-options


## Changes to Shrimp

- Added background mode (even works in JRuby >1.7.4).
- Allows configuring pretty much anything: proxies, userName/password, scrollPosition, jpeg quality, etc.
- Prevents shell attacks by passing all options over pipes as JSON.
- Better error handling.


## Copyright

Shrimp, the original project, is Copyright © 2012 adeven (Manuel Kniep).
It is free software, and may be redistributed under the MIT License (see LICENSE.txt).

Shrimple is also Copyright © 2013 Scott Bronson and may be redistributed under the same terms.
