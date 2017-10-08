%include "header_asm.h"
;%xdefine videoMemorySegment 0xA000
;%xdefine videoMemoryAddress 0xA0000
%xdefine videoMemorySegment 0xB800
%xdefine videoMemoryAddress 0xB8000
%xdefine NUMBER_OF_SECTOR_TO_READ 1400
%xdefine MAX_SECTOR_PER_READ_FOR_HARDDISK 1
%define DEBUG

;-------------------------------------------------------------------------------------------
; This file is loaded to 0x0:0x800 and execute
;-------------------------------------------------------------------------------------------

bits	16		;here is 0x8000
org		0x8000
	;mov		dx,0xffff
;kkk:
	;mov		al,'p'
	;out		dx,al
	;mov		al,'e'
	;out		dx,al
	;mov		al,10
	;out		dx,al
	;jmp		kkk


second_sector:
	mov     ax,0x0                ; boot loader start here , inital all the segment registers
	mov     ds,ax
	mov     fs,ax
	mov     ss,ax
	mov		ax,0x9000
	mov		es,ax
	mov     sp,0x3000

	mov     bp,pmsetup_str
	mov     cx,pmsetup_str_end-pmsetup_str
	mov     dl,0xf
	mov     al,1
	mov     bl,0
	call    print_str

;-------------------------------------------------------------------------------------------
; Check memory size
;-------------------------------------------------------------------------------------------
	mov	ax,0xe801
	int	0x15
	mov     [es:MEMSIZE],bx

;----------------------------------------------------------------------------------
; Set Video Mode
;----------------------------------------------------------------------------------
	;mov     ax,103                        ;set text mode 3, just used to clear screen
    ;int     0x10                         ;do it
	;mov	ax,0x4f02
	;mov	bx,0x100
	;int	0x10

;-------------------------------------------------------------------------------------------
; Check VESA
;-------------------------------------------------------------------------------------------
	mov		ax,OS_DATA_AREA_SEGMENT
	mov     es,ax
	mov		di,VESA_BUFFER
	mov		ax,0x4f00
	int		0x10

	cmp		di,VESA_BUFFER
	je		go1
	
	mov     bp,wrong1
	mov     cx,wrong1_end-wrong1
	mov     dl,0xf  
	mov     al,2
	mov     bl,0    
	call    print_str
vesa_detect_error:		jmp	vesa_detect_error
go1:

	cmp	ax,0x004f
	je	have_vbe
	mov	byte [es:VBE],0
	jmp	finish_vbe_checking
have_vbe:

	mov	byte [es:VBE],1

	;pointer to OEM name
;	xor	eax,eax
;	mov	ax,[es:VESA_BUFFER+8]  ; segment
;	xor	ebx,ebx
;	mov	bx,[es:VESA_BUFFER+6]  ; offset
;	mov	dword [es:VESA_BUFFER+6],0
;	shl	eax,4
;	add	eax,ebx
;	mov	[es:VESA_BUFFER+6],eax


	;pointer to list of supported VESA and OEM video modes
;	xor     eax,eax
;        mov     ax,[es:VESA_BUFFER+0x10]  ; segment
;        xor     ebx,ebx
;        mov     bx,[es:VESA_BUFFER+0xe]  ; offset
;        mov     dword [es:VESA_BUFFER+0xe],0
;	shl     eax,4
;        add     eax,ebx
;        mov     [es:VESA_BUFFER+0xe],eax

	;count how many vesa mode
	xor	cx,cx	;number of vesa mode will stored in CX
	push	ds
	mov	ds,[es:VESA_BUFFER+0x10]
;jmp	end_count_vesa_mode
	mov	si,[es:VESA_BUFFER+0xe]
repease_count_vesa:
	mov	bx,[ds:si]
	inc	si
	inc	si
	cmp	bx,0xffff
	je	end_count_vesa_mode
	inc	cx
	jmp	repease_count_vesa;
end_count_vesa_mode:
	mov	[es:VESA_NUMBER_OF_MODE],cx
	pop	ds
	;end count how many vesa mode

	;fill in VESA mode buffer
	;----------------------------------------------------------------
	;Bitfields for VESA/VBE video mode number:
	;Bit(s)  Description     (Table 04082)
	;15     preserve display memory on mode change
	;14     (VBE v2.0+) use linear (flat) frame buffer
	;13     (VBE/AF 1.0P) VBE/AF initializes accelerator hardware
	;12     reserved for VBE/AF
	;11     (VBE v3.0) user user-specified CRTC refresh rate values
	;10-9   reserved for future expansion
	;8-0    video mode number (0xxh are non-VESA modes, 1xxh are VESA-defined)
	;----------------------------------------------------------------
	push	ds
	mov     ds,[es:VESA_BUFFER+0x10]
	mov	si,[es:VESA_BUFFER+0xe]
	mov	di,VESA_MODE
	mov     cx,[es:VESA_NUMBER_OF_MODE]
