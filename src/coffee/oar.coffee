###
Kazitori Path Helper
###

do(window)->
  Oar =()->

  Oar.host = ''

  Oar.ASSET_DIR = 'assets'

  Oar.CSS_DIR = 'css'

  Oar.SCRIPT_DIR = 'js'

  Oar.IMAGE_DIR = 'images'

  Oar.data = 'data'
  Oar.deviceIsParent = true
  Oar.strictSlash = false
  Oar.pc = 'pc'
  Oar.sp = 'sp'
  Oar.tablet = 'tablet'

  Oar.ROOT = 'root'

  Oar.RELATIVE = 'relative'

  ###Oar.init###
  ##初期化
  Oar.init=(options)->
    loc = window.location
    Oar.ASSET_DIR = if options.packageRoot? then options.packageRoot else 'assets'
    Oar.CSS_DIR = if options.css? then options.css else 'css'
    Oar.SCRIPT_DIR = if options.js? then options.css else 'js'
    Oar.IMAGE_DIR = if options.images? then options.images else 'images'
    Oar.data = if options.data? then options.data else 'data'
    Oar.pc = if options.pc? then options.pc else 'pc'
    Oar.sp = if options.sp? then options.sp else 'sp'
    Oar.tablet = if options.tablet then options.tablet else 'tablet'
    Oar.host = if options.host? then options.host else loc.host
    Oar.root = if options.root? then options.root else '/'
    return

  ###Oar.GET_CSS_PATH###
  ##CSSのパスを取得
  # **args**
  # * rule : String
  #   相対か、ルートかを指定
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Oar.GET_CSS_PATH =(rule, device)->
    func = if rule is Oar.RELATIVE then Oar.GET_RELATIVE_PATH else Oar.GET_ROOT_PATH
    return func.apply(Oar, [Oar.CSS_DIR, device])


  ###Oar.GET_SCRIPT_PATH###
  ##スクリプトのパスを取得
  # **args**
  # * rule : String
  #   相対か、ルートかを指定
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Oar.GET_SCRIPT_PATH =(rule, device)->
    func if rule is Oar.RELATIVE then Oar.GET_RELATIVE_PATH else Oar.GET_ROOT_PATH
    return func .apply(Oar, [Oar.CSS_DIR, device])


  ###Oar.GET_IMAGE_PATH###
  ##画像のパスを取得
  # **args**
  # * rule : String
  #   相対か、ルートかを指定
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Oar.GET_IMAGE_PATH=(rule, device)->
    func if rule is Oar.RELATIVE then Oar.GET_RELATIVE_PATH else Oar.GET_ROOT_PATH
    return func .apply(Oar, [Oar.IMAGE_DIR, device])

  ###Oar.GET_RELATIVE_PATH###
  ##相対パスで取得
  # **args**
  # * asset : String
  #   欲しい素材の種類(css,js,image)
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Oar.GET_RELATIVE_PATH =(asset, device)->
    fragment = window.location.pathname
    if Oar.root?
      fragment = fragment.replace(Oar.root, '')
    level = fragment.split('/').length - 1
    
    result = _GET_PATH(asset, device)
    
    i = 0
    while i < level
      result = '../' + result
      i++
    if Oar.strictSlash
      result + '/'
    return result


  ###Oar.GET_ROOT_PATH###
  ##ルートパスで取得
  # **args**
  # * asset : String
  #   欲しい素材の種類(css,js,image)
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Oar.GET_ROOT_PATH =(asset, device)->
    result = '/' + _GET_PATH(asset, device)
    if Oar.strictSlash
      result + '/'
    return result

  _GET_PATH =(asset,device)->
    targetDev = ''
    targetAsset = ''

    switch device
      when Oar.PC_DIR
        targetDev = Oar.PC_DIR
      when Oar.TABLET_DIR
        targetDev = Oar.TABLET_DIR
      when Oar.SP_DIR
        targetDev = Oar.SP_DIR
      when COMMON_DIR
        targetDev = Oar.COMMON_DIR
      else 
        targetDev = ''

    switch asset
      when Oar.CSS_DIR
        targetAsset = Oar.CSS_DIR
      when Oar.IMAGE_DIR
        targetAsset = Oar.IMAGE_DIR
      when Oar.SCRIPT_DIR
        targetAsset = Oar.SCRIPT_DIR
      when Oar.DATA_DIR
        targetAsset = Oar.DATA_DIR
      else
        throw new Error('asset typei fail')
    if targetDev?
      result = if Oar.deviceIsParent then [Oar.ASSET_DIR, targetDev, targetAsset] else [Oar.ASSET_DIR, targetAsset, targetDev]
    else
      result = [Oar.ASSET_DIR, targetAsset]
    result = result.join('/')
    return result


  window.Oar = Oar
