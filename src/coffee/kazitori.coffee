###
	(c) 2013 Eikichi Yamaguchi
	kazitori.js may be freely distributed under the MIT license.
	http://dev.hageee.net

	fork from::
//     (c) 2010-2012 Jeremy Ashkenas, DocumentCloud Inc.
//     Backbone may be freely distributed under the MIT license.
//     For all details and documentation:
//     http://backbonejs.org
###

#delegate
delegater = (target, func)->
	return ()->
		func.apply(target, arguments)

#regexps
trailingSlash = /\/$/
routeStripper = /^[#\/]|\s+$/g
escapeRegExp = /[\-{}\[\]+?.,\\\^$|#\s]/g
namedParam = /:\w+/g
optionalParam = /\((.*?)\)/g
splatParam = /\*\w+/g


###
# ほとんど Backbone.Router と Backbone.History から拝借。
# jQuery や underscore に依存していないのでいろいろなライブラリと組み合わせられるはず。
# もっと高級なことしたけりゃ素直に Backbone 使うことをおぬぬめ。
#
###
class Kazitori
	VERSION:"0.1.3"
	history:null
	location:null
	handlers:[]
	beforeHandlers:[]
	afterhandlers:[]
	root:null
	beforeAnytimeHandler:null
	#失敗した時
	beforeFaildHandler:()->
		return
	isBeforeForce:false

	breaker:{}

	_dispatcher:null
	#hum
	_beforeDeffer:null


	constructor:(options)->
		@.options = options || (options = {})

		if options.routes
			@.routes = options.routes
		
		@.root = if options.root then options.root else '/'

		win = window
		if typeof win != 'undefined'
			@.location = win.location
			@.history = win.history
		docMode = document.docmentMode
		@isOldIE = (win.navigator.userAgent.toLowerCase().indexOf('msie') != -1) and (!docMode||docMode < 7)
		@_dispatcher = new EventDispatcher()
		@_bindBefores()
		@_bindRules()

		if "isAutoStart" not in options or options["isAutoStart"] != false
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
		fragment = @getFragment()
		atRoot = @.location.pathname.replace(/[^\/]$/, '$&/') is @.root

		if @isOldIE and @._wantChangeHash
			frame = document.createElement("iframe")
			frame.setAttribute("src","javascript:0")
			frame.setAttribute("tabindex", "-1")
			frame.style.display = "none"
			document.body.appendChild(frame)
			@.iframe = frame.contentWindow
			@change(fragment)

		if @._hasPushState is true
			win.addEventListener 'popstate', delegater(@, @observeURLHandler)
		else if @._wantChangeHash is true and ('onhashchange' in win) and not @.isOldIE
			win.addEventListener 'hashchange', delegater(@, @observeURLHandler)

		if @._hasPushState and atRoot and @.location.hash
			@.fragment = @.getHash().replace(routeStripper, '')
			@.history.replaceState({}, document.title, @.root + @.fragment + @.location.search)
			# return

		if !@.options.silent
			return  @loadURL()


	#止める
	stop:()->
		win = window
		win.removeEventListener 'popstate', arguments.callee
		win.removeEventListener 'hashchange', arguments.callee


	#url を変更する
	change:(fragment, options)->
		if not Kazitori.started
			return false
		prev = @.fragment
		if not options
			options = {'trigger':options}
		frag = @getFragment(fragment || '')
		if @.fragment is frag
			return
		@.fragment = frag
		next = @.fragment
		url = @.root + frag
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

		@._dispatcher.dispatchEvent({type:KazitoriEvent.CHANGE, prev:prev, next:next})
		@loadURL(frag)
		return 

	registHandler:(rule, name, isBefore, callback )->
		if typeof rule isnt RegExp
			rule = @_ruleToRegExp(rule)
		if not callback
			callback = if isBefore then @_bindFunctions(name) else @[name]

		target = if isBefore then @.beforeHandlers else @.handlers
		
		target.unshift {
			rule:rule, 
			callback:@_binder (fragment)->
				args = @._extractParams(rule, fragment)				
				callback && callback.apply(@, args)
			,@
		}
		return @

	#URL を読み込む
	loadURL:(fragmentOverride)->
		fragment = @.fragment = @getFragment(fragmentOverride)
		matched = []

		@._beforeDeffer = new Deffered()
		@._beforeDeffer.queue = []
		@._beforeDeffer.index = -1
		if @.beforeAnytimeHandler?
			@._beforeDeffer.deffered((d)=>
				@.beforeAnytimeHandler.callback(fragment)
				d.execute(d)
				return
			)

		y = 0
		for handler in @.beforeHandlers
			if handler.rule.test(fragment) is true
				@._beforeDeffer.deffered((d)->
					handler.callback(fragment)
					d.execute(d)
					return
				)

		@._beforeDeffer.addEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, @beforeComplete)
		@._beforeDeffer.addEventListener(KazitoriEvent.TASK_QUEUE_FAILD, @beforeFaild)
		@._beforeDeffer.execute(@._beforeDeffer)

		
	#before で登録した処理が無難に終わった
	beforeComplete:(event)=>
		@._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, @beforeComplete)
		@._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_FAILD, @beforeFaild)
		matched = []
		@._beforeDeffer.queue = []
		@._beforeDeffer.index = -1
		for handler in @.handlers
			if handler.rule.test(@.fragment)
				handler.callback(@.fragment)
				matched.push true
		return matched

	

	beforeFaild:(event)=>
		@.beforeFaildHandler.apply(@, arguments)
		# throw new Error()
		# @._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_FAILD, @beforeFaild)
		# @._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, @beforeComplete)
		if @isBeforeForce
			@beforeComplete()
		@._beforeDeffer = null



	#URL の変更を監視
	observeURLHandler:(event)->
		current = @getFragment()
		if current is @.fragment and @.iframe
			current = @getFragment(@getHash(@.iframe))
		if current is @.fragment
			return false
		if @.iframe
			@change(current)
		@loadURL() || @loadURL(@getHash())


	# routes から指定されたルーティングをバインド
	_bindRules:()->
		if not @.routes?
			return
		routes = @_keys(@.routes)
		for rule in routes
			@registHandler(rule, @.routes[rule],false)
		return

	# befores から指定された事前に処理したいメソッドをバインド
	_bindBefores:()->
		if not @.befores?
			return 
		befores = @_keys(@.befores)
		for key in befores
			@registHandler(key, @.befores[key], true)

		if @.beforeAnytime
			callback = @_bindFunctions(@.beforeAnytime)
			@.beforeAnytimeHandler = {
					callback:@_binder (fragment)->
						args = [fragment]						
						callback && callback.apply(@, args)
					,@
				}
		return


	_updateHash:(location, fragment, replace)->
		if replace
			href = location.href.replace /(javascript:|#).*$/, ''
			location.replace href + '#' + fragment
		else
			location.hash = "#" + fragment
		return




	#===============================================
	#
	# URL Querys
	#
	#==============================================

	# URL ルート以下を取得
	getFragment:(fragment)->
		if not fragment?
			if @._hasPushState or !@._wantChangeHash
				fragment = @.location.pathname
				root = @.root.replace(trailingSlash, '')
				if not fragment.indexOf(root)
					fragment = fragment.substr(root.length)
			else
				fragment = @getHash()
		return fragment.replace(routeStripper, '')


	# URL の # 以降を取得
	getHash:()->
		match = (window || @).location.href.match(/#(.*)$/)
		if match?
			return match[1]
		else
			return ''


	#URL パラメーターを取得
	_extractParams:(rule, fragment)->
		param = rule.exec(fragment)
		if param?
			return param.slice(1)
		else
			return null


	#url 正規化後 RegExp クラスに変換
	_ruleToRegExp:(rule)->
		newRule = rule.replace(escapeRegExp, '\\$&').replace(optionalParam, '(?:$1)?').replace(namedParam, '([^\/]+)').replace(splatParam, '(.*?)')
		return new RegExp('^' + newRule + '$')


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


class EventDispatcher
	listeners:{}
	addEventListener:(type, listener)->
		if @listeners[ type ] is undefined
			@listeners[ type ] =[]

		if @listeners[type].indexOf listener is -1
			@listeners[type].push listener
		return

	removeEventListener:(type, listener)->
		index = @listeners[type].indexOf listener

		if index isnt -1
			@listeners[type].splice(index, 1)
		return

	dispatchEvent:(event)->
		ary = @listeners[ event.type ]
		if ary isnt undefined
			event.target = @

			for handler in ary
				handler.call(@, event)
		return

class Deffered extends EventDispatcher
	queue : []
	index : -1

	constructor:()->
		@queue = []
		@index = -1
	
	deffered:(func)->
		@queue.push func
		return @

	execute:()->
		@index++
		try
			if @queue[@index]
				@queue[@index].apply(this, arguments)
				if @queue.length is @index
					@queue = []
					@index = -1
					@.dispatchEvent({type:KazitoriEvent.TASK_QUEUE_COMPLETE})
					
		catch error
			@reject(error)

	reject:(error)->
		@dispatchEvent({type:KazitoriEvent.TASK_QUEUE_FAILD, index:@index, message:error.message })

do(window)->
	KazitoriEvent = {}

	#タスクキューが空になった
	KazitoriEvent.TASK_QUEUE_COMPLETE = 'task_queue_complete'

	#タスクキューが中断された
	KazitoriEvent.TASK_QUEUE_FAILD = 'task_queue_faild'

	#URL が変わった時
	KazitoriEvent.CHANGE = 'change'

	window.KazitoriEvent = KazitoriEvent


Kazitori.started = false