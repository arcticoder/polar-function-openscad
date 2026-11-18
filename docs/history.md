
spiral_surface.scad is attached. I have not rendered it, so it is untested in OpenSCAD.

• Log base: OpenSCAD's log() is base 10, so the script uses ln(). This assumes the equation's log is the natural log, which the equation does not state.
• Angle units: sin() and atan2() work in degrees. The phase is computed in radians and converted before calling sin().
• Origin: f(0,0) is set to 0, which is the limit as r → 0, to avoid ln(0).
• Surface and colors: The surface is a closed polyhedron over [−2.5, 2.5]², with its underside at z = −0.5. It is colored by height in 14 bands, blue (low) to red (high). A small red sphere marks the origin.
• Settings: zscale (0.35) compresses the vertical axis, since f reaches about 18.75 at the corners. n (80) sets the grid resolution.
• Rendering speed: The banding uses 14 intersections, which is slow with the CGAL renderer. Use a Manifold-enabled build, or lower n or bands, if rendering takes too long.

The pasted visualization description contradicts itself about the gradient arrow and the "negative gradient" annotation. That does not affect the script, because f ≥ 0 everywhere with its minimum at the origin.
<!-- ------ -->
---
Code-wise, the script isn't print-ready yet. These are the things I'd settle before slicing.

Model changes

• Scale: One unit is currently 1 mm, so the footprint is 5 × 5 mm. Add an xy scale factor s (mm per unit). The K1's bed is 220 × 220 mm, so something like 120-180 mm wide is the usable range.
• Height: The tallest point of the current surface is about 0.35 × 18.75 ≈ 6.6 units, so the height is roughly 1.3× the width. At s = 30 that is about 200 mm of surface plus the base, which is close to the K1's 250 mm limit. Reduce zscale if you want a less tall part.
• Base: zbase is also in units and would scale up to 15 mm at s = 30. Set it in mm after scaling, and 2-3 mm is probably enough.
• Slope: By my arithmetic (not checked numerically), the steepest slope is about 25 × zscale near the corners, which is around 83° from horizontal at zscale = 0.35. Because the surface is a height field, no face points downward, so there are no overhangs and no supports are needed. Slopes that steep will still show heavy layer-line stepping.
• Your two properties are unaffected by scaling: The radial derivative is r(2 + sin φ − 5 cos φ), with φ = θ − 10 ln r. Its sign, and the xy direction of the gradient, don't change under uniform xy scaling or by scaling f by a constant. So zscale and s can be changed freely without losing property 2.
• Resolution: n = 80 gives a cell of about 0.06 units, which is about 1.9 mm at s = 30. That is coarser than the nozzle on the steep regions. Something like n = 250-300 gives about 0.5 mm cells and a few hundred thousand triangles, which is fine for a single polyhedron.
• Print mode: The color bands and the red marker sphere don't survive STL export and aren't needed on a single-material printer. Export just surface(). The bands also make the render much slower at high n.

Physical limits

• Flat center: Near the origin f ≈ r²(1 + 0.5 sin φ), so the height rises very slowly. The region whose height is under one layer is where zscale·s·r² is below the layer height. For example, with s = 30, zscale = 0.35 and 0.2 mm layers, that is r of about 0.14 units, roughly 4 mm. The center will print as a flat terrace a few mm across, and the spiral modulation there is below layer height. That is a printing limit rather than a model error.
• Spiral spacing: The bands repeat at a radius ratio of e^0.628 ≈ 1.87, so there are only about 3-4 visible turns between r = 0.3 and r = 2.5. Anything finer than that is under-resolved at both the mesh and the nozzle level.
• Shallow regions: Low-slope areas are where layer stepping on the top surface is most visible, since each step is a wide terrace. Steep areas look smoother in the stepping sense. That may be relevant to your slicer settings.
• Orientation: The flat bottom can print as-is on the PEI with no rotation, since the base is wide relative to the height.

I haven't tested any of this on the K1 or in OrcaSlicer 2.4.2, so the slicer-specific behavior is yours to check.

