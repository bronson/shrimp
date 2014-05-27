# Here is a list of all the phantomjs settings that we know about.
# Note that you can set any option you want.  It need not be listed here.
#
# nil means leave unset -- use Phantom's defaults


class Shrimple
  DefaultConfig = {

    #
    # options for launching the PhantomJS executable
    #

    background: nil,       # false blocks until page is rendered, true returns immediately
    executable: nil,       # specifies the PhantomJS executable to use. If unspecified then Shrimple will search for one.
    renderer: nil,         # the render script to use. Useful for testing, or if you want to do something other than rendering the page.
    timeout: nil,          # time in seconds after which the PhantomJS process should simply be killed
    input: nil,            # specifies the URL to request (use file:// for local assets)
    output: nil,           # path to the rendered output file, nil to buffer output in memory.  "to" is a more readable synonym: 'render url, to: file'.
    stderr: nil,           # path to the file to receive PhantomJS's stderr, leave nil to store it in a string


    #
    # arguments passed to the PhantomJS render method  http://phantomjs.org/api/webpage/method/render.html
    #

    render: {
      format: nil,         # format for the output file.  usually supplied by a helper (render_pdf, render_png, etc)
      quality: nil         # only relevant to format=jpeg I think, range is 1-100.  not sure what Phantom's default is
    },


    #
    # command-line options passed to PhantomJS in --config: http://phantomjs.org/api/command-line.html
    #

    config: {
      cookiesFile: nil,        # path to the persitent cookies file
      diskCache: nil,          # if true, caches requested assets.  Defaults to false.  See config.maxDiskCacheSize.  The cache location is not currently configurable.
      ignoreSslErrors: nil,    # if true, SSL errors won't prevent page from being rendered.  defaults to false
      loadImages: nil,         # load inlined images?  defaults to true.  see also page.settings.loadImages
      localStoragePath: nil,   # directory to save LocalStorage and WebSQL content
      localStorageQuota: nil,  # maximum size for local data
      localToRemoteUrlAccess: nil,   # local content can initiate requests for remote assets?  Defaults to false. also see page.settings.localToRemoteUrlAccessEnabled
      maxDiskCacheSize: nil,   # maximum size for disk cache in KB.  Also see config.diskCache.
      outputEncoding: nil,     # sets the encoding used in the logfile.  nil means "utf8"
      remoteDebuggerPort: nil, # starts the render script in a debug harness and listens on this port
      remoteDebuggerAutorun: nil, # run the render script in a debugger?  defaults to false, probably never needed
      proxy: nil,              # proxy to use in "address:port" format
      proxyType: nil,          # type of proxy to use
      proxyAuth: nil,          # authentication information for proxy
      scriptEncoding: nil,     # encoding of the render script, defaults to "utf8"
      sslProtocol: nil,        # the protocol to use for SSL connections, defaults to "SSLv3"
      webSecurity: nil         # enable web security and forbid cross-domain XHR?  Defaults to true
    },


    #
    # settings for rendering the page: http://phantomjs.org/api/webpage/
    #

    page: {
      canGoBack: nil,          # allow javascript navigation, defaults to false
      canGoForward: nil,       # allow javascript navigation, defaults to false
      clipRect: {              # area to rasterize when page.render is called
        left: nil,             # Defaults to (0,0,0,0) meaning render the entire page
        top: nil,
        width: nil,
        height: nil
      },
      customHeaders: {       # headers added to every HTTP request.  if nil, Shrimple.DefaultHeaders is used.
        "Accept-Encoding" => "identity" # Don't accept gzipped responses, work around https://github.com/ariya/phantomjs/issues/10930
      },
      # event?  http://phantomjs.org/api/webpage/property/event.html
      # libraryPath?           # might be useful if we add support for calling injectJS
      navigationLocked: nil,   # if true, phantomjs prevents navigating away from the page. Defaults to false.
      offlineStoragePath: nil, # file to contain offline storage data
      offlineStorageQuota: nil, # maximum amount of data allowed in offline storage
      ownsPages: nil,          # should child pages (opened with window.open()) be closed when parent closes?  Defaults to true.
      paperSize: {             # the size of the rendered output (overridden by render_pdf and render_png)
        format: nil,           # size for pdf pages, defaults to 'A4'?
        orientation: nil,      # orientation for pdf pages, defautls to 'portrait?'
        width: nil,            # width of png/jpeg/gif
        height: nil,           # height of png/jpeg/gif
        border: nil            # defaults to '1cm'?
      },
      scrollPosition: {        # scroll page to here before rendering
        left: nil,             # defaults to (0,0) which renders the entire page
        top: nil
      },
      settings: {             # request settings: http://phantomjs.org/api/webpage/property/settings.html
        javascriptCanCloseWindows: nil,        # whether window.open() is allowed, defaults to true
        javascriptCanOpenWindows: nil,         # whether window.close() is allowed, defaults to true
        javascriptEnabled: nil,                # if false, Javascript in the requested page is not executed.  Defaults to true.
        loadImages: nil,                       # if false, inlined images in the requested page are not loaded (see also config.loadImages).  Defaults to true.
        localToRemoteUrlAccessEnabled: nil,    # if true, local resources (like a page loaded using file:// url) are able to load remote assets.  Defaults to false.
        password: nil,                         # password for basic HTTP authentication, see also userName
        resourceTimeout: nil,                  # time in ms after which request will stop and onResourceTimeout() is called
        userAgent: nil,                        # user agent string for requests (nil means use PhantomJS's default WebKitty one)
        userName: nil,                         # name for basic HTTP authentication, see also password
        webSecurityEnabled: nil,               # see config.webSecurity.  Defaults to true.
        XSSAuditingEnabled: nil                # monitor requests for XSS attempts.  Defaults to false.
      },
      viewportSize: {            # sets the size of the virtual browser window
        width: nil,
        height: nil
      },
      zoomFactor: nil            # 4.0 increases page by 4X before rendering (right?), 0.25 shrinks page by 4X.  Defaults to 1.0.
    }
  }
end
