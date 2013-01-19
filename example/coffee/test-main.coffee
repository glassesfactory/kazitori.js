class Router extends Kazitori
	beforeAnytime:['test','test2']
	befores:
		':minchi':['beforeMinchi']

	routes :
		'':'index'
		'/':'index'
		':minchi':'show'
		

	index:()->
		$('.currentPage').empty().append "this page is index"

	show:(id)->
		$('.currentPage').empty().append "this page is test" + id

	###
		some before functions
	###
	test:(hiroshi)->
		console.log "before 1", hiroshi

	beforeMinchi:()->
		console.log "before minchi"


$(document).ready ()->
	window.App = new Router({root:'/'})
	$('.test').on "click", (event)->
		event.preventDefault()
		target = event.currentTarget.pathname
		window.App.change(target)

test2 =()->
	console.log "before 2"
