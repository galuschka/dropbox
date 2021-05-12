// copyright Holger Galuschka

include <getriebe/Getriebe.scad>;
include <horn.scad>;

adresse1 = "Holger Galuschka";
adresse2 = "Gelsenkircher Str. 25";
adresse3 = "13583 Berlin";

a_font = "Arial";
b_font = "URW Bookman";

dicke     =   3; // Rotunden
achse_r   =   2; // Achsen
klappe_b  = 100; // Breite ohne offset
klappe_t  =  10; // Tiefe (Dicke)
klappe_h  = 120; // Hoehe
klappe_o  =  40; // offset nach links
k_achse_o =  20; // Achs-Offset
k_achse_h = klappe_h + 2*k_achse_o;
riegel    =  40; // Viertelkreis (aussen)
box_t     = 200; // Tiefe
box_h     = 200; // Hoehe der "0-Ebene" (Unterkante der Klappe)

// $vpr = [70 + (40 * $t), 0, -$t * 270];

// Animation: Gewichtung der Phasen:
weight = [ 1, 4,  // pause, unlock
           1, 4,  // pause, open
           3, 4,  // fade-in, insert
           1, 3,  // pause, close
           2, 3,  // drop1, drop2
           1, 4,  // pause, rev-open,
           1, 4,  // fade-out, rev-close
           1      // pause
];
function sum(list, c = 0) =
    c < len(list) - 1
        ? list[c] + sum(list, c + 1)
        : (c >= len(list) ? 0 : list[c]);

total = sum(weight);
// echo(total);

// s_/e_/d_ = start/end/duration
d_unlock = weight[1]/total;
d_open   = weight[3]/total;
d_fadein = weight[4]/total;
d_insert = weight[5]/total;
d_close  = weight[7]/total;
d_drop1  = weight[8]/total;
d_drop2  = weight[9]/total;
d_drop   = d_drop1 + d_drop2;
d_ropen  = weight[11]/total;
d_rclose = weight[13]/total;

s_unlock =              weight[0]/total;
e_unlock = s_unlock + d_unlock;
s_open   = e_unlock +   weight[2]/total;
e_open   = s_open   + d_open;
s_fadein = e_open;
e_fadein = s_fadein + d_fadein;
s_insert = e_fadein;
e_insert = s_insert + d_insert;
s_close  = e_insert +   weight[6]/total;
e_close  = s_close  + d_close;
s_drop   = e_close;
e_drop1  = s_drop   + d_drop1;
e_drop   = s_drop   + d_drop;
s_ropen  = e_drop   +   weight[10]/total;
e_ropen  = s_ropen  + d_ropen;
s_rclose = e_ropen  +   weight[12]/total;
e_rclose = s_rclose + d_rclose;
s_fadeout = e_ropen;
e_fadeout = s_rclose;
d_fadeout = e_fadeout - s_fadeout;

module rotate_about(a, v, p=[0,0,0]) {
     translate(p) rotate(a,v) translate(-p) children();
}

module outline_text(text, size, font = b_font) {
    difference() {
        text(
            text,
            font = font,
            size = size,
            valign = "center",
            halign = "center"
        );
        offset(r = -0.3) {
            text(
                text,
                font = font,
                size = size,
                valign = "center",
                halign = "center", $fn=64
            );
        }
    };
}

module revolve_text(radius, angle, chars, unterschneidung = []) {
    PI = 3.14159;
    circumference = 2 * PI * radius * angle / 360;
    chars_len = len(chars);
    adj = sum(unterschneidung)/2;
    font_size = circumference / chars_len;
    step_angle = angle / chars_len;
    for(i = [0 : chars_len - 1]) {
        rotate(((chars_len - 1) / 2 - i) * step_angle + adj - sum(unterschneidung, i))
            translate([0, radius + font_size / 3, 0])
                linear_extrude(1)
                    outline_text( chars[i], font_size );
    }
}


rotate([0,0,
$t <= s_open || $t >= e_close ? 0 :
($t >= e_open && $t <= s_close ? -90 :
($t <= e_open ? (s_open - $t) / d_open * 90
              : ($t - e_close) / d_open * 90))])
union() {
    color("lightblue")
        union() {
            translate([-klappe_o,-klappe_t/2,0])
                cube([klappe_b+klappe_o,klappe_t,klappe_h]);
            translate([0,0,-k_achse_o])
                cylinder(k_achse_h,achse_r,achse_r);
            // Blockier-Halbkreis
            translate([0,0,0])
                intersection() {
                    cylinder(dicke,klappe_o,klappe_o);
                    translate([-klappe_o,-klappe_o,0])
                        cube([klappe_o*2,klappe_o,dicke]);
                };
            
