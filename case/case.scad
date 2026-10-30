// GrowBox monitor case, L version (2026-10-11)
// 1.8" TFT ST7735 in a bezel printed together with the body (screen.stl geometry 1:1, TFT press-fit from the back),
// screen 10° from vertical, ESP32-C3 Super Mini upside down in an 18 mm base (USB-C at the back).
// L-shaped roof slides up along the screen; held by a rail under the roof plate that catches
// on 2 springy tongues in the body (releasable: pull off with a firmer tug upwards along the screen).
// Printed without supports: body bottom down, roof on its left side (part = "dach").
// Needs screen.stl in the same folder.
//   openscad -D 'part="obudowa"' -o case_body.stl case.scad
//   openscad -D 'part="dach"' -o case_roof.stl case.scad
// GrowBox Monitor case: 1.8" TFT ST7735 (128x160, red board with SD) + ESP32-C3 Super Mini
// The bezel includes mac's screen.stl geometry 1:1 (must sit next to this file).
// Three parts printed separately, all without supports:
//     part="obudowa" -> body (wedge without roof), print bottom down
//     part="ramka"   -> front with TFT pocket, print front down (hooks up)
//     part="dach"    -> removable roof, print top down (snaps up)
//     part="assembly" | "przekroj" | "wnetrze" | "otwarty" -> previews
// Render: openscad -D 'part="obudowa"' -o case_body.stl case.scad
//
// Width = TFT board (36) + side wall 1.6 with 0.2 clearance on each side = 39.6 mm (mac's bezel 38 + 1.6).
// TFT is press-fit in the pocket, as in screen.stl.
// No screws. Roof: 4 push-button snaps in the side walls (front and back of the roof, on both sides):
//     press a pair and lift that side of the roof. The bezel has no snaps:
//     bottom: 2 hooks at the back of the bezel catch behind a ledge in the body (like a hinge),
//     top: the front edge of the roof goes into the chamfer at the top of the bezel and presses it against the body.
//     Assembly: put the bezel hooks behind the ledge (bezel tilted slightly), press it to the body, snap the roof on.
//     Disassembly: remove the roof, tilt the top of the bezel forward and lift it out.
// ESP lies UPSIDE DOWN: components, buttons and USB-C down, heatsink (on the pin label side) up.
// PCB underside 6.6 mm above the floor, supports only under the corners (pads and wires at the sides are free).
// Inserting the ESP: lift the antenna end by 3-4 mm, slide the USB end under 2 catches up to the back
//     wall, then press the antenna end down until the snaps click.
// Removing: slide the board towards USB, push the bar above the snaps forward and lift the antenna end.
// Before mounting, file off the leftover breakaway tabs (teeth) on the short ESP edges; board max approx. 23 mm.
// Route wires from the corner pads straight out sideways first (approx. 2 mm), only then bend them.
// BOOT and RST are pressed with a toothpick through 2 holes in the floor.
// Antenna (ESP end on the screen side) is uncovered: stops and snaps only at the corners.
// USB-C exits through the back wall. Solder wires directly (no dupont connectors).
// All parts print without supports. Stick 4 rubber feet (2-3 mm) under the floor so the floor slots can breathe.
//
// Axes: X width, Y depth (front y=0), Z height (floor underside z=0).
// Front coordinates: u = X, v = up along the screen, w = inwards (perpendicular to the screen).
// Roof coordinates:  x = X, s = along the roof from the ridge, t = inwards (perpendicular to the roof).

part = "none";   // "obudowa" | "dach" | "zlozenie"
$fn = 40;

// ---------- general ----------
tilt  = -2;      // screen tilt from vertical [deg]; negative = top slightly towards the viewer (92°, mac 2026-10-16: loses contrast at 10°)
D     = 58;      // depth at the base
Hs    = 64;      // bezel height along the tilt = screen.stl (mac's requirement)
h0    = 5;       // plinth under the bezel: TFT pin headers (under the board) need room above the floor
Hb    = 30;      // back wall height (to the outer edge of the roof)
wall  = 1.6;     // walls, floor and roof (PET-G: 4 perimeters with a 0.4 nozzle)

// ---------- push-button snaps ----------
// Tapered tongue (thick at the root, thinner at the tooth) and rounded root: when pressed,
// root strain approx. 1.5% (PET-G tolerates approx. 2-3%), previously 2.1% with a straight 1.1 mm tongue.
hk_t = 1.4;      // tongue thickness at the root
hk_tip = 1.1;    // tongue thickness at the tooth (nowhere thinner than before)
hk_w = 10;       // width
hk_L = 13;       // root to tooth (long = soft, does not crack)
hk_b = wall;     // tooth reach into the wall window (0.2 mm back from the face)
hk_bh = 3.5;     // tooth height
hk_r = 0.8;      // root rounding (tension side when pressed)
hk_gap = 0.2;    // tongue - wall clearance
hk_x = wall + hk_gap;                  // outer plane of the tongue (left side)

W = 36 + 2 * (wall + 0.2);             // width: TFT board 36 (sticks out 0.43 past the bezel) + walls with clearance

