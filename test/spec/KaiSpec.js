var randomString;

randomString = function() {
  var a, i, n, s, _i;
  a = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.split('');
  s = '';
  n = Math.floor(Math.random() * 5) + 5;
  for (i = _i = 0; 0 <= n ? _i <= n : _i >= n; i = 0 <= n ? ++_i : --_i) {
    s += a[Math.floor(Math.random() * a.length)];
  }
  return s;
};

this.t = {
  PACKAGE_ROOT: "PACKAGE_ROOT_" + (randomString()),
  CSS: "CSS_" + (randomString()),
  JS: "JS_" + (randomString()),
  IMAGES: "IMAGES_" + (randomString()),
  DATA: "DATA_" + (randomString()),
  PC: "PC_" + (randomString()),
  SP: "SP_" + (randomString()),
  TABLET: "TABLET_" + (randomString()),
  HOST: "HOST_" + (randomString()),
  ROOT: "ROOT_" + (randomString())
};

Kai.init({
  packageRoot: t.PACKAGE_ROOT,
  css: t.CSS,
  js: t.JS,
  images: t.IMAGES,
  data: t.DATA,
  pc: t.PC,
  sp: t.SP,
  tablet: t.TABLET,
  host: t.HOST,
  root: t.ROOT
});

describe("Kai", function() {
  describe("init", function() {
    it('ASSET_DIR', function() {
      return expect(Kai.ASSET_DIR).toEqual(t.PACKAGE_ROOT);
    });
    it('CSS_DIR', function() {
      return expect(Kai.CSS_DIR).toEqual(t.CSS);
    });
    it('SCRIPT_DIR', function() {
      return expect(Kai.SCRIPT_DIR).toEqual(t.JS);
    });
    it('IMAGE_DIR', function() {
      return expect(Kai.IMAGE_DIR).toEqual(t.IMAGES);
    });
    it('DATA_DIR', function() {
      return expect(Kai.DATA_DIR).toEqual(t.DATA);
    });
    it('PC_DIR', function() {
      return expect(Kai.PC_DIR).toEqual(t.PC);
    });
    it('SP_DIR', function() {
      return expect(Kai.SP_DIR).toEqual(t.SP);
    });
    return it('TABLET_DIR', function() {
      return expect(Kai.TABLET_DIR).toEqual(t.TABLET);
    });
  });
  describe("GET_CSS_PATH", function() {
    describe("root", function() {
      it('default', function() {
        return expect(Kai.GET_CSS_PATH(Kai.ROOT)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.CSS);
      });
      it('pc', function() {
        return expect(Kai.GET_CSS_PATH(Kai.ROOT, Kai.PC_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.CSS);
      });
      it('sp', function() {
        return expect(Kai.GET_CSS_PATH(Kai.ROOT, Kai.SP_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.CSS);
      });
      return it('tablet', function() {
        return expect(Kai.GET_CSS_PATH(Kai.ROOT, Kai.TABLET_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.CSS);
      });
    });
    return describe("relative", function() {
      it('default', function() {
        return expect(Kai.GET_CSS_PATH(Kai.RELATIVE)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.CSS);
      });
      it('pc', function() {
        return expect(Kai.GET_CSS_PATH(Kai.RELATIVE, Kai.PC_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.CSS);
      });
      it('sp', function() {
        return expect(Kai.GET_CSS_PATH(Kai.RELATIVE, Kai.SP_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.CSS);
      });
      return it('tablet', function() {
        return expect(Kai.GET_CSS_PATH(Kai.RELATIVE, Kai.TABLET_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.CSS);
      });
    });
  });
  describe("GET_SCRIPT_PATH", function() {
    describe("root", function() {
      it('default', function() {
        return expect(Kai.GET_SCRIPT_PATH(Kai.ROOT)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.JS);
      });
      it('pc', function() {
        return expect(Kai.GET_SCRIPT_PATH(Kai.ROOT, Kai.PC_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.JS);
      });
      it('sp', function() {
        return expect(Kai.GET_SCRIPT_PATH(Kai.ROOT, Kai.SP_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.JS);
      });
      return it('tablet', function() {
        return expect(Kai.GET_SCRIPT_PATH(Kai.ROOT, Kai.TABLET_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.JS);
      });
    });
    return describe("relative", function() {
      it('default', function() {
        return expect(Kai.GET_SCRIPT_PATH(Kai.RELATIVE)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.JS);
      });
      it('pc', function() {
        return expect(Kai.GET_SCRIPT_PATH(Kai.RELATIVE, Kai.PC_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.JS);
      });
      it('sp', function() {
        return expect(Kai.GET_SCRIPT_PATH(Kai.RELATIVE, Kai.SP_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.JS);
      });
      return it('tablet', function() {
        return expect(Kai.GET_SCRIPT_PATH(Kai.RELATIVE, Kai.TABLET_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.JS);
      });
    });
  });
  describe("GET_IMAGE_PATH", function() {
    describe("root", function() {
      it('default', function() {
        return expect(Kai.GET_IMAGE_PATH(Kai.ROOT)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.IMAGES);
      });
      it('pc', function() {
        return expect(Kai.GET_IMAGE_PATH(Kai.ROOT, Kai.PC_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.IMAGES);
      });
      it('sp', function() {
        return expect(Kai.GET_IMAGE_PATH(Kai.ROOT, Kai.SP_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.IMAGES);
      });
      return it('tablet', function() {
        return expect(Kai.GET_IMAGE_PATH(Kai.ROOT, Kai.TABLET_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.IMAGES);
      });
    });
    return describe("relative", function() {
      it('default', function() {
        return expect(Kai.GET_IMAGE_PATH(Kai.RELATIVE)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.IMAGES);
      });
      it('pc', function() {
        return expect(Kai.GET_IMAGE_PATH(Kai.RELATIVE, Kai.PC_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.IMAGES);
      });
      it('sp', function() {
        return expect(Kai.GET_IMAGE_PATH(Kai.RELATIVE, Kai.SP_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.IMAGES);
      });
      return it('tablet', function() {
        return expect(Kai.GET_IMAGE_PATH(Kai.RELATIVE, Kai.TABLET_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.IMAGES);
      });
    });
  });
  describe("GET_RELATIVE_PATH", function() {
    describe('CSS_DIR', function() {
      it('PC_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.CSS_DIR, Kai.PC_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.CSS);
      });
      it('SP_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.CSS_DIR, Kai.SP_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.CSS);
      });
      return it('TABLET_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.CSS_DIR, Kai.TABLET_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.CSS);
      });
    });
    describe('SCRIPT_DIR', function() {
      it('PC_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.SCRIPT_DIR, Kai.PC_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.JS);
      });
      it('SP_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.SCRIPT_DIR, Kai.SP_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.JS);
      });
      return it('TABLET_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.SCRIPT_DIR, Kai.TABLET_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.JS);
      });
    });
    describe('IMAGE_DIR', function() {
      it('PC_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.IMAGE_DIR, Kai.PC_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.IMAGES);
      });
      it('SP_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.IMAGE_DIR, Kai.SP_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.IMAGES);
      });
      return it('TABLET_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.IMAGE_DIR, Kai.TABLET_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.IMAGES);
      });
    });
    return describe('DATA_DIR', function() {
      it('PC_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.DATA_DIR, Kai.PC_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.DATA);
      });
      it('SP_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.DATA_DIR, Kai.SP_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.DATA);
      });
      return it('TABLET_DIR', function() {
        return expect(Kai.GET_RELATIVE_PATH(Kai.DATA_DIR, Kai.TABLET_DIR)).toEqual("../" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.DATA);
      });
    });
  });
  return describe("GET_ROOT_PATH", function() {
    describe('CSS_DIR', function() {
      it('PC_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.CSS_DIR, Kai.PC_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.CSS);
      });
      it('SP_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.CSS_DIR, Kai.SP_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.CSS);
      });
      return it('TABLET_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.CSS_DIR, Kai.TABLET_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.CSS);
      });
    });
    describe('SCRIPT_DIR', function() {
      it('PC_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.SCRIPT_DIR, Kai.PC_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.JS);
      });
      it('SP_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.SCRIPT_DIR, Kai.SP_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.JS);
      });
      return it('TABLET_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.SCRIPT_DIR, Kai.TABLET_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.JS);
      });
    });
    describe('IMAGE_DIR', function() {
      it('PC_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.IMAGE_DIR, Kai.PC_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.IMAGES);
      });
      it('SP_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.IMAGE_DIR, Kai.SP_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.IMAGES);
      });
      return it('TABLET_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.IMAGE_DIR, Kai.TABLET_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.IMAGES);
      });
    });
    return describe('DATA_DIR', function() {
      it('PC_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.DATA_DIR, Kai.PC_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.PC + "/" + t.DATA);
      });
      it('SP_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.DATA_DIR, Kai.SP_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.SP + "/" + t.DATA);
      });
      return it('TABLET_DIR', function() {
        return expect(Kai.GET_ROOT_PATH(Kai.DATA_DIR, Kai.TABLET_DIR)).toEqual("/" + t.PACKAGE_ROOT + "/" + t.TABLET + "/" + t.DATA);
      });
    });
  });
});
