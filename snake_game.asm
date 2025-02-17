.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc
extern fprintf: proc
extern fclose: proc
extern fopen: proc
extern fgetc: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Snake Game",0
area_width EQU 640
area_height EQU 640
area DD 0

format db "%d",0
format2 db "%d %d",0
counter DD 0 ; numara evenimentele de tip timer
scor DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

 button_x equ 60
 button_y equ 57
 button_size equ 400

image_width EQU 38
image_height EQU 38
include corp.inc;var_1
include patratel.inc;var_0
include fruct.inc;var_2
include zid.inc
image_width1 EQU 5
image_height1 EQU 400

patrat_x dd 120, 100 dup (0)
patrat_y dd 100,100 dup (0)
patrat_xverif dd 0
patrat_yverif dd 0

patrat_x1 dd 82
patrat_y2 dd 100

inaltime dd 0
inaltime2 dd 0
a_mancat_fructul dd 0
a_mancat_corpul dd 0

sa_facut_sus dd 0
sa_facut_jos dd 0
sa_facut_stanga dd 0
sa_facut_dreapta dd 0

poz_x dd 100
poz_y dd 150
verif_tasta dd 0
new_poz_x dd 0
new_poz_y dd 0

sf_joc dd 0

mode_write db "a+", 0 
filename db "scor.txt", 0
f dd 0
formatd db "%d",10, 0
afisare_scor dd 0
caracter dd 0
formatc db "%c", 0
var1 dd 510
var2 dd 60
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
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
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
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

make_image proc

	push ebp
	mov ebp, esp
	pusha

	lea esi, var_0
	
draw_image:
	mov ecx, image_height
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	
	popa
	mov esp, ebp
	pop ebp
	ret
make_image endp

;simple macro to call the procedure easier
make_image_macro macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_image
	add esp, 12
endm

make_image2 proc

	push ebp
	mov ebp, esp
	pusha

	lea esi, var_1
draw_image2:
	mov ecx, image_height
loop_draw_lines2:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width ; store drawing width for drawing loop
	
loop_draw_columns2:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns2
	
	pop ecx
	loop loop_draw_lines2
	
	popa
	mov esp, ebp
	pop ebp
	ret
make_image2 endp

;simple macro to call the procedure easier
make_image_macro2 macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_image2
	add esp, 12
endm

make_image3 proc

	push ebp
	mov ebp, esp
	pusha

	lea esi, var_3
draw_image3:
	mov ecx, image_height1
loop_draw_lines3:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height1 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width1 ; store drawing width for drawing loop
	
loop_draw_columns3:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns3
	
	pop ecx
	loop loop_draw_lines3
	
	popa
	mov esp, ebp
	pop ebp
	ret
make_image3 endp

;simple macro to call the procedure easier
make_image_macro4 macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_image3
	add esp, 12
endm


fruct proc

	push ebp
	mov ebp, esp
	pusha

	lea esi, var_2
draw_image3:
	mov ecx, image_height
loop_draw_lines3:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width ; store drawing width for drawing loop
	
loop_draw_columns3:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns3
	
	pop ecx
	loop loop_draw_lines3
	
	popa
	mov esp, ebp
	pop ebp
	ret
fruct endp

;simple macro to call the procedure easier
make_image_macro3 macro drawArea, x, y
	push y
	push x
	push drawArea
	call fruct
	add esp, 12
endm

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
line_horizontal macro x,y,len,color
local bucla_line

    mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax , area
	mov ecx,len
	
	bucla_line:
	mov dword ptr[eax],color
	add eax,4
	loop bucla_line
	
endm

line_vertical macro x,y,len,color
local bucla_line

    mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax , area
	mov ecx,len
	
	bucla_line:
	mov dword ptr[eax],color
	add eax,area_width*4
	loop bucla_line
	