// ---------- bezel without snaps ----------
tc   = 1.1;      // chamfer on the back top edge of the bezel, parallel to the roof (room for the roof above the bezel)
rs   = 2.0;      // 45° chamfer at the front top of the bezel: the front edge of the roof goes into it
fit  = 0.2;      // bezel - roof clearance
bh_w = 6;        // bottom hook width
bh_u = [2.4, W - 2.4 - bh_w];          // bottom hooks at the sides (centre free for the TFT pin headers)
// hook profile in (v, w): 1.8 arm above the ledge, finger with 45° chamfer behind the ledge
bh_pts  = [[0, 0], [1.8, 0], [1.8, 3.4], [-1.5, 3.4], [0, 1.9]];
// ledge in the body (v, w): top 0.3 below the arm, back slanted 0.3 from the finger
lip_pts = [[-0.3, -2], [-0.3, 1.776], [-4, 5.476], [-4, -2]];
// free room for the hook in the body (v, w)
bh_room = [[-0.3, -1], [3, -1], [3, 4.2], [-2.0, 4.2], [-2.0, 3.476], [-0.3, 1.776]];

// ---------- TFT: geometry from mac's bezel (screen.stl, 38 x 64 x 4, the one in the photos) ----------
// screen.stl: front z=0, PCB pocket 36 x 60 from z=2.83, window 34.2 x 46, bottom (LCD ribbon) at y<0
fr_w = 38; fr_l = 64;
pk_w = 34; pk_l = 58;   // TFT board per the pocket in screen.stl (34.2 x 58.2)
pk_z = 2.83;            // pocket floor (front of the TFT board)
tft_pcb = 1.6;
bt   = 4.0;             // bezel thickness (as screen.stl)
fr_v0 = 0;              // bezel = screen.stl over the full height

// ---------- ESP32-C3 Super Mini ----------
esp_l = 22.52; esp_w = 18.0; esp_t = 0.8;
usb_over = 0.6;  // socket sticks out past the PCB edge
usb_w = 8.94; usb_h = 3.2;
// ESP lies upside down: components, buttons and USB-C down, heatsink (pin label side) up
hs_a  = 14;      // heatsink: width (estimated from photos, not measured)
hs_l  = 15;      // heatsink: length along the board
hs_h  = 6;       // heatsink: ESP with USB-C and heatsink = 10 mm (mac)
hs_off = 1.5;    // heatsink distance from the USB edge (heatsink up to 15 mm wide clears the catches at USB)
esp_lift = 6.6;  // PCB underside above the floor (USB-C 3.2 mm hangs below, the plug fits above the bed); z=8.2 = multiple of the layer height
esp_z = wall + esp_lift;               // ESP PCB underside
esp_y1 = D - wall - usb_over;          // back PCB edge (USB side)
esp_y0 = esp_y1 - esp_l;               // front PCB edge (antenna)
esp_x0 = (W - esp_w) / 2;
usb_cz = esp_z - usb_h / 2;           // socket hangs below the PCB
plug_w = 11.5; plug_h = 6.5;           // USB-C plug opening (smaller, mac 2026-10-15)
btn_dx = 4.9;                          // BOOT/RST: 4.1 mm from the long ESP edges, approx. 10-14 mm from the USB edge


P1 = [0, h0];
P2 = P1 + [Hs * sin(tilt), Hs * cos(tilt)];
R  = [D, Hb];
function prof() = [[0, 0], [D, 0], R, P2, P1];
rl = norm(R - P2);
rr = (R - P2) / rl;                     // roof direction (from the ridge down)
roof_hook_s = [rl * 0.45, rl * 0.82];  // roof buttons (from the ridge)
rn = [-rr[1], rr[0]];          // outer roof normal
// roof normal in front coordinates (v, w): for the bezel chamfer
a_v = rn[0] * sin(tilt) + rn[1] * cos(tilt);
a_w = rn[0] * cos(tilt) - rn[1] * sin(tilt);
lid_ztop = P1[1] + (Hs + 0.6) * cos(tilt) + bt * sin(tilt);   // top of the roof above the bezel (cut flat)
// roof local (x, s, t) -> global; t grows inwards
M_roof = [[1, 0, 0, 0], [0, rr[0], -rn[0], P2[0]], [0, rr[1], -rn[1], P2[1]]];
M_roof_inv = [[1, 0, 0, 0], [0, rr[0], rr[1], -(rr[0] * P2[0] + rr[1] * P2[1])],
              [0, -rn[0], -rn[1], rn[0] * P2[0] + rn[1] * P2[1]]];

module ext(w = W) multmatrix([[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0]]) linear_extrude(w) children();
module face() multmatrix([[1, 0, 0, 0], [0, sin(tilt), cos(tilt), P1[0]], [0, cos(tilt), -sin(tilt), P1[1]]]) children();
module roof() multmatrix(M_roof) children();

// snap: tongue grows in +Z from z=0, outer face at x=0, tooth sticks out in -x (into the wall window)
module snap_hook() translate([0, hk_w, 0]) rotate([90, 0, 0]) linear_extrude(hk_w) {
  polygon([[0, 0], [hk_t, 0], [hk_tip, hk_L], [hk_tip, hk_L + hk_bh], [0, hk_L + hk_bh]]);
  // tooth: flat catch edge, chamfer on the outer corner (shorter overhang when printing)
  polygon([[0.01, hk_L], [-hk_b + 0.5, hk_L], [-hk_b, hk_L + 0.5], [-hk_b, hk_L + 1.2], [0.01, hk_L + hk_bh]]);
  // root rounding
  difference() {
    translate([-hk_r, 0]) square([hk_r + 0.01, hk_r]);
    translate([-hk_r, hk_r]) circle(r = hk_r);
  }
}
// chamfer on the inner wall edge at the tongue root (room for the rounding, easier sliding in)
module root_relief() translate([0, hk_w + 1, 0]) rotate([90, 0, 0]) linear_extrude(hk_w + 2)
  polygon([[-hk_gap + 0.01, -0.5], [-hk_gap - 1.5, -0.5], [-hk_gap + 0.01, 1.0]]);
