readfile =: 1!:1
print =: 1!:2&2

split =: <;._2
words =: > split readfile < 'input/day2'

repeats =: [: +/"1 =
hasrep =: e. repeats

print [ (+/ > 3 hasrep"1 words) * (+/ > 2 hasrep"1 words)
exit 0
