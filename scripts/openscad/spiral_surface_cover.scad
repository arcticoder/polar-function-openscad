// Thin cover skin for spiral_surface_print.scad.
//
// Follows the same surface f(x1,x2) as the main print, offset upward by
// gap_mm and cover_mm thick (measured vertically). Print it, then glue it onto
// the printed surface to hide blisters / holes.
//
// The surface parameters below MUST match spiral_surface_print.scad.
//
// Orientation: exported as-is (glue face down, visible face up). The glue face
// is the underside, so any supports only touch the hidden side. Slice it with
// supports enabled (see docs/ for slicer notes).

// ---- surface parameters (keep identical to spiral_surface_print.scad) ----
width_mm  = 140;
relief_mm = 60;
base_mm   = 3;
n         = 256;
L         = 2.5;

// ---- cover parameters (mm) ----
cover_mm = 1.6;   // vertical thickness. Normal thickness is ~0.65x this on the steepest slopes (~49 deg)
gap_mm   = 0.15;  // clearance above the printed surface, for glue / first-layer squish

F_BOUND = 1.5 * 2 * L * L;
xy_s    = width_mm / (2 * L);
z_s     = relief_mm / F_BOUND;

assert(cover_mm > gap_mm, "cover_mm must exceed gap_mm");

function f(x, y) =
    let(r2 = x*x + y*y)
    r2 == 0 ? 0
    : r2 * (1 + 0.5 * sin(atan2(y, x) - 5 * ln(r2) * 180 / PI));

function u(i) = -L + 2 * L * i / n;

// vertex indices: upper surface first, then lower (glue) surface
function t(i, j) = j * (n + 1) + i;
function b(i, j) = (n + 1) * (n + 1) + j * (n + 1) + i;

function surf_z(i, j) = base_mm + z_s * f(u(i), u(j));

top_pts = [for (j = [0:n]) for (i = [0:n])
    [u(i) * xy_s, u(j) * xy_s, surf_z(i, j) + cover_mm]];
bot_pts = [for (j = [0:n]) for (i = [0:n])
    [u(i) * xy_s, u(j) * xy_s, surf_z(i, j) + gap_mm]];

top_faces = [for (j = [0:n-1]) for (i = [0:n-1]) each [
    [t(i, j), t(i, j+1), t(i+1, j+1)],
    [t(i, j), t(i+1, j+1), t(i+1, j)]
]];

bot_faces = [for (j = [0:n-1]) for (i = [0:n-1]) each [
    [b(i, j), b(i+1, j), b(i+1, j+1)],
    [b(i, j), b(i+1, j+1), b(i, j+1)]
]];

side_faces = concat(
    [for (i = [0:n-1]) [t(i, 0),   t(i+1, 0), b(i+1, 0), b(i, 0)]],     // y = -L
    [for (i = [0:n-1]) [t(i+1, n), t(i, n),   b(i, n),   b(i+1, n)]],   // y = +L
    [for (j = [0:n-1]) [t(0, j+1), t(0, j),   b(0, j),   b(0, j+1)]],   // x = -L
    [for (j = [0:n-1]) [t(n, j),   t(n, j+1), b(n, j+1), b(n, j)]]      // x = +L
);

module cover() {
    polyhedron(points = concat(top_pts, bot_pts),
               faces  = concat(top_faces, bot_faces, side_faces),
               convexity = 10);
}

cover();
