

section .data
buf times 4096 db 0 ;; 4 mb of data space
_RMODE equ 0

dataptr  db 0

section .text
global _start

;; Handle everything.
EepyHandle:
  .Loop:
    ;; We know that once we get a null byte, the program ends. So just exit
    cmp [ecx], byte 0
    je _exit

    ;; Check against known values.
    cmp [ecx], byte 'e'   ;; Increase data pointer
    je .IncDP

    cmp [ecx], byte 'p'   ;; Dec data pointer
    je .DecDP

    cmp [ecx], byte 'y'   ;; Print out 
    je .PrintDP

    cmp [ecx], byte '.'   ;; Set DP to 0
    je .SetDPZero

    ;; Not equal, check for others, and if still
    ;; not equal increment and loop
    jne .i2nc
    jmp .Loop

  .SetDPZero:
    mov ebx, [dataptr]
    xor ebx, ebx
    mov [dataptr], ebx
    inc ecx
    jmp .Loop

  .IncDP:
    mov ebx, [dataptr]
    inc ebx
    mov [dataptr], ebx
    inc ecx
    jmp .Loop

  .DecDP:
    mov ebx, [dataptr]
    dec ebx
    mov [dataptr], ebx
    inc ecx
    jmp .Loop

  .PrintDP:
    push ecx
    mov eax, 0x04
    mov ebx, 0x01   ;; stdout
    mov ecx, dataptr
    mov edx, 1      ;; self explanatory
    int 0x80

    pop ecx    
    inc ecx
    jmp .Loop

  .i2nc:
    inc ecx
    jmp .Loop
  

_start:
  ;; Get first argument
  lea ecx, [esp+8]
  mov ebx, [ecx]

  mov eax, 5        ;; sys_open     
  mov ecx, _RMODE
  int 0x80

  ;; time for reading
  mov eax, 3      ;; sys_read
  mov ebx, eax
  mov ecx, buf
  mov edx, 512   ;; buf size is 4mb, so we should use that.
  int 0x80

  ;; handle all code and things
  call EepyHandle

  jmp _exit
  ret

_exit:
  mov eax, 0x01
  xor ebx, ebx
  int 0x80
