$fn = 20;

fiddle = 3;

battery_width = 95.8;
battery_height = 76.0;
battery_length = 39.0;

padding_thickness = 3;

thickness = 2;

//external_case_width = battery_width + padding_thickness*2 + thickness*2;
//external_case_length = battery_length + padding_thickness*2 + thickness*2;


bolt_height = 22;
bolt_diameter = 3.5;
rounding_radius = 6;
washer_diameter = 8;
//^measured as 10
nut_radius = 4;
nut_width = 5;


cylinder_height = bolt_height;
bolt_cut_radius = washer_diameter/2;
bolt_cut_replacement_radius = bolt_cut_radius + thickness;
bolt_holder_thickness = thickness*1.5;


external_case_width = battery_width + thickness * 2 + (bolt_cut_radius + thickness*2) * 2^(1/2);
external_case_length = battery_length + thickness * 2 + 2^(1/2) * (bolt_cut_radius + thickness*2);

//
complete_case_height = battery_height + padding_thickness*2 + thickness;


bms_width = 20;
bms_length = 15;
bms_height = 5;

wire_diameter = 2;
wire_hole_diameter = wire_diameter * 1.1;

vent_cylinder_diameter = 2;
vent_width = vent_cylinder_diameter;
vent_length = battery_width *1/4;
vent_spacing = battery_length /8;
vent_height = 20;


/*
Metionable edits:
- created nuts/bolts if statement
- reduced padding thickness from 6.5 -> 3
- made bolt holders 50% thicker, to allow for nut holes
- added vents, moved vents
- changed case_height from a global varible to a specific varible
- changed how the case size is calculated

*/


/*

Reasonable bolt hole postion
Add curve in bolt holder
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
//#battery();

module bolt_cut() {
    //$fn = 6;
    //cylinder(cylinder_height , r = bolt_cut_radius);
    cylinder(cylinder_height, r = nut_radius, center = true);
    
}    


module bolt_cut_replacement(case_height) {
    cylinder(case_height / 2, r = bolt_cut_replacement_radius, center = true);
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
    cylinder(bolt_holder_thickness, r = bolt_cut_replacement_radius, center = true);
}


module bolt_hole() {
    
    cylinder(bolt_holder_thickness * fiddle, d = bolt_diameter, center = true);
}


module vent(){
    
    hull() {
        translate([vent_length/2, 0, 0]){
            cylinder(h = thickness*2, d = vent_width, center = true);
        }
    
        translate([-vent_length/2, 0, 0]){
            cylinder(h = thickness*2, d = vent_width, center = true);
        }
        
    }
    
}

module vents(){
    translate([-vent_length*1, -vent_spacing*3.25, -vent_height]){
        for (y_postion=[0:3]){
            translate([0,y_postion*vent_spacing,0]){
                vent();
            }
        }
    }
}
module build_corner(h){
    difference(){
        bolt_cut_replacement(h);
        bolt_cut();
    }
    
    translate([0,0,h/4 - bolt_holder_thickness /2]){
        difference(){
            bolt_holder();
            bolt_hole();
        }
    } 
    //if (style == "main") {}
}


module build_corners(h){
    corner_shift = thickness * 3;
    
    
    build_four(external_case_width/2 - corner_shift, external_case_length/2 - corner_shift, -h/4){
        translate([0,0,0]) build_corner(h);
        
    }
}
    
module case(case_height) {
    /*difference() {
        bolt_holders();
        bolt_holes();
    }
    difference() {
        bolt_cut_replacements(case_height);
        bolt_cuts();
    }*/
    difference() {
        case_shape(external_case_width, external_case_length, case_height);
        case_shape(external_case_width - thickness*2, 
                   external_case_length - thickness*2, 
                   case_height - thickness*2);
        vents();
        
        build_four(external_case_width/2 - thickness*2, external_case_length/2 - thickness*2, -case_height/4){
            bolt_cut_replacement(case_height);
            
        }
        
    }
    
    build_corners(case_height);
        
}

module half_case(case_height) {
    delete_cube_side = battery_width*2;
    
    difference() {
        case(case_height);
        translate([-delete_cube_side/2, -delete_cube_side / 2, 0]) {
            cube(delete_cube_side);
        }
    }
}

module case_external(case_height) {
    difference(){
        case_shape(external_case_width + thickness*5, external_case_length + thickness*5, case_height + thickness*5);
        case_shape(external_case_width, external_case_length, case_height);
    }
}



module case_cleaned(case_height) {
    difference() {
        half_case(case_height);
        case_external(case_height);
    }
}
//Done


module hexagon(x, y, z)
{
    //$fn = 6;
    cylinder(nut_width, r = nut_radius, center = true);
}


module hexagons(){
    build_four(external_case_width/2 - bolt_cut_replacement_radius / 2,           external_case_length/2 - bolt_cut_replacement_radius / 2, 
               -thickness*2) {
                   hexagon();
               } 
}

module styled_case(style){
    if (style == "main") {
        case_height = complete_case_height * 2/3;  
        
        difference(){
            case_cleaned(case_height);
            //hexagons();
        }
    }
    else if (style == "lid"){
        case_height = complete_case_height * 1/3;
        translate([0, external_case_width, 0])
        case_cleaned(case_height);
        
        /*
        Stuff to add:
        - wire cable hole
        - switch cutout
        - form fit for BMS
        
        */
        
    }
    else {
        case_height = complete_case_height * 1/2;
        case_cleaned(case_height);
    }
    
}
//Done


styled_case("main");
styled_case("lid");
//styled_case("pizza");


