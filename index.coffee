
module.exports = (game, opts) -> new VoilaPlugin(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-highlight', 'voxel-registry', 'voxel-registry']

class VoilaPlugin
  constructor: (@game, opts) ->
    @hl = @game.plugins?.get('voxel-highlight') ? throw 'voxel-voila requires voxel-highlight plugin'
    @registry = @game.plugins?.get('voxel-registry') ? throw 'voxel-voila requires voxel-registry plugin'
    throw 'voxel-voila requires voxel-registry >=0.2.0 with getItemDisplayName' if not @registry.getItemDisplayName?

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
font-size: 18pt;
'
    @node.textContent = ''

    document.body.appendChild(@node)

  enable: () ->
    @node.style.visibility = ''

    @hl.on 'highlight', @onHighlight = (pos) =>
      id = @game.getBlock(pos)
      name = @registry.getBlockName(id)

      displayName = @registry.getItemDisplayName(name)

      @node.textContent = "#{displayName} (#{name}/#{id})"  # TODO: by default, only show displayName but have debug option for more

    @hl.on 'remove', @onRemove = () =>
      @node.textContent = ''

  disable: () ->
    @hl.removeListener 'highlight', @onHighlight
    @hl.removeListener 'remove', @onRemove
    @node.style.visibility = 'hidden'

