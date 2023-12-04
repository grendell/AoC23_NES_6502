CC = clang
LD = clang
CC_FLAGS = -O2 -Wall -Wextra -c
LD_FLAGS = -Wall -Wextra
OBJ = obj

reformat: $(OBJ) $(OBJ)/reformat.o
	$(CC) $(LD_FLAGS) $(OBJ)/reformat.o -o reformat

$(OBJ)/reformat.o: reformat.c
	$(CC) $(CC_FLAGS) reformat.c -o $(OBJ)/reformat.o

$(OBJ):
	mkdir $(OBJ)

.PHONY: clean
clean:
	rm -rf $(OBJ) reformat