endm

 generare_val_random macro x,y
 local alegere1,alegere2
    push eax
	push edx
	
	alegere1:
	rdtsc
	shr eax,23
	cmp eax,60
	jle alegere1
	cmp eax,420
	jge alegere1
	
	mov x,eax
	
	alegere2:
	rdtsc
	shr eax,23
	cmp eax,57
	jle alegere2
	cmp eax,419
	jge alegere2
	
	mov y,eax
	
	pop edx
	pop eax
	
 endm
 
 
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
creare_sarpe proc
    push ebp
	mov ebp, esp
	pusha
	
	mov esi, [ebp+arg1]
	
	cmp sa_facut_dreapta,1
	je dr
	 cmp sa_facut_jos,1
	je joz
	cmp sa_facut_sus,1
	je su
	cmp sa_facut_stanga,1
	je stg
	
	dr:
	sub esi,1
	mov edx,patrat_x[4*esi]
	add esi,1
	sub edx,38
	mov patrat_x[4*esi],edx
	sub esi,1
	mov edx,patrat_y[4*esi]
	add esi,1
	mov patrat_y[4*esi],edx
	jmp finall
	
	stg:
	sub esi,1
	mov edx,patrat_x[4*esi]
	add esi,1
	add edx,38
	mov patrat_x[4*esi],edx
	sub esi,1
	mov edx,patrat_y[4*esi]
	add esi,1
	mov patrat_y[4*esi],edx
	jmp finall
	
	joz:
	sub esi,1
	mov edx,patrat_y[4*esi]
	add esi,1
	sub edx,38
	mov patrat_y[4*esi],edx
	sub esi,1
	mov edx,patrat_x[4*esi]
	add esi,1
	mov patrat_x[4*esi],edx
	jmp finall
	
	su:
	sub esi,1
	mov edx,patrat_y[4*esi]
	add esi,1
	add edx,38
	mov patrat_y[4*esi],edx
	sub esi,1
	mov edx,patrat_x[4*esi]
	add esi,1
	mov patrat_x[4*esi],edx
	jmp finall
	
    finall:
	popa
	mov esp, ebp
	pop ebp
	ret
creare_sarpe endp

draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	cmp eax, 3
	jz evt_tasta ; nu s-a apasat  nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	jmp afisare_litere
	
evt_click:

	jmp afisare_litere
	
evt_tasta:
      
	cmp sf_joc,1
	jne continua
	mov scor,0
	mov sf_joc,0
	mov a_mancat_corpul,0
	
	mov patrat_x,120
	mov patrat_y,100
	mov verif_tasta,0
	mov afisare_scor, 0
	
	mov var1, 510
	mov var2, 60
	jmp afisare_litere
	
	
	 
	continua:
	mov verif_tasta,1
	
	mov eax, [ebp+arg2]
	cmp eax, '('
	je jos
	cmp eax, '&'
	je sus
	cmp eax, "'"
	je dreapta
	cmp eax, '%'
	je stanga
	
	sus:
	cmp sa_facut_jos, 1
	je final
	cmp sa_facut_sus, 1
	je final
	sub patrat_y[0],10
	mov sa_facut_sus, 1
	mov sa_facut_jos, 0
	mov sa_facut_dreapta, 0
	mov sa_facut_stanga, 0
	jmp final
	
	jos:
	cmp sa_facut_sus, 1
	je final
	cmp sa_facut_jos, 1
	je final
	add patrat_y[0],10
	mov sa_facut_sus, 0
	mov sa_facut_jos, 1
	mov sa_facut_dreapta, 0
	mov sa_facut_stanga, 0
	jmp final
	
	stanga:
	cmp sa_facut_dreapta, 1
	je final
	cmp sa_facut_stanga, 1
	je final
	mov sa_facut_sus, 0
	mov sa_facut_jos, 0
	mov sa_facut_dreapta, 0
	mov sa_facut_stanga, 1
	sub patrat_x[0],10
	jmp final
	
	dreapta:
	cmp sa_facut_stanga, 1
	je final
	cmp sa_facut_dreapta, 1
	je final
	mov sa_facut_sus, 0
	mov sa_facut_jos, 0
	mov sa_facut_dreapta, 1
	mov sa_facut_stanga, 0
	add patrat_x[0],10
	
final:
	
	jmp afisare_litere
	
