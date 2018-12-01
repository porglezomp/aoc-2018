EXIT: equ   0x2000001

global start

section .text
start:
    ;; hi
exit:
    mov     rax, EXIT
    mov     rdi, 0
    syscall
