view =
  showEntry: (id) ->
    # console.log "view.showEntry"

controller =
  beforeAny: ->
    # console.log 'controller.beforeAny'
  beforeShow: (id) ->
    # console.log 'controller.beforeShow'
  index: ->
    # console.log 'controller.index'
  show: (id) ->
    # console.log "controller.show"
  search: ->
    # console.log "controller.search"
  showEntry: (id) ->
    # console.log "controller.showEntry"
    view.showEntry(id)

childController =
  beforeAny: ->
    # console.log 'childController.beforeAny'
  beforeShow: (id) ->
    # console.log 'childController.beforeShow'
  index: ->
    # console.log 'childController.index'
  show: (id) ->
    # console.log "childController.show"

class Child extends Kazitori
  root: "/child"
  beforeAnytime: ["beforeAnyChild"]
  befores:
    '/': ['beforeIndex']
    '/<int:id>': ['beforeShow']

  routes:
    '/': 'index'
    '/<int:id>': 'show'

  index: ->
    childController.index()

  show: (id)->
    childController.show()

  beforeAnyChild: ->
    childController.beforeAny()

  beforeShow: (id)->
    childController.beforeShow()

class ChildAppend extends Kazitori
  root: "/appender"
  beforeAnytime: ["beforeAny"]
  befores:
    '/': ['beforeIndex']
    '/<int:id>': ['beforeShow']

  routes:
    '/': 'index'
    '/<int:id>': 'show'

  index: ->
    childController.index()

  show: (id)->
    childController.show()

  beforeAny: ->
    childController.beforeAny()

  beforeShow: (id)->
    childController.beforeShow()

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
    '/users/<int:id>/posts/<int:id>': 'show'
    '/entries/<int:id>': controller.showEntry
    '/child': Child

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



