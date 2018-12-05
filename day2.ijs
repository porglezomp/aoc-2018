unwords =: <;._2
cart =: (<@,"0)/
repeats =: [: +/"1 =
hasrep =: e. repeats

words =: > unwords fread < 'input/day2'
distances =: +/"1 -. ="1/~ words
NB. Thanks to Lynn for helping me figure this one out
similar =: > {. (, distances = 1) # (, cart~ <"1 words)

echo (+/ > 3 hasrep"1 words) * (+/ > 2 hasrep"1 words)
NB. And also make this one nice instead of ugly
echo (=/>similar) # >{.similar
exit 0