I can update the script with an s factor, a base thickness in mm, a print_mode flag and a higher default n if you want.
<!-- ------ -->
---
I'll rewrite the script for printing with no color code and dimensions in mm, then check that the mesh is closed and correctly oriented.

spiral_surface_print.scad is attached. It replaces the earlier script and has no color code.

Checks run

• OpenSCAD isn't installed here, so the script itself has not been rendered.
• I reproduced the face and index construction in Python with n = 8. Every edge is used exactly once in each direction, so the mesh is closed with consistent winding. The signed volume is negative, which matches OpenSCAD's clockwise-from-outside convention, so the faces point outward.
• The log, degree-conversion and origin handling are the same as in the first script.

Script changes

• Parameters: width_mm = 140, relief_mm = 60, base_mm = 3, n = 256. The cell size is about 0.55 mm.
• Relief: relief_mm is the height of the surface above the base at f = 18.75, the upper bound on the domain. The actual peak is lower. On the n = 8 check grid it came out at about 58 mm including the base.
• Slope: By my arithmetic, using the bound on the gradient and not a computed maximum, the steepest slope at these settings is about 70°. The earlier defaults gave about 83°.
• Build volume: Asserts check the K1 build volume (220 × 220 × 250).
• Removed: The colour bands and the origin marker sphere are gone.
• Property 2: Scaling x and y uniformly and f by a positive constant doesn't change the sign of the radial derivative r(2 + sin φ − 5 cos φ), so the regions where downhill points away from the origin are preserved.
• Export: Render with F6 and export STL. With a CGAL build, expect a slow render. A Manifold backend should be fast. The result is roughly 270k triangles.

OrcaSlicer settings

I haven't checked these against 2.4.2, so menu names may differ. They are starting points I haven't tested on this model.

Profiles

• Start from the built-in Creality K1 0.4 mm printer profile.
• Use a Hyper PLA filament profile if one is listed. If not, use the generic PLA profile and set temperatures from the spool.

Quality

• Layer height: 0.12 mm, first layer 0.2 mm.
• Variable layer height: Open it from the object's right-click menu and use the adaptive option. Allow about 0.08-0.16 mm. It spends the fine layers on the shallow regions, where the stair-stepping terraces are widest.
• Seam: Try a scarf seam if the option exists in 2.4.2, otherwise random. The cross-section at each height is the square minus a growing pit around the origin, so the seam lands on the visible landscape surface. Aligned would draw a radial line of dots up the slope. I haven't tested which looks best here.
• Ironing: Off. It acts on flat top surfaces, and I'd expect little benefit on a continuous slope.
• Resolution: Leave at the default. The mesh cell is already coarser than the 0.012 mm gcode resolution.

Strength

• Wall loops: 3.
• Top shell: Thickness of at least 1.0 mm, about 8 layers at 0.12 mm.
• Bottom shell: 5 layers.
• Infill: Gyroid at 10%.
• Top surface pattern: Monotonic.
• Ensure vertical shell thickness: Leave at the default.

Speed and acceleration (conservative)

• Outer wall: About 100 mm/s with about 3000 mm/s² acceleration. Hyper PLA is marketed for high speed, but surface quality matters more here.
• First layer: About 50 mm/s.
• Inner walls and infill: Take them from the K1 profile and raise them if you want a shorter print.

Temperature and cooling

• Nozzle: About 215 °C, within the Hyper PLA range as I remember it (190-230 °C). Check the spool label.
• Bed: 55-60 °C on textured PEI.
• Part cooling: Full fan.
• Enclosure: The usual advice for PLA in an enclosed printer is to open the door or remove the lid, since a long print builds heat.

Adhesion

• Footprint: The flat 140 × 140 mm base should stick without supports. I'd expect no brim to be needed.
• Corners: If the corners lift, add a 5 mm outer brim.
• Elephant foot: Leave the compensation at the profile default unless you see flaring.

Supports

• None. The surface is a height field, so nothing overhangs.

Print time and file size

