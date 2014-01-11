
module.exports = (game, opts) -> new VoilaPlugin(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-highlight']

class VoilaPlugin
  constructor: (@game, opts) ->
    @hl = @game.plugins?.get('voxel-highlight') ? throw 'voxel-voila requires voxel-highlight plugin'

    @enable()

  enable: () ->
    @hl.on 'highlight', @onHighlight = (pos) =>
      console.log 'hl',pos

  disable: () ->
    @hl.removeListener 'highlight', @onHighlight

