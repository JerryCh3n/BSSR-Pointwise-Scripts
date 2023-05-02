#General mesher for airfoils
#Author: Jerry Chen
#Started: 5/27/2020
#Last Updated: 6/8/2020

package require PWI_Glyph 2.3





#If you want to add for loops to parameterize add after them after these comments.
#Do not forget about curly braces at the end!
#If you get "extra characters after close-brace" error, remember to have a space before the "{" that starts the for loop

#PARAMETERS YOU CAN CHANGE


#The points filename
set FILENAME "AIRFOIL.txt"

#The export location *remember is forward slash, NOT back slash
set EXPORTLOCATION "C:/Users/Bluesky/LOCATION/AIRFOIL.cas" 
 
#Default number of nodes per connector
set AIRFOILDIM 250


#Number of nodes on the tail
set TAILDIM 1000


#Specify the clustering at the end and front of the airfoil
set AIRFOILSPACING 0.0015


#Number of Points and intial spacing on the back line. You need to calculate it/experiment if you change anything parameters after this
set BACKDIM 50
set BACKSPACING 0.5


#Scales the mesh up or down. Default for airfoil is 1 unit
set SCALE 5


#Distance from the end of the airfoil to the end
set TRAILINGDISTANCE 50
#Radius of the arc centers at the end of the airfoil
set RADIALDISTANCE 25


#First Layer height generated from y+
set FIRSTLAYER 0.00002


#_____________________________
#No need to anything past here
#_____________________________





#Generates upper horizontal line

set horUpper [pw::Application begin Create]
set horUpperPts [pw::SegmentSpline create]

$horUpperPts addPoint [list $SCALE $RADIALDISTANCE 0]
$horUpperPts addPoint [list $TRAILINGDISTANCE $RADIALDISTANCE 0]

set horUpperCurve [pw::Curve create]
$horUpperCurve addSegment $horUpperPts

set horUpperCon [pw::Connector createOnDatabase $horUpperCurve ]
$horUpperCon  setName horUpper
$horUpperCon setDimension $TAILDIM 

set tempDist [$horUpperCon getDistribution 1]
$tempDist  setBeginSpacing $AIRFOILSPACING
unset tempDist 

$horUpper end





#Generates lower horizontal line

set horLower [pw::Application begin Create]
set horLowerPts [pw::SegmentSpline create]

$horLowerPts addPoint [list $SCALE [expr -1 * $RADIALDISTANCE] 0]
$horLowerPts addPoint [list $TRAILINGDISTANCE [expr -1 * $RADIALDISTANCE] 0]

set horLowerCurve [pw::Curve create]
$horLowerCurve addSegment $horLowerPts

set horLowerCon [pw::Connector createOnDatabase $horLowerCurve ]
$horLowerCon  setName horLower
$horLowerCon setDimension $TAILDIM 

set tempDist [$horLowerCon getDistribution 1]
$tempDist  setBeginSpacing $AIRFOILSPACING
unset tempDist 

$horLower end





#Generates the top arc
set arcUpperSeg [pw::SegmentCircle create]
$arcUpperSeg addPoint [list $SCALE $RADIALDISTANCE 0]
$arcUpperSeg addPoint [list [expr -1 * [expr $RADIALDISTANCE - $SCALE]] 0 0] 
$arcUpperSeg setAngle 90 {0 0 1}

set arcUpperCon [pw::Connector create]
$arcUpperCon setName arcUpper
$arcUpperCon addSegment $arcUpperSeg 
$arcUpperCon setDimension $AIRFOILDIM 

set tempDist [$arcUpperCon getDistribution 1]
$tempDist setBeginSpacing $AIRFOILSPACING
$tempDist setBeginSpacing $AIRFOILSPACING
$tempDist setEndSpacing $AIRFOILSPACING
unset tempDist 




#Generates the lower arc
set arcLowerSeg [pw::SegmentCircle create]
$arcLowerSeg addPoint [list [expr -1 * [expr $RADIALDISTANCE - $SCALE]] 0 0]  
$arcLowerSeg addPoint [list $SCALE [expr -1 * $RADIALDISTANCE] 0] 
$arcLowerSeg setAngle 90 {0 0 1}

set arcLowerCon [pw::Connector create]
$arcLowerCon setName arcLower
$arcLowerCon addSegment $arcLowerSeg 
$arcLowerCon setDimension $AIRFOILDIM 

set tempDist [$arcLowerCon getDistribution 1]
$tempDist setBeginSpacing $AIRFOILSPACING
$tempDist setEndSpacing $AIRFOILSPACING
unset tempDist 


#Solver Setting
pw::Application setCAESolver {ANSYS Fluent} 2

set inletbc [pw::BoundaryCondition create]
$inletbc setName inlet
$inletbc setPhysicalType -usage CAE {Velocity Inlet}

set outletbc [pw::BoundaryCondition create]
$outletbc setName outlet
$outletbc setPhysicalType -usage CAE {Pressure Outlet}

set airfoilbc [pw::BoundaryCondition create]
$airfoilbc setName airfoil
$airfoilbc setPhysicalType -usage CAE {Wall}

