kazitori.js
===============

kazitori.js は pushState を良い感じにさばいてくれるライブラリです。  
依存しているライブラリはありません。  

実装としては現状 [Backbone.js](http://backbonejs.org) の  
`Backbone.Router` と `Backbone.History` を多大に参考、もといほぼ抜き出している状態です。

そのうち最適化も含め実装が変わっていく…予定です。

先述の通り、Backbone.js を多大に参考としているため  
`Backbone.Router` のルーティングを定義するかのようにルーティングを定義できます。

使い方
----------

kazitori.js を読み込んだ上で Kazitori クラスを継承。  
routes に対して URL マップを定義。  
各 URL に対しアクセスが有った際の処理を書いていきます。

```coffee
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
		#url を変更
		window.App.change(target)
```

[こちらの記事](http://dev.hageee.net/4) でもうちょっと解説しています。  
というか使い勝手としては Backbone.Router とほぼ同じなのでそのあたりでググったほうが早いと思います。  

使い所
----------

使い所としては Backbone.js の Model や Controller といった高機能な部分はいらないけど  
pushState で良い感じに捌きたい、といった時に使います。  
IE など pushState に対応していないブラウザは自動的に #(ハッシュ) で処理されます。

jQuery.pjax との大きな違いは

* ルーティングを一覧で定義するため、どんな URL が存在しているのか見通しがいい
* /contents/1, /contents/2, /contents/3... のように動的な URL にも対応している。
* Ajax 通信と URL の書き換え(pushState処理)が分離しているのでロジックが明確になる、クリックしなくても URL が変えられる。
* それにより、URL の変更タイミングをデータ読み込みの開始前、完了後と任意で選ぶことができる。

といったことが挙げられます。

欠点という欠点といえば

* URL の書き換え処理を行うためにいちいち change メソッドを実行しなければならない煩わしさがある。

ぐらいでしょうか。


LICENSE
-------------
多大な参考元に倣って MIT License です。


要望とか
------------
こういう風にしたら使いやすいんじゃないとか  
オメーこれじっそうたりてねーよ ks! とか 
本家 Backbone.js に言いづらい or 英語分かんねーよといった方がいるのなら  
[@__hage__](https://twitter.com/__hage__) あたりに連絡を下さい。

