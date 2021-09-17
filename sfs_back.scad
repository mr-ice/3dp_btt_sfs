// BTT Smart Filament Sensor Back Cover
// specs from https://github.com/bigtreetech/smart-filament-detection-module/blob/master/manual/smart%20filament%20sensor%20module%20manual201125.pdf
// modified and modeled in OpenSCAD by me


btt_length = 75.00;     // length of the back (from specs)
btt_width = 30.00;      // width of the back (from specs)
btt_back_depth = 4.50;  // overall depth of the back (observed)

m3_head_diam = 6.1;     // space for the m3 head to fit loosely
m3_head_height = 1.55;  // thickness of the cover under the head
m3_hole_diam = 3.25;    // space for the m3 shaft and threads to pass

shell_wall_thickness = 2.0;

// btt m3 hole setup from https://github.com/bigtreetech/smart-filament-detection-module/blob/master/manual/smart%20filament%20sensor%20module%20manual201125.pdf
//
// top  A  B       C  bottom
//      D  E       F
//
AC = 57.75; // by observation, 56.75 by spec
AD = 20.35; // by spec and observation
AB = 13.99; // by spec and observation

TA = (btt_length - AC)/2; // top to A, A and C equidistant from ends

$fn = 100;

use <../scadlib/move.scad>

module m3( d, depth )
{
    cylinder(depth, d/2, d/2);
}

module rectangle( x, y )
{
    square([x,y]);
}

module oval( depth, width, length )
{
    union()
    {
        cylinder(depth, width/2, width/2);

        move(y=-width/2)
        cube([
            length - width,
            width,
            depth
        ]);

        move(x=length-width)
        cylinder(depth, width/2, width/2);
    };
}

// cap( btt_depth, btt_width, btt_length)
//   this is a hull between two ovals to make
//   the basic shape of the cover
module cap(depth, width, length, lip_edge=1.0)
{
    union() {
        top_width = width - depth*2;
        top_length = length - depth*2;
        hull()
        {
            // the base of the cap is an oval depth 1
            // this will give a small lip before the
            // chamfer
            oval( lip_edge, width, length );

            // offset the top so that its top is at
            // depth (the total depth of the cover as passed into
            // this function).
            move(z=depth-lip_edge)
            oval( lip_edge, top_width, top_length );
        }
    };
}


difference()
{
    union() {
        // hollow out a cap
        difference()
        {
            cap(btt_back_depth, btt_width, btt_length, m3_head_height);
            
            // we'll make a resized cap offset from the first
            // to hollow it out
            move(z=-shell_wall_thickness)
            cap(btt_back_depth,
                btt_width-shell_wall_thickness*2,
                btt_length-shell_wall_thickness*2,
                m3_head_height);
        }

        // cylinders around the fasteners
        // but only the part that would be inside the shell
        intersection()
        {
            cap(btt_back_depth, btt_width, btt_length);
            move(x=-(btt_width/2-TA), y=-AD/2)
            for (x = [0, AB, AC])
                for (y = [0, AD])
                    move(x=x, y=y)
                    cylinder(
                        m3_hole_diam*2,
                        btt_back_depth,
                        btt_back_depth );
        }
    };

    // holes for the m3 bolt threads
    move(x=-(btt_width/2-TA), y=-AD/2, z=-1)
    color("red")
    {
        for (x = [0, AB, AC])
            for (y = [0, AD])
                move(x=x, y=y)
                m3( m3_hole_diam, btt_back_depth+2);
    };

    // holes for the m3 heads
    move(x=-(btt_width/2-TA), y = -AD/2, z=m3_head_height)
    color("green")
    {
        for (x = [0, AB, AC])
            for (y = [0, AD])
                move(x=x, y=y)
                m3( m3_head_diam, btt_back_depth );
    };
};
