section .data
buf times 4096 db 0 ;; 4 mb of data space
_RMODE equ 0

section .text
global _start

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

  jmp _exit
  ret

_exit:
  mov eax, 0x01
  xor ebx, ebx
  int 0x80
