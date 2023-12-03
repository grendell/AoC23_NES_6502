AS = ca65
LD = ld65
AS_FLAGS =
LD_FLAGS = -C nes.cfg
OBJ = obj

2-1.nes: $(OBJ) $(OBJ)/2-1.o
	$(LD) $(LD_FLAGS) $(OBJ)/2-1.o -o 2-1.nes

$(OBJ)/2-1.o: 2-1.s 2-1.bin nes.cfg
	$(AS) $(AS_FLAGS) 2-1.s -o $(OBJ)/2-1.o

2-1.bin: reformat/reformat 2-1.txt
	reformat/reformat 2-1.txt 2-1.bin

reformat/reformat: reformat/reformat.c
	$(MAKE) -C reformat

$(OBJ):
	mkdir $(OBJ)

.PHONY: clean
clean:
	rm -rf $(OBJ) 2-1.bin 2-1.nes