
module.exports = (game, opts) -> new VoilaPlugin(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-highlight', 'voxel-registry', 'voxel-registry', 'voxel-blockdata', 'voxel-keys']
  clientOnly: true

class VoilaPlugin
  constructor: (@game, opts) ->
    @hl = @game.plugins?.get('voxel-highlight') ? throw new Error('voxel-voila requires voxel-highlight plugin')
    @registry = @game.plugins?.get('voxel-registry') ? throw new Error('voxel-voila requires voxel-registry plugin')
    throw new Error('voxel-voila requires voxel-registry >=0.2.0 with getItemDisplayName') if not @registry.getItemDisplayName?
    @blockdata = @game.plugins?.get('voxel-blockdata')
    @keys = @game.plugins?.get('voxel-keys') # optional

    @createNode()

    @enable()

  createNode: () ->
    @node = document.createElement 'span'
    @node.setAttribute 'id', 'voxel-voila'
    @node.setAttribute 'style', '
background-image: linear-gradient(rgba(0,0,0,0.6) 0%, rgba(0,0,0,0.6) 100%);
visibility: hidden;
color: white;
font-size: 18pt;
'

    @node.textContent = ''

    container = document.createElement 'div'
    container.setAttribute 'style', '
position: absolute;
top: 0px;
width: 100%;
text-align: center;
'

    container.appendChild @node
    document.body.appendChild container

  update: (pos) ->
    @lastPos = pos
    if not @lastPos?
      @clear()
      return

    id = @game.getBlock(pos)
    name = @registry.getBlockName(id)

    displayName = @registry.getItemDisplayName(name)

    if @game.buttons.crouch # TODO: voxel-keys state?
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

    if @keys?
      @keys.changed.on 'crouch', @onChanged = () =>
        @update(@lastPos)


  disable: () ->
    @hl.removeListener 'highlight', @onHighlight
    @hl.removeListener 'remove', @onRemove
    @keys.changed.removeListener 'crouch', @onChanged if @keys?
    @node.style.visibility = 'hidden'

