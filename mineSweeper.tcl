#! /bin/env wish
package require Tk

set GRID_SIZE 25
set BUTTON_SIZE 18
# Number of bombs is 20% of the number of tiles
#set NUM_BOMBS [expr {int( [expr $GRID_SIZE * $GRID_SIZE] * 0.2)}]
set NUM_BOMBS [expr {int( [expr $GRID_SIZE * $GRID_SIZE] * 0.1)}]

set NUM_LENGTH [string length $GRID_SIZE]

puts "NUM LENGTH"
puts $NUM_LENGTH

set uniqueID 0

set bombsPlaced 0

set bombsLeft $NUM_BOMBS

# 1 = Game Over, 0 = Game not over
set gameOver 0

# Import the various image files -------------------------
set bomb [image create photo -file images/minesweeperBomb.png]
set flag [image create photo -file images/minesweeperFlag.png]
set empty [image create photo -file images/minesweeperEmpty.png]
set redBomb [image create photo -file images/minesweeperBombRedX.png]
set zero [image create photo -file images/grey.png]

set one [image create photo -file images/one.png]
set two [image create photo -file images/two.png]
set three [image create photo -file images/three.png]
set four [image create photo -file images/four.png]
set five [image create photo -file images/five.png]
set six [image create photo -file images/six.png]
set seven [image create photo -file images/seven.png]
set eight [image create photo -file images/eight.png]
# --------------------------------------------------------

set firstClick true

set board() []

proc updateButton {x y newImage} {
	global BUTTON_SIZE
	global uniqueID

	set xy $x,$y

	grid [button .myButtonUnique$uniqueID$xy  -image $newImage -height $BUTTON_SIZE -width $BUTTON_SIZE]
	grid .myButtonUnique$uniqueID$xy -row $y -column $x
	incr uniqueID
}

proc bombPopulate {x y} {
	global board bombsPlaced NUM_BOMBS GRID_SIZE NUM_LENGTH

	while {$NUM_BOMBS > $bombsPlaced} {
		set xPosition [expr {int(rand() * $GRID_SIZE)}]
		set yPosition [expr {int(rand() * $GRID_SIZE)}]

		set xyPosition ${xPosition},${yPosition}

		set xy ${x},${y}

		# If position randomly selected is the bomb position, reselect position or if position already has a bomb
		if {$xyPosition == $xy || $board($xyPosition) == 1} {
			continue
		}

		# Sets position to be a bomb position
		set board($xyPosition) 1
		incr bombsPlaced
####		puts $xyPosition
	}

}

# Generates a minesweeper board without a bomb at x y
proc generateBoard {x y} {
	global GRID_SIZE board NUM_LENGTH

	# Sets entire grid to initalize with no bomb status
	for {set xCurrent 0} {$xCurrent < $GRID_SIZE} {incr xCurrent} {
		for {set yCurrent 0} {$yCurrent < $GRID_SIZE} {incr yCurrent} {
			#set xPadded [format {%0*s} $NUM_LENGTH $xCurrent]
			#set yPadded [format {%0*s} $NUM_LENGTH $yCurrent]

			#set xy ${xPadded},${yPadded}
			set xy ${xCurrent},${yCurrent}
			#set xy $xCurrent$yCurrent

			# 0 == no bomb
			# 1 == bomb
			set board($xy) 0
		}
		}

	bombPopulate $x $y	
}