evt_timer:

    
	push eax
	mov eax,patrat_x[0]
	add eax,38
	mov patrat_xverif,eax
	pop eax
	
	cmp patrat_xverif,button_x+button_size
	jnl geme_over
	
	cmp patrat_x[0],button_x
	jng geme_over
	
	push eax
	mov eax,patrat_y[0]
	add eax,38
	mov patrat_yverif,eax
	pop eax
	
	cmp patrat_yverif,button_y+button_size
	jnl geme_over
	
	cmp patrat_y[0],button_y
	jng geme_over
	
   cmp verif_tasta,1
   jne afisare_litere
 
   push eax
   
   mov eax,poz_x
   add eax,38
   add eax,poz_x
   shr eax,1;centrul patartului pe Ox
   
   push ebx
   
   mov ebx,patrat_x[0]
   add ebx,38
   
	 cmp eax,patrat_x[0]
	 jl contt
	 cmp eax,ebx
	 jg contt
	 
	 
	  mov eax,poz_y
   add eax,38
   add eax,poz_y
   shr eax,1;centrul patartului pe Ox
   
   
   mov ebx,patrat_y[0]
   add ebx,38
   
	 cmp eax,patrat_y[0]
	 jl contt
	 cmp eax,ebx
	 jg contt
	 
   mov a_mancat_fructul,1
    
	contt:
	pop eax
	pop ebx
	
	
	
	cmp scor,4
	jl treci
	;verificare daca si a mancat coada
	push eax
	push ebx
	push ecx
	push edx
	push esi
	
	mov esi,scor
	bucla:
	cmp esi,4
	jl asta
	mov eax,patrat_x[4*esi]
   add eax,38
   add eax,patrat_x[4*esi]
   shr eax,1;centrul patartului pe Ox
	mov ebx,patrat_x[0]
   add ebx,38
   
	 cmp eax,patrat_x[0]
	 jl continua2
	 cmp eax,ebx
	 jg continua2
	 
	mov eax,patrat_y[4*esi]
   add eax,38
   add eax,patrat_y[4*esi]
   shr eax,1;centrul patartului pe Ox
   
   
   mov ebx,patrat_y[0]
   add ebx,38
   
	 cmp eax,patrat_y[0]
	 jl continua2
	 cmp eax,ebx
	 jg continua2 
   mov a_mancat_corpul,1
	continua2:dec esi
	jmp bucla
	
	asta:
	
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	cmp a_mancat_corpul,1
	je geme_over
	
	
	treci:
	push eax
	mov eax,scor
	
	cmp scor,0
	je sari
	
	
	mutare:
	sub eax,1
	mov edx,patrat_y[eax*4]
	add eax,1
	mov patrat_y[4*eax],edx
	
	sub eax,1
	mov edx,patrat_x[4*eax]
	add eax,1
	mov patrat_x[4*eax],edx
	sub eax,1
	cmp eax,1
	jge mutare
	sari:
	pop eax
	
	cmp sa_facut_dreapta,1
	je dreaptaa
	cmp sa_facut_stanga,1
	je stangaa
	cmp sa_facut_sus,1
	je suss
	cmp sa_facut_jos,1
	je joss
	

	dreaptaa:
	
	cmp scor,0
	je next
	mov ebx,scor
	mov edx,1
	incetinire:
	cmp ebx,0
	jge next
	  sub patrat_x[4*ebx],edx
	 dec ebx
	 jmp incetinire
	next:
	push eax
	mov eax,patrat_x[0]
	add eax,10
	mov patrat_x[0],eax
	pop eax
	jmp afisare_litere
	
	
	stangaa:
	
	cmp scor,0
	je next2
	mov ebx,scor
	mov edx,1
	incetinire2:cmp ebx,0
	jge next2
	  add patrat_x[4*ebx],edx
	 dec ebx
	 jmp incetinire2
	next2:
	push eax
	mov eax,patrat_x[0]
	sub eax,10
	mov patrat_x[0],eax
	pop eax
	jmp afisare_litere
	
	joss:
	
	cmp scor,0
	je next3
	mov ebx,scor
	mov edx,1
	incetinire3:
	cmp ebx,0
	jge next3
	  sub patrat_y[4*ebx],edx
	 dec ebx
	 jmp incetinire3
	next3:
	push eax
	mov eax,patrat_y[0]
	add eax,10
	mov patrat_y[0],eax
	pop eax
	jmp afisare_litere
	
	suss:
	
	cmp scor,0
	je next4
    mov ebx,scor
	mov edx,1
	incetinire4:
	cmp ebx,0
	jge next4
	  add patrat_y[4*ebx],edx
	 dec ebx
	 jmp incetinire4
	next4:
	push eax
	mov eax,patrat_y[0]
	sub eax,10
	mov patrat_y[0],eax
	pop eax
	
	
	
    

afisare_litere:

    mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	;coloreaza patratul cu verde
	mov ecx,button_size
	mov inaltime, button_y
