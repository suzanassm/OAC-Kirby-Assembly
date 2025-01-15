Print:
 	 # Coloca em t0 o ENDERECO INICIAL DO BITMAP  de acordo com o FRAME a3
 	 #t0 = endereço bitmap; a3 = frame
	 li t0, 0xFF0 # carrega 0xFF0 em t0
	 add t0, t0, a3 # adiciona o frame a FF0
	 slli t0, t0, 20 # shift de 20 bits pra esquerda
	 
	 # carrega a posição inicial (x,y) onde a imagem começa a ser printada no bitmap
	 # posição inicial = t0(inicial) + x + 320*y
	 # o acréscimo de um byte na altura corresponde a 320 bytes no vetor de cores
	 add t0, t0, a1 # adiciona x ao t0
	 li t1, 320 # t1 = 320
	 mul t1, t1, a2 # multiplica y por t1
	 add t0, t0, t1 # coloca o endereco em t0
	 
	 #a0 = endereço da imagem, t1 = cont. linhas, t2 = cont. colunas
	 #t3 = largura, t4 = altura
	 #a4 = posição X onde o mapa começa a ser printado 
	 # t6 = a0 = endereço da imagem
	
	mv t6, a0 # data em t6 para nao mudar a0
	lw t3,0(t6) # carrega a largura em t3
	lw t4, 4(t6) # carrega a altura em t4
	addi t6, t6, 8 # primeira cor em t6
	add  t6, t6, a4 # posição X inicial do mapa a ser printado
	li t1, 320
	mul t1, a5, t1
	add t6, t6, t1 
	mv t1, zero # zera t1
	mv t2, zero # zera t2
	 
 PrintLinha:
 	 #printando o bit t6 da imagem, no endereço t5 do bitmap
	 lbu t5, 0(t6) # carrega em t5 um byte da imagem
	 sb t5, 0(t0) # imprime no bitmap o byte da imagem
	 
	 addi t0, t0, 1 # incrementa endereco do bitmap
	 addi t6, t6, 1 # incrementa endereco da imagem
	 addi t2, t2, 1 # incrementa contador de coluna
	 
	 blt t2, t3, PrintLinha # cont da coluna < largura ?
	 
	 addi t0, t0, 320 # t0 += largura do bitmap
	 sub t0, t0, t3 # t0-= largura da imagem
	 
	 mv t2, zero # zera t2 (cont de coluna)
	 addi t1, t1, 1 # incrementa contador de linha
	 
	 bgt t4, t1, PrintLinha # altura > contador de linha ?
	 ret # retorna