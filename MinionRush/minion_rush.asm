.386
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc

public start

.data

window_title db "Minion Rush 2D", 0
area_width equ 640
area_height equ 480
area dd 0

counter dd 0
counter_caramida dd 0

argument_1 equ 8
argument_2 equ 12
argument_3 equ 16
argument_4 equ 20

symbol_width equ 10
symbol_height equ 20

include digits.inc
include letters.inc

minion_x dd 320
minion_y dd 360
minion_height dd 80
minion_width dd 60

caramida_1_x dd 95
caramida_1_y dd 55
caramida_1_width dd 40

caramida_2_x dd 265
caramida_2_y dd 35
caramida_2_width dd 40

caramida_3_x dd 445
caramida_3_y dd 75
caramida_3_width dd 40

banana_1_x dd 210
banana_1_y dd 55 
banana_1_height dd 40
banana_1_width dd 15

banana_2_x dd 400
banana_2_y dd 55 
banana_2_height dd 40
banana_2_width dd 15

.code

; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; argument_1 - simbolul de afisat (litera sau cifra)
; argument_2 - pointer la vectorul de pixeli
; argument_3 - pos_x
; argument_4 - pos_y
make_text proc

	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp + argument_1]												 	; citim simbolul de afisat
	
	cmp eax, 'A'
	jl make_digit
	
	cmp eax, 'Z'
	jg make_digit
	
	sub eax, 'A'
	
	lea esi, letters
	jmp draw_text
	
	make_digit:
		cmp eax, '0'
		jl make_space
		
		cmp eax, '9'
		jg make_space
		
		sub eax, '0'
		
		lea esi, digits
		jmp draw_text
		
	make_space:	
		mov eax, 26																; de la 0 pana la 25 sunt litere, 26 e space
		lea esi, letters
		
	draw_text:
		mov ebx, symbol_width
		mul ebx
		mov ebx, symbol_height
		mul ebx
		add esi, eax
		mov ecx, symbol_height
		
	bucla_simbol_linii:
		mov edi, [ebp + argument_2] 											; pointer la matricea de pixeli
		mov eax, [ebp + argument_4] 											; pointer la coord y
		add eax, symbol_height
		sub eax, ecx
		mov ebx, area_width
		mul ebx
		add eax, [ebp + argument_3] 											; pointer la coord x
		shl eax, 2 																; inmultim cu 4, avem un DWORD per pixel
		add edi, eax
		push ecx
		mov ecx, symbol_width
		
	bucla_simbol_coloane:
		cmp byte ptr [esi], 0
		je simbol_pixel_alb
		mov dword ptr [edi], 0
		jmp simbol_pixel_next
		
	simbol_pixel_alb:
		mov dword ptr [edi], 0FFFFFFh
		
	simbol_pixel_next:
		inc esi
		add edi, 4
		loop bucla_simbol_coloane
		pop ecx
		loop bucla_simbol_linii
		
	popa
	mov esp, ebp
	pop ebp
	ret
	
make_text endp

; un macro ca sa apelam desenarea simbolului
make_text_macro macro symbol, drawArea, x, y

	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
	
endm

; un macro care face o linie orizontala
line_horizontal macro x, y, len, color

local loop_line

	mov eax, y																		; eax = y
	mov ebx, area_width
	mul ebx																			; eax = y * area_width
	add eax, x																		; eax = y * area_width + x
	shl eax, 2																		; eax = (y * area_width + x) * 4
	add eax, area   			
	
	mov ecx, len 																	; len = nr de pixeli 
	
	loop_line : 
		mov dword ptr [eax], color
		add eax, 4
		loop loop_line
endm

; un macro care face o linie verticala
line_vertical macro x, y, len, color

local loop_line

	mov eax, y																		; eax = y
	mov ebx, area_width
	mul ebx																			; eax = y * area_width
	add eax, x																		; eax = y * area_width + x
	shl eax, 2																		; eax = (y * area_width + x) * 4
	add eax, area   			
	
	mov ecx, len 																	; len = nr de pixeli 
	
	loop_line : 
		mov dword ptr [eax], color
		add eax, area_width * 4														; area_width deoarece merge in jos
		loop loop_line
endm

