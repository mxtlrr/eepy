

section .data
buf times 4096 db 0 ;; 4 mb of data space

dataptr    db 0
inst_ptr   db 0 ;; copy of ecx.
plchldr    db 0
loop_ct    db 0

;; >>
;; 1 - 1
;; 2 - 2
;; ...
;; 0 - 10 for the number after z (end loop)

section .text
global _start

;; breakpoint
n22test:
  int 0x3
  ret

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
      mov ebx, 0x01    ;; stdout
      mov ecx, dataptr ;; data to print out
      mov edx, 1       ;; self explanatory
      int 0x80
    pop ecx    
    inc ecx
    jmp .Loop

  .i2nc:
    inc ecx
    ;; Increase instruction pointer. This is only really used
    ;; for loops
    push ebx
      cmp edi, 1 ;; Looping... update
        je .Yess
        jne .Loop
    pop ebx

    .Yess:    ;; Increase instruction pointer
      inc esi
      jmp .Loop ;; Go back
  

  .EnableLooping:
    cmp edi, 0
    jne $     ;; Just hang. WTF are you doing?
    je  .SetAndRt

    .SetAndRt:
      mov edi, 1
      jmp .i2nc

    .DisableLooping:    ;; after we finish looping
      ;; TODO: move this to handle looping      
      
      xor edi, edi
      xor esi, esi
      jmp .i2nc
    
    .HandleLooping:
    ;; TODO: fix this, shouldn't stop if we are looping.
      push edx
        cmp edi, 0            ;; Looping?
        je .GetStuff
        jne .GoBack ;; Yes, continue
      pop edx
      
      cmp esi, [loop_ct]
      je .DisableLooping
      
      ;; loop_ct has amount of times we need to loop

      ;; Delete everything that we did from ecx
      .GoBack:
        push edx
          mov edx, esi
          sub ecx, edx    ;; ecx - inst_ptr. This will not increase on
                          ;; the 'z'.
        pop edx
        jmp .Loop

      .GetStuff:
        ;; How many times do we need to loop?
        ;; Next char is amount
        push eax  ;; Store so we don't end up fucking something up
        push ebx
          mov eax, [ecx+1]
          mov [loop_ct], eax
        pop ebx
        pop eax

_start:
  xor edi, edi    ;; are we looping?
  xor esi, esi    ;; instruction pointer

  ;; Get first argument
  lea ecx, [esp+8]
  mov ebx, [ecx]

  mov eax, 5        ;; sys_open     
  mov ecx, 0
  int 0x80

  ;; time for reading
  mov eax, 3      ;; sys_read
  mov ebx, eax
  mov ecx, buf
  mov edx, 512   ;; buf size is 4mb, so we should use that.
  int 0x80

  ;; handle all code and things
  xor edx, edx
  call EepyHandle

  jmp _exit
  ret

_exit:
  mov eax, 0x01
  xor ebx, ebx
  int 0x80
