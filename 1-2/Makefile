AS = ca65
LD = ld65
AS_FLAGS =
LD_FLAGS = -C nes.cfg
OBJ = obj

1-2.nes: $(OBJ) $(OBJ)/1-2.o
	$(LD) $(LD_FLAGS) $(OBJ)/1-2.o -o 1-2.nes

$(OBJ)/1-2.o: 1-2.s 1-2.bin nes.cfg
	$(AS) $(AS_FLAGS) 1-2.s -o $(OBJ)/1-2.o

1-2.bin: reformat/reformat 1-2.txt
	reformat/reformat 1-2.txt 1-2.bin

reformat/reformat: reformat/reformat.c
	$(MAKE) -C reformat

$(OBJ):
	mkdir $(OBJ)

.PHONY: clean
clean:
	rm -rf $(OBJ) 1-2.bin 1-2.nes