// Invokes PhantomJS to render a webpage to stdout.  Config is supplied as json on stdin.
/* jshint phantom: true */


// add onResourceTimeout:
// https://github.com/onlyurei/phantomjs/commit/fa5a3504070f86a99f11469a3b7eb17a0b005ef7


// phantom.onError = function(msg, trace) {
//   var msgStack = ['PHANTOM ERROR: ' + msg];
//   if (trace && trace.length) {
//     msgStack.push('TRACE:');
//     trace.forEach(function(t) {
//       msgStack.push(' -> ' + (t.file || t.sourceURL) + ': ' + t.line + (t.function ? ' (in function ' + t.function + ')' : ''));
//     });
//   }

//   console.error(msgStack.join('\n'));
//   phantom.exit(1);
// };


var system = require('system')
var page = require('webpage').create()

var config = JSON.parse(system.stdin.read())

for(var key in config.page) {
  page[key] = config.page[key]
}

page.open(config.input, function (status) {
  if (status !== 'success' /* || (statusCode !== 200 && statusCode !== null) */) {
    console.error(statusCode, 'Unable to load the address: ', address);
    phantom.exit(1);
  } else {
    if(config.render.format === 'text') {
      system.stdout.writeLine(page.plainText)
    } else if(config.render.format === 'html') {
      system.stdout.writeLine(page.content)
    } else {
      // window.setTimeout(function () {
        page.render('/dev/stdout', config.render);
      // }, render_time);
    }
    phantom.exit(0);
  }
});
  
// var margin = args.margin || '0cm',
//   orientation = args.orientation || 'portrait',
//   render_time = args.render_time || 10000 ,
//   address, output, size, statusCode;

// page.customHeaders = {
//   'Rack-Middleware-Shrimp': 'true',
//   // Don't accept gzipped responses to fix https://github.com/ariya/phantomjs/issues/10930
//   "Accept-Encoding": "identity"
// };

// if (typeof cookie_file !== 'undefined') {
//   try {
//     var f = fs.open(cookie_file, "r");
//     cookies = JSON.parse(f.read());
//     fs.remove(cookie_file)
//   } catch (e) {
//     // TODO: run this through regular error reporter.  just don't catch right?
//     console.log(e);
//   }
  
//   phantom.cookiesEnabled = true;
//   phantom.cookies = cookies;
// }



// address = args.input;
// output = args.output;


// page.viewportSize = { width:1200, height:1200 };
// page.zoomFactor = args.zoom;


// if ("clip_height" in args) {
//   page.clipRect = { left:0, top:0, width:page.viewportSize.width, height:args.clip_height }
// }

// if (args.output_format === "pdf") {
//   size = args.format.split('*');
//   var paperSize = size.length === 2 ? { width:size[0], height:size[1], margin:'0px' }
//     : { format:args.format, orientation:orientation, margin:margin };
  
//   if ("footer" in args) {
//     paperSize.footer =  {
//       height: args.footer_height || "1cm",
//       contents: phantom.callback(function(pageNum, numPages) {
//         return args.footer;
//       })
//     };
//   }
//   if ("header" in args) {
//     paperSize.header =  {
//       height: args.header_height || "1cm",
//       contents: phantom.callback(function(pageNum, numPages) {
//         return args.header;
//       })
//     };
//   }
  
//   page.paperSize = paperSize;
// }

// Determine the statusCode
// page.onResourceReceived = function (resource) {
//   if (resource.url === address) {
//     statusCode = resource.status;
//   }
// };

// page.onError = function(msg,trace) {
//   phantom.onError("PAGE: " + msg, trace)
// }