// window in the wall for the tooth (button pressed with a finger)
// up = +1/-1: which end of the window is higher; there the tooth edge is extended (ext),
// so the top edge of the window is steep (>45°) and prints without supports
module snap_window(up, ext) hull() {
  translate([-wall - hk_gap - 1, -0.3, hk_L - 0.15]) cube([wall + 1 + 0.1, hk_w + 0.6, hk_bh + 0.45]);
  translate([-wall - hk_gap - 1, up > 0 ? hk_w + 0.3 + ext : -0.3 - ext, hk_L - 0.15]) cube([wall + 1 + 0.1, 0.01, 0.01]);
}
// pair of snaps (left and right) in local coordinates: Y = position, Z = depth
module snap_pair(y) {
  translate([hk_x, y, 0]) children();
  translate([W - hk_x, y, 0]) mirror([1, 0, 0]) children();
}

// ================= BODY =================
module shell() {
  difference() {
    ext() polygon(prof());
    translate([wall, 0, 0]) ext(W - 2 * wall) offset(delta = -wall) polygon(prof());
    // open front (leaves a rim for the bezel)
    face() translate([wall, 1.2, -1]) cube([W - 2 * wall, Hs + 10, wall + 1.5]);   // all the way to the top: no beam on the ridge
  }
}
module roof_zone(t0 = -60, t1 = wall) roof() translate([-1, -60, t0]) cube([W + 2, rl + 120, t1 - t0]);

module body() {
  difference() {
    union() {
      difference() {
        shell();
        roof_zone(t1 = wall + 0.05);   // the roof is a separate part
      }
      esp_holder();
      // ledges for the bezel hooks
      intersection() {
        ext() polygon(prof());
        for (u = bh_u) face() translate([u - 0.4, 0, 0]) ext(bh_w + 0.8) polygon(lip_pts);
      }
    }
    // room for the bezel hooks
    for (u = bh_u) face() translate([u - 0.4, 0, 0]) ext(bh_w + 0.8) polygon(bh_room);
    // windows for the roof buttons
    for (s = roof_hook_s) roof() translate([0, 0, wall]) snap_pair(s - hk_w / 2) { snap_window(-1, 1.6); root_relief(); }
    // USB-C
    translate([W / 2, D - wall - 0.01, usb_cz]) rotate([-90, 0, 0])
      hull() for (dx = [-1, 1], dz = [-1, 1]) translate([dx * (plug_w / 2 - 2), dz * (plug_h / 2 - 2), 0]) cylinder(r = 2, h = wall + 2);
    // slots in the floor under the ESP (cool air from below), avoiding the buttons
    for (dx = [-9, 9]) translate([W / 2 + dx - 0.8, esp_y0 + 3, -1]) cube([1.6, esp_l - 6, wall + 2]);
    translate([W / 2 - 1.2, esp_y0 + 3, -1]) cube([2.4, esp_l - 6, wall + 2]);
    // holes for BOOT and RST (buttons are on the ESP underside): press with a toothpick
    for (dx = [-btn_dx, btn_dx]) hull() for (bx = [10.8, 12.8]) translate([W / 2 + dx, esp_y1 - bx, -1]) cylinder(d = 3, h = wall + 2);
    // slots in the back wall (above USB, near the heatsink)
    for (z = [13.4, 16.2, 19.0, 21.8], x = [10, W / 2 + 0.8]) translate([x, D - wall - 1, z]) cube([W / 2 - 10.8, wall + 2, 1.2]);
  }
}

// ================= ROOF (removable) =================
module lid() {
  difference() {
    union() {
      difference() {
        // roof extended forward over the bezel (one roof plane, no seam on the ridge)
        intersection() {
          ext() polygon([P2 - 6 * rr, R, [D, 0], [-10, 0], [-10, (P2 - 6 * rr)[1]]]);
          union() {
            roof_zone();
            face() translate([-1, Hs - rs - 1, -bt - 1]) cube([W + 2, 30, bt + 1]);   // in front of the bezel full depth (into the bezel chamfer)
          }
          face() translate([-1, -50, -bt]) cube([W + 2, 200, 100]);
        }
        // in front of the bezel the roof only goes down to the chamfer at its top
        face() translate([-1, -50, -bt - 1]) cube([W + 2, 50 + Hs - rs + 0.9, bt + 1]);
        // top above the bezel cut flat
        translate([-1, -50, lid_ztop]) cube([W + 2, 200, 50]);
      }
      roof() translate([0, 0, wall - 0.01]) for (s = roof_hook_s) snap_pair(s - hk_w / 2) snap_hook();
    }
    // bezel (with clearance): the roof wraps around its top
    face() translate([0, 0, -bt]) bezel_env(fit);
    // undercut from below at the ridge: room for the top edge of the TFT board (roof top unchanged)
    intersection() {
      face() translate([-1, -10, -1]) cube([W + 2, Hs + 20, 1.8]);
      roof() translate([-1, -10, 1.2]) cube([W + 2, 30, 5]);
    }
    // slots in the roof (heat escapes at the top)
    for (s = [rl * 0.45, rl * 0.6, rl * 0.75]) roof() translate([12, s - 0.9, -5]) cube([W - 24, 1.8, 10]);
  }
}

