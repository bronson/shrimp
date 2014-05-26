// ensures config correctly arrives via stdin
//
// reads json from stdin, adds "processed: true", and writes it to stdout.

var system = require('system')

config = JSON.parse(system.stdin.read())
config.processed = true
console.log(JSON.stringify(config))
phantom.exit(0)
