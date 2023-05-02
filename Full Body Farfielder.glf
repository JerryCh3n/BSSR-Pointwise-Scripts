#Creates the farfield and boundary conditions
#Author: Jerry Chen
#Started: 6/24/2020
#Last Updated: 6/26/2020

package require PWI_Glyph 2.3

#The export location *remember is forward slash, NOT back slash
set EXPORTLOCATION "C:/Users/Bluesky/LOCATION/AIRFOIL.cas" 
 
#The name of the group containing car domains 
set CAR_DOMAINS "car_domains"  


set AVERAGE_CONNECTOR_SPACING 500


#How many points you go in the z direction for source starting from point above canopy
set Z_DIRECTION_NODES 6


#How many points you go in the y direction for source (should be half the total distance)
set Y_DIRECTION_NODES 9


#How many points you go in the x direction for source aka total length
#This is from 110 - 26 (front from inlet) -15 (back from outlet)
set X_FRONT_NODES 26  
set X_DIRECTION_NODES 69


#Source settings
set beginning_spacing 40
set beginning_decay 0.6  
set ending_spacing 100  
set ending_decay 0.6  

set aniso_iso_blend  0.75





#___________________________
#No need to anything past here
#___________________________
set car_domain_PX 35000
set car_domain_MX 15000
set car_domain_PY 10000
set car_domain_MY 10000
set car_domain_PZ 10000
set car_domain_MZ 60





set car_dom_gp [pw::Group getByName $CAR_DOMAINS]


set max_ptX -9999
set min_ptX 9999
set max_ptY -9999
set min_ptY 9999
set max_ptZ -9999
set min_ptZ 9999

#Finding the max and min points around the car
puts "Fitting tightest box around car"
foreach domain [$car_dom_gp getEntityList] {
	set num_points [lindex [regexp -inline -all -- {\S+} [$domain getDimensions]] 0]
	for {set i 1}  {$i <= $num_points} {incr i} {
		set x [lindex [regexp -inline -all -- {\S+} [$domain getXYZ -grid $i]] 0]
		set y [lindex [regexp -inline -all -- {\S+} [$domain getXYZ -grid $i]] 1]
		set z [lindex [regexp -inline -all -- {\S+} [$domain getXYZ -grid $i]] 2]
		
		if {$x < $min_ptX} {set min_ptX $x}
		if {$x > $max_ptX} {set max_ptX $x}
		if {$y < $min_ptY} {set min_ptY $y}
		if {$y > $max_ptY} {set max_ptY $y}
		if {$z < $min_ptZ} {set min_ptZ $z}
		if {$z > $max_ptZ} {set max_ptZ $z}
	}
}






#Building the box around the car
puts "Building the mesh around the car"
set extended_max_ptX [expr $max_ptX + $car_domain_PX ]
set extended_min_ptX [expr $min_ptX - $car_domain_MX ]

set extended_max_ptY [expr $max_ptY + $car_domain_PY ]
set extended_min_ptY [expr $min_ptY - $car_domain_MY ]

set extended_max_ptZ [expr $max_ptZ + $car_domain_PZ ]
set extended_min_ptZ [expr $min_ptZ - $car_domain_MZ ]

#AB
set pts {}
lappend pts [list $extended_min_ptX $extended_max_ptY $extended_max_ptZ]
lappend pts [list $extended_min_ptX $extended_min_ptY $extended_max_ptZ]
set front_upper_con [pw::Connector createFromPoints $pts]
$front_upper_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING

#CD
set pts {}
lappend pts [list $extended_min_ptX $extended_max_ptY $extended_min_ptZ]
lappend pts [list $extended_min_ptX $extended_min_ptY $extended_min_ptZ]
set front_lower_con [pw::Connector createFromPoints $pts]
$front_lower_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING

#AC
set pts {}
lappend pts [list $extended_min_ptX $extended_max_ptY $extended_max_ptZ]
lappend pts [list $extended_min_ptX $extended_max_ptY $extended_min_ptZ]
set front_left_con [pw::Connector createFromPoints $pts]
$front_left_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING

#BD
set pts {}
lappend pts [list $extended_min_ptX $extended_min_ptY $extended_max_ptZ]
lappend pts [list $extended_min_ptX $extended_min_ptY $extended_min_ptZ]
set front_right_con [pw::Connector createFromPoints $pts]
$front_right_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING



