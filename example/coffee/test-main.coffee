test3 = ()->
	console.log "/?"

isLoaded = false
class Router extends Kazitori
	# beforeAnytime:['checkMaterial']
	befores:
		
		# 'admin' :['ninshou']
		# '/<string:user>/<int:post>/<friend>':['beforeMinchi']
		'/<int:id>':['beforeShow']
	routes :
		'/':'index'		
		'/<int:id>':'show'
		# '/admin/<int:id>':'show'
		'/admin':'admin'
		'/login':'login'
		'/logout':'logout'
		# '/<string:user>/<int:post>':'post'
		'/<string:user>/<int:post>/<friend>':'firend'
		# '/hyoge':'hyoge'
		

	index:()->
		console.log "index"
		$('#dialog').hide()
		$('#adminContainer').empty()
		$('.currentPage').empty().append "this page is index"

	show:(id)->
		console.log "showwww", id
		console.log Oar.GET_CSS_PATH(Oar.RELATIVE)
		$('.currentPage').empty().append "this page is test" + id

	hyoge:()->
		console.log "oppai"
		$('.currentPage').empty().append "(´･ω｀･)ｴｯ?"

	admin:()->
		console.log "admin"
		$('.currentPage').empty().append "this is admin page"
		$('#adminContainer').empty().append('<a href="/admin/1" class="test">1</a><a href="/admin/2" class="test">2</a><a href="/admin/3" class="test">3</a>')

	login:()->
		$('#dialog').show()

	logout:()->
		setCookie(COOKIE_KEY, '')
		window.App.change('')
		console.log "logout"
		$('#adminContainer').empty()
		return

	post:(username, postid)->
		$('.currentPage').empty().append username, postid
		console.log username, postid

	firend:(username, postid, firend, queries)->
		console.log "friend"
		console.log queries
		console.log Oar.GET_CSS_PATH(Oar.RELATIVE)
		$('.currentPage').empty().append username, postid, firend

	###
		some before functions
	###
	test:(hiroshi)->
		console.log "before 1", hiroshi

	beforeShow:(id)->
		console.log "before"
		console.log id

	beforeMinchi:()->
		console.log "before minchi"

	ninshou:()->
		isLogined = Boolean(getCookie(COOKIE_KEY))
		if isLogined is true
			return
		else
			# @change('login')
			@reject()
			

		# @change(@poolFragment)


COOKIE_KEY = 'kazitoriExpCookie'
USER = "hage"
PASS = "hikaru"

$(document).ready ()->
	$('#dialog').css({
		top : window.innerHeight / 2 - 90
		left : window.innerWidth / 2 - 150
	})
	$('#dialog').hide()

	window.App = new Router({root:'/hage/'})
	
	#チェンジイベント
	window.App.addEventListener( KazitoriEvent.CHANGE, (event)->
		console.log event, "change"
		)

	window.App.addEventListener( KazitoriEvent.FIRST_REQUEST, (event)->
		console.log event, "firstrequest"
		)
	
	window.App.addEventListener( KazitoriEvent.PREV, (event)->
		console.log event, "prev"
		)
	window.App.addEventListener( KazitoriEvent.NEXT, (event)->
		console.log event, "next"
		)
	#リジェクトイベント
	window.App.addEventListener(KazitoriEvent.REJECT, (event)->
		console.log event
		)

	#not foudn
	window.App.addEventListener(KazitoriEvent.NOT_FOUND, (event)->
		console.log "not found"
		)

	$('.test').on "click", clickHandler

	$('.prev').on "click", prevHandler

	$('.next').on "click", nextHandler
	
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
	console.log Oar.GET_CSS_PATH(Oar.RELATIVE)

clickHandler =(event)->
	event.preventDefault()
	target = $(event.currentTarget)
	url = target.attr('href')
	window.App.change(url,{replace:true})

prevHandler =(event)->
	event.preventDefault()
	window.App.omokazi()

nextHandler =(event)->
	event.preventDefault()
	window.App.torikazi()

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
