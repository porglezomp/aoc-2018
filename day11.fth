9424 value grid-serial
1 value grid-size
300 constant length

variable grid  length length * cells allot
: erase-grid   grid length length * cells erase ;
: access ( x y -- ptr )
  1- length * + 1- cells grid + ;

: 3dup ( x y z -- x y z x y z )  dup 2over rot ;
: input  0. bl word count >number 2drop drop ;

: limit ( n -- lim )  length swap - 1+ 2 max ;
: rack-id ( x y -- x y rid )  over 10 + ;
: hundreds-place   100 /  10 mod ;
: cell-power ( x y -- power )
  rack-id *  grid-serial +  rack-id *
  hundreds-place  5 -  nip ;

: down ( x y n -- x y+n )  + ;
: right ( x y n -- x+n y )  rot + swap ;
0 value grid-point
: grow-cell ( x y n -- )
  3dup drop access to grid-point
  dup if dup 0 do
    3dup down i right cell-power  grid-point +!
    3dup right i down cell-power  grid-point +!
  loop then
  >r r@ down r> right cell-power  grid-point +! ;

: grow-all ( n -- )
  dup limit 1 do  dup limit 1 do
    dup i j rot grow-cell
  loop loop drop ;
: grow-range ( to from -- )  do  i grow-all  loop ;

0 value best-x
0 value best-y
: find-square ( n -- x y )
  1 1 access @ swap
  1 to best-x  1 to best-y
  dup limit 1 do  dup limit 1 do
    swap i j access @
    2dup < if  swap  j to best-x  i to best-y  then
    drop swap
  loop loop best-y best-x ;

1 value best-size
1 value best-x2
1 value best-y2
: find-grid
  1 to best-size
  erase-grid  0 grow-all  1 find-square access @
  12 2 do
    i 1- grow-all
    i find-square access @
    over > if  i to best-size  best-x to best-x2  best-y to best-y2  then
  loop best-size best-y2 best-x2 ;

: comma   [char] , emit ;
: .#  0 .r ;
: print-coord ( x y -- )  swap .# comma .# ;

erase-grid  3 0 grow-range  3 find-square print-coord cr
find-grid print-coord comma best-size .# cr
bye
