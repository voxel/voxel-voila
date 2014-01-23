
module.exports = (game, opts) -> new VoilaPlugin(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-highlight', 'voxel-registry', 'voxel-registry', 'voxel-blockdata']
  clientOnly: true

class VoilaPlugin
  constructor: (@game, opts) ->
    @hl = @game.plugins?.get('voxel-highlight') ? throw 'voxel-voila requires voxel-highlight plugin'
    @registry = @game.plugins?.get('voxel-registry') ? throw 'voxel-voila requires voxel-registry plugin'
    throw 'voxel-voila requires voxel-registry >=0.2.0 with getItemDisplayName' if not @registry.getItemDisplayName?
    @blockdata = @game.plugins?.get('voxel-blockdata')

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

  update: (pos) ->
    @lastPos = pos
    id = @game.getBlock(pos)
    name = @registry.getBlockName(id)

    displayName = @registry.getItemDisplayName(name)

    if @game.buttons.crouch
      # more detailed info when crouching

      if @blockdata?
        # optional attached arbitrary block data
        [x, y, z] = pos
        bd = @blockdata.get(x, y, z)
        if bd?
          # TODO: show this somewhere
          extra = "BD(#{x},#{y},#{y}): #{JSON.stringify(bd)}"
          window.status = extra
          console.log(extra)

          extra = '+'
        else
          extra = ''
      
      @node.textContent = "#{displayName} (#{name}/#{id})#{extra}"
    else
      @node.textContent = displayName

  clear: () ->
    @lastPos = undefined
    @node.textContent = ''

  enable: () ->
    @node.style.visibility = ''

    @hl.on 'highlight', @onHighlight = (pos) =>
      @update(pos)

    @hl.on 'remove', @onRemove = () =>
      @clear()

    if @game.buttons.changed? # available in kb-bindings >=0.2.0
      @game.buttons.changed.on 'crouch', @onChanged = () =>
        @update(@lastPos)


  disable: () ->
    @hl.removeListener 'highlight', @onHighlight
    @hl.removeListener 'remove', @onRemove
    @game.buttons.changed.removeListener 'crouch', @onChanged if @game.buttons.changed?
    @node.style.visibility = 'hidden'

