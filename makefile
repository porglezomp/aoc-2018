all: day1

day1: day1.exe input/day1
	./day1.exe < input/day1

day1.exe: day1.asm
	nasm -f macho64 day1.asm -o day1.o
	ld -macosx_version_min 10.7.0 -lSystem -o $@ day1.o

clean:
	rm -f *.exe *.o
