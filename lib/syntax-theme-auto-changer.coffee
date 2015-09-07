{CompositeDisposable} = require 'atom'
SyntaxThemeAutoChangerView = require './syntax-theme-auto-changer-view'

module.exports = SyntaxThemeAutoChanger =
  sub: null

  config:
    activateOnStartup:
      title: "Activate on startup"
      type: "string"
      default: "on"
      enum: ["on", "off"]
    syntaxMap:
      title: "Syntax map"
      type: "array"
      default: ["grammar-name:syntax-name, grammar2-name:syntax2-name"]
      items:
        type: "string"

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar

    if atom.config.get("syntax-theme-auto-changer.activateOnStartup") is "on"
      @start(@statusBar)

  activate: ->
    @defaultTheme = atom.config.get("core.themes")
    atom.config.onDidChange "core.themes", ({newValue}) =>
      @defaultTheme = newValue if newValue[1] != @tempTheme

    @maps = atom.config.get("syntax-theme-auto-changer.syntaxMap")
    atom.config.onDidChange "syntax-theme-auto-changer.syntaxMap", (theme) =>
      @maps = theme

    if atom.config.get("syntax-theme-auto-changer.activateOnStartup") is "off"
      @sub = new CompositeDisposable
      @sub.add atom.commands.add 'atom-workspace',
        'syntax-theme-auto-changer:start': => @start(@statusBar)

  deactivate: ->
    @sub?.dispose()
    atom.config.set("core.themes", @defaultTheme) if @defaultTheme
    @statusBarTile?.destroy()
    @statusBarTile = null

  serialize: ->
    atom.config.set("core.themes", @defaultTheme) if @defaultTheme
    
  changeStatus: ->
    item = atom.workspace.getActiveTextEditor()
    if item?.getGrammar?
      scopeName = item.getGrammar().scopeName
      for map in @maps
        theme = map.split(":")
        if scopeName is theme[0]
          @tempTheme = theme[1]
          atom.config.set("core.themes", [@defaultTheme[0], theme[1]])
          @SyntaxThemeAutoChangerView.setSyntax(theme.join(" : "))
          return null

    else
      @SyntaxThemeAutoChangerView.setSyntax("- : -")
      @tempTheme = "none"
      return null

    if @tempTheme? and  @tempTheme != @defaultTheme[1]
      atom.config.set("core.themes", @defaultTheme)
      @SyntaxThemeAutoChangerView.setSyntax("* : #{@defaultTheme[1]}")
      @tempTheme = @defaultTheme[1]
      return null

  start: (statusBar) ->
    @SyntaxThemeAutoChangerView = new SyntaxThemeAutoChangerView({syntax: "* : #{@defaultTheme[1]}"})
    @statusBarTile = statusBar.addRightTile
      item: atom.views.getView(@SyntaxThemeAutoChangerView), priority: -1

    @changeStatus()
    atom.workspace.onDidChangeActivePaneItem (item) =>
      @changeStatus()
