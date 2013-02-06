randomString = ->
  a = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.split('')
  s = ''
  n = (Math.floor(Math.random() * 5) + 5)
  for i in [0..n]
    s += a[Math.floor(Math.random() * a.length)]
  return s

@t =
  PACKAGE_ROOT: "PACKAGE_ROOT_#{randomString()}"
  CSS: "CSS_#{randomString()}"
  JS: "JS_#{randomString()}"
  IMAGES: "IMAGES_#{randomString()}"
  DATA: "DATA_#{randomString()}"
  PC: "PC_#{randomString()}"
  SP: "SP_#{randomString()}"
  TABLET: "TABLET_#{randomString()}"
  HOST: "HOST_#{randomString()}"
  ROOT: "ROOT_#{randomString()}"

Kai.init
  packageRoot: t.PACKAGE_ROOT
  css: t.CSS
  js: t.JS
  images: t.IMAGES
  data: t.DATA
  pc: t.PC
  sp: t.SP
  tablet: t.TABLET
  host: t.HOST
  root: t.ROOT

describe "Kai", ->
  describe "init", ->
    it 'ASSET_DIR', ->
      expect(Kai.ASSET_DIR).toEqual(t.PACKAGE_ROOT)

    it 'CSS_DIR', ->
      expect(Kai.CSS_DIR).toEqual(t.CSS)

    it 'SCRIPT_DIR', ->
      expect(Kai.SCRIPT_DIR).toEqual(t.JS)

    it 'IMAGE_DIR', ->
      expect(Kai.IMAGE_DIR).toEqual(t.IMAGES)

    it 'DATA_DIR', ->
      expect(Kai.DATA_DIR).toEqual(t.DATA)

    it 'PC_DIR', ->
      expect(Kai.PC_DIR).toEqual(t.PC)

    it 'SP_DIR', ->
      expect(Kai.SP_DIR).toEqual(t.SP)

    it 'TABLET_DIR', ->
      expect(Kai.TABLET_DIR).toEqual(t.TABLET)

  describe "GET_CSS_PATH", ->
    describe "root", ->
      it 'default', ->
        expect(Kai.GET_CSS_PATH(Kai.ROOT)).toEqual("/#{t.PACKAGE_ROOT}/#{t.CSS}")

      it 'pc', ->
        expect(Kai.GET_CSS_PATH(Kai.ROOT, Kai.PC_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.PC}/#{t.CSS}")

      it 'sp', ->
        expect(Kai.GET_CSS_PATH(Kai.ROOT, Kai.SP_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.SP}/#{t.CSS}")

      it 'tablet', ->
        expect(Kai.GET_CSS_PATH(Kai.ROOT, Kai.TABLET_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.CSS}")

    describe "relative", ->
      it 'default', ->
        expect(Kai.GET_CSS_PATH(Kai.RELATIVE)).toEqual("../#{t.PACKAGE_ROOT}/#{t.CSS}")

      it 'pc', ->
        expect(Kai.GET_CSS_PATH(Kai.RELATIVE, Kai.PC_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.PC}/#{t.CSS}")

      it 'sp', ->
        expect(Kai.GET_CSS_PATH(Kai.RELATIVE, Kai.SP_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.SP}/#{t.CSS}")

      it 'tablet', ->
        expect(Kai.GET_CSS_PATH(Kai.RELATIVE, Kai.TABLET_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.CSS}")

  describe "GET_SCRIPT_PATH", ->
    describe "root", ->
      it 'default', ->
        expect(Kai.GET_SCRIPT_PATH(Kai.ROOT)).toEqual("/#{t.PACKAGE_ROOT}/#{t.JS}")

      it 'pc', ->
        expect(Kai.GET_SCRIPT_PATH(Kai.ROOT, Kai.PC_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.PC}/#{t.JS}")

      it 'sp', ->
        expect(Kai.GET_SCRIPT_PATH(Kai.ROOT, Kai.SP_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.SP}/#{t.JS}")

      it 'tablet', ->
        expect(Kai.GET_SCRIPT_PATH(Kai.ROOT, Kai.TABLET_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.JS}")

    describe "relative", ->
      it 'default', ->
        expect(Kai.GET_SCRIPT_PATH(Kai.RELATIVE)).toEqual("../#{t.PACKAGE_ROOT}/#{t.JS}")

      it 'pc', ->
        expect(Kai.GET_SCRIPT_PATH(Kai.RELATIVE, Kai.PC_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.PC}/#{t.JS}")

      it 'sp', ->
        expect(Kai.GET_SCRIPT_PATH(Kai.RELATIVE, Kai.SP_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.SP}/#{t.JS}")

      it 'tablet', ->
        expect(Kai.GET_SCRIPT_PATH(Kai.RELATIVE, Kai.TABLET_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.JS}")

  describe "GET_IMAGE_PATH", ->
    describe "root", ->
      it 'default', ->
        expect(Kai.GET_IMAGE_PATH(Kai.ROOT)).toEqual("/#{t.PACKAGE_ROOT}/#{t.IMAGES}")

      it 'pc', ->
        expect(Kai.GET_IMAGE_PATH(Kai.ROOT, Kai.PC_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.PC}/#{t.IMAGES}")

      it 'sp', ->
        expect(Kai.GET_IMAGE_PATH(Kai.ROOT, Kai.SP_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.SP}/#{t.IMAGES}")

      it 'tablet', ->
        expect(Kai.GET_IMAGE_PATH(Kai.ROOT, Kai.TABLET_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.IMAGES}")

    describe "relative", ->
      it 'default', ->
        expect(Kai.GET_IMAGE_PATH(Kai.RELATIVE)).toEqual("../#{t.PACKAGE_ROOT}/#{t.IMAGES}")

      it 'pc', ->
        expect(Kai.GET_IMAGE_PATH(Kai.RELATIVE, Kai.PC_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.PC}/#{t.IMAGES}")

      it 'sp', ->
        expect(Kai.GET_IMAGE_PATH(Kai.RELATIVE, Kai.SP_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.SP}/#{t.IMAGES}")

      it 'tablet', ->
        expect(Kai.GET_IMAGE_PATH(Kai.RELATIVE, Kai.TABLET_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.IMAGES}")

  describe "GET_RELATIVE_PATH", ->
    describe 'CSS_DIR', ->
      it 'PC_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.CSS_DIR, Kai.PC_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.PC}/#{t.CSS}")

      it 'SP_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.CSS_DIR, Kai.SP_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.SP}/#{t.CSS}")

      it 'TABLET_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.CSS_DIR, Kai.TABLET_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.CSS}")

    describe 'SCRIPT_DIR', ->
      it 'PC_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.SCRIPT_DIR, Kai.PC_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.PC}/#{t.JS}")

      it 'SP_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.SCRIPT_DIR, Kai.SP_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.SP}/#{t.JS}")

      it 'TABLET_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.SCRIPT_DIR, Kai.TABLET_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.JS}")

    describe 'IMAGE_DIR', ->
      it 'PC_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.IMAGE_DIR, Kai.PC_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.PC}/#{t.IMAGES}")

      it 'SP_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.IMAGE_DIR, Kai.SP_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.SP}/#{t.IMAGES}")

      it 'TABLET_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.IMAGE_DIR, Kai.TABLET_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.IMAGES}")

    describe 'DATA_DIR', ->
      it 'PC_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.DATA_DIR, Kai.PC_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.PC}/#{t.DATA}")

      it 'SP_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.DATA_DIR, Kai.SP_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.SP}/#{t.DATA}")

      it 'TABLET_DIR', ->
        expect(Kai.GET_RELATIVE_PATH(Kai.DATA_DIR, Kai.TABLET_DIR)).toEqual("../#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.DATA}")

  describe "GET_ROOT_PATH", ->
    describe 'CSS_DIR', ->
      it 'PC_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.CSS_DIR, Kai.PC_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.PC}/#{t.CSS}")

      it 'SP_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.CSS_DIR, Kai.SP_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.SP}/#{t.CSS}")

      it 'TABLET_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.CSS_DIR, Kai.TABLET_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.CSS}")

    describe 'SCRIPT_DIR', ->
      it 'PC_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.SCRIPT_DIR, Kai.PC_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.PC}/#{t.JS}")

      it 'SP_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.SCRIPT_DIR, Kai.SP_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.SP}/#{t.JS}")

      it 'TABLET_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.SCRIPT_DIR, Kai.TABLET_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.JS}")

    describe 'IMAGE_DIR', ->
      it 'PC_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.IMAGE_DIR, Kai.PC_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.PC}/#{t.IMAGES}")

      it 'SP_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.IMAGE_DIR, Kai.SP_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.SP}/#{t.IMAGES}")

      it 'TABLET_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.IMAGE_DIR, Kai.TABLET_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.IMAGES}")

    describe 'DATA_DIR', ->
      it 'PC_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.DATA_DIR, Kai.PC_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.PC}/#{t.DATA}")

      it 'SP_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.DATA_DIR, Kai.SP_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.SP}/#{t.DATA}")

      it 'TABLET_DIR', ->
        expect(Kai.GET_ROOT_PATH(Kai.DATA_DIR, Kai.TABLET_DIR)).toEqual("/#{t.PACKAGE_ROOT}/#{t.TABLET}/#{t.DATA}")
