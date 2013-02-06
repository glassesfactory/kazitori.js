/*
Kazitori Path Helper
*/

(function(window) {
  var Kai, _GET_PATH;
  Kai = function() {
    throw new Error('インスタンス化できません');
  };
  Kai.host = '';
  Kai.ASSET_DIR = 'assets';
  Kai.CSS_DIR = 'css';
  Kai.SCRIPT_DIR = 'js';
  Kai.IMAGE_DIR = 'images';
  Kai.DATA_DIR = 'data';
  Kai.deviceIsParent = true;
  Kai.strictSlash = false;
  Kai.PC_DIR = 'pc';
  Kai.SP_DIR = 'sp';
  Kai.TABLET_DIR = 'tablet';
  Kai.ROOT = 'root';
  Kai.RELATIVE = 'relative';
  /*Kai.init
  */

  Kai.init = function(options) {
    var loc;
    loc = window.location;
    Kai.ASSET_DIR = options.packageRoot != null ? options.packageRoot : 'assets';
    Kai.CSS_DIR = options.css != null ? options.css : 'css';
    Kai.SCRIPT_DIR = options.js != null ? options.js : 'js';
    Kai.IMAGE_DIR = options.images != null ? options.images : 'images';
    Kai.DATA_DIR = options.data != null ? options.data : 'data';
    Kai.PC_DIR = options.pc != null ? options.pc : 'pc';
    Kai.SP_DIR = options.sp != null ? options.sp : 'sp';
    Kai.TABLET_DIR = options.tablet ? options.tablet : 'tablet';
    Kai.host = options.host != null ? options.host : loc.host;
    Kai.root = options.root != null ? options.root : '/';
  };
  /*Kai.GET_CSS_PATH
  */

  Kai.GET_CSS_PATH = function(rule, device) {
    var func;
    func = rule === Kai.RELATIVE ? Kai.GET_RELATIVE_PATH : Kai.GET_ROOT_PATH;
    return func.apply(Kai, [Kai.CSS_DIR, device]);
  };
  /*Kai.GET_SCRIPT_PATH
  */

  Kai.GET_SCRIPT_PATH = function(rule, device) {
    var func;
    func = rule === Kai.RELATIVE ? Kai.GET_RELATIVE_PATH : Kai.GET_ROOT_PATH;
    return func.apply(Kai, [Kai.SCRIPT_DIR, device]);
  };
  /*Kai.GET_IMAGE_PATH
  */

  Kai.GET_IMAGE_PATH = function(rule, device) {
    var func;
    func = rule === Kai.RELATIVE ? Kai.GET_RELATIVE_PATH : Kai.GET_ROOT_PATH;
    return func.apply(Kai, [Kai.IMAGE_DIR, device]);
  };
  /*Kai.GET_DATA_PATH
  */

  Kai.GET_DATA_PATH = function(rule, device) {
    var func;
    func = rule === Kai.RELATIVE ? Kai.GET_RELATIVE_PATH : Kai.GET_ROOT_PATH;
    return func.apply(Kai, [Kai.DATA_DIR, device]);
  };
  /*Kai.GET_RELATIVE_PATH
  */

  Kai.GET_RELATIVE_PATH = function(asset, device) {
    var fragment, i, level, result;
    fragment = window.location.pathname;
    if (Kai.root != null) {
      fragment = fragment.replace(Kai.root, '');
    }
    level = fragment.split('/').length - 1;
    result = _GET_PATH(asset, device);
    i = 0;
    while (i < level) {
      result = '../' + result;
      i++;
    }
    if (Kai.strictSlash) {
      result + '/';
    }
    return result;
  };
  /*Kai.GET_ROOT_PATH
  */

  Kai.GET_ROOT_PATH = function(asset, device) {
    var result;
    result = '/' + _GET_PATH(asset, device);
    if (Kai.strictSlash) {
      result + '/';
    }
    return result;
  };
  _GET_PATH = function(asset, device) {
    var result, targetAsset, targetDev;
    targetDev = '';
    targetAsset = '';
    switch (device) {
      case Kai.PC_DIR:
        targetDev = Kai.PC_DIR;
        break;
      case Kai.TABLET_DIR:
        targetDev = Kai.TABLET_DIR;
        break;
      case Kai.SP_DIR:
        targetDev = Kai.SP_DIR;
        break;
      default:
        targetDev = '';
    }
    switch (asset) {
      case Kai.CSS_DIR:
        targetAsset = Kai.CSS_DIR;
        break;
      case Kai.IMAGE_DIR:
        targetAsset = Kai.IMAGE_DIR;
        break;
      case Kai.SCRIPT_DIR:
        targetAsset = Kai.SCRIPT_DIR;
        break;
      case Kai.DATA_DIR:
        targetAsset = Kai.DATA_DIR;
        break;
      default:
        throw new Error('asset type fail');
    }
    if ((targetDev != null) && targetDev !== '') {
      result = Kai.deviceIsParent ? [Kai.ASSET_DIR, targetDev, targetAsset] : [Kai.ASSET_DIR, targetAsset, targetDev];
    } else {
      result = [Kai.ASSET_DIR, targetAsset];
    }
    result = result.join('/');
    return result;
  };
  return window.Kai = Kai;
})(window);
