// Printable solid of the surface
//   f(x1,x2) = (x1^2 + x2^2) * (1 + 0.5*sin(atan2(x2,x1) - 5*ln(x1^2 + x2^2)))
// over [-L, L]^2.
//
// Notes
// - OpenSCAD trig uses degrees and log() is base 10. This file uses ln() and
//   converts the log term (radians) to degrees. "log" in the equation is
//   assumed to be the natural log.
// - f(0,0) is defined as 0 (the limit as r -> 0).
// - Uniform xy scaling and a positive constant scaling of f do not change the
//   sign of the radial derivative r*(2 + sin(phi) - 5*cos(phi)), so the
//   "downhill points away from the origin" regions are preserved by the
//   parameters below.

// ---- print parameters (mm) ----
width_mm  = 140;   // footprint edge length
relief_mm = 60;    // height above the base at f = F_BOUND (18.75, the bound on the domain)
base_mm   = 3;     // solid slab under the minimum at the origin
n         = 256;   // grid cells per side (cell = width_mm / n)

// ---- domain / scaling ----
L       = 2.5;
F_BOUND = 1.5 * 2 * L * L;       // 1.5 * (max r^2 = 2*L^2) = 18.75
xy_s    = width_mm / (2 * L);    // mm per x unit
z_s     = relief_mm / F_BOUND;   // mm per unit of f

// K1 build volume is 220 x 220 x 250 mm
assert(width_mm <= 215, "width_mm exceeds the K1 bed");
assert(base_mm + relief_mm <= 245, "height exceeds the K1 build height");

function f(x, y) =
    let(r2 = x*x + y*y)
    r2 == 0 ? 0
    : r2 * (1 + 0.5 * sin(atan2(y, x) - 5 * ln(r2) * 180 / PI));

function u(i) = -L + 2 * L * i / n;

// vertex indices: top grid first, then bottom grid
function t(i, j) = j * (n + 1) + i;
function b(i, j) = (n + 1) * (n + 1) + j * (n + 1) + i;

top_pts = [for (j = [0:n]) for (i = [0:n])
    [u(i) * xy_s, u(j) * xy_s, base_mm + z_s * f(u(i), u(j))]];
bot_pts = [for (j = [0:n]) for (i = [0:n])
    [u(i) * xy_s, u(j) * xy_s, 0]];

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

module surface() {
    polyhedron(points = concat(top_pts, bot_pts),
               faces  = concat(top_faces, bot_faces, side_faces),
               convexity = 10);
}

surface();
