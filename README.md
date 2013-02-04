kazitori.js
===============

[![Build Status](https://travis-ci.org/glassesfactory/kazitori.js.png?branch=master)](https://travis-ci.org/glassesfactory/kazitori.js)

kazitori.js は pushState を良い感じにさばいてくれるライブラリです。  
依存している外部ライブラリなどは存在しないので  
様々なコンテンツに組み合わせることができます。  

サンプル
[http://pstest.hageee.net](http://pstest.hageee.net)

[Backbone.js](http://backbonejs.org) の  
`Backbone.Router` と `Backbone.History` にインスパイアされつつ、
Python や Rails など他言語の Web フレームワークの挙動を参考にしています。

既存の pjax 系ライブラリと異なり、
Ajax 通信と pushState が分離しています。
また、多くの Web フレームワークを参考にしていることで
pushState を活用するルーティングを明示的に示すことができます。


使い方
----------

kazitori.js を読み込んだ上で Kazitori クラスを継承。  
routes に対して URL マップを定義。  
各 URL に対しアクセスが有った際の処理を書いていきます。

```coffee
class Router extends Kazitori
	beforeAnytime:["testBefore"]
	befores:
		'/<int:id>':['testShow']
	routes :
		'/':'index'
		'/<int:id>':'show'
		'/<string:username>/<int:id>':'post'
		
	index:()->
		# console.log "index"
		$('.currentPage').empty().append "this page is index"

	show:(id)->
		# console.log id
		$('.currentPage').empty().append "this page is test" + id

	post:(username, id)->
		$('.currentPage').empty().append username + "post " + id

	###
		some before handlers
	###
	testBefore:()->
		console.log "before!"
	testShow:()->
		console.log "before show"



$(document).ready ()->
	window.App = new Router({root:'/'})
	$('.test').on "click", (event)->
		event.preventDefault()
		target = event.currentTarget.pathname
		#url を変更
		window.App.change(target)
```

[こちらの記事](http://dev.hageee.net/4) でもうちょっと解説しています。  
というか使い勝手としては `Backbone.Router` とほぼ同じなのでそのあたりでググったほうが早いと思います。  

使い所
----------

pushState で URL を管理する必要がありつつ、
ユーザー ID やエントリー ID など、URL 内に動的な要素を多く含む場合に活躍します。
IE など pushState に対応していないブラウザは自動的に #(ハッシュ) で処理されます。

既存 pjax 系ライブラリの筆頭格 jQuery.pjax との大きな違いは

* ルーティングを一覧で定義するため、どんな URL が存在しているのか見通しがいい
* /contents/1, /contents/2, /contents/3... のように動的な URL にも対応している。
* Ajax 通信と URL の書き換え(pushState処理)が分離しているのでロジックが明確になる。
* クリックだけでなく、スクロール位置が一定に達することで URL が変えられる。
* それにより、URL の変更タイミングをデータ読み込みの開始前、完了後と任意で選ぶことができる。

といったことが挙げられます。

欠点という欠点といえば

* URL の書き換え処理を行うためにいちいち `change` メソッドを実行しなければならないのが煩わしいと感じる人もいるかもしれない。

ぐらいでしょうか。


LICENSE
-------------
多大な参考元に倣って MIT License です。


要望とか
------------
こういう風にしたら使いやすいんじゃないとか  
オメーこれ実装たりてねーよ ks! とか  
本家 Backbone.js に言いづらい or 英語分かんねーよといった方がいるのなら  
[@__hage__](https://twitter.com/__hage__) あたりに連絡を下さい。


Change Log
--------------

**2013 02 04 ver 0.2**

* URL variable の型指定に対応しました。
* 併せて URL variable のネストにも対応しています。
* 型指定実現のため、URL variable の定義方法が変更になりました。
* ヒストリーバック/ネクストをする `omokazi / torikazi` メソッドを追加しました。
* 要求された URL 対し適切なコントローラーが見つからなかった場合、代替として実行させるコントローラーを指定できるようにしました。
* 0.1.3 系より、より詳細にイベントを発行するようになりました。
* おまけ程度ですがドキュメントを用意しました。
* 友人の協力により npm でのインストールに対応しました。 thanks!=>[@matsumos](https://twitter.com/matsumos)


**2013 01 28 ver 0.1.3**

* before 機能に対し、before で登録した処理が全て完了した上で routes で登録した処理が実行されるように修正。
* URL 変更時に CHANGE イベントをディスパッチするように。
* イベントオブジェクトにはそれぞれ 変更前の URL `prev` と新しい URL `next` が保持されています。


**2013 01 19 ver 0.1.2**

* バージョン名をつけました。今回から 0.1.2 です。
* routes で登録した handler が処理される前に、事前処理を行う before 機能を実装しました。
