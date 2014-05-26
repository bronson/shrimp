// Invokes PhantomJS to render a webpage to stdout.  Config is supplied as json on stdin.

/* jshint phantom: true */


var system = require('system')
var page = require('webpage').create()

function errorHandler(msg, trace) {
  system.stderr.writeLine(msg)
  trace.forEach(function(item) {
    system.stderr.writeLine(' -> ' + (item.file || item.sourceURL) + ': ' + item.line + (item.function ? ' (in function ' + item.function + ')' : ''));
  })
  phantom.exit(1)
}

phantom.onError = function(msg, trace) { errorHandler("PHANTOM ERROR: " + msg, trace) }

page.onError = function(msg, trace) { errorHandler("PAGE ERROR: " + msg, trace) }

var config = JSON.parse(system.stdin.read())

for(var key in config.page) {
  page[key] = config.page[key]
}

page.open(config.input, function (status) {
  if (status !== 'success' /* || (statusCode !== 200 && statusCode !== null) */) {
    system.stderr.writeLine('Unable to load ' + config.input);
    phantom.exit(1);
  }

  if(config.render.format === 'text') {
    system.stdout.writeLine(page.plainText)
  } else if(config.render.format === 'html') {
    system.stdout.writeLine(page.content)
  } else {
    page.render('/dev/stdout', config.render);
  }

  phantom.exit(0);
});



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



// Determine the statusCode
// page.onResourceReceived = function (resource) {
//   if (resource.url === address) {
//     statusCode = resource.status;
//   }
// };

