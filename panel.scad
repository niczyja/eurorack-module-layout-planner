
$fn = 50;

eurorack3UHeight = 128.5;
eurorack1UHeight = 43.2;
eurorackWidth = 5.08;
eurorackHoleEdgeDistance = 3.0;

module Hole(diameter, oval = false) {
    translate([0, 0, -5])
    linear_extrude(10)
    if (oval == true) {
        hull() {
            translate([-1, 0, 0])
            circle(d = diameter);
            translate([1, 0, 0])
            circle(d = diameter);
        }
    } else {
        circle(d = diameter);
    }
}

module Rail(hp, flipped = false) {
    w = eurorackWidth * hp;
    
    color("firebrick", 0.6)
    rotate([90, 0, flipped ? 90 : -90])
    translate([-5, -15.5, -w / 2])
    linear_extrude(w)
    polygon([
        [0,0], [7.5,0], [7.5,8.7], [10,8.7], [10,19],
        [8.4,19], [8.4,15.35], [0,15.35], [0,0]
    ]);
}

module Knob(s = 1.0, c = "forestgreen") {
    scale([s, s, s]) {
        color(c, 0.9)
        cylinder(h = 21, d1 = 13, d2 = 12);
        
        translate([0, 4, 14])
        color("white", 1.0)
        cube([1, 5, 15], center = true);
    }
}

module EurorackModule(name, hp = 6, u = 3, th = 2, holes = [], comps = [], knobs = []) {
    
    // panel dimensions
    w = eurorackWidth * hp;
    h = u == 1 ? eurorack1UHeight : eurorack3UHeight;
    c = w / 2;
    
    // rails obstruction
    translate([0, -h / 2 + eurorackHoleEdgeDistance, -th / 2])
    Rail(hp = hp + 2, flipped = false);
    
    translate([0, h / 2 - eurorackHoleEdgeDistance, -th / 2])
    Rail(hp = hp + 2, flipped = true);

    // module name
    if (len(name) > 0) {
        color("gray", 0.9)
        translate([0, h / 2 - 6, th / 2])
        linear_extrude(0.1)
        text(name, size = 3, font = "Liberation Sans", halign = "center");
    }

    difference() {
        
        // panel plate
        color("black", 0.9)
        cube([w, h, th], center = true);
        
        // mounting holes
        union() {
            isOval = hp > 2;
            hDist = hp == 1 ? 0 : -c + 7.5;
            vDist = eurorackHoleEdgeDistance;
            
            translate([hDist, h / 2 - vDist, 0])
            Hole(diameter = 3.2, oval = isOval);
            
            translate([hDist, -h / 2 + vDist, 0])
            Hole(diameter = 3.2, oval = isOval);
            
            if (hp > 7) {
                hMod = eurorackWidth * (hp - 3);
    
                translate([hDist + hMod, h / 2 - vDist, 0])
                Hole(diameter = 3.2, oval = isOval);
                
                translate([hDist + hMod, -h / 2 + vDist, 0])
                Hole(diameter = 3.2, oval = isOval);
            }
        }
        
        // component holes
        union() {
            rows = len(holes);
            for(row = [0 : rows - 1]) {
                cols = len(holes[row]);
                for(col = [0 : cols - 1]) {
                    xPos = (w / (cols + 1)) * (col + 1);
                    yPos = (h / (rows + 1)) * (row + 1);
                    
                    translate([-w / 2, h / 2, 0])
                    translate([xPos, -yPos, 0])
                    Hole(holes[row][col]);
                }
            }
        }
    }
    
    // knobs
    rows = len(knobs);
    for(row = [0 : rows - 1]) {
        cols = len(knobs[row]);
        for(col = [0 : cols - 1]) {
            xPos = (w / (cols + 1)) * (col + 1);
            yPos = (h / (rows + 1)) * (row + 1);
            
            translate([-w / 2, h / 2, 0])
            translate([xPos, -yPos, 0])
            Knob(s = knobs[row][col]);
        }
    }
}