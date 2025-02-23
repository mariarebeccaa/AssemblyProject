.data 
    vector: .space 1024 //;memoria
    id: .space 4
    size: .space 4
    v_stanga: .space 1024 // 256 * 4
    v_dreapta: .space 1024 // 256 * 4
    nr_operatii: .space 4
    nr_fisiere: .space 4
    tip_operatie: .space 4
    formatInt: .asciz "%d"
    formatAdd: .asciz "%d: (%d, %d)\n"
    formatGet: .asciz "(%d, %d)\n"
    operatii_index: .space 4 //;primul for
    nr_blocuri_id: .space 4 
    blocuri_libere: .space 4
    add_index: .space 4
    delete_index: .space 4
    memorie_index: .space 4
    poz_dreapta: .space 4
    poz_stanga: .space 4
    poz_ultim: .space 4
    ultim: .space 4
    dr: .space 4
    stg: .space 4
    verif: .space 4

.text 

.global main 

main: 
    // ;citire int
    push $nr_operatii
    push $formatInt
    call scanf
    pop %ebx
    pop %ebx

    movl $0, poz_stanga
    movl $0, poz_ultim
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

        cmp $4, %edx
        je caz_defragmentation

        jmp cont_et_for_operatii_input //;cazul in care dam un input diferit de 1, 2, 3 sau 4(caz else)

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
                movl nr_blocuri_id, %eax
                cmpl $1024, %eax
                jg nu_incape

                continuare:

                    lea vector, %edi
                    //;aici ar trebui sa fac o parcurgere a v_memorie sa vad unde mai sunt spatii libere adica 0 uri 
                    //;a.i. sa verific daca poate sa incapa fisierul resp. in acele spatii goale..daca nu il adaugam la final cum ar fi normal
                    movl $0, memorie_index
                    movl $0, blocuri_libere
                    et_for_blocuri_libere:
                        mov memorie_index, %ecx
                        cmp %ecx, poz_ultim
                        je adaug_la_final

                        mov (%edi, %ecx, 1), %bl
                        cmpb $0, %bl
                        jne urmatorul //;daca blocul nu e liber, sar la urmatorul 

                        addl $1, blocuri_libere
                        //;verificam daca incape fisierul resp, adica daca nr blocurilor libere este enough
                        mov blocuri_libere, %eax
                        cmp %eax, nr_blocuri_id
                        je adaug_in_interior //; daca nr_blocuri_id > blocuri_libere inseamna ca nu incape fisierul respectiv in portiunea resp deci sare la urm bloc liber

                        addl $1, memorie_index
                        jmp et_for_blocuri_libere       
                    
                        urmatorul:
                            movl $0, blocuri_libere
                            addl $1, memorie_index
                            jmp et_for_blocuri_libere

                    adaug_in_interior:
                        mov memorie_index, %eax
                        sub nr_blocuri_id, %eax
                        incl %eax
                        mov %eax, poz_stanga
                        add nr_blocuri_id, %eax
                        mov %eax, poz_dreapta

                        //;cmpl $1024, %eax
                        //;jg nu_incape
                      
                        jmp continuare_add
                                    
                    //; aici verificam daca dimensiunea fisierului depaseste memoria

                    adaug_la_final:
                        //;aici facem poz_stanga = poz_ultim -> asta in cazul in care adaugam la final
                        mov poz_ultim, %eax
                        mov %eax, poz_stanga
                        

                        // ; Calculam poz_dreapta = poz_stanga + nr_blocuri_id
                        add nr_blocuri_id, %eax //;16
                        mov %eax, poz_dreapta //;16 //;poz dreapta acum e practic calculata cu +1 deci are val lui poz_ultim

                        mov $1024, %eax
                        sub poz_ultim, %eax
                        cmp %eax, nr_blocuri_id
                        
                        jg nu_incape 

                        decl poz_dreapta
                        mov poz_dreapta, %eax
                        cmpl $1024, %eax
                        jg nu_incape
                        incl poz_dreapta

                        mov poz_dreapta, %eax //;daca incape la final schimbam si poz_ultim cu poz_dreapta
                        mov %eax, poz_ultim

                    continuare_add:
                        lea vector, %edi
                        mov poz_stanga, %ecx
                    
                        et_for_blocuri_id:
                            cmp %ecx, poz_dreapta
                            je et_for_exit_blocuri_id

                            mov id, %bl
                            mov %bl, (%edi, %ecx, 1) //;vector[(0...nr_blocuri-1)] =id   bl pt ca id e nr de max 8 biti
                            inc %ecx
                            jmp et_for_blocuri_id

                        et_for_exit_blocuri_id:

                        //;aici facem v_stanga[id] = poz_stanga adica ca in ex de mai sus 0 dupa 6 dupa 16
                        lea v_stanga, %edi
                        mov id, %eax
                        //;(edi-adresa vectorului, indexul curent-id-ul practic, dim=1)
                        mov poz_stanga, %ebx
                        mov %ebx, (%edi, %eax, 4)

                        decl poz_dreapta//;15
                        lea v_dreapta, %edi
                        mov id, %eax
                        mov poz_dreapta, %ebx
                        mov %ebx, (%edi, %eax, 4)

                        push poz_dreapta
                        push poz_stanga
                        push id
                        push $formatAdd
                        call printf
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
                            movl $0, stg
                            movl $0, dr
                            push stg
                            push dr
                            push id
                            push $formatAdd
                            call printf
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

            lea v_stanga, %edi
            mov id, %eax
            mov (%edi, %eax, 4), %ebx
            mov %ebx, stg 

            lea v_dreapta, %edi
            mov id, %eax
            mov (%edi, %eax, 4), %ebx
            mov %ebx, dr 
            

            push dr
            push stg
            push $formatGet
            call printf
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

            //; punem 0 uri in v_stanga si v_dreapta si tinem minte stg si dr ca sa parcurgem mai usor cand punem 0 uri si in vectorul memorie
            mov id, %eax

            lea v_stanga, %edi
            mov (%edi, %eax, 4), %ebx
            mov %ebx, stg
            
            lea v_dreapta, %edi
            mov (%edi, %eax, 4), %ebx
            mov %ebx, dr

            cmp $0, %ebx
            je et_afisare_v_memorie
 
            mov id, %eax
            lea v_stanga, %edi
            movl $0, (%edi, %eax, 4)

            lea v_dreapta, %edi
            movl $0, (%edi, %eax, 4)

            //;acum punem 0 uri in memorie
            lea vector, %edi

            //;aici treb sa facem dr+=1 
            mov dr, %eax
            incl %eax
            mov %eax, dr  //; (16, 60) e bine pana aici 100% (am afisat sa vad)

            mov stg, %ecx
            et_for_punem_zerouri_in_v_memorie:
                cmp %ecx, dr
                je continuare_delete //;aici afisam id cu pozitiile, ce ramane dupa stergere 

                movb $0, (%edi, %ecx, 1)
                inc %ecx
                jmp et_for_punem_zerouri_in_v_memorie

            continuare_delete:
                mov dr, %eax

                cmp poz_ultim, %eax //;daca sunt egale insemna ca stergem utlimul fisier adaugat la final deci poz_ultim trb actualizat cu ultima poz care e dif de 0
                je stergem_de_la_final

                jl et_afisare_v_memorie
                
                stergem_de_la_final:
 
                    mov stg, %eax
                    cmp $0, %eax
                    je et

                    decl %eax
                    mov %eax, ultim

                    et_for_delete_schimbare_poz_ultim:
                        mov ultim, %ecx
                        cmp $0, %ecx
                        je schimbare_poz_ultim

                        lea vector, %edi
                        mov (%edi, %ecx, 1), %bl
                        cmp $0, %bl
                        jne schimbare_poz_ultim
                        addl $-1, ultim
                        jmp et_for_delete_schimbare_poz_ultim

                    schimbare_poz_ultim:
                        incl ultim
                        movl ultim, %eax
                        movl %eax, poz_ultim
                        jmp et_afisare_v_memorie
                        et:
                        movl $0, poz_ultim
                
                


            et_afisare_v_memorie:
                movl $0, delete_index
            
                //;lea vector, %edi
                et_for_memorie:
                    lea vector, %edi
                    mov delete_index, %ecx
                    cmp $1024, %ecx

                    je et_exit_afisare_v_memorie
                    mov (%edi, %ecx, 1), %bl
                    mov %bl, id
                    cmp $0, %bl
                    je continuare_exit

                    mov id, %ecx
                    lea v_stanga, %edi
                    mov (%edi, %ecx, 4), %ebx
                    mov %ebx, stg

                    lea v_dreapta, %edi
                    mov (%edi, %ecx, 4), %ebx
                    mov %ebx, dr
                    
                    pushl dr
                    push stg
                    push id
                    push $formatAdd
                    call printf
                    pop %ebx
                    pop %ebx
                    pop %ebx
                    pop %ebx

                    pushl $0
                    call fflush
                    pop %ebx

                    mov dr, %eax
                    mov %eax, delete_index

                        
                    continuare_exit:
                        addl $1, delete_index
                        jmp et_for_memorie
                
            et_exit_afisare_v_memorie:
                jmp cont_et_for_operatii_input


        caz_defragmentation:
            //;mai intai verificam daca memoria e gaoala
            mov $0, %eax
            //;mov poz_ultim, %edx
            cmp %eax, poz_ultim

            je et_exit_afisare
            //;iteram in vectorul memorie sa aflam secventele de 0 uri 

            movl poz_ultim, %eax
            movl %eax, ultim

            movl $0, memorie_index
            movl $0, blocuri_libere
            movl $0, stg
            movl $0, id
            et_for_memorie_d:
                lea vector, %edi
                mov memorie_index, %ecx
                cmp %ecx, ultim
                je et_exit_for_memorie

                mov $0, %ebx
                mov (%edi, %ecx, 1), %bl
                cmp $0, %bl
                je bloc_gol

                cmp id, %ebx
                je cont    
              
                movb %bl, id

                mov id, %ecx
                lea v_stanga, %edi
                movl (%edi, %ecx, 4), %eax //;poz_stanga veche
                subl blocuri_libere, %eax
                movl %eax, (%edi, %ecx, 4)
                
                lea v_dreapta, %edi
                movl (%edi, %ecx, 4), %eax //;poz_dreapta veche
                subl blocuri_libere, %eax
                movl %eax, (%edi, %ecx, 4)

                cont:
                lea vector, %edi
                mov stg, %eax
                mov id, %bl
                mov %bl, (%edi, %eax, 1)

                incl stg
                addl $1, memorie_index
                jmp et_for_memorie_d

            bloc_gol:
                addl $1, blocuri_libere
                addl $1, memorie_index
                jmp et_for_memorie_d

            et_exit_for_memorie:
               //;punem 0 uri de la stg+1 la ultim

                movl stg, %eax
                movl %eax, poz_ultim

                movl stg, %ecx
                lea vector, %edi
                for_zerouri:
                   cmp %ecx, ultim
                   je exit 

                   movb $0, (%edi, %ecx, 1)
                   inc %ecx
                   jmp for_zerouri

            exit:
                movl $0, memorie_index
    
                et_for_afisare:
                    lea vector, %edi
                    mov memorie_index, %ecx
                    cmp $1024, %ecx
                    je et_exit_afisare
                    
                    mov (%edi, %ecx, 1), %bl
                    mov %bl, id
                    cmp $0, %bl
                    je cont_exit_d
                    
                    mov id, %ecx
                    
                    lea v_stanga, %edi
                    mov (%edi, %ecx, 4), %ebx
                    mov %ebx, stg
                    
                    lea v_dreapta, %edi
                    mov (%edi, %ecx, 4), %ebx
                    mov %ebx, dr
                    
                    push dr
                    push stg
                    push id
                    push $formatAdd
                    call printf
                    pop %ebx
                    pop %ebx
                    pop %ebx
                    pop %ebx

                    pushl $0
                    call fflush
                    pop %ebx

                    mov dr, %eax
                    mov %eax, memorie_index
                    
                cont_exit_d:
                    addl $1, memorie_index
                    jmp et_for_afisare
                    
            et_exit_afisare:
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