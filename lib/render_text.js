// Invokes Phantom to download the given webpage and return its plaintext. 

// todo: roll this into render.js so it can take advantage of timeouts, onerrors, etc.

var system = require('system')
var page = require('webpage').create()
config = JSON.parse(system.stdin.read())

page.open(config.input, function (status) {
  if (status !== 'success' /* || (statusCode !== 200 && statusCode !== null) */) {
    console.error(status, 'Unable to load the address: ', address);
    phantom.exit(1)
  } else {
    console.log(config.html ? page.content : page.plainText)
    phantom.exit()
  }
});