// ESP holder (board upside down, components down): supports only under the corners (between the pads
// and the edge, clear of the USB socket), at USB rigid catches above the PCB, at the antenna rigid
// stops in front of the edge (take the plug insertion force) and 2 springy snaps joined by
// a bar (one press releases both), with a deflection stop at the front.
module sym() { children(); translate([W, 0, 0]) mirror([1, 0, 0]) children(); }
module yz(w) rotate([90, 0, 90]) linear_extrude(w) children();   // (y, z) profile extruded along X
module esp_holder() {
  gz = esp_z + esp_t + 0.6;          // underside of catches and barbs: 0.6 clearance (PCB 0.8), 0.4 (PCB 1.0); z=9.6
  tw = 3; tt = 1.0; cf = 0.5;        // snap: width, thickness, distance from the PCB edge
  sym() translate([esp_x0, 0, 0]) {
    // --- back (USB) ---
    // v6: no support under the PCB corner at USB (it tore off a component when sliding in); ESP rests on the USB socket
    translate([-1.4, esp_y1 + 0.16, wall - 0.01]) cube([1.4 + 2.3, D - wall - esp_y1 - 0.16 + 0.01, gz - wall + 0.02]);  // stop behind the PCB (next to the plug)
    translate([-1.4, esp_y1 - 1.0, wall]) cube([1.2, D - wall - esp_y1 + 1.01, gz + 1.2 - wall]);                      // side guide
    translate([-1.4, esp_y1 - 1.0, gz]) cube([1.4 + 1.2, D - wall - esp_y1 + 1.01, 1.2]);                              // catch above the PCB
    // --- front (antenna) --- v3 (2026-10-15): vertical snaps with a crossbar cracked along the layers.
    // Now side tabs flexing horizontally (X): vertical plate along Y, root in a post at the front,
    // bends in the layer plane. Tooth 0.5 mm above the PCB corner (before the pads), 45° chamfer from below.
    translate([0, esp_y0 - 1.5, wall - 0.01]) cube([2.4, 1.2, esp_lift + esp_t + 0.6]);                  // stop in front of the PCB
    translate([0, esp_y0 - 1.5, wall - 0.01]) cube([2.4, 1.5 + 1.2, esp_lift + 0.01]);                   // corner support
    translate([0, 0, 0]) yz(2.4) polygon([[esp_y0 - 1.49, wall - 0.01], [esp_y0 - 1.49, wall + 4.5], [esp_y0 - 6, wall - 0.01]]);  // 45° brace
    translate([1.0 - 0.01, esp_y0 + 0.5, wall - 0.01]) cube([3.8 + 0.01, 0.7, esp_lift + 0.01]);          // support under the PCB
    // tab
    translate([-ek_g - ek_t, 0, 0]) {
      translate([0, ek_yp - 2, wall - 0.01]) cube([ek_t, 2.01, ek_ztop - wall + 0.01]);                 // post (root)
      yz(ek_t) polygon([[ek_yp - 1, wall - 0.5], [ek_yp - 1, ek_ztop], [ek_ye, ek_ztop], [ek_ye, ek_zh], [ek_yp - 0.5, wall - 0.5]]);    // plate, 45° underside
      translate([ek_t - 0.01, 0, 0]) intersection() {                                                   // tooth above the PCB
        translate([0, ek_ye - 1.4, 0]) cube([2, 1.4, 20]);
        rotate([90, 0, 0]) translate([0, 0, -50]) linear_extrude(100)
          polygon([[0, ek_zh], [ek_g + ek_o, ek_zh], [ek_g + ek_o, ek_zh + 0.2], [0, ek_zh + 0.2 + ek_g + ek_o]]);
      }
      // deflection stop: the tab can move outwards by 0.8 mm
      translate([-0.8 - 1.2, ek_ye - 2.4, wall - 0.01]) cube([1.2, 2.4, ek_zh - wall]);
    }
  }
  // cradle under the USB-C socket: channel shaped like the socket (oval 8.94 x 3.2), sides up to half the socket height,
  // entry on the antenna side widened 45° so the socket slides into it by itself
  difference() {
    translate([W / 2 - usb_w / 2 - 1.2, esp_y1 - 6.25, wall - 0.01]) cube([usb_w + 2.4, 5.95, usb_cz - wall + 0.01]);
    usb_shell(0.15, esp_y1 - 7, esp_y1 + 1);
    hull() { usb_shell(0.15, esp_y1 - 5.0, esp_y1 - 4.99); usb_shell(1.4, esp_y1 - 7, esp_y1 - 6.24); }
  }
}
ek_t = 1.6;                       // tab thickness
ek_g = 0.2;                       // tab - PCB edge clearance
ek_o = 0.45;                      // tooth reaches 0.45 mm over the PCB (thicker tab: less deflection)
ek_zh = esp_z + 1.0;              // tooth underside (PCB 0.8: 0.2 clearance, PCB 1.0: flush)
ek_ztop = ek_zh + 0.9 + ek_g + ek_o;
ek_ye = esp_y0 + 1.4;             // tab end: 1.4 mm along the PCB (before the first pad)
ek_yp = ek_ye - (ek_zh - wall);   // root: 45° underside from the floor to the tooth

