{CompositeDisposable} = require 'atom'
SyntaxThemeAutoChangerView = require './syntax-theme-auto-changer-view'

module.exports = SyntaxThemeAutoChanger =
  subscriptions: null

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

  activate: ->

    atom.config.observe "core.themes", (theme) =>
      @defaultTheme = theme if theme[1] != @tempTheme

    atom.config.observe "syntax-theme-auto-changer.syntaxMap", (theme) =>
      @maps = theme

    if atom.config.get("syntax-theme-auto-changer.activateOnStartup") is "on"
      @starusBar
      @start()
    else
      @sub = new CompositeDisposable
      @sub.add atom.commands.add 'atom-workspace',
        'syntax-theme-auto-changer:start': => @start()
      # @statusBar

  deactivate: ->
    @sub.despose()
    atom.config.set("core.themes", @defaultThemes) if @defaultThmes
    @statusBarTile?.destroy()
    @statusBarTile = null

  serialize: ->

  start: ->
    @SyntaxThemeAutoChangerView = new SyntaxThemeAutoChangerView({syntax: "* : #{@defaultTheme[1]}"})
    setTimeout =>
      @statusBarTile = @statusBar.addRightTile
        item: atom.views.getView(@SyntaxThemeAutoChangerView), priority: -1
    , 1000

    atom.workspace.observeActivePaneItem (item) =>
      if item.getGrammar
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

      if @tempTheme and  @tempTheme != @defaultTheme[1]
        atom.config.set("core.themes", @defaultTheme)
        @SyntaxThemeAutoChangerView.setSyntax("* : #{@defaultTheme[1]}")
        @tempTheme = @defaultTheme[1]
        return null
