class Router extends Kazitori
  beforeAnytime:["beforeAny"]
  befores:
    '/<int:id>':['beforeShow']
  routes :
    '/': 'index'
    '/<int:id>': 'show'
    '/posts': 'index'
    '/posts/<int:id>': 'show'
    '/posts/new': 'new'
    '/posts/<int:id>/edit': 'edit'
    '/users/<int:id>/posts/<int:id>':'show'

  index: ->
    controller.index()

  show: (id)->
    controller.show(id)

  search: ->
    controller.search()

  beforeAny:(a)->
    console.log "before any"
  beforeShow:(a, b)->
    console.log "before show"

router = new Router()

controller =
  index: ->
    console.log 'controller.index'
  show: (id) ->
    console.log "controller.show"
  search: ->
    console.log "controller.search"

# originalLocation = location.href

describe "Kazitori", ->

  beforeEach ->
    router.change('/')

  afterEach ->
    router.change('/')

  describe "property", ->

    it "should started to be Truthy", ->
      expect(Kazitori.started).toBeTruthy()

    it "test stop and restart", ->
      router.stop()
      expect(Kazitori.started).toBeFalsy()
      router.start()

    it "test getHash", ->
      router.change('/#hogehoge')
      expect(router.getHash()).toEqual 'hogehoge'

    it "test getFragment", ->
      router.change('/2/2/1/2/a/e')
      expect(router.getFragment()).toEqual '/2/2/1/2/a/e'

    it "test isOldIE", ->
      msie = navigator.appVersion.toLowerCase()
      msie = if msie.indexOf('msie')>-1 then parseInt(msie.replace(/.*msie[ ]/,'').match(/^[0-9]+/)) else 0

      if msie is 0
        expect(router.isOldIE).toBeFalsy()
      else if msie <= 9
        expect(router.isOldIE).toBeTruthy()

  describe "event", ->

    it "test change event", ->
      _prev = "/valvalval/"
      _next = "/29y843g2w3t98n"
      router.change("#{_prev}")
      expect(window.location.pathname).toEqual "#{_prev}"
      _onChangeCalled = false

      _onChange = (e) ->
        _onChangeCalled = true
        expect(e.prev).toEqual "#{_prev}"
        expect(e.next).toEqual "#{_next}"

      router.addEventListener KazitoriEvent.CHANGE, _onChange
      router.change("#{_next}")
      expect(_onChangeCalled).toBeTruthy()
      router.removeEventListener KazitoriEvent.CHANGE, _onChange

  xit "test routes (simple)", ->
    location.replace("#{location.origin}/posts/1")
    expect(window.location.pathname).toEqual '/posts/1'

  it "can be change location (simple)", ->
    router.change('/posts/1')
    expect(window.location.pathname).toEqual '/posts/1'

  it "can be change location (two part)", ->
    router.change('/users/3/posts/1')
    expect(window.location.pathname).toEqual '/users/3/posts/1'

  describe "with controller", ->

    beforeEach ->
      spyOn(controller, 'index')
      spyOn(controller, 'show')

    it 'should be called', ->
      router.change('/posts/1')
      expect(controller.show).toHaveBeenCalled()

    it 'should be called with casted argments', ->
      router.change('/posts/32941856')
      expect(controller.show).toHaveBeenCalledWith(32941856)
