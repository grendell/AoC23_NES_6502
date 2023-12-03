.segment "HEADER"
  .byte $4e, $45, $53, $1a ; iNES header identifier
  .byte $02                ; 2x 16KB PRG-ROM banks
  .byte $01                ; 1x  8KB CHR-ROM banks
  .byte $00                ; mapper 0, no save battery, and horizonal mirroring
  .byte $08                ; mapper 0, NES 2.0, and NES
  .byte $00                ; submapper 0 and mapper 0
  .byte $00                ; no MSB ROM sizes
  .byte $00                ; 0 bytes PRG-NVRAM, 0 bytes PRG-RAM
  .byte $00                ; 0 bytes CHR-RAM
  .byte $00                ; NTSC NES
  .byte $00                ; NES/Famicom
  .byte $00                ; no miscellaneous ROMs
  .byte $01                ; standard NES/Famicom controllers

.segment "VECTORS"
  .addr nmi, reset, 0

.segment "ZEROPAGE"
ptr: .res 2

NOT_FOUND = $ff
first: .res 1
last: .res 1
scratch: .res 1
total: .res 4
bcd_total: .res 6

.enum
  COMPUTING = 0
  READY = 1
  DISPLAYED = 2
.endenum
state: .res 1

.segment "CODE"
PPU_CTRL = $2000
PPU_MASK = $2001
PPU_STATUS = $2002
PPU_SCROLL = $2005
PPU_ADDR = $2006
PPU_DATA = $2007

DMC_FREQ = $4010
APU_FRAME_COUNTER = $4017

ASCII_STX = $03
ASCII_ETX = $04
ASCII_LF = $0a
ASCII_0 = $30
ASCII_9 = $39

input:
.incbin "1-1.bin"

.proc reset
  ; init
  sei                    ; ignore IRQs
  cld                    ; disable decimal mode
  ldx #$40
  stx APU_FRAME_COUNTER  ; disable APU frame IRQ
  ldx #$ff
  txs                    ; Set up stack
  inx                    ; now X = 0
  stx PPU_CTRL           ; disable NMI
  stx PPU_MASK           ; disable rendering
  stx DMC_FREQ           ; disable DMC IRQs

  ; clear vblank flag
  bit PPU_STATUS

  ; wait for first vblank
: bit PPU_STATUS
  bpl :-

  ; initialize cpu variables
  lda #0
  sta total
  sta total + 1
  sta total + 2
  sta total + 3

  sta bcd_total
  sta bcd_total + 1
  sta bcd_total + 2
  sta bcd_total + 3
  sta bcd_total + 4
  sta bcd_total + 5

  lda #COMPUTING
  sta state

  ; wait for second vblank
: bit PPU_STATUS
  bpl :-

  ; initialize background graphics
  ; set ppu address to palette entries
  lda #$3f
  sta PPU_ADDR
  lda #0
  sta PPU_ADDR

  ; store black for clear color
  lda #$0f
  sta PPU_DATA

  ; store white in the first background palette
  lda #$20
  sta PPU_DATA

  ; clear nametables
  ; set ppu address to first nametable
  lda #$20
  sta PPU_ADDR
  lda #0
  sta PPU_ADDR

  ; clear first nametable and attributes
  lda #0
  ldx #0
  ldy #4
: sta PPU_DATA
  inx
  bne :-

  dey
  bne :-

  ; reset scroll position
  lda #0
  sta PPU_SCROLL
  sta PPU_SCROLL
  sta PPU_MASK

  ; enable NMI
  lda #%10000000
  sta PPU_CTRL

  ; process input
  lda #<input
  sta ptr
  lda #>input
  sta ptr + 1

  ldy #0
  lda (ptr), y
  iny

  cmp #ASCII_STX
  beq read_line

  ; something has gone terribly wrong
  brk

read_line:
  lda #$ff
  sta first

read_next:
  lda (ptr), y
  iny

  bne :+
  inc ptr + 1

: cmp #ASCII_ETX
  bne :+

  jsr calc_bcd

  lda #READY
  sta state
  jmp done

: cmp #ASCII_LF
  bne :+

  lda first
  jsr mul10

  clc
  adc last

  jsr add_to_total
  jmp read_line

: jsr is_digit
  cpx #1
  bne read_next

  sec
  sbc #ASCII_0

  ldx first
  cpx #NOT_FOUND
  bne update_last

update_first:
  sta first

update_last:
  sta last
  jmp read_next

done:
  jmp done
.endproc

