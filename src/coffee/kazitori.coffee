# pushState をいい感じに捌けるルーターライブラリ
# pushState を使ったコンテンツで必要なことはひと通り出来るはず。
#
#----------------------------------------------

#### Copyrights
# (c) 2013 Eikichi Yamaguchi
# kazitori.js may be freely distributed under the MIT license.
# http://dev.hageee.net

# inspired from::
#     (c) 2010-2012 Jeremy Ashkenas, DocumentCloud Inc.
#     Backbone may be freely distributed under the MIT license.
#     For all details and documentation:
#     http://backbonejs.org
#
#----------------------------------------------


#delegate
delegater = (target, func)->
  return ()->
    func.apply(target, arguments)

#regexps
trailingSlash = /\/$/
routeStripper = /^[#\/]|\s+$/g
escapeRegExp = /[\-{}\[\]+?.,\\\^$|#\s]/g
namedParam = /<(\w+|[A-Za-z_]+:\w+)>/g
genericParam = /([A-Za-z_]+):(\w+)/

optionalParam = /\((.*?)\)/g
splatParam = /\*\w+/g

#--------------------------------------------

###URL 変数に対して指定できる型###
# **Default:**
#
# * int : Number としてキャストされます
# * string : String としてキャストされます
#

VARIABLE_TYPES = [
  {
    name:"int"
    cast:Number
  },
  {
    name:"string"
    cast:String
  }
]

#--------------------------------------------

## Kazitori クラス
class Kazitori
  VERSION:"0.2.1"
  history:null
  location:null
  handlers:[]
  beforeHandlers:[]
  afterhandlers:[]
  rootFiles: ['index.html', 'index.htm', 'index.php', 'unko.html']
  root:null
  notFound:null
  beforeAnytimeHandler:null
  direct:null
  ###beforeFailedHandler ###
  # before 処理が失敗した時に実行されます。
  # デフォルトでは空の function になっています。
  #
  #--------------------------------------------
  beforeFailedHandler:()->
    return



  ###isBeforeForce###
  isBeforeForce:false

  isNotFoundForce:false
  _notFoudn:null

  breaker:{}

  _dispatcher:null
  _beforeDeffer:null

  fragment:null
  lastFragment:null
  isUserAction:false

  _isFirstRequest:true






  constructor:(options)->
    @.options = options || (options = {})

    if options.routes
      @.routes = options.routes
    
    @.root = if options.root then options.root else '/'

    #見つからなかった時強制的に root を表示する
    # @.notFound = if options.notFound then options.notFound else @.root
    if @.notFound is null
      @.notFound = if options.notFound then options.notFound else @.root

    win = window
    if typeof win != 'undefined'
      @.location = win.location
      @.history = win.history
    docMode = document.docmentMode
    @isOldIE = (win.navigator.userAgent.toLowerCase().indexOf('msie') != -1) and (!docMode||docMode < 7)
    @_dispatcher = new EventDispatcher()
    @_bindBefores()
    @_bindRules()
    @_bindNotFound()

    if not @.options.isAutoStart? or @.options.isAutoStart != false
      @start()
    return


  #開始する
  start:(options)->
    if Kazitori.started
      throw new Error('mou hazim matteru')
    Kazitori.started = true
    win = window
    @.options = @_extend({}, {root:'/'}, @.options, options)
    @._hasPushState = !!(@.history and @.history.pushState)
    @._wantChangeHash = @.options.hashChange isnt false
    fragment = @.fragment = @getFragment()

    atRoot = @.location.pathname.replace(/[^\/]$/, '$&/') is @.root

    if @isOldIE and @._wantChangeHash
      frame = document.createElement("iframe")
      frame.setAttribute("src","javascript:0")
      frame.setAttribute("tabindex", "-1")
      frame.style.display = "none"
      document.body.appendChild(frame)
      @.iframe = frame.contentWindow
      @change(fragment)

    @._addPopStateHandler()

    if @._hasPushState and atRoot and @.location.hash
      @.fragment = @.lastFragment = @.getHash().replace(routeStripper, '')
      @.history.replaceState({}, document.title, @.root + @.fragment + @.location.search)
    #スタートイベントをディスパッチ
    @._dispatcher.dispatchEvent( new KazitoriEvent( KazitoriEvent.START, @.fragment ))
    if !@.options.silent
      override = @.root
      if not @._hasPushState and atRoot
        override = @.root + @.fragment.replace(routeStripper, '')
      else if not atRoot
        override = @.fragment
      return  @loadURL(override)


  #止める
  stop:()->
    win = window
    win.removeEventListener 'popstate', @observeURLHandler
    win.removeEventListener 'hashchange', @observeURLHandler
    Kazitori.started = false
    #ストップイベントをディスパッチ
    @._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.STOP, @.fragment))

  ## torikazi
  # ヒストリーネクストを実行します。
  torikazi:(options)->
    return @direction(options, "next")

  ## omokazi
  # ヒストリーバックを実行します
  omokazi:(options)->
    return @direction(options, "prev")

  direction:(option, direction)->
    if not Kazitori.started
      return false

    tmpFrag = @.lastFragment
    @.lastFragment = @getFragment()
    @.direct = direction
    @.isUserAction = true
    @._removePopStateHandler()
    if direction is "prev"
      @.history.back()
      @._dispatcher.dispatchEvent( new KazitoriEvent( KazitoriEvent.PREV, tmpFrag, @.lastFragment ))
    else if direction is "next"
      @.history.forward()
      @._dispatcher.dispatchEvent( new KazitoriEvent( KazitoriEvent.NEXT, tmpFrag, @.lastFragment ))
    else
      return
    @._addPopStateHandler()
    return @loadURL(tmpFrag)


  #url を変更する
  change:(fragment, options)->
    if not Kazitori.started
      return false
    prev = @.fragment
    if not options
      options = {'trigger':options}

    #TODO : @ に突っ込んじゃうとこのあと全部 BeforeForce されてまう
    @.isBeforeForce = options.isBeforeForce isnt false
    frag = @getFragment(fragment || '')
    if @.fragment is frag
      return
    @.lastFragment = @.fragment
    @.fragment = frag
    next = @.fragment
    
    url = @.root + frag.replace(routeStripper, '')
    
    matched = @_matchCheck(@.fragment, @.handlers)
    if matched is false and @.isNotFoundForce is false
      if @.notFound isnt null
        @._notFound.callback(@.fragment)
        url = @.root + @._notFound.rule.replace(routeStripper, '')
        @.history[ if options.replace then 'replaceState' else 'pushState' ]({}, document.title, url)
      @._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.NOT_FOUND))
      return
    if @._hasPushState
      @.history[ if options.replace then 'replaceState' else 'pushState' ]({}, document.title, url)
    else if @._wantChangeHash
      @_updateHash(@.location, frag, options.replace)
      if @.iframe and (frag isnt @getFragment(@getHash(@.iframe)))
        if !options.replace
          @.iframe.document.open().close()
        @_updateHash(@.iframe.location, frag, options.replace)
    else
      return @.location.assign(url)

    #イベントディスパッチ
    @dispatchEvent(new KazitoriEvent(KazitoriEvent.CHANGE, next, prev))
    if options.internal and options.internal is true
      @._dispatcher.dispatchEvent( new KazitoriEvent(KazitoriEvent.INTERNAL_CHANGE, next, prev))
    @loadURL(frag, options)
    return

  #pushState ではなく replaceState で処理する
  replace:(fragment, options)->
    if not options
      options = {replace:true}
    else if not options.replace or options.replace is false
      options.replace = true
    @change(framgent, options)
    return

  #中断する
  #メソッド名 intercept のほうがいいかな
  reject:()->
    @dispatchEvent(new KazitoriEvent(KazitoriEvent.REJECT, @.fragment))
    @._beforeDeffer.removeEventListener KazitoriEvent.TASK_QUEUE_COMPLETE, @beforeComplete
    @._beforeDeffer.removeEventListener KazitoriEvent.TASK_QUEUE_FAILED, @beforeFailed
    @._beforeDeffer = null
    return
    
  registerHandler:(rule, name, isBefore, callback )->
    if not callback
      if isBefore
        callback = @_bindFunctions(name)
      else if typeof name is "function"
        callback = name
      else
        callback = @[name]

    target = if isBefore then @.beforeHandlers else @.handlers
    target.unshift new Rule(rule, (fragment)->
      args = @_extractParams(fragment)
      args = @_getCastedParams(args)
      callback && callback.apply(@.router, args)
    ,@)
    return @

  #URL を読み込む
  loadURL:(fragmentOverride, options)->
    fragment = @.fragment = @getFragment(fragmentOverride)
    
    if @.beforeAnytimeHandler or @.beforeHandlers.length > 0
      @._beforeDeffer = new Deffered()
      if @.beforeAnytimeHandler?
        @._beforeDeffer.deffered((d)=>
          @.beforeAnytimeHandler.callback(fragment)
          d.execute(d)
          return
        )
      
      matched = @._matchCheck(fragment, @.beforeHandlers)
      for handler in matched
        @._beforeDeffer.deffered((d)->
          handler.callback(fragment)
          d.execute(d)
          return
          )

      @._beforeDeffer.addEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, @beforeComplete)
      @._beforeDeffer.addEventListener(KazitoriEvent.TASK_QUEUE_FAILED, @beforeFailed)
      @._beforeDeffer.execute(@._beforeDeffer)
    else
      @executeHandlers()
    return

  #指定した URL に対応した handler が設定されているかどうかチェック
  match:(fragment)->
    matched = @._matchCheck(fragment, @.handlers)
    return matched.length > 0


    
  #before で登録した処理が無難に終わった
  beforeComplete:(event)=>
    @._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, @beforeComplete)
    @._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_FAILED, @beforeFailed)
    
    @._dispatcher.dispatchEvent( new KazitoriEvent(KazitoriEvent.BEFORE_EXECUTED, @.fragment, @.lastFragment))

    @executeHandlers()
    return
  
  #routes で登録されたメソッドを実行
  executeHandlers:()=>
    #毎回 match チェックしてるので使いまわしたいのでリファクタ
    matched = @._matchCheck(@.fragment, @.handlers)
    isMatched = true
    if matched is false or matched.length < 1
      if @.notFound isnt null
        @._notFound.callback(@.fragment)
      isMatched = false
      @._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.NOT_FOUND))

    else if matched.length > 1
      console.log "too many matched..."
    else
      for handler in matched
        handler.callback(@.fragment)

    if @._isFirstRequest
      #間に合わないので遅延させて発行
      setTimeout ()=>
        @._dispatcher.dispatchEvent( new KazitoriEvent(KazitoriEvent.FIRST_REQUEST, @.fragment, null))
        if isMatched
          @._dispatcher.dispatchEvent( new KazitoriEvent(KazitoriEvent.EXECUTED, @.fragment, null))
      ,0
      @._isFirstRequest = false
    else
      if isMatched
        @._dispatcher.dispatchEvent( new KazitoriEvent(KazitoriEvent.EXECUTED, @.fragment, @.lastFragment))
    
    return matched

  

  beforeFailed:(event)=>
    @.beforeFailedHandler.apply(@, arguments)
    @._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_FAILED, @beforeFailed)
    @._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, @beforeComplete)
    if @isBeforeForce
      @beforeComplete()
    @._beforeDeffer = null
    return


  #URL の変更を監視
  observeURLHandler:(event)=>
    current = @getFragment()
    if current is @.fragment and @.iframe
      current = @getFragment(@getHash(@.iframe))
    if current is @.fragment
      return false
    if @.iframe
      @change(current)
    if @.lastFragment is current and @.isUserAction is false
      @._dispatcher.dispatchEvent( new KazitoriEvent( KazitoriEvent.PREV, current, @.fragment ))
    else if @.lastFragment is @.fragment and @.isUserAction is false
      @._dispatcher.dispatchEvent( new KazitoriEvent( KazitoriEvent.NEXT, current, @.lastFragment ))
    @.isUserAction = false
    @._dispatcher.dispatchEvent( new KazitoriEvent( KazitoriEvent.CHANGE, current, @.lastFragment ))
    return @loadURL(current)


  # routes から指定されたルーティングをバインド
  _bindRules:()->
    if not @.routes?
      return
    routes = @_keys(@.routes)
    for rule in routes
      @registerHandler(rule, @.routes[rule],false)
    return

  # befores から指定された事前に処理したいメソッドをバインド
  _bindBefores:()->
    if not @.befores?
      return
    befores = @_keys(@.befores)
    for key in befores
      @registerHandler(key, @.befores[key], true)

    if @.beforeAnytime
      callback = @_bindFunctions(@.beforeAnytime)
      @.beforeAnytimeHandler = {
        callback:@_binder (fragment)->
          args = [fragment]
          callback && callback.apply(@, args)
        ,@
      }
    return

  # notFound で指定されたメソッドをバインド
  _bindNotFound:()->
    if not @.notFound?
      return
    if typeof @.notFound is "string"
      for rule in @.handlers
        if rule.rule is '/' + @.notFound.replace(@.root, '')
          @._notFound = rule
          return
    else
      notFoundFragment = @_keys(@.notFound)[0]

    notFoundFuncName = @.notFound[notFoundFragment]
    
    if typeof notFoundFuncName is "function"
      callback = notFoundFuncName
    else
      callback = @[notFoundFuncName]

    @._notFound = new Rule(notFoundFragment, (fragment)->
      args = @_extractParams(fragment)
      args = @_getCastedParams(args)
      callback && callback.apply(@.router, args)
    ,@)
    return




  _updateHash:(location, fragment, replace)->
    if replace
      href = location.href.replace /(javascript:|#).*$/, ''
      location.replace href + '#' + fragment
    else
      location.hash = "#" + fragment
    return

  #マッチする URL があるかどうか
  # memo : 20130130
  # ここでここまでのチェックを実際に行うなら
  # loadURL, executeHandler 内で同じチェックは行う必要がないはずなので
  # それぞれのメソッドが簡潔になるようにリファクタする必要がある
  _matchCheck:(fragment, handlers)->
    matched = []
    for handler in handlers
      if handler.rule is fragment
        matched.push handler
      else if handler.test(fragment)
        if handler.isVariable and handler.types.length > 0
          #型チェック用
          args = handler._extractParams(fragment)
          argsMatch = []
          len = args.length
          i = 0

          while i < len
            a = args[i]
            t = handler.types[i]
            if typeof a isnt "object"
              if t is null or @_typeCheck(a,t) is true
                argsMatch.push true
            i++
          if not false in argsMatch
            matched.push handler
        else
          matched.push handler
    return if matched.length > 0 then matched else false




  #===============================================
  #
  # URL Queries
  #
  #==============================================

  # URL ルート以下を取得
  getFragment:(fragment)->
    if not fragment?
      if @._hasPushState or !@._wantChangeHash
        fragment = @.location.pathname
        matched = false
        frag = fragment
        if frag.match(/^\//)
          frag = frag.substr(1)
        root = @.root
        if root.match(/^\//)
          root = root.substr(1)
        for index in @.rootFiles
          if index is frag or root + index is frag
            matched = true

        if matched
          fragment = @.root
        fragment = fragment + @.location.search
        root = @.root.replace(trailingSlash, '')
        if not fragment.indexOf(root)
          fragment = fragment.substr(root.length)
      else
        fragment = @getHash()
    return fragment


  # URL の # 以降を取得
  getHash:()->
    match = (window || @).location.href.match(/#(.*)$/)
    if match?
      return match[1]
    else
      return ''

  #===============================================
  #
  # Event
  #
  #==============================================

  addEventListener:(type, listener)->
    @_dispatcher.addEventListener(type, listener)

  removeEventListener:(type, listener)->
    @_dispatcher.removeEventListener(type, listener)

  dispatchEvent:(event)->
    @_dispatcher.dispatchEvent(event)


  _addPopStateHandler:()->
    win = window
    if @._hasPushState is true
      win.addEventListener 'popstate', @observeURLHandler
    if @._wantChangeHash is true and ('onhashchange' in win) and not @.isOldIE
      win.addEventListener 'hashchange', @observeURLHandler

  _removePopStateHandler:()->
    win = window
    win.removeEventListener 'popstate', @observeURLHandler
    win.removeEventListener 'hashchange', @observeURLHandler


  #==============================================
  #
  # utils
  #
  #==============================================

  _slice: Array.prototype.slice

  _keys: Object.keys || (obj)->
    if obj is not Object(obj)
      throw new TypeError('object ja nai')
    keys = []
    for key of obj
      if Object.hasOwnProperty.call(obj, key)
        keys[keys.length] = key
    return keys


  _binder:(func, obj)->
    slice = @_slice
    args = slice.call(arguments, 2)
    return ()->
      return func.apply(obj||{},args.concat(slice.call(arguments)))


  _extend:(obj)->
    @_each( @_slice.call(arguments,1), (source)->
      if source
        for prop of source
          obj[prop] = source[prop]
      )
    return obj


  _each:(obj, iter, ctx)->
    if not obj?
      return
    each = Array.prototype.forEach
    if each && obj.forEach is each
      obj.forEach(iter, ctx)
    else if obj.length is +obj.length
      i = 0
      l = obj.length
      while i < l
        if iter.call(ctx, obj[i], i, obj ) is @breaker
          return
        i++
    else
      for k of obj
        if k in obj
          if iter.call(ctx, obj[k], k, obj) is @breaker
            return

  _bindFunctions:(funcs)->
    if typeof funcs is 'string'
      funcs = funcs.split(',')
    bindedFuncs = []
    for funcName in funcs
      func = @[funcName]
      if not func?
        names = funcName.split('.')
        if names.length > 1
          f = window[names[0]]
          i = 1
          len = names.length
          while i < len
            newF = f[names[i]]
            if newF?
              f = newF
              i++
            else
              break
          func = f
        else
          func = window[funcName]

      if func?
        bindedFuncs.push(func)
    callback =(args)->
      for func in bindedFuncs
        func.apply(@, [args])
      return
    return callback

  _typeCheck:(a,t)->
    matched = false
    for type in VARIABLE_TYPES
      if t.toLowerCase() is type.name
        if type.cast(a)
          matched = true
    return matched


## Rule
# URL を定義する Rule クラス
# ちょっと大げさな気もするけど外部的には変わらんし
# 今後を見据えてクラス化しておく
class Rule
  rule:null
  _regexp:null
  callback:null
  name:""
  router:null
  isVariable:false
  types:[]
  constructor:(string, callback, router)->
    @rule = string
    @callback = callback
    @_regexp = @_ruleToRegExp(string)

    #これ…どうなんだろ…
    @router = router
    @types = []

    re = new RegExp(namedParam)
    matched = string.match(re)
    if matched isnt null
      @isVariable = true
      for m in matched
        t = m.match(genericParam)||null
        @types.push if t isnt null then t[1] else null

  #マッチするかどうかテスト
  # **args**
  # fragment : テスト対象となる URL
  # **return**
  # Boolean : テスト結果の真偽値
  test:(fragment)->
    return @_regexp.test(fragment)

  #URL パラメータを分解
  _extractParams:(fragment)->
    param = @_regexp.exec(fragment)
    if param?
      newParam = param.slice(1)
      last = param[param.length - 1]
      if last.indexOf('?') > -1
        newQueries = []
        queries = last.split('?')[1]
        queryParams = queries.split('&')
        for query in queryParams
          kv = query.split('=')
          k = kv[0]
          v = if kv[1] then kv[1] else ""
          if v.indexOf('|') > -1
            v = v.split("|")
          obj = {}
          obj[k] = v
          newQueries.push obj
        newParam.pop()
        newParam.push last.split('?')[0]
        newParam.push {"queries":newQueries}
      return newParam
    else
      return null

  #パラメーターを指定された型でキャスト
  _getCastedParams:(params)->
    i = 0
    if not params
      return params
    len = params.length
    castedParams = []
    while i < len
      if @types[i] is null
        castedParams.push params[i]
      else if typeof params[i] is "object"
        castedParams.push params[i]
      else
        for type in VARIABLE_TYPES
          if @types[i] is type.name
            castedParams.push type.cast(params[i])
      i++
    return castedParams

  _ruleToRegExp:(rule)->
    newRule = rule.replace(escapeRegExp, '\\$&')
    newRule = newRule.replace(optionalParam, '(?:$1)?')
    newRule = newRule.replace(namedParam, '([^\/]+)')
    newRule = newRule.replace(splatParam, '(.*?)')
    return new RegExp('^' + newRule + '$')




class EventDispatcher
  listeners:{}
  addEventListener:(type, listener)->
    if @listeners[ type ] is undefined
      @listeners[ type ] =[]

    if @listeners[type].indexOf listener is -1
      @listeners[type].push listener
    return

  removeEventListener:(type, listener)->
    len = 0
    for prop of @listeners
      len++
    if len < 1
      return
    arr = @listeners[type]
    if not arr
      return
    i = 0
    len = arr.length
    while i < len
      if arr[i] is listener
        if len is 1
          delete @listeners[type]
        else arr.splice(i,1)
        break
      i++
    return

  dispatchEvent:(event)->
    ary = @listeners[ event.type ]
    if ary isnt undefined
      event.target = @

      for handler in ary
        handler.call(@, event)
    return

## Deffered
# **internal**
# before を確実に処理するための簡易的な Deffered クラス
class Deffered extends EventDispatcher
  queue : []

  constructor:()->
    @queue = []
  
  deffered:(func)->
    @queue.push func
    return @

  execute:()->
    try
      task = @queue.shift()
      if task
        task.apply(@, arguments)
      if @queue.length < 1
        @queue = []
        @.dispatchEvent(new KazitoriEvent(KazitoriEvent.TASK_QUEUE_COMPLETE))
    catch error
      @reject(error)

  reject:(error)->
    message = if not error then "user reject" else error
    @dispatchEvent({type:KazitoriEvent.TASK_QUEUE_FAILED, index:@index, message:message })



## KazitoriEvent
# Kazitori がディスパッチするイベント
class KazitoriEvent
  next:null
  prev:null
  type:null

  constructor:(type, next, prev)->
    @type = type
    @next = next
    @prev = prev

  clone:()->
    return new KazitoriEvent(@type, @next, @prev)

  toString:()->
    return "KazitoriEvent :: " + "type:" + @type + " next:" + String(@next) + " prev:" + String(@prev)


#タスクキューが空になった
KazitoriEvent.TASK_QUEUE_COMPLETE = 'task_queue_complete'

#タスクキューが中断された
KazitoriEvent.TASK_QUEUE_FAILED = 'task_queue_failed'

#URL が変わった時
KazitoriEvent.CHANGE = 'change'

#URL に登録されたメソッドがちゃんと実行された
KazitoriEvent.EXECUTED = 'executed'

#ビフォアー処理が完了した
KazitoriEvent.BEFORE_EXECUTED = 'before_executed'

#ユーザーアクション以外で URL の変更があった
KazitoriEvent.INTERNAL_CHANGE = 'internal_change'

#ユーザー操作によって URL が変わった時
KazitoriEvent.USER_CHANGE = 'user_change'

#ヒストリーバックした時
KazitoriEvent.PREV = 'prev'

#ヒストリーネクストした時
KazitoriEvent.NEXT = 'next'

#中断
KazitoriEvent.REJECT = 'reject'

#見つからなかった
KazitoriEvent.NOT_FOUND = 'not_found'

#スタート
KazitoriEvent.START = 'start'

#ストップ
KazitoriEvent.STOP = 'stop'

#一番最初のアクセスがあった
KazitoriEvent.FIRST_REQUEST = 'first_request'

Kazitori.started = false