// ================= BEZEL (local: front z=0, features grow in +Z) =================
fr_c = [W / 2, fr_v0 + fr_l / 2];

module bezel() difference() { bezel_raw(); bezel_top_cut(0); }
module bezel_raw() {
  difference() {
    cube([W, Hs, bt]);
    translate([fr_c[0] - fr_w / 2, fr_c[1] - fr_l / 2, -1]) cube([fr_w, fr_l, bt + 2]);
  }
  // mac's bezel 1:1 (mirror in X keeps the side as seen from the front)
  translate([fr_c[0], fr_c[1], 0]) mirror([1, 0, 0]) import("screen.stl", convexity = 6);
  // bottom hooks (catch behind the ledge in the body)
  for (u = bh_u) translate([u, 0, bt - 0.01]) ext(bh_w) polygon(bh_pts);
}
// top of the bezel to cut away: 45° chamfer at the front and back chamfer parallel to the roof; g = clearance (for the roof)
module bezel_top_cut(g = 0) {
  c = g * sqrt(2);
  translate([-1, 0, 0]) ext(W + 2)
    polygon([[Hs - rs + c - 1, -1], [Hs + 10, -1], [Hs + 10, rs + 2], [Hs + c + 2, rs + 2]]);
  multmatrix([[1, 0, 0, 0], [0, -a_w, a_v, Hs - (tc - g) * a_v], [0, a_v, a_w, bt - (tc - g) * a_w]])
    translate([-1, -20, 0]) cube([W + 2, 40, 20]);
}
// bezel outline grown by clearance g (cut out of the roof)
module bezel_env(g) difference() {
  translate([-1, -1, -g]) cube([W + 2, Hs + 1 + g, bt + 2 * g]);
  bezel_top_cut(g);
}

// ================= PREVIEW DUMMIES =================
module tft_dummy() {
  translate([fr_c[0], fr_c[1], 0]) {
    color("#222") translate([-17, -23, 0.05]) cube([34, 46, pk_z - 0.05]);
    color("#c62828") translate([-pk_w / 2 + 0.25, -pk_l / 2 + 0.25, pk_z]) cube([pk_w - 0.5, pk_l - 0.5, tft_pcb]);
    color("#111") translate([-10.2, -pk_l / 2 + 1.5, pk_z + tft_pcb]) cube([20.4, 2.5, 2.5]);
    color("gold") for (i = [0 : 7]) translate([-8.9 + i * 2.54, -pk_l / 2 + 2.75, pk_z + tft_pcb]) cylinder(d = 0.64, h = 8.5, $fn = 8);
    color("silver") translate([1, 2, pk_z + tft_pcb]) cube([15, 15, 2.5]);
  }
}
// USB-C socket outline (oval) along Y, cl = clearance; socket underside always at z = esp_z - usb_h
module usb_shell(cl, y0, y1) hull() for (dx = [-1, 1])
  translate([W / 2 + dx * (usb_w / 2 - usb_h / 2), y0, usb_cz + cl]) rotate([-90, 0, 0]) cylinder(r = usb_h / 2 + cl, h = y1 - y0, $fn = 48);
module esp_dummy() {
  // upside down: components down, heatsink on the pin label side (up)
  translate([esp_x0, esp_y0, esp_z]) {
    color("#1a1a1a") cube([esp_w, esp_l, esp_t]);
    color("silver") translate([-esp_x0, -esp_y0, -esp_z]) usb_shell(0, esp_y1 + usb_over - 7.35, esp_y1 + usb_over);
    color("#333") translate([esp_w / 2 - 2.5, esp_l - 14, -0.9]) cube([5, 5, 0.9]);
    color("#ddd") for (x = [2.6, esp_w - 2.6 - 3.0]) translate([x, esp_l - 13.6, -1.6]) cube([3.0, 3.6, 1.6]);
    color("#b5651d") translate([esp_w / 2 - 2.5, esp_l - 21.0, -1.0]) cube([5, 1.6, 1.0]);
    color("goldenrod") translate([esp_w / 2 - hs_a / 2, esp_l - hs_off - hs_l, esp_t]) {
      cube([hs_a, hs_l, 2]);
      for (i = [0 : 5], j = [0 : 4]) translate([0.3 + i * 2.4, 0.4 + j * 3.0, 2]) cube([1.0, 2.2, hs_h - 2]);
    }
  }
}

module front_asm() face() translate([0, 0, -bt]) {
  color("#4a4f54") bezel();
  tft_dummy();
}
module assembly() {
  color("#6d7378") body();
  color("#7d838a") lid();
  front_asm();
  esp_dummy();
}