• Print time: Expect a long print of roughly 500 layers. I haven't estimated the time, so check the slicer's figure.
• G-code size: The G-code will be large. Lower n if loading becomes a problem.
<!-- ------ -->
---
Here is the translation of the instructions into OrcaSlicer 2.4.2 settings and terminology:

Quality

• Layer Height: Set Layer height to 0.12 mm and First layer height to 0.2 mm under the Process settings.
• Variable Layer Height: Right-click the object on the build plate and select Adaptive layer height. Configure the range to 0.08–0.16 mm so finer increments concentrate on shallow terraces.
• Seam: Under Quality, locate the Seam settings and set the seam type to Scarf joint seam (Contour), which is fully supported in 2.4.2. Fall back to Random if a simpler distribution is preferred.
• Ironing: Ensure Enable ironing is unchecked.
• Resolution: Leave the mesh and arc resolution parameters at their profile defaults.

Strength

• Wall Loops: Set to 3 under Strength.
• Top Shell: Set Top shell thickness to 1.0 mm (which translates to approximately 8 layers at a 0.12 mm layer height).
• Bottom Shell: Set Bottom shell layers to 5.
• Infill: Set Sparse infill pattern to Gyroid and Sparse infill density to 10%.
• Top Surface Pattern: Set to Monotonic.
• Ensure Vertical Shell Thickness: Leave at the default profile setting.

Speed and Acceleration

• Outer Wall: Set outer wall speed to roughly 100 mm/s and acceleration to 3000 mm/s² under the Speed and Acceleration tabs.
• First Layer: Set first layer speed to 50 mm/s.
• Inner Walls and Infill: Retain the default K1 profile speeds, scaling them up if shorter print times are desired.

Temperature and Cooling

• Nozzle Temperature: Set to 215 °C under Filament Settings -> Temperature.
• Bed Temperature: Set to 55–60 °C for textured PEI sheets.
• Cooling: Keep part cooling fan at 100%.
• Enclosure: Open the printer door or remove the top lid manually to prevent heat buildup during long PLA prints.

Adhesion

• Footprint / Brim: Leave Brim type set to No brim for the 140 × 140 mm base. If edge lifting occurs, configure a 5 mm outer-only brim under Print Settings -> Skirt and brim, or apply manual mouse-ear tabs using the left toolbar.
• Elephant Foot Compensation: Leave at the default profile value unless base flare is observed.

Supports

• Supports: Ensure Enable support is unchecked under the Support tab.

────────────────────────────────────────────────────────────────────────────────

For a visual demonstration of how the seam options behave, check out this OrcaSlicer scarf joint seam overview. This video provides a quick look at configuring scarf joints to hide surface lines effectively on contoured models.
<!-- ------ -->
---
In OrcaSlicer, Variable Layer Height is accessed from the top toolbar rather than the right-click menu.

Here is how to locate and configure it:

    *Verification:* The object will highlight with a bounding box, and the tool icons along the top menu bar will become active.

    *Shortcut alternative:* Press `Shift + C` on your keyboard.
    
    *Verification:* A vertical layer height preview bar will open on the right side of the 3D viewport.

    *Verification:* The vertical bar on the right side of your model will turn green/yellow/red, showing fine layers assigned to the shallow sloped regions.
<!-- ------ -->
---
I wrote the cover script and the slicer notes. The cover renders as a valid closed solid in OpenSCAD (263,168 facets), but I haven't sliced or printed it. Nothing is committed.

**Cover:** [spiral_surface_cover.scad](scripts/openscad/spiral_surface_cover.scad) follows the same surface as your print. It sits 0.15 mm above it (`gap_mm`, clearance for glue) and is 1.6 mm thick measured vertically (`cover_mm`). On the steepest slope (about 49°) the thickness perpendicular to the surface is about 1.0 mm. I copied the surface parameters from [spiral_surface_print.scad](scripts/openscad/spiral_surface_print.scad), so keep the two files in sync if you change either. It prints upright, so the glue face is the underside and any supports only touch the hidden side. That underside is nearly flat over the shallow slopes, so slice it with supports on.

