#!/usr/bin/tclsh

# first.tcl

proc stringreverse str {
   set res {}
   set i [string length $str]
   while {$i > 0} {append res [string index $str [incr i -1]]}
   set res
   puts $res
} ;

stringreverse "TCL"