            // Griff:
            translate([klappe_b-25,-5,klappe_h/2+5]) 
                union() {
                    difference() {
                        intersection() {
                            scale([1,1,2])
                                sphere(10,$fn=90);
                            translate([0,0,-20])
                                rotate(-90)
                                    cube([10,10,40]);
                        };
                        translate([-0.5,0,0])
                        scale([0.9,0.9,0.9])
                        intersection() {
                            scale([1,1,2])
                                sphere(10,$fn=90);
                            translate([0,0,-20])
                                rotate(-90)
                                    cube([10,10,40]);
                        };
                    };
                };
        };
    color("grey")
        translate([klappe_b-15,-klappe_t/2,15])
            rotate([90,0,0])
                linear_extrude(1)
                    outline_text("2", 10);
    color("grey")
        translate([25,-klappe_t/2,klappe_h/2-30])
            rotate([90,0,0])
                revolve_text(50, 100, "PAKETE", [4,-1,-1,3,4] );

    color("grey")
        translate([25,-klappe_t/2,klappe_h/2-10])
            rotate([90,0,0])
                linear_extrude(1)
                    resize([70,40])
                        horn();
};

rotate_about(
    $t >= e_unlock && $t <= s_drop ? 0 :
    ($t <= s_unlock || $t >= e_drop1 ? -90 :
        ($t <= e_unlock ? ($t - e_unlock)/d_unlock * 90
                        : (s_drop - $t)/d_drop1 * 90)),
    [0,1,0],[klappe_b+5,0,-6])
union() {
    // Blockier-Viertelkreis
    translate([klappe_b+1,-((klappe_t/2)+dicke/2),-10])
        union() {
            color("lightgreen")
            rotate([90,180,0])
                intersection() {
                    cylinder(dicke,riegel,riegel);
                    rotate(180)
                        cube([riegel,riegel,dicke]);
                };
            color("grey")
                union() {
                    translate([9,-dicke-0.5,riegel-9])
                        rotate([90,90,0])
                            linear_extrude(1)
                                outline_text("1", 10);
                    translate([riegel-18,-dicke-0.25,5])
                        rotate([90,-45,0])
                            linear_extrude(1)
                                polygon([[0,0],[10,0],[0,10]]);
                    translate([12,-dicke-0.25,12])
                        rotate([90,0,0])
                            linear_extrude(1)
                                intersection() {
                                    difference() {
                                        circle(12);
                                        circle(8);
                                    };
                                    square(12);
                                };
                };
        };
    // Griff
    color("lightgreen")
        union() {
            translate([klappe_b+riegel-5,-6,-6])
                union() {
                    rotate([90,0,0])
                        cylinder(8,achse_r,achse_r);
                    translate([0,-10,0])
                        sphere(5);
                };
            // Achse
            translate([klappe_b+5,-10,-6])
                rotate([270,0,0])
                    cylinder(box_t+40,achse_r,achse_r);
            // Fallklappe
            translate([klappe_b/2-2,klappe_t/2+2,-11])
                cube([klappe_b/2+12,box_t,klappe_t]);

            // zahnrad:
            translate([klappe_b+13-8,box_t+22,-6])
                rotate([90,0,0])
                    stirnrad(3,12,8,achse_r+2);
        };
};

rotate_about(
    $t >= e_unlock && $t <= s_drop ? 0 :
    ($t <= s_unlock || $t >= e_drop1 ? 90 :
        ($t <= e_unlock ? (e_unlock - $t)/d_unlock * 90
                        : ($t - s_drop)/d_drop1 * 90)),
    [0,1,0],[-8,0,-6])
color("cyan")
    union() {
        translate([-8,-10,-6])
            rotate([270,0,0])
                cylinder(box_t+40,achse_r,achse_r);
        translate([-klappe_o,klappe_t/2+2,-11])
            difference() {
                cube([klappe_o+klappe_b/2-3,box_t,klappe_t]);
                translate([-12,dicke,-1])
                    cube([klappe_o,box_t+2-dicke,klappe_t+2]);
                translate([-1,-1,-klappe_t/2+2])
                    cube([2,dicke+2,klappe_t/2+2]);
            };

        // Blockier-Viertelkreis
        translate([-8,+10,-5])
            rotate([90,0,0])
                intersection() {
                    cylinder(dicke,klappe_o-8,klappe_o-8);
                    rotate(180)
                        cube([klappe_o-8,klappe_o-8,dicke]);
                };
        // zahnrad:
        translate([-8,box_t+22,-6])
            rotate([90,15,0])
                stirnrad(3,12,8,achse_r+2);
    };


