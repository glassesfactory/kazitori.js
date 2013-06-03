kazitori.js
===============

[![Build Status](https://travis-ci.org/glassesfactory/kazitori.js.png?branch=master)](https://travis-ci.org/glassesfactory/kazitori.js)


**Lastest version:** 0.9.9

kazitori.js は pushState を良い感じにさばいてくれるライブラリです。  
外部ライブラリへの依存は無いため、単体で使用することが出来ます。  

サンプル
[http://pstest.hageee.net](http://pstest.hageee.net)  
[http://webgl.hageee.net](http://webgl.hageee.net)

Python や Rails など他言語における Web フレームワークの挙動を参考にしています。

既存の pjax 系ライブラリと異なり、
Ajax 通信と pushState 処理が分離しています。
また、多くのサーバーサイド言語フレームワークの思想や設計を参考、それに習っています。
結果として、pushState の対象となる URL とその設計を  
明示的に示せることを実現しています。

インストール
------------

`$ git clone https://github.com/glassesfactory/kazitori.js.git`

or 

`$ npm install kazitori.js`

or 

`$ bower install kazitori.js`

または Kazitori.js を[直接ダウンロード](https://raw.github.com/glassesfactory/kazitori.js/master/src/js/kazitori.js)して下さい。



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


$(()->
  window.App = new Router({root:'/'})
  $('.test').on "click", (event)->
    event.preventDefault()
    target = event.currentTarget.pathname
    #url を変更
    window.App.change(target)
)
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
オメーこれ実装たりてねーよ ks! などありましたら  
[@__hage__](https://twitter.com/__hage__) あたりに連絡を下さい。


Change Log
--------------

**2013 06 06 ver 0.9.9**

* ネスト機能を実装しました。別々で開発していた Kazitori を、あとから結合することができます。
* サイレントモードを搭載しました。 pushState コンテンツ以外でも Kazitori をメディエイターやオブザーバー + コントローラーのような扱いで使用することができます。

**2013 04 22 ver 0.2.3**

* IE まわりで適当に実装していた部分をちゃんと実装。IE7+ で動作を確認。
* root と fragment の名前が一部被っていつつ、-(ハイフン) や _(アンダースコア) で接続されている場合、きちんと処理されない問題を解決。
* replace のバグを修正。

**2013 02 25 ver 0.2.2**

* 現在の URL にマッチするハンドラが登録されているかどうか、事前にチェックできる `match` メソッドを追加しました。
* 現在の URL パラメーター、クエリをどこからでも参照できる `params` と `queries` を実装しました。
* notFound 周りのバグを修正するとともに notFound 処理の定義方法を変更しました。
* 現在の処理を一時停止、再開する `suspend` と `resume` を実装しました。
* 変更、機能改善に伴いイベントが追加されています。

**2013 02 12 ver 0.2.1**

* URL の履歴を pushState ではなく replaceState で処理する replace メソッドを追加しました。
* `index.html` や `index.htm` など指定したファイルを root として扱う rootFiles というプロパティを追加しました。
* routes で登録したメソッドが実行されたことを通知する `EXECUTED` イベントを追加しました。
* その他細かいバグやイベント発行タイミングの不具合などを改善しました。


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


Authors
-------------------
* [@__hage__](https://twitter.com/__hage__)

Thanks for assistance and contributions:

* [@matsumos](https://twitter.com/matsumos)
* [@alumican_net](https://twitter.com/alumican_net)
