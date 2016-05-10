'use strict';

module.exports = (game, opts) => new VoilaPlugin(game, opts);

module.exports.pluginInfo = {
  loadAfter: ['voxel-highlight', 'voxel-outline', 'voxel-registry', 'voxel-registry', 'voxel-blockdata', 'voxel-keys'],
  clientOnly: true,
};

class VoilaPlugin {
  constructor(game, opts) {
    this.game = game;
    this.hl = game.plugins.get('voxel-highlight');
    if (!this.hl) this.hl = game.plugins.get('voxel-outline');
    if (!this.hl) throw new Error('voxel-voila requires voxel-highlight or voxel-outline plugins');

    this.registry = game.plugins.get('voxel-registry');
    if (!this.registry) throw new Error('voxel-voila requires voxel-registry plugin');

    if (this.registry.getItemDisplayName === undefined) throw new Error('voxel-voila requires voxel-registry >=0.2.0 with getItemDisplayName');

    this.blockdata = game.plugins.get('voxel-blockdata');

    this.keys = this.game.plugins.get('voxel-keys'); // optional

    this.createNode();

    this.enable();
  }

  createNode() {
    this.node = document.createElement('span');
    this.node.setAttribute('id', 'voxel-voila');
    this.node.setAttribute('style', `
background-image: linear-gradient(rgba(0,0,0,0.6) 0%, rgba(0,0,0,0.6) 100%);
visibility: hidden;
color: white;
font-size: 18pt;
`);

    this.node.textContent = '';

    const container = document.createElement('div');
    container.setAttribute('style', `
position: absolute;
top: 0px;
width: 100%;
text-align: center;
`);

    container.appendChild(this.node);
    document.body.appendChild(container);
  }

  update(pos, hit) {
    this.lastPos = pos;
    this.lastHit = hit;
    if (this.lastPos === undefined) {
      this.clear();
      return;
    }

    const index = this.game.getBlock(pos);
    const name = this.registry.getBlockName(index);

    const displayName = this.registry.getItemDisplayName(name);

    if (this.game.buttons.crouch) { // TODO: voxel-keys state?
      //  more detailed info when crouching

      this.node.textContent = "";

      const [x, y, z] = pos;

      const lines = [
        displayName,
        '',
        `Name: ${name}`,
        `Index: ${index}`,
        `Position: (${x}, ${y}, ${z})`,
      ];

      if (hit !== undefined && hit.normal !== undefined) {
        const [nx, ny, nz] = hit.normal;
        lines.push(`Normal: (${nx}, ${ny}, ${nz})`);
      }

      const props = this.registry.getBlockProps(name);
      if (props.requiredTool) {
        lines.push(`Requires: ${props.requiredTool}`);
      }

      if (this.blockdata !== undefined) {
        //  optional attached arbitrary block data
        const bd = this.blockdata.get(x, y, z);
        if (bd !== undefined) {
          //  TODO: show this somewhere
          lines.push(`Data: ${JSON.stringify(bd)}`);
        }
      }

      for (let line of lines) {
        this.node.appendChild(document.createTextNode(line));
        this.node.appendChild(document.createElement('br'));
      }
    } else {
      this.node.textContent = displayName;
    }
  }

  clear() {
    this.lastPos = undefined;
    this.node.textContent = '';
  }

  enable() {
    this.node.style.visibility = '';

    this.hl.on('highlight', this.onHighlight = (pos, hit) => {
      this.update(pos, hit);
    });

    this.hl.on('remove', this.onRemove = () => {
      this.clear();
    });

    if (this.keys) {
      this.keys.changed.on('crouch', this.onChanged = () => {
        process.nextTick(() => {
          this.update(this.lastPos, this.lastHit);
        });
      });
    }
  }

  disable() {
    this.hl.removeListener('highlight', this.onHighlight);
    this.hl.removeListener('remove', this.onRemove);
    if (this.keys) this.keys.changed.removeListener('crouch', this.onChanged);
    this.node.style.visibility = 'hidden';
  }
}
