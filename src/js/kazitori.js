var Deffered, EventDispatcher, Kazitori, KazitoriEvent, Rule, VARIABLE_TYPES, delegater, escapeRegExp, genericParam, namedParam, optionalParam, routeStripper, splatParam, trailingSlash,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

delegater = function(target, func) {
  return function() {
    return func.apply(target, arguments);
  };
};

trailingSlash = /\/$/;

routeStripper = /^[#\/]|\s+$/g;

escapeRegExp = /[\-{}\[\]+?.,\\\^$|#\s]/g;

namedParam = /<(\w+|[A-Za-z_-]+:\w+)>/g;

genericParam = /([A-Za-z_-]+):(\w+)/;

optionalParam = /\((.*?)\)/g;

splatParam = /\*\w+/g;


/*URL 変数に対して指定できる型 */

VARIABLE_TYPES = [
  {
    name: "int",
    cast: Number
  }, {
    name: "string",
    cast: String
  }
];


/**
* Kazitori.js は pushState をいい感じにさばいてくれるルーターライブラリです。<br>
* シンプルかつ見通しよく pushState コンテンツのルーティングを定義することができます。
*
* 使い方はとても簡単。
* <ul><li>Kazitori を継承したクラスを作る</li><li>routes に扱いたい URL と、それに対応したメソッドを指定。</li><li>インスタンス化</li></ul>
*
* <h4>example</h4>
*      class Router extends Kazitori
*        routes:
*          "/": "index"
*          "/<int:id>": "show"
*
*        index:()->
*          console.log "index!"
*        show:(id)->
*          console.log id
*
*      $(()->
*        app = new Router()
*      )
*
* Kazitori では pushState で非同期コンテンツを作っていく上で必要となるであろう機能を他にも沢山用意しています。<br>
* 詳細は API 一覧から確認して下さい。
* @module Kazitori.js
* @main Kazitori
 */


/**
*  Kazitori のメインクラス
*
*  @class Kazitori
*  @constructor
 */

Kazitori = (function() {
  Kazitori.prototype.VERSION = "1.0.2";

  Kazitori.prototype.history = null;

  Kazitori.prototype.location = null;


  /**
  * マッチするURLのルールと、それに対応する処理を定義します。
  * <h4>example</h4>
  *     routes:
  *       '/':'index'
  *       '/<int:id>':'show'
  *
  * @property routes
  * @type Object
  * @default {}
   */

  Kazitori.prototype.routes = {};

  Kazitori.prototype.handlers = [];


  /**
  * マッチした URL に対する処理を行う前に実行したい処理を定義します。
  * @property befores
  * @type Object
  * @default {}
   */

  Kazitori.prototype.befores = {};

  Kazitori.prototype.beforeHandlers = [];


  /**
  * URL が変わる際、事前に実行したい処理を定義します。<br>
  * このプロパティに登録された処理は、与えられた URL にマッチするかどうかにかかわらず、常に実行されます。
  * @property beforeAnytimeHandler
  * @type Array
  * @default []
   */

  Kazitori.prototype.beforeAnytimeHandler = null;

  Kazitori.prototype.afterhandlers = [];


  /**
  * 特定のファイル名が URL に含まれていた時、ルートとして処理するリストです。
  * @property rootFiles
  * @type Array
   */

  Kazitori.prototype.rootFiles = ['index.html', 'index.htm', 'index.php', 'unko.html'];


  /**
  * ルートを指定します。<br>
  * ここで指定された値が URL の prefix として必ずつきます。<br>
  * 物理的に URL のルートより 1ディレクトリ下がった箇所で pushState を行いたい場合<br>
  * この値を / 以外に指定します。
  * <h4>example</h4>
  * コンテンツを配置する実ディレクトリが example だった場合
  *
  *     app = new Router({root:'/example/'})
  * @property root
  * @type String
  * @default /
   */

  Kazitori.prototype.root = null;


  /**
  * 現在の URL にマッチするルールがなかった場合に変更する URL
  * @property notFound
  * @type String
  * @default null
   */

  Kazitori.prototype.notFound = null;

  Kazitori.prototype.direct = null;

  Kazitori.prototype.isIE = false;


  /**
  * URL を実際には変更しないようにするかどうかを決定します。<br>
  * true にした場合、URL は変更されず、内部で保持している状態管理オブジェクトを基準に展開します。
  * @property silent
  * @type Boolean
  * @default false
   */

  Kazitori.prototype.silent = false;


  /**
  * pushState への監視が開始されているかどうか
  * @property started
  * @type Boolean
  * @default false
   */

  Kazitori.prototype.started = false;

  Kazitori.prototype._params = {
    params: [],
    'fragment': ''
  };


  /**
  * before 処理が失敗した時に実行されます。<br>
  * デフォルトでは空の function になっています。
  *
  * @method beforeFailedHandler
   */

  Kazitori.prototype.beforeFailedHandler = function() {};


  /*isBeforeForce */

  Kazitori.prototype.isBeforeForce = false;

  Kazitori.prototype.isTemae = false;

  Kazitori.prototype._changeOptions = null;

  Kazitori.prototype.isNotFoundForce = false;

  Kazitori.prototype._notFound = null;

  Kazitori.prototype.breaker = {};

  Kazitori.prototype._dispatcher = null;

  Kazitori.prototype._beforeDeffer = null;


  /**
  * 現在の URL を返します。
  * @property fragment
  * @type String
  * @default null
   */

  Kazitori.prototype.fragment = null;


  /**
  * 現在の URL から 1つ前の URL を返します。
  * @property lastFragment
  * @type String
  * @default null
   */

  Kazitori.prototype.lastFragment = null;

  Kazitori.prototype.isUserAction = false;

  Kazitori.prototype._isFirstRequest = true;

  Kazitori.prototype.isInitReplace = true;

  Kazitori.prototype.isLastSlash = false;


  /**
  * 一時停止しているかどうかを返します。
  *
  * @property isSuspend
  * @type Boolean
  * @default false
   */

  Kazitori.prototype.isSuspend = false;

  Kazitori.prototype._processStep = {
    'status': 'null',
    'args': []
  };

  function Kazitori(options) {
    this.observeURLHandler = __bind(this.observeURLHandler, this);
    this.beforeFailed = __bind(this.beforeFailed, this);
    this.executeHandlers = __bind(this.executeHandlers, this);
    this._executeBefores = __bind(this._executeBefores, this);
    this.beforeComplete = __bind(this.beforeComplete, this);
    var docMode, e, win;
    this._processStep.status = 'constructor';
    this._processStep.args = [options];
    this.options = options || (options = {});
    if (options.routes) {
      this.routes = options.routes;
    }
    this.root = options.hasOwnProperty("root") ? options.root : this.root === null ? '/' : this.root;
    this.isTemae = options.isTemae ? options.isTemae : false;
    this.silent = options.silent ? options.silent : false;
    this.isInitReplace = options.hasOwnProperty("isInitReplace") ? options.isInitReplace : true;
    this.isLastSlash = options.hasOwnProperty("isLastSlash") ? options.isLastSlash : false;
    this._params = {
      params: [],
      queries: {},
      fragment: null
    };
    if (this.notFound === null) {
      this.notFound = options.notFound ? options.notFound : this.root;
    }
    win = window;
    if (typeof win !== 'undefined') {
      this.location = win.location;
      this.history = win.history;
    }
    docMode = document.documentMode;
    this.isIE = win.navigator.userAgent.toLowerCase().indexOf('msie') !== -1;
    this.isOldIE = this.isIE && (!docMode || docMode < 9);
    this._dispatcher = new EventDispatcher();
    this.handlers = [];
    this.beforeHandlers = [];
    this._bindBefores();
    this._bindRules();
    this._bindNotFound();
    try {
      Object.defineProperty(this, 'params', {
        enumerable: true,
        get: function() {
          return this._params.params;
        }
      });
      Object.defineProperty(this, 'queries', {
        enumerable: true,
        get: function() {
          return this._params.queries;
        }
      });
    } catch (_error) {
      e = _error;
      if (this.isOldIE) {
        this.params = this._params.params;
        this.queries = this._params.queries;
      }
    }
    if ((this.options.isAutoStart == null) || this.options.isAutoStart !== false) {
      this.start();
    }
    return;
  }


  /**
  * Kazitori.js を開始します。<br>
  * START イベントがディスパッチされます。
  * @method start
  * @param {Object} options オプション
   */

  Kazitori.prototype.start = function(options) {
    var atRoot, fragment, frame, ieFrag, override, win;
    this._processStep.status = 'start';
    this._processStep.args = [options];
    if (this.started) {
      throw new Error('mou hazim matteru');
    }
    this.started = true;
    win = window;
    this.options = this._extend({}, {
      root: '/'
    }, this.options, options);
    this._hasPushState = !!(this.history && this.history.pushState);
    this._wantChangeHash = this.options.hashChange !== false;
    fragment = this.fragment = this.getFragment();
    atRoot = this.location.pathname.replace(/[^\/]$/, '$&/') === this.root;
    if (this.isIE && !atRoot && !this._hasPushState && this.isInitReplace) {
      ieFrag = this.location.pathname.replace(this.root, '');
      this._updateHashIE(ieFrag);
    }
    if (this.isOldIE && this._wantChangeHash) {
      frame = document.createElement("iframe");
      frame.setAttribute("src", "javascript:0");
      frame.setAttribute("tabindex", "-1");
      frame.style.display = "none";
      document.body.appendChild(frame);
      this.iframe = frame.contentWindow;
      this.change(fragment);
    }
    this._addPopStateHandler();
    if (this._hasPushState && atRoot && this.location.hash) {
      this.fragment = this.lastFragment = this.getHash().replace(routeStripper, '');
      this.history.replaceState({}, document.title, this.root + this.fragment + this.location.search);
    }
    this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.START, this.fragment));
    override = this.root;
    if (!this.silent) {
      if (!this._hasPushState && atRoot) {
        override = this.fragment;
      } else if (!atRoot) {
        override = this.fragment;
      }
    }
    return this.loadURL(override);
  };


  /**
  * Kazitori.js を停止します。<br>
  * STOP イベントがディスパッチされます。
  * @method stop
   */

  Kazitori.prototype.stop = function() {
    var win;
    win = window;
    win.removeEventListener('popstate', this.observeURLHandler);
    win.removeEventListener('hashchange', this.observeURLHandler);
    this.started = false;
    return this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.STOP, this.fragment));
  };


  /**
  * ブラウザのヒストリー機能を利用して「進む」を実行します。<br>
  * 成功した場合 NEXT イベントがディスパッチされます。
  * @method torikazi
  * @param {Object} options
   */

  Kazitori.prototype.torikazi = function(options) {
    return this.direction(options, "next");
  };


  /**
  * ブラウザヒストリー機能を利用して「戻る」を実行します。<br>
  * 成功した場合 PREV イベントがディスパッチされます。
  * @method omokazi
  * @param {Object} options
   */

  Kazitori.prototype.omokazi = function(options) {
    return this.direction(options, "prev");
  };

  Kazitori.prototype.direction = function(option, direction) {
    var tmpFrag;
    if (!this.started) {
      return false;
    }
    tmpFrag = this.lastFragment;
    this.lastFragment = this.getFragment();
    this.direct = direction;
    this.isUserAction = true;
    this._removePopStateHandler();
    if (direction === "prev") {
      this.history.back();
      this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.PREV, tmpFrag, this.lastFragment));
    } else if (direction === "next") {
      this.history.forward();
      this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.NEXT, tmpFrag, this.lastFragment));
    } else {
      return;
    }
    this._addPopStateHandler();
    return this.loadURL(tmpFrag);
  };


  /**
  * url を変更します。<br>
  * 無事 URL が切り替わった場合、CHANGE イベントがディスパッチされます。
  * <h4>example</h4>
  *     app.change('/someurl');
  * @method change
  * @param {String} fragment 変更したい URL
  * @param {Object} options オプション
   */

  Kazitori.prototype.change = function(fragment, options) {
    var frag, matched, next, url;
    if (!this.started) {
      return false;
    }
    this._processStep.status = 'change';
    this._processStep.args = [fragment, options];
    if (!options) {
      options = {
        'trigger': options
      };
    }
    this._changeOptions = options;
    this.isBeforeForce = options.isBeforeForce !== false;
    frag = this.getFragment(fragment || '');
    if (this.fragment === frag) {
      return;
    }
    this.lastFragment = this.fragment;
    this.fragment = frag;
    next = this.fragment;
    url = this.root + this._replace.apply(frag, [routeStripper, '']);
    matched = this._matchCheck(this.fragment, this.handlers);
    if (matched === false && this.isNotFoundForce === false) {
      if (this.notFound !== null) {
        this._notFound.callback(this.fragment);
        url = this.root + this._notFound.rule.replace(routeStripper, '');
        this.history[options.replace ? 'replaceState' : 'pushState']({}, document.title, url);
      }
      this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.NOT_FOUND));
      return;
    }
    if (this.isTemae && (this.beforeAnytimeHandler || this.beforeHandlers.length > 0)) {
      this._executeBefores(frag);
    } else {
      this._urlChange(frag, options);
    }
  };


  /**
  * pushState ではなく replaceState で処理します。<br>
  * replaceState は現在の URL を置き換えるため、履歴には追加されません。
  * <h4>example</h4>
  *     app.replace('/someurl');
  * @method replace
  * @param {String} fragment 変更したい URL
  * @param {Object} options オプション
   */

  Kazitori.prototype.replace = function(fragment, options) {
    this._processStep.status = 'replace';
    this._processStep.args = [fragment, options];
    if (!options) {
      options = {
        replace: true
      };
    } else if (!options.replace || options.replace === false) {
      options.replace = true;
    }
    this.change(fragment, options);
  };

  Kazitori.prototype._urlChange = function(fragment, options) {
    var url;
    this._processStep.status = '_urlChange';
    this._processStep.args = [fragment, options];
    if (this.isSuspend) {
      return;
    }
    if (!options) {
      options = this._changeOptions;
    }
    url = this.root + this.fragment.replace(routeStripper, '');
    if (this.isLastSlash) {
      url += "/";
    }
    if (!this.silent) {
      if (this._hasPushState) {
        this.history[options.replace ? 'replaceState' : 'pushState']({}, document.title, url);
      } else if (this._wantChangeHash) {
        this._updateHash(this.location, fragment, options.replace);
        if (this.iframe && (fragment !== this.getFragment(this.getHash(this.iframe)))) {
          if (!options.replace) {
            this.iframe.document.open().close();
          }
          this._updateHash(this.iframe.location, fragment, options.replace);
        }
      } else {
        return this.location.assign(url);
      }
    }
    this.dispatchEvent(new KazitoriEvent(KazitoriEvent.CHANGE, this.fragment, this.lastFragment));
    if (options.internal && options.internal === true) {
      this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.INTERNAL_CHANGE, this.fragment, this.lastFragment));
    }
    return this.loadURL(this.fragment, options);
  };


  /**
  * 中止します。
  * @method reject
   */

  Kazitori.prototype.reject = function() {
    this.dispatchEvent(new KazitoriEvent(KazitoriEvent.REJECT, this.fragment));
    if (this._beforeDeffer) {
      this._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, this.beforeComplete);
      this._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_FAILED, this.beforeFailed);
      this._beforeDeffer = null;
    }
  };


  /**
  * 処理を一時停止します。<br>
  * SUSPEND イベントがディスパッチされます。
  * @method suspend
   */

  Kazitori.prototype.suspend = function() {
    if (this._beforeDeffer != null) {
      this._beforeDeffer.suspend();
    }
    this.started = false;
    this.isSuspend = true;
    this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.SUSPEND, this.fragment, this.lastFragment));
  };


  /**
  * 処理を再開します。<br>
  * RESUME イベントがディスパッチされます。
  * @method resume
   */

  Kazitori.prototype.resume = function() {
    if (this._beforeDeffer != null) {
      this._beforeDeffer.resume();
    }
    this.started = true;
    this.isSuspend = false;
    this[this._processStep.status](this._processStep.args);
    this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.RESUME, this.fragment, this.lastFragment));
  };

  Kazitori.prototype.registerHandler = function(rule, name, isBefore, callback) {
    var child, e, target;
    if (!callback) {
      if (isBefore) {
        callback = this._bindFunctions(name);
      } else if (name instanceof Kazitori) {
        this._bindChild(rule, name);
        return this;
      } else if (typeof name === "function") {
        if (name.hasOwnProperty('__super__')) {
          try {
            child = new name({
              'isAutoStart': false
            });
            this._bindChild(rule, child);
            return this;
          } catch (_error) {
            e = _error;
            callback = name;
          }
        } else {
          callback = name;
        }
      } else {
        callback = this[name];
      }
    }
    target = isBefore ? this.beforeHandlers : this.handlers;
    target.unshift(new Rule(rule, function(fragment) {
      var args;
      args = this.router.extractParams(this, fragment);
      return callback && callback.apply(this.router, args);
    }, this));
    return this;
  };

  Kazitori.prototype._bindChild = function(rule, child) {
    var childBefore, childBefores, childHandlers, childRule, _i, _j, _len, _len1;
    child.reject();
    child.stop();
    childHandlers = child.handlers.concat();
    for (_i = 0, _len = childHandlers.length; _i < _len; _i++) {
      childRule = childHandlers[_i];
      childRule.update(rule);
    }
    this.handlers = childHandlers.concat(this.handlers);
    childBefores = child.beforeHandlers.concat();
    for (_j = 0, _len1 = childBefores.length; _j < _len1; _j++) {
      childBefore = childBefores[_j];
      childBefore.update(rule);
    }
    this.beforeHandlers = childBefores.concat(this.beforeHandlers);
    if (child.beforeAnytimeHandler) {
      this.lastAnytime = this.beforeAnytime.concat();
      return this._bindBeforeAnytime(this.beforeAnytime, [child.beforeAnytimeHandler.callback]);
    }
  };


  /**
  * ルーターを動的に追加します。<br>
  * ルーターの追加に成功した場合、ADDED イベントがディスパッチされます。
  * <h4>example</h4>
  *     fooRouter = new FooRouter();
  *     app.appendRouter(foo);
  * @method appendRouter
  * @param {Object} child
  * @param {String} childRoot
   */

  Kazitori.prototype.appendRouter = function(child, childRoot) {
    var e, rule, _instance;
    if (!child instanceof Kazitori && typeof child !== "function") {
      throw new Error("引数の値が不正です。 引数として与えられるオブジェクトは Kazitori を継承している必要があります。");
      return;
    }
    if (child instanceof Kazitori) {
      rule = this._getChildRule(child, childRoot);
      this._bindChild(rule, child);
      return this;
    } else {
      if (child.hasOwnProperty('__super__')) {
        try {
          _instance = new child({
            'isAutoStart': false
          });
          rule = this._getChildRule(_instance, childRoot);
          this._bindChild(rule, _instance);
          return this;
        } catch (_error) {
          e = _error;
          throw new Error("引数の値が不正です。 引数として与えられるオブジェクトは Kazitori を継承している必要があります。");
        }
      }
    }
    this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.ADDED, this.fragment, this.lastFragment));
    return this;
  };

  Kazitori.prototype._getChildRule = function(child, childRoot) {
    var rule;
    rule = child.root;
    if (childRoot) {
      rule = childRoot;
    }
    if (rule.match(trailingSlash)) {
      rule = rule.replace(trailingSlash, '');
    }
    if (rule === this.root) {
      throw new Error("かぶってる");
    }
    return rule;
  };


  /**
  * 動的に追加したルーターを削除します。
  * ルーターの削除に成功した場合、REMOVED イベントがディスパッチされます。
  * <h4>example</h4>
  *     foo = new FooRouter();
  *     app.appendRouter(foo);
  *     app.removeRouter(foo);
  * @method removeRouter
  * @param {Object} child
  * @param {String} childRoot
   */

  Kazitori.prototype.removeRouter = function(child, childRoot) {
    var e, _instance;
    if (!child instanceof Kazitori && typeof child !== "function") {
      throw new Error("引数の値が不正です。 引数として与えられるオブジェクトは Kazitori を継承している必要があります。");
      return;
    }
    if (child instanceof Kazitori) {
      this._unbindChild(child, childRoot);
    } else {
      if (child.hasOwnProperty('__super__')) {
        try {
          _instance = new child({
            'isAutoStart': false
          });
          this._unbindChild(_instance, childRoot);
          return this;
        } catch (_error) {
          e = _error;
          throw new Error("引数の値が不正です。 引数として与えられるオブジェクトは Kazitori を継承している必要があります。");
        }
      }
    }
    this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.REMOVED, this.fragment, this.lastFragment));
    return this;
  };

  Kazitori.prototype._unbindChild = function(child, childRoot) {
    var beforeRule, i, len, newBefores, newHandlers, rule, ruleObj;
    rule = this._getChildRule(child, childRoot);
    i = 0;
    len = this.handlers.length;
    newHandlers = [];
    while (i < len) {
      ruleObj = this.handlers.shift();
      if ((ruleObj.rule.match(rule)) === null) {
        newHandlers.unshift(ruleObj);
      }
      i++;
    }
    this.handlers = newHandlers;
    i = 0;
    len = this.beforeHandlers.length;
    newBefores = [];
    while (i < len) {
      beforeRule = this.beforeHandlers.shift();
      if ((beforeRule.rule.match(rule)) === null) {
        newBefores.unshift(beforeRule);
      }
      i++;
    }
    return this.beforeHandlers = newBefores;
  };


  /**
  * ブラウザから現在の URL を読み込みます。
  * @method loadURL
  * @param {String} fragmentOverride
  * @param {Object} options
   */

  Kazitori.prototype.loadURL = function(fragmentOverride, options) {
    var fragment;
    this._processStep.status = 'loadURL';
    this._processStep.args = [fragmentOverride, options];
    if (this.isSuspend) {
      return;
    }
    fragment = this.fragment = this.getFragment(fragmentOverride);
    if (this.isTemae === false && (this.beforeAnytimeHandler || this.beforeHandlers.length > 0)) {
      this._executeBefores(fragment);
    } else {
      this.executeHandlers();
    }
  };


  /**
  * 指定した 文字列に対応した URL ルールが設定されているかどうか<br>
  * Boolean で返します。
  * <h4>example</h4>
  *     app.match('/hoge');
  * @method match
  * @param {String} fragment
  * @return {Boolean}
   */

  Kazitori.prototype.match = function(fragment) {
    var matched;
    matched = this._matchCheck(fragment, this.handlers, true);
    return matched.length > 0;
  };

  Kazitori.prototype.beforeComplete = function(event) {
    this._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, this.beforeComplete);
    this._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_FAILED, this.beforeFailed);
    this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.BEFORE_EXECUTED, this.fragment, this.lastFragment));
    if (this.isTemae) {
      this._urlChange(this.fragment, this._changeOptions);
    } else {
      this.executeHandlers();
    }
  };

  Kazitori.prototype._executeBefores = function(fragment) {
    var handler, matched, _i, _len;
    this._processStep.status = '_executeBefores';
    this._processStep.args = [fragment];
    this._beforeDeffer = new Deffered();
    if (this.beforeAnytimeHandler != null) {
      this._beforeDeffer.deffered((function(_this) {
        return function(d) {
          _this.beforeAnytimeHandler.callback(fragment);
          d.execute(d);
        };
      })(this));
    }
    matched = this._matchCheck(fragment, this.beforeHandlers);
    for (_i = 0, _len = matched.length; _i < _len; _i++) {
      handler = matched[_i];
      this._beforeDeffer.deffered(function(d) {
        handler.callback(fragment);
        d.execute(d);
      });
    }
    this._beforeDeffer.addEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, this.beforeComplete);
    this._beforeDeffer.addEventListener(KazitoriEvent.TASK_QUEUE_FAILED, this.beforeFailed);
    return this._beforeDeffer.execute(this._beforeDeffer);
  };

  Kazitori.prototype.executeHandlers = function() {
    var handler, isMatched, match, matched, _i, _j, _len, _len1;
    this._processStep.status = 'executeHandlers';
    this._processStep.args = [];
    if (this.isSuspend) {
      return;
    }
    matched = this._matchCheck(this.fragment, this.handlers);
    isMatched = true;
    if (matched === false || matched.length < 1) {
      if (this.notFound !== null) {
        this._notFound.callback(this.fragment);
      }
      isMatched = false;
      this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.NOT_FOUND));
    } else if (matched.length > 1) {
      for (_i = 0, _len = matched.length; _i < _len; _i++) {
        match = matched[_i];
        if (this.fragment.indexOf(match.rule) > -1) {
          match.callback(this.fragment);
        }
      }
    } else {
      for (_j = 0, _len1 = matched.length; _j < _len1; _j++) {
        handler = matched[_j];
        handler.callback(this.fragment);
      }
    }
    if (this._isFirstRequest) {
      setTimeout((function(_this) {
        return function() {
          _this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.FIRST_REQUEST, _this.fragment, null));
          if (isMatched) {
            return _this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.EXECUTED, _this.fragment, null));
          }
        };
      })(this), 0);
      this._isFirstRequest = false;
    } else {
      if (isMatched) {
        this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.EXECUTED, this.fragment, this.lastFragment));
      }
    }
    return matched;
  };

  Kazitori.prototype.beforeFailed = function(event) {
    this.beforeFailedHandler.apply(this, arguments);
    this._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_FAILED, this.beforeFailed);
    this._beforeDeffer.removeEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, this.beforeComplete);
    if (this.isBeforeForce) {
      this.beforeComplete();
    }
    this._beforeDeffer = null;
  };

  Kazitori.prototype.observeURLHandler = function(event) {
    var current;
    current = this.getFragment();
    if (current === this.fragment && this.iframe) {
      current = this.getFragment(this.getHash(this.iframe));
    }
    if (current === this.fragment) {
      return false;
    }
    if (this.iframe) {
      this.change(current);
    }
    if (this.lastFragment === current && this.isUserAction === false) {
      this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.PREV, current, this.fragment));
    } else if (this.lastFragment === this.fragment && this.isUserAction === false) {
      this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.NEXT, current, this.lastFragment));
    }
    this.isUserAction = false;
    this._dispatcher.dispatchEvent(new KazitoriEvent(KazitoriEvent.CHANGE, current, this.lastFragment));
    return this.loadURL(current);
  };

  Kazitori.prototype._bindRules = function() {
    var routes, rule, _i, _len;
    if (this.routes == null) {
      return;
    }
    routes = this._keys(this.routes);
    for (_i = 0, _len = routes.length; _i < _len; _i++) {
      rule = routes[_i];
      this.registerHandler(rule, this.routes[rule], false);
    }
  };

  Kazitori.prototype._bindBefores = function() {
    var befores, key, _i, _len;
    if (this.beforeAnytime) {
      this._bindBeforeAnytime(this.beforeAnytime);
    }
    if (this.befores == null) {
      return;
    }
    befores = this._keys(this.befores);
    for (_i = 0, _len = befores.length; _i < _len; _i++) {
      key = befores[_i];
      this.registerHandler(key, this.befores[key], true);
    }
  };

  Kazitori.prototype._bindBeforeAnytime = function(funcs, bindedFuncs) {
    var callback;
    callback = this._bindFunctions(funcs, bindedFuncs);
    return this.beforeAnytimeHandler = {
      callback: this._binder(function(fragment) {
        var args;
        args = [fragment];
        return callback && callback.apply(this, args);
      }, this)
    };
  };

  Kazitori.prototype._bindNotFound = function() {
    var callback, notFoundFragment, notFoundFuncName, rule, _i, _len, _ref;
    if (this.notFound == null) {
      return;
    }
    if (typeof this.notFound === "string") {
      _ref = this.handlers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        rule = _ref[_i];
        if (rule.rule === '/' + this.notFound.replace(this.root, '')) {
          this._notFound = rule;
          return;
        }
      }
    } else {
      notFoundFragment = this._keys(this.notFound)[0];
    }
    notFoundFuncName = this.notFound[notFoundFragment];
    if (typeof notFoundFuncName === "function") {
      callback = notFoundFuncName;
    } else {
      callback = this[notFoundFuncName];
    }
    this._notFound = new Rule(notFoundFragment, function(fragment) {
      var args;
      args = this.router.extractParams(this, fragment);
      return callback && callback.apply(this.router, args);
    }, this);
  };

  Kazitori.prototype._updateHash = function(location, fragment, replace) {
    var atRoot, href;
    atRoot = this.location.pathname.replace(/[^\/]$/, '$&/') === this.root;
    if (!atRoot) {
      location.replace(this.root + '#' + fragment);
      return;
    }
    if (replace) {
      href = location.href.replace(/(javascript:|#).*$/, '');
      location.replace(href + '#' + fragment);
    } else {
      location.hash = "#" + fragment;
    }
  };

  Kazitori.prototype._updateHashIE = function(fragment, replace) {
    return location.replace(this.root + '#/' + fragment);
  };

  Kazitori.prototype._matchCheck = function(fragment, handlers, test) {
    var a, args, argsMatch, argsMatched, handler, hasQuery, i, len, match, matched, t, tmpFrag, _i, _j, _len, _len1;
    if (test == null) {
      test = false;
    }
    matched = [];
    tmpFrag = fragment;
    if (tmpFrag !== void 0 && tmpFrag !== 'undefined') {
      hasQuery = this._match.apply(tmpFrag, [/(\?[\w\d=|]+)/g]);
    }
    if (hasQuery) {
      fragment = fragment.split('?')[0];
    }
    for (_i = 0, _len = handlers.length; _i < _len; _i++) {
      handler = handlers[_i];
      if (handler.rule === fragment) {
        matched.push(handler);
      } else if (handler.test(fragment)) {
        if (handler.isVariable && handler.types.length > 0) {
          args = this.extractParams(handler, fragment, test);
          argsMatch = [];
          len = args.length;
          i = 0;
          while (i < len) {
            a = args[i];
            t = handler.types[i];
            if (typeof a !== "object") {
              if (t === null) {
                argsMatch.push(true);
              } else {
                argsMatch.push(this._typeCheck(a, t));
              }
            }
            i++;
          }
          argsMatched = true;
          for (_j = 0, _len1 = argsMatch.length; _j < _len1; _j++) {
            match = argsMatch[_j];
            if (!match) {
              argsMatched = false;
            }
          }
          if (argsMatched) {
            matched.push(handler);
          }
        } else {
          matched.push(handler);
        }
      }
    }
    if (matched.length > 0) {
      return matched;
    } else {
      return false;
    }
  };


  /**
  * URL ルート以下を取得
  * @method getFragment
  * @param {String} fragment
   */

  Kazitori.prototype.getFragment = function(fragment) {
    var frag, index, matched, root, _i, _len, _ref;
    if ((fragment == null) || fragment === void 0) {
      if (this._hasPushState || !this._wantChangeHash) {
        fragment = this.location.pathname;
        matched = false;
        frag = fragment;
        if (frag.match(/^\//)) {
          frag = frag.substr(1);
        }
        root = this.root;
        if (root.match(/^\//)) {
          root = root.substr(1);
        }
        _ref = this.rootFiles;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          index = _ref[_i];
          if (index === frag || root + index === frag) {
            matched = true;
          }
        }
        if (matched) {
          fragment = this.root;
        }
        fragment = fragment + this.location.search;
        root = this.root.replace(trailingSlash, '');
        if (fragment.indexOf(root) > -1) {
          fragment = fragment.substr(root.length);
        }
      } else {
        fragment = this.getHash();
      }
    } else {
      root = this.root.replace(trailingSlash, '');
      if (fragment.indexOf(this.root) > -1 && fragment.indexOf(root) > -1) {
        fragment = fragment.substr(root.length);
      }
    }
    if (typeof fragment === "string") {
      fragment = fragment.replace(trailingSlash, '');
      if (fragment === "") {
        fragment = "/";
      }
    }
    return fragment;
  };


  /**
  * URL の # 以降を取得
  * @method getHash
  * @return {String} URL の # 以降の文字列
   */

  Kazitori.prototype.getHash = function() {
    var match;
    match = (window || this).location.href.match(/#(.*)$/);
    if (match != null) {
      return match[1];
    } else {
      return '';
    }
  };


  /**
  * URL パラメータを分解
  * @method extractParams
  * @param {Rule} rule
  * @param {String} fragment
  * @param {Boolean} test
   */

  Kazitori.prototype.extractParams = function(rule, fragment, test) {
    var k, kv, last, newParam, newQueries, param, q, queries, query, queryParams, v, _i, _len;
    if (test == null) {
      test = false;
    }
    if (this._params.params.length > 0 && this._params.fragment === fragment) {
      return this._params.params;
    }
    param = rule._regexp.exec(fragment);
    if (param === null && fragment.indexOf('?') > -1) {
      param = [0, '?' + fragment.split('?')[1]];
    }
    this._params.fragment = fragment;
    if (param != null) {
      newParam = param.slice(1);
      last = param[param.length - 1];
      if (last.indexOf('?') > -1) {
        newQueries = {};
        queries = last.split('?')[1];
        queryParams = queries.split('&');
        for (_i = 0, _len = queryParams.length; _i < _len; _i++) {
          query = queryParams[_i];
          kv = query.split('=');
          k = kv[0];
          v = kv[1] ? kv[1] : "";
          if (v.indexOf('|') > -1) {
            v = v.split("|");
          }
          newQueries[k] = v;
        }
        newParam.pop();
        newParam.push(last.split('?')[0]);
        q = {
          "queries": newQueries
        };
        newParam.push(q);
        if (!test) {
          this._params.params = this._getCastedParams(rule, newParam.slice(0));
          this._params.queries = newQueries;
          if (this.isOldIE) {
            this.params = this._params.params;
            this.queries = this._params.queries;
          }
        }
      } else {
        if (!test) {
          this._params.params = this._getCastedParams(rule, newParam);
          if (this.isOldIE) {
            this.params = this._params.params;
          }
        }
      }
      return newParam;
    } else {
      this._params.params = [];
      if (this.isOldIE) {
        this.param = [];
      }
      return null;
    }
  };

  Kazitori.prototype._getCastedParams = function(rule, params) {
    var castedParams, i, len, type, _i, _len;
    i = 0;
    if (!params) {
      return params;
    }
    if (rule.types.length < 1) {
      return params;
    }
    len = params.length;
    castedParams = [];
    while (i < len) {
      if (rule.types[i] === null) {
        castedParams.push(params[i]);
      } else if (typeof params[i] === "object") {
        castedParams.push(params[i]);
      } else {
        for (_i = 0, _len = VARIABLE_TYPES.length; _i < _len; _i++) {
          type = VARIABLE_TYPES[_i];
          if (rule.types[i] === type.name) {
            castedParams.push(type.cast(params[i]));
          }
        }
      }
      i++;
    }
    return castedParams;
  };

  Kazitori.prototype.addEventListener = function(type, listener) {
    return this._dispatcher.addEventListener(type, listener);
  };

  Kazitori.prototype.removeEventListener = function(type, listener) {
    return this._dispatcher.removeEventListener(type, listener);
  };

  Kazitori.prototype.dispatchEvent = function(event) {
    return this._dispatcher.dispatchEvent(event);
  };

  Kazitori.prototype._addPopStateHandler = function() {
    var win;
    win = window;
    if (this._hasPushState === true) {
      win.addEventListener('popstate', this.observeURLHandler);
    }
    if (this._wantChangeHash === true && !this.isOldIE) {
      return win.addEventListener('hashchange', this.observeURLHandler);
    } else if (this._wantChangeHash === true) {
      return win.attachEvent('onhashchange', this.observeURLHandler);
    }
  };

  Kazitori.prototype._removePopStateHandler = function() {
    var win;
    win = window;
    win.removeEventListener('popstate', this.observeURLHandler);
    win.removeEventListener('hashchange', this.observeURLHandler);
    if (this.isOldIE) {
      return win.detachEvent('onhashchange', this.observeURLHandler);
    }
  };

  Kazitori.prototype._slice = Array.prototype.slice;

  Kazitori.prototype._replace = String.prototype.replace;

  Kazitori.prototype._match = String.prototype.match;

  Kazitori.prototype._keys = Object.keys || function(obj) {
    var key, keys;
    if (obj === !Object(obj)) {
      throw new TypeError('object ja nai');
    }
    keys = [];
    for (key in obj) {
      if (Object.hasOwnProperty.call(obj, key)) {
        keys[keys.length] = key;
      }
    }
    return keys;
  };

  Kazitori.prototype._binder = function(func, obj) {
    var args, slice;
    slice = this._slice;
    args = slice.call(arguments, 2);
    return function() {
      return func.apply(obj || {}, args.concat(slice.call(arguments)));
    };
  };

  Kazitori.prototype._extend = function(obj) {
    this._each(this._slice.call(arguments, 1), function(source) {
      var prop, _results;
      if (source) {
        _results = [];
        for (prop in source) {
          _results.push(obj[prop] = source[prop]);
        }
        return _results;
      }
    });
    return obj;
  };

  Kazitori.prototype._each = function(obj, iter, ctx) {
    var each, i, k, l;
    if (obj == null) {
      return;
    }
    each = Array.prototype.forEach;
    if (each && obj.forEach === each) {
      return obj.forEach(iter, ctx);
    } else if (obj.length === +obj.length) {
      i = 0;
      l = obj.length;
      while (i < l) {
        if (iter.call(ctx, obj[i], i, obj) === this.breaker) {
          return;
        }
        i++;
      }
    } else {
      for (k in obj) {
        if (__indexOf.call(obj, k) >= 0) {
          if (iter.call(ctx, obj[k], k, obj) === this.breaker) {
            return;
          }
        }
      }
    }
  };

  Kazitori.prototype._bindFunctions = function(funcs, insert) {
    var bindedFuncs, callback, f, func, funcName, i, len, names, newF, _i, _len;
    if (typeof funcs === 'string') {
      funcs = funcs.split(',');
    }
    bindedFuncs = [];
    for (_i = 0, _len = funcs.length; _i < _len; _i++) {
      funcName = funcs[_i];
      func = this[funcName];
      if (func == null) {
        names = funcName.split('.');
        if (names.length > 1) {
          f = window[names[0]];
          i = 1;
          len = names.length;
          while (i < len) {
            newF = f[names[i]];
            if (newF != null) {
              f = newF;
              i++;
            } else {
              break;
            }
          }
          func = f;
        } else {
          func = window[funcName];
        }
      }
      if (func != null) {
        bindedFuncs.push(func);
      }
    }
    if (insert) {
      bindedFuncs = insert.concat(bindedFuncs);
    }
    callback = function() {
      var args, _j, _len1;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      for (_j = 0, _len1 = bindedFuncs.length; _j < _len1; _j++) {
        func = bindedFuncs[_j];
        func.apply(this, __slice.call(args));
      }
    };
    return callback;
  };

  Kazitori.prototype._typeCheck = function(a, t) {
    var matched, type, _i, _len;
    matched = false;
    for (_i = 0, _len = VARIABLE_TYPES.length; _i < _len; _i++) {
      type = VARIABLE_TYPES[_i];
      if (t.toLowerCase() === type.name) {
        if (type.cast(a)) {
          matched = true;
        }
      }
    }
    return matched;
  };

  return Kazitori;

})();


/**
* pushState で処理したいルールを定義するクラス
*
* @class Rule
* @constructor
* @param {String} rule
* @param {Function} callback
* @param {Kazitori} router
 */

Rule = (function() {

  /**
  * ルール文字列
  * @property rule
  * @type String
  * @default ""
   */
  Rule.prototype.rule = "";

  Rule.prototype._regexp = null;


  /**
  * コールバック関数
  * ルールとマッチする場合実行されます。
  * @property callback
  * @type: Function
  * @default null
   */

  Rule.prototype.callback = null;

  Rule.prototype.name = "";

  Rule.prototype.router = null;

  Rule.prototype.isVariable = false;

  Rule.prototype.types = [];

  function Rule(rule, callback, router) {
    this.update = __bind(this.update, this);
    if (typeof rule !== "string" && typeof rule !== "Number") {
      return;
    }
    this.callback = callback;
    this.router = router;
    this.update(rule);
  }


  /**
  * Rule として定義したパターンと fragment として与えられた文字列がマッチするかどうかテストする
  * @method test
  * @param {String} fragment
  * @return {Boolean} マッチする場合 true を返す
   */

  Rule.prototype.test = function(fragment) {
    return this._regexp.test(fragment);
  };

  Rule.prototype._ruleToRegExp = function(rule) {
    var newRule;
    newRule = rule.replace(escapeRegExp, '\\$&').replace(optionalParam, '(?:$1)?').replace(namedParam, '([^\/]+)').replace(splatParam, '(.*?)');
    return new RegExp('^' + newRule + '$');
  };


  /**
  * 与えられた path で現在の Rule をアップデートします。
  * @method update
  * @param {String} path
   */

  Rule.prototype.update = function(path) {
    var m, matched, re, t, _i, _len, _results;
    this.rule = path + this.rule;
    if (this.rule !== '/') {
      this.rule = this.rule.replace(trailingSlash, '');
    }
    this._regexp = this._ruleToRegExp(this.rule);
    re = new RegExp(namedParam);
    matched = path.match(re);
    if (matched !== null) {
      this.isVariable = true;
      _results = [];
      for (_i = 0, _len = matched.length; _i < _len; _i++) {
        m = matched[_i];
        t = m.match(genericParam) || null;
        _results.push(this.types.push(t !== null ? t[1] : null));
      }
      return _results;
    }
  };

  return Rule;

})();


/**
* イベントディスパッチャ
* @class EventDispatcher
* @constructor
 */

EventDispatcher = (function() {
  function EventDispatcher() {}

  EventDispatcher.prototype.listeners = {};

  EventDispatcher.prototype.addEventListener = function(type, listener) {
    if (this.listeners[type] === void 0) {
      this.listeners[type] = [];
    }
    if (this._inArray(listener, this.listeners[type]) < 0) {
      this.listeners[type].push(listener);
    }
  };

  EventDispatcher.prototype.removeEventListener = function(type, listener) {
    var arr, i, len, prop;
    len = 0;
    for (prop in this.listeners) {
      len++;
    }
    if (len < 1) {
      return;
    }
    arr = this.listeners[type];
    if (!arr) {
      return;
    }
    i = 0;
    len = arr.length;
    while (i < len) {
      if (arr[i] === listener) {
        if (len === 1) {
          delete this.listeners[type];
        } else {
          arr.splice(i, 1);
        }
        break;
      }
      i++;
    }
  };

  EventDispatcher.prototype.dispatchEvent = function(event) {
    var ary, handler, _i, _len;
    ary = this.listeners[event.type];
    if (ary !== void 0) {
      event.target = this;
      for (_i = 0, _len = ary.length; _i < _len; _i++) {
        handler = ary[_i];
        handler.call(this, event);
      }
    }
  };

  EventDispatcher.prototype._inArray = function(elem, array) {
    var i, len;
    i = 0;
    len = array.length;
    while (i < len) {
      if (array[i] === elem) {
        return i;
      }
      i++;
    }
    return -1;
  };

  return EventDispatcher;

})();

Deffered = (function(_super) {
  __extends(Deffered, _super);

  Deffered.prototype.queue = [];

  Deffered.prototype.isSuspend = false;

  function Deffered() {
    this.queue = [];
    this.isSuspend = false;
  }

  Deffered.prototype.deffered = function(func) {
    this.queue.push(func);
    return this;
  };

  Deffered.prototype.execute = function() {
    var error, task;
    if (this.isSuspend) {
      return;
    }
    try {
      task = this.queue.shift();
      if (task) {
        task.apply(this, arguments);
      }
      if (this.queue.length < 1) {
        this.queue = [];
        return this.dispatchEvent(new KazitoriEvent(KazitoriEvent.TASK_QUEUE_COMPLETE));
      }
    } catch (_error) {
      error = _error;
      return this.reject(error);
    }
  };

  Deffered.prototype.reject = function(error) {
    var message;
    message = !error ? "user reject" : error;
    this.dispatchEvent({
      type: KazitoriEvent.TASK_QUEUE_FAILED,
      index: this.index,
      message: message
    });
    return this.isSuspend = false;
  };

  Deffered.prototype.suspend = function() {
    this.isSuspend = true;
  };

  Deffered.prototype.resume = function() {
    this.isSuspend = false;
    this.execute();
  };

  return Deffered;

})(EventDispatcher);


/**
* pushState 処理や Kazitori にまつわるイベント
* @class KazitoriEvent
* @constructor
* @param {String} type
* @param {String} next
* @param {String} prev
 */

KazitoriEvent = (function() {
  KazitoriEvent.prototype.next = null;

  KazitoriEvent.prototype.prev = null;

  KazitoriEvent.prototype.type = null;

  function KazitoriEvent(type, next, prev) {
    this.type = type;
    this.next = next;
    this.prev = prev;
  }

  KazitoriEvent.prototype.clone = function() {
    return new KazitoriEvent(this.type, this.next, this.prev);
  };

  KazitoriEvent.prototype.toString = function() {
    return "KazitoriEvent :: " + "type:" + this.type + " next:" + String(this.next) + " prev:" + String(this.prev);
  };

  return KazitoriEvent;

})();


/**
* タスクキューが空になった
* @property TASK_QUEUE_COMPLETE
* @type String
* @default task_queue_complete
 */

KazitoriEvent.TASK_QUEUE_COMPLETE = 'task_queue_complete';


/**
* タスクキューが中断された
* @property TASK_QUEUE_FAILED
* @type String
* @default task_queue_failed
 */

KazitoriEvent.TASK_QUEUE_FAILED = 'task_queue_failed';


/**
* URL が変更された
* @property CHANGE
* @type String
* @default change
 */

KazitoriEvent.CHANGE = 'change';


/**
* URL に登録されたメソッドがちゃんと実行された
* @property EXECUTED
* @type String
* @default executed
 */

KazitoriEvent.EXECUTED = 'executed';


/**
* 事前処理が完了した
* @property BEFORE_EXECUTED
* @type String
* @default before_executed
 */

KazitoriEvent.BEFORE_EXECUTED = 'before_executed';


/**
* ユーザーアクション以外で URL の変更があった
* @property INTERNAL_CHANGE
* @type String
* @default internal_change
 */

KazitoriEvent.INTERNAL_CHANGE = 'internal_change';

KazitoriEvent.USER_CHANGE = 'user_change';


/**
* ヒストリーバックした
* @property PREV
* @type String
* @default prev
 */

KazitoriEvent.PREV = 'prev';


/**
* ヒストリーネクストした時
* @property NEXT
* @type String
* @default next
 */

KazitoriEvent.NEXT = 'next';


/**
* Kazitori が中断した
* @property REJECT
* @type String
* @default reject
 */

KazitoriEvent.REJECT = 'reject';


/**
* URL にマッチする処理が見つからなかった
* @property NOT_FOUND
* @type String
* @default not_found
 */

KazitoriEvent.NOT_FOUND = 'not_found';


/**
* Kazitori が開始した
* @property START
* @type String
* @default start
 */

KazitoriEvent.START = 'start';


/**
* Kazitori が停止した
* @property STOP
* @type String
* @default stop
 */

KazitoriEvent.STOP = 'stop';


/**
* Kazitori が一時停止した
* @property SUSPEND
* @type String
* @default SUSPEND
 */

KazitoriEvent.SUSPEND = 'SUSPEND';


/**
* Kazitori が再開した
* @property RESUME
* @type String
* @default resume
 */

KazitoriEvent.RESUME = 'resume';


/**
* Kazitori が開始してから、一番最初のアクセスがあった
* @property FIRST_REQUEST
* @type String
* @default first_request
 */

KazitoriEvent.FIRST_REQUEST = 'first_request';


/**
* ルーターが追加された
* @property ADDED
* @type String
* @default added
 */

KazitoriEvent.ADDED = 'added';


/**
* ルーターが削除された
* @property REMOVED
* @type String
* @default removed
 */

KazitoriEvent.REMOVED = 'removed';