// ================= L VERSION =================
HbL = 19;            // base height (+1 mm above the heatsink, mac 2026-10-16)
wi  = 5;             // turret depth behind the TFT board (SD slot ~2.5 mm)
wt  = wi + wall;
Rf  = 8;             // inner corner rounding of the L
vcap = Hs + 0.6; vtop = vcap + wall;
function fp(v, w) = [P1[0] + v * sin(tilt) + w * cos(tilt), P1[1] + v * cos(tilt) - w * sin(tilt)];
function zv(z, w) = (z - P1[1] + w * sin(tilt)) / cos(tilt);
d2 = [sin(tilt), cos(tilt)];
C  = fp(zv(HbL, wt), wt);
th = 90 - tilt;                       // angle between the base and the back of the turret (air)
tf = Rf / tan(th / 2);
bis = [cos(th / 2) * 1 + 0, 0];       // placeholder
T1 = C + [tf, 0];
T2 = C + d2 * tf;
bv = ([1, 0] + d2) / norm([1, 0] + d2);
O  = C + bv * (Rf / sin(th / 2));
module profL(lip = true) union() {
  polygon(lip ? [[0, 0], [D, 0], [D, HbL], C, fp(vtop, wt), fp(vtop, -bt - 1), fp(Hs - rs + 0.9, -bt - 1), fp(Hs - rs + 0.9, 0), P1]
              : [[0, 0], [D, 0], [D, HbL], C, fp(vtop, wt), fp(vtop, 0), P1]);
  difference() { polygon([C, T1, T2]); translate(O) circle(r = Rf, $fn = 96); }
}
module cav() offset(delta = -wall) profL(false);
module bodyzone(c = true) union() {
  if (c) cav();
  translate([-30, -5]) square([D + 40, HbL - wall + 5]);
  polygon([fp(-20, wi), fp(vcap, wi), fp(vcap, 0), fp(-20, 0)]);
}
module shellL() difference() {
  ext() profL();
  translate([wall, 0, 0]) ext(W - 2 * wall) cav();
  face() translate([wall, 1.2, -1]) cube([W - 2 * wall, vcap - 1.2 - 0.05, wall + 1.5]);   // -0.05: not in the inner plane
}
module bodyL() difference() {
  union() {
    // body = (solid ∩ body zone) − interior; interior reaches 0.1 above the base ceiling (no zero-thickness sheet)
    difference() {
      intersection() { ext() profL(); translate([-1, 0, 0]) ext(W + 2) bodyzone(); }
      translate([wall, 0, 0]) ext(W - 2 * wall) cav();
      translate([wall, 18, HbL - wall - 0.1]) cube([W - 2 * wall, D - wall - 18, 1]);
      face() translate([wall, 1.2, -1]) cube([W - 2 * wall, vcap - 1.2, wall + 1.5]);
      face() translate([wall, vcap - 0.1, -0.5]) cube([W - 2 * wall, 2, wi + 0.5]);   // same, under the turret cap
      face() translate([wall, 14, wi - 0.1]) cube([W - 2 * wall, vcap - 13, 2]);   // same, back of the turret
    }
    esp_holder();
    // stiffening the turret sides (behind the TFT board, next to the SD slot)
    for (x = [wall - 0.01, W - 2 * wall + 0.01 - 0.01]) intersection() {
      translate([x, 0, 0]) ext(wall + 0.01) polygon([fp(-20, 1), fp(vcap, 1), fp(vcap, wi - 0.05), fp(-20, wi - 0.05)]);
      translate([-1, 0, 0]) ext(W + 2) polygon([[0, wall], [D, wall], [D, 100], [0, 100]]);
      translate([-1, 0, 0]) ext(W + 2) cav();
    }
    // screen bezel as part of the body (screen.stl geometry 1:1), no separate part
    face() translate([0, 0, -bt]) bezel_fixed();
    // full plinth under the bezel down to the bed (one solid with the bezel)
    ext() polygon([[0.01, 0], [0.01, P1[1] + 0.01], fp(0.02, -bt), [fp(0, -bt)[0], 0]]);
    // roof snap catches
    lc_blocks();
  }
  translate([W / 2, D - wall - 0.01, usb_cz]) rotate([-90, 0, 0])
    hull() for (dx = [-1, 1], dz = [-1, 1]) translate([dx * (plug_w / 2 - 2), dz * (plug_h / 2 - 2), 0]) cylinder(r = 2, h = wall + 2);
  for (dx = [-9, 9]) translate([W / 2 + dx - 0.8, esp_y0 + 3, -1]) cube([1.6, esp_l - 6, wall + 2]);
  translate([W / 2 - 1.2, esp_y0 + 3, -1]) cube([2.4, esp_l - 10.5, wall + 2]);   // shorter: a cradle sits under the USB socket
  for (dx = [-btn_dx, btn_dx]) hull() for (bx = [10.8, 12.8]) translate([W / 2 + dx, esp_y1 - bx, -1]) cylinder(d = 3, h = wall + 2);
  for (z = [12.2, 14.6], x = [10, W / 2 + 0.8]) translate([x, D - wall - 1, z]) cube([W / 2 - 10.8, wall + 2, 1.2]);
}
module lidL() union() {
  difference() {
    shellL();
    face() translate([0, 0, -bt]) bezel_env(fit);   // the roof wraps around the top of the bezel
    translate([-1, 0, 0]) ext(W + 2) bodyzone();
    // slots above the heatsink
    for (y = [esp_y0 + 6 : 3 : esp_y1 - 3]) translate([12, y, HbL - 3]) cube([W - 24, 1.6, 5]);
  }
  // rail with a nose under the roof plate: catches on the tongues in the body
  lc_tongues();
}
m = [sin(tilt), cos(tilt)];   // the roof comes off upwards along the screen
module old_body() { body(); lid(); }
module asmL() { color("#6d7378") bodyL(); color("#8a9096") lidL(); tftF(); esp_dummy(); }

