# THE LONG SILENCE — Native Edition

A native Godot 4 port of **The Long Silence**, preserving the complete MIT-licensed browser implementation and its generated art assets alongside a new desktop renderer and gameplay runtime.

## Native Godot version

The repository root is a Godot project. Install **Godot 4.3 or newer**, import `project.godot`, allow the GLB/WebP assets to import, and press Play.

```text
project.godot
└── godot/
    ├── Main.tscn
    ├── scripts/     native game, flight, world and UI code
    └── shaders/     native planet, cloud and atmosphere shaders
```

See [`GODOT_PORT.md`](GODOT_PORT.md) for Windows export instructions, recommended RTX 4050 settings, controls and implementation details.

## Original browser version

The complete browser edition remains in `src/` and `public/`:

```bash
npm install
npm run dev
npm run build
```

## Native controls

| Control | Action |
| --- | --- |
| Mouse | Look / steer |
| W / S | Walk or thrust |
| A / D | Strafe or steer |
| Q / E | Roll |
| Shift | Sprint / boost |
| X | Full stop |
| E | Pilot-seat interaction |
| F | Hold to scan |
| L | Planetfall |
| J | Fold travel |
| M | Stellar cartography |
| Tab | Archive |
| V | Cockpit / chase camera |

## Rendering

- Vulkan Forward+ native renderer
- ACES tonemapping, native HDR glow, fog and MSAA
- Procedural GPU planet shaders preserving the established teal/mineral, neutral-moon and rose/gold giant palettes
- Animated cloud and atmospheric shells
- GPU-instanced star, asteroid and surface-rock fields
- Floating-origin precision management
- Native procedural terrain
- Original generated GLB and PBR texture assets imported directly by Godot

## Attribution

The browser implementation and generated source assets originate from [achimala/TheLongSilence](https://github.com/achimala/TheLongSilence), copyright © 2026 Anshu Chimala, under the MIT License. See [`LICENSE`](LICENSE) and [`NOTICE.md`](NOTICE.md).
