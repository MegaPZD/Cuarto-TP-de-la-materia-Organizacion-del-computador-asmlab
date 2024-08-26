
global strClone
global strPrint
global strCmp
global strLen
global strDelete

global arrayNew
global arrayDelete
global arrayPrint
global arrayGetSize
global arrayAddLast
global arrayGet
global arrayRemove
global arraySwap

global cardCmp
global cardClone
global cardAddStacked
global cardDelete
global cardGetSuit
global cardGetNumber
global cardGetStacked
global cardPrint
global cardNew

extern malloc
extern calloc
extern intClone
extern listNew
extern fprintf
extern listPrint
extern intPrint
extern fputc
extern getCompareFunction
extern getCloneFunction
extern getDeleteFunction
extern getPrintFunction
extern intCmp
extern free
extern listAddFirst
extern intDelete
extern listDelete
extern listClone

section .data

LLAVE_ABIERTA db '[', 0
COMA db ',', 0
LLAVE_CERRADA db ']', 0
CADENA_VACIA db 'NULL', 0

section .text

ARRAY_OFF_TYPE equ 0
ARRAY_OFF_SIZE equ 4
ARRAY_OFF_CAPACITY equ 5
ARRAY_OFF_DATA equ 8
ARRAY_SIZE equ 16
LLAVE_ABRIR_ASCII equ 123
LLAVE_CERRAR_ASCII equ 125
GUION_ASCII equ 45
TYPE_CARD equ 3
SIZE_CARD equ 24
CARD_STACKED_OFF equ 16
CARD_NUMBER_OFF equ 8
SIZE_POINTER equ 8


; ** String **

;char* strClone(char* a);
strClone:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    call strLen
    mov r12d, eax
    lea edi, [eax + 1]
    call malloc
    xor rdx, rdx
    cmp r12d, edx
    je .final
    .copiar_char:
        mov cl, [rbx + rdx]
        mov [rax + rdx], cl
        inc rdx
        cmp edx, r12d
        jne .copiar_char
    .final:
        mov [rax + rdx], BYTE 0
        pop r12
        pop rbx
        pop rbp
        ret

;void strPrint(char* a, FILE* pFile)
strPrint:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
    call strLen
    xor rdx, rdx
    cmp eax, edx
    je .vacio
    mov rdi, r12
    mov rsi, rbx
    call fprintf
    jmp .fin
    .vacio:
        mov rdi, r12
        mov rsi, CADENA_VACIA
        call fprintf
    .fin:
        pop r12
        pop rbx
        pop rbp
        ret

;uint32_t strLen(char* a);
strLen:
    xor rcx, rcx
    .loop:
        cmp byte [rdi + rcx], 0
        je .fin
        inc rcx
        jmp .loop
    .fin:
        mov eax, ecx
    ret

;int32_t strCmp(char* a, char* b);
strCmp:
    .comparar:
        mov dl, [rdi]
        mov cl, [rsi]
        cmp dl, cl
        je .siguiente
        jl .menor
        jg .mayor
    .siguiente:
        cmp dl, 0
        je .fin_iguales
        inc rdi
        inc rsi
        jmp .comparar
    .menor:
        mov eax, 1
        jmp .fin
    .mayor:
        mov eax, -1
        jmp .fin
    .fin_iguales:
        mov eax, 0
    .fin:
        ret

;void strDelete(char* a);
strDelete:
    push rbp
    mov rbp, rsp
    call free
    pop rbp
    ret


; ** Array **

; uint8_t  arrayGetSize(array_t* a)
arrayGetSize:
    mov al, BYTE [rdi + ARRAY_OFF_SIZE]
    ret

;void arrayAddLast(array_t* a, void* data)
arrayAddLast:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r15
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    mov dl, [r12 + ARRAY_OFF_SIZE]
    mov cl, [r12 + ARRAY_OFF_CAPACITY]
    cmp dl, cl
    jge .fin
    mov rdi, [r12 + ARRAY_OFF_TYPE]
    call getCloneFunction
    mov rdi, r13
    call rax
    mov r15, rax
    xor rdx, rdx
    mov dl, [r12 + ARRAY_OFF_SIZE]
    mov rcx, [r12 + ARRAY_OFF_DATA]
	shl rdx, 3
	mov [rcx + rdx], r15
    inc BYTE [r12 + ARRAY_OFF_SIZE]
    .fin:
        add rsp, 8
        pop r15
    	pop r13
    	pop r12
    	pop rbp
    	ret

