class Router extends Kazitori
	beforeAnytime:[]
	befores:
		'admin' :['ninshou']
		'admin/:id':['beforeMinchi']
	routes :
		# '/':'index'
		'':'index'
		'admin/:id':'show'
		'admin':'admin'
		'login':'login'
		'logout':'logout'

	index:()->
		console.log "index"
		$('#dialog').hide()
		$('#adminContainer').empty()
		$('.currentPage').empty().append "this page is index"

	show:(id)->
		console.log "showwww"
		$('.currentPage').empty().append "this page is test" + id

	admin:()->
		$('.currentPage').empty().append "this is admin page"
		$('#adminContainer').append('<a href="/admin/1" class="test">1</a><a href="/admin/2" class="test">2</a><a href="/admin/3" class="test">3</a>')
		$('.test').on 'click', clickHandler

	login:()->
		$('#dialog').show()

	logout:()->
		setCookie(COOKIE_KEY, '')
		window.App.change('')
		console.log "logout"
		$('#adminContainer').empty()
		return

	###
		some before functions
	###
	test:(hiroshi)->
		console.log "before 1", hiroshi

	beforeMinchi:()->
		console.log "before minchi"

	ninshou:()->
		isLogined = Boolean(getCookie(COOKIE_KEY))
		if isLogined is true
			return
		else
			window.App.change('login')
			


COOKIE_KEY = 'kazitoriExpCookie'
USER = "hage"
PASS = "hikaru"

$(document).ready ()->
	$('#dialog').css({
		top : window.innerHeight / 2 - 90
		left : window.innerWidth / 2 - 150
	})
	$('#dialog').hide()


	window.App = new Router({root:'/'})

	#チェンジイベント
	window.App.addEventListener(KazitoriEvent.CHANGE, (event)->
		# console.log event
		)

	$('.test').on "click", clickHandler
	
	$('form').on 'submit', (event)->
		event.preventDefault()
		userID = $('input[name=user]').val()
		pw = $('input[name=pw]').val()
		if userID is USER and pw is PASS
			setCookie(COOKIE_KEY, true)
			$('#dialog').hide()
			window.App.change('admin')
		else
			alert('バルス')

clickHandler =(event)->
	event.preventDefault()
	target = event.currentTarget.pathname
	console.log "inclick", target
	window.App.change(target)

getCookie =(key)->
	cookies = document.cookie.split(";")
	for cookie in cookies
		items = cookie.split('=')
		if items.shift() is key
			return items.join('=')
	return null


## TODO あとで secure とか expire のオプションに対応させようね
setCookie =(key, value, opt)->
	if not value?
		return
	expire = new Date()
	expire.setTime(expire.getTime()+60*60*24*1000)
	exipre = expire.toGMTString()
	document.cookie = key + '=' + escape(value) + ';expires=' + expire

test2 =()->
	console.log "before 2"
