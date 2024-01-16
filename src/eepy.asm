section .data
buf times 4096 db 0 ;; 4 mb of data space
_RMODE        equ 0

LOOP_STARTED equ 1
__loop__     db  0
dataptr      db  0

section .text
global _start

%macro goback 0
  inc ecx
  jmp .Loop
%endmacro

;; We know that ECX is the buffer containing the program
;; So we can just loop until buffer is equal to 0, then return.
EepyHandle:
  
  xor esi, esi    ;; counter for loops
  .Loop:
    cmp [ecx], byte 0   ;; No more to read!
    je .Exit

    cmp [ecx], byte 'ż'   ;;; increases data pointer
    je .IncreaseDataPTR

    cmp [ecx], byte 'Ž'   ;;; decreases data pointer
    je .DecreaseDataPTR

    cmp [ecx], byte 'ℤ'   ;;; outputs ascii of data pointer
    je .OutputDataPTR

    cmp [ecx], byte 'O'
    je .StartLoop


    cmp [ecx], byte 'o'   ;;; starts loop
    je .EndLoop

    cmp edi, 1    ;; loop started
    je  ._Loop
    jne .Normal
  .Exit: ret

  ._Loop:
    inc esi
    inc ecx
    jmp .Loop
  
  .Normal:
    inc ecx
    jmp .Loop

  .StartLoop:
    mov edi, LOOP_STARTED
    goback

  .EndLoop:
    push ebx
    mov ebx, [__loop__]
    cmp ebx, 1
    je ._goback

    ;; Maybe fix?
    ; inc esi
    ;; ECX-ESI
    sub ecx, esi
    xor esi, esi  ;; reset counter

    ;; set loop to one
    mov ebx, 1
    mov [__loop__], ebx
    pop ebx
   
    inc ecx
    jmp .Loop
      ._goback:
        inc ecx
        jmp .Loop

  .IncreaseDataPTR:
    mov edi, [dataptr]
    inc edi
    mov [dataptr], edi
    goback

  .DecreaseDataPTR:
    mov edi, [dataptr]
    dec edi
    mov [dataptr], edi
    
    inc ecx
    jmp .Loop


  .OutputDataPTR:
    push ecx
    mov eax, 0x04
    mov ebx, 0x01   ;; stdout
    mov ecx, dataptr
    mov edx, 1      ;; self explanatory
    int 0x80

    pop ecx    
    inc ecx
    jmp .Loop

_start:
  ;; this is such a gross way of doing it
  ;; but lea ebx, [esp+8] just does not work
  pop ebx
  pop ebx
  pop ebx
  
  mov eax, 5        ;; sys_open     
  mov ecx, _RMODE
  int 0x80

  ;; time for reading
  mov eax, 3      ;; sys_read
  mov ebx, eax
  mov ecx, buf
  mov edx, 512
  int 0x80

  ;; buf is already in ecx.
  call EepyHandle
  mov eax, 0x01
  xor ebx, ebx
  int 0x80
