# This structure is preconfigured with the default for each component.
# All nil values are automatically removed before use (i.e. specify customHeaders:nil to prevent setting).

class Shrimple
  DefaultConfig = {
    # specifies options for running the PhantomJS executable
    background: false,     # false blocks until page is rendered, true returns immediately
    executable: nil,       # specifies the PhantomJS executable to use, if unspecified then Shrimple will search.
    renderer: nil,         # the render script to use (probably only useful when running automated tests or if you don't actually want to render)
    renderTimeTODO: 30,    # time in seconds after which the PhantomJS process should be killed
    input: nil,            # specifies the URL to request (use file:// for local assets)
    output: nil,           # path to the rendered output file
    logfile: nil,          # path to the file to contain the results of the render

    # options passed to the PhantomJS render method  http://phantomjs.org/api/webpage/method/render.html
    render: {
      format: nil,         # the format for the output file, taken from output extension
      quality: nil         # only relevant to format=jpeg I think, 1-100.
    },

    # specifies the command-line options passed to PhantomJS: http://phantomjs.org/api/command-line.html
    config: {
      cookiesFile: nil,      # path to the persitent cookies file
      diskCache: false,      # if true, caches requested assets.  See config.maxDiskCacheSize.  The cache location is not currently configurable.
      ignoreSslErrors: false, # if true, SSL errors won't prevent page from being rendered
      loadImages: true,       # load inlined images?  see also page.settings.loadImages
      localStoragePath: nil,   # directory to save LocalStorage and WebSQL content
      localStorageQuota: nil,  # maximum size for local data
      localToRemoteUrlAccess: false,   # local content can initiate requests for remote assets?  also see page.settings.localToRemoteUrlAccessEnabled
      maxDiskCacheSize: nil,   # maximum size for disk cache in KB.  Also see config.diskCache.
      outputEncoding: "utf8",  # sets the encoding used in the logfile
      remoteDebuggerPort: nil,      # starts the render script in a debug harness and listens on this port
      remoteDebuggerAutorun: false, # run the render script in a debugger?  (never needed)
      proxy: nil,              # proxy to use in "address:port" format
      proxyType: nil,          # type of proxy to use
      proxyAuth: nil,          # authentication information for proxy
      scriptEncoding: "utf8",  # encoding of the render script
      sslProtocol: "SSLv3",    # the protocol to use for SSL connections
      webSecurity: true        # enable web security and forbid cross-domain XHR?
    },

    # configures PhantomJS's webpage module: http://phantomjs.org/api/webpage/
    page: {
      canGoBack: false,      # allow javascript navigation
      canGoForward: false,   # allow javascript navigation
      clipRect: {            # area to rasterize when page.render is called
        left: 0,           #   (0,0,0,0) means render the entire page
        top: 0,
        width: 0,
        height: 0
      },
      customHeaders: {       # headers added to every HTTP request
        'X-User-Agent' => 'Shrimple',      # let servers know who is requesting the page (TODO: better header name?)
        "Accept-Encoding" => "identity"    # Don't accept gzipped responses, work around https://github.com/ariya/phantomjs/issues/10930
      },
      # event?  http://phantomjs.org/api/webpage/property/event.html
      # libraryPath?         # useful if we add support for calling injectJS
      navigationLocked: false, # if true, phantomjs prevents navigating away from the page
      offlineStoragePath: {},  # file to contain offline storage data
      offlineStorageQuota: {}, # maximum amount of data allowed in offline storage
      ownsPages: true,         # should child pages (opened with window.open()) be closed when parent closes
      paperSize: {             # the size of the rendered output (overridden by render_pdf and render_png)
        format: 'A4',
        orientation: 'portrait',
        border: '1cm'
      },
      scrollPosition: {        # scroll page to here before rendering
        left: 0,
        top: 0
      },
      settings: {             # request settings: http://phantomjs.org/api/webpage/property/settings.html
        javascriptCanCloseWindows: true,       # whether window.open() is allowed
        javascriptCanOpenWindows: true,        # whether window.close() is allowed
        javascriptEnabled: true,               # if false, Javascript in the requested page is not executed
        loadImages: true,                      # if false, inlined images in the requested page are not loaded (see also config.loadImages)
        localToRemoteUrlAccessEnabled: false,  # if true, local resources (like a page loaded using file:// url) are able to load remote assets.
        password: nil,                         # password for basic HTTP authentication, see also userName
        resourceTimeout: nil,                  # time in ms after which request will stop and onResourceTimeout() is called
        userAgent: nil,                        # user agent string for requests (nil means use PhantomJS's default WebKitty one)
        userName: nil,                         # name for basic HTTP authentication, see also password
        webSecurityEnabled: true,              # see config.webSecurity
        XSSAuditingEnabled: false              # monitor requests for XSS attempts
      },
      viewportSize: {            # like setting the size of the browser window
        width: 800,
        height: 600
      },
      zoomFactor: 1.0            # 4.0 increases page by 4X before rendering (right?), 0.25 shrinks page by 4X
    }
  }


  # defaults used by the render_pdf, render_png, etc helpers

  DefaultPageSize = {
    format: 'A4',
    orientation: 'portrait',
    border: '1cm'
  }

  DefaultImageSize = {
    width: '800px',
    height: '600px',
    border: '0px'
  }
end



# read-only fields, used for output:
#  content
#  frameContent
#  frameName
#  framePlainText
#  frameTitle
#  frameUrl
#  framesCount
#  framesName
#  pages    -- child pages opened with window.open() right?
#  pagesWindowName
#  plainText
#  title
#  url
#  windowName
