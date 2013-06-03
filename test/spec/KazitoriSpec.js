var Child, ChildAppend, Router, childController, controller, originalLocation, view,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

view = {
  showEntry: function(id) {}
};

controller = {
  beforeAny: function() {},
  beforeShow: function(id) {},
  index: function() {},
  show: function(id) {},
  search: function() {},
  showEntry: function(id) {
    return view.showEntry(id);
  }
};

childController = {
  beforeAny: function() {},
  beforeShow: function(id) {},
  index: function() {},
  show: function(id) {}
};

Child = (function(_super) {

  __extends(Child, _super);

  function Child() {
    return Child.__super__.constructor.apply(this, arguments);
  }

  Child.prototype.root = "/child";

  Child.prototype.beforeAnytime = ["beforeAnyChild"];

  Child.prototype.befores = {
    '/': ['beforeIndex'],
    '/<int:id>': ['beforeShow']
  };

  Child.prototype.routes = {
    '/': 'index',
    '/<int:id>': 'show'
  };

  Child.prototype.index = function() {
    return childController.index();
  };

  Child.prototype.show = function(id) {
    return childController.show();
  };

  Child.prototype.beforeAnyChild = function() {
    return childController.beforeAny();
  };

  Child.prototype.beforeShow = function(id) {
    return childController.beforeShow();
  };

  return Child;

})(Kazitori);

