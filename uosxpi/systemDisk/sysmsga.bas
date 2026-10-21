10 '================================
20 'EXIBIDOR DE MENSAGENS DA INTEGRACAO
30 'OPENMSX VIA RAM COMPARTILHADA
40 ' AUTOR: CLEVERSON SA
50 '================================
60 KEY OFF:SCREEN 0
100 ON INTERVAL=120 GOSUB 3000
105 INTERVAL ON
110 '===============================
120 ' TRAVANDO O PROGRAMA
130 '===============================
140 GOTO 140
200 '===============================
210 ' O FIM NO COMECO
220 '===============================
230 INTERVAL OFF
240 PRINT:PRINT:END
2000 '================================
2005 'LE A AREA COMPARTILHADA RAM
2010 '================================
2020 CM%=PEEK(&HCF00)
2030 A%=&HCF01:S$=""
2040 FOR I=1 TO 255
2050 VL%=PEEK(A%)
2060 IF VL%=0 THEN 2100
2070 IF VL%>=32 AND VL%<=126 THEN S$=S$+CHR$(VL%)
2080 IF VL%<32 AND VL%>126 THEN S$=S$+"?"
2090 A%=A%+1:NEXT I
2100 RETURN
3000 '=================================
3010 ' APRESENTACAO DA TELA
3020 '=================================
3030 CLS:PRINT STRING$(38,"=")
3040 PRINT "     UOSXPI - AVISO DE SISTEMA"
3050 PRINT STRING$(38,"=")
3100 '=================================
3110 ' LEITURA DA MEMORIA
3120 '=================================
3130 CM%=0:S$="":GOSUB 2000
3140 IF CM%<>&HF0 AND CM%<>&HFF THEN 3200
3150 BEEP:LOCATE 1,5:PRINT S$
3160 IF CM%=&HFF THEN 200
3200 '=================================
3210 ' RETORNO DO TIMER
3220 '=================================
3230 RETURN
