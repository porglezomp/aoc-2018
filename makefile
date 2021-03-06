latest: day11
all: day1 day2 day3 day4 day5 day6 day7 day8 day9 day10 day11

day1: day1.exe input/day1
	./day1.exe < input/day1

day2: day2.ijs input/day2
	jcon day2.ijs

day3: day3.sql input/day3
	sqlite3 < day3.sql

day4: day4.awk input/day4
	sort input/day4 | awk -f day4.awk

day5: day5.exe input/day5
	./day5.exe < input/day5

day6: day6.exe input/day6
	./day6.exe < input/day6

day7: day7.pl input/day7
	swipl day7.pl

day8: day8.cl input/day8
	sbcl --script day8.cl < input/day8

day9: day9.exe input/day9
	mono day9.exe < input/day9

# Chipmunk Basic http://www.nicholson.com/rhn/basic/
day10: day10.bas input/day10
	chipmunk day10.bas < input/day10

day11: day11.fth input/day11
	gforth $< < input/day11

day1.exe: day1.asm
	nasm -f macho64 day1.asm -o day1.o
	ld -macosx_version_min 10.7.0 -lSystem -o $@ day1.o

day5.exe: day5.hs
	ghc $< -o $@ -O2

day6.exe: day6.go
	go build -o $@ $<
  
day7.dot: day7

day7.svg: day7.dot
	dot $< -Tsvg > $@

day9.exe: day9.cs
	csc /o $<

clean:
	rm -f *.exe *.o *.hi
	rm -f day7.dot day7.svg