ChildAppend = (function(_super) {

  __extends(ChildAppend, _super);

  function ChildAppend() {
    return ChildAppend.__super__.constructor.apply(this, arguments);
  }

  ChildAppend.prototype.root = "/appender";

  ChildAppend.prototype.beforeAnytime = ["beforeAny"];

  ChildAppend.prototype.befores = {
    '/': ['beforeIndex'],
    '/<int:id>': ['beforeShow']
  };

  ChildAppend.prototype.routes = {
    '/': 'index',
    '/<int:id>': 'show'
  };

  ChildAppend.prototype.index = function() {
    return childController.index();
  };

  ChildAppend.prototype.show = function(id) {
    return childController.show();
  };

  ChildAppend.prototype.beforeAny = function() {
    return childController.beforeAny();
  };

  ChildAppend.prototype.beforeShow = function(id) {
    return childController.beforeShow();
  };

  return ChildAppend;

})(Kazitori);

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
    '/users/<int:id>/posts/<int:id>': 'show',
    '/entries/<int:id>': controller.showEntry,
    '/child': Child
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
      return expect(router.started).toBeTruthy();
    });
    it("should router.started to be Falsy when router.stop called", function() {
      router.stop();
      expect(router.started).toBeFalsy();
      return router.start();
    });
    it("test getHash", function() {
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
  describe("method", function() {
    return it("should work suspend and resume", function() {
      router.suspend();
      expect(router.started).toBeFalsy();
      router.resume();
      return expect(router.started).toBeTruthy();
    });
  });
  describe("event", function() {
    var nextHandler, notFoundHandler, prevHandler, rejectHandler, startHandler, stopHandler;
    it("should remove listener without listener added", function() {
      return router.removeEventListener(KazitoriEvent.START, function(e) {
        return true;
      });
    });
    startHandler = jasmine.createSpy('START event');
    it("should dispatch start event when kazitori started", function() {
      router.addEventListener(KazitoriEvent.START, startHandler);
      router.stop();
      router.start();
      return expect(startHandler).toHaveBeenCalled();
    });
    it("should dispatch start event once", function() {
      return expect(startHandler.calls.length).toEqual(1);
    });
    it("should not call handler when START event listener removed", function() {
      router.removeEventListener(KazitoriEvent.START, startHandler);
      startHandler.reset();
      router.stop();
      router.start();
      return expect(startHandler).not.toHaveBeenCalled();
    });
    stopHandler = jasmine.createSpy('STOP event');
    it("should dispatch stop event when kazitori stoped", function() {
      router.addEventListener(KazitoriEvent.STOP, stopHandler);
      router.stop();
      return expect(stopHandler).toHaveBeenCalled();
    });
    it("should dispatch stop event once", function() {
      return expect(stopHandler.calls.length).toEqual(1);
    });
    it("should not call handler when STOP event listener removed", function() {
      router.removeEventListener(KazitoriEvent.STOP, stopHandler);
      stopHandler.reset();
      router.stop();
      expect(stopHandler).not.toHaveBeenCalled();
      return router.start();
    });
    xit("should dispatch change events when kazitori changed", function() {
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
    rejectHandler = jasmine.createSpy('REJECT Event');
    it("should dispatch REJECT event when kazitori rejected", function() {
      router.addEventListener(KazitoriEvent.REJECT, rejectHandler);
      router.reject();
      expect(rejectHandler).toHaveBeenCalled();
      return expect(rejectHandler.calls.length).toEqual(1);
    });
    prevHandler = jasmine.createSpy('PREV Event');
    it("should dispatch PREV event when kazitori omokazied", function() {
      router.addEventListener(KazitoriEvent.PREV, prevHandler);
      router.omokazi();
      expect(prevHandler).toHaveBeenCalled();
      return expect(prevHandler.calls.length).toEqual(1);
    });
    it("should not call handler when PREV event listener removed", function() {
      router.removeEventListener(KazitoriEvent.PREV, prevHandler);
      prevHandler.reset();
      router.omokazi();
      return expect(prevHandler).not.toHaveBeenCalled();
    });
    nextHandler = jasmine.createSpy('NEXT Event');
    it("should dispatch NEXT event when kazitori torikazied", function() {
      router.change('/posts/1');
      router.omokazi();
      router.addEventListener(KazitoriEvent.NEXT, nextHandler);
      router.torikazi();
      expect(nextHandler).toHaveBeenCalled();
      return expect(nextHandler.calls.length).toEqual(1);
    });
    it("should not call handler when NEXT event listener removed", function() {
      router.change('/posts/1');
      router.omokazi();
      nextHandler.reset();
      router.removeEventListener(KazitoriEvent.NEXT, nextHandler);
      router.torikazi();
      return expect(nextHandler).not.toHaveBeenCalled();
    });
    notFoundHandler = jasmine.createSpy('NOT_FOUND Event');
    it("should dispatch not_found event when kazitori router undefined", function() {
      router.addEventListener(KazitoriEvent.NOT_FOUND, notFoundHandler);
      router.change("/hageeeeeee");
      expect(notFoundHandler).toHaveBeenCalled();
      return expect(notFoundHandler.calls.length).toEqual(1);
    });
    return it("should not call handler when NEXT event listener removed", function() {
      router.removeEventListener(KazitoriEvent.NOT_FOUND, notFoundHandler);
      notFoundHandler.reset();
      router.change("/hogeeeeeee");
      return expect(notFoundHandler).not.toHaveBeenCalled();
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
  describe("router", function() {
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
    it('should call controller method directly', function() {
      spyOn(view, 'showEntry');
      router.change('/entries/123');
      return expect(view.showEntry).toHaveBeenCalled();
    });
    it('should call controller method directly with casted argments', function() {
      spyOn(view, 'showEntry');
      router.change('/entries/12495876');
      return expect(view.showEntry).toHaveBeenCalledWith(12495876);
    });
    it('show should be called with casted argments', function() {
      spyOn(controller, 'beforeShow');
      router.change('/posts/32941856');
      return expect(controller.beforeShow).toHaveBeenCalledWith(32941856);
    });
    it('beforeAny should be before called', function() {
      spyOn(controller, 'beforeAny');
      router.change('/posts');
      expect(controller.beforeAny).toHaveBeenCalled();
      router.change('/posts/1');
      return expect(controller.beforeAny).toHaveBeenCalled();
    });
    it('should navigate to root when router.change undefined path', function() {
      spyOn(controller, 'beforeShow');
      router.change('/blahblahblah');
      return expect(window.location.pathname).toBe('/');
    });
    it('should match route /', function() {
      var matcher;
      matcher = router.match('/');
      return expect(matcher).toBeTruthy();
    });
    it('should match route /posts', function() {
      var matcher;
      matcher = router.match('/posts');
      return expect(matcher).toBeTruthy();
    });
    it('should match route /posts/2221', function() {
      var matcher;
      matcher = router.match('/posts/2221');
      return expect(matcher).toBeTruthy();
    });
    it('should match route /users/24233/posts/874324', function() {
      var matcher;
      matcher = router.match('/users/24233/posts/874324');
      return expect(matcher).toBeTruthy();
    });
    it('should not match route /posts/blaf', function() {
      var matcher;
      matcher = router.match('/posts/blaf');
      return expect(matcher).toBeFalsy();
    });
    it('should not match route /users/blaf/posts/874324', function() {
      var matcher;
      matcher = router.match('/users/blaf/posts/874324');
      return expect(matcher).toBeFalsy();
    });
    it('should not match route /users/blaf/posts/blafblaf', function() {
      var matcher;
      matcher = router.match('/users/blaf/posts/blafblaf');
      return expect(matcher).toBeFalsy();
    });
    it('should params [349857] when change(/posts/349857)', function() {
      router.change('/posts/349857');
      return expect(router.params[0]).toBe(349857);
    });
    it('should params [893473,219834] when change(/posts/349857)', function() {
      router.change('/users/893473/posts/219834');
      expect(router.params[0]).toBe(893473);
      return expect(router.params[1]).toBe(219834);
    });
    it('should queries {hoge:"hogeee"} when change(/?hoge=hogeee)', function() {
      router.change('/?hoge=hogeee');
      return expect(router.queries.hoge).toBe("hogeee");
    });
    return it('should queries {hoge:"hogeee"} when change(/posts/123?hoge=hogeee)', function() {
      router.change('/posts/123?hoge=hogeee');
      return expect(router.queries.hoge).toBe("hogeee");
    });
  });
  describe("exception", function() {
    return it("should throw error when Kazitori started and router.start called", function() {
      expect(router.started).toBeTruthy();
      return expect(router.start).toThrow();
    });
  });
  describe("nest", function() {
    it('should call nest router controller', function() {
      spyOn(childController, 'index');
      router.change('/child');
      return expect(childController.index).toHaveBeenCalled();
    });
    it('should call nest router controller show', function() {
      spyOn(childController, 'show');
      router.change('/child/1');
      return expect(childController.show).toHaveBeenCalled();
    });
    it('child befores should be before called', function() {
      spyOn(childController, 'beforeShow');
      router.change('/child/1');
      return expect(childController.beforeShow).toHaveBeenCalled();
    });
    return it('child beforeAny should be before called', function() {
      spyOn(childController, 'beforeAny');
      router.change('/posts');
      expect(childController.beforeAny).toHaveBeenCalled();
      router.change('/child/1');
      return expect(childController.beforeAny).toHaveBeenCalled();
    });
  });
  describe("dynamic nest", function() {
    var notFoundHandler;
    it('should append router from constructor', function() {
      spyOn(childController, 'index');
      router.appendRouter(ChildAppend, '/appender');
      router.change('/appender');
      return expect(childController.index).toHaveBeenCalled();
    });
    it('should append router from instance', function() {
      var child;
      spyOn(childController, 'index');
      child = new ChildAppend({
        'isAutoStart': false
      });
      router.appendRouter(child, '/appender');
      router.change('/appender');
      return expect(childController.index).toHaveBeenCalled();
    });
    notFoundHandler = jasmine.createSpy('NOT_FOUND Event');
    it('should remove router from constructor', function() {
      spyOn(childController, 'index');
      router.appendRouter(ChildAppend);
      router.change('/appender');
      return expect(childController.index).toHaveBeenCalled();
    });
    return it('shuold remove router from instance', function() {
      var child;
      spyOn(childController, 'index');
      child = new ChildAppend({
        'isAutoStart': false
      });
      router.appendRouter(child);
      router.change('/appender');
      expect(childController.index).toHaveBeenCalled();
      router.addEventListener(KazitoriEvent.NOT_FOUND, notFoundHandler);
      router.removeRouter(childController);
      return router.change('/appender');
    });
  });
  return describe("silent", function() {
    return it('shuold call show and not change location', function() {
      spyOn(controller, 'show');
      router.silent = true;
      expect(window.location.pathname).toEqual("/");
      router.change('/posts/1');
      expect(controller.show).toHaveBeenCalled();
      expect(window.location.pathname).toEqual("/");
      router.silent = false;
      router.change('/posts/2');
      return expect(window.location.pathname).toEqual("/posts/2");
    });
  });
});

this.d = new Deffered();

describe("Deffered", function() {
  var chaninedDefferedSpy, defferedSpy, defferedSpy2, taskQueueCompleteHandler, taskQueueFailedHandler;
  defferedSpy = jasmine.createSpy('defferedSpy');
  chaninedDefferedSpy = jasmine.createSpy('chaninedDefferedSpy');
  defferedSpy2 = jasmine.createSpy('defferedSpy2');
  taskQueueCompleteHandler = jasmine.createSpy('TASK_QUEUE_COMPLETE Event');
  taskQueueFailedHandler = jasmine.createSpy('TASK_QUEUE_FAILED Event');
  d.addEventListener(KazitoriEvent.TASK_QUEUE_COMPLETE, taskQueueCompleteHandler);
  d.addEventListener(KazitoriEvent.TASK_QUEUE_FAILED, taskQueueFailedHandler);
  beforeEach(function() {
    defferedSpy.reset();
    chaninedDefferedSpy.reset();
    defferedSpy2.reset();
    taskQueueFailedHandler.reset();
    return taskQueueCompleteHandler.reset();
  });
  afterEach(function() {});
  it('should excecute method', function() {
    d.deffered(function(d) {
      return defferedSpy();
    });
    d.execute(d);
    return expect(defferedSpy).toHaveBeenCalled();
  });
  it('should excecute chanined methods', function() {
    d.deffered(function(d) {
      defferedSpy();
      return d.execute(d);
    }).deffered(function(d) {
      return chaninedDefferedSpy();
    });
    d.execute(d);
    expect(defferedSpy).toHaveBeenCalled();
    return expect(chaninedDefferedSpy).toHaveBeenCalled();
  });
  it('should excecute method directly', function() {
    d.deffered(defferedSpy2);
    return d.execute(d);
  });
  it('should dispatch TASK_QUEUE_COMPLETE envet when defferd completed', function() {
    var complete;
    complete = false;
    runs(function() {
      return d.deffered(function(d) {
        return complete = true;
      });
    });
    waitsFor(function() {
      d.execute(d);
      return complete;
    });
    return runs(function() {
      return expect(taskQueueCompleteHandler).toHaveBeenCalled();
    });
  });
  return it('should dispatch TASK_QUEUE_FAILED envet when defferd.reject called', function() {
    d.deffered(function(d) {
      return d.reject();
    });
    d.execute(d);
    return expect(taskQueueFailedHandler).toHaveBeenCalled();
  });
});