#AE
set pts {}
lappend pts [list $extended_min_ptX $extended_max_ptY $extended_max_ptZ]
lappend pts [list $extended_max_ptX $extended_max_ptY $extended_max_ptZ]
set mid_upper_left_con [pw::Connector createFromPoints $pts]
$mid_upper_left_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING

#BF
set pts {}
lappend pts [list $extended_min_ptX $extended_min_ptY $extended_max_ptZ]
lappend pts [list $extended_max_ptX $extended_min_ptY $extended_max_ptZ]
set mid_upper_right_con [pw::Connector createFromPoints $pts]
$mid_upper_right_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING

#CG
set pts {}
lappend pts [list $extended_min_ptX $extended_max_ptY $extended_min_ptZ]
lappend pts [list $extended_max_ptX $extended_max_ptY $extended_min_ptZ]
set mid_lower_left_con [pw::Connector createFromPoints $pts]
$mid_lower_left_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING

#DH
set pts {}
lappend pts [list $extended_min_ptX $extended_min_ptY $extended_min_ptZ]
lappend pts [list $extended_max_ptX $extended_min_ptY $extended_min_ptZ]
set mid_lower_right_con [pw::Connector createFromPoints $pts]
$mid_lower_right_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING


#EF
set pts {}
lappend pts [list $extended_max_ptX $extended_max_ptY $extended_max_ptZ]
lappend pts [list $extended_max_ptX $extended_min_ptY $extended_max_ptZ]
set back_upper_con [pw::Connector createFromPoints $pts]
$back_upper_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING

#GH
set pts {}
lappend pts [list $extended_max_ptX $extended_max_ptY $extended_min_ptZ]
lappend pts [list $extended_max_ptX $extended_min_ptY $extended_min_ptZ]
set back_lower_con [pw::Connector createFromPoints $pts]
$back_lower_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING

#EG
set pts {}
lappend pts [list $extended_max_ptX $extended_max_ptY $extended_max_ptZ]
lappend pts [list $extended_max_ptX $extended_max_ptY $extended_min_ptZ]
set back_left_con [pw::Connector createFromPoints $pts]
$back_left_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING 

#FH
set pts {}
lappend pts [list $extended_max_ptX $extended_min_ptY $extended_max_ptZ]
lappend pts [list $extended_max_ptX $extended_min_ptY $extended_min_ptZ]
set back_right_con [pw::Connector createFromPoints $pts]
$back_right_con setDimensionFromSpacing -resetDistribution $AVERAGE_CONNECTOR_SPACING






#Creating Domains

#Front Domain
set front_dom [pw::DomainUnstructured createFromConnectors [list $front_upper_con $front_left_con $front_lower_con $front_right_con]]
set left_dom [pw::DomainUnstructured createFromConnectors [list $mid_upper_left_con $front_left_con $mid_lower_left_con $back_left_con]]
set right_dom [pw::DomainUnstructured createFromConnectors [list $mid_upper_right_con $front_right_con $mid_lower_right_con $back_right_con]]
set upper_dom [pw::DomainUnstructured createFromConnectors [list $front_upper_con $mid_upper_left_con $back_upper_con $mid_upper_right_con]]
set lower_dom [pw::DomainUnstructured createFromConnectors [list $front_lower_con $mid_lower_left_con $back_lower_con $mid_lower_right_con]]
set back_dom [pw::DomainUnstructured createFromConnectors [list $back_upper_con $back_left_con $back_lower_con $back_right_con]]

set farfield_dom_gc [pw::Group create]
$farfield_dom_gc setName "farfield_domains"
$farfield_dom_gc setEntityType pw::Domain
$farfield_dom_gc addEntity [list $front_dom $left_dom $right_dom $upper_dom $lower_dom $back_dom]

#Applying T-Rex

set trex_mode [pw::Application begin UnstructuredSolver [list $front_dom $left_dom $right_dom $upper_dom $lower_dom $back_dom]]
set temp_collection [pw::Collection create]
$temp_collection set [list $front_dom $left_dom $right_dom $upper_dom $lower_dom $back_dom]
$temp_collection do setUnstructuredSolverAttribute Algorithm AdvancingFront
$temp_collection do setUnstructuredSolverAttribute TRexGrowthRate 1.2
$temp_collection delete
$trex_mode run Initialize
$trex_mode end






#Create source
puts "Creating source"
set z_space [$front_left_con getAverageSpacing]
set width [expr [expr ceil([expr $max_ptZ - $extended_min_ptZ] / $z_space) + $Z_DIRECTION_NODES] * $z_space]

set height [expr [$front_lower_con getAverageSpacing] * $Y_DIRECTION_NODES * 2]

