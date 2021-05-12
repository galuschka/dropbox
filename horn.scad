// copyright Holger Galuschka

module horn() {
    difference() {
        union() {
            translate([0,56])
                union() {
                    difference() {
                        intersection() {
                            circle(110);
                            polygon([[0,0],[-111,-50],[-111,-111],[0,-111]]);
                        }
                        translate([-3,0])
                            circle(100);
                        translate([0,-57])
                            circle(50.5);
                        translate([0,-11])
                            rotate(-72)
                                translate([0,-102,0])
                                    offset(r=3.25)
                                        square([1,9], center=true);
                    }
                    difference() {
                        intersection() {
                            circle(110);
                            polygon([[0,0],[111,-40],[111,-111],[0,-111]]);
                        }
                        translate([-10,-10])
                            circle(95);
                        translate([0,-57])
                            circle(50.5);
                        translate([0,-11])
                            rotate(66)
                                translate([0,-95,0])
                                    offset(r=4)
                                        square([1,23], center=true);
                    }
                }
            circle(50);
        }
        circle(40);
        for (i = [-1,+1]) {
            rotate(18*i)
                translate([0,-47,0])
                    square([18,20], center=true);
        }
    }

    for (i = [-1,+1]) {
        rotate(18*i)
            for (j = [0:3]) {
                translate([4*j-6,-47,0])
                offset(r=1)
                    square([1,20], center=true);
            }
    }

    translate([0,45])
        rotate(66)
            translate([0,-95,0])
                union() {
                    offset(r=3)
                        square([1,23], center=true);
                    translate([12,0])
                        difference() {
                            square([15,40], center=true);
                            translate([-8,-25])
                                circle(16);
                            translate([-8,+25])
                                circle(15);
                    };
                    polygon([[21,-21],[24,-19],[24,19],[21,21]]);
                }

    translate([0,45])
        rotate(-72)
            translate([0,-102,0])
                union() {
                    offset(r=2)
                        square([1,9], center=true);
                    translate([-9,0])
                        difference() {
                            square([10,20], center=true);
                            translate([4,-14])
                                circle(10);
                            translate([4,+14])
                                circle(10);
                    };
                    polygon([[-15,10],[-17,9],[-17,-9],[-15,-10]]);
                }

    for (i = [-1,+1]) {
        rotate(9*i)
            translate([0,-60]) {
                circle(2);
                offset(r=1)
                    polygon([[-2*i,-4.25],[1*i,-4.25],[6*i,-15],[4*i,-17],[1*i,-15],[-3*i,-15]]);
            }
    }
}