; un macro care deseneaza minionul
desenare_minion macro minion_x, minion_y, minion_width, minion_height

	mov edi, minion_x
	add edi, minion_width
		
	mov esi, minion_y
	add esi, minion_height
		
	line_horizontal minion_x, minion_y, minion_width, 0ffdb4dh
	line_horizontal minion_x, esi, minion_width, 0ffdb4dh 
	line_vertical minion_x, minion_y, minion_height, 0ffdb4dh
	line_vertical edi, minion_y, minion_height, 0ffdb4dh
	
endm

; un macro care sterge minionul
sterge_minion macro minion_x, minion_y, minion_width, minion_height   

	mov edi, minion_x
	add edi, minion_width
		
	mov esi, minion_y
	add esi, minion_height
		
	line_horizontal minion_x, minion_y, minion_width, 0cccccch
	line_horizontal minion_x, esi, minion_width, 0cccccch
	line_vertical minion_x, minion_y, minion_height, 0cccccch
	line_vertical edi, minion_y, minion_height, 0cccccch

endm

; un macro care deseneaza o caramida (zid)
desenare_caramida macro caramida_x, caramida_y, caramida_width

	mov edi, caramida_x
	add edi, caramida_width
		
	mov esi, caramida_y
	add esi, caramida_width
		
	line_horizontal caramida_x, caramida_y, caramida_width, 0cc3300h
	line_horizontal caramida_x, esi, caramida_width, 0cc3300h
	line_vertical caramida_x, caramida_y, caramida_width, 0cc3300h
	line_vertical edi, caramida_y, caramida_width, 0cc3300h
	
endm

; un macro care sterge o caramida (zid)
sterge_caramida macro caramida_x, caramida_y, caramida_width

	mov edi, caramida_x
	add edi, caramida_width
		
	mov esi, caramida_y
	add esi, caramida_width
		
	line_horizontal caramida_x, caramida_y, caramida_width, 0cccccch
	line_horizontal caramida_x, esi, caramida_width, 0cccccch
	line_vertical caramida_x, caramida_y, caramida_width, 0cccccch
	line_vertical edi, caramida_y, caramida_width, 0cccccch
	
endm 

; un macro care deseneaza o banana
desenare_banana macro banana_x, banana_y, banana_width, banana_height

	mov edi, banana_x
	add edi, banana_width
		
	mov esi, banana_y
	add esi, banana_height
		
	line_horizontal banana_x, banana_y, banana_width, 0ffff00h
	line_horizontal banana_x, esi, banana_width, 0ffff00h
	line_vertical banana_x, banana_y, banana_height, 0ffff00h
	line_vertical edi, banana_y, banana_height, 0ffff00h
	
endm

; un macro care sterge o banana
sterge_banana macro banana_x, banana_y, banana_width, banana_height

	mov edi, banana_x
	add edi, banana_width
		
	mov esi, banana_y
	add esi, banana_1_height
		
	line_horizontal banana_x, banana_y, banana_width, 0cccccch
	line_horizontal banana_x, esi, banana_width, 0cccccch
	line_vertical banana_x, banana_y, banana_height, 0cccccch
	line_vertical edi, banana_y, banana_height, 0cccccch
	
endm


; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; argument_1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; argument_2 - x
; argument_3 - y
draw proc

	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp + argument_1]
	
	cmp eax, 1
	jz evt_click
	
	cmp eax, 2
	jz evt_timer 																		; nu s-a efectuat click pe nimic
	
	; se intializeaza fereastra cu pixeli gri
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 203
	push area
	call memset
	add esp, 12
	
	jmp afisare_litere
	
	evt_click:
		mov eax, [ebp + argument_2]
		
		mov ebx, minion_x
		add ebx, minion_width
		
		cmp eax, ebx
		jg right
		
		cmp eax, minion_x
		jl left
		
		; daca s-a dat click in partea stanga se sterge minionul din pozitia curenta si se actualizeaza datele
		left : 
			
			sterge_minion minion_x, minion_y, minion_width, minion_height 
			
			mov ecx, minion_x
			
			sub ecx, minion_width
			
			mov minion_x, ecx
			
			jmp final
		
		; daca s-a dat click in partea dreapta se sterge minionul din pozitia curenta si se actualizeaza datele
		right :
			
			sterge_minion minion_x, minion_y, minion_width, minion_height
			
			mov ecx, minion_x
			
			add ecx, minion_width
			
			mov minion_x, ecx
			
			jmp final
			
		final :
		
		jmp afisare_litere
	
	evt_timer:
		
		; la fiecare event de timer, se sterg caramizile din pozitiile lor curente si se actualizeaza datele 
		redesenare_caramizi : 
		
			sterge_caramida caramida_1_x, caramida_1_y, caramida_1_width
			sterge_caramida caramida_2_x, caramida_2_y, caramida_2_width
			sterge_caramida caramida_3_x, caramida_3_y, caramida_3_width
			
			add caramida_1_y, 42
			add caramida_2_y, 60
			add caramida_3_y, 60
			
			mov ebx, minion_y
			add ebx, minion_height
			
			; se compara coordonatele caramizilor, daca acestea au depasit partea de jos a minionului se reinitializeaza
			cmp caramida_1_y, ebx
			jle compara_2
			
			mov caramida_1_y, 55
				
			compara_2 : 	
			cmp caramida_2_y, ebx
			jle compara_3
			
			mov caramida_2_y, 35
				
			compara_3 :	
			cmp caramida_3_y, ebx
			jle final_comparare
			
			mov caramida_3_y, 65
			
			final_comparare :
				jmp e_ok
		
			e_ok :
		
