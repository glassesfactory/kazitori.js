var Router, controller, originalLocation,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

controller = {
  beforeAny: function() {},
  beforeShow: function(id) {},
  index: function() {},
  show: function(id) {},
  search: function() {}
};

Router = (function(_super) {

  __extends(Router, _super);

  function Router() {
    return Router.__super__.constructor.apply(this, arguments);
  }

  Router.prototype.beforeAnytime = ["beforeAny"];

  Router.prototype.befores = {
    '/<int:id>': ['beforeShow'],
    '/posts/<int:id>': ['beforeShow']
  };

  Router.prototype.routes = {
    '/': 'index',
    '/<int:id>': 'show',
    '/posts': 'index',
    '/posts/<int:id>': 'show',
    '/posts/new': 'new',
    '/posts/<int:id>/edit': 'edit',
    '/users/<int:id>/posts/<int:id>': 'show'
  };

  Router.prototype.index = function() {
    return controller.index();
  };

  Router.prototype.show = function(id) {
    return controller.show(id);
  };

  Router.prototype.search = function() {
    return controller.search();
  };

  Router.prototype.beforeAny = function() {
    return controller.beforeAny();
  };

  Router.prototype.beforeShow = function(id) {
    return controller.beforeShow(id);
  };

  return Router;

})(Kazitori);

this.router = new Router();

originalLocation = location.href;

