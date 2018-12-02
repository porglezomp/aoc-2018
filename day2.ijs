readfile =: 1!:1
print =: 1!:2&2

words =: <;._2 readfile < 'input/day2'

repeats =: [: +/"1 =
hasrep =: e. repeats

print [ (+/ > (3&hasrep) L: 0 words) * (+/ > (2&hasrep) L: 0 words)
exit 0
