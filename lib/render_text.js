var system = require('system')
var page = require('webpage').create()
config = JSON.parse(system.stdin.read())

page.open(config.input, function (status) {
  if (status !== 'success' /* || (statusCode !== 200 && statusCode !== null) */) {
    console.error(status, 'Unable to load the address: ', address);
    phantom.exit(1)
  } else {
    console.log(page.plainText)
    phantom.exit()
  }
});
