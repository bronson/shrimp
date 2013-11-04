# Shrimple

Use PhantomJS to generate PDFs from URLs or local files.
This is meant to be a do-one-thing-well interface extracted from [Shrimp](https://github.com/k1w1/shrimp).


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

There are a number of ways of passing configuration options.

```ruby
  s = Shrimple.new(orientation: 'landscape')    # pass options to the constructor
  s.options[:zoom] = 0.25    # set an option any time after the object is created
  s.render_pdf(src, dst, output_format: 'gif')  # or supply right to the renderer
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

Shrimp, the original project, is Copyright © 2012 adeven (Manuel Kniep).
It is free software, and may be redistributed under the terms specified in the LICENSE file. 

Shrimple is also Copyright © 2013 Scott Bronson and may be redistributed under the same terms.
