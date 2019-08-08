set nums { 1 2 3 4 5 6 7 8 9 10 11 12 13 14
    15 16 17 18 19 20 21 22 23 24
}

puts "Prime numbers"

foreach num $nums {

    if { $num==1 || $num==2 || $num==3 } {

        puts -nonewline "$num "
        continue
    }

    set i [expr int(sqrt($num))]
    set isPrime true

    while { $i > 1 } {

        if { $num % $i == 0 } {

            set isPrime false
        }

        incr i -1
    }

    if { $isPrime } {

        puts -nonewline "$num "
    }
}

puts ""
