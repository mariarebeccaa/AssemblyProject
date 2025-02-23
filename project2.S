.data
    matrix: .space 1048576//;1024 * 1024
    //;lines: .space 4
    //;columns: .space 4
    line_index: .space 4
    column_index: .space 4
    operatii_index: .space 4
    id: .space 4
    size: .space 4
    nr_operatii: .space 4
    nr_fisiere: .space 4
    tip_operatie: .space 4
    nr_blocuri_id: .space 4
    blocuri_libere: .space 4
    formatAdd: .asciz "%d: ((%d, %d), (%d, %d))\n"
    formatGet: .asciz "((%d, %d), (%d, %d))\n"
    formatInt: .asciz "%d"
    add_index: .space 4
    v_stanga: .space 1024 // 256 * 4
    v_dreapta: .space 1024 // 256 * 4
    v_linia: .space 1024
    poz_dreapta: .space 4
    poz_stanga: .space 4
    poz_ultim_linie: .space 4
    stg: .space 4
    dr: .space 4

.text 

.global main 

main:
    // ;citire int
    push $nr_operatii
    push $formatInt
    call scanf
    pop %ebx
    pop %ebx

    movl $0, operatii_index
    et_for_operatii_input:

        movl operatii_index, %ecx

        cmp  %ecx, nr_operatii
        je et_exit_for_operatii
       
        push $tip_operatie
        push $formatInt
        call scanf
        pop %ebx
        pop %ebx

        mov tip_operatie, %edx
        cmp $1, %edx
        je caz_add

        cmp $2, %edx
        je caz_get

        cmp $3, %edx
        je caz_delete

        caz_add:
            pushl $nr_fisiere
            push $formatInt
            call scanf
            pop %ebx
            pop %ebx
            
            movl $0, add_index
            et_for_add:
                mov add_index, %ecx

                cmp %ecx, nr_fisiere
                je et_exit_for_add

                pushl $id
                push $formatInt
                call scanf
                pop %ebx
                pop %ebx

                push $size
                push $formatInt
                call scanf
                pop %ebx
                pop %ebx

                //;calc nr de blocuri necesare pt fiecare fisier
                mov size, %eax
                mov $8, %ebx
                xor %edx, %edx
                div %ebx  // ;%eax = %eax / 8 = size / 8; catul in eax si restul in edx
                
                mov %eax, nr_blocuri_id
                cmp $0, %edx 
                je continuare
                
                incl nr_blocuri_id //;daca restul e mai mare decat 0 inseamna ca mai avem nevoie de un bloc
                
                continuare:
                    lea matrix, %edi

                    //; aici fac o parcurgere a memoriei matrix de la inceput pt ca trb sa iau in considerare si spatiile libere din interior
                    movl $0, line_index
                    for_matrix:
                        mov line_index, %ecx
                        cmp $1024, %ecx
                        je nu_incape

                        movl $0, column_index
                        movl $0, blocuri_libere
                        for_blocuri_libere_linie:
                            movl column_index, %ecx
                            cmp $1024, %ecx
                            je cont

                            movl line_index, %eax
                            mov $1024, %edx
                            mull %edx
                            addl column_index, %eax
                            mov (%edi, %eax, 1), %bl

                            cmpb $0, %bl
                            jne urmatorul

                            addl $1, blocuri_libere

                            mov blocuri_libere, %eax
                            cmp %eax, nr_blocuri_id
                            je adaug_in_interior_linie

                            addl $1, column_index
                            jmp for_blocuri_libere_linie

                            urmatorul:
                                movl $0, blocuri_libere
                                addl $1, column_index
                                jmp for_blocuri_libere_linie

                        cont:
                            addl $1, line_index
                            jmp for_matrix

                    adaug_in_interior_linie:
                        mov column_index, %eax
                        sub nr_blocuri_id, %eax
                        incl %eax
                        mov %eax, poz_stanga
                        add nr_blocuri_id, %eax
                        mov %eax, poz_dreapta

                        jmp continuare_add  

                     
                    continuare_add:
                        lea matrix, %edi
                        mov poz_stanga, %ecx

                        for_punem_id:
                            cmp %ecx, poz_dreapta
                            je exit_for_punem_id

                            mov id, %bl
                            movl line_index, %eax
                            movl $1024, %edx
                            mull %edx
                            addl %ecx, %eax
                            movb %bl, (%edi, %eax, 1)

                            inc %ecx
                            jmp for_punem_id

                        exit_for_punem_id:
                            mov id, %eax

                            lea v_stanga, %edi
                            mov poz_stanga, %ebx
                            mov %ebx, (%edi, %eax, 4) 

                            decl poz_dreapta//;15
                            lea v_dreapta, %edi
                            mov poz_dreapta, %ebx
                            mov %ebx, (%edi, %eax, 4)   

                            lea v_linia, %edi
                            mov line_index, %ebx
                            mov %ebx, (%edi, %eax, 4)

                            push poz_dreapta
                            push line_index
                            push poz_stanga
                            push line_index
                            push id
                            push $formatAdd
                            call printf
                            pop %ebx
                            pop %ebx
                            pop %ebx
                            pop %ebx
                            pop %ebx
                            pop %ebx

                            push $0
                            call fflush
                            pop %ebx

                            addl $1, add_index 
                            jmp et_for_add

                            nu_incape:
                                movl $0, poz_dreapta
                                movl $0, poz_stanga
                                movl $0, line_index

                                push poz_dreapta
                                push line_index
                                push poz_stanga
                                push line_index
                                push id
                                push $formatAdd
                                call printf
                                pop %ebx
                                pop %ebx
                                pop %ebx
                                pop %ebx
                                pop %ebx
                                pop %ebx

                                push $0
                                call fflush
                                pop %ebx

                                addl $1, add_index 
                                jmp et_for_add


        et_exit_for_add:
            jmp cont_et_for_operatii_input

                
        caz_get:
            pushl $id
            push $formatInt
            call scanf
            pop %ebx
            pop %ebx

            mov id, %eax

            lea v_stanga, %edi
            mov (%edi, %eax, 4), %ebx
            mov %ebx, poz_stanga 

            lea v_dreapta, %edi
            mov (%edi, %eax, 4), %ebx
            mov %ebx, poz_dreapta   

            lea v_linia, %edi
            mov (%edi, %eax, 4), %ebx
            mov %ebx, line_index

            push poz_dreapta
            push line_index
            push poz_stanga
            push line_index
            push $formatGet
            call printf
            pop %ebx
            pop %ebx
            pop %ebx
            pop %ebx
            pop %ebx

            push $0
            call fflush
            pop %ebx

            jmp cont_et_for_operatii_input

        caz_delete:
            push $id
            push $formatInt
            call scanf
            pop %ebx
            pop %ebx

            mov id, %eax

            lea v_stanga, %edi
            mov (%edi, %eax, 4), %ebx
            mov %ebx, stg
            
            lea v_dreapta, %edi
            mov (%edi, %eax, 4), %ebx
            mov %ebx, dr

            cmp $0, %ebx
            je afisare_memorie

            lea v_linia, %edi
            mov (%edi, %eax, 4), %ebx
            mov %ebx, line_index

            mov id, %eax
            lea v_stanga, %edi
            movl $0, (%edi, %eax, 4)

            lea v_dreapta, %edi
            movl $0, (%edi, %eax, 4)

            lea v_linia, %edi
            movl $0, (%edi, %eax, 4)

            //;acum punem 0 uri in memorie
            lea matrix, %edi

            mov dr, %eax
            incl %eax
            mov %eax, dr
            
            mov stg, %ecx
            for_punem_zerouri_in_memorie:
                cmp %ecx, dr
                je afisare_memorie

                movl line_index, %eax
                movl $1024, %edx
                mull %edx
                addl %ecx, %eax
                movb $0, (%edi, %eax, 1)

                inc %ecx
                jmp for_punem_zerouri_in_memorie

            afisare_memorie:
                //afisam
                lea matrix, %edi
                movl $0, line_index
                for_memorie:
                    lea matrix, %edi
                    movl line_index, %ecx
                    cmp $1024, %ecx
                    je exit_afisare_memorie

                    movl $0, column_index
                    for_columns:
                        lea matrix, %edi 
                        movl column_index, %ecx
                        cmp $1024, %ecx
                        je cont_for_memorie
                                
                        movl line_index, %eax
                        movl $1024, %edx
                        mull %edx
                        addl column_index, %eax
                        movb (%edi, %eax, 1), %bl
                        mov %bl, id
                        cmp $0, %bl
                        je cont_for_columns

                        mov id, %ecx
                        lea v_stanga, %edi
                        mov (%edi, %ecx, 4), %ebx
                        mov %ebx, stg

                        lea v_dreapta, %edi
                        mov (%edi, %ecx, 4), %ebx
                        mov %ebx, dr

                        push dr
                        push line_index
                        push stg
                        push line_index
                        push id
                        push $formatAdd
                        call printf
                        pop %ebx
                        pop %ebx
                        pop %ebx
                        pop %ebx
                        pop %ebx
                        pop %ebx

                        push $0
                        call fflush
                        pop %ebx

                        mov dr, %eax
                        mov %eax, column_index

                        cont_for_columns:
                            addl $1, column_index
                            jmp for_columns

                    cont_for_memorie:
                        addl $1, line_index
                        jmp for_memorie

            exit_afisare_memorie:
                jmp cont_et_for_operatii_input
                 

    cont_et_for_operatii_input:
        addl $1, operatii_index        
        jmp et_for_operatii_input  //;sfarsit de for operatii 


    et_exit_for_operatii:
        pushl $0
        call fflush
        popl %eax

        mov $1, %eax 
        mov $0, %ebx 
        int $0x80


//; 231_Edu_MariaRebecca_1

