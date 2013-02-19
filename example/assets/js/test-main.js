var COOKIE_KEY, PASS, Router, USER, clickHandler, getCookie, isLoaded, nextHandler, prevHandler, setCookie, test2, test3,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

test3 = function() {
  return console.log("/?");
};

isLoaded = false;

Router = (function(_super) {

  __extends(Router, _super);

  function Router() {
    return Router.__super__.constructor.apply(this, arguments);
  }

  Router.prototype.befores = {
    '/<string:user>/<int:post>/<friend>': ['beforeMinchi'],
    '/<int:id>': ['beforeShow']
  };

  Router.prototype.routes = {
    '/': 'index',
    '/<int:id>': 'show',
    '/admin': 'admin',
    '/login': 'login',
    '/logout': 'logout',
    '/<string:user>/<int:post>/<friend>': 'firend'
  };

  Router.prototype.index = function() {
    console.log("index");
    $('#dialog').hide();
    $('#adminContainer').empty();
    return $('.currentPage').empty().append("this page is index");
  };

  Router.prototype.show = function(id) {
    console.log("showwww", id);
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


  Router.prototype.test = function(hiroshi) {
    return console.log("before 1", hiroshi);
  };

  Router.prototype.beforeShow = function(id) {
    console.log("before");
    return console.log(id);
  };

  Router.prototype.beforeMinchi = function() {
    var _this = this;
    console.log("before minchi");
    this.resume();
    return setTimeout(function() {
      console.log("restart?", _this);
      return _this.restart();
    }, 2000);
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
    root: '/unko/',
    isTemae: true
  });
  window.App.addEventListener(KazitoriEvent.CHANGE, function(event) {
    return console.log(event, "change");
  });
  window.App.addEventListener(KazitoriEvent.FIRST_REQUEST, function(event) {
    return console.log(event, "firstrequest");
  });
  window.App.addEventListener(KazitoriEvent.PREV, function(event) {
    return console.log(event, "prev");
  });
  window.App.addEventListener(KazitoriEvent.NEXT, function(event) {
    return console.log(event, "next");
  });
  window.App.addEventListener(KazitoriEvent.REJECT, function(event) {
    return console.log(event);
  });
  window.App.addEventListener(KazitoriEvent.NOT_FOUND, function(event) {
    return console.log("not found");
  });
  window.App.addEventListener(KazitoriEvent.EXECUTED, function(event) {
    return console.log(event, "executed");
  });
  console.log("matche check....", window.App.match('/'));
  console.log("matche check....", window.App.match('/webebebeaaa'));
  console.log(window.App.params);
  $('.test').on("click", clickHandler);
  $('.prev').on("click", prevHandler);
  $('.next').on("click", nextHandler);
  $('form').on('submit', function(event) {
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
  return console.log(Kai.GET_CSS_PATH(Kai.RELATIVE));
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
  if (!(value != null)) {
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
