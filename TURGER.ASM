
		Title	Trke, Almanca ve BOX karakter reten program. ATB
		.Model Small
		.Code
cseg		segment
		assume CS:CSEG,DS:CSEG
		org	100h


PRG_START:	jmp atb_basla

install 	db "Already$"

just_in		db "ATB: TURGER.COM$"

copyright	label byte
		db" installed.",24h
;---------------------------------------------------------------------

Old		dd	0
_shift		db	0

; scan kodlari

_SCAN	label	byte

_e	db	12h
_a	db	1eh
_s	db	1fh
_u	db	16h
_i	db	17h
_o	db	18h
_g	db	22h
_n	db	31h
_b	db	30h
_c	db	2eh

; boxing tools

box_t	db	52h,53h
	db	47h,48h,49h
	db	4bh,4ch,4dh
	db	4fh,50h,51h

; sub-boxing
box_t2	db	19h,1ah,1bh
	db	26h,27h,28h
	db	33h,34h,35h

_SIRA	dw	0			; # 2 XLT


; ascii kodlari

_ASCII	label byte

	db	89h,90h,84h,8eh,9fh,9eh,81h,9ah,8dh,98h,94h,99h,0a7h,0a6h
	db	0a4h,0a5h,0e1h,0e1h,87h,80h
; box
	db	196,205,179,186

	db	218,201,	194,203,	191,187
	db	195,204,	197,206,	180,185
	db	192,200,	193,202,	217,188

; sub-boxing
	db	213,214,	209,210,	184,183
	db	198,199,	216,215,	181,182
	db	212,211,	207,208,	190,189	

atb_basla:

	xor	ax,ax
	mov	ds,ax		
	mov	bx,ds:198h		;IF INTERRUPT IS NOT IN USE, SET IT!!
	or	bx,bx			; cause, there wont be any problem..
	jz	install_et

	push	cs
	pop	ds
	mov	dx,offset install
	call	ekrana
	mov	dx,offset copyright
	call	ekrana
	int	20h

install_et:				

	mov	word ptr ds:198h,1111h	;	ds = 0

	push	cs
	pop	ds

	mov	ax,3509h
	int	21h
	mov	cs:word ptr Old[0],bx
	mov	cs:word ptr Old[2],es

;	push	cs
;	pop	ds			; still, ds = cs

	mov	dx,offset New
	mov	ax,2509h
	int	21h

	mov	dx,offset just_in
	call	ekrana
	mov	dx,offset copyright	; this will be written always. 
	call	ekrana

	mov	dx,offset END_OF_PRG
	int	27h

ekrana	proc
	mov	ah,9
	int	21h
	ret
ekrana	endp

New	PROC
	sti
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es
	pushf
	cld

	mov	cs:word ptr _SIRA, offset _SIRA - offset _SCAN

	mov	cs:byte ptr _IRET,90h		; nop = 90h

	mov	ax,40h
	mov	ds,ax
	mov	bx,ds:17h
	test	bx,1000000000b
	jnz	pass_1
	jmp	cikis1

pass_1:
	mov	byte ptr cs:_SHIFT,0

	and	bx,01000011b
	or	bx,bx
	jz	pass_2
	
	mov	byte ptr cs:_SHIFT,1

pass_2:

	in	al,60h

	push	cs
	pop	es
	mov	di,offset	_SCAN
	mov	cx,word ptr cs:	_SIRA
	repnz	scasb
	jz	degistir
	jmp	cikis1

degistir:

	sub	word ptr cs:_SIRA,cx

	mov	cs:byte ptr _IRET,0CFh
	push	ax
	in	al,61h
	mov	ah,al
	or 	al,80h
	out	61h,al
	pop	ax
	mov	ah,al

	push	ax

	push	cs
	pop	ds
	mov	bx,offset	_ASCII
	mov	ax,ds:word ptr	_SIRA
	dec	al
	add	al,al
	xor	ah,ah
	add	ax,cs:word ptr	_SHIFT
	xlat

	pop	bx
	mov	ah,bh

	mov	dx,40h
	mov	ds,dx
	mov	bx,ds:1ch
	mov	si,bx		;si'de karakterin addresi saklandi
	add	bx,2
	cmp	bx,3eh
	jnz	ilk_donus
	mov	bx,1eh	
ilk_donus:
	cmp	bx,ds:1ah
	jz	cikis2

	mov	[si],ax
	mov	ds:1ch,bx


cikis2:	mov	al,20h
	out	20h,al


cikis1:
	popf
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

_IRET:	db	90h

	pushf
	call	cs:dword ptr Old

	iret

NEW	ENDP

END_OF_PRG:	nop

cseg		Ends
		End	PRG_START
;
; The aim and how to use.				
;	
;
; This program is written to fake Turkish, German and Boxing characters by
; using "LEFT ALT" -"key" combination..
; Such That:
; To get a Turkish  character, press simultaneously to 
;					"LEFT ALT"-"S"-"SHIFT"
; 		and if Caps Lock is setted, no need to "SHIFT"ing.
;
;
;	แ	=	LeftAlt-B	or  LeftAlt-B-SHIFT, if !caps setted.
;
;  ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;  ณ and for ีัธฦุติฯพำะฝวืถึาทษหปฬฮนศสผฺยฟรลดภมูฤณอบ characters use LALT ณ
;  ณ and KEYPAD or P{}L:"<>? DEL and INS characters...			  ณ
;  ณ									  ณ
;  ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;  All Available key fakes are 
;
;      แแ คฅ  ”  €  งฆ   ีัธ  ึาท ฺยฟ ษหป
;				     ฦุต  วืถ รลด ฬฮน  and of course ฤอณบ
;				     ิฯพ  ำะฝ ภมู ศสผ
;
; 								Written by ATB
;