describe("Kazitori", function() {
  beforeEach(function() {
    return router.change('/');
  });
  afterEach(function() {
    return router.change('/');
  });
  describe("property", function() {
    it("should started to be Truthy", function() {
      return expect(Kazitori.started).toBeTruthy();
    });
    it("test stop and restart", function() {
      router.stop();
      expect(Kazitori.started).toBeFalsy();
      return router.start();
    });
    xit("test getHash", function() {
      location.replace("" + location.origin + "/#posts");
      return expect(router.getHash()).toEqual('posts');
    });
    it("test getFragment", function() {
      router.change('/posts/1');
      return expect(router.getFragment()).toEqual('/posts/1');
    });
    return it("test isOldIE", function() {
      var msie;
      msie = navigator.appVersion.toLowerCase();
      msie = msie.indexOf('msie') > -1 ? parseInt(msie.replace(/.*msie[ ]/, '').match(/^[0-9]+/)) : 0;
      if (msie === 0) {
        return expect(router.isOldIE).toBeFalsy();
      } else if (msie <= 9) {
        return expect(router.isOldIE).toBeTruthy();
      }
    });
  });
  describe("event", function() {
    it("should dispatch start event when kazitori started", function() {
      var startHandlerSpy;
      startHandlerSpy = jasmine.createSpy('START event');
      router.addEventListener(KazitoriEvent.START, startHandlerSpy);
      router.stop();
      router.start();
      expect(startHandlerSpy).toHaveBeenCalled();
      expect(startHandlerSpy.calls.length).toEqual(1);
      router.removeEventListener(KazitoriEvent.START, startHandlerSpy);
      startHandlerSpy.reset();
      router.stop();
      router.start();
      return expect(startHandlerSpy).not.toHaveBeenCalled();
    });
    it("should dispatch stop event when kazitori stoped", function() {
      var stopHandlerSpy;
      stopHandlerSpy = jasmine.createSpy('STOP event');
      router.addEventListener(KazitoriEvent.START, stopHandlerSpy);
      router.stop();
      expect(stopHandlerSpy).toHaveBeenCalled();
      expect(stopHandlerSpy.calls.length).toEqual(1);
      router.removeEventListener(KazitoriEvent.START, stopHandlerSpy);
      stopHandlerSpy.reset();
      router.start();
      router.stop();
      expect(stopHandlerSpy).not.toHaveBeenCalled();
      return router.start();
    });
    it("should dispatch change events when kazitori changed", function() {
      var listener, _next, _prev;
      _prev = "/posts";
      _next = "/posts/new";
      router.change("" + _prev);
      expect(window.location.pathname).toEqual("" + _prev);
      listener = {
        onChange: function(e) {
          console.log('onChange');
          expect(e.prev).toEqual("" + _prev);
          return expect(e.next).toEqual("" + _next);
        },
        onInternalChange: function(e) {
          console.log('onInternalChange');
          expect(e.prev).toEqual("" + _prev);
          return expect(e.next).toEqual("" + _next);
        },
        onUserChange: function(e) {
          console.log('onUserChange');
          expect(e.prev).toEqual("" + _prev);
          return expect(e.next).toEqual("" + _next);
        }
      };
      spyOn(listener, 'onChange').andCallThrough();
      spyOn(listener, 'onInternalChange').andCallThrough();
      spyOn(listener, 'onUserChange').andCallThrough();
      router.addEventListener(KazitoriEvent.CHANGE, listener.onChange);
      router.addEventListener(KazitoriEvent.INTERNAL_CHANGE, listener.onInternalChange);
      router.addEventListener(KazitoriEvent.USER_CHANGE, listener.onUserChange);
      router.change("" + _next);
      expect(listener.onChange).toHaveBeenCalled();
      expect(listener.onChange.calls.length).toEqual(1);
      expect(listener.onInternalChange).toHaveBeenCalled();
      expect(listener.onInternalChange.calls.length).toEqual(1);
      expect(listener.onUserChange).not.toHaveBeenCalled();
      listener.onChange.reset();
      listener.onInternalChange.reset();
      listener.onUserChange.reset();
      location.replace("" + location.origin + _prev);
      location.replace("" + location.origin + _next);
      expect(listener.onChange).toHaveBeenCalled();
      expect(listener.onChange.calls.length).toEqual(1);
      expect(listener.onInternalChange).not.toHaveBeenCalled();
      expect(listener.onUserChange).toHaveBeenCalled();
      expect(listener.onUserChange.calls.length).toEqual(1);
      router.removeEventListener(KazitoriEvent.CHANGE, listener.onChange);
      router.removeEventListener(KazitoriEvent.INTERNAL_CHANGE, listener.onChange);
      router.removeEventListener(KazitoriEvent.USER_CHANGE, listener.onChange);
      router.change("" + _next);
      location.replace("" + location.origin + _next);
      listener.onChange.reset();
      listener.onInternalChange.reset();
      listener.onUserChange.reset();
      expect(listener.onChange).not.toHaveBeenCalled();
      expect(listener.onInternalChange).not.toHaveBeenCalled();
      return expect(listener.onUserChange).not.toHaveBeenCalled();
    });
    it("should dispatch prev event when kazitori omokazied", function() {
      var handlerSpy;
      handlerSpy = jasmine.createSpy('PREV Event');
      router.addEventListener(KazitoriEvent.PREV, handlerSpy);
      router.omokazi();
      expect(handlerSpy).toHaveBeenCalled();
      expect(handlerSpy.calls.length).toEqual(1);
      router.removeEventListener(KazitoriEvent.PREV, handlerSpy);
      handlerSpy.reset();
      router.omokazi();
      expect(handlerSpy).not.toHaveBeenCalled();
      return router.torikazi();
    });
    it("should dispatch prev event when kazitori torikazied", function() {
      var handlerSpy;
      handlerSpy = jasmine.createSpy('NEXT Event');
      router.addEventListener(KazitoriEvent.NEXT, handlerSpy);
      router.torikazi();
      expect(handlerSpy).toHaveBeenCalled();
      expect(handlerSpy.calls.length).toEqual(1);
      router.removeEventListener(KazitoriEvent.NEXT, handlerSpy);
      handlerSpy.reset();
      router.torikazi();
      return expect(handlerSpy).not.toHaveBeenCalled();
    });
    return it("should dispatch not_found event when kazitori router undefined", function() {
      var handlerSpy;
      handlerSpy = jasmine.createSpy('NOT_FOUND Event');
      router.addEventListener(KazitoriEvent.NOT_FOUND, handlerSpy);
      router.change("/hageeeeeee");
      expect(handlerSpy).toHaveBeenCalled();
      expect(handlerSpy.calls.length).toEqual(1);
      router.removeEventListener(KazitoriEvent.NOT_FOUND, handlerSpy);
      handlerSpy.reset();
      router.change("/hogeeeeeee");
      return expect(handlerSpy).not.toHaveBeenCalled();
    });
  });
  xit("test routes (simple)", function() {
    location.replace("" + location.origin + "/posts/1");
    return expect(window.location.pathname).toEqual('/posts/1');
  });
  it("can be change location (simple)", function() {
    router.change('/posts/1');
    return expect(window.location.pathname).toEqual('/posts/1');
  });
  it("can be change location (two part)", function() {
    router.change('/users/3/posts/1');
    return expect(window.location.pathname).toEqual('/users/3/posts/1');
  });
  return describe("with controller", function() {
    it('index should be called', function() {
      spyOn(controller, 'index');
      router.change('/posts');
      return expect(controller.index).toHaveBeenCalled();
    });
    it('show should be called', function() {
      spyOn(controller, 'show');
      router.change('/posts/1');
      return expect(controller.show).toHaveBeenCalled();
    });
    it('show should be called with casted argments', function() {
      spyOn(controller, 'show');
      router.change('/posts/32941856');
      return expect(controller.show).toHaveBeenCalledWith(32941856);
    });
    it('befores should be before called', function() {
      spyOn(controller, 'beforeShow');
      router.change('/posts/1');
      return expect(controller.beforeShow).toHaveBeenCalled();
    });
    it('show should be called with casted argments', function() {
      spyOn(controller, 'beforeShow');
      router.change('/posts/32941856');
      return expect(controller.beforeShow).toHaveBeenCalledWith(32941856);
    });
    return it('beforeAny should be before called', function() {
      spyOn(controller, 'beforeAny');
      router.change('/posts');
      expect(controller.beforeAny).toHaveBeenCalled();
      router.change('/posts/1');
      return expect(controller.beforeAny).toHaveBeenCalled();
    });
  });
});