set x_space [$mid_lower_right_con getAverageSpacing]
set length [expr $x_space * $X_DIRECTION_NODES]

set create_source [pw::Application begin Create]
set source [pw::SourceShape create]
#Width=X Height=Y Length=Z
$source box -width $width -height $height -length $length
#Rotation https://image.slideserve.com/1229348/rotation-matrices-l.jpg
#Learn 4D matrix transfromation if you wanna understand this
set x_translate [expr $x_space * $X_FRONT_NODES + $extended_min_ptX]
set y_translate [expr [expr $max_ptY + $min_ptY] / 2]
set z_translate [expr $width / 2 + $extended_min_ptZ]

#Pointwise has each four elements as a COLUMN of a 4D matrix
$source setTransform [list 0 0 -1 0 0 1 0 0 1 0 0 0 $x_translate $y_translate $z_translate 1]
$source setPivot Base
$source setSectionMinimum 0
$source setSectionMaximum 360
$source setSidesType Plane
$source setBaseType Plane
$source setTopType Plane
$source setEnclosingEntities {}
$source setBeginSpacing $beginning_spacing
$source setBeginDecay $beginning_decay
$source setEndSpacing $ending_spacing
$source setEndDecay $ending_decay
$create_source end




#Create Baffle Faces
puts "Creating baffle faces"
set baffle_faces_mode [pw::Application begin Create]
set block [pw::BlockUnstructured create]

set temp_face_1 [pw::FaceUnstructured createFromDomains [$farfield_dom_gc getEntityList]]
$temp_face_1 setNormalOrientation In

set temp_face_2 [pw::FaceUnstructured createFromDomains [$car_dom_gp getEntityList]]
$temp_face_2 setNormalOrientation Out

$block addFace $temp_face_1
$block addFace $temp_face_2

$baffle_faces_mode end




#Building the Block
puts "Building block"
puts "This will take at least 5 min. Go stretch"
set block_solver_mode [pw::Application begin UnstructuredSolver [list $block]]

set car_rexbc [pw::TRexCondition create]
$car_rexbc setName kar
$car_rexbc setConditionType Wall
$car_rexbc setValue 0.02

set car_bl_dom {}
foreach domain [$car_dom_gp getEntityList] {
	lappend car_bl_dom [list $block $domain]
}

$car_rexbc apply $car_bl_dom

set build_off_rexbc [pw::TRexCondition create]
$build_off_rexbc setName build_off
$build_off_rexbc setConditionType Off
$build_off_rexbc setAdaptation On
$build_off_rexbc apply [list [list $block $lower_dom]]

$block setUnstructuredSolverAttribute TRexMaximumLayers 50
$block setUnstructuredSolverAttribute TRexFullLayers 1
$block setUnstructuredSolverAttribute TRexGrowthRate 1.2
$block setUnstructuredSolverAttribute TRexPushAttributes True
$block setUnstructuredSolverAttribute TRexAnisotropicIsotropicBlend $aniso_iso_blend
$block setUnstructuredSolverAttribute TRexCollisionBuffer 2
$block setUnstructuredSolverAttribute TRexSkewCriteriaMaximumAngle 170

$block_solver_mode setStopWhenFullLayersNotMet true
$block_solver_mode run Initialize

$block_solver_mode end

#Solver Setting
puts "Setting Fluent boundary conditions"
pw::Application setCAESolver {ANSYS Fluent} 3

set inlet_bc [pw::BoundaryCondition create]
$inlet_bc setName inlet
$inlet_bc setPhysicalType -usage CAE {Velocity Inlet}
$inlet_bc apply [list [list $block $front_dom]]

set outlet_bc [pw::BoundaryCondition create]
$outlet_bc setName outlet
$outlet_bc setPhysicalType -usage CAE {Pressure Outlet}
$outlet_bc apply [list [list $block $back_dom]]

set walls_bc [pw::BoundaryCondition create]
$walls_bc setName walls
$walls_bc setPhysicalType -usage CAE {Wall}
$walls_bc apply [list [list $block $left_dom] [list $block $right_dom] [list $block $upper_dom]]

set road_bc [pw::BoundaryCondition create]
$road_bc setName road
$road_bc setPhysicalType -usage CAE {Wall}
$road_bc apply [list [list $block $lower_dom]]

set car_bc [pw::BoundaryCondition create]
$car_bc setName car
$car_bc setPhysicalType -usage CAE {Wall}
$car_bc apply $car_bl_dom