proc checkBombNeighbours {x y} {
	global board zero GRID_SIZE NUM_LENGTH
	set bombCount 0

	puts "Hello"
	puts $x
	puts $y
	puts "Goodbye"

	set xPO [expr [expr [scan $x %d]] + 1]
	set xNO [expr [expr [scan $x %d]] - 1]
	set yPO [expr [expr [scan $y %d]] + 1]
	set yNO [expr [expr [scan $y %d]] - 1]
	
	if {$xPO >= $GRID_SIZE} {set xPO [expr $GRID_SIZE - 1]}
	if {$yPO >= $GRID_SIZE} {set yPO [expr $GRID_SIZE - 1]}
	if {$xPO >= $GRID_SIZE} {puts "EEEEEEEEEEEEEEEEEEE"}
	if {$yPO >= $GRID_SIZE} {puts "EEEGGGGGGGGGGGGGGGGGG"}
	if {$xPO >= $GRID_SIZE} {puts [expr $GRID_SIZE - 1]}
	if {$yPO >= $GRID_SIZE} {puts [expr $GRID_SIZE - 1]}
	if {$xPO >= $GRID_SIZE} {puts $xPO}
	if {$yPO >= $GRID_SIZE} {puts $yPO}
	if {$xNO < 0} {set $xNO 0}
	if {$yNO < 0} {set $yNO 0}

	puts "AAAAAA"
	puts $xPO
	puts $yPO
	puts $xNO
	puts $yNO
	puts "BBBBBB"
	puts ""

	if {$xPO < $GRID_SIZE && $board($xPO,$y) == 1 } {incr bombCount}
	if {$yNO >= 0 && $xPO < $GRID_SIZE && $board($xPO,$yNO) == 1} {incr bombCount}
	if {$yNO >= 0 && $board($x,$yNO) == 1} {incr bombCount}
	if {$xNO >= 0 && $yNO >= 0 && $board($xNO,$yNO) == 1} {incr bombCount}
	if {$xNO >= 0 && $board($xNO,$y) == 1} {incr bombCount}
	if {$xNO >= 0 && $yPO < $GRID_SIZE && $board($xNO,$yPO) == 1} {incr bombCount}
	if {$yPO < $GRID_SIZE && $board($x,$yPO) == 1} {incr bombCount}
	if {$xPO < $GRID_SIZE && $yPO < $GRID_SIZE && $board($xPO,$yPO) == 1} {incr bombCount}

	set board(${x},${y}) 2
	return $bombCount
}

# Recursively go through board and display adjact bomb values
proc uncoverState {x y} {
	global one two three four five six seven eight zero
	global board GRID_SIZE NUM_LENGTH gameOver

	if {$x >= $GRID_SIZE} {set x [expr $GRID_SIZE - 1]}
	if {$y >= $GRID_SIZE} {set y [expr $GRID_SIZE - 1]}
	if {$x < 0} {set $x 0}
	if {$y < 0} {set $y 0}

	set value [checkBombNeighbours $x $y]

	if {$value == 0} {
		set xPO [expr [expr [scan $x %d]] + 1]
		set xNO [expr [expr [scan $x %d]] - 1]
		set yPO [expr [expr [scan $y %d]] + 1]
		set yNO [expr [expr [scan $y %d]] - 1]

		if {$xPO >= $GRID_SIZE} {set $xPO [expr $GRID_SIZE - 1]}
		if {$yPO >= $GRID_SIZE} {set $yPO [expr $GRID_SIZE - 1]}
		if {$xNO < 0} {set $xNO 0}
		if {$yNO < 0} {set $yNO 0}

		set xP [format {%0*s} $NUM_LENGTH $xPO]
		set xN [format {%0*s} $NUM_LENGTH $xNO]
		set yP [format {%0*s} $NUM_LENGTH $yPO]
		set yN [format {%0*s} $NUM_LENGTH $yNO]
	
		# To stop infinite recursion, sets current board position to 3
		set $board(${x},${y}) 3		

		if {$xPO < $GRID_SIZE && $board(${xPO},${y}) < 2 } {uncoverState $xPO $y}
		if {$yNO >= 0 && $xPO < $GRID_SIZE && $board(${xPO},${yNO}) < 2} {uncoverState $xPO $yPO}
		if {$yNO >= 0 && $board(${x},${yNO}) < 2} {uncoverState $x $yNO}
		if {$xNO >= 0 && $yNO >= 0 && $board(${xNO},${yNO}) < 2} {uncoverState $xNO $yNO}
		if {$xNO >= 0 && $board(${xNO},${y}) < 2} {uncoverState $xNO $y}
		if {$xNO >= 0 && $yPO < $GRID_SIZE && $board(${xNO},${yPO}) < 2} {uncoverState $xNO $yPO}
		if {$yPO < $GRID_SIZE && $board(${x},${yPO}) < 2} {uncoverState $x $yPO}
		if {$xPO < $GRID_SIZE && $yPO < $GRID_SIZE && ($board(${xPO},${yPO}) < 2)} {uncoverState $xPO $yPO}
	}
	if {$value == 0 && $gameOver == 0} {updateButton $x $y $zero}
	if {$value == 1 && $gameOver == 0} {updateButton $x $y $one}
	if {$value == 2 && $gameOver == 0} {updateButton $x $y $two}
	if {$value == 3 && $gameOver == 0} {updateButton $x $y $three}
	if {$value == 4 && $gameOver == 0} {updateButton $x $y $four}
	if {$value == 5 && $gameOver == 0} {updateButton $x $y $five}
	if {$value == 6 && $gameOver == 0} {updateButton $x $y $six}
	if {$value == 7 && $gameOver == 0} {updateButton $x $y $seven}
	if {$value == 8 && $gameOver == 0} {updateButton $x $y $eight}
}