**Why it failed:** I'm confident about the first cause and less sure about the others. All are in [spiral-surface-print-fixes.md](docs/spiral-surface-print-fixes.md).
1. **Vertical shell thickness:** your 3MF has "Ensure vertical shell thickness" set to None, which Gemini suggested. That is what cut 1h20m of print time. It also removed the solid layers under the shallow slopes, where the blisters are. This is the most likely cause.
2. **Thin skin over sparse infill:** the top shell is 4 layers over 5% gyroid, and top surface speed is 200 mm/s.
3. **Wet filament:** silk PLA blisters and pops when it's damp. I can't tell from the photo, so dry the spool (45–50 °C, 4–6 h) before reprinting.

**Slicer changes:**
- Set "Ensure vertical shell thickness" to Ensure all, or Ensure moderate to save some time.
- Use 6 top shell layers and 10–15% infill.
- Lower top surface speed to 80–100 mm/s and internal solid infill to 150–200 mm/s.
- The 3MF still has the seam as aligned, so set it to scarf.
- Expect roughly 5–5.5 h and about 100 g.

**First layer, Silk PLA on textured PEI:**
- Speed: 30 mm/s (it's 50 now), with first-layer infill at 50.
- Bed: 60 °C for the first layer.
- Nozzle: 225 °C for the first layer.
- Fan: off for the first 1–3 layers.

The doc has the full table, including the cover's own slicing notes. I didn't add the hardware (K1, stock extruder, 0.4 mm brass nozzle, textured PEI) or the correction to Silk PLA to gemini-history.md, since it's a Gemini chat log. I recorded them in the new doc instead. If you want them in gemini-history.md too, say so.
<!-- ------ -->
---
I added a "first layer will not stick" checklist to [spiral-surface-print-fixes.md](docs/spiral-surface-print-fixes.md). I'm guessing at the cause from the settings, so tell me what the first layer looked like if it still fails.

In order of likelihood:

1. **Dirty plate:** wash it with hot water and dish soap. IPA alone doesn't remove skin oil from textured PEI. Don't touch the print area afterward.
2. **Z offset too high:** re-run auto-leveling and watch the first lines. They should be slightly flattened and touching each other. If they look like round strings, lower the Z offset in 0.02 mm steps while it prints.
3. **Bed too cool for Silk PLA:** your 3MF had 58 °C. Use 60–65 °C for the first layer and let the bed soak 3–5 minutes before starting.
4. **First layer settings:** 30 mm/s, fan off for the first 1–3 layers, and first-layer flow ratio 1.05 if the lines look thin.
5. **Extra grip:** a thin coat of glue stick, or a 5 mm outer brim. This model has tall corners that pull upward as they cool, so a brim is worth turning on. In the photo the corners are curled up.
6. **Wet filament:** damp silk PLA also extrudes unevenly and bonds poorly. That's another reason to dry the spool, on top of the blisters.

One thing I couldn't tell: the photo shows a finished print, so I don't know whether this was a failed start you restarted or something that happened mid-print. If the print stuck at first and let go later, it's more likely the corner lift than the first layer.
<!-- ------ -->
---
All four items are done. I haven't committed or pushed the README and LICENSE, because you didn't ask for that.

1. **README:** I added [README.md](README.md). It covers the function, the two `.scad` files, usage, the Git LFS note and the license.
2. **License:** I added [LICENSE](LICENSE) with the MIT text. The copyright holder is "Arcticoder", from your git user name, and the year is 2026. Change the holder if you want your real name there.
3. **Description:** I set it with `gh repo edit`: "OpenSCAD models of a spiral polar-function surface, generated as 3D-printable solids and cover skins".
4. **Topics:** I set these with `gh repo edit`: `openscad`, `3d-printing`, `parametric-design`, `polar-coordinates`, `stl`, `creality-k1` and `math-art`.

`gh repo view` confirmed the description and topics on GitHub. GitHub should detect the MIT license once the LICENSE file is pushed.
<!-- ------ -->
---