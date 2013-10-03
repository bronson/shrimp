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

page.customHeaders = { 'Rack-Middleware-Shrimp': 'true' };

try {
  f = fs.open(cookie_file, "r");
  cookies = JSON.parse(f.read());
  fs.remove(cookie_file)
} catch (e) {
  console.log(e);
}
phantom.cookiesEnabled = true;
phantom.cookies = cookies;

if (system.args.length < 3) {
  console.log('Usage: rasterize.js [options]');
  phantom.exit(1);
} else {
  address = args.input;
  output = args.output;
  page.viewportSize = { width:1200, height:1200 };
  page.zoomFactor = args.zoom;
  if (args.output_format == "pdf") {
    size = args.format.split('*');
    page.paperSize = size.length === 2 ? { width:size[0], height:size[1], margin:'0px' }
      : { format:args.format, orientation:orientation, margin:margin };
  }

  // determine the statusCode
  page.onResourceReceived = function (resource) {
    if (resource.url == address) {
      statusCode = resource.status;
    }
  };

  page.open(address, function (status) {
    if (status !== 'success' || (statusCode != 200 && statusCode != null)) {
      console.log(statusCode, 'Unable to load the address: ', address);
      if (fs.exists(output)) {
        fs.remove(output);
      }
      try {
        fs.touch(output);
      }
      catch (e) {
        phantom.exit(1);
        throw e
      }
      phantom.exit(1);
    } else {
      window.setTimeout(function () {
        page.render(output);

        console.log('rendered to: ' + output, new Date().getTime());
        phantom.exit();
      }, render_time);
    }
  });
}
