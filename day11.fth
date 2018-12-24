0 value grid-serial
\ : text  ( delimiter -- )  pad 258 bl fill  word count pad swap  move ;
: rack-id ( x y -- x y rid )  over 10 + ;
: hundreds-place   100 /  10 mod ;
: cell-power ( x y -- power )
  rack-id *  grid-serial +  rack-id *
  hundreds-place  5 -  nip ;

\ Find the best chronal charge

300 constant length

\ variable grid  length length * cells allot
\ : access ( x y -- ptr )  length * +  grid + ;

: square-power ( x y -- power )
  0 swap dup 3 + swap do
    over dup 3 + swap do
      i j cell-power +
    loop
  loop nip ;

: 3max ( x1 i1 j1 x2 i2 j2 -- x? i? j? )
  5 pick 3 pick <
  if  5 roll 5 roll 5 roll  then 
  drop drop drop ;

: main ( grid-serial -- )
  to grid-serial
  0 0 0
  length 3 -  1 do
    length 3 -  1 do
      i j square-power  i j 3max
    loop
  loop
  rot drop swap
  0 .r [char] , emit 0 .r ;

\ 1 text  pad >number .
9424 main
bye

