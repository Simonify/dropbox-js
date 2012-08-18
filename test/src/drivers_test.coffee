describe 'DropboxRedirectDriver', ->
  describe 'url', ->
    beforeEach ->
      @stub = sinon.stub Dropbox.Drivers.Redirect, 'currentLocation'
    afterEach ->
      @stub.restore()

    it 'adds a query string to a static URL', ->
      @stub.returns 'http://test/file'
      driver = new Dropbox.Drivers.Redirect
      expect(driver.url()).to.
          equal 'http://test/file?_dropboxjs_scope=default'

    it 'adds a fragment to a static URL', ->
      @stub.returns 'http://test/file'
      driver = new Dropbox.Drivers.Redirect useHash: true
      expect(driver.url()).to.
          equal 'http://test/file#?_dropboxjs_scope=default'

    it 'adds a query param to a URL with a query string', ->
      @stub.returns 'http://test/file?a=true'
      driver = new Dropbox.Drivers.Redirect
      expect(driver.url()).to.
          equal 'http://test/file?a=true&_dropboxjs_scope=default'

    it 'adds a fragment to a URL with a query string', ->
      @stub.returns 'http://test/file?a=true'
      driver = new Dropbox.Drivers.Redirect useHash: true
      expect(driver.url()).to.
          equal 'http://test/file?a=true#?_dropboxjs_scope=default'

    it 'adds a query string to a static URL with a fragment', ->
      @stub.returns 'http://test/file#frag'
      driver = new Dropbox.Drivers.Redirect
      expect(driver.url()).to.
          equal 'http://test/file?_dropboxjs_scope=default#frag'

    it 'replaces the fragment in a static URL with a fragment', ->
      @stub.returns 'http://test/file#frag'
      driver = new Dropbox.Drivers.Redirect useHash: true
      expect(driver.url()).to.
          equal 'http://test/file#?_dropboxjs_scope=default'

    it 'adds a query param to a URL with a query string and fragment', ->
      @stub.returns 'http://test/file?a=true#frag'
      driver = new Dropbox.Drivers.Redirect
      expect(driver.url()).to.
          equal 'http://test/file?a=true&_dropboxjs_scope=default#frag'

    it 'replaces the fragment in a URL with a query string and fragment', ->
      @stub.returns 'http://test/file?a=true#frag'
      driver = new Dropbox.Drivers.Redirect useHash: true
      expect(driver.url()).to.
          equal 'http://test/file?a=true#?_dropboxjs_scope=default'

    it 'obeys the scope option', ->
      @stub.returns 'http://test/file'
      driver = new Dropbox.Drivers.Redirect scope: 'not default'
      expect(driver.url()).to.
          equal 'http://test/file?_dropboxjs_scope=not%20default'

    it 'obeys the scope option when adding a fragment', ->
      @stub.returns 'http://test/file'
      driver = new Dropbox.Drivers.Redirect scope: 'not default', useHash: true
      expect(driver.url()).to.
          equal 'http://test/file#?_dropboxjs_scope=not%20default'

  describe 'locationToken', ->
    beforeEach ->
      @stub = sinon.stub Dropbox.Drivers.Redirect, 'currentLocation'
    afterEach ->
      @stub.restore()

    it 'returns null if the location does not contain the arg', ->
      @stub.returns 'http://test/file?_dropboxjs_scope=default& ' +
                    'another_token=ab%20cd&oauth_tok=en'
      driver = new Dropbox.Drivers.Redirect
      expect(driver.locationToken()).to.equal null

    it 'returns null if the location fragment does not contain the arg', ->
      @stub.returns 'http://test/file#?_dropboxjs_scope=default& ' +
                    'another_token=ab%20cd&oauth_tok=en'
      driver = new Dropbox.Drivers.Redirect
      expect(driver.locationToken()).to.equal null

    it "extracts the token successfully with default scope", ->
      @stub.returns 'http://test/file?_dropboxjs_scope=default&' +
                    'oauth_token=ab%20cd&other_param=true'
      driver = new Dropbox.Drivers.Redirect
      expect(driver.locationToken()).to.equal 'ab cd'

    it "extracts the token successfully with set scope", ->
      @stub.returns 'http://test/file?_dropboxjs_scope=not%20default&' +
                    'oauth_token=ab%20cd'
      driver = new Dropbox.Drivers.Redirect scope: 'not default'
      expect(driver.locationToken()).to.equal 'ab cd'

    it "extracts the token from fragment with default scope", ->
      @stub.returns 'http://test/file#?_dropboxjs_scope=default&' +
                    'oauth_token=ab%20cd&other_param=true'
      driver = new Dropbox.Drivers.Redirect
      expect(driver.locationToken()).to.equal 'ab cd'

    it "extracts the token from fragment with set scope", ->
      @stub.returns 'http://test/file#?_dropboxjs_scope=not%20default&' +
                    'oauth_token=ab%20cd'
      driver = new Dropbox.Drivers.Redirect scope: 'not default'
      expect(driver.locationToken()).to.equal 'ab cd'

    it "returns null if the location scope doesn't match", ->
      @stub.returns 'http://test/file?_dropboxjs_scope=defaultx&oauth_token=ab'
      driver = new Dropbox.Drivers.Redirect
      expect(driver.locationToken()).to.equal null

    it "returns null if the location fragment scope doesn't match", ->
      @stub.returns 'http://test/file#?_dropboxjs_scope=defaultx&oauth_token=a'
      driver = new Dropbox.Drivers.Redirect
      expect(driver.locationToken()).to.equal null

  describe 'integration', ->
    beforeEach ->
      @node_js = module? and module?.exports? and require?

    it 'should work', (done) ->
      return done() if @node_js
      @timeout 30 * 1000  # Time-consuming because the user must click.

      listener = (event) ->
        [error, credentials] = JSON.parse event.data
        expect(error).to.equal null
        expect(credentials).to.have.property 'uid'
        expect(credentials.uid).to.be.a 'string'
        window.removeEventListener 'message', listener
        done()      

      window.addEventListener 'message', listener
      (new Dropbox.Drivers.Popup()).openWindow(
          '/test/html/redirect_driver_test.html')

describe 'DropboxPopupDriver', ->
  describe 'url', ->
    beforeEach ->
      @stub = sinon.stub Dropbox.Drivers.Popup, 'currentLocation'
      @stub.returns 'http://test:123/a/path/file.htmx'

    afterEach ->
      @stub.restore()

    it 'reflects the current page when there are no options', ->
      driver = new Dropbox.Drivers.Popup
      expect(driver.url()).to.equal 'http://test:123/a/path/file.htmx'

    it 'replaces the current file correctly', ->
      driver = new Dropbox.Drivers.Popup receiverFile: 'another.file'
      expect(driver.url()).to.equal 'http://test:123/a/path/another.file#'

    it 'replaces the entire URL correctly', ->
      driver = new Dropbox.Drivers.Popup
        receiverUrl: 'https://something.com/filez'
      expect(driver.url()).to.equal 'https://something.com/filez'