describe "Kazitori", ->

  beforeEach ->
    # console.log '_beforeEach'
    router.change('/')

  afterEach ->
    # console.log '^-afterEach'
    router.change('/')

  describe "property", ->

    it "should started to be Truthy", ->
      expect(router.started).toBeTruthy()

    it "should router.started to be Falsy when router.stop called", ->
      router.stop()
      expect(router.started).toBeFalsy()
      router.start()

    it "test getHash", ->
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

  describe "method", ->
    it "should work suspend and resume", ->
      router.suspend()
      expect(router.started).toBeFalsy()
      router.resume()
      expect(router.started).toBeTruthy()

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

      expect(startHandler.calls.count()).toEqual(1)

    it "should not call handler when START event listener removed", ->

      router.removeEventListener KazitoriEvent.START, startHandler
      startHandler.calls.reset()
      router.stop()
      router.start()
      expect(startHandler).not.toHaveBeenCalled()

    stopHandler = jasmine.createSpy('STOP event')

    it "should dispatch stop event when kazitori stoped", ->
      router.addEventListener KazitoriEvent.STOP, stopHandler
      router.stop()
      expect(stopHandler).toHaveBeenCalled()

    it "should dispatch stop event once", ->
      expect(stopHandler.calls.count()).toEqual(1)

    it "should not call handler when STOP event listener removed", ->
      router.removeEventListener KazitoriEvent.STOP, stopHandler
      stopHandler.calls.reset()
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
      expect(listener.onChange.calls.count()).toEqual(1)

      expect(listener.onInternalChange).toHaveBeenCalled()
      expect(listener.onInternalChange.calls.count()).toEqual(1)

      expect(listener.onUserChange).not.toHaveBeenCalled()

      listener.onChange.reset()
      listener.onInternalChange.reset()
      listener.onUserChange.reset()
      location.replace("#{location.origin}#{_prev}")
      location.replace("#{location.origin}#{_next}")

      expect(listener.onChange).toHaveBeenCalled()
      expect(listener.onChange.calls.count()).toEqual(1)

      expect(listener.onInternalChange).not.toHaveBeenCalled()

      expect(listener.onUserChange).toHaveBeenCalled()
      expect(listener.onUserChange.calls.count()).toEqual(1)

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

    rejectHandler = jasmine.createSpy('REJECT Event')

    it "should dispatch REJECT event when kazitori rejected", ->
      router.addEventListener KazitoriEvent.REJECT, rejectHandler
      router.reject()
      expect(rejectHandler).toHaveBeenCalled()
      expect(rejectHandler.calls.count()).toEqual(1)

    prevHandler = jasmine.createSpy('PREV Event')

    it "should dispatch PREV event when kazitori omokazied", ->
      router.addEventListener KazitoriEvent.PREV, prevHandler
      router.omokazi()
      expect(prevHandler).toHaveBeenCalled()
      expect(prevHandler.calls.count()).toEqual(1)

    it "should not call handler when PREV event listener removed", ->
      router.removeEventListener KazitoriEvent.PREV, prevHandler
      prevHandler.calls.reset()
      router.omokazi()
      expect(prevHandler).not.toHaveBeenCalled()

    nextHandler = jasmine.createSpy('NEXT Event')

    it "should dispatch NEXT event when kazitori torikazied", ->
      router.change('/posts/1')
      router.omokazi()

      router.addEventListener KazitoriEvent.NEXT, nextHandler
      router.torikazi()
      expect(nextHandler).toHaveBeenCalled()
      expect(nextHandler.calls.count()).toEqual(1)

    it "should not call handler when NEXT event listener removed", ->
      router.change('/posts/1')
      router.omokazi()
      nextHandler.calls.reset()

      router.removeEventListener KazitoriEvent.NEXT, nextHandler
      router.torikazi()
      expect(nextHandler).not.toHaveBeenCalled()

    notFoundHandler = jasmine.createSpy('NOT_FOUND Event')

    it "should dispatch not_found event when kazitori router undefined", ->
      router.addEventListener KazitoriEvent.NOT_FOUND, notFoundHandler
      router.change("/hageeeeeee")
      expect(notFoundHandler).toHaveBeenCalled()
      expect(notFoundHandler.calls.count()).toEqual(1)

    it "should not call handler when NEXT event listener removed", ->
      router.removeEventListener KazitoriEvent.NOT_FOUND, notFoundHandler
      notFoundHandler.calls.reset()
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

  describe "router", ->

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

    it 'should call controller method directly', ->
      spyOn(view, 'showEntry')
      router.change('/entries/123')
      expect(view.showEntry).toHaveBeenCalled()

    it 'should call controller method directly with casted argments', ->
      spyOn(view, 'showEntry')
      router.change('/entries/12495876')
      expect(view.showEntry).toHaveBeenCalledWith(12495876)

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

    it 'should navigate to root when router.change undefined path', ->
      spyOn(controller, 'beforeShow')
      router.change('/blahblahblah')
      expect(window.location.pathname).toBe('/')

    it 'should match route /', ->
      matcher = router.match('/')
      expect(matcher).toBeTruthy()

    it 'should match route /posts', ->
      matcher = router.match('/posts')
      expect(matcher).toBeTruthy()

    it 'should match route /posts/2221', ->
      matcher = router.match('/posts/2221')
      expect(matcher).toBeTruthy()

    it 'should match route /users/24233/posts/874324', ->
      matcher = router.match('/users/24233/posts/874324')
      expect(matcher).toBeTruthy()

    it 'should not match route /posts/blaf', ->
      matcher = router.match('/posts/blaf')
      expect(matcher).toBeFalsy()

    it 'should not match route /users/blaf/posts/874324', ->
      matcher = router.match('/users/blaf/posts/874324')
      expect(matcher).toBeFalsy()

    it 'should not match route /users/blaf/posts/blafblaf', ->
      matcher = router.match('/users/blaf/posts/blafblaf')
      expect(matcher).toBeFalsy()

    it 'should params [349857] when change(/posts/349857)', ->
      router.change('/posts/349857')
      expect(router.params[0]).toBe(349857)

    it 'should params [893473,219834] when change(/posts/349857)', ->
      router.change('/users/893473/posts/219834')
      expect(router.params[0]).toBe(893473)
      expect(router.params[1]).toBe(219834)

    it 'should queries {hoge:"hogeee"} when change(/?hoge=hogeee)', ->
      router.change('/?hoge=hogeee')
      expect(router.queries.hoge).toBe("hogeee")

    it 'should queries {hoge:"hogeee"} when change(/posts/123?hoge=hogeee)', ->
      router.change('/posts/123?hoge=hogeee')
      expect(router.queries.hoge).toBe("hogeee")

  describe "exception", ->
    it "should throw error when Kazitori started and router.start called", ->
      expect(router.started).toBeTruthy()
      expect(router.start).toThrow()

  describe "nest", ->
    it 'should call nest router controller', ->
      spyOn(childController, 'index')
      router.change('/child')
      expect(childController.index).toHaveBeenCalled()

    it 'should call nest router controller show', ->
      spyOn(childController, 'show')
      router.change('/child/1')
      expect(childController.show).toHaveBeenCalled()

    it 'child befores should be before called', ->
      spyOn(childController, 'beforeShow')
      router.change('/child/1')
      expect(childController.beforeShow).toHaveBeenCalled()

    it 'child beforeAny should be before called', ->
      spyOn(childController, 'beforeAny')
      #ここの挙動どうしようかな…
      #まんま bind するのと、/child 配下だった時だけ動作するの…
      router.change('/posts')
      expect(childController.beforeAny).toHaveBeenCalled()
      router.change('/child/1')
      expect(childController.beforeAny).toHaveBeenCalled()


  describe "dynamic nest", ->

    it 'should append router from constructor', ->
      spyOn(childController, 'index')
      router.appendRouter ChildAppend, '/appender'
      router.change('/appender')
      expect(childController.index).toHaveBeenCalled()

    it 'should append router from instance', ->
      spyOn(childController, 'index')
      child = new ChildAppend({'isAutoStart': false})
      router.appendRouter child, '/appender'
      router.change('/appender')
      expect(childController.index).toHaveBeenCalled()

    notFoundHandler = jasmine.createSpy('NOT_FOUND Event')

    it 'should remove router from constructor', ->
      spyOn(childController, 'index')
      router.appendRouter ChildAppend
      router.change('/appender')
      expect(childController.index).toHaveBeenCalled()

      #jasmine を置き去りにした…！
      # router.addEventListener KazitoriEvent.NOT_FOUND, notFoundHandler
      # router.removeRouter ChildAppend
      # router.change('/appender')

      # expect(notFoundHandler).toHaveBeenCalled()
      # expect(notFoundHandler.calls.count()).toEqual(1)

    it 'shuold remove router from instance', ->
      spyOn(childController, 'index')
      child = new ChildAppend({'isAutoStart': false})
      router.appendRouter child
      router.change('/appender')
      expect(childController.index).toHaveBeenCalled()


      router.addEventListener KazitoriEvent.NOT_FOUND, notFoundHandler
      router.removeRouter childController
      router.change('/appender')

      # expect(notFoundHandler).toHaveBeenCalled()
      # expect(notFoundHandler.calls.count()).toEqual(1)

  describe "silent", ->
    it 'shuold call show and not change location', ->
      spyOn(controller, 'show')
      router.silent = true
      expect(window.location.pathname).toEqual "/"
      router.change('/posts/1')
      expect(controller.show).toHaveBeenCalled()
      expect(window.location.pathname).toEqual "/"
      expect(router.fragment).toEqual "/posts/1"
      router.silent = false
      router.change('/posts/2')
      expect(window.location.pathname).toEqual "/posts/2"






