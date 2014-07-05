# Shrimple

Launches PhantomJS to render web sites or local files (or have
Phantom do pretty much everything).
Shrimple started as a set of patches for [Shrimp](https://github.com/adjust/shrimp).

[![Build Status](https://travis-ci.org/bronson/shrimple.svg?branch=master)](https://travis-ci.org/bronson/shrimple)
[![Gem Version](https://badge.fury.io/rb/shrimple.svg)](http://badge.fury.io/rb/shrimple)



## Installation

Install [PhantomJS](http://phantomjs.org/download.html), then add this line to your application's Gemfile:

    gem 'shrimple', git: 'https://github.com/bronson/shrimple'

and execute `bundle`.

## Usage

Render to a file:

```ruby
require 'shrimple'

s = Shrimple.new( page: { paperSize: { format: 'A4' }} )
s.render_pdf('http://bl.ocks.org/mbostock', to: '/tmp/output.pdf')
```

Or render to a variable by omitting the destination:

```ruby
result = Shrimple.new.render_text('http://thingsididlastnight.com')
result.stdout   # <== TODO: naming stdout is arcane
=> "Your Mom\n"
```

Render in the background:

TODO: show background mode
TODO: show start_time and finish_time?


## Configuration

Shrimple supports all configuration options provided by PhantomJS
(including unanticipated ones added in the future).

Options specified later override those specified earlier, and
options passed directly to render only affect that call -- they are not remembered.

```ruby
s = Shrimple.new( page: { zoomFactor: 0.5 }, timeout: 10 )
s.page.paperSize = { border: '3cm', format: 'A4', orientation: 'landscape' }
s.render_pdf('http://joeyh.name/blog/', to: '/tmp/joey.pdf')
```

* Set options passed to PhantomJS's [command line](http://phantomjs.org/api/command-line.html) with `config`:<br>
`s.config.loadImages = false`<br>
Phantom requires these to be in JSON notation: `proxyType` instead of `--proxy-type`.

* Set options in PhantomJS's [web page module](http://phantomjs.org/api/webpage/) with `page`:<br>
`s.page.paperSize.orientation = 'landscape'`

* Set options passed to PhantomJS's [render call](http://phantomjs.org/api/webpage/method/render.html) with `render`:<br>
`s.render = { format: 'jpeg', quality: 85 }`

See [default_config.rb](https://github.com/bronson/shrimple/blob/master/lib/shrimple/default_config.rb)
for the known options all listed in one place.

### Shrimple Options

- **background** If true, the PhantomJS process will be spawned in the background
  and Ruby execution will resume immediatley.<br>
  `background: false`

- **timeout** The time in seconds after which the PhantomJS executable is killed.
  If killed, the render results in an error.<br>
  `timeout: nil`

- **output / to** Specifies the destination file.  If you don't specify a destination
  then the output is buffered into memory and can be retrieved with `result.stdout`.
  `to` is just a more readable synonym for `output`.

- **stderr** The path to save phantom's stderr.  Normally it's buffered into memory
  and can be retrieved with `result.stderr`

- **onSuccess** A Ruby proc to be called when the render succeeds.<br>
  `onSuccess = ->(result) { ftp.put(result.stdout) }`

- **onError** A Ruby proc called when the render fails or is killed.<br>
  `onError = ->(result) { page_admin(result.stderr, result.options.to_hash) }`

####

These are more obscure, only necessary if you're trying to use Phantom in
an obscure way.

- **input** specifies the source file to render.  Normally you'd pass this as the first
  argument to render.  Use this option if you want to specify the input file once and render it multiple times.
  You must specify a valid URL.  Use `file://test_file.html` to specify a file on the local filesystem.

- **execuatable** a path to the phantomjs exectuable to use.  Shrimple searches
  pretty hard for installed phantomjs executables so there's usually no need
  to specify this.

- **renderer** the render.js script to pass to Phantom.  Probably only useful for testing.


## Changes to Shrimp

- Added background mode (even works in JRuby >1.7.4).
- Allows configuring pretty much anything: proxies, userName/password, scrollPosition, jpeg quality, etc.
- Prevents potential shell attacks by ensuring options aren't passed on the command line.
- Better error handling.
- Removed middleware.  In my app, background mode made it unnecessary.  Besides, I could never get it to work reliably.


## Copyright

Shrimp, the original project, is Copyright © 2012 adeven (Manuel Kniep).
It is free software, and may be redistributed under the MIT License (see LICENSE.txt).

Shrimple is also Copyright © 2013 Scott Bronson and may be redistributed under the same terms.