// zahnraeder dazwischen:
color("yellow")
    union() {
            translate([(klappe_b+13)*2/3-8,box_t+9,-6])
                rotate([270,0,0])
                    cylinder(21,achse_r,achse_r);
            translate([(klappe_b+13)*2/3-8,box_t+22,-6])
                rotate([90,17+($t >= e_unlock && $t <= s_drop ? 0 :
                        ($t <= s_unlock || $t >= e_drop1 ? 90 :
                        ($t <= e_unlock ? (e_unlock - $t)/d_unlock * 90 :
                        ($t - s_drop)/d_drop1 * 90))),0])
                    stirnrad(3,12,8,achse_r+2);
    };

color("orange")
    union() {
        translate([(klappe_b+13)*1/3-8,box_t+9,-6])
            rotate([270,0,0])
                cylinder(21,achse_r,achse_r);
        translate([(klappe_b+13)*1/3-8,box_t+22,-6])
            rotate([90,$t >= e_unlock && $t <= s_drop ? 0 :
                        ($t <= s_unlock || $t >= e_drop1 ? -90 :
                        ($t <= e_unlock ? ($t - e_unlock)/d_unlock * 90 :
                        (s_drop - $t)/d_drop1 * 90)),0])
                stirnrad(3,12,8,achse_r+2);
    };


// Paket:
if (($t > s_fadein) && ($t < e_fadeout))
translate([5,
    $t <= s_insert ? 10 - (box_t + klappe_b + 100) :
    ($t < e_insert ? 10 - ((e_insert - $t)/d_insert * (box_t+klappe_b+100)) : 10),
    $t <= s_drop ? 0
    : ($t < e_drop
        ? pow(($t-s_drop)/(e_drop-s_drop),2) * -(box_h-8)
        : -(box_h-8))])
    union() {
        alpha = ($t > e_fadein) && ($t < s_fadeout) ? 1
              : ($t <= e_fadein ? ($t - s_fadein)/d_fadein
                                : (e_fadeout - $t)/d_fadeout);
        color("khaki",alpha)
            cube([klappe_b-10,box_t-5,klappe_h-5]);
        translate([klappe_b/3,box_t/2,klappe_h-4.99])
            union() {
                color("white",alpha)
                    cube([40,50,0.1]);
                color("black",alpha)
                    translate([15,15,0.1])
                    rotate(90)
                    resize([30,20,0.1])
                    linear_extrude(0.1)
                    union()
                    {
                        translate([0,-10,0]) text(adresse1, font = a_font);
                        translate([0,-25,0]) text(adresse2, font = a_font);
                        translate([0,-40,0]) text(adresse3, font = a_font);
                    };
            };
    };

// innere Bleche:
color("black",0.4)
    difference() {
        union() {
            translate([-klappe_o-2,-5,-2])
                cube([50,10,1]);// Lagerblech vorn
            translate([-klappe_o-1,box_t+10,-28])
                cube([klappe_o+klappe_b+32,1,klappe_h+29]); // Lagerblech hinten

            translate([-klappe_o-1,klappe_o+1,3])
                cube([klappe_o+klappe_t/2+1,1,klappe_h-2]); // Abschlussblech vorn links
            translate([klappe_t/2-1,klappe_o+2,0])
                cube([1,box_t-klappe_o+8,klappe_h+1]);// Fuehrungsblech links
            translate([klappe_b+1,-klappe_t/2+1,0])
                cube([1,klappe_t/2+box_t+9,klappe_h+1]);// Fuehrungsblech rechts
        };
        // Achslager vertikal:
        translate([0,0,-k_achse_o])
            cylinder(k_achse_h,achse_r+1,achse_r+1);

        // Achslager hinten:
        translate([(klappe_b+13)*0/3-8,box_t+9,-6])
            rotate([270,0,0])
                cylinder(21,achse_r+1,achse_r+1);
        translate([(klappe_b+13)*1/3-8,box_t+9,-6])
            rotate([270,0,0])
                cylinder(21,achse_r+1,achse_r+1);
        translate([(klappe_b+13)*2/3-8,box_t+9,-6])
            rotate([270,0,0])
                cylinder(21,achse_r+1,achse_r+1);
        translate([(klappe_b+13)*3/3-8,box_t+9,-6])
            rotate([270,0,0])
                cylinder(21,achse_r+1,achse_r+1);
    };

