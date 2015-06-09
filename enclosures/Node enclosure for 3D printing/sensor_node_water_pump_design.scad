// Generic case - Improved
// v1 January 2015
// Printbus

// Remixed from dandmpye's Generic case (box and lid) http://www.thingiverse.com/thing:28608
// Changes include revised dimensioning for improved scalability
// Reformatted and labels revised for readability
// Added provision for mounting tabs

// Revise your paths to libary where these openSCAD library modules are located
use <E:\PlantFriends\enclosures\Node enclosure for 3D printing\teardrops.scad>
use <E:\PlantFriends\enclosures\Node enclosure for 3D printing\roundCornersCube.scad>
use <E:\PlantFriends\enclosures\Node enclosure for 3D printing\polyhole.scad>
// Summary of external modules used - 
// polyhole(h,d) provides improved size control on small holes
// roundCornersCube (x,y,z,r)

module standoff( post_od , post_id , post_h , hole_depth) {
  // Generates a standoff for mounting lid or circuit board
  // post_od: outer diamter of the standoff post
  // post_id: diameter of the inner hole in the standoff post
  // post_h: height of the standoff post
  // hole_depth: depth of the inner hole in the standoff post
  difference() {
    // start with a solid post
    cylinder( d = post_od , h = post_h , $fs=0.01);
    // remove the hole for the screw
    translate([ 0 , 0 , post_h - hole_depth ])
      polyhole( hole_depth + 1 , post_id ); 
  }  // end difference
}  // end module standoff

module cylindrical_lip( lip_od , lip_h , lip_w ) {	
  // Generate a quarter circle arc for use as a lip
  // lip_od: outer diameter of the lip arc
  // lip_h: height of the lip arc
  // lip_w: width of the lip arc
  lip_r = lip_od / 2;   // calculate radius of the lip arc
  difference() {
    // start with a solid cylinder
    cylinder( r=lip_r , h=lip_h , $fs=0.01);
    // hollow it out to form a ring
    translate([ 0 , 0 , -0.5 ])                // -0.5 to offset oversized cylinder being removed
      cylinder( r = lip_r - lip_w , h = lip_h + 1 , $fs=0.01 ); // oversize by +1 to ensure complete removal
    // remove all but a quarter of the ring
    translate([ -lip_r , 0 , -0.5 ])           // -0.5 to offset oversized cube being removed
      cube([ lip_od + 1 , lip_r , lip_h + 1 ]);// oversize by +1 to ensure complete removal 
    translate([ 0 , -lip_r , -0.5 ])           // -0.5 to offset oversized cube being removed
      cube([ lip_od + 1 , lip_r , lip_h + 1 ]);// oversize by +1 to ensure complete removal
  }  // end difference
}  // end module cylindrical_lip

module rounded_cube_case (generate_box, generate_lid) {
  // generate_box: true or false flag
  // generate_lid: true or false flag

  // Design rendering of box starts at x=0, y=0, z=0 (mounting tab will go into -x)
  // If used, mounting tabs are always added on X axis ends

  // Case parameters for tailoring  
  sx = 77; 			     // box outer size in X axis
  sy = 52;			     // box outer size in Y axis
  sz = 28;				  // box outer size in Z axis, including top and bottom
  box_r = 2.5;			  // radius of the box corners
  wall_t = 2;       // wall thickenss for the box and lid should be < box_hole_dia
  ft = 0.2;            // fit tolerance or clearance on lid

  // Box and lid screw hole parameters for tailoring
  box_hole_dia = 2.4;  // diameter of the screw hole in the box part (2.4 for #4)
  box_hole_depth = 10; // depth of the screw hole must be < box height
  lid_hole_dia = 3.2;  // diameter of the screw hole in the lid part (3.2 for #4)
  lid_head_dia = 5.5;  // diameter of the screw head recess (5.5 for #4)
  lid_head_depth = 0;  // depth of head recess (only use if wall_t can accomodate it)

