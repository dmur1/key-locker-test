section .data
    hardware_support_for_key_locker_fmt db "hardware support for key locker: %u", 10, 0

    kl_restriction_cpl_0_only_fmt db "restriction of CPL-0-only supported: %u", 10, 0
    kl_restriction_no_encrypt_fmt db "restriction of no-encrypt supported: %u", 10, 0
    kl_restriction_no_decrypt_fmt db "restriction of no-decrypt supported: %u", 10, 0
    kl_fully_enabled_fmt db "key locker fully enabled: %u", 10, 0
    kl_wide_instructions_fmt db "aes wide key locker instructions supported: %u", 10, 0
    kl_platform_supports_backups_fmt db "platform supports IWKeyBackup MSRs: %u", 10, 0
    kl_no_backup_param_supported_fmt db "no backup parameter to loadiwkey is supported: %u", 10, 0
    kl_key_source_1_supported_fmt db "internally randomized key source encoding supported: %u", 10, 0

section .text
    global main
    extern printf

; hardware support for key locker is enumerated through
; CPUID.KL: CPUID.(07H,0).ECX[23] = 1
has_key_locker_support:
    mov     eax, 0x07
    xor     ecx, ecx
    cpuid
    mov     eax, ecx
    shr     eax, 23
    and     eax, 1
    ret

; more information is available via CPUID leaf 19H
enumerate_key_locker_support:
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp, 8

    mov     eax, 0x19
    xor     ecx, ecx
    cpuid
    mov     r12d, eax
    mov     r13d, ebx
    mov     r14d, ecx

    ; EAX[0]
    mov     esi, r12d
    and     esi, 1
    lea     rdi, [kl_restriction_cpl_0_only_fmt]
    xor     eax, eax
    call    printf

    ; EAX[1]
    mov     esi, r12d
    shr     esi, 1
    and     esi, 1
    lea     rdi, [kl_restriction_no_encrypt_fmt]
    xor     eax, eax
    call    printf

    ; EAX[2]
    mov     esi, r12d
    shr     esi, 2
    and     esi, 1
    lea     rdi, [kl_restriction_no_decrypt_fmt]
    xor     eax, eax
    call    printf

    ; EBX[0]
    mov     esi, r13d
    and     esi, 1
    lea     rdi, [kl_fully_enabled_fmt]
    xor     eax, eax
    call    printf

    ; EBX[2]
    mov     esi, r13d
    shr     esi, 2
    and     esi, 1
    lea     rdi, [kl_wide_instructions_fmt]
    xor     eax, eax
    call    printf

    ; EBX[4]
    mov     esi, r13d
    shr     esi, 4
    and     esi, 1
    lea     rdi, [kl_platform_supports_backups_fmt]
    xor     eax, eax
    call    printf

    ; ECX[0]
    mov     esi, r14d
    and     esi, 1
    lea     rdi, [kl_no_backup_param_supported_fmt]
    xor     eax, eax
    call    printf

    ; ECX[1]
    mov     esi, r14d
    shr     esi, 1
    and     esi, 1
    lea     rdi, [kl_key_source_1_supported_fmt]
    xor     eax, eax
    call    printf

    add     rsp, 8
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

main:
    sub     rsp, 8

    call    has_key_locker_support
    mov     r12d, eax

    mov     esi, r12d
    lea     rdi, [hardware_support_for_key_locker_fmt]
    xor     eax, eax
    call    printf

    test    r12d, r12d
    jz      exit

    call    enumerate_key_locker_support

exit:
    mov     eax, 60
    xor     edi, edi
    syscall
