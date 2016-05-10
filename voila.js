
module.exports = (game, opts) -> new VoilaPlugin(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-highlight', 'voxel-outline', 'voxel-registry', 'voxel-registry', 'voxel-blockdata', 'voxel-keys']
  clientOnly: true

class VoilaPlugin
  constructor: (@game, opts) ->
    @hl = @game.plugins?.get('voxel-highlight') ? @game.plugins?.get('voxel-outline') ? throw new Error('voxel-voila requires voxel-highlight or voxel-outline plugins')
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

  update: (pos, hit) ->
    @lastPos = pos
    @lastHit = hit
    if not @lastPos?
      @clear()
      return

    index = @game.getBlock(pos)
    name = @registry.getBlockName(index)

    displayName = @registry.getItemDisplayName(name)

    if @game.buttons.crouch # TODO: voxel-keys state?
      # more detailed info when crouching

      @node.textContent = ""

      [x, y, z] = pos

      lines = [
        displayName,
        '',
        "Name: #{name}",
        "Index: #{index}",
        "Position: (#{x}, #{y}, #{z})"
      ]

      if hit?.normal?
        [nx, ny, nz] = hit?.normal
        lines.push "Normal: (#{nx}, #{ny}, #{nz})"

      props = @registry.getBlockProps(name)
      if props.requiredTool
        lines.push "Requires: #{props.requiredTool}"

      if @blockdata?
        # optional attached arbitrary block data
        bd = @blockdata.get(x, y, z)
        if bd?
          # TODO: show this somewhere
          lines.push "Data: #{JSON.stringify(bd)}"

      for line in lines
        @node.appendChild(document.createTextNode(line))
        @node.appendChild(document.createElement('br'))
    else
      @node.textContent = displayName

  clear: () ->
    @lastPos = undefined
    @node.textContent = ''

  enable: () ->
    @node.style.visibility = ''

    @hl.on 'highlight', @onHighlight = (pos, hit) =>
      @update(pos, hit)

    @hl.on 'remove', @onRemove = () =>
      @clear()

    if @keys?
      @keys.changed.on 'crouch', @onChanged = () =>
        process.nextTick () =>
          @update(@lastPos, @lastHit)


  disable: () ->
    @hl.removeListener 'highlight', @onHighlight
    @hl.removeListener 'remove', @onRemove
    @keys.changed.removeListener 'crouch', @onChanged if @keys?
    @node.style.visibility = 'hidden'

