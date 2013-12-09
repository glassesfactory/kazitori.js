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
namedParam = /<(\w+|[A-Za-z_-]+:\w+)>/g
genericParam = /([A-Za-z_-]+):(\w+)/

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

###*
* Kazitori.js は pushState をいい感じにさばいてくれるルーターライブラリです。<br>
* シンプルかつ見通しよく pushState コンテンツのルーティングを定義することができます。
*
* 使い方はとても簡単。
* <ul><li>Kazitori を継承したクラスを作る</li><li>routes に扱いたい URL と、それに対応したメソッドを指定。</li><li>インスタンス化</li></ul>
*
* <h4>example</h4>
*      class Router extends Kazitori
*        routes:
*          "/": "index"
*          "/<int:id>": "show"
*
*        index:()->
*          console.log "index!"
*        show:(id)->
*          console.log id
*
*      $(()->
*        app = new Router()
*      )
*
* Kazitori では pushState で非同期コンテンツを作っていく上で必要となるであろう機能を他にも沢山用意しています。<br>
* 詳細は API 一覧から確認して下さい。
* @module Kazitori.js
* @main Kazitori
###

## Kazitori クラス

###*
*  Kazitori のメインクラス
*
*  @class Kazitori
*  @constructor
###
class Kazitori
  VERSION: "0.9.10"
  history: null
  location: null


  ###*
  * マッチするURLのルールと、それに対応する処理を定義します。
  * <h4>example</h4>
  *     routes:
  *       '/':'index'
  *       '/<int:id>':'show'
  *
  * @property routes
  * @type Object
  * @default {}
  ###
  routes: {}

  handlers: []


  ###*
  * マッチした URL に対する処理を行う前に実行したい処理を定義します。
  * @property befores
  * @type Object
  * @default {}
  ###
  befores: {}
  beforeHandlers: []


  ###*
  * URL が変わる際、事前に実行したい処理を定義します。<br>
  * このプロパティに登録された処理は、与えられた URL にマッチするかどうかにかかわらず、常に実行されます。
  * @property beforeAnytimeHandler
  * @type Array
  * @default []
  ###
  beforeAnytimeHandler: null
  afterhandlers: []


  ###*
  * 特定のファイル名が URL に含まれていた時、ルートとして処理するリストです。
  * @property rootFiles
  * @type Array
  ###
  rootFiles: ['index.html', 'index.htm', 'index.php', 'unko.html']


  ###*
  * ルートを指定します。<br>
  * ここで指定された値が URL の prefix として必ずつきます。<br>
  * 物理的に URL のルートより 1ディレクトリ下がった箇所で pushState を行いたい場合<br>
  * この値を / 以外に指定します。
  * <h4>example</h4>
  * コンテンツを配置する実ディレクトリが example だった場合
  *
  *     app = new Router({root:'/example/'})
  * @property root
  * @type String
  * @default /
  ###
  root: null


  ###*
  * 現在の URL にマッチするルールがなかった場合に変更する URL
  * @property notFound
  * @type String
  * @default null
  ###
  notFound: null

  direct: null
  isIE: false


  ###*
  * URL を実際には変更しないようにするかどうかを決定します。<br>
  * true にした場合、URL は変更されず、内部で保持している状態管理オブジェクトを基準に展開します。
  * @property silent
  * @type Boolean
  * @default false
  ###
  silent: false


  ###*
  * pushState への監視が開始されているかどうか
  * @property started
  * @type Boolean
  * @default false
  ###
  started: false


  #URL パラメーター
  _params:
    params:[]
    'fragment':''


  ###*
  * before 処理が失敗した時に実行されます。<br>
  * デフォルトでは空の function になっています。
  *
  * @method beforeFailedHandler
  ###
  beforeFailedHandler:()->
    return



  ###isBeforeForce###
  isBeforeForce: false
  #befores の処理を URL 変更前にするかどうか
  isTemae: false
  _changeOptions: null

  isNotFoundForce: false
  _notFound: null

  breaker: {}

  _dispatcher: null
  _beforeDeffer: null

  ###*
  * 現在の URL を返します。
  * @property fragment
  * @type String
  * @default null
  ###
  fragment: null


  ###*
  * 現在の URL から 1つ前の URL を返します。
  * @property lastFragment
  * @type String
  * @default null
  ###
  lastFragment: null
  isUserAction: false

  _isFirstRequest: true



  ###*
  * 一時停止しているかどうかを返します。
  *
  * @property isSuspend
  * @type Boolean
  * @default false
  ###
  isSuspend: false

  _processStep:
    'status': 'null'
    'args': []

  constructor:(options)->
    @._processStep.status = 'constructor'
    @._processStep.args = [options]
    @.options = options || (options = {})

    if options.routes
      @.routes = options.routes

    @.root = if options.root then options.root else if @.root is null then '/' else @.root
    @.isTemae = if options.isTemae then options.isTemae else false
    @.silent = if options.silent then options.silent else false


    @._params = {
      params:[]
      queries:{}
      fragment:null
    }

    #見つからなかった時強制的に root を表示する
    # @.notFound = if options.notFound then options.notFound else @.root
    if @.notFound is null
      @.notFound = if options.notFound then options.notFound else @.root

    win = window
    if typeof win != 'undefined'
      @.location = win.location
      @.history = win.history
    docMode = document.docmentMode
    @isIE = win.navigator.userAgent.toLowerCase().indexOf('msie') != -1
    @isOldIE = @isIE and (!docMode||docMode < 7)
    @_dispatcher = new EventDispatcher()
    @.handlers = []
    @.beforeHandlers = []
    @_bindBefores()
    @_bindRules()
    @_bindNotFound()

    try
      Object.defineProperty(@, 'params', {
        enumerable : true
        get:()->
          return @._params.params
        })
      Object.defineProperty(@, 'queries', {
        enumerable : true
        get:()->
          return @._params.queries
        })
    catch e
      #throw new Error(e)
      #IEだと defineProperty がアレらしいので
      #@.__defineGetter__ したほうがいいかなー

    if not @.options.isAutoStart? or @.options.isAutoStart != false
      @start()
    return


  ###*
  * Kazitori.js を開始します。<br>
  * START イベントがディスパッチされます。
  * @method start
  * @param {Object} options オプション
  ###
  start:(options)->
    @._processStep.status = 'start'
    @._processStep.args = [options]
    if @.started
      throw new Error('mou hazim matteru')
    @.started = true
    win = window
    @.options = @_extend({}, {root:'/'}, @.options, options)
    @._hasPushState = !!(@.history and @.history.pushState)
    @._wantChangeHash = @.options.hashChange isnt false
    fragment = @.fragment = @getFragment()

    atRoot = @.location.pathname.replace(/[^\/]$/, '$&/') is @.root

    if @isIE and not atRoot
      ieFrag = @.location.pathname.replace(@.root, '')
      @_updateHashIE(ieFrag)

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

    override = @.root
    if !@.silent
      if not @._hasPushState and atRoot
        override = @.root + @.fragment.replace(routeStripper, '')
      else if not atRoot
        override = @.fragment
    return @loadURL(override)


  ###*
  * Kazitori.js を停止します。<br>
  * STOP イベントがディスパッチされます。
  * @method stop
  ###
  stop:()->
    win = window
    win.removeEventListener 'popstate', @observeURLHandler
    win.removeEventListener 'hashchange', @observeURLHandler
    @.started = false
    #ストップイベントをディスパッチ
    @._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.STOP, @.fragment))

  ###*
  * ブラウザのヒストリー機能を利用して「進む」を実行します。<br>
  * 成功した場合 NEXT イベントがディスパッチされます。
  * @method torikazi
  * @param {Object} options
  ###
  torikazi:(options)->
    return @direction(options, "next")

  ###*
  * ブラウザヒストリー機能を利用して「戻る」を実行します。<br>
  * 成功した場合 PREV イベントがディスパッチされます。
  * @method omokazi
  * @param {Object} options
  ###
  omokazi:(options)->
    return @direction(options, "prev")

  direction:(option, direction)->
    if not @.started
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


  ###*
  * url を変更します。<br>
  * 無事 URL が切り替わった場合、CHANGE イベントがディスパッチされます。
  * <h4>example</h4>
  *     app.change('/someurl');
  * @method change
  * @param {String} fragment 変更したい URL
  * @param {Object} options オプション
  ###
  change:(fragment, options)->
    if not @.started
      return false
    @._processStep.status = 'change'
    @._processStep.args = [fragment, options]
    if not options
      options = {'trigger':options}
    @._changeOptions = options

    #TODO : @ に突っ込んじゃうとこのあと全部 BeforeForce されてまう
    @.isBeforeForce = options.isBeforeForce isnt false
    frag = @getFragment(fragment || '')
    if @.fragment is frag
      return
    @.lastFragment = @.fragment
    @.fragment = frag
    next = @.fragment

    #memo : jasmine だけなんかおかしい
    #frag が undefined になってしまう
    # console.debug frag
    url = @.root + @_replace.apply(frag,[routeStripper, ''])
    matched = @_matchCheck(@.fragment, @.handlers)
    if matched is false and @.isNotFoundForce is false
      if @.notFound isnt null
        @._notFound.callback(@.fragment)
        url = @.root + @._notFound.rule.replace(routeStripper, '')
        @.history[ if options.replace then 'replaceState' else 'pushState' ]({}, document.title, url)
      @._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.NOT_FOUND))
      return

    if @.isTemae and (@.beforeAnytimeHandler or @.beforeHandlers.length > 0)
      @_executeBefores(frag)
    else
      @_urlChange(frag, options)
    return

  ###*
  * pushState ではなく replaceState で処理します。<br>
  * replaceState は現在の URL を置き換えるため、履歴には追加されません。
  * <h4>example</h4>
  *     app.replace('/someurl');
  * @method replace
  * @param {String} fragment 変更したい URL
  * @param {Object} options オプション
  ###
  replace:(fragment, options)->
    @._processStep.status = 'replace'
    @._processStep.args = [fragment, options]
    if not options
      options = {replace:true}
    else if not options.replace or options.replace is false
      options.replace = true
    @change(fragment, options)
    return

  _urlChange:(fragment, options)->
    @._processStep.status = '_urlChange'
    @._processStep.args = [fragment, options]

    if @.isSuspend
      return
    if not options
      options = @._changeOptions
    url = @.root + @.fragment.replace(routeStripper, '')
    if not @.silent
      if @._hasPushState
        @.history[ if options.replace then 'replaceState' else 'pushState' ]({}, document.title, url)
      else if @._wantChangeHash
        @_updateHash(@.location, fragment, options.replace)
        if @.iframe and (fragment isnt @getFragment(@getHash(@.iframe)))
          if !options.replace
            @.iframe.document.open().close()
          @_updateHash(@.iframe.location, fragment, options.replace)
      else
        return @.location.assign(url)

    #イベントディスパッチ
    @dispatchEvent(new KazitoriEvent(KazitoriEvent.CHANGE, @.fragment, @.lastFragment))
    if options.internal and options.internal is true
      @._dispatcher.dispatchEvent( new KazitoriEvent(KazitoriEvent.INTERNAL_CHANGE, @.fragment, @.lastFragment))
    @loadURL(@.fragment, options)


  ###*
  * 中止します。
  * @method reject
  ###
  reject:()->
    @dispatchEvent(new KazitoriEvent(KazitoriEvent.REJECT, @.fragment ))
    if @._beforeDeffer
      @._beforeDeffer.removeEventListener KazitoriEvent.TASK_QUEUE_COMPLETE, @beforeComplete
      @._beforeDeffer.removeEventListener KazitoriEvent.TASK_QUEUE_FAILED, @beforeFailed
      @._beforeDeffer = null
    return

  ###*
  * 処理を一時停止します。<br>
  * SUSPEND イベントがディスパッチされます。
  * @method suspend
  ###
  suspend:()->
    if @._beforeDeffer?
      @._beforeDeffer.suspend()
    @.started = false
    @.isSuspend = true
    @._dispatcher.dispatchEvent( new KazitoriEvent( KazitoriEvent.SUSPEND, @.fragment, @.lastFragment ))
    return

  ###*
  * 処理を再開します。<br>
  * RESUME イベントがディスパッチされます。
  * @method resume
  ###
  resume:()->
    if @._beforeDeffer?
      @._beforeDeffer.resume()
    @.started = true
    @.isSuspend = false
    @[@._processStep.status](@._processStep.args)
    @._dispatcher.dispatchEvent( new KazitoriEvent( KazitoriEvent.RESUME, @.fragment, @.lastFragment ))
    return

  registerHandler:(rule, name, isBefore, callback )->
    if not callback
      if isBefore
        callback = @_bindFunctions(name)
      else if name instanceof Kazitori
        @_bindChild(rule, name)
        return @
      else if typeof name is "function"
        #これ再帰的にチェックするメソッドに落としこもう
        #__super__ って coffee のクラスだけなきガス
        #むーん
        if name.hasOwnProperty('__super__')
          try
            child = new name({'isAutoStart':false})
            @_bindChild(rule, child)
            return @
          catch e
            callback = name
        else
          callback = name
      else
        callback = @[name]

    target = if isBefore then @.beforeHandlers else @.handlers
    target.unshift new Rule(rule, (fragment)->
      args = @.router.extractParams(@, fragment)
      callback && callback.apply(@.router, args)
    ,@)
    return @

  _bindChild:(rule, child)->
    child.reject()
    child.stop()
    childHandlers = child.handlers.concat()
    for childRule in childHandlers
      childRule.update(rule)
    @.handlers = childHandlers.concat @.handlers

    childBefores = child.beforeHandlers.concat()
    for childBefore in childBefores
      childBefore.update(rule)
    @.beforeHandlers = childBefores.concat @.beforeHandlers

    if child.beforeAnytimeHandler
      @.lastAnytime = @.beforeAnytime.concat()
      @_bindBeforeAnytime(@.beforeAnytime, [child.beforeAnytimeHandler.callback])


  ###*
  * ルーターを動的に追加します。<br>
  * ルーターの追加に成功した場合、ADDED イベントがディスパッチされます。
  * <h4>example</h4>
  *     fooRouter = new FooRouter();
  *     app.appendRouter(foo);
  * @method appendRouter
  * @param {Object} child
  * @param {String} childRoot
  ###
  appendRouter:(child, childRoot)->
    if not child instanceof Kazitori and typeof child isnt "function"
      throw new Error("引数の値が不正です。 引数として与えられるオブジェクトは Kazitori を継承している必要があります。")
      return

    if child instanceof Kazitori
      rule = @_getChildRule(child, childRoot)
      @_bindChild(rule, child)
      return @
    else
      if child.hasOwnProperty('__super__')
        try
          _instance = new child({'isAutoStart':false})
          rule = @_getChildRule(_instance, childRoot)
          @_bindChild(rule, _instance)
          return @
        catch e
          throw new Error("引数の値が不正です。 引数として与えられるオブジェクトは Kazitori を継承している必要があります。")
    @._dispatcher.dispatchEvent( new KazitoriEvent( KazitoriEvent.ADDED, @.fragment, @.lastFragment ))
    return @

  _getChildRule:(child, childRoot)->
    rule = child.root
    if childRoot
      rule = childRoot
    if rule.match(trailingSlash)
      rule = rule.replace(trailingSlash, '')
    if rule is @.root
      throw new Error("かぶってる")
    return rule

  ###*
  * 動的に追加したルーターを削除します。
  * ルーターの削除に成功した場合、REMOVED イベントがディスパッチされます。
  * <h4>example</h4>
  *     foo = new FooRouter();
  *     app.appendRouter(foo);
  *     app.removeRouter(foo);
  * @method removeRouter
  * @param {Object} child
  * @param {String} childRoot
  ###
  removeRouter:(child, childRoot)->
    if not child instanceof Kazitori and typeof child isnt "function"
      throw new Error("引数の値が不正です。 引数として与えられるオブジェクトは Kazitori を継承している必要があります。")
      return
    if child instanceof Kazitori
      @_unbindChild(child, childRoot)
    else
      if child.hasOwnProperty('__super__')
        try
          _instance = new child({'isAutoStart':false})
          @_unbindChild(_instance, childRoot)
          return @
        catch e
          throw new Error("引数の値が不正です。 引数として与えられるオブジェクトは Kazitori を継承している必要があります。")
    @._dispatcher.dispatchEvent( new KazitoriEvent(KazitoriEvent.REMOVED, @.fragment, @.lastFragment))
    return @

  _unbindChild:(child, childRoot)->
    rule = @_getChildRule(child, childRoot)
    i = 0
    len = @.handlers.length
    newHandlers = []
    while i < len
      ruleObj = @.handlers.shift()
      if (ruleObj.rule.match rule) is null
        newHandlers.unshift(ruleObj)
      i++
    @.handlers = newHandlers

    i = 0
    len = @.beforeHandlers.length
    newBefores = []
    while i < len
      beforeRule = @.beforeHandlers.shift()
      if (beforeRule.rule.match rule) is null
        newBefores.unshift(beforeRule)
      i++
    @.beforeHandlers = newBefores


  ###*
  * ブラウザから現在の URL を読み込みます。
  * @method loadURL
  * @param {String} fragmentOverride
  * @param {Object} options
  ###
  loadURL:(fragmentOverride, options)->
    @._processStep.status = 'loadURL'
    @._processStep.args = [fragmentOverride, options]
    if @.isSuspend
      return
    fragment = @.fragment = @getFragment(fragmentOverride)
    if @.isTemae is false and (@.beforeAnytimeHandler or @.beforeHandlers.length > 0)
      @_executeBefores(fragment)
    else
      @executeHandlers()
    return

  ###*
  * 指定した 文字列に対応した URL ルールが設定されているかどうか<br>
  * Boolean で返します。
  * <h4>example</h4>
  *     app.match('/hoge');
  * @method match
  * @param {String} fragment
  * @return {Boolean}
  ###
  match:(fragment)->
    matched = @._matchCheck(fragment, @.handlers, true)
    return matched.length > 0



  #before で登録した処理が無難に終わった
  beforeComplete:(event)=>
    @._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, @beforeComplete)
    @._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_FAILED, @beforeFailed)

    @._dispatcher.dispatchEvent( new KazitoriEvent(KazitoriEvent.BEFORE_EXECUTED, @.fragment, @.lastFragment))
    #ここではんだんするしかないかなー
    if @.isTemae
      @_urlChange(@.fragment, @._changeOptions)
    else
      @executeHandlers()
    return

  #登録されたbefores を実行
  _executeBefores:(fragment)=>
    @._processStep.status = '_executeBefores'
    @._processStep.args = [fragment]
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

  #routes で登録されたメソッドを実行
  executeHandlers:()=>
    @._processStep.status = 'executeHandlers'
    @._processStep.args = []
    if @.isSuspend
      return
    #毎回 match チェックしてるので使いまわしたいのでリファクタ
    matched = @._matchCheck(@.fragment, @.handlers)
    isMatched = true
    if matched is false or matched.length < 1
      if @.notFound isnt null
        @._notFound.callback(@.fragment)
      isMatched = false
      @._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.NOT_FOUND))

    else if matched.length > 1
      for match in matched
        if @.fragment.indexOf(match.rule) > -1
            match.callback(@.fragment)

        # if @.fragment.indexOf match.rule
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
      @registerHandler(rule, @.routes[rule], false)
    return

  # befores から指定された事前に処理したいメソッドをバインド
  _bindBefores:()->
    if @.beforeAnytime
      @_bindBeforeAnytime(@.beforeAnytime)
    if not @.befores?
      return
    befores = @_keys(@.befores)
    for key in befores
      @registerHandler(key, @.befores[key], true)
    return

  _bindBeforeAnytime:(funcs, bindedFuncs)->
    callback = @_bindFunctions(funcs, bindedFuncs)
    @.beforeAnytimeHandler = {
      callback:@_binder (fragment)->
        args = [fragment]
        callback && callback.apply(@, args)
      ,@
    }

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
      args = @.router.extractParams(@, fragment)
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

  #zantei
  _updateHashIE:(fragment, replace)->
    location.replace @.root + '#/' + fragment


  #マッチする URL があるかどうか
  # memo : 20130130
  # ここでここまでのチェックを実際に行うなら
  # loadURL, executeHandler 内で同じチェックは行う必要がないはずなので
  # それぞれのメソッドが簡潔になるようにリファクタする必要がある
  _matchCheck:(fragment, handlers, test=false)->
    matched = []
    tmpFrag = fragment
    if tmpFrag isnt undefined and tmpFrag isnt 'undefined'

      hasQuery = @_match.apply(tmpFrag, [/(\?[\w\d=|]+)/g])
    if hasQuery
      fragment = fragment.split('?')[0]
    for handler in handlers
      if handler.rule is fragment
        matched.push handler
      else if handler.test(fragment)
        if handler.isVariable and handler.types.length > 0
          #型チェック用
          # args = handler._extractParams(fragment)
          args = @.extractParams(handler, fragment, test)
          argsMatch = []
          len = args.length
          i = 0
          while i < len
            a = args[i]
            t = handler.types[i]
            if typeof a isnt "object"
              if t is null
                argsMatch.push true
              else
                argsMatch.push @_typeCheck(a,t)
            i++
          argsMatched = true
          for match in argsMatch
            if not match
              argsMatched = false
          if argsMatched
            matched.push handler
        else
          matched.push handler
    return if matched.length > 0 then matched else false


  #===============================================
  #
  # URL Queries
  #
  #==============================================

  ###*
  * URL ルート以下を取得
  * @method getFragment
  * @param {String} fragment
  ###
  getFragment:(fragment)->
    if not fragment? or fragment == undefined
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

        if fragment.indexOf(root) > -1
          fragment = fragment.substr(root.length)
      else
        fragment = @getHash()
    else
      root = @.root.replace(trailingSlash, '')

      if fragment.indexOf(@.root) > -1 and fragment.indexOf(root) > -1
        fragment = fragment.substr(root.length)
    if typeof fragment is "string"
      fragment = fragment.replace(trailingSlash, '')
    # console.log "kazitori current fragment::", fragment.replace(trailingSlash, '')
    return fragment


  ###*
  * URL の # 以降を取得
  * @method getHash
  * @return {String} URL の # 以降の文字列
  ###
  getHash:()->
    match = (window || @).location.href.match(/#(.*)$/)
    if match?
      return match[1]
    else
      return ''


  ###*
  * URL パラメータを分解
  * @method extractParams
  * @param {Rule} rule
  * @param {String} fragment
  * @param {Boolean} test
  ###
  extractParams:(rule, fragment, test=false)->
    if @._params.params.length > 0 and @._params.fragment is fragment
      return @._params.params
    param = rule._regexp.exec(fragment)
    if param is null and fragment.indexOf('?') > -1
      param = [0,'?' + fragment.split('?')[1]]
    @._params.fragment = fragment
    if param?
      newParam = param.slice(1)
      last = param[param.length - 1]
      if last.indexOf('?') > -1
        newQueries = {}
        queries = last.split('?')[1]
        queryParams = queries.split('&')
        for query in queryParams
          kv = query.split('=')
          k = kv[0]
          v = if kv[1] then kv[1] else ""
          if v.indexOf('|') > -1
            v = v.split("|")
          newQueries[k] = v
        newParam.pop()
        newParam.push last.split('?')[0]
        q = {"queries":newQueries}
        newParam.push q

        if not test
          @._params.params = @_getCastedParams(rule, newParam.slice(0))
          @._params.queries = newQueries
      else
        if not test
          @._params.params = @_getCastedParams(rule, newParam)
      return newParam
    else
      @._params.params = []
      return null

  #パラメーターを指定された型でキャスト
  _getCastedParams:(rule, params)->
    i = 0
    if not params
      return params

    if rule.types.length < 1
      return params
    len = params.length
    castedParams = []
    while i < len
      if rule.types[i] is null
        castedParams.push params[i]
      else if typeof params[i] is "object"
        castedParams.push params[i]
      else
        for type in VARIABLE_TYPES
          if rule.types[i] is type.name
            castedParams.push type.cast(params[i])
      i++
    return castedParams

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

  _replace:String.prototype.replace
  _match:String.prototype.match

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

  _bindFunctions:(funcs, insert)->
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
    if insert
      bindedFuncs = insert.concat bindedFuncs
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
###*
* pushState で処理したいルールを定義するクラス
*
* @class Rule
* @constructor
* @param {String} rule
* @param {Function} callback
* @param {Kazitori} router
###
class Rule
  ###*
  * ルール文字列
  * @property rule
  * @type String
  * @default ""
  ###
  rule: ""

  _regexp: null

  ###*
  * コールバック関数
  * ルールとマッチする場合実行されます。
  * @property callback
  * @type: Function
  * @default null
  ###
  callback:null

  name:""
  router:null
  isVariable:false
  types:[]
  constructor:(rule, callback, router)->
    if typeof rule isnt "string" and typeof rule isnt "Number"
      return
    @callback = callback
    @router = router
    @update(rule)

  #マッチするかどうかテスト
  # **args**
  # fragment : テスト対象となる URL
  # **return**
  # Boolean : テスト結果の真偽値
  ###*
  * Rule として定義したパターンと fragment として与えられた文字列がマッチするかどうかテストする
  * @method test
  * @param {String} fragment
  * @return {Boolean} マッチする場合 true を返す
  ###
  test:(fragment)->
    return @_regexp.test(fragment)

  _ruleToRegExp:(rule)->
    newRule = rule.replace(escapeRegExp, '\\$&').replace(optionalParam, '(?:$1)?').replace(namedParam, '([^\/]+)').replace(splatParam, '(.*?)')
    return new RegExp('^' + newRule + '$')

  ###*
  * 与えられた path で現在の Rule をアップデートします。
  * @method update
  * @param {String} path
  ###
  update:(path)=>
    @.rule = path + @.rule
    #trailing last slash
    if @.rule isnt '/'
      @.rule = @.rule.replace(trailingSlash, '')
    @._regexp = @_ruleToRegExp(@.rule)
    re = new RegExp(namedParam)
    matched = path.match(re)
    if matched isnt null
      @isVariable = true
      for m in matched
        t = m.match(genericParam)||null
        @types.push if t isnt null then t[1] else null


###*
* イベントディスパッチャ
* @class EventDispatcher
* @constructor
###
class EventDispatcher
  listeners:{}
  addEventListener:(type, listener)->
    if @listeners[ type ] is undefined
      @listeners[ type ] =[]

    if @_inArray(listener, @listeners[type]) < 0
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

  _inArray: ( elem, array )->
    i = 0
    len = array.length
    while i < len
      if array[ i ] is elem
        return i
      i++
    return -1


## Deffered
# **internal**
# before を確実に処理するための簡易的な Deffered クラス
class Deffered extends EventDispatcher
  queue : []
  isSuspend : false

  constructor:()->
    @queue = []
    @isSuspend = false

  deffered:(func)->
    @queue.push func
    return @

  execute:()->
    if @isSuspend
      return
    try
      task = @queue.shift()
      if task
        task.apply(@, arguments)
      if @queue.length < 1
        @queue = []
        @.dispatchEvent(new KazitoriEvent(KazitoriEvent.TASK_QUEUE_COMPLETE))
    catch error
      @reject(error)

  #defferd を中断する
  reject:(error)->
    message = if not error then "user reject" else error
    @dispatchEvent({type:KazitoriEvent.TASK_QUEUE_FAILED, index:@index, message:message })
    @isSuspend = false

  #deffered を一時停止する
  suspend:()->
    @isSuspend = true
    return

  #deffered を再開する
  resume:()->
    @isSuspend = false
    @execute()
    return



## KazitoriEvent
# Kazitori がディスパッチするイベント
###*
* pushState 処理や Kazitori にまつわるイベント
* @class KazitoriEvent
* @constructor
* @param {String} type
* @param {String} next
* @param {String} prev
###
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


###*
* タスクキューが空になった
* @property TASK_QUEUE_COMPLETE
* @type String
* @default task_queue_complete
###
KazitoriEvent.TASK_QUEUE_COMPLETE = 'task_queue_complete'

###*
* タスクキューが中断された
* @property TASK_QUEUE_FAILED
* @type String
* @default task_queue_failed
###
KazitoriEvent.TASK_QUEUE_FAILED = 'task_queue_failed'


###*
* URL が変更された
* @property CHANGE
* @type String
* @default change
###
KazitoriEvent.CHANGE = 'change'


###*
* URL に登録されたメソッドがちゃんと実行された
* @property EXECUTED
* @type String
* @default executed
###
KazitoriEvent.EXECUTED = 'executed'


###*
* 事前処理が完了した
* @property BEFORE_EXECUTED
* @type String
* @default before_executed
###
KazitoriEvent.BEFORE_EXECUTED = 'before_executed'


###*
* ユーザーアクション以外で URL の変更があった
* @property INTERNAL_CHANGE
* @type String
* @default internal_change
###
KazitoriEvent.INTERNAL_CHANGE = 'internal_change'


KazitoriEvent.USER_CHANGE = 'user_change'


###*
* ヒストリーバックした
* @property PREV
* @type String
* @default prev
###
KazitoriEvent.PREV = 'prev'


###*
* ヒストリーネクストした時
* @property NEXT
* @type String
* @default next
###
KazitoriEvent.NEXT = 'next'


###*
* Kazitori が中断した
* @property REJECT
* @type String
* @default reject
###
KazitoriEvent.REJECT = 'reject'


###*
* URL にマッチする処理が見つからなかった
* @property NOT_FOUND
* @type String
* @default not_found
###
KazitoriEvent.NOT_FOUND = 'not_found'


###*
* Kazitori が開始した
* @property START
* @type String
* @default start
###
KazitoriEvent.START = 'start'


###*
* Kazitori が停止した
* @property STOP
* @type String
* @default stop
###
KazitoriEvent.STOP = 'stop'


###*
* Kazitori が一時停止した
* @property SUSPEND
* @type String
* @default SUSPEND
###
KazitoriEvent.SUSPEND = 'SUSPEND'


###*
* Kazitori が再開した
* @property RESUME
* @type String
* @default resume
###
KazitoriEvent.RESUME = 'resume'


###*
* Kazitori が開始してから、一番最初のアクセスがあった
* @property FIRST_REQUEST
* @type String
* @default first_request
###
KazitoriEvent.FIRST_REQUEST = 'first_request'


###*
* ルーターが追加された
* @property ADDED
* @type String
* @default added
###
KazitoriEvent.ADDED = 'added'

###*
* ルーターが削除された
* @property REMOVED
* @type String
* @default removed
###
KazitoriEvent.REMOVED = 'removed'
