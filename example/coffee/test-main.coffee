class Router extends Kazitori
	routes :
		'':'index'
		'/':'index'
		':id':'show'
		

	index:()->
		# console.log "index"
		$('.currentPage').empty().append "this page is index"

	show:(id)->
		# console.log id
		$('.currentPage').empty().append "this page is test" + id


$(document).ready ()->
	window.App = new Router({root:'/'})
	$('.test').on "click", (event)->
		event.preventDefault()
		target = event.currentTarget.pathname
		window.App.change(target)
