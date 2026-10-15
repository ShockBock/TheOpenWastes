# The Open Wastes

An entirely open-source game inspired by the Fallout franchise. It uses
procedural generation to build a 3D post-apocalyptic world, explored by the
player from a first-person perspective.

## Running the game

1. Install [Godot 4.7](https://godotengine.org/download) (the standard build;
   .NET is not needed).
2. Clone this repository and open its `project.godot` in Godot.
3. Press **F5** (Run Project).

The first time the project opens, Godot imports its assets, which takes a
minute or two. Blender is **not** needed: models are stored as `.gltf`.

### Controls

| Action | Default |
|---|---|
| Move | W A S D |
| Jump | E |
| Sprint | Shift |
| Shoot | Left mouse button |
| Change weapon | Right mouse button |
| Free the mouse pointer | Pause |
| Exit to menu | Esc |

All of these can be remapped in **Options**.

## Project layout

Files are grouped by the feature they belong to, and every file and folder
name is lower-case `snake_case`.

| Folder | Contents |
|---|---|
| `main/` | Main game scene, start-up sequence, character spawning, music |
| `world/terrain/` | Streamed, procedurally generated terrain |
| `world/buildings/` | Building placement and the modular building001 |
| `world/objects/` | Furniture and other props (works in progress) |
| `player/` | Player controller and weapons |
| `npcs/` | NPCs, their stats and the NPC state machine |
| `combat/` | Projectiles, tracers and muzzle flash |
| `ui/` | Menus |
| `common/` | Font and editor icons |
| `autoload/` | `Settings` (key mapping and mouse options) |
| `tools/ci/` | Automated checks (excluded from exported builds) |

Tuning values live in Resources (`.tres`) rather than in code or nodes: for
example `npcs/shotgun_monk/shotgun_monk_stats.tres` and
`player/weapons/pistol/pistol_stats.tres`. Select one in the FileSystem dock to
edit it in the Inspector.

## Source art

Blender files and other editable art live in a separate repository,
**TheOpenWastes-art**, so this one stays small and needs no Blender. Check it
out beside this one; its README explains how to export models into the game.

## Contributing

Every push and pull request runs the checks in `.github/workflows/checks.yml`:

- **GDScript style**: [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit)
  (`gdformat` and `gdlint`) must pass.
- **Godot**: the project must import cleanly, every script and scene must load,
  and a smoke test plays the main scene and checks the world is built.

To run the same checks locally:

```bash
pip install "gdtoolkit==4.*"
gdformat $(git ls-files '*.gd')
gdlint $(git ls-files '*.gd')
godot --headless --path . --import
godot --headless --path . -s res://tools/ci/check_project.gd
godot --headless --path . -s res://tools/ci/smoke_test.gd
```

In the Godot editor, turn on **Editor Settings → Text Editor → Behavior →
Files → Trim Trailing Whitespace On Save**, so the editor's indentation of
blank lines doesn't fail `gdlint`.

Static typing is expected: the project warns about untyped declarations.

## Licence

MIT; see [LICENSE](LICENSE). Third-party assets and their licences are listed
in [ATTRIBUTIONS.md](ATTRIBUTIONS.md).