; la fiecare event de timer, se sterg bananele din pozitiile lor curente si se actualizeaza datele 
		redesenare_banana :
		
			sterge_banana banana_1_x, banana_1_y, banana_1_width, banana_1_height
			sterge_banana banana_2_x, banana_2_y, banana_2_width, banana_2_height
			
			add banana_1_y, 80
			add banana_2_y, 80
			
			mov ebx, minion_y
			add ebx, minion_height
			
			; se compara coordonatele bananelor, daca acestea au depasit partea de jos a minionului se reinitializeaza
			cmp banana_1_y, ebx
			jle compara_banana_2
			
			mov banana_1_y, 55
			
			compara_banana_2 :
			cmp banana_2_y, ebx
			jle final_comparare_banane
			
			mov banana_2_y, 55
			
			final_comparare_banane :
				jmp e_ok_2
			
			e_ok_2 :
			
		; se compara coordonatele bananelor, daca acestea se afla in interiorul minionului, counter-ul se incrementeaza cu 10
		puncte_banane : 
			mov eax, banana_1_x
			
			banana_1 :
				cmp eax, minion_x
				jl nu_a_consumat
				
				mov ebx, minion_x
				add ebx, minion_width
				
				cmp eax, ebx
				jg nu_a_consumat 
				
				mov eax, banana_1_y
				
				cmp eax, minion_y
				jl nu_a_consumat
				
				mov ebx, minion_y
				add ebx, minion_height
				
				cmp eax, ebx
				jg nu_a_consumat 
				
				add counter, 10
				
			nu_a_consumat :
				
			mov eax, banana_2_x
			
			banana_2 :
				cmp eax, minion_x
				jl nu_a_consumat_2
				
				mov ebx, minion_x
				add ebx, minion_width
				
				cmp eax, ebx
				jg nu_a_consumat_2 
				
				mov eax, banana_2_y
				
				cmp eax, minion_y
				jl nu_a_consumat_2
				
				mov ebx, minion_y
				add ebx, minion_height
				
				cmp eax, ebx
				jg nu_a_consumat_2 
				
				add counter, 10
			
			nu_a_consumat_2 :
			
	afisare_litere:
		; afisam valoarea counter-ului curent (sute, zeci si unitati)
		mov ebx, 10
		mov eax, counter
		
		; cifra unitatilor
		mov edx, 0
		div ebx
		add edx, '0'
		make_text_macro edx, area, 30, 10
		
		; cifra zecilor
		mov edx, 0
		div ebx
		add edx, '0'
		make_text_macro edx, area, 20, 10
		
		; cifra sutelor
		mov edx, 0
		div ebx 
		add edx, '0'
		make_text_macro edx, area, 10, 10
		
		; afisam caramizile
		desenare_caramida caramida_1_x, caramida_1_y, caramida_1_width
		desenare_caramida caramida_2_x, caramida_2_y, caramida_2_width
		desenare_caramida caramida_3_x, caramida_3_y, caramida_3_width
		
		; afisam bananele
		desenare_banana banana_1_x, banana_1_y, banana_1_width, banana_1_height
		desenare_banana banana_2_x, banana_2_y, banana_2_width, banana_2_height
		
		; afisare minionul 
		desenare_minion minion_x, minion_y, minion_width, minion_height
		
	final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp


start:
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	
	add esp, 4
	
	mov area, eax
	
	; apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char * title, int width, int height, unsigned int * area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	
	add esp, 20
	
	push 0
	call exit
end start