@d = new Deffered()

describe "Deffered", ->

  defferedSpy = jasmine.createSpy('defferedSpy')
  chaninedDefferedSpy = jasmine.createSpy('chaninedDefferedSpy')
  defferedSpy2 = jasmine.createSpy('defferedSpy2')
  taskQueueCompleteHandler = jasmine.createSpy('TASK_QUEUE_COMPLETE Event')
  taskQueueFailedHandler = jasmine.createSpy('TASK_QUEUE_FAILED Event')

  d.addEventListener KazitoriEvent.TASK_QUEUE_COMPLETE, taskQueueCompleteHandler
  d.addEventListener KazitoriEvent.TASK_QUEUE_FAILED, taskQueueFailedHandler

  beforeEach ->
    defferedSpy.calls.reset()
    chaninedDefferedSpy.calls.reset()
    defferedSpy2.calls.reset()
    taskQueueFailedHandler.calls.reset()
    taskQueueCompleteHandler.calls.reset()

  afterEach ->

  it 'should excecute method', ->
    d.deffered (d)->
      defferedSpy()

    d.execute(d)

    expect(defferedSpy).toHaveBeenCalled()

  it 'should excecute chanined methods', ->
    d.deffered (d)->
      defferedSpy()
      d.execute(d)
    .deffered (d)->
      chaninedDefferedSpy()
    d.execute(d)
    expect(defferedSpy).toHaveBeenCalled()
    expect(chaninedDefferedSpy).toHaveBeenCalled()

  it 'should excecute method directly', ->
    d.deffered defferedSpy2
    d.execute(d)

    return


  # it 'should dispatch TASK_QUEUE_FAILD envet when defferd completed', ->
  it 'should dispatch TASK_QUEUE_COMPLETE envet when defferd completed', ->
    complete = false
    # console.log runs
    # runs ->
    #   d.deffered (d)->
    #     complete = true
    #     return
    #   return

    # waitsFor ->
    #   d.execute(d)
    #   return complete

    # runs ->
    #   expect(taskQueueCompleteHandler).toHaveBeenCalled()
    #   return
    return

  it 'should dispatch TASK_QUEUE_FAILED envet when defferd.reject called', ->
    d.deffered (d)->
      d.reject()

    d.execute(d)
    expect(taskQueueFailedHandler).toHaveBeenCalled()
    return
  return
