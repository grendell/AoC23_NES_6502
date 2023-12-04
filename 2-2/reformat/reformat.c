#include <stdint.h>
#include <stdio.h>
#include <string.h>

const uint8_t ASCII_STX = 3;
const uint8_t ASCII_ETX = 4;
const uint8_t ASCII_LF = 10;

int main(int argc, char ** argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s <input.txt> <output.bin>\n", argv[0]);
        return 1;
    }

    FILE * input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "failed to open %s\n", argv[1]);
        return 1;
    }

    FILE * output = fopen(argv[2], "wb");
    if (!output) {
        fprintf(stderr, "failed to create %s\n", argv[2]);
        fclose(input);
        return 1;
    }

    size_t w = fwrite(&ASCII_STX, sizeof(uint8_t), 1, output);
    if (w != 1) {
        fprintf(stderr, "failed to write %s\n", argv[2]);
        fclose(input);
        fclose(output);
        return 1;
    }

    const int BUFFER_SIZE = 4096;
    char buffer[BUFFER_SIZE];
    while (fgets(buffer, BUFFER_SIZE, input)) {
        char * newline = strchr(buffer, '\n');
        if (newline) {
            *newline = '\0';
        }

        size_t len = strlen(buffer);
        w = fwrite(buffer, sizeof(char), len, output);
        if (w != len) {
            fprintf(stderr, "failed to write %s\n", argv[2]);
            fclose(input);
            fclose(output);
            return 1;
        }

        w = fwrite(&ASCII_LF, sizeof(uint8_t), 1, output);
        if (w != 1) {
            fprintf(stderr, "failed to write %s\n", argv[2]);
            fclose(input);
            fclose(output);
            return 1;
        }
    }

    w = fwrite(&ASCII_ETX, sizeof(uint8_t), 1, output);
    if (w != 1) {
        fprintf(stderr, "failed to write %s\n", argv[2]);
        fclose(input);
        fclose(output);
        return 1;
    }

    fclose(input);
    fclose(output);
    return 0;
}