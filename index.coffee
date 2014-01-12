
module.exports = (game, opts) -> new VoilaPlugin(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-highlight', 'voxel-registry', 'voxel-registry', 'voxel-blockdata']

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

  enable: () ->
    @node.style.visibility = ''

    @hl.on 'highlight', @onHighlight = (pos) =>
      id = @game.getBlock(pos)
      name = @registry.getBlockName(id)

      displayName = @registry.getItemDisplayName(name)

      if @game.buttons.crouch
        # more detailed info when crouching
        # TODO: edge-trigger, too, .down.on, .up.on to hide/show even if not retargetting block

        if @blockdata?
          # optional attached arbitrary block data
          bd = @blockdata.get(pos[0], pos[1], pos[2])
          if bd?
            # TODO: show this somewhere
            extra = "BD(#{pos[0]},#{pos[1]},#{pos[2]}): #{JSON.stringify(bd)}"
            window.status = extra
            console.log(extra)

            extra = '+'
          else
            extra = ''
        
        @node.textContent = "#{displayName} (#{name}/#{id})#{extra}"
      else
        @node.textContent = displayName

    @hl.on 'remove', @onRemove = () =>
      @node.textContent = ''

  disable: () ->
    @hl.removeListener 'highlight', @onHighlight
    @hl.removeListener 'remove', @onRemove
    @node.style.visibility = 'hidden'

