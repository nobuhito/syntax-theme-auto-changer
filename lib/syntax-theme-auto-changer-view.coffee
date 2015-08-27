{View} = require 'atom-space-pen-views'
module.exports =
class SyntaxThemeAutoChangerView extends View
  @content: (params) ->
    @div class: "inline-block syntax-theme-auto-changer icon-paintcan", =>
      @span "#{params.syntax}", outlet: "syntax"

  setSyntax: (syntax) ->
    @syntax.text syntax
