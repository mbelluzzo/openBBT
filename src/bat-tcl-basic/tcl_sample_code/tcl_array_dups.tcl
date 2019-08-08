proc getdups {list} {
  array set tmp {}

  foreach item $list {
    lappend tmp($item) .
  }

  foreach item [array names tmp] {
    if {[llength $tmp($item)] > 1} continue
    unset tmp($item)
  }

  return [array names tmp]
}
