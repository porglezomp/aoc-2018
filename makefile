latest: day4
all: day1 day2 day3 day4

day1: day1.exe input/day1
	./day1.exe < input/day1

day2: day2.ijs input/day2
	jcon day2.ijs

day3: day3.sql input/day3
	sqlite3 < day3.sql

day4: day4.awk input/day4
	sort input/day4 | awk -f day4.awk

day1.exe: day1.asm
	nasm -f macho64 day1.asm -o day1.o
	ld -macosx_version_min 10.7.0 -lSystem -o $@ day1.o

clean:
	rm -f *.exe *.o
