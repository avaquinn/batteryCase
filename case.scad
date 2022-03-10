$fn = 50;

battery_width = 95.7;
battery_height = 65.0;
battery_length = 48.0;

padding_thickness = 6.5;

thickness = 3;

module battery() {
    cube([battery_width, battery_length, battery_height], center = true);

}

battery();

module case() {
    case_width = battery_width + padding_thickness*2 + thickness;
    case_length = battery_length + padding_thickness*2 + thickness;
    case_height = battery_height + padding_thickness*2 + thickness;
    rounding_radius = 8;
    
    minkowski() {
        cube([case_width - rounding_radius*2, 
              case_length - rounding_radius*2, 
              case_height - rounding_radius*2],
              center = true);
        sphere(rounding_radius);
    }
}

case();