
module.exports = (game, opts) -> new VoilaPlugin(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-highlight', 'voxel-registry']

class VoilaPlugin
  constructor: (@game, opts) ->
    @hl = @game.plugins?.get('voxel-highlight') ? throw 'voxel-voila requires voxel-highlight plugin'
    @registry = @game.plugins?.get('voxel-registry') ? throw 'voxel-voila requires voxel-registry plugin'

    @createNode()

    @enable()

  createNode: () ->
    @node = document.createElement 'div'
    @node.setAttribute 'id', 'voxel-voila'
    @node.setAttribute 'style', '
border: 1px solid black;
background-image: linear-gradient(rgba(0,0,0,0.6) 0%, rgba(0,0,0,0.6) 100%);
position: absolute;
visibility: hidden;
top: 0px;
left: 50%;
color: white;
'
    @node.textContent = ''

    document.body.appendChild(@node)

  enable: () ->
    @node.style.visibility = ''

    @hl.on 'highlight', @onHighlight = (pos) =>
      blockID = @game.getBlock(pos)
      blockName = @registry.getBlockName(blockID)

      @node.textContent = "#{blockName} (#{blockID})"

  disable: () ->
    @hl.removeListener 'highlight', @onHighlight
    @node.style.visibility = 'hidden'

