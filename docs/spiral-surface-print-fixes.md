# Spiral surface print: failure analysis and fixes

Hardware (not recorded in gemini-history.md): Creality K1, stock extruder, 0.4 mm brass nozzle, textured PEI plate, **Silk PLA** (not Hyper PLA).

## What failed

Blisters and rough, pitted patches in rings on the shallow-slope part of the bowl (see `failed_print.jpg`). Corners and steep walls are clean. Likely causes, most likely first:

1. **`ensure_vertical_shell_thickness = none`** (set during the time-saving pass). Shallow slopes are where a top skin sits on only a few layers of 5% gyroid. Without the vertical-shell guarantee, the skin spans sparse infill and sags, gaps and blisters. The 4h29m -> 5h49m difference is exactly the solid infill that was removed, so it is also the support that was removed.
2. **Skin too thin / too sparse underneath**: 4 top layers (the 1.0 mm top thickness gives ~8 at 0.12 mm, but adaptive layers of 0.08 mm and up to 0.3 mm vary this), 5% infill, `top_surface_speed` 200 mm/s with the fan at 100%.
3. **Wet filament**: silk PLA is hygroscopic and blistering/popping is the classic symptom. If the spool has been open for a while, dry it (45-50 C, 4-6 h) before reprinting. This is cheap and worth doing regardless.
4. 223 C nozzle with a 12 -> 10 mm^3/s cap is fine. Not a prime suspect.

## Slicer fixes (OrcaSlicer 2.4.2)

| Setting | Was | Change to |
|---|---|---|
| Strength > Advanced > Ensure vertical shell thickness | None | **Ensure all** (or Ensure moderate to save some time) |
| Top shell layers | 4 | 6 (keep top shell thickness 1.0 mm) |
| Sparse infill density | 5% | 10-15% gyroid (gives the skin something to sit on) |
| Top surface speed | 200 | 80-100 |
| Internal solid infill speed | 300 | 150-200 |
| Wall loops | 3 in the 3MF | 2-3 (leave) |
| Seam | aligned in the 3MF | scarf (Contour); the 3MF still says `aligned` |
| Avoid crossing walls | off | leave off |
| Variable layer height | adaptive, 0.08-0.30 | OK. Or use a flat 0.12 mm to remove a variable |
| Max volumetric speed (filament) | 10 | keep 10 |
| Nozzle | 223 | keep, 220-225 |

Expect 5-5.5 h and ~100 g. That is the real cost of a skin that does not blister.

### First layer (mechanical bonding on textured PEI)

| Setting | Current | Recommended for Silk PLA |
|---|---|---|
| First layer height | 0.2 | 0.2 |
| First layer speed | 50 | **30** (outer/inner), first layer infill 50 |
| First layer nozzle temp | 223 | 225 |
| Bed temp, textured PEI, first layer | 58 | **60** |
| Bed temp, other layers | 58 | 55-60 |
| First layer line width | 0.5 | 0.5 |
| Part cooling | fan 100%, off first layer | keep fan closed for 1-3 layers |

Textured PEI grips by pushing the first layer into the texture, so slower and slightly hotter (and a well-squished 0.2 mm layer) beats speed. A 140 x 140 mm footprint should stay down without a brim; add a 5 mm outer brim only if corners lift (the tall corner spikes will pull on it).

### If the first layer will not stick

Work down this list; the first two cause most failures on textured PEI:

1. **Clean the plate**: wash with hot water and dish soap, rinse, dry without touching the surface. IPA alone does not remove skin oil from textured PEI. Do not touch the print area afterward.
2. **Z offset / first-layer squish**: run the K1 auto-leveling again and watch the first lines. They should be slightly flattened and touch each other, not round strings. If they are round, lower the Z offset in 0.02 mm steps (live-adjust during the first layer).
3. **Bed temperature**: raise the first layer to 60-65 C for Silk PLA (it was 58). Let the bed heat-soak 3-5 min before starting.
4. **First layer speed 30 mm/s, fan off for the first layers** (see table above).
5. **First layer flow ratio**: 1.0 -> 1.05 if lines look thin.
6. **Glue stick** (thin, even coat) on the textured sheet, or a 5 mm outer brim. This part has tall corners that pull upward as they cool, so a brim is worth enabling after one failed start.
7. **Filament**: wet silk PLA also extrudes unevenly and bonds poorly, another reason to dry the spool.

## Cover piece

`scripts/openscad/spiral_surface_cover.scad` generates a thin skin that follows the same surface, 0.15 mm above it, 1.6 mm thick (vertical). Print it, glue it on top of the printed part.

- Keep its surface parameters identical to `spiral_surface_print.scad`.
- Printed upright, the underside (the glue face, hidden) is shallow and needs supports. Use normal or tree supports, support type "normal", top Z distance 0.15-0.2, and ensure supports touch the build plate only if you want less material (the bowl cavity is large).
- Use the same fixes as above: 2 walls, 10% infill, ensure vertical shell thickness, or just 3-4 walls and ~100% infill is cheap at 1.6 mm.
- Glue: cyanoacrylate gel or epoxy. Sand/scrape blisters flat first.
- `cover_mm` and `gap_mm` at the top of the file are the knobs. On the steepest slope (~49 deg) the normal thickness is ~1.0 mm.
