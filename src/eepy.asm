

section .data
buf times 4096 db 0 ;; 4 mb of data space
_RMODE equ 0

dataptr db 0

section .text
global _start

;; We know that ECX is the buffer containing the program
;; So we can just loop until buffer is equal to 0, then return.
EepyHandle:
  ;; make a back up <333
  mov esi, ecx
  .Loop:
    cmp [ecx], byte 0   ;; No more to read!
    je .Exit

    cmp [ecx], byte 'ż'
    je .IncreaseDataPTR

    cmp [ecx], byte 'Ž'
    je .DecreaseDataPTR

    cmp [ecx], byte 'ℤ'
    je .OutputDataPTR

    inc ecx
    jmp .Loop
  .Exit:
    ret

  .IncreaseDataPTR:
    mov edi, [dataptr]
    inc edi
    mov [dataptr], edi
    inc ecx
    jmp .Loop

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

    pop ecx   ;; restore current value
              ;; here we could also do
              ;; mov ecx, esi, but eh
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

  jmp _exit
  ret

_exit:
  mov eax, 0x01
  xor ebx, ebx
  int 0x80
