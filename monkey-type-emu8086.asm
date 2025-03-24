ORG 100h
JMP inicio

mensaje_inicio DB 13,10,'--- MONKEY TYPE EN EMU8086 ---'
               DB 13,10,'Escribe las palabras exactamente como se muestran!'
               DB 13,10,'Presiona Enter para comenzar...$'
texto_objetivo DB 13,10,'el murcielago comia kiwi$'
resultados     DB 13,10,'--- RESULTADOS FINALES ---$'
precision_msg  DB 13,10,'Precision: $'
correctos_msg  DB 13,10,'Caracteres correctos: $'
total_msg      DB 13,10,'Total de caracteres: $'
porcentaje     DB '%$'
tiempo_msg     DB 13,10,'Tiempo total: $'
segundos_msg   DB ' segundos$'
lpm_msg        DB 13,10,'WPM: $'

caracteres_correctos DW 0
caracteres_totales   DW 24
buffer_entrada       DB 80 DUP(0)
longitud_entrada     DW 0
buffer_numero        DB 10 DUP('$')
tiempo_inicial       DW 0, 0
tiempo_final         DW 0, 0
tiempo_total         DW 0

inicio:
    MOV AX, @data
    MOV DS, AX
    MOV ES, AX

    MOV AH, 09h
    LEA DX, mensaje_inicio
    INT 21h

esperar_enter:
    MOV AH, 08h
    INT 21h
    CMP AL, 0Dh
    JNE esperar_enter

    CALL obtener_tiempo
    MOV [tiempo_inicial], CX  
    MOV [tiempo_inicial+2], DX 

    
    MOV AH, 09h
    LEA DX, texto_objetivo
    INT 21h
    
    MOV AH, 02h
    MOV DL, 13
    INT 21h
    MOV DL, 10
    INT 21h
    
    LEA DI, buffer_entrada      

leer_entrada:
    MOV AH, 01h
    INT 21h
    CMP AL, 0Dh     
    JE fin_entrada
    STOSB           
    INC [longitud_entrada]
    JMP leer_entrada

fin_entrada:
    CALL obtener_tiempo
    MOV [tiempo_final], CX
    MOV [tiempo_final+2], DX

    CALL calcular_tiempo

    CALL verificar_precision

    CALL mostrar_finales

    CALL mostrar_tiempo

    CALL mostrar_lpm

    MOV AX, 4C00h
    INT 21h

verificar_precision PROC
    LEA SI, texto_objetivo + 2  
    LEA DI, buffer_entrada
    MOV CX, [longitud_entrada]
    CMP CX, [caracteres_totales]
    JBE comparar
    MOV CX, [caracteres_totales]

comparar:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, BL
    JNE siguiente_caracter
    INC [caracteres_correctos]
siguiente_caracter:
    INC SI
    INC DI
    LOOP comparar
    RET
verificar_precision ENDP

mostrar_finales PROC
    MOV AH, 09h
    LEA DX, resultados
    INT 21h

    LEA DX, precision_msg
    INT 21h
    MOV AX, [caracteres_correctos]
    MOV BX, 100
    MUL BX
    MOV BX, [caracteres_totales]
    DIV BX
    CALL imprimir_numero
    LEA DX, porcentaje
    INT 21h

    LEA DX, correctos_msg
    INT 21h
    MOV AX, [caracteres_correctos]
    CALL imprimir_numero

    LEA DX, total_msg
    INT 21h
    MOV AX, [caracteres_totales]
    CALL imprimir_numero

    RET
mostrar_finales ENDP

imprimir_numero PROC
    LEA SI, [buffer_numero + 9]
    MOV BYTE PTR [SI], '$'
    MOV BX, 10
convertir:
    XOR DX, DX
    DIV BX
    ADD DL, 30h
    DEC SI
    MOV [SI], DL
    TEST AX, AX
    JNZ convertir
    MOV AH, 09h
    MOV DX, SI
    INT 21h
    RET
imprimir_numero ENDP

obtener_tiempo PROC
    MOV AH, 00h    
    INT 1Ah        
    RET
obtener_tiempo ENDP

calcular_tiempo PROC
    MOV AX, [tiempo_final+2]
    SUB AX, [tiempo_inicial+2] 
    XOR DX, DX                
    MOV BX, 18                
    DIV BX                    
    MOV [tiempo_total], AX
    RET
calcular_tiempo ENDP


mostrar_tiempo PROC
    MOV AH, 09h
    LEA DX, tiempo_msg
    INT 21h
    MOV AX, [tiempo_total]
    CALL imprimir_numero
    MOV AH, 09h
    LEA DX, segundos_msg
    INT 21h
    RET
mostrar_tiempo ENDP

mostrar_lpm PROC
    MOV AH, 09h
    LEA DX, lpm_msg
    INT 21h

    MOV BX, [tiempo_total]
    CMP BX, 0
    JE sin_tiempo

    MOV AX, [caracteres_correctos]
    XOR DX, DX
    DIV BX 
    MOV BX, 60
    MUL BX

    MOV BX, 5
    XOR DX, DX         
    DIV BX      

    CALL imprimir_numero
    JMP fin_mostrar_lpm

sin_tiempo:
    MOV AX, 0
    CALL imprimir_numero

fin_mostrar_lpm:
    RET
mostrar_lpm ENDP