  // Mounting tab parameters for tailoring
  tab_w = 8;           // mounting tab width 
  use_tab = true;     // true or false for mounting tab yes/no
  tab_hole_dia = 3.2;  // diameter of the clearance holes in the mounting tabs
  tab_hole_offset = 7; // offset from edge of tab to mounting holes

  // Misc calculations
  // corner_post_dia must be >= twice the wall thickness and >= lid_head_dia
  corner_post_dia = box_hole_dia * 3 ;    // diameter of the corner standoff post
  corner_post_r = corner_post_dia / 2 ;   // radius of the corner standoff post
  corner_lip_dia = corner_post_dia + 2 * (corner_post_r - wall_t) + 2 * ft ;
  corner_lip_r = corner_lip_dia / 2;

  // Prepare matrix of lid hole locations
  lid_hole_centres = [[    corner_post_r ,      corner_post_r , 0], 
					    [  sx - corner_post_r ,      corner_post_r , 0],
					    [  sx - corner_post_r , sy - corner_post_r , 0], 
					    [       corner_post_r , sy - corner_post_r , 0]];

  // Prepare matrix of mounting tab hole locations
  // Mounting holes are centered each corner of the mounting tabs
  tab_hole_centres = [[ -tab_w/2      , tab_hole_offset      , 0 ],
                      [  sx + tab_w/2 , tab_hole_offset      , 0 ],
                      [  sx + tab_w/2 , sy - tab_hole_offset , 0 ],
                      [  -tab_w/2     , sy - tab_hole_offset , 0 ]];

  if (generate_box == true) {    // we need to create the box part
    union() {
      difference() {
        // Start with a solid rounded cube
        translate([ sx/2 , sy/2 , sz/2 ])
          roundCornersCube( sx , sy , sz , box_r );
        // reduce the solids by the height of the box lid
        translate([ -0.1 , -0.1 , sz - wall_t ])
          cube([ sx+1 , sy+1 , wall_t + 1 ]);
        // Hollow out the box
        translate([ sx/2 , sy/2 , sz/2 + wall_t ]) 
          roundCornersCube( sx - (wall_t*2) , sy - (wall_t*2) , sz, box_r );

        // Define any holes in the box walls here
        translate([5, 23, 10+wall_t])
          roundCornersCube(15,10,6);
        translate([70, 42, 10+wall_t])
          rotate([0,90,0])
          cylinder(h=10, r=5, $fn=20);
           translate([32, 22.7, 0])
          cylinder(h=10, r=3, $fn=20);
        translate([62, 22.7, 0])
          roundCornersCube(17,14,5);
       
       translate([75, 13.5, 10+wall_t])
          roundCornersCube(19,14,6);
       translate([75, 30, 10+wall_t])
          roundCornersCube(19,10,6);
          
      }  // End difference
			
      // Add the standoff posts for the lid screws in each corner
      for (i = lid_hole_centres) {
        translate([ 0 , 0 , wall_t ])  // raise up to the inside of the box
          translate(i)                 // locate a corner
            standoff( corner_post_dia , box_hole_dia , sz - (wall_t * 2) , box_hole_depth );
      }  // end for loop

      // Add any mounting standoff posts on the box bottom here
      translate([5,10,wall_t/2])
      standoff(4,2,5,4);
      translate([70,10,wall_t/2])
      standoff(4,2,5,4);
      translate([5,35,wall_t/2])
      standoff(4,2,5,4);
      translate([70,35,wall_t/2])
      standoff(4,2,5,4);
      // Add mounting tab if needed
      if ( use_tab == true ) {
        difference () {
          // start with the solid mounting tab
          translate ([ sx/2 , sy/2 , wall_t/2 ])
            roundCornersCube ( sx + (tab_w*2) , sy , wall_t , box_r );

          // now remove holes in the mounting tab
          for (j = tab_hole_centres) {          // for each hole in the mounting tab
            translate ([ 0 , 0 , -0.5 ])        // shift Z to ensure complete removal of hole
              translate(j)
                polyhole ( wall_t + 1 , tab_hole_dia );
          }  // end for loop on mounting tab holes
           translate([32, 22.7, 0])
          cylinder(h=10, r=2.5, $fn=20);
        translate([62, 22.7, 0])
          roundCornersCube(17,14,5);
          
        }  // end difference
      }  // end if use_tab

    }  // end union
  }  // end if generate_box