bucla_colorare:
	push ecx
	line_horizontal button_x+1 ,inaltime, button_size,00FF00h
	pop ecx
	inc inaltime
	loop bucla_colorare
	make_image_macro4  area, 60,57
	make_image_macro4  area, 460,57
	
	verif:cmp a_mancat_fructul,0
	je cont2;daca nu a mancat fructul nu face un nou fruct
	generare_val_random new_poz_x,new_poz_y
	make_image_macro3 area, new_poz_x,new_poz_y;daca l a mancat face un nou fruct la o noua pozitie (generata-in loc de 120 si 150 o sa fie new_poz_x si new_poz_y)
	inc scor
	
	mov esi,scor
	push esi
	call creare_sarpe
	add esp,4
	
	make_image_macro2 area, patrat_x[4*esi],patrat_y[4*esi]
	
	
	mov a_mancat_fructul,0
	;actualizam pozitiile 
	push eax 
	mov eax,new_poz_x
	mov poz_x,eax;in loc de 120 si 150 o sa fie new_poz_x si new_poz_y
	mov eax,new_poz_y
	mov poz_y,eax
	pop eax
	jmp cont
	cont2:make_image_macro3 area, poz_x,poz_y;daca nu l a mancat ramane fructul la vechea pozitite
	mov a_mancat_fructul,0
	cont:

	cmp scor,0
	je nu
	mov ecx,scor
	mov esi,1
	creare_corp:
	make_image_macro2 area, patrat_x[4*esi],patrat_y[4*esi]
	add esi,1
	loop creare_corp
	
	nu:
	make_image_macro area, patrat_x[0],patrat_y[0]
    
	make_text_macro 'S', area, 10, 10
	make_text_macro 'C', area, 20, 10
	make_text_macro 'O', area, 30, 10
	make_text_macro 'R', area, 40, 10

	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, scor
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 80, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 70, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 60, 10
	
	;scriem un mesaj
	make_text_macro 'S', area, 200, 10
	make_text_macro 'N', area, 210, 10
	make_text_macro 'A', area, 220, 10
	make_text_macro 'K', area, 230, 10
	make_text_macro 'E', area, 240, 10
	
	make_text_macro 'G', area, 260, 10
	make_text_macro 'A', area, 270, 10
	make_text_macro 'M', area, 280, 10
	make_text_macro 'E', area, 290, 10
	
	 make_text_macro 'H', area, 400, 10
	 make_text_macro 'O', area, 410, 10
	 make_text_macro 'R', area, 420, 10
	 make_text_macro 'G', area, 430, 10
	 make_text_macro 'A', area, 440, 10
	
	 make_text_macro 'A', area, 460, 10
	 make_text_macro 'N', area, 470, 10
	 make_text_macro 'A', area, 480, 10
	

	line_horizontal button_x ,button_y, button_size,0
	line_horizontal button_x ,button_y+button_size, button_size,0
	line_vertical button_x ,button_y, button_size,0
	line_vertical button_x+button_size ,button_y, button_size,0
	
	
	
	
	jmp final_draw
	
geme_over:
    mov sf_joc,1
	inc afisare_scor
    make_text_macro 'G', area, 260, 200
	make_text_macro 'A', area, 270, 200
	make_text_macro 'M', area, 280, 200
	make_text_macro 'E', area, 290, 200
	make_text_macro ' ', area, 300, 200
	make_text_macro 'O', area, 310, 200
	make_text_macro 'V', area, 320, 200
	make_text_macro 'E', area, 330, 200
	make_text_macro 'R', area, 340, 200
	
	make_text_macro 'S', area, 510, 40
	make_text_macro 'C', area, 520, 40
	make_text_macro 'O', area, 530, 40
	make_text_macro 'R', area, 540, 40
	make_text_macro 'U', area, 550, 40
	make_text_macro 'R', area, 560, 40
	make_text_macro 'I', area, 570, 40
	
	
	cmp afisare_scor, 1
	jne final_draw
	;deschiderea fisierului
	push offset mode_write
	push offset filename
	call fopen
	add esp, 8
	mov f, eax
	
	;scrierea in fisier
	push scor
	push offset formatd
	push f
	call fprintf
	add esp, 12

	;inchiderea fisierului
	push f
	call fclose
	add esp, 4
	;;;;;;;;;;;;printeaza pe zona de joc scorurile din fisier
	
	;deschiderea fisierului
	push offset mode_write
	push offset filename
	call fopen
	add esp, 8
	mov f, eax
	
citire:
    
	push f
	call fgetc
	add esp, 4
	mov caracter, eax
	
	add var2, 20
	 make_text_macro caracter, area, var1, var2
	
	cmp caracter, -1
	jne citire
	
	;inchiderea fisierului
	push f
	call fclose
	add esp, 4
   
	
final_draw:

	
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