again1:
	mov	bx,[ds:si]
	;modeNumber
	mov	[es:di],bx
	and	word [es:di],0x1FF;

	;reservedforFutureExpansion
	add	di,2
	mov	[es:di],bh
	shr	byte [es:di],1
	and	byte [es:di],00000011b

	;userSpecifiedCRTCrefreshRateValuesbool	
	add	di,1
	mov	[es:di],bh
	shr     byte [es:di],3
	and     byte [es:di],00000001b

	;reservedForVBE
	add     di,1
    mov     [es:di],bh
    shr     byte [es:di],4
	and     byte [es:di],00000001b

	;initializesAcceleratorHardware
	add     di,1    
    mov     [es:di],bh
    shr     byte [es:di],5
	and     byte [es:di],00000001b

	;useLinearFrameBuffer
	add     di,1
    mov     [es:di],bx
    shr     byte [es:di],6
	and     byte [es:di],00000001b

	;preserveDisplayMemoryOnModeChange
	add     di,1
    mov     [es:di],bh
    shr     byte [es:di],7
    and     byte [es:di],00000001b

	add	di,1
	add	si,2
	loop	again1
	pop	ds
	;end fill in VESA mode buffer

	;fill in VESA mode information
	;-----------------------------------------------------------------------------------------
	;Format of VESA SuperVGA mode information:
	;Offset  Size    Description     (Table 00079)
	;00h    WORD    mode attributes (see #00080)
	;02h    BYTE    window attributes, window A (see #00081)
	;03h    BYTE    window attributes, window B (see #00081)
	;04h    WORD    window granularity in KB
	;06h    WORD    window size in KB
	;08h    WORD    start segment of window A (0000h if not supported)
	;0Ah    WORD    start segment of window B (0000h if not supported)
	;0Ch    DWORD   -> FAR window positioning function (equivalent to AX=4F05h)
	;10h    WORD    bytes per scan line
	;---remainder is optional for VESA modes in v1.0/1.1, needed for OEM modes---
	;12h    WORD    width in pixels (graphics) or characters (text)
	;14h    WORD    height in pixels (graphics) or characters (text)
	;16h    BYTE    width of character cell in pixels
	;17h    BYTE    height of character cell in pixels
	;18h    BYTE    number of memory planes
	;19h    BYTE    number of bits per pixel
	;1Ah    BYTE    number of banks
	;1Bh    BYTE    memory model type (see #00082)
	;1Ch    BYTE    size of bank in KB
	;1Dh    BYTE    number of image pages (less one) that will fit in video RAM
	;1Eh    BYTE    reserved (00h for VBE 1.0-2.0, 01h for VBE 3.0)
	;---VBE v1.2+ ---
	;1Fh    BYTE    red mask size
	;20h    BYTE    red field position
	;21h    BYTE    green mask size
	;22h    BYTE    green field size
	;23h    BYTE    blue mask size
	;24h    BYTE    blue field size
	;25h    BYTE    reserved mask size
	;26h    BYTE    reserved mask position
	;27h    BYTE    direct color mode info
	;bit 0:Color ramp is programmable
	;bit 1:Bytes in reserved field may be used by application
	;---VBE v2.0+ ---
	;28h    DWORD   physical address of linear video buffer
	;2Ch    DWORD   pointer to start of offscreen memory
	;30h    WORD    KB of offscreen memory
	;---VBE v3.0 ---
	;32h    WORD    bytes per scan line in linear modes
	;34h    BYTE    number of images (less one) for banked video modes
	;35h    BYTE    number of images (less one) for linear video modes
	;36h    BYTE    linear modes:Size of direct color red mask (in bits)
	;37h    BYTE    linear modes:Bit position of red mask LSB (e.g. shift count)
	;38h    BYTE    linear modes:Size of direct color green mask (in bits)
	;39h    BYTE    linear modes:Bit position of green mask LSB (e.g. shift count)
	;3Ah    BYTE    linear modes:Size of direct color blue mask (in bits)
	;3Bh    BYTE    linear modes:Bit position of blue mask LSB (e.g. shift count)
	;3Ch    BYTE    linear modes:Size of direct color reserved mask (in bits)
	;3Dh    BYTE    linear modes:Bit position of reserved mask LSB
	;3Eh    DWORD   maximum pixel clock for graphics video mode, in Hz
	;42h 190 BYTEs  reserved (0)
	;-----------------------------------------------------------------------------------------

	push	ds
	mov     cx,[es:VESA_NUMBER_OF_MODE]
	mov     ds,[es:VESA_BUFFER+0x10]
	mov     si,[es:VESA_BUFFER+0xe]
    mov     di,VESA_MODE_INFORMATIONS
again2:
	push	cx
	mov	ax,0x4F01
        mov     cx,[ds:si]
	int	0x10
	pop	cx
	add	di,256
	add	si,2

	loop	again2
	pop	ds
	;end fill in VESA mode information

	;-------------------------------------------------------------------------------------
	; rewrite the real mode address (segment:offset) into linear address
	;-------------------------------------------------------------------------------------
	xor     eax,eax
	mov     ax,[es:VESA_BUFFER+8]  ; segment
	xor     ebx,ebx
	mov     bx,[es:VESA_BUFFER+6]  ; offset
	mov     dword [es:VESA_BUFFER+6],0
	shl     eax,4
	add     eax,ebx
	mov     [es:VESA_BUFFER+6],eax


	;pointer to list of supported VESA and OEM video modes
	xor     eax,eax
	mov     ax,[es:VESA_BUFFER+0x10]  ; segment
	xor     ebx,ebx
	mov     bx,[es:VESA_BUFFER+0xe]  ; offset
	mov     dword [es:VESA_BUFFER+0xe],0
	shl     eax,4
	add     eax,ebx
	mov     [es:VESA_BUFFER+0xe],eax



finish_vbe_checking:
;-------------------------------------------------------------------------------------------
; End Check VESA
;-------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------
; Check Harddisk parameters
;-------------------------------------------------------------------------------------------
	push	es
	push	di
	xor 	ax,ax
	mov	es,ax
	xor	di,di
	mov	ah,0x8
	mov	dl,0x80
	int	0x13
	xor	eax,eax
	mov	eax,es
	shl	eax,4
	add	ax,di

	pop	di
	pop	es
	mov	[es:DRIVE_PARAMETER_TABLE],eax
	mov	[es:DRIVE_TYPE],bl
	mov	[es:MAX_CYLINDER],ch
	mov	bl,cl
	shr	bl,6
	mov	[es:MAX_CYLINDER+1],bl
	mov	[es:MAX_HEAD],dh
	and	cl,111111b
	mov	[es:MAX_SECTOR],cl
	mov	[es:NUMBER_OF_DRIVE],dl

;-------------------------------------------------------------------------------------------
; End Check Harddisk parameters
;-------------------------------------------------------------------------------------------

%ifdef	DEBUG
	mov		bp,a20_str
	mov		dl,0xf
	mov		cx,a20_str_end-a20_str
	mov		al,2
	mov		bl,0
	call	print_str
%endif

	Call	EnableA20


;--------------------------- Initialize protected mode---------------------------------------

	mov     ax,cs
	movzx	eax,ax				;clear high word
	shl		eax,4				;make a	physical address
	add		eax,GDT				;calculate physical address of GDT
	mov		[gdt_start+2],eax


	;mov	ax,cs				;get 32-bit code segment into AX
	;movzx	eax,ax				;clear high word
	;shl	eax,4				;make a	physical address
	;add	eax,IDT				;calculate physical address of IDT
	;mov	[idt_start+2],eax;

	cli		;disable interrupts

	;mov	al, 0x20
	;out	0x20, al

	;mov	al,0x11
	;out	0x20,al
	;out 0xA0,al				; don't do this; unless you reprogram the 2nd 8259 too

	;mov	al,0x10				; IRQ0-IRQ7 <-- interrupt number
	;out	0x21,al

	;mov	al,4
	;out	0x21,al

	;mov	al,1
	;out	0x21,al

	;mov	al,0xFd				; IRQ0 (timer) and IRQ1 (keyboard)
	;out	0x21,al
	;sti

	mov	eax,gdt_start
	lgdt	[gdt_start]			;load	GDT register
;	lidt	[idt_start]			;load	IDT register

	mov	eax,00000000000000000000000000010001b
	mov	cr0,eax				;after this we are in Protected Mode!
	jmp	flush
flush:
	db	0eah				;opcode for far jump (to set CS correctly)
	dw	start32,OS_CODE_SELECTOR

;-------------------------------- Enable A20 -------------------------------------------------------------

	enablea20kbwait:		;wait for safe to write to 8042
	xor	cx,cx			;loop a maximum of FFFFh times
	enablea20kbwaitl0:
	jmp	short $+2		;these three jumps are inserted to wait some clockcycles
	jmp	short $+2		;for the port to settle down
	jmp	short $+2
	in	al,0x64			;read 8042 status
	test	al,2			;buffer full? zero-flag is set if bit 2 of 64h is not set
	loopnz	enablea20kbwaitl0	;if yes (bit 2 of 64h is set), loopuntil cx=0
	ret

;while the above loop is executing keyboard interrupts will occur which will empty the buffer
;so be sure to have interrupts still enabled when you execute this code

enablea20test:				;test for enabled A20
	mov	al,byte [fs:0]		;get byte from 0:0
	mov	ah,al			;preserve old byte
 	not	al			;modify byte
	xchg	al,byte [gs:0x10]	;put modified byte to 0ffffh:10h
					;which is either 0h or 100000h depending on the a20 state
	cmp	ah,byte [fs:0]		;set zero if byte at 0:0 equals preserved value
					;which means a20 is enabled
	mov	[gs:10h],al			;put back old byte at 0ffffh:10h
	ret				;return, zeroflag is set if A20 enabled

	; if the preserve byte is equal to 0:0 still , then a20 is enabled
	; if it is not (equal to the modified byte) , then a20 still disable

EnableA20:				;hardware enable gate A20 (entry point of routine

	xor	ax,ax			;set A20 test segments 0 and 0ffffh
	mov	fs,ax			;fs=0000h
	dec	ax
	mov	gs,ax			;gs=0ffffh

	call	enablea20test		;is A20 already enabled?
	jz	short	enablea20done		;if yes (zf is set), done

;if the system is PS/2 then bit 2 of port 92h (Programmable Option Select)
;controls the state of the a20 gate

	in	al,0x92			;PS/2 A20 enable
	or	al,2			;set bit 2 without changing the rest of al
	jmp	short $+2		;Allow port to settle down
	jmp	short $+2
	jmp	short $+2
	out	92h,al			;enable bit 2 of the POS
	call	enablea20test		;is A20 enabled?
	jz	short	enablea20done	;if yes, done

	call	enablea20kbwait		;AT A20 enable using the 8042 keyboard controller
					;wait for buffer empty (giving zf set)
	jnz	short	enablea20f0	;if failed to clear buffer jump

	mov	al,0xd1			;keyboard controller command 01dh (next byte written to
	out	0x64,al			;60h will go to the 8042 output port

	call	enablea20kbwait		;clear buffer and let line settle down
	jnz	short	enablea20f0		;if failed to clear buffer jump

	mov	al,0xdf			;write 11011111b to the 8042 output port 
					;(bit 2 is anded with A20 so we should set that one) 
	out	0x60,al

	call	enablea20kbwait		;clear buffer and let line settle down

enablea20f0:				;wait for A20 to enable
	mov	cx,0x800		;do 800h tries

enablea20l0:
	call	enablea20test		;is A20 enabled?
	jz	enablea20done		;if yes, done

	in	al,0x40			;get current tick counter (high byte)
	jmp	short $+2
	jmp	short $+2
	jmp	short $+2
	in	al,0x40			;get current tick counter (low byte)
	mov	ah,al			;save low byte of clock in ah

enablea20l1:				;wait a single tick
	in	al,0x40			;get current tick counter (high byte)
	jmp	short $+2
	jmp	short $+2
	jmp	short $+2
	in	al,0x40			;get current tick counter (low byte)
	cmp	al,ah			;compare clocktick to one saved in ah
	je	enablea20l1			;if equal wait a bit longer

	loop	enablea20l0		;wait a bit longer to give a20 achance to get enabled
	stc				;a20 hasn't been enabled so setcarry to indicate failure
	ret				;return to caller
enablea20done:
	clc				;a20 has been enabled succesfully so clear carry
	ret				;return to caller

;-------------------------------- End of Enable A20 ------------------------------------------------------

%ifdef	DEBUG
print_str:              ;bp = string offset, dl = attri, cx = count ,al = row, bl = column
        xor     ah,ah
        mov     dh,160
        mul     dh      
        push    ax      ; finish cal row*160

        xor     bh,bh
        mov     ax,bx
        mov     dh,2    
        mul     dh      ; finish cal col*2
        pop     bx
        add     ax,bx   ; ax=row*160+col*2
        mov     bx,ax   ; save ax to bx

        push    es
        mov     ax,videoMemorySegment
        mov     es,ax

repeat: mov     ah,[ds:bp]
        mov     [es:bx],ah
        inc     bx
        mov     [es:bx],dl
        inc     bx
        inc     bp
        loop    repeat
        pop     es
        ret
%endif


%ifdef	DEBUG

a20_str	db	'Enable A20'
a20_str_end

initgdt_str db	'Initialize GDT'
initgdt_str_end

initidt_str	db	'Initialize IDT'
initidt_str_end

epe_str     db      'Enable Protected Mode'
epe_str_end
%endif

bits	  32

;---------------------------------------------------------------------------------------------------------
;    GDT
;---------------------------------------------------------------------------------------------------------

gdt_start	dw	GDT_END-GDT-1,0,0

align	8

GDT:
dummy_descriptor	dw	0
			dw	0
			db	0
			db	0
			db	0
			db	0

os_code_entry		dw	0xffff
			dw	0000
			db	00
			db	0x9a
			db	0xcf
			db	00

os_data_entry		dw      0xffff
			dw      0000
			db      00
			db      10010010b
			db      11001111b
			db      00

GDT_END:

DUMMY_SELECTOR		equ	0x0
OS_CODE_SELECTOR	equ	0x8
OS_DATA_SELECTOR	equ	0x10


;--------------------------------------------------------------------------------------------
; Protected mode start here
;--------------------------------------------------------------------------------------------
start32:
	mov     ax,0x10
	mov     ds,ax
	mov     es,ax
	mov     fs,ax
	mov     gs,ax
	mov     ss,ax

	;mov     esp,0x18fffff
	mov     esp,KERNEL_END
	;mov	esp,interruptd_end+0x4000
	xor	eax,eax
	xor	ebx,ebx
	xor	ecx,ecx
	xor	edx,edx
	xor	esi,esi
	xor	edi,edi
	xor	ebp,ebp

	mov	byte	[ds:videoMemoryAddress],'0'
	inc    byte [ds:videoMemoryAddress]

;-------------------- check memory size ------------------------------------------------------
;	mov	eax,0xefffffff
;check_memory_size_loop:
;	mov	byte [ds:eax],0xab
;	cmp	byte [ds:eax],0xab
;	je	finish_check_memory_size
;	cmp	eax,0xfffff
;	je	finish_check_memory_size
;	sub	eax,0x100000
;	;dec	eax
;	jmp	check_memory_size_loop
;finish_check_memory_size:
;	inc	eax
;	mov	[ds:0x50100],eax


;	mov	eax,0x1fffff
;check_memory_size_loop:
;	mov	bh,[ds:eax]
;	mov	byte [ds:eax],0xab
;	mov	bl,[ds:eax]
;	mov	[es:eax],bh
;	add	eax,0x100000
;	cmp	bl,0xab
;	je	check_memory_size_loop

;	sub	eax,0x100000
;	sub	eax,0x100000
;	inc	eax
;	mov	[ds:MEMSIZE],eax

	inc    byte [ds:videoMemoryAddress]
;-------------------------- Load kernel ---------------------------------
;
;        mov     esi,kernel               ;es:di <- ds:si
;        mov     edi,KERNEL
;        mov     ecx,kernel_image_end-kernel
;        cld
;next_load_kernel:
;        lodsb
;        stosb
;        loop    next_load_kernel

;-------------------------- Load plib ----------------------------------

;	mov     esi,plib               ;es:di <- ds:si
;        mov     edi,PLIB
;        mov     ecx,plib_end-plib
;        cld
;next_load_plib:
;        lodsb
;        stosb
;        loop    next_load_plib


;-------------------------- Load timer ------------------------------
                                                                                                                             
        mov     esi,timer_offset               ;es:di <- ds:si
        mov     edi,TIMER
        mov     ecx,timer_offset_end-timer_offset
        cld
next_load_timer:
        lodsb
        stosb
        loop    next_load_timer
;-------------------------- Load keyboard ------------------------------
                                                                                                                             
        mov     esi,keyboard_offset              ;es:di <- ds:si
        mov     edi,KEYBOARD
        mov     ecx,keyboard_offset_end-keyboard_offset
        cld
next_load_keyboard:
        lodsb
        stosb
        loop    next_load_keyboard

;-------------------------- load interrupt 0 ------------------------------

        mov     esi,interrupt0               ;es:di <- ds:si
        mov     edi,INTERRUPT0
        mov     ecx,interrupt0_end-interrupt0
        cld
next_load_interrupt0:
        lodsb
        stosb
        loop    next_load_interrupt0

;-------------------------- load interrupt 1 ------------------------------

        mov     esi,interrupt1               ;es:di <- ds:si
        mov     edi,INTERRUPT1
        mov     ecx,interrupt1_end-interrupt1
        cld
next_load_interrupt1:
        lodsb
        stosb
        loop    next_load_interrupt1

;-------------------------- load interrupt 2 ------------------------------

        mov     esi,interrupt2               ;es:di <- ds:si
        mov     edi,INTERRUPT2
        mov     ecx,interrupt2_end-interrupt2
        cld
next_load_interrupt2:
        lodsb
        stosb
        loop    next_load_interrupt2


;-------------------------- load interrupt 3 ------------------------------

        mov     esi,interrupt3               ;es:di <- ds:si
        mov     edi,INTERRUPT3
        mov     ecx,interrupt3_end-interrupt3
        cld
next_load_interrupt3:
        lodsb
        stosb
        loop    next_load_interrupt3

;-------------------------- load interrupt 4 ------------------------------

        mov     esi,interrupt4               ;es:di <- ds:si
        mov     edi,INTERRUPT4
        mov     ecx,interrupt4_end-interrupt4
        cld
next_load_interrupt4:
        lodsb
        stosb
        loop    next_load_interrupt4

;-------------------------- load interrupt 5 ------------------------------

        mov     esi,interrupt5               ;es:di <- ds:si
        mov     edi,INTERRUPT5
        mov     ecx,interrupt5_end-interrupt5
        cld
next_load_interrupt5:
        lodsb
        stosb
        loop    next_load_interrupt5

;-------------------------- load interrupt 6 ------------------------------

        mov     esi,interrupt6               ;es:di <- ds:si
        mov     edi,INTERRUPT6
        mov     ecx,interrupt6_end-interrupt6
        cld
next_load_interrupt6:
        lodsb
        stosb
        loop    next_load_interrupt6

;-------------------------- load interrupt 7 ------------------------------

        mov     esi,interrupt7               ;es:di <- ds:si
        mov     edi,INTERRUPT7
        mov     ecx,interrupt7_end-interrupt7
        cld
next_load_interrupt7:
        lodsb
        stosb
        loop    next_load_interrupt7


;-------------------------- load interrupt 8 ------------------------------
        mov     esi,interrupt8               ;es:di <- ds:si
        mov     edi,INTERRUPT8
        mov     ecx,interrupt8_end-interrupt8
        cld
next_load_interrupt8:
        lodsb
        stosb
        loop    next_load_interrupt8
;-------------------------- load interrupt 9 ------------------------------

        mov     esi,interrupt9               ;es:di <- ds:si
        mov     edi,INTERRUPT9
        mov     ecx,interrupt9_end-interrupt9
        cld
next_load_interrupt9:
        lodsb
        stosb
        loop    next_load_interrupt9

;-------------------------- load interrupt a ------------------------------

        mov     esi,interrupta               ;es:di <- ds:si
        mov     edi,INTERRUPTA
        mov     ecx,interrupta_end-interrupta
        cld
next_load_interrupta:
        lodsb
        stosb
        loop    next_load_interrupta

;-------------------------- load interrupt b ------------------------------

        mov     esi,interruptb               ;es:di <- ds:si
        mov     edi,INTERRUPTB
        mov     ecx,interruptb_end-interruptb
        cld
next_load_interruptb:
        lodsb
        stosb
        loop    next_load_interruptb

;-------------------------- load interrupt c ------------------------------

        mov     esi,interruptc               ;es:di <- ds:si
        mov     edi,INTERRUPTC
        mov     ecx,interruptc_end-interruptc
        cld
next_load_interruptc:
        lodsb
        stosb
        loop    next_load_interruptc

;-------------------------- load interrupt d ------------------------------

        mov     esi,interruptd               ;es:di <- ds:si
        mov     edi,INTERRUPTD
        mov     ecx,interruptd_end-interruptd
        cld
next_load_interruptd:
        lodsb
        stosb
        loop    next_load_interruptd



;--------------------------- Map PT0 0-4MB ---------------------------

;	mov     edi,PT0			;es:di <- ds:si
;	mov     eax,3
;	mov     ecx,1024
;InitPt_4MB:
;	stosd
;	add     eax,1000h
;	loop    InitPt_4MB

;	mov     eax,PD0		; PD0 is point to PT0, now move the addr of PT0 to PD0
;        mov     ebx,PT0+3	; 3 is the page table attribute
;        mov     [eax],ebx

;---------------------------- Map PT1 4-8MB -----------------------


;	mov     edi,PT1			; es:di <- ds:si 
;        mov     eax,0x400003		; 0x400003 = (4096*1024)+3
;        mov     ecx,1024
;InitPt_8MB:
;        stosd   
;        add     eax,1000h
;        loop    InitPt_8MB

;        mov     eax,PD0+4	; map PT1 into PD0[1]
;        mov     ebx,PT1+3        ; 3 is the page table attribute
;        mov     [eax],ebx

;---------------------------- Map PT2 8-12MB -----------------------

;        mov     edi,PT2                  ;es:di <- ds:si
;        mov     eax,0x800003		; 0x800003 = 0x400000+(4096*1024)+3
;        mov     ecx,1024
;InitPt_12MB:
;        stosd  
;        add     eax,1000h
;        loop    InitPt_12MB

;        mov     eax,PD0+8		; map Pt2 into PD0[2]
;        mov     ebx,PT2+3        ; 3 is the page table attribute
;        mov     [eax],ebx

;---------------------------- Map PT3 12-16MB -----------------------

;        mov     edi,PT3                  ;es:di <- ds:si
;        mov     eax,0xc00003            ; 0xc00003 = 0x800000+(4096*1024)+3
;        mov     ecx,1024
;InitPt_16MB:
;        stosd
;        add     eax,1000h
;        loop    InitPt_16MB

;        mov     eax,PD0+12               ; map Pt2 into PD0[2]
;        mov     ebx,PT3+3        ; 3 is the page table attribute
;        mov     [eax],ebx

;---------------------------- Map PT4 20MB -----------------------

;        mov     edi,PT4                  ;es:di <- ds:si
;        mov     eax,0x1000003            ; 0x1000003 = 0xc00000+(4096*1024)+3
;        mov     ecx,1024
;InitPt_20MB:
;        stosd
;        add     eax,1000h
;        loop    InitPt_20MB

;        mov     eax,PD0+16               ; map Pt2 into PD0[2]
;        mov     ebx,PT4+3        ; 3 is the page table attribute
;        mov     [eax],ebx

;---------------------------- Map PT5 24MB -----------------------

;        mov     edi,PT5                  ;es:di <- ds:si
;        mov     eax,0x1400003            ; 0x1400003 = 0x1000000+(4096*1024)+3
;        mov     ecx,1024
;InitPt_24MB:
;        stosd
;        add     eax,1000h
;        loop    InitPt_24MB

;        mov     eax,PD0+20               ; map Pt2 into PD0[2]
;        mov     ebx,PT5+3        ; 3 is the page table attribute
;        mov     [eax],ebx

;---------------------------- Map PT5 28MB -----------------------

;        mov     edi,PT6                  ;es:di <- ds:si
;        mov     eax,0x1800003            ; 0x1800003 = 0x1400000+(4096*1024)+3
;        mov     ecx,1024
;InitPt_28MB:
;        stosd
;        add     eax,1000h
;        loop    InitPt_28MB

;        mov     eax,PD0+24               ; map Pt2 into PD0[2]
;        mov     ebx,PT6+3        ; 3 is the page table attribute
;        mov     [eax],ebx

;---------------------------- Map PT5 32MB -----------------------

;        mov     edi,PT7                  ;es:di <- ds:si
;        mov     eax,0x1C0003		; 0x1C0003 = 0x1800003+(4096*1024)+3
;        mov     ecx,1024
;InitPt_32MB:
;        stosd
;        add     eax,1000h
;        loop    InitPt_32MB

;        mov     eax,PD0+28               ; map Pt2 into PD0[2]
;        mov     ebx,PT7+3        ; 3 is the page table attribute
;        mov     [eax],ebx


;------------------------- End mapping PD/PT -------------------

	inc    byte [ds:videoMemoryAddress]

;	mov     eax,PD0
;	mov     cr3,eax

;	mov     eax,cr0
;	or      eax,80000000h
	;mov     cr0,eax			; Paging is on now

	;mov	al,0xfe			; enable timer, irq0
	;out	0x21,al

	;cli

	;mov     ax,OS_TSS_SELECTOR
	;ltr     ax

	;in	al,0x21
	;mov	al,0xfc
	;out	0x21,al
	;mov	al,0x20
	;out	0x20,al

	;in      al,0xa1
	;mov     al,0xff
	;out     0xa1,al
	;mov     al,0x20
	;out     0xa0,al

	;sti


sched:
	;int 8
	;int 9
	;call	0x1800009
	call	readKernel
	call	KERNEL
	;inc	byte [ds:videoMemoryAddress]

	inc     byte [ds:videoMemoryAddress]	
	;int	8
	;int	9


	;jmp    TASK1_SELECTOR:0
        ;mov    al,0x20
        ;out     0x20,al
        ;mov    byte [task1_tss_entry+5],0x89           ; clear busy bit

        ;jmp     TASK2_SELECTOR:0
        ;mov     al,0x20
        ;out     0x20,al
        ;mov     byte [task2_tss_entry+5],0x89          ; clear busy bit


	;jmp	KEYBOARD_TSS_SELECTOR:0x800000
	
	jmp	sched

; read harddisk subroutine
readKernel:
	mov		cx,NUMBER_OF_SECTOR_TO_READ
repeat_harddisk_read:
	push	cx

	mov		al, 1
	mov		dx, 0x1f2
	out		dx, al

	mov		bx, [lba]

	mov		al, bl
	mov		dx, 0x1f3
	out		dx, al

	mov		al, bh
	mov		dx, 0x1f4
	out		dx, al

	mov		al, 0
	mov		dx, 0x1f5
	out		dx, al

	mov		al, 0xe0 ; drive number
	mov		dx, 0x1f6
	out		dx, al

	mov		al, 0x20
	mov		dx, 0x1f7
	out		dx, al

wait_for_harddisk_read_all_sectors:
	mov		dx, 0x1f7
	in		al, dx
	and		al, 0x8
	cmp		al, 0x8
	jne		wait_for_harddisk_read_all_sectors

	; es:bx is the desination
	;mov		ax,[dest]
	;mov		es,ax
	;mov		bx,0
	mov		ax,0x10
	mov		es,ax
	mov		ebx,[dest]
	; end es:bx is the desination

	mov		cx, MAX_SECTOR_PER_READ_FOR_HARDDISK*512/2
harddisk_read_again:
	mov		dx, 0x1f0
	in		ax, dx
	mov		[es:ebx], ax
	add		ebx,2
	loop	harddisk_read_again


	;;;;;;;;;;;;;; increase dest ;;;;;;;;;;;;;;;;
	add     dword    [dest],MAX_SECTOR_PER_READ_FOR_HARDDISK*512

	add		word	[lba],MAX_SECTOR_PER_READ_FOR_HARDDISK
	pop		cx
	loop	repeat_harddisk_read
	ret

dest	dd	0x1600000
lba		dw	800+(0x3000/512)	; sector 800 is the offset of KERNEL in hd.img, 8=8*512=0x1000 offset in kernel elf, readelf kernel/kernel -S, you can see the offset

; end read harddisk subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       OS state segments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
os_tss:	dw	0, 0			; back link
        dd	0x18FF000		; ESP0
        dw	0, 0			; SS0, reserved
        dd	0x18FE000		; ESP1
        dw	0, 0			; SS1, reserved
        dd	0x18FD000		; ESP2
        dw	0, 0			; SS2, reserved
        dd	0, 0, 0			; CR3, EIP, EFLAGS
        dd	0, 0, 0, 0		; EAX, ECX, EDX, EBX
        dd	KERNEL_END, 0, 0, 0		; ESP, EBP, ESI, EDI
        dw	0, 0			; ES, reserved
        dw	0, 0			; CS, reserved
        dw	0, 0			; SS, reserved
        dw	0, 0			; DS, reserved
        dw	0, 0			; FS, reserved
        dw	0, 0			; GS, reserved
        dw	0, 0			; LDTR, reserved
        dw	0, 0			; debug, IO perm. bitmap

pmsetup_str:	db	"pm setup"
pmsetup_str_end:

wrong1	db	"wrong 1"
wrong1_end:

kernel:
	;incbin	"kernel"
kernel_image_end:

plib:
	;incbin	"../library/plib/plib.a"
plib_end:

timer_offset:
	incbin  "../interrupt/interrupt0/interrupt0"
timer_offset_end:

keyboard_offset:
	incbin  "../interrupt/interrupt1/interrupt1"
keyboard_offset_end:

interrupt0:
        incbin "../interrupt/interrupt0/interrupt0"
interrupt0_end:

interrupt1:
        incbin "../interrupt/interrupt1/interrupt1"
interrupt1_end:

interrupt2:
        incbin "../interrupt/interrupt2/interrupt2"
interrupt2_end:

interrupt3:
        incbin "../interrupt/interrupt3/interrupt3"
interrupt3_end:

interrupt4:
        incbin "../interrupt/interrupt4/interrupt4"
interrupt4_end:

interrupt5:
        incbin "../interrupt/interrupt5/interrupt5"
interrupt5_end:

interrupt6:
        incbin "../interrupt/interrupt6/interrupt6"
interrupt6_end:

interrupt7:
        incbin "../interrupt/interrupt7/interrupt7"
interrupt7_end:

interrupt8:
        incbin "../interrupt/interrupt8/interrupt8"
interrupt8_end:

interrupt9:
		incbin "../interrupt/interrupt9/interrupt9"
interrupt9_end:

interrupta:
		incbin "../interrupt/interrupta/interrupta"
interrupta_end:

interruptb:
        incbin "../interrupt/interruptb/interruptb"
interruptb_end:

interruptc:
        incbin "../interrupt/interruptc/interruptc"
interruptc_end:

interruptd:
        incbin "../interrupt/interruptd/interruptd"
interruptd_end:
	

buff:
	times	100	db	0