  y_offset = generate_box ? sy+10 : 0; // offset lid Y by sy+10 if we are also doing box
  if ( generate_lid == true ) {        // we need to create the lid part
    translate([ 0, y_offset , 0]) { 
      difference() {
        // create the base solids for the lid
        union() {
          //Create the plate of the lid
          translate([ sx/2 , sy/2, wall_t/2 ])
            roundCornersCube( sx , sy , wall_t , box_r );
 
          // Add a reinforcement lip to the lid, starting with the straight portions 
          // The lip has a height equal to the wall thickness
          // The lip width is adjusted to align inside edge with corner hole centers
          translate([ corner_post_dia + ft , wall_t + ft , wall_t ]) 
            cube([sx - (corner_post_dia*2) - (ft*2) , corner_post_r-wall_t , wall_t ]);
          translate([wall_t + ft , corner_post_dia + ft , wall_t]) 
            cube([ corner_post_r-wall_t , sy - (corner_post_dia*2) - (ft*2) , wall_t ]);
          translate([sx - corner_post_r - ft , corner_post_dia + ft , wall_t ]) 
            cube([corner_post_r-wall_t , sy - (corner_post_dia*2) - (ft*2) , wall_t ]);	
          translate([corner_post_dia + ft, sy - corner_post_r - ft, wall_t]) 
            cube([sx - (corner_post_dia*2) - (ft*2) , corner_post_r-wall_t , wall_t]);
					
          //Fit a quarter circle lip around the corner standoffs
          translate([ 0 , 0 , wall_t]) 
            translate( lid_hole_centres[0] ) 
              rotate(180)  
                cylindrical_lip( corner_lip_dia , wall_t , corner_post_r-wall_t );
          translate([ 0 , 0 , wall_t ])
            translate( lid_hole_centres [1] )
              rotate(270)  
                cylindrical_lip( corner_lip_dia , wall_t , corner_post_r-wall_t );
          translate([ 0 , 0 , wall_t ])
            translate( lid_hole_centres [2] ) 
              cylindrical_lip( corner_lip_dia , wall_t, corner_post_r-wall_t );
          translate([ 0 , 0 , wall_t ])
            translate( lid_hole_centres [3] )
              rotate(90)  
					 cylindrical_lip( corner_lip_dia , wall_t , corner_post_r-wall_t );
        }  // end union of the base solids

        for (i = lid_hole_centres) {            // for each corner in the lid
          // remove the material for the corner screw hole 
          translate([ 0 , 0 , -0.5 ])           // shift Z to ensure complete removal of hole
            translate(i) 
              polyhole( wall_t + 1 , lid_hole_dia ); // height is +1 to ensure complete removal
          if ( lid_head_depth > 0 ) {           // we need to countersink the screw head
            // remove the material for the screw head recess 
            translate([ 0 , 0 , -1 ])           // -1 to offset oversize hole being removed
              translate(i) 
                polyhole( lid_head_depth + 1 , lid_head_dia ); // oversize +1 to ensure complete removal 
          }  // end if lid_head_depth
        }  // end for loop on lid holes

        // Add removal of any holes in the lid here

      }  // end difference for lid
    }  // end translate to move away from box if it is also being made
  }  // end if generate_lid
}  // end module rounded_cube_case

// Here's the top level geometry
// Edit true or false for obtaining box and lid respectively
rounded_cube_case(false, true);