; void* arrayGet(array_t* a, uint8_t i)
arrayGet:
	push r12
    xor rax, rax
    mov r12b, sil
	mov dl, [rdi + ARRAY_OFF_SIZE]
    and sil, 0x80
    cmp sil, 0x80
    je .fin
    mov sil, r12b
	cmp sil, dl
	jl .menor
	jmp .fin
	.menor:
        xor rsi, rsi
        mov sil, r12b
		mov rcx, [rdi + ARRAY_OFF_DATA]
		shl rsi, 3
    	mov rax, [rcx + rsi]
	.fin:
        pop r12
		ret

; array_t* arrayNew(type_t t, uint8_t capacity)
arrayNew:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8
    xor r13, r13
    mov r12, rdi
    mov r13b, sil
    mov rdi, ARRAY_SIZE
    call malloc
    mov r14, rax
    mov [r14 + ARRAY_OFF_TYPE], r12
    mov [r14 + ARRAY_OFF_SIZE], BYTE 0
    mov [r14 + ARRAY_OFF_CAPACITY], r13b
    mov rdi, r13
    mov esi, SIZE_POINTER
    call calloc
    mov [r14 + ARRAY_OFF_DATA], rax
    mov rax, r14
    add rsp, 8
    pop r14
    pop r13
    pop r12
    leave
    ret

;void* arrayRemove(array_t* a, uint8_t i)
arrayRemove:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    mov r13b, sil
    call arrayGet
    mov r14, rax
    cmp rax, 0
    jz .fin
    mov r15b, [r12 + ARRAY_OFF_SIZE]
.for:
    mov cl, r13b
    mov dl, r13b
    inc dl
    cmp dl, r15b
    jge .decSize
    mov rdi, r12
    mov sil, r13b
    call arraySwap 
    inc r13
    jmp .for
.decSize:
    dec BYTE [r12 + ARRAY_OFF_SIZE]
.fin:
    mov rax, r14
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; void  arraySwap(array_t* a, uint8_t i, uint8_t j);
arraySwap:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    xor r13, r13
    xor r14, r14
    mov r12, rdi
    mov r13b, sil
    mov r14b, dl
    call arrayGet
    mov r15, rax
    cmp r15, 0
    jz .fin
    mov rdi, r12
	mov sil, r14b
    call arrayGet
    cmp rax, 0
    jz .fin 
    mov rcx, [r12 + ARRAY_OFF_DATA]
    shl r13, 3
    shl r14, 3
    mov [rcx + r13], rax
    mov [rcx + r14], r15
	.fin:	
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

;void  arrayDelete(array_t* a)
arrayDelete:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    cmp r12, 0
    jz .finArrayTVacio
    mov r13, [r12 + ARRAY_OFF_DATA]
    cmp r13, 0
    jz .finDataVacio
    mov r14b, [r12 + ARRAY_OFF_SIZE]
    mov rdi, [r12 + ARRAY_OFF_TYPE]
    call getDeleteFunction
    mov r15, rax
    cmp r15, 0
    jz .finDataVacio
    .loop:
        cmp r14b, 0
        je .end_loop
        dec r14b
        xor rdx, rdx
        mov dl, r14b
        shl rdx, 3
        mov rdi, [r13 + rdx]
        cmp rdi, 0
        jz .loop
        call r15
        jmp .loop
    .end_loop:
        mov rdi, r13
        call free
    .finDataVacio:
        mov rdi, r12
        call free
    .finArrayTVacio:
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret

