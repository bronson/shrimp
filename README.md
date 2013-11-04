# Shrimple

Creates PDFs from URLs using phantomjs.

A do-one-thing-well interface to PhantomJS extracted from [Shrimp](https://github.com/k1w1/shrimp).

## Installation

Add this line to your application's Gemfile:

    gem 'shrimple', git: 'https://github.com/bronson/shrimple'

And then execute:

    $ bundle

### pantomjs

    See http://phantomjs.org/download.html on how to install phatomjs

## Usage

```
require 'shrimple'
url     = 'http://www.google.com'
options = { :margin => "1cm"}
Shrimple.new(url, [options...]).to_pdf("~/output.pdf")
```
## Configuration

```
Shrimp.configure do |config|

  # The path to the phantomjs executable
  # defaults to `where phantomjs`
  # config.phantomjs = '/usr/local/bin/phantomjs'

  # the default pdf output format
  # e.g. "5in*7.5in", "10cm*20cm", "A4", "Letter"
  # config.format           = 'Letter'

  # the default margin
  # config.margin           = '1cm'

  # the zoom factor
  # config.zoom             = 1

  # the page orientation 'portrait' or 'landscape'
  # config.orientation      = 'portrait'

  # a temporary dir used to store tempfiles
  # config.tmpdir           = Dir.tmpdir

  # whether or not exceptions should explicitly be raised
  # config.fail_silently    = false

  # the maximum time spent rendering a pdf
  # config.rendering_time   = 30000
end
```

### Troubleshooting

*  **Single thread issue:** In development environments it is common to run a
   single server process. This can cause issues because rendering your pdf
   requires phantomjs to hit your server again (for images, js, css).
   This is because the resource requests will get blocked by the initial
   request and the initial request will be waiting on the resource
   requests causing a deadlock.

   This is usually not an issue in a production environment. To get
   around this issue you may want to run a server with multiple workers
   like Passenger or try to embed your resources within your HTML to
   avoid extra HTTP requests.
   
   Example solution (rails / bundler), add unicorn to the development 
   group in your Gemfile `gem 'unicorn'` then run `bundle`. Next, add a 
   file `config/unicorn.conf` with
   
        worker_processes 3
   
   Then to run the app `unicorn_rails -c config/unicorn.conf` (from rails_root)
  (taken from pdfkit readme: https://github.com/pdfkit/pdfkit)


## Copyright

Shrimp is Copyright © 2012 adeven (Manuel Kniep).
It is free software, and may be redistributed under the terms specified in the LICENSE file. 

Shrimple is Copyright © 2013 Scott Bronson and may be redistributed under the same terms.
