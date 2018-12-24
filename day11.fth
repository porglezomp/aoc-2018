0 value grid-serial
1 value grid-size
300 constant length

: rack-id ( x y -- x y rid )  over 10 + ;
: hundreds-place   100 /  10 mod ;
: cell-power ( x y -- power )
  rack-id *  grid-serial +  rack-id *
  hundreds-place  5 -  nip ;

: square-power ( x y -- power )
  0 swap dup grid-size + swap do
    over dup grid-size + swap do
      i j cell-power +
    loop
  loop nip ;

: 3<   5 pick 3 pick < ;
: 3max ( x1 i1 j1 x2 i2 j2 -- x? i? j? )
  3< if  5 roll 5 roll 5 roll  then 
  drop drop drop ;

0 value safe-end
: find-square ( grid-size -- )
  to grid-size
  grid-size 0 = if  abort" grid-size must be nonzero "  then
  length grid-size - 2 max to safe-end 
  0 0 0
  safe-end 1 do
    safe-end 1 do
      i j square-power  i j 3max
    loop
  loop ;

0 value best-size
: find-grid
  0 to best-size
  0 0 0
  length 1 + 1 do
    ." find " i 3 .r cr
    i find-square
    3< if  i to best-size  then
    3max
  loop ;

: comma   [char] , emit ;
: .#  0 .r ;
: print-coord ( v x y -- )  swap .# comma .# drop ;

: main
  3 find-square print-coord cr
  find-grid print-coord comma best-size .# cr ;

\ We don't do input here, because I haven't figured it out
9424 to grid-serial
main
bye