# If bomb was clicked, shows all bombs on screen
proc lostState {xPressed yPressed} {
	global board GRID_SIZE NUM_LENGTH
	global bomb redBomb gameOver

	set gameOver 1
	
	for {set x 0} {$x < $GRID_SIZE} {incr x} {
		for {set y 0} {$y < $GRID_SIZE} {incr y} {
			set xPadded [format {%0*s} $NUM_LENGTH $x]
			set yPadded [format {%0*s} $NUM_LENGTH $y]

			#set xy $xPadded$yPadded
			set xy ${x},${y}

			if {$board($xy) == 1} {
				updateButton $x $y $bomb
			}
		}	
	}

	updateButton $xPressed $yPressed $redBomb
}

proc buttonClicked {x y} {
	global firstClick board
	global flag bomb empty
	global one two three four five six seven eight

	set xy ${x},${y}
	
	puts $xy

	#Check if location is a bomb or not...
		
	if {$firstClick == true} {
		set firstClick false
		# generate board where their click is not a bomb
		generateBoard $x $y
	}

	# Position clicked is bomb...
	if {$board($xy) == 1} {
		# Uncover all bombs
		lostState $x $y
	}
	
	# Position clicked is not a bomb
	if {$board($xy) == 0} {
		uncoverState $x $y
	}

}

menu .menu -tearoff 0 
.menu add command -label "Option 1"
.menu add command -label "Option 2"



proc rightClick {xPass yPass} {
	global flag BUTTON_SIZE
	# set x [expr [winfo rootx .]+$xPass]
	# set y [expr [winfo rooty .]+$yPass]
	puts "\n\nStart of right click"
	puts [winfo pointerx .]
	puts [winfo pointery .]
	puts [winfo rootx .]
	puts [winfo rooty .]
	puts $xPass
	puts $yPass
	#set x [expr [winfo pointerx .]+$xPass]
	#set y [expr [winfo pointery .]+$yPass]
	set x $xPass
	set y $yPass

	puts "WOW DID RIGHT CLICK WORK????"
	puts $x
	puts $y
	set x [expr $x / $BUTTON_SIZE]
	set y [expr $y / $BUTTON_SIZE]
	puts $x
	puts $y
	puts "End--------"
	updateButton $x $y $flag
}

proc initGrid {} {
	global GRID_SIZE BUTTON_SIZE NUM_LENGTH
	global flag bomb empty
	global one two three four five six seven eight
	global bombsLeft

	grid [label .locationLable  -text "" -textvar locationText]

	for {set yy 0} {$yy < $GRID_SIZE} {incr yy} {
		for {set xx 0} {$xx < $GRID_SIZE} {incr xx} {
			#set xPadded [format {%0*s} $NUM_LENGTH $x]
			#set yPadded [format {%0*s} $NUM_LENGTH $y]

			#set xy $xPadded$yPadded

			set xy ${xx},${yy}
	
			grid [button .myButton$xy  -image $empty -height $BUTTON_SIZE -width $BUTTON_SIZE -command "buttonClicked $xx $yy"]
			#grid [button .myButton$xy  -image $empty -height $BUTTON_SIZE -width $BUTTON_SIZE -command "buttonClicked $xPadded $yPadded"]
			#grid [button .myButton$xy  -image $empty -height $BUTTON_SIZE -width $BUTTON_SIZE]

			bind .myButton$xy <Button-3> {
				rightClick %X %Y
				puts %X
				puts %Y
				puts %x
				puts %y
			}

			#bind .myButton$xy <Button-1> {
			#	 buttonClicked %x %y
			#}

			grid .myButton$xy -row $yy -column $xx
		}
	}
	label .l -text "Bombs Left: $bombsLeft"
	grid .l -row $GRID_SIZE -column 0 -columnspan $GRID_SIZE
}

initGrid

