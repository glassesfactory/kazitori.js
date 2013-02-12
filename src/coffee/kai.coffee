###
Kazitori Path Helper
###

do(window)->
  Kai =()->
    throw new Error('インスタンス化できません')

  Kai.host = ''

  Kai.ASSET_DIR = 'assets'

  Kai.CSS_DIR = 'css'

  Kai.SCRIPT_DIR = 'js'

  Kai.IMAGE_DIR = 'images'

  Kai.DATA_DIR = 'data'

  Kai.deviceIsParent = true
  Kai.strictSlash = false

  Kai.PC_DIR = 'pc'

  Kai.SP_DIR = 'sp'

  Kai.TABLET_DIR = 'tablet'

  Kai.ROOT = 'root'

  Kai.RELATIVE = 'relative'

  ###Kai.init###
  ##初期化
  Kai.init=(options)->
    loc = window.location
    Kai.ASSET_DIR = if options.packageRoot? then options.packageRoot else 'assets'
    Kai.CSS_DIR = if options.css? then options.css else 'css'
    Kai.SCRIPT_DIR = if options.js? then options.js else 'js'
    Kai.IMAGE_DIR = if options.images? then options.images else 'images'
    Kai.DATA_DIR = if options.data? then options.data else 'data'
    Kai.PC_DIR = if options.pc? then options.pc else 'pc'
    Kai.SP_DIR = if options.sp? then options.sp else 'sp'
    Kai.TABLET_DIR = if options.tablet then options.tablet else 'tablet'
    Kai.host = if options.host? then options.host else loc.host
    Kai.root = if options.root? then options.root else '/'
    return

  ###Kai.GET_CSS_PATH###
  ##CSSのパスを取得
  # **args**
  # * rule : String
  #   相対か、ルートかを指定
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Kai.GET_CSS_PATH =(rule, device)->
    func = if rule is Kai.RELATIVE then Kai.GET_RELATIVE_PATH else Kai.GET_ROOT_PATH
    return func.apply(Kai, [Kai.CSS_DIR, device])


  ###Kai.GET_SCRIPT_PATH###
  ##スクリプトのパスを取得
  # **args**
  # * rule : String
  #   相対か、ルートかを指定
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Kai.GET_SCRIPT_PATH =(rule, device)->
    func = if rule is Kai.RELATIVE then Kai.GET_RELATIVE_PATH else Kai.GET_ROOT_PATH
    return func.apply(Kai, [Kai.SCRIPT_DIR, device])


  ###Kai.GET_IMAGE_PATH###
  ##画像のパスを取得
  # **args**
  # * rule : String
  #   相対か、ルートかを指定
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Kai.GET_IMAGE_PATH=(rule, device)->
    func = if rule is Kai.RELATIVE then Kai.GET_RELATIVE_PATH else Kai.GET_ROOT_PATH
    return func.apply(Kai, [Kai.IMAGE_DIR, device])

  ###Kai.GET_DATA_PATH###
  ##データのパスを取得
  # **args**
  # * rule : String
  #   相対か、ルートかを指定
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Kai.GET_DATA_PATH=(rule, device)->
    func = if rule is Kai.RELATIVE then Kai.GET_RELATIVE_PATH else Kai.GET_ROOT_PATH
    return func.apply(Kai, [Kai.DATA_DIR, device])
  ###Kai.GET_RELATIVE_PATH###
  ##相対パスで取得
  # **args**
  # * asset : String
  #   欲しい素材の種類(css,js,image)
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Kai.GET_RELATIVE_PATH =(asset, device)->
    fragment = window.location.pathname
    if Kai.root?
      fragment = fragment.replace(Kai.root, '')
    level = fragment.split('/').length - 1
    
    result = _GET_PATH(asset, device)
    
    i = 0
    while i < level
      result = '../' + result
      i++
    if Kai.strictSlash
      result + '/'
    return result


  ###Kai.GET_ROOT_PATH###
  ##ルートパスで取得
  # **args**
  # * asset : String
  #   欲しい素材の種類(css,js,image)
  # * device : String
  #   デバイスごとに分けるのであればデバイス名
  #
  Kai.GET_ROOT_PATH =(asset, device)->
    result = '/' + _GET_PATH(asset, device)
    if Kai.strictSlash
      result + '/'
    return result

  _GET_PATH =(asset,device)->
    targetDev = ''
    targetAsset = ''

    switch device
      when Kai.PC_DIR
        targetDev = Kai.PC_DIR
      when Kai.TABLET_DIR
        targetDev = Kai.TABLET_DIR
      when Kai.SP_DIR
        targetDev = Kai.SP_DIR
      else
        targetDev = ''

    switch asset
      when Kai.CSS_DIR
        targetAsset = Kai.CSS_DIR
      when Kai.IMAGE_DIR
        targetAsset = Kai.IMAGE_DIR
      when Kai.SCRIPT_DIR
        targetAsset = Kai.SCRIPT_DIR
      when Kai.DATA_DIR
        targetAsset = Kai.DATA_DIR
      else
        throw new Error('asset type fail')
    if targetDev? and targetDev isnt ''
      result = if Kai.deviceIsParent then [Kai.ASSET_DIR, targetDev, targetAsset] else [Kai.ASSET_DIR, targetAsset, targetDev]
    else
      result = [Kai.ASSET_DIR, targetAsset]
    result = result.join('/')
    return result


  window.Kai = Kai
