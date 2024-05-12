

section .data
buf times 4096 db 0 ;; 4 mb of data space
_RMODE equ 0

dataptr    db 0
inst_ptr   db 0  ;; copy of ecx.
is_looping db 0  ;; 0 -- No (Z not found yet!) 1 -- Yes!
loop_ct    db 0
;; >>
;; 1 - 1
;; 2 - 2
;; ...
;; 0 - 10 for the number after z (end loop)

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

    cmp [ecx], byte 'Z'   ;; Enable looping
    je .EnableLooping

    cmp [ecx], byte 'z'   ;; Handle the looping
    je .HandleLooping


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
    ;; Increase instruction pointer. This is only really used
    ;; for loops
    push ebx
      mov ebx, [is_looping]      
      cmp ebx, 1 ;; Looping... update
        je .Yess
        jne .Loop

    .Yess:    ;; Increaseinstruction pointer
      mov ebx, [is_looping]
      inc ebx
      mov [inst_ptr], ebx
      pop ebx
      jmp .Loop ;; Go back
  

  .EnableLooping:
    ;; Is it already enabled?
    mov edx, [is_looping]

    ;; edx != 0 => ???
    cmp edx, 0
    jne $     ;; Just hang. WTF are you doing?
    je  .SetAndRt

    .SetAndRt:
      push edx
        mov edx, [is_looping]
        inc edx   ;; edx here should be one
        mov [is_looping], edx
      pop edx
      jmp .i2nc

    .DisableLooping:    ;; after we finish looping
      push edx
      mov edx, [is_looping]
      xor edx, edx
      mov [is_looping], edx
      jmp .i2nc

    
    .HandleLooping:
      push edx
        mov edx, [is_looping]
        cmp edx, 1
        jne .DisableLooping ;; Stop looping, don't do anything. 
      pop edx
      ;; How many times do we need to loop?
      ;; Next char is amount
      push eax  ;; Store so we don't end up fucking something up
      push ebx
        mov eax, [ecx+1]
        mov [loop_ct], eax
      pop ebx
      pop eax
      ;; loop_ct has amount of times we need to loop

      ;; Delete everything that we did from ecx
      push edx
        mov edx, [inst_ptr]
        sub ecx, edx    ;; ecx - inst_ptr. This will not increase on
                        ;; the 'z'.
      pop edx

      ;; Now we can go back to .Loop, and see if it works.
      jmp .Loop

_start:
  mov edx, [is_looping]
  xor edx, edx
  mov [is_looping], edx
  
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
