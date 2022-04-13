.db "NES", $1A
.db $01
.db $01
.db $42
.dsb 9, $00

base $c000

enum $00
temp .dsb 1
temp2 .dsb 1
column .dsb 1
columnh .dsb 1
picturec .dsb 1
done .dsb 1
xscroll .dsb 1
yscroll .dsb 1
xcoarse .dsb 1
scnline .dsb 1
inarray .dsb 1
xscrolldec .dsb 1
yscrolldec .dsb 1
xscrollspeed .dsb 1
yscrollspeed .dsb 1
xscrollDspeed .dsb 1
yscrollDspeed .dsb 1
movewave .dsb 1
flags1 .dsb 1



.ende

WAVELENGTH = $38
STARTWAVE = $00
EFFECTLENGTH = $10



RESET:
sei
cld
ldx #$40
stx $4017
ldx #$ff
txs
inx
stx $2000
stx $2001
stx $4010

jsr vblankwait

clearmem:
lda #$00
sta $0000, x
sta $0100, x
sta $0200, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  
  STA $6000, x
  STA $6100, x
  STA $6200, x
  STA $6300, x
  STA $6400, x

lda #$fe
sta $0300, x
inx
bne clearmem
clearmemdone:

jsr vblankwait

lda #%10000000
sta $2000
lda #$18
sta $2001



createPallete:
lda $2002
lda #$3f
sta $2006
lda #$00
sta $2006
ldx #$00

paletteLoop:
lda palette, x
sta $2007
inx
cpx #$20
bne paletteLoop
paletteDone:


setNametables:
lda #$00
sta $a000
sta column
sta picturec
lda #$20
sta columnh
lda #$04
sta $2000
ldx #$00
ldy #$00

;initialize variables
lda #$00
sta xscroll
sta yscroll
sta xscrolldec
sta yscrolldec
sta xscrollspeed
sta yscrollspeed
sta xscrollDspeed
sta yscrollDspeed



lda #$84
sta $2000


forever:
jmp forever

;NMINMINMINMINMINMINMINMINMINMINMINMI
NMI:
lda #$84
sta $2000

ldx picturec
ldy #$00

lda done
bne NCend

lda columnh
sta $2006
lda column
sta $2006

jsr drawColumn


cpx #$10
bcc NCend
ldx #$00
lda column
cmp #$20
bne NCend
lda #$00
sta column
lda columnh
clc
adc #$04
sta columnh
cmp #$28
bcc NCend
inc done
NCend:
stx picturec

lda #$00
sta $2005
sta $2005
LDA #%10001000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  
  lda done
  beq NMIdone
  
bit flags1
bmi ++
lda xscrollDspeed
clc
adc #$08
sta xscrollDspeed
lda xscrollspeed
adc #$00
sta xscrollspeed
jmp speedToPos
++
lda xscrollDspeed
sec
sbc #$08
sta xscrollDspeed
lda xscrollspeed
sbc #$00
sta xscrollspeed
speedToPos:
lda xscrollspeed
cmp #$08
bcc +
lda flags1
eor #$80
sta flags1
+


lda xscrolldec
clc
adc xscrollDspeed
sta xscrolldec
lda xscroll
adc xscrollspeed
sta xscroll






lda movewave
sec
sbc #$01
cmp #WAVELENGTH
bcc +
clc
adc #WAVELENGTH
+
sta movewave

xScrollandCoarse:
lda xscroll
lsr
lsr
lsr
sta xcoarse


lda #EFFECTLENGTH
sta scnline

lda movewave
sta inarray



lda #STARTWAVE

sta $c000
sta $e001
cli
;setup, before it is called
sta $2006
sta $2005
and #$38
asl
asl
ora xcoarse
tay

ldx xscroll


- lda scnline
bne -
sei
sta $e000




NMIdone:



RTI

SCREENCUT:
stx $2005
sty $2006
sta $e000
lda #$00
inc scnline

bne +
ldx #$0c
- dex
bne -
sta $2006
sta $2005
sta $2005
sta $2006
RTI
+
sta $c001
sta $c000
sta $2006
lda scnline
clc
adc yscroll
ldx inarray
clc
adc wave1,x
and #$1f
sta $2005
and #$f8
asl
asl
ora xcoarse
tay
inx
txa
cmp #WAVELENGTH
bcc +
sec
sbc #WAVELENGTH
+
sta inarray
ldx xscroll
sta $e001

RTI


vblankwait:
bit $2002
bpl vblankwait
RTS
vblankwaitend:

drawColumn:
lda nametable,x
sta $2007
inx
txa
and #$03
cmp #$00
bne drawColumn
txa
sec
sbc #$04
tax
iny
cpy #$7
bcc drawColumn
txa
clc
adc #$04
tax
ldy #$00
sty $2007
sty $2007
inc column
bne +
inc columnh

+ RTS


palette:

.db $00, $16, $27, $18, $00, $16, $27, $18, $00, $16, $27, $18, $00, $16, $27, $18
.db $22, $16, $27, $18, $22, $16, $27, $18, $22, $16, $27, $18, $22, $16, $27, $18

nametable:
.hex 0 4 8 c 1 5 9 d 2 6 a e 3 7 b f

wave1:
.db $00, $01, $01, $02, $02, $03, $03, $04, $04, $04, $05, $05, $05, $05, $05, $05, $05, $05, $05, $04, $04, $04, $03, $03, $02, $02, $01, $01, $00, $ff, $ff, $fe, $fe, $fd, $fd, $fc, $fc, $fc, $fb, $fb, $fb, $fb, $fb, $fb, $fb, $fb, $fb, $fc, $fc, $fc, $fd, $fd, $fe, $fe, $ff, $ff


.pad $fffa
dw NMI
dw RESET
dw SCREENCUT


incbin "BigMario.nes"
incbin "BigMario.nes"