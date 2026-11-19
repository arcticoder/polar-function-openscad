# polar-function-openscad

OpenSCAD models that turn a polar-style function surface into a 3D-printable solid:

```
f(x1, x2) = (x1^2 + x2^2) * (1 + 0.5 * sin(atan2(x2, x1) - 5 * ln(x1^2 + x2^2)))
```

over the square domain `[-2.5, 2.5]^2`. The result is a spiral-ridged bowl with
a minimum at the origin.

## Attribution

The function comes from the retrospective described below, which Mark Schmidt
[announced on X](https://x.com/MarkSchmidtUBC/status/2122438238204014898)
alongside the 2026 ECML PKDD Test of Time Award for the 2016 PL paper. It makes a
good loss-landscape benchmark: highly non-convex, yet gradient descent still
converges linearly.

In the retrospective [The Polyak-Łojasiewicz Paper: A 10-Year Retrospective](https://arxiv.org/abs/2611.17745)
(Hamed Karimi, Julie Nutini and Mark Schmidt, 2026, arXiv:2611.17745 [math.OC]), it is called the "toilet flush"
function (Section 2.2). It is a 2-D counter-example that satisfies the
Polyak-Łojasiewicz (PL) condition, so gradient descent still converges linearly,
but not the restricted secant inequality (RSI). The paper (Appendix B) defines it
in polar coordinates as

```
f(r, theta) = r^2 * (1 + 0.5 * sin(theta - 10 * log(r)))
```

with a unique minimum of 0 at the origin. Its radial derivative is
`df/dr = r * (2 + sin(a) - 5 * cos(a))`, where `a = theta - 10 * log(r)`. Since
`r^2 = x1^2 + x2^2`, the Cartesian form above is the same function, with
`10 * ln(r) = 5 * ln(x1^2 + x2^2)` and `log` read as the natural log.

The minimum is at the origin, but the radial derivative changes sign in places,
so "downhill" can point away from the minimizer along parts of the spiral. This
repo only turns that surface into 3D-printable OpenSCAD models. The function and
its analysis belong to the paper's authors.

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