tb_w = pk_z + tft_pcb - bt;   // back of the TFT board in front coordinates (w)
module bezel_fixed() difference() {
  union() {
    difference() {
      cube([W, Hs, bt + 0.05]);   // overlaps 0.05 into the body (one solid)
      translate([fr_c[0] - fr_w / 2, fr_c[1] - fr_l / 2, -1]) cube([fr_w, fr_l, bt + 2]);
    }
    translate([fr_c[0], fr_c[1], 0]) mirror([1, 0, 0]) import("screen.stl", convexity = 6);
    // back of the bezel at the sides overlaps 0.05 into the walls (no touching planes with negative tilt)
    for (x = [0, W - wall]) translate([x, 0, bt - 0.01]) cube([wall, Hs, 0.06]);
  }
  bezel_top_cut(0);
}
module tftF() face() translate([0, 0, -bt]) tft_dummy();

// ---------- roof snap ----------
// Roof: full-width rail under the plate (profile along X, prints on its side without supports).
// Body: 2 springy tongues with a 45/45 tooth (releasable snap: the roof comes off with a firmer
// tug upwards along the screen, won't fall off by itself).
dt_r0 = 22;        // rail front (Y)
dt_zb = 12.0;      // rail underside
dt_x  = 7;         // tongue width
// left end of the rail cut at 45° (the roof prints on its left side: no overhang)
module dt_rail() intersection() {
  dt_rail_raw();
  translate([0, D + 1, 0]) rotate([90, 0, 0]) linear_extrude(D + 2) polygon([[wall + 0.2, HbL], [W, HbL], [W, 0], [wall + 0.2 + HbL, 0]]);
}
module dt_rail_raw() translate([wall + 0.2, 0, 0]) ext(W - 2 * wall - 0.4)
  polygon([[dt_r0, HbL - wall + 0.01], [dt_r0, dt_zb], [dt_r0 + 1.2, dt_zb], [dt_r0 + 2.2, dt_zb + 1.0], [dt_r0 + 1.2, dt_zb + 2.0], [dt_r0 + 1.2, HbL - wall + 0.01]]);
// tongue: y from dt_r0+2.4, thickness 1.4, from the floor to z=15.6; tooth in -y above the rail nose
module dt_tongue_prof() {
  y0 = dt_r0 + 2.4; zt = dt_zb + 1.2;   // tooth 0.2 above the nose (45° chamfers parallel)
  polygon([[y0, wall - 0.01], [y0 + 1.4, wall - 0.01], [y0 + 1.4, 15.6], [y0, 15.6]]);
  polygon([[y0 + 0.01, zt - 0.2], [y0 - 0.8, zt + 0.6], [y0 - 0.8, zt + 1.0], [y0 + 0.01, zt + 1.8]]);
}
module dt_tongues() for (x = [7, W - 7 - dt_x]) translate([x, 0, 0]) ext(dt_x) dt_tongue_prof();

// ================= SELECTION =================
if (part == "obudowa") bodyL();
else if (part == "dach") multmatrix([[0, 1, 0, 0], [0, 0, 1, 0], [1, 0, 0, 0]]) lidL();   // on the left side
else if (part == "zlozenie") asmL();
else if (part == "nakladka") nk_print();
else if (part == "zlozenie_nk") { asmL(); color("#3a3f44") nakladka(); }

// ---------- roof snap v2 (2026-10-15) ----------
// v1: the tongues in the body broke along the layers (printed vertically, bent across the layers).
// v2: the springy tongue is in the ROOF (the roof prints on its side: the tongue bends along the layers),
// the body only has a rigid, short catch with a nose on the floor. 45/45 chamfers: releasable snap.
lc_y0 = 22.6;      // tongue front (Y), in front of the ESP tab posts
lc_t  = 1.6;       // tongue thickness
lc_zb = 6.0;       // tongue underside
lc_zr = HbL - wall;  // root (underside of the roof plate)
// tongue in (x, z): trapezoid, bottom edge on the bed side (when printing) cut at 45°
lc_l = [[wall + 0.2, lc_zr + 0.01], [19.2, lc_zr + 0.01], [19.2, lc_zb], [wall + 0.2 + (lc_zr - lc_zb), lc_zb]];
lc_w = 7;          // tongue width (v4: both at the walls, symmetric; centre free for wires)
lc_r = [[W - wall - 0.2 - lc_w, lc_zr + 0.01], [W - wall - 0.2, lc_zr + 0.01], [W - wall - 0.2, lc_zb], [W - wall - 0.2 - lc_w, lc_zb]];
lc_l2 = [[wall + 0.2, lc_zr + 0.01], [wall + 0.2 + lc_w, lc_zr + 0.01], [wall + 0.2 + lc_w, lc_zb], [wall + 0.2, lc_zb]];
module lc_xz(pts) translate([0, lc_y0 + lc_t, 0]) rotate([90, 0, 0]) linear_extrude(lc_t + 0.81) polygon(pts);
module lc_tongues() for (pts = [lc_l2, lc_r]) union() {   // v4: left and right at the walls
  intersection() { lc_xz(pts); translate([0, lc_y0, 0]) cube([W, lc_t, 30]); }
  // tooth in -y at the bottom of the tongue
  intersection() {
    lc_xz(pts);
    translate([0, 0, 0]) rotate([90, 0, 90]) linear_extrude(W)
      polygon([[lc_y0 + 0.01, lc_zb], [lc_y0 - 0.8, lc_zb + 0.8], [lc_y0 - 0.8, lc_zb + 1.0], [lc_y0 + 0.01, lc_zb + 1.8]]);
  }
}
// rigid catch in the body in front of the tooth (same width as the tongue bottom)
module lc_block_prof() polygon([[lc_y0 - 3.4, wall - 0.01], [lc_y0 - 1.0, wall - 0.01], [lc_y0 - 1.0, lc_zb + 1.0],
  [lc_y0 - 0.2, lc_zb + 1.8], [lc_y0 - 0.2, lc_zb + 2.4], [lc_y0 - 1.0, lc_zb + 3.2], [lc_y0 - 3.4, lc_zb + 3.2]]);
