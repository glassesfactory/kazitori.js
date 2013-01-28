class Router extends Kazitori
	beforeAnytime:['test']
	befores:
		'admin' :['ninshou']
		'admin/:minchi':['beforeMinchi']


	routes :
		# '/':'index'
		'':'index'
		'admin':'admin'
		'login':'login'
		'logout':'logout'
		'admin/:minchi':'show'

		

	index:()->
		console.log "index"
		$('.currentPage').empty().append "this page is index"

	show:(id)->
		$('.currentPage').empty().append "this page is test" + id

	admin:()->
		$('.currentPage').empty().append "this is admin page"

	login:()->
		$('#dialog').show()

	logout:()->
		setCookie(COOKIE_KEY, '')
		window.App.change('')
		console.log "logout"
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
	$('.test').on "click", (event)->
		event.preventDefault()
		target = event.currentTarget.pathname
		window.App.change(target)

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
