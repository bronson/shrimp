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

Render to a variable by omitting the destination:

```ruby
result = Shrimple.new.render_text('http://thingsididlastnight.com')
result.stdout   # <== TODO: is the stdout name too arcane?
=> "Your Mom\n"
```

Render in the background (demonstrates both callbacks and waiting):

```ruby
s = Shrimple.new(background: true)
s.onSuccess = ->(result) { File.write('/tmp/thumbs.png', result.stdout) }
s.onError   = ->(result) { File.write('/tmp/thumbs.err', result.stderr) }
result = s.render_png('https://www.google.com/search?tbm=isch&q=rameses%20b%20wallpaper')

puts "waiting..."   # printed immediately
result.wait         # blocks until the render process exits
puts "That took #{result.stop_time - result.start_time} seconds."
```


## Configuration

Shrimple supports all configuration options provided by PhantomJS,
including unanticipated ones added in the future.

Options specified later override those specified earlier.
Options passed directly to render only affect that particular call -- they are not remembered.

Here are some examples of passing options to Shrimple calls:

```ruby
s = Shrimple.new( page: { zoomFactor: 0.5 }, timeout: 10 )
s.page.paperSize = { border: '3cm', format: 'A4', orientation: 'landscape' }
s.render_pdf('http://joeyh.name/blog/', to: '/tmp/joey.pdf', background: true)
```

### PhantomJS Options

See [default_config.rb](https://github.com/bronson/shrimple/blob/master/lib/shrimple/default_config.rb)
for the known options all listed in one place.

* Options passed to PhantomJS's [command line](http://phantomjs.org/api/command-line.html) are set with `config`:<br>
`s.config.loadImages = false`<br>
Phantom requires these to be in JSON notation: `proxyType` instead of `--proxy-type`.

* Options for PhantomJS's [web page module](http://phantomjs.org/api/webpage/) are set with `page`:<br>
`s.page.paperSize.orientation = 'landscape'`

* Options for PhantomJS's [render call](http://phantomjs.org/api/webpage/method/render.html) are set, of course, with `render`:<br>
`s.render = { format: 'jpeg', quality: 85 }`

### Shrimple Options

- **background** If true, the PhantomJS process will be spawned in the background
  and the render call returns immediately<br>
  `background: false`

- **timeout** The time in seconds after which the PhantomJS executable is killed.<br>
  `timeout: 0.5`

- **output / to** Specifies the destination file.  If you don't specify a destination
  then the output is buffered into memory and can be retrieved with `result.stdout`.
  `to` is just a more readable synonym for `output`.<br>
  `to: '/tmp/tt.gif'`

- **stderr** The path to save phantom's stderr.  Normally it's buffered into memory
  and can be retrieved at any time with `result.stderr`.  There's no harm in calling
  it multiple times to monitor the process's output.

- **onSuccess** A Ruby proc to be called when the render succeeds.<br>
  `onSuccess = ->(result) { ftp.put(result.stdout) }`

- **onError** A Ruby proc called when the render fails or is killed.<br>
  `onError = ->(result) { page_admin(result.stderr, result.options.to_hash) }`

- **input** specifies the source file to render.  Normally you'd pass this as the first
  argument to render.  Use this option if you want to specify the input file once and render it multiple times.
  You must specify a valid URL.  Use `file://test_file.html` to specify a file on the local filesystem.

- **execuatable** a path to the phantomjs exectuable to use.  Shrimple searches
  pretty hard for installed phantomjs executables so there's usually no need
  to specify this.

- **renderer** the render.js script to pass to Phantom.  Probably only useful for testing.

## Examples

Here's a render pipeline that retrieves assets from a database, renders them, and
uploads them to an FTP site.  It keeps MAX_PROCESSES simultaneous
Phantom processes running, and ensures no more than MAX_FTP_BACKLOG PDF files are waiting
to be uploaded.

The pipeline stays as full as possible without violating its constraints.

```ruby
  # TODO: this could use some code review
  MAX_PROCESSES = 4
  MAX_FTP_BACKLOG = 8

  # FTP runs in a separate thread, plucking files and uploading them
  ftp_queue = SizedQueue.new(MAX_FTP_BACKLOG)

  # TODO: either make this clearer or use pseudocode?
  ftp_thread = Thread.new do
    open_ftp_connection do |ftp|
      done = false
      while !done || (done && !ftp_queue.empty?)
        name,data = ftp_queue.pop
        if value == :done
          done = true
        else
          send_file(ftp, name, data)
        end
      end
    end
  end

  renderer = Shrimple.new
  renderer.onSuccess = Proc.new do |result|
    # If there's no room in the queue, this call blocks until there is.
    ftp_queue.push([result.options.asset_file, result.stdout])
  end

  # finally, send each asset down the pipeline
  Asset.find_each do |asset|
    if Shrimple.processes.count >= MAX_PROCESSES
      Shrimple.processes.wait_next # block until a slot opens up
    end

    # render the pdf into memory
    renderer.render_pdf(asset.url, asset_file: asset.file)
  end
  ftp_thread.join   # ensure all files are uploaded before returning
```


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