.proc nmi
  ; preserve processor status and a
  php
  pha

  ; clear vblank flag
  bit PPU_STATUS

  lda state
  cmp #READY
  bne done

  ; center answer
  lda #NOT_FOUND
  sta scratch

  ldx #0
center_loop:
  lda bcd_total, x
  beq :+

  stx scratch

: inx
  cpx #6
  bne center_loop

  lda scratch
  cmp #NOT_FOUND
  bne :+

  ; something has gone terribly wrong
  brk

: lda #$21
  sta PPU_ADDR

  lda #$cf
  sec
  sbc scratch
  sta PPU_ADDR

  ldx scratch
display_loop:
  lda bcd_total, x
  lsr
  lsr
  lsr
  lsr

  bne :+

  cpx scratch
  beq second_digit

: ora #$10
  sta PPU_DATA

second_digit:
  lda bcd_total, x
  and #$0f
  ora #$10
  sta PPU_DATA

  dex
  bpl display_loop

  ; reset scroll position
  lda #0
  sta PPU_SCROLL
  sta PPU_SCROLL

  ; enable background rendering
  lda #%00001000
  sta PPU_MASK

  lda #DISPLAYED
  sta state

done:
  ; restore a and processor status
  pla
  plp
  rti
.endproc

.proc is_digit
  cmp #ASCII_0
  bcc fail

  cmp #ASCII_9 + 1
  bcs fail

pass:
  ldx #1
  rts

fail:
  ldx #0
  rts
.endproc

.proc mul10
  ; x 2
  asl
  sta scratch

  ; x 8
  asl
  asl

  clc
  adc scratch

  rts
.endproc

.proc add_to_total
  clc
  adc total
  sta total
  bcc done

  inc total + 1
  bne done

  inc total + 2
  bne done

  inc total + 3

done:
  rts
.endproc

.proc calc_bcd
; https://en.wikipedia.org/wiki/Double_dabble

  ldy #32
iterate:
  ldx #5

check:
  lda bcd_total, x
  lsr
  lsr
  lsr
  lsr

  cmp #5
  bcc :+

  clc
  adc #3

  asl
  asl
  asl
  asl
  sta scratch

  lda bcd_total, x
  and #$0f
  ora scratch
  sta bcd_total, x

: lda bcd_total, x
  and #$0f

  cmp #5
  bcc :+

  clc
  adc #3
  sta scratch

  lda bcd_total, x
  and #$f0
  ora scratch
  sta bcd_total, x

: dex
  bpl check

shift:
  asl total
  rol total + 1
  rol total + 2
  rol total + 3

  rol bcd_total
  rol bcd_total + 1
  rol bcd_total + 2
  rol bcd_total + 3
  rol bcd_total + 4
  rol bcd_total + 5

  dey
  bne iterate

  rts
.endproc

.segment "CHARS"
; derived from https://gist.github.com/rothwerx/700f275d078b3483509f

  .byte %01111000
  .byte %11001100
  .byte %11011100
  .byte %11111100
  .byte %11101100
  .byte %11001100
  .byte %01111100
  .byte %00000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %00110000
  .byte %01110000
  .byte %00110000
  .byte %00110000
  .byte %00110000
  .byte %00110000
  .byte %11111100
  .byte %00000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111000
  .byte %11001100
  .byte %00001100
  .byte %00111000
  .byte %01100000
  .byte %11001100
  .byte %11111100
  .byte %00000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111000
  .byte %11001100
  .byte %00001100
  .byte %00111000
  .byte %00001100
  .byte %11001100
  .byte %01111000
  .byte %00000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %00011100
  .byte %00111100
  .byte %01101100
  .byte %11001100
  .byte %11111110
  .byte %00001100
  .byte %00011110
  .byte %00000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111100
  .byte %11000000
  .byte %11111000
  .byte %00001100
  .byte %00001100
  .byte %11001100
  .byte %01111000
  .byte %00000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %00111000
  .byte %01100000
  .byte %11000000
  .byte %11111000
  .byte %11001100
  .byte %11001100
  .byte %01111000
  .byte %00000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111100
  .byte %11001100
  .byte %00001100
  .byte %00011000
  .byte %00110000
  .byte %00110000
  .byte %00110000
  .byte %00000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111000
  .byte %11001100
  .byte %11001100
  .byte %01111000
  .byte %11001100
  .byte %11001100
  .byte %01111000
  .byte %00000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111000
  .byte %11001100
  .byte %11001100
  .byte %01111100
  .byte %00001100
  .byte %00011000
  .byte %01110000
  .byte %00000000
  .byte $00, $00, $00, $00, $00, $00, $00, $00