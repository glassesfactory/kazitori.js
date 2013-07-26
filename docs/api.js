YUI.add("yuidoc-meta", function(Y) {
   Y.YUIDoc = { meta: {
    "classes": [
        "EventDispatcher",
        "Kazitori",
        "KazitoriEvent",
        "Rule"
    ],
    "modules": [
        "Kazitori.js"
    ],
    "allModules": [
        {
            "displayName": "Kazitori.js",
            "name": "Kazitori.js",
            "description": "Kazitori.js は pushState をいい感じにさばいてくれるルーターライブラリです。<br>\nシンプルかつ見通しよく pushState コンテンツのルーティングを定義することができます。\n\n使い方はとても簡単。\n<ul><li>Kazitori を継承したクラスを作る</li><li>routes に扱いたい URL と、それに対応したメソッドを指定。</li><li>インスタンス化</li></ul>\n\n<h4>example</h4>\n     class Router extends Kazitori\n       routes:\n         \"/\": \"index\"\n         \"/<int:id>\": \"show\"\n\n       index:()->\n         console.log \"index!\"\n       show:(id)->\n         console.log id\n\n     $(()->\n       app = new Router()\n     )\n\nKazitori では pushState で非同期コンテンツを作っていく上で必要となるであろう機能を他にも沢山用意しています。<br>\n詳細は API 一覧から確認して下さい。"
        }
    ]
} };
});