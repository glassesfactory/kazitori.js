test3 = ()->
  console.log "/?"

isLoaded = false

class FooRouter extends Kazitori
  root: '/foo/'
  beforeAnytime: ['beforeFoobar']
  befores:
    '/': ['beforeFooMinchi']
  routes:
    '/': 'index'
    '/<int:id>': 'show'

  index:()->
    console.log 'Foo!'
    # console.log window.App.fragment
    $('.currentPage').empty().append "this page is Foo!"

  show:(id)->
    console.log 'Show Foo!'
    $('.currentPage').empty().append "this page is Foo " + id

  bar:()->
    console.log "hoover-ooover"
    $('.currentPage').empty().append "this page is ふーばーおーばー"

  beforeFooMinchi:()->
    console.log "before foo"

  beforeFoobar:()->
    console.log "コレクション コレクション"

class BarRouter extends FooRouter
  routes:
    '/': 'index'
  index:()->
    console.log "extends extends bar"

class Router extends Kazitori
  beforeAnytime:['anytime']
  # beforeAnytime: ["anytime"]
  # befores:

  #   # 'admin' :['ninshou']
  #   '/<string:user>/<int:post>/<friend>':['beforeMinchi']
  #   '/<int:id>':['beforeShow']
  routes :
    '/':'index'
    '/foo': FooRouter
    # '/bar': BarRouter
    # '/<int:id>':'show'
    '/<id>/':'show'
    # # '/admin/<int:id>':'show'
    # '/admin':'admin'
    # '/login':'login'
    # '/logout':'logout'
    # # '/<string:user>/<int:post>':'post'
    # '/<string:user>/<int:post>/<friend>':'firend'
    # '/hyoge':'hyoge'
  # notFound:
    # '/404':'notfound'

  index:()->
    console.log "index"
    # $('#dialog').hide()
    # $('#adminContainer').empty()
    # $('.currentPage').empty().append "this page is index"

  show:(id)->
    console.log "show::", id
    # console.log Kai.GET_CSS_PATH(Kai.RELATIVE)
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
    # console.log "friend"
    # console.log queries
    # console.log Kai.GET_CSS_PATH(Kai.RELATIVE)
    console.log @.params, "hironori"
    $('.currentPage').empty().append username, postid, firend

  notfound:()->
    console.log "nullpo"

  ###
    some before functions
  ###
  anytime:()->
    console.log "any!?"

  test:(hiroshi)->
    console.log "before 1", hiroshi

  beforeShow:(id)->
    console.log "before"
    console.log id

  beforeMinchi:()->
    console.log "before minchi"
    @suspend()
    @resume()
    console.log "in example", Kazitori.started

    # setTimeout ()=>
      # console.log "restart?", @
      # @resume()
      # console.log "in example resumed", Kazitori.started
    # , 2000

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
  window.App = new Router({'root': "/jp/"})
  console.log window.App.handlers
  # foo = new FooRouter({'isAutoStart':false})
  # window.App.appendRouter foo, '/foo/'
  # window.App.appendRouter FooRouter

  # window.App.removeRouter FooRouter

  Kai.init()
  #CSS のパスを返す
  console.log Kai.GET_CSS_PATH()
  #script のパスを返す

  #画像のパスを返す
  console.log Kai.GET_IMAGE_PATH()
  console.log Kai.GET_IMAGE_PATH(Kai.RELATIVE)

  console.log Kai.GET_SCRIPT_PATH()
  Kai.init
    scripts: "js"
  console.log Kai.GET_SCRIPT_PATH()
  # window.App.appendRouter foo, '/foo/'
  # window.App.removeRouter foo, '/foo/'
  # #チェンジイベント
  # window.App.addEventListener( KazitoriEvent.CHANGE, (event)->
  #   console.log event, "change"
  #   )

  # window.App.addEventListener( KazitoriEvent.FIRST_REQUEST, (event)->
  #   console.log event, "firstrequest"
  #   )

  # window.App.addEventListener( KazitoriEvent.PREV, (event)->
  #   console.log event, "prev"
  #   )
  # window.App.addEventListener( KazitoriEvent.NEXT, (event)->
  #   console.log event, "next"
  #   )
  # #リジェクトイベント
  # window.App.addEventListener(KazitoriEvent.REJECT, (event)->
  #   console.log event
  #   )

  # #not foudn
  window.App.addEventListener(KazitoriEvent.NOT_FOUND, (event)->
    console.log "not found"
  )

  # window.App.addEventListener(KazitoriEvent.EXECUTED, (event)->
  #   console.log event, "executed"
  #   )

  # console.log "matche check....", window.App.match('/')
  # console.log "matche check....", window.App.match('/webebebeaaa')
  # console.log window.App.params


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

  # Kai.init({'css':'hoge'})
  # console.log Kai.GET_CSS_PATH(Kai.RELATIVE)

clickHandler =(event)->
  event.preventDefault()
  target = $(event.currentTarget)
  url = target.attr('href')
  window.App.change(url)

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
