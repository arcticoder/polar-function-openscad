# polar-function-openscad

OpenSCAD models that turn a polar-style function surface into a 3D-printable solid:

```
f(x1, x2) = (x1^2 + x2^2) * (1 + 0.5 * sin(atan2(x2, x1) - 5 * ln(x1^2 + x2^2)))
```

over the square domain `[-2.5, 2.5]^2`. The result is a spiral-ridged bowl with
a minimum at the origin.

## Why this function

It is meant as the "hardest" function under which standard machine learning
models still work well, so it is a deliberately difficult but still tractable
loss-landscape benchmark. The minimum is at the origin, but the radial
derivative `r * (2 + sin(phi) - 5 * cos(phi))` (with `phi = theta - 10 ln r`)
changes sign, so in some spiral regions "downhill" points away from the origin.
These models turn that landscape into a physical object you can hold.

## Contents

| File | Description |
| --- | --- |
| [scripts/openscad/spiral_surface_print.scad](scripts/openscad/spiral_surface_print.scad) | Solid slab of the surface (140 mm footprint, 60 mm relief, 3 mm base). |
| [scripts/openscad/spiral_surface_cover.scad](scripts/openscad/spiral_surface_cover.scad) | Thin cover skin that follows the surface, glued on to hide blisters or holes. |
| `scripts/openscad/*.stl`, `*.3mf` | Pre-rendered exports (tracked with Git LFS). |
| [docs/](docs/) | Print notes, fixes, and history. See [spiral-surface-print-fixes.md](docs/spiral-surface-print-fixes.md). |

## Usage

1. Install [OpenSCAD](https://openscad.org/).
2. Open a `.scad` file and render (F6), then export to STL or 3MF.
3. Adjust parameters at the top of the file (`width_mm`, `relief_mm`, `base_mm`, `n`).

The surface parameters in `spiral_surface_cover.scad` must match those in
`spiral_surface_print.scad`.

Notes:
- OpenSCAD trig uses degrees and `log()` is base 10, so the files use `ln()` and convert the log term to degrees.
- `f(0,0)` is defined as 0 (the limit as r -> 0).
- Defaults are sized for a Creality K1 (220 x 220 x 250 mm build volume).

## Git LFS

STL, 3MF and PNG files are stored with Git LFS. Run `git lfs install` before cloning.

## License

[MIT](LICENSE)
