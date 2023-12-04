AS = ca65
LD = ld65
AS_FLAGS =
LD_FLAGS = -C nes.cfg
OBJ = obj

2-2.nes: $(OBJ) $(OBJ)/2-2.o
	$(LD) $(LD_FLAGS) $(OBJ)/2-2.o -o 2-2.nes

$(OBJ)/2-2.o: 2-2.s 2-2.bin nes.cfg
	$(AS) $(AS_FLAGS) 2-2.s -o $(OBJ)/2-2.o

2-2.bin: reformat/reformat 2-2.txt
	reformat/reformat 2-2.txt 2-2.bin

reformat/reformat: reformat/reformat.c
	$(MAKE) -C reformat

$(OBJ):
	mkdir $(OBJ)

.PHONY: clean
clean:
	rm -rf $(OBJ) 2-2.bin 2-2.nes