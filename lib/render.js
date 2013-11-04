// Invokes PhantomJS to render a PDF or PNG file.
//
// Override the default arguments by supplying alternatives on the command line.
//
// 

var page = require('webpage').create(),
  fs = require('fs'),
  system = require('system'),
  args = {};
  
for (var i = 1; i < system.args.length; i += 2) {
  args[system.args[i].replace(/^-/, '')] = system.args[i+1];
}
console.log(JSON.stringify(args));

var margin = args.margin || '0cm',
  orientation = args.orientation || 'portrait',
  cookie_file = args.cookies ,
  render_time = args.render_time || 10000 ,
  cookies = {},
  address, output, size, statusCode;

page.customHeaders = {
  'Rack-Middleware-Shrimp': 'true',
  // Don't accept gzipped responses to fix https://github.com/ariya/phantomjs/issues/10930
  "Accept-Encoding": "identity"
};

if (typeof cookie_file != 'undefined') {
  try {
    f = fs.open(cookie_file, "r");
    cookies = JSON.parse(f.read());
    fs.remove(cookie_file)
  } catch (e) {
    console.log(e);
  }
  
  phantom.cookiesEnabled = true;
  phantom.cookies = cookies;
}

if (system.args.length < 3) {
  console.log('Usage: rasterize.js [options]');
  phantom.exit(1);
} else {
  address = args.input;
  output = args.output;
  page.viewportSize = { width:1200, height:1200 };
  page.zoomFactor = args.zoom;
  if ("clip_height" in args) {
    page.clipRect = { left:0, top:0, width:page.viewportSize.width, height:args.clip_height }
  }
  
  if (args.output_format == "pdf") {
    size = args.format.split('*');
    var paperSize = size.length === 2 ? { width:size[0], height:size[1], margin:'0px' }
      : { format:args.format, orientation:orientation, margin:margin };
    
    if ("footer" in args) {
      paperSize.footer =  {
        height: args.footer_height || "1cm",
        contents: phantom.callback(function(pageNum, numPages) {
          return args.footer;
        })
      };
    }
    if ("header" in args) {
      paperSize.header =  {
        height: args.header_height || "1cm",
        contents: phantom.callback(function(pageNum, numPages) {
          return args.header;
        })
      };
    }
    
    page.paperSize = paperSize;
  }
  // Determine the statusCode
  page.onResourceReceived = function (resource) {
    if (resource.url == address) {
      statusCode = resource.status;
    }
  };

  page.onError = function(msg,trace) {
    msgStack = ['ERROR: ' + msg]
    if(trace && trace.length) {
      msgStack.push('TRACE: ')
      trace.forEach(function(t) {
        msgStack.push(' -> ' + t.file + ': ' + t.line + (t.function ? ' (in function "' + t.function '")' : ''))
      })
    }
    console.error(msgStack.join('\n'))
  }

  page.open(address, function (status) {
    if (status !== 'success' || (statusCode != 200 && statusCode != null)) {
      console.log(statusCode, 'Unable to load the address: ', address);
      phantom.exit(1);
    } else {
      window.setTimeout(function () {
        page.render(output);

        if ("html_output" in args) {
          // Append the HTML content since the file is created by caller.
          fs.write(args.html_output, page.content, 'a');
        }
        
        console.log('rendered to: ' + output, new Date().getTime());
        phantom.exit();
      }, render_time);
    }
  });
}
