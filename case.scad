$fn = 50;

battery_width = 95.8;
battery_height = 76.0;
battery_length = 39.0;

padding_thickness = 3;

thickness = 2;

case_width = battery_width + padding_thickness*2 + thickness;
case_length = battery_length + padding_thickness*2 + thickness;
case_height = battery_height + padding_thickness*2 + thickness;

bolt_height = 24;
bolt_diameter = 3;
rounding_radius = 6;
washer_diameter = 10;
nut_radius = 2;
nut_width = 2;

bms_width = 20;
bms_length = 15;
bms_height = 5;

wire_diameter = 2;
wire_hole_diameter = wire_diameter * 1.1;

vent_cylinder_diameter = 5;
vent_width = vent_cylinder_diameter;
vent_length = battery_width - thickness*4;


cylinder_height = bolt_height/2*1.5;
bolt_cut_radius = washer_diameter/2;
bolt_cut_replacement_radius = bolt_cut_radius + thickness;
bolt_holder_thickness = thickness*1.5;
/*
Metionable edits:
- created nuts/bolts if statement
- reduced padding thickness from 6.5 -> 3
- made bolt holders 50% thicker, to allow for nut holes


*/


/*
To do list:
Reasonable bolt hole postion
Add curve in bolt holder
Add vents
Increase bolt cut size 12+
Add cutout for power cable
-Hexagonal bolt holders
-Bolt side extra room + cable holder


*/

module build_four(x, y, z) {
        translate([0, 0, z]) {
            translate([x, y, 0]) {
            children();
            }
            translate([-x, y, 0]) {
                children();
            }
            translate([x, -y, 0]) {
                children();
            }
            translate([-x, -y, 0]) {
                children();
            }      
        }
}

module battery() {
    cube([battery_width, battery_length, battery_height], center = true);
    
}

module bolt_cut() {
    cylinder(cylinder_height, r = bolt_cut_radius);
}    

module bolt_cuts() {   
    build_four(case_width/2 - bolt_cut_radius + thickness, case_length/2 - bolt_cut_radius + thickness, -cylinder_height){
        bolt_cut();
    }
}

module bolt_cut_replacement() {
    cylinder(case_height / 2, r = bolt_cut_replacement_radius);
}

module bolt_cut_replacements(){
    build_four(case_width/2 - bolt_cut_radius + thickness, case_length/2 - bolt_cut_radius + thickness, -case_height/2){
        bolt_cut_replacement();
    }
}

module case_shape(width, length, height) {
    minkowski() {
        cube([width - rounding_radius*2, 
              length - rounding_radius*2, 
              height - rounding_radius*2],
              center = true);
        sphere(rounding_radius);
    }
}

module bolt_holder() {
    cylinder(bolt_holder_thickness, r = bolt_cut_replacement_radius);
}

module bolt_holders() {
    build_four(case_width/2 - bolt_cut_radius + thickness, case_length/2 - bolt_cut_radius + thickness, -bolt_holder_thickness) {
        bolt_holder();
    }
    
}

module bolt_hole() {
    cylinder(thickness, d = bolt_diameter);
}

module bolt_holes() {
    build_four(case_width/2 - bolt_cut_replacement_radius / 2,           case_length/2 - bolt_cut_replacement_radius / 2, 
               -thickness) {
                   bolt_hole();
               } 
}
module case() {
    difference() {
        bolt_holders();
        bolt_holes();
    }
    difference() {
        bolt_cut_replacements();
        bolt_cuts();
    }
    difference() {
        case_shape(case_width, case_length, case_height);
        case_shape(case_width - thickness*2, 
                   case_length - thickness*2, 
                   case_height - thickness*2);
        bolt_cuts();
    }
}


module half_case() {
    delete_cube_side = battery_width*2;
    
    difference() {
        case();
        translate([-delete_cube_side / 2, -delete_cube_side / 2, 0]) {
            cube(delete_cube_side);
        }
    }
}

module case_external() {
    difference(){
        case_shape(case_width + thickness*5, case_length + thickness*5, case_height + thickness*5);
        case_shape(case_width, case_length, case_height);
    }
}

module case_cleaned() {
    difference() {
        half_case();
        case_external();
    }
}

//case_cleaned();


module case_style(style){
    if (style == "bolt") {
        case_cleaned();
    }
    else if (style == "nut"){
        translate([0, case_width, 0])
        case_cleaned();
    }
    else {
        sphere(r = 10);
    }
}
case_style("nut");
case_style("bolt");
//case_style("pizza");