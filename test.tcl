#! /bin/env tclsh

set board() []

proc test {} {
	global board

	set board(test0) 0
	set board(test1) 1
	set board(test2) 2
	set board(test3) 3
}

test

proc print {} {
	global board

	puts $board(test0)
	puts $board(test1)
	puts $board(test2)
	puts $board(test3)
}

print