; void arrayPrint(array_t* a, FILE* pFile)
arrayPrint:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    mov r14, [r12 + ARRAY_OFF_SIZE]
    mov r15, [r12 + ARRAY_OFF_DATA]
    mov rdi, r13
    mov rsi, LLAVE_ABIERTA
    mov rdx, 0
    call fprintf
    mov rdi, [r12 + ARRAY_OFF_TYPE]
    call getPrintFunction
    mov r12, rax
    .for:
        cmp bl, r14b
        jge .fin
        xor rdx, rdx
        mov rdx, rbx
        shl rdx, 3
        mov rdi, [r15 + rdx]
        mov rsi, r13
        call r12
        inc rbx
        cmp bl, r14b
        je .for
        mov rdi, r13
        mov rsi, COMA
        mov rdx, 0
        call fprintf
        jmp .for
    .fin:
        mov rdi, r13
        mov rsi, LLAVE_CERRADA
        mov rdx, 0
        call fprintf
        add rsp, 8
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret

; ** Card **

; card_t* cardNew(char* suit, int32_t* number)
cardNew:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov edi, SIZE_CARD
    call malloc 
    mov r13, rax
    mov rdi, rbx
    call strClone
    mov [r13], rax
    mov rdi, r12
    call intClone 
    mov [r13 + CARD_NUMBER_OFF], rax
    mov edi, TYPE_CARD
    call listNew
    mov [r13 + CARD_STACKED_OFF], rax
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;char* cardGetSuit(card_t* c)
cardGetSuit:
    mov rax, [rdi]
    ret

;int32_t* cardGetNumber(card_t* c)
cardGetNumber:
    mov rax, [rdi + CARD_NUMBER_OFF]
    ret

;list_t* cardGetStacked(card_t* c)
cardGetStacked:
    mov rax, [rdi + CARD_STACKED_OFF]
    ret


;void cardPrint(card_t* c, FILE* pFile)
cardPrint:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
    mov rsi, r12
    mov edi, LLAVE_ABRIR_ASCII
    call fputc
    mov rdi, rbx
    call cardGetSuit
    mov rdi, rax
    mov rsi, r12
    call strPrint
    mov edi, GUION_ASCII
    mov rsi, r12
    call fputc
    mov rdi, rbx
    call cardGetNumber
    mov rdi, rax
    mov rsi, r12
    call intPrint
    mov rsi, r12
    mov edi, GUION_ASCII
    call fputc
    mov rdi, rbx
    call cardGetStacked
    mov rdi, rax
    mov rsi, r12
    call listPrint
    mov rsi, r12
    mov edi, LLAVE_CERRAR_ASCII
    call fputc
    pop r12
    pop rbx
    pop rbp
    ret


;int32_t cardCmp(card_t* a, card_t* b)
cardCmp:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    call cardGetSuit
    mov r13, rax
    mov rdi, r12
    call cardGetSuit
    mov rdi, r13
    mov rsi, rax
    call strCmp
    xor r13, r13
    cmp eax, r13d
    jnz .fin
    mov rdi, rbx
    call cardGetNumber
    mov r13, rax
    mov rdi, r12
    call cardGetNumber
    mov rdi, r13
    mov rsi, rax
    call intCmp
    jmp .fin
    .fin:
        add rsp, 8
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret
        

;card_t* cardClone(card_t* c)
cardClone:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    call cardGetNumber
    mov r12, rax
    mov rdi, rbx
    call cardGetSuit
    mov r13, rax
    mov rdi, rbx
    call cardGetStacked
    mov rdi, rax
    call listClone
    mov r14, rax
    mov rdi, r13
    mov rsi, r12
    call cardNew
    mov rbx, rax
    mov rdi, rbx
    call cardGetStacked
    mov rdi, rax
    call listDelete
    mov [rbx + CARD_STACKED_OFF], r14
    mov rax, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;void cardAddStacked(card_t* c, card_t* card)
cardAddStacked:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
    call cardGetStacked
    mov rdi, rax
    mov rsi, r12
    call listAddFirst
    pop r12
    pop rbx
    pop rbp
    ret

;void cardDelete(card_t* c)
cardDelete:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
    call cardGetStacked
    mov rdi, rax
    call listDelete
    mov rdi, rbx
    call cardGetSuit
    mov rdi, rax
    call strDelete
    mov rdi, rbx
    call cardGetNumber
    mov rdi, rax
    call intDelete
    mov rdi, rbx
    call free
    add rsp, 8
    pop rbx
    pop rbp
    ret

