# Native Godot 4 port

This repository now contains two implementations:

1. The complete MIT-licensed browser edition in `src/`.
2. A native Godot 4 desktop port rooted at `project.godot` and `godot/`.

The native port is designed for the Lenovo LOQ configuration described during development: Ryzen 7 7435HS, 24 GB RAM and a 6 GB RTX 4050. It uses Godot's Vulkan Forward+ renderer, GPU instancing, ACES tonemapping, MSAA, screen-space antialiasing, native shaders and a floating origin.

## Open and run

1. Install **Godot 4.3 or newer** from <https://godotengine.org/download/windows/>.
2. Start Godot and choose **Import**.
3. Select this repository's `project.godot`.
4. Allow the initial GLB and WebP import to finish.
5. Press **F6** or the Play button.

The first import can take a minute because Godot converts the original generated hard-surface GLB and PBR textures into its native cache. Later launches are much faster.

## Windows export

In Godot:

1. Open **Project → Export**.
2. Add **Windows Desktop**.
3. Install the export template when prompted.
4. Export as `TheLongSilence.exe`.

For the RTX 4050, leave the renderer on **Forward+**. Use exclusive fullscreen at 1920×1080 and VSync enabled. If a higher resolution is used, switch Godot's 3D scaling mode to FSR 2 Quality in Project Settings.

## Native controls

| Key | Action |
| --- | --- |
| Mouse | Look / steer |
| W / S | Walk or set thrust |
| A / D | Strafe or steer |
| Q / E | Roll while flying |
| Shift | Sprint / boost |
| X | Full stop |
| E | Enter or leave pilot seat contextually |
| F | Hold to scan |
| L | Land / return to surface mode |
| J | Fold to next survey vector |
| M | Stellar cartography |
| Tab | Archive |
| V | Cockpit / chase camera |
| Esc | Release mouse |

## Ported systems

- Native six-degree-of-freedom flight
- Walkable vessel interior and interactive pilot seat
- Cockpit and chase cameras
- Procedural Lyra planet shaders preserving the established palettes
- Animated atmosphere and cloud shells
- Rings, moons, stars and instanced asteroid fields
- Surface landing and first-person exploration
- Procedural terrain and instanced surface rocks
- Landed vessel and buried surface Resonator
- Seven Resonators, hold-to-scan loop and Cantos
- Fold travel, archive, map, HUD and cinematic fades
- Floating-origin precision management
- Native ACES, glow, fog, MSAA and GPU instancing

## Source layout

```text
project.godot
public/models/                 original generated GLB/PBR assets
godot/Main.tscn
godot/scripts/Main.gd          game director
godot/scripts/NativeShip.gd    flight, walking, cameras, ship construction
godot/scripts/Universe.gd      stars, planets, asteroids and Resonators
godot/scripts/PlanetBody.gd    planet mesh, clouds, atmosphere and rings
godot/scripts/SurfaceWorld.gd  landing terrain and surface set piece
godot/scripts/NativeHUD.gd     native interface and menus
godot/shaders/                 native Godot spatial shaders
```

The original project's MIT attribution remains in `LICENSE` and `NOTICE.md`.