// Revisionsklappe:
rotate_about(($t <= s_ropen) || ($t >= e_rclose) ? 0
             : (($t >= e_ropen) && ($t <= s_rclose) ? -80
                : ((($t <= e_ropen
                    ? ($t-s_ropen)/d_ropen
                    : (e_rclose-$t)/d_rclose
                    ) * -80))),
            [0,0,1],[klappe_b+29.5,12,0])
    color([0.3,0.6,1],0.4)
        translate([klappe_b+30,+11,11-box_h])
            cube([1,box_t-2,box_h+klappe_h-22]); // rechts

// Kasten mit Revisionsklappenoeffnung und Achslager:
color([0.1,0.7,1],0.2)
    difference() {
        union() {
            translate([-klappe_o-2,-4,-box_h-1])
                cube([klappe_o+klappe_b+32,box_t+30,1]); // boden
            translate([-klappe_o-2,-4,klappe_h+1])
                cube([klappe_o+klappe_b+32,box_t+30,1]); // deckel
            translate([-klappe_o-2,-4,-box_h])
                cube([klappe_o+klappe_b+32,1,box_h-1]); // vorn unten
            translate([klappe_b+1,-4,-1])
                cube([29,1,klappe_h+2]); // vorn rechts
            translate([-klappe_o-2,-4,-box_h])
                cube([1,box_t+30,box_h+klappe_h+2]); // links
            translate([klappe_b+30,-4,-box_h])
                cube([1,box_t+30,box_h+klappe_h+2]); // rechts
            translate([-klappe_o-1,box_t+26,-box_h])
                cube([klappe_o+klappe_b+32,1,box_h+klappe_h+2]); // hinten
        }

        // Revisionsklappenoeffnung:
        translate([klappe_b+29,+10,10-box_h])
            cube([3,box_t+0,box_h+klappe_h-20]); // rechts

        // Achslager vertikal:
        translate([0,0,-k_achse_o])
            cylinder(k_achse_h,achse_r+1,achse_r+1);

        // Achslager vorn:
        translate([(klappe_b+13)*3/3-8,-15,-6])
            rotate([270,0,0])
                cylinder(21,achse_r+1,achse_r+1);
        translate([(klappe_b+13)*0/3-8,-15,-6])
            rotate([270,0,0])
                cylinder(21,achse_r+1,achse_r+1);

        // Achslager hinten:
        translate([(klappe_b+13)*0/3-8,box_t+9,-6])
            rotate([270,0,0])
                cylinder(21,achse_r+1,achse_r+1);
        translate([(klappe_b+13)*1/3-8,box_t+9,-6])
            rotate([270,0,0])
                cylinder(21,achse_r+1,achse_r+1);
        translate([(klappe_b+13)*2/3-8,box_t+9,-6])
            rotate([270,0,0])
                cylinder(21,achse_r+1,achse_r+1);
        translate([(klappe_b+13)*3/3-8,box_t+9,-6])
            rotate([270,0,0])
                cylinder(21,achse_r+1,achse_r+1);
};

// Schaumstoff:
coswave = [ [0,-1],
            [1,cos(195)],
            [2,cos(210)],
            [3,cos(225)],
            [4,cos(240)],
            [5,cos(255)],
            [6,0],
            [7,cos(285)],
            [8,cos(300)],
            [9,cos(315)],
            [10,cos(330)],
            [11,cos(345)],
            [12,1],
            [13,cos(15)],
            [14,cos(30)],
            [15,cos(45)],
            [16,cos(60)],
            [17,cos(75)],
            [18,0],
            [19,cos(105)],
            [20,cos(120)],
            [21,cos(135)],
            [22,cos(150)],
            [23,cos(165)],
            [24,-1] ];

//  (boden: klappe_o+klappe_b+32, box_t+30)
nx = floor((klappe_o+klappe_b+30)/24);
ny = floor((box_t+28)/24);
color("coral")
    translate([-klappe_o+(klappe_o+klappe_b+32-nx*24)/2,
                (box_t+30-ny*24)/2,
                -box_h])
        union() {
            for (x = [0:nx-1])
                for (y = [0:ny-1])
                    translate([x*24,y*24,5])
                        rotate([90,0,0])
                            for (z=[0:72])
                                translate([0,1+cos((z*5)+180),-z/3])
                                    linear_extrude(1/3)
                                        scale([1,1+cos((z*5)+180)])
                                            polygon(coswave);
            cube([nx*24,ny*24,5]);
        };
