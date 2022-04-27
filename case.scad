//CASE VERSION 3

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
bolt_diameter = 4.5;
//rounding_radius = 6;
rounding_radius = 8;

washer_diameter = 8;
//^measured as 10
nut_radius = 4.5;
nut_width = 5;


cylinder_height = bolt_height;
bolt_cut_radius = washer_diameter/2;
bolt_cut_replacement_radius = rounding_radius;
//^ bolt_cut_replacement_radius = bolt_cut_radius + thickness;

bolt_holder_thickness = thickness*1.5;


external_case_width = battery_width + thickness * 2 + (bolt_cut_replacement_radius*2) * 2^(1/2);
external_case_length = battery_length + thickness * 2 + 2^(1/2) * (bolt_cut_replacement_radius*2);

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

corner_shift = rounding_radius;


/* Stuff to do:
- Change battery height
- Spilt halves

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

module bolt_cut(h, style) {
    //$fn = 6;
    //cylinder(cylinder_height , r = bolt_cut_radius);
    if (style == "main") {
        $fn = 6;
        cylinder(h/2, r = nut_radius, center = true);
    }
    else if (style == "lid"){
        
        cylinder(h/2, r = washer_diameter/2, center = true);
    }
    else {
        cylinder(h/2, r = nut_radius, center = true);
    }
}    


module bolt_cut_replacement(h) {
    cylinder(h / 2, r = bolt_cut_replacement_radius, center = true);
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

module vents(case_height){
    translate([-vent_length*1, -vent_spacing*3.25, -case_height/2 +thickness]){
        for (y_postion=[0:3]){
            translate([0,y_postion*vent_spacing,0]){
                vent();
            }
        }
    }
}


module hole_vents(case_height){
    hole_radius = 2;
    hole_spacing = hole_radius * 3; 
    translate([0, 0, - case_height/2 + 0.5*thickness]){
        for (y_postion = [0 : hole_spacing : 4 * hole_spacing]){
            for (x_postion = [0 : hole_spacing : 4 * hole_spacing]){
                translate([x_postion, y_postion, 0]){
                    cylinder(thickness * fiddle/2, r = hole_radius, center = true);
                
                }   
            }
        }
    } 
}


module build_corner(h, style){
    if (style == "main") {
        difference(){
            bolt_cut_replacement(h);
            union(){
                bolt_cut(h, style);
                
            }
            
        }
    }
    else if (style == "lid"){
         difference(){
            bolt_cut_replacement(h);
            bolt_cut(h, style);
        }
        
    }
    else {
        difference(){
            bolt_cut_replacement(h);
            bolt_cut(h, style);
        }
        
    }
     
    translate([0,0,h/4 - bolt_holder_thickness /2]){
        difference(){
            bolt_holder();
            bolt_hole();
        }
    } 
    //if (style == "main") {}
}


module build_corners(h, style){
    build_four(external_case_width/2 - corner_shift, external_case_length/2 - corner_shift, -h/4){
        translate([0,0,0]) build_corner(h, style);
        
    }
}
    
module case(case_height, style) {
    /*difference() {
        bolt_holders();
        bolt_holes();
    }
    difference() {
        bolt_cut_replacements(case_height);
        bolt_cuts(case_height);
    }*/
    difference() {
        case_shape(external_case_width, external_case_length, case_height);
        case_shape(external_case_width - thickness*2, 
                   external_case_length - thickness*2, 
                   case_height - thickness*2);
        if (style == "lid"){
            //vents(case_height); 
            
            //kludge, fix
            translate([0,-5,0]){
                hole_vents(case_height);
                
            }
        }
        build_four(external_case_width/2 - corner_shift, external_case_length/2 - corner_shift, -case_height/4){
            bolt_cut_replacement(case_height);
            
        }
        
    }
    
    
    
    build_corners(case_height, style);
        
}

module half_case(case_height, style) {
    delete_cube_side = battery_width*2;
    
    difference() {
        case(case_height, style);
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



module case_cleaned(case_height, style) {
    difference() {
        half_case(case_height, style);
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
            case_cleaned(case_height, style);
            //hexagons();
        }
    }
    else if (style == "lid"){
        case_height = complete_case_height * 1/3;
        translate([0, external_case_width/1.6, -complete_case_height * 1/6])
        case_cleaned(case_height, style);
        
        /*
        Stuff to add:
        - wire cable hole
        - switch cutout
        - form fit for BMS
        
        */
        
    }
    else {
        case_height = complete_case_height * 1/2;
        case_cleaned(case_height, style);
    }
    
}
//Done
difference(){
    translate([0, 0, complete_case_height/3]){
        styled_case("main");
    //styled_case("lid");
        
    }
    rotate([0,0,45]) translate([30,0,0]) cube(140, center = true);
}

//styled_case("pizza");

