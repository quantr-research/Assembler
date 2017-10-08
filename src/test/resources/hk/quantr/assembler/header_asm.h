// This file is useless now because I don't use pm_setup.asm

;//////////////////////////////////////////
;// This file have to sunc with header.h //
;//////////////////////////////////////////

;////////////////////////////////////////////    os data area    /////////////////////////////////////////////
OS_DATA_AREA_SEGMENT	equ	0x9000
VBE	equ	0x90000
MEMSIZE	equ	0x90001
;CPUID_VENDORSIGN	equ	0x90005
;CPUID_FAMILY	equ	0x90012
;CPUID_MODEL	equ	0x90016
;CPUID_STEPPING	equ	0x9001A
;CPUID_FAMILYEX	equ	0x9001E
;CPUID_MODELEX	equ	0x90022
;CPUID_TYPE	equ	0x90026
;CPUID_BRAND	equ	0x90039
;CPUID_CACHELINESIZE	equ	0x9003D
;CPUID_LOGICALPROCESSORCOUNT	equ	0x90041
;CPUID_LOCALAPICID	equ	0x90045
;CPU_SPEED	equ	0x90049
VESA_BUFFER	equ	0x9004D	; 512 byte buffer
VESA_NUMBER_OF_MODE	equ	0x9024D
VESA_MODE	equ	0x9024F	; assume only got 100 modes, so = 8 bytes * 100 = 800 bytes
VESA_MODE_INFORMATIONS	equ	0x9056F	; assum only got 100 mode information, so =  256 bytes * 100 = 25600 bytes
DRIVE_TYPE	equ	0x9696F
MAX_CYLINDER	equ	0x96970
MAX_HEAD	equ	0x96972
MAX_SECTOR	equ	0x96973
NUMBER_OF_DRIVE	equ	0x96974
DRIVE_PARAMETER_TABLE	equ	0x96975	; 32 bits address
;//KEYBOARD_BUFFER equ	0x96979		;  8 bytes


;/////////////////////////////////////////////////////////////////////////////////////////////////////////////

;//PD0		equ		0x200000		; 4K = 4*2^10
;//PT0		equ		0x200000+4096		; 4K = 4*2^10	PT0,1,2... has 1024 page tables
;//PT1		equ		0x200000+4096*2		; 4K = 4*2^10
;//PT2		equ		0x200000+4096*3		; 4K = 4*2^10
;//PT3		equ		0x200000+4096*4		; 4K = 4*2^10
;//PT4		equ		0x200000+4096*5		; 4K = 4*2^10
;//PT5		equ		0x200000+4096*6		; 4K = 4*2^10
;//PT6		equ		0x200000+4096*7		; 4K = 4*2^10
;//PT7		equ		0x200000+4096*8		; 4k = 4*2^10

INTERRUPT0		equ		0x500000	; 0.5 MB
INTERRUPT1		equ		0x508000	; 0.5 MB
INTERRUPT2		equ		0x600000	; 0.5 MB
INTERRUPT3		equ		0x608000	; 0.5 MB
INTERRUPT4		equ		0x700000	; 0.5 MB
INTERRUPT5		equ		0x708000	; 0.5 MB
INTERRUPT6		equ		0x800000	; 0.5 MB
INTERRUPT7		equ		0x808000	; 0.5 MB
INTERRUPT8		equ		0x900000	; 0.5 MB
TIMER			equ		0x900000	; 0.5 MB
INTERRUPT9		equ		0x908000	; 0.5 MB
KEYBOARD		equ		0x908000	; 0.5 MB
INTERRUPTA		equ		0xa00000	; 0.5 MB
INTERRUPTB		equ		0xa08000	; 0.5 MB
INTERRUPTC		equ		0xb00000	; 0.5 MB
INTERRUPTD		equ		0xb08000	; 0.5 MB

KERNEL_PDs	equ		0x1100000		; 1024 PD, 4Bytes each
KERNEL_PTs	equ		0x1101000		; 1024 * 1024 PTE * 4 Bytes each
FREEPAGELIST	equ		0x1501000		; 1MB

KERNEL				equ     0x1600000               ; 1 MB
KERNEL_END			equ     0x1700000               ; used for ESP
FREEVIRTUALADDRESSLIST		equ	0x1700000
PLIB				equ     0x1800000               ; 1 MB
USEDVIRTUALADDRESSLIST		equ	0x1900000
;KERNEL_HEAP			equ	0x1a00000
;KERNEL_HEAP_END			equ	0x1b00000

KERNEL_RESERVED_MEMORY		equ	0x1b00000
KERNEL_RESERVED_MEMORY_END	equ	0x1bfffff

