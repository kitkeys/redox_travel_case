keys_height = 15.6;
keebcase_height = 18.4;
ipad_height = 10;

module outer_case(height) {
    corner_rad=18;
    bottom_rad=4;
    translate([corner_rad, corner_rad+bottom_rad, bottom_rad]) {
        minkowski() {
            minkowski() {
                cube([
                    196-2 * corner_rad-1,
                    150-2 * corner_rad - (2 * bottom_rad),
                    height - (2 * bottom_rad) - 1,
                 ]);
                cylinder(r=corner_rad,h=1,$fn=300);
            }
            rotate([0,90,0])cylinder(r=bottom_rad,h=1,$fn=100);
        }
    }

    //add corners back on two sides of minkowski
    cube([corner_rad, corner_rad, height]);
    cube([196, corner_rad, height]);
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
    main_x = 151.75;
    main_y = 118;
    // %translate([0, 1, 0])
    //      cube([154, 120, height]);
    translate([0, 3, 0])
        cube([main_x, main_y, height]);

    // leg_len = 51; // 50mm actual
    // leg_width = 15;

    rad = 4;
    round_corner_offset = 2 * rad;
    thumb_module_y = 67;  // orig 67
    thumb_module_x = 60;  // orig 60

    {
        // leg cutouts
        top = main_y - leg_len + 3;
        {
            translate([-(leg_width - grace), top, 0])
                leg_cutout(height);
            translate([main_x - grace, top - (10 - 0.75), 0])
                leg_cutout(height);
            translate([main_x - grace, 3 + 4, 0])
                leg_cutout(height);
        }
    }

    rotate([0, 0, 30]) {
        translate([-(rad + 0.75), -(15.5), 0]) {
            // thumb cluster
            minkowski() {
                cube([
                    thumb_module_x - round_corner_offset,
                    62 - round_corner_offset,
                    height,
                ]);
                cylinder(r=rad,h=1);
            }

            // leg cutout
            translate([-(rad + leg_width - grace), 0, 0])
                leg_cutout(height);
        }
    }
}

module finger_hole(height, depth = 18) {
    finger_hole_rad=14;
    finger_hole_cutout_overhang=6;

    translate([0,0,finger_hole_rad])
        rotate([0, 90, 0])
            cylinder(r=finger_hole_rad, h=depth, $fn=100);
    translate([0,-finger_hole_rad-finger_hole_cutout_overhang,finger_hole_rad])
        cube([depth, finger_hole_rad*2+finger_hole_cutout_overhang*2, keys_height+keebcase_height-finger_hole_rad+1]);
}

module receiver(height) {
    cube([57+2, 38+2, height]);
    translate([-17,14,0]) finger_hole(height);
}

module ipad(height) {
    len = 247.6 / 2 + 8; // only half ipad per case
    wid = 178.5 + 8;
    cube([wid, len, height]);
}

module keys(height) {
    // top right
    translate([30,  127, 0]) cube([15,20,height]);
    translate([45,  137, 0]) cylinder(r=10,h=height, $fn=100);

    // top left
    difference() {
        union() {
            // % translate([155, 134, 0]) cube([30,13,height]);
            translate([155, 134, 0]) cube([27.1, 13, height]);
            translate([155, 141, 0]) cylinder(r=7, h=height, $fn=100);
        }

        translate([145, 134 + 13, -1]) cube([40, 13, height + 10]);
    }

    // bottom middle
    translate([99, 27, 0]) cylinder(r=11,h=height, $fn=100);
    translate([99, 27, 0]) cube([8,11,height]);
    translate([107, 27, 0]) cylinder(r=11,h=height, $fn=100);

    // bottom left
    translate([175, 27, 0]) cube([10,17,height]);
    translate([181, 44, 0]) cylinder(r=6,h=height, $fn=100);

    // middle right nub
    translate([27,  74, 0]) cube([7,4,height]);
    translate([34,  76, 0]) cylinder(r=2,h=height, $fn=100);
}

difference() {
    outer_case(height=keys_height+keebcase_height+ipad_height);

    translate([30, 26, -1]) keeb(height=keys_height + keebcase_height + ipad_height + 2);
    translate([5, 98, keys_height]) finger_hole(keebcase_height + ipad_height, 26);
    translate([90, -19, keys_height]) receiver(keebcase_height + ipad_height + 1);

    translate([5, 0, keys_height + keebcase_height]) ipad(ipad_height + 1);
}

keys(height=keys_height);