module lc_blocks() {   // fused with the walls
  translate([wall - 0.01, 0, 0]) ext(lc_l2[2][0] - wall + 0.01) lc_block_prof();
  translate([lc_r[3][0], 0, 0]) ext(W - wall + 0.01 - lc_r[3][0]) lc_block_prof();
}

// ---------- left roof snap v3: flap in the left wall ----------
// The roof prints on its left side, so the flap lies flat on the bed and bends along the layers (outwards).
// The tooth on the inner side catches under the slanted nose of the block in the body. Flap edges parallel
// to the roof removal direction (m). Centre of the case free for wires.
st_ya = 25; st_yb = 37;            // flap (y at z = roof underside)
st_zn = 4.4;                       // bottom of the notch in the wall
tn = tan(tilt);
function st_y(y, z) = y + (z - lc_zr) * tn;
module st_par(ya, yb, z0, z1) rotate([90, 0, 90]) linear_extrude(wall)
  polygon([[st_y(ya, z0), z0], [st_y(yb, z0), z0], [st_y(yb, z1), z1], [st_y(ya, z1), z1]]);
module st_notch() translate([-0.01, 0, 0]) scale([1.02, 1, 1]) st_par(st_ya, st_yb, st_zn, lc_zr + 1);
module st_tab() {
  st_par(st_ya + 0.2, st_yb - 0.2, st_zn + 0.2, lc_zr + 0.01);
  // tooth: sticks out 0.9 inwards, 45° chamfers
  translate([0, st_y(st_ya + 0.6, 5.7), 0]) rotate([90, 0, 0]) translate([0, 0, -(st_yb - st_ya - 1.2)])
    linear_extrude(st_yb - st_ya - 1.2) polygon([[wall - 0.01, 4.6], [2.5, 5.5], [2.5, 5.9], [wall - 0.01, 6.8]]);
}
module st_block() translate([0, st_y(st_ya, 5.7) - 1, 0]) rotate([90, 0, 0]) translate([0, 0, -(st_yb - st_ya + 2)])
  linear_extrude(st_yb - st_ya + 2)
    polygon([[3.6, wall - 0.01], [5.6, wall - 0.01], [5.6, 8.6], [2.5, 8.6], [1.8, 7.9], [1.8, 6.7], [3.6, 4.9]]);

// ---------- front cover plate (2026-10-15) ----------
// 1 mm plate glued to the front of the bezel, printed front down (PEI texture).
// Face flush with the front edge of the roof (w = -bt - 1), at the bottom goes down to the bed and covers the plinth.
nk_t   = 1.0;            // thickness
nk_top = Hs - rs + 0.6;  // top: 0.3 below the roof lip (the roof slides up, doesn't catch)
nk_ch  = 0.6;            // 45° window chamfer from the front
// v8 (mac 2026-10-26): window only over the active TFT image, the plate masks the edges of the bezel opening.
// ST7735 1.8": active area 28.03 x 35.04, offset from the glass centre away from the ribbon (y>0).
nk_win = [29.4, 36.4];   // active area + approx. 0.7 mm on each side
nk_off = [0, 2.3];       // window offset relative to the bezel window centre
module nakladka() difference() {
  intersection() {
    ext() polygon([fp(nk_top, -bt - nk_t), fp(nk_top, -bt), fp(0.02, -bt), [fp(0, -bt)[0], 0],
                   fp(zv(0, -bt - nk_t), -bt - nk_t)]);
    translate([-1, -20, 0]) cube([W + 2, 40, 100]);
  }
  face() translate([fr_c[0] + nk_off[0], fr_c[1] + nk_off[1], -bt - nk_t]) {
    translate([-nk_win[0] / 2, -nk_win[1] / 2, -1]) cube([nk_win[0], nk_win[1], nk_t + 2]);
    hull() {
      translate([-nk_win[0] / 2 - nk_ch, -nk_win[1] / 2 - nk_ch, -1]) cube([nk_win[0] + 2 * nk_ch, nk_win[1] + 2 * nk_ch, 1]);
      translate([-nk_win[0] / 2, -nk_win[1] / 2, nk_ch - 0.01]) cube([nk_win[0], nk_win[1], 0.01]);
    }
  }
}
// for printing: face on the bed
module nk_print() translate([0, 0, bt + nk_t])
  multmatrix([[1, 0, 0, 0], [0, sin(tilt), cos(tilt), -P1[0] * sin(tilt) - P1[1] * cos(tilt)],
              [0, cos(tilt), -sin(tilt), -P1[0] * cos(tilt) + P1[1] * sin(tilt)]]) nakladka();
