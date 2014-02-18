var BarRouter, COOKIE_KEY, FooRouter, PASS, Router, USER, clickHandler, getCookie, isLoaded, nextHandler, prevHandler, setCookie, test2, test3, _ref, _ref1, _ref2,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

test3 = function() {
  return console.log("/?");
};

isLoaded = false;

FooRouter = (function(_super) {
  __extends(FooRouter, _super);

  function FooRouter() {
    _ref = FooRouter.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  FooRouter.prototype.root = '/foo/';

  FooRouter.prototype.beforeAnytime = ['beforeFoobar'];

  FooRouter.prototype.befores = {
    '/': ['beforeFooMinchi']
  };

  FooRouter.prototype.routes = {
    '/': 'index',
    '/<int:id>/': 'show'
  };

  FooRouter.prototype.index = function() {
    console.log('Foo!');
    return $('.currentPage').empty().append("this page is Foo!");
  };

  FooRouter.prototype.show = function(id) {
    console.log('Show Foo!');
    return $('.currentPage').empty().append("this page is Foo " + id);
  };

  FooRouter.prototype.bar = function() {
    console.log("hoover-ooover");
    return $('.currentPage').empty().append("this page is ふーばーおーばー");
  };

  FooRouter.prototype.beforeFooMinchi = function() {
    return console.log("before foo");
  };

  FooRouter.prototype.beforeFoobar = function() {
    return console.log("コレクション コレクション");
  };

  return FooRouter;

})(Kazitori);

BarRouter = (function(_super) {
  __extends(BarRouter, _super);

  function BarRouter() {
    _ref1 = BarRouter.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  BarRouter.prototype.routes = {
    '/': 'index'
  };

  BarRouter.prototype.index = function() {
    return console.log("extends extends bar");
  };

  return BarRouter;

})(FooRouter);

Router = (function(_super) {
  __extends(Router, _super);

  function Router() {
    _ref2 = Router.__super__.constructor.apply(this, arguments);
    return _ref2;
  }

  Router.prototype.beforeAnytime = ['anytime'];

  Router.prototype.routes = {
    '/': 'index',
    '/foo': FooRouter,
    '/<id>/': 'show'
  };

  Router.prototype.index = function() {
    return console.log("index");
  };

  Router.prototype.show = function(id) {
    console.log("show::", id);
    return $('.currentPage').empty().append("this page is test" + id);
  };

  Router.prototype.hyoge = function() {
    console.log("oppai");
    return $('.currentPage').empty().append("(´･ω｀･)ｴｯ?");
  };

  Router.prototype.admin = function() {
    console.log("admin");
    $('.currentPage').empty().append("this is admin page");
    return $('#adminContainer').empty().append('<a href="/admin/1" class="test">1</a><a href="/admin/2" class="test">2</a><a href="/admin/3" class="test">3</a>');
  };

  Router.prototype.login = function() {
    return $('#dialog').show();
  };

  Router.prototype.logout = function() {
    setCookie(COOKIE_KEY, '');
    window.App.change('');
    console.log("logout");
    $('#adminContainer').empty();
  };

  Router.prototype.post = function(username, postid) {
    $('.currentPage').empty().append(username, postid);
    return console.log(username, postid);
  };

  Router.prototype.firend = function(username, postid, firend, queries) {
    console.log(this.params, "hironori");
    return $('.currentPage').empty().append(username, postid, firend);
  };

  Router.prototype.notfound = function() {
    return console.log("nullpo");
  };

  /*
    some before functions
  */


  Router.prototype.anytime = function() {
    return console.log("any!?");
  };

  Router.prototype.test = function(hiroshi) {
    return console.log("before 1", hiroshi);
  };

  Router.prototype.beforeShow = function(id) {
    console.log("before");
    return console.log(id);
  };

  Router.prototype.beforeMinchi = function() {
    console.log("before minchi");
    this.suspend();
    this.resume();
    return console.log("in example", Kazitori.started);
  };

  Router.prototype.ninshou = function() {
    var isLogined;
    isLogined = Boolean(getCookie(COOKIE_KEY));
    if (isLogined === true) {

    } else {
      return this.reject();
    }
  };

  return Router;

})(Kazitori);

COOKIE_KEY = 'kazitoriExpCookie';

USER = "hage";

PASS = "hikaru";

$(document).ready(function() {
  $('#dialog').css({
    top: window.innerHeight / 2 - 90,
    left: window.innerWidth / 2 - 150
  });
  $('#dialog').hide();
  window.App = new Router({
    'root': "/",
    isLastSlash: true
  });
  console.log(window.App.handlers);
  Kai.init();
  console.log(Kai.GET_CSS_PATH());
  console.log(Kai.GET_IMAGE_PATH());
  console.log(Kai.GET_IMAGE_PATH(Kai.RELATIVE));
  console.log(Kai.GET_SCRIPT_PATH());
  Kai.init({
    scripts: "js"
  });
  console.log(Kai.GET_SCRIPT_PATH());
  window.App.addEventListener(KazitoriEvent.NOT_FOUND, function(event) {
    return console.log("not found");
  });
  $('.test').on("click", clickHandler);
  $('.prev').on("click", prevHandler);
  $('.next').on("click", nextHandler);
  return $('form').on('submit', function(event) {
    var pw, userID;
    event.preventDefault();
    userID = $('input[name=user]').val();
    pw = $('input[name=pw]').val();
    if (userID === USER && pw === PASS) {
      setCookie(COOKIE_KEY, true);
      $('#dialog').hide();
      return window.App.change('admin');
    } else {
      return alert('バルス');
    }
  });
});

clickHandler = function(event) {
  var target, url;
  event.preventDefault();
  target = $(event.currentTarget);
  url = target.attr('href');
  return window.App.change(url);
};

prevHandler = function(event) {
  event.preventDefault();
  return window.App.omokazi();
};

nextHandler = function(event) {
  event.preventDefault();
  return window.App.torikazi();
};

getCookie = function(key) {
  var cookie, cookies, items, _i, _len;
  cookies = document.cookie.split(";");
  for (_i = 0, _len = cookies.length; _i < _len; _i++) {
    cookie = cookies[_i];
    items = cookie.split('=');
    if (items.shift() === key) {
      return items.join('=');
    }
  }
  return null;
};

setCookie = function(key, value, opt) {
  var exipre, expire;
  if (value == null) {
    return;
  }
  expire = new Date();
  expire.setTime(expire.getTime() + 60 * 60 * 24 * 1000);
  exipre = expire.toGMTString();
  return document.cookie = key + '=' + escape(value) + ';expires=' + expire;
};

test2 = function() {
  return console.log("before 2");
};
