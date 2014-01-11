
module.exports = (game, opts) -> new VoilaPlugin(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-highlight', 'voxel-registry']

class VoilaPlugin
  constructor: (@game, opts) ->
    @hl = @game.plugins?.get('voxel-highlight') ? throw 'voxel-voila requires voxel-highlight plugin'
    @registry = @game.plugins?.get('voxel-registry') ? throw 'voxel-voila requires voxel-registry plugin'

    @enable()

  enable: () ->
    @hl.on 'highlight', @onHighlight = (pos) =>
      blockID = @game.getBlock(pos)
      blockName = @registry.getBlockName(blockID)

      console.log blockName

  disable: () ->
    @hl.removeListener 'highlight', @onHighlight

