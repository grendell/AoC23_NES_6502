AS = ca65
LD = ld65
AS_FLAGS =
LD_FLAGS = -C nes.cfg
OBJ = obj

1-1.nes: $(OBJ) $(OBJ)/1-1.o
	$(LD) $(LD_FLAGS) $(OBJ)/1-1.o -o 1-1.nes

$(OBJ)/1-1.o: 1-1.s 1-1.bin nes.cfg
	$(AS) $(AS_FLAGS) 1-1.s -o $(OBJ)/1-1.o

1-1.bin: reformat/reformat 1-1.txt
	reformat/reformat 1-1.txt 1-1.bin

reformat/reformat: reformat/reformat.c
	$(MAKE) -C reformat

$(OBJ):
	mkdir $(OBJ)

.PHONY: clean
clean:
	rm -rf $(OBJ) 1-1.bin 1-1.nes