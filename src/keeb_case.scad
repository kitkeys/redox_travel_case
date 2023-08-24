keys_height = 15.6;
keebcase_height = 18.4;
ipad_height = 10;

bottom_rad = 4;
corner_rad = 18;

module outer_case(height) {
    corner_circumference = corner_rad * 2;
    bottom_circumference = bottom_rad * 2;
    exterior_x = 196;
    exterior_y = 150;

    difference() {
        hull() {
            translate([corner_rad, corner_rad + bottom_rad, bottom_rad]) {
                minkowski() {
                    minkowski() {
                        cube([
                            exterior_x - corner_circumference - 1,
                            exterior_y - corner_circumference - bottom_circumference,
                            height - bottom_circumference - 1,
                        ]);
                        cylinder(r=corner_rad, h=1, $fn=300);
                    }
                    rotate([0, 90, 0])
                        cylinder(r=bottom_rad, h=1, $fn=100);
                }
            }
            // add corners back on two sides of minkowski
            cube([exterior_x, corner_rad, height]);
        }

        // cutout for magnetic usb
        usb_x = 15;
        translate([(exterior_x / 2) - (usb_x / 2) + 5.5, exterior_y - corner_rad, keys_height])
            cube([usb_x, 30, height]);
    }
}

leg_len = 51; // 50mm actual
leg_width = 15;

module leg_cutout(height) {
    offset = keys_height + 1;
    translate([0, 0, offset])
        cube([leg_width, leg_len, height - offset]);
}

module keeb(height) {
    grace = 0.15;
    // actual 151 x 118
    main_x = 153.75;
    main_y = 120;
    main_r = 7.5;
    main_circ = main_r * 2;
    translate([main_r - 1, main_r + 1, 0])
    minkowski() {
        cube([main_x - main_circ, main_y - main_circ, height]);
        cylinder(h = height, r = main_r);
    }

    rad = 4;
    round_corner_offset = 2 * rad;
    thumb_module_y = 62;  // orig 67
    thumb_module_x = 60;  // orig 60

    // leg cutouts
    top = main_y - leg_len + 3;
    // top left
    translate([-(leg_width + 1 - grace), top - 22 - 2, 0])
        leg_cutout(height);
    // top right
    translate([main_x - 1 - grace, top - (10 - 0.75) - 2, 0])
        leg_cutout(height);
    // bottom right
    translate([main_x - 1 - grace, 3 + 4, 0])
        leg_cutout(height);

    rotate([0, 0, 30]) {
        translate([-(rad + 0.75), -(15.5), 0]) {
            // thumb cluster
            minkowski() {
                cube([
                    thumb_module_x - round_corner_offset,
                    thumb_module_y - round_corner_offset,
                    height,
                ]);
                cylinder(r=rad, h=1, $fn=40);
            }

            // leg cutout
            translate([-(rad + leg_width - grace), 0, 0])
                leg_cutout(height);
        }
    }
}

module finger_hole(height, depth = 18) {
    finger_hole_rad = 14;
    finger_hole_circumference = finger_hole_rad * 2;
    finger_hole_cutout_overhang = 6;

    translate([0, 0, finger_hole_rad])
        rotate([0, 90, 0])
            cylinder(r=finger_hole_rad, h=depth, $fn=100);
    translate([0, -finger_hole_rad - finger_hole_cutout_overhang, finger_hole_rad])
        cube([
            depth,
            finger_hole_circumference + finger_hole_cutout_overhang * 2,
            keys_height + keebcase_height - finger_hole_rad + 1,
        ]);
}

module receiver(height) {
    x = 57;
    y = 38;
    padding = 2;
    cube([x + padding, y + padding, height]);
    translate([-17, 14, 0])
        finger_hole(height);
}

module ipad(height) {
    len = 247.6 / 2 + 9; // only half ipad per case
    wid = 178.5 + 8;
    cube([wid, len, height]);
}

module keys(height) {
    // top left
    hull() {
        translate([28, 127, 0])
            cube([18, 20, height]);
        translate([45, 137, 0])
            cylinder(r=10, h=height, $fn=100);
    }

    // top right
    // FIXME: rather kludgey
    hull() {
        translate([155, 135 + bottom_rad, bottom_rad]) {
            x = 28.1;
            minkowski() {
                cube([x - 1, 14 - bottom_rad * 2, height - bottom_rad * 2]);
                rotate([0, 90, 0])
                    cylinder(r=bottom_rad, h=1, $fn=100);
            }

            translate([0, -bottom_rad - 1,-bottom_rad]) {
                cube([x, 11,  height]);
            }
        }

        translate([155, 141, 0])
            cylinder(r=6, h=height, $fn=100);
    }

    // bottom middle
    hull() {
        translate([99, 27, 0])
            cylinder(r=11, h=height, $fn=100);
        translate([107, 27, 0])
            cylinder(r=11, h=height, $fn=100);
    }

    // bottom right
    hull() {
        r = 6;
        translate([175, 27, 0])
            cube([r * 2, 17, height]);
        translate([181, 44, 0])
            cylinder(r=r, h=height, $fn=100);
    }

    // middle left
    hull() {
        translate([27, 74, 0])
            cube([7, 4, height]);
        translate([34, 76, 0])
            cylinder(r=2, h=height, $fn=100);
    }
}

module diamond_row(n = 1, size = 8, scale = 1) {
    for (i = [0 : n - 1]) {
        translate([(size + 4) * i, 0, 0])
            rotate([0, 0, 45])
                cube([size, size, scale]);
    }
}

case_height = keys_height + keebcase_height + ipad_height;

difference() {
    outer_case(height = case_height);
    translate([30, 26, -1])
        keeb(height = case_height + 2);
    translate([5, 98, keys_height])
        finger_hole(keebcase_height + ipad_height, 26);
    translate([90, -19, keys_height])
        receiver(keebcase_height + ipad_height + 1);
    // extra pocket
    translate([154, -1, -.15])
        cube([(196 - 158.5), 20, case_height + 1]);
    translate([5, -1, keys_height + keebcase_height])
        ipad(ipad_height + 1);

    // material reduction
    diamond_scale = 15;
    translate([90 + (8 * 4) / 3, 32, keys_height + 4])
        rotate([90, 0, 0])
            diamond_row(n = 4, scale = diamond_scale);
    translate([153 + (8 * 3) / 3, 32, keys_height + 4])
        rotate([90, 0, 0])
            diamond_row(n = 3, scale = diamond_scale);

    top_left_x = 39;
    translate([top_left_x, 155, keys_height + 4])
        rotate([90, 0, 0])
            diamond_row(n = 4, scale = diamond_scale);
    translate([top_left_x + 6, 155, keys_height + 4 + 8])
        rotate([90, 0, 0])
            diamond_row(n = 4, scale = diamond_scale);

    top_right_n = 5;
    top_right_x = 118;
    translate([top_right_x, 155, keys_height + 4])
        rotate([90, 0, 0])
            diamond_row(n = top_right_n, scale = diamond_scale);
    translate([top_right_x + 6, 155, keys_height + 4 + 8])
        rotate([90, 0, 0])
            diamond_row(n = top_right_n, scale = diamond_scale);
}

keys(height = keys_height);
