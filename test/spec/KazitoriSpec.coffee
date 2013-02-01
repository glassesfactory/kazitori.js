controller =
  beforeAny: ->
    console.log 'controller.beforeAny'
  beforeShow: (id) ->
    console.log 'controller.beforeShow'
  index: ->
    # console.log 'controller.index'
  show: (id) ->
    # console.log "controller.show"
  search: ->
    # console.log "controller.search"

class Router extends Kazitori
  beforeAnytime:["beforeAny"]

  befores:
    '/<int:id>': ['beforeShow']
    '/posts/<int:id>': ['beforeShow']

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

  show: (id) ->
    controller.show(id)

  search: ->
    controller.search()

  beforeAny: ->
    controller.beforeAny()

  beforeShow: (id) ->
    controller.beforeShow(id)

@router = new Router()

originalLocation = location.href

window.addEventListener 'popstate', (e) ->
  console.log 'popstate'
window.addEventListener 'hashchange', (e) ->
  console.log 'hashchangedddd'

describe "Kazitori", ->

  beforeEach ->
    # console.log '_beforeEach'
    router.change('/')

  afterEach ->
    # console.log '^-afterEach'
    router.change('/')

  describe "property", ->

    it "should started to be Truthy", ->
      expect(Kazitori.started).toBeTruthy()

    it "test stop and restart", ->
      router.stop()
      expect(Kazitori.started).toBeFalsy()
      router.start()

    xit "test getHash", ->
      location.replace("#{location.origin}/#posts")
      expect(router.getHash()).toEqual 'posts'

    it "test getFragment", ->
      router.change('/posts/1')
      expect(router.getFragment()).toEqual '/posts/1'

    it "test isOldIE", ->
      msie = navigator.appVersion.toLowerCase()
      msie = if msie.indexOf('msie')>-1 then parseInt(msie.replace(/.*msie[ ]/,'').match(/^[0-9]+/)) else 0

      if msie is 0
        expect(router.isOldIE).toBeFalsy()
      else if msie <= 9
        expect(router.isOldIE).toBeTruthy()

  describe "event", ->

    it "should remove listener without listener added", ->
      router.removeEventListener KazitoriEvent.START, (e) ->
        true

    startHandler = jasmine.createSpy('START event')

    it "should dispatch start event when kazitori started", ->
      router.addEventListener KazitoriEvent.START, startHandler

      router.stop()
      router.start()
      expect(startHandler).toHaveBeenCalled()

    it "should dispatch start event once", ->
      expect(startHandler.calls.length).toEqual(1)

    it "should not call handler when START event listener removed", ->

      router.removeEventListener KazitoriEvent.START, startHandler
      startHandler.reset()
      router.stop()
      router.start()
      expect(startHandler).not.toHaveBeenCalled()

    stopHandler = jasmine.createSpy('STOP event')

    it "should dispatch stop event when kazitori stoped", ->
      router.addEventListener KazitoriEvent.STOP, stopHandler
      router.stop()
      expect(stopHandler).toHaveBeenCalled()

    it "should dispatch stop event once", ->
      expect(stopHandler.calls.length).toEqual(1)

    it "should not call handler when STOP event listener removed", ->
      router.removeEventListener KazitoriEvent.STOP, stopHandler
      stopHandler.reset()
      router.stop()
      expect(stopHandler).not.toHaveBeenCalled()
      router.start()

    xit "should dispatch change events when kazitori changed", ->
      _prev = "/posts"
      _next = "/posts/new"
      router.change("#{_prev}")
      expect(window.location.pathname).toEqual "#{_prev}"

      listener =
        onChange: (e) ->
          console.log 'onChange'
          expect(e.prev).toEqual "#{_prev}"
          expect(e.next).toEqual "#{_next}"
        onInternalChange: (e) ->
          console.log 'onInternalChange'
          expect(e.prev).toEqual "#{_prev}"
          expect(e.next).toEqual "#{_next}"
        onUserChange: (e) ->
          console.log 'onUserChange'
          expect(e.prev).toEqual "#{_prev}"
          expect(e.next).toEqual "#{_next}"

      spyOn(listener, 'onChange').andCallThrough()
      spyOn(listener, 'onInternalChange').andCallThrough()
      spyOn(listener, 'onUserChange').andCallThrough()

      router.addEventListener KazitoriEvent.CHANGE, listener.onChange
      router.addEventListener KazitoriEvent.INTERNAL_CHANGE, listener.onInternalChange
      router.addEventListener KazitoriEvent.USER_CHANGE, listener.onUserChange

      router.change("#{_next}")
      expect(listener.onChange).toHaveBeenCalled()
      expect(listener.onChange.calls.length).toEqual(1)

      expect(listener.onInternalChange).toHaveBeenCalled()
      expect(listener.onInternalChange.calls.length).toEqual(1)

      expect(listener.onUserChange).not.toHaveBeenCalled()

      listener.onChange.reset()
      listener.onInternalChange.reset()
      listener.onUserChange.reset()
      location.replace("#{location.origin}#{_prev}")
      location.replace("#{location.origin}#{_next}")

      expect(listener.onChange).toHaveBeenCalled()
      expect(listener.onChange.calls.length).toEqual(1)

      expect(listener.onInternalChange).not.toHaveBeenCalled()

      expect(listener.onUserChange).toHaveBeenCalled()
      expect(listener.onUserChange.calls.length).toEqual(1)

      router.removeEventListener KazitoriEvent.CHANGE, listener.onChange
      router.removeEventListener KazitoriEvent.INTERNAL_CHANGE, listener.onChange
      router.removeEventListener KazitoriEvent.USER_CHANGE, listener.onChange

      router.change("#{_next}")
      location.replace("#{location.origin}#{_next}")

      listener.onChange.reset()
      listener.onInternalChange.reset()
      listener.onUserChange.reset()

      expect(listener.onChange).not.toHaveBeenCalled()
      expect(listener.onInternalChange).not.toHaveBeenCalled()
      expect(listener.onUserChange).not.toHaveBeenCalled()

      #タスクキューが空になった
      #KazitoriEvent.TASK_QUEUE_COMPLETE

      #タスクキューが中断された
      #KazitoriEvent.TASK_QUEUE_FAILD

      #ユーザーアクション以外で URL の変更があった
      #KazitoriEvent.INTERNAL_CHANGE

      #ユーザー操作によって URL が変わった時
      #KazitoriEvent.USER_CHANGE

      #KazitoriEvent.REJECT

    prevHandler = jasmine.createSpy('PREV Event')

    it "should dispatch prev event when kazitori omokazied", ->
      router.addEventListener KazitoriEvent.PREV, prevHandler
      router.omokazi()
      expect(prevHandler).toHaveBeenCalled()
      expect(prevHandler.calls.length).toEqual(1)

    it "should not call handler when PREV event listener removed", ->
      router.removeEventListener KazitoriEvent.PREV, prevHandler
      prevHandler.reset()
      router.omokazi()
      expect(prevHandler).not.toHaveBeenCalled()
      router.torikazi()

    nextHandler = jasmine.createSpy('NEXT Event')

    it "should dispatch prev event when kazitori torikazied", ->

      router.addEventListener KazitoriEvent.NEXT, nextHandler
      router.torikazi()
      expect(nextHandler).toHaveBeenCalled()
      expect(nextHandler.calls.length).toEqual(1)

    it "should not call handler when NEXT event listener removed", ->
      router.removeEventListener KazitoriEvent.NEXT, nextHandler
      nextHandler.reset()
      router.torikazi()
      expect(nextHandler).not.toHaveBeenCalled()

    notFoundHandler = jasmine.createSpy('NOT_FOUND Event')

    it "should dispatch not_found event when kazitori router undefined", ->
      router.addEventListener KazitoriEvent.NOT_FOUND, notFoundHandler
      router.change("/hageeeeeee")
      expect(notFoundHandler).toHaveBeenCalled()
      expect(notFoundHandler.calls.length).toEqual(1)

    it "should not call handler when NEXT event listener removed", ->
      router.removeEventListener KazitoriEvent.NOT_FOUND, notFoundHandler
      notFoundHandler.reset()
      router.change("/hogeeeeeee")
      expect(notFoundHandler).not.toHaveBeenCalled()

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

    # beforeEach ->

    it 'index should be called', ->
      spyOn(controller, 'index')
      router.change('/posts')
      expect(controller.index).toHaveBeenCalled()

    it 'show should be called', ->
      spyOn(controller, 'show')
      router.change('/posts/1')
      expect(controller.show).toHaveBeenCalled()

    it 'show should be called with casted argments', ->
      spyOn(controller, 'show')
      router.change('/posts/32941856')
      expect(controller.show).toHaveBeenCalledWith(32941856)

    it 'befores should be before called', ->
      spyOn(controller, 'beforeShow')
      router.change('/posts/1')
      expect(controller.beforeShow).toHaveBeenCalled()

    it 'show should be called with casted argments', ->
      spyOn(controller, 'beforeShow')
      router.change('/posts/32941856')
      expect(controller.beforeShow).toHaveBeenCalledWith(32941856)

    it 'beforeAny should be before called', ->
      spyOn(controller, 'beforeAny')
      router.change('/posts')
      expect(controller.beforeAny).toHaveBeenCalled()
      router.change('/posts/1')
      expect(controller.beforeAny).toHaveBeenCalled()

  # describe "Asynchronous specs", ->
  #   value = null
  #   flag = null

  #   it "should support async execution of test preparation and exepectations", ->

  #     runs ->
  #       flag = false
  #       value = 0

  #       setTimeout ->
  #         flag = true
  #       , 500

  #     waitsFor ->
  #       value++
  #       flag
  #     , "The Value should be incremented", 750

  #     runs ->
  #       expect(value).toBeGreaterThan(0)
