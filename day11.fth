0 value grid-serial
3 value grid-size
300 constant length

: rack-id ( x y -- x y rid )  over 10 + ;
: hundreds-place   100 /  10 mod ;
: cell-power ( x y -- power )
  rack-id *  grid-serial +  rack-id *
  hundreds-place  5 -  nip ;

\ Find the best chronal charge

: square-power ( x y -- power )
  0 swap dup grid-size + swap do
    over dup grid-size + swap do
      i j cell-power +
    loop
  loop nip ;

: 3max ( x1 i1 j1 x2 i2 j2 -- x? i? j? )
  5 pick 3 pick <
  if  5 roll 5 roll 5 roll  then 
  drop drop drop ;

: find-square ( grid-size -- )
  to grid-size
  0 0 0
  length grid-size -  1 do
    length grid-size -  1 do
      i j square-power  i j 3max
    loop
  loop swap ;

: main
  3 find-square
  0 .r [char] , emit 0 .r cr
  drop ;

9424 to grid-serial
main
bye

