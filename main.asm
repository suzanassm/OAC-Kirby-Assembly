.include "MACROSv24.s"

.data 
	.include "Map-One-Vegetable-Valley.s"
	.include "Kirby.s"
	.include "estrela.s"
	.include "sky.s"
	
	 map_x:     .word 0			# guarda o deslocamento horizontal do mapa
	CHAR_POS:   .half 140,140
	OLD_CHAR_POS:   .half 140,140   #x,y
	flag:		.byte 0
.text

SETUP:	#setup mapa
	la a0, MapOneVegetableValley	# label do mapa a ser impress
	li a1, 0			# Define a posição X no BITMAP onde o mapa começa a ser printado 
	li a2, 30			# Define a posição Y no BITMAP onde o mapa começa a ser printado 
	li a3,0 			# Define o frame
	la t0, map_x			
	lw a4 0(t0)			# carrega a posiçao X do MAPA
	jal Print
	

	
	
GAME_LOOP:
	#Processos de movimento	
	call KEY2
	#SO RENDERIZACAO A PARTIR DAQUI:
	#mv a3,s0			# carrega o frame atual (que esta na tela em a3)
	#xori a3,a3,1			# inverte a3 (0 vira 1, 1 vira 0)
	la a0, MapOneVegetableValley	# label do mapa a ser impress
	li a1, 0			# Define a posição X no BITMAP onde o mapa começa a ser printado 
	li a2, 30			# Define a posição Y no BITMAP onde o mapa começa a ser printado 
	mv a3, s0 			# Define o frame
	la t0, map_x			
	lw a4 0(t0)			# carrega a posiçao X do MAPA
	call Print
	

	#xori s0, s0, 1
	
	la t0,CHAR_POS			# carrega em t0 o endereco de CHAR_POS
	la a0,Kirby			# carrega o endereco do sprite 'char' em a0
	lh a1,0(t0)			# carrega a posicao x do personagem em a1
	lh a2,2(t0)			# carrega a posicao y do personagem em a2
	mv a3,s0			# carrega o valor do frame em a3
	li a4,0
	call Print			# imprime o sprite
		
	li t0,0xFF200604		# carrega em t0 o endereco de troca de frame
	sw s0,0(t0)			# mostra o sprite pronto para o usuario
		
	
	mv zero,a0
	la a0,flag 			# vai ler a flag e colocar as informacoes no a0
	li t0,1				# t0 recebe 1
	lb t1, 0(a0)			# t1 recebe as informcoes do a0
		
	beq t1,t0,SETUP2		# se a flag for VERDADEIRA, ou seja, ele chegou na porta e esta com a chave, o código vai fechar
	
	
	xori s0,s0,1
	
	
	
	j GAME_LOOP
KEY2:		
	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,FIM   	   	# Se nao ha tecla pressionada entao vai para FIM
  	lw t2,4(t1)  			# le o valor da tecla tecla
	
	li t0,'a'
	beq t2,t0,MAP_ESQ		# se tecla pressionada for 'a', chama CHAR_ESQ
	
	li t0,'d'
	beq t2,t0,MAP_DIR		# se tecla pressionada for 'd', chama CHAR_DIR
	
	li t0,'w'
	beq t2, t0, CHAR_CIMA
	
	li t0,'s'
	beq t2, t0, CHAR_BAIXO

FIM:	ret				# retorna	

MAP_ESQ:	
	la t0, map_x
	lw t1, 0(t0)
	addi t1, t1, -30
	sw t1, 0(t0)
	ret
MAP_DIR:	
	la t0, map_x
	lw t1, 0(t0)
	addi t1, t1, 30
	sw t1, 0(t0)
	ret	
	
CHAR_CIMA:	la t0,CHAR_POS			# carrega em t0 o endereco de CHAR_POS
		la t1,OLD_CHAR_POS		# carrega em t1 o endereco de OLD_CHAR_POS
		lw t2,0(t0)
		sw t2,0(t1)			# salva a posicao atual do personagem em OLD_CHAR_POS
		
		la t0,CHAR_POS
		lh t1,2(t0)			# carrega o y atual do personagem
		addi t1,t1,-16			# decrementa 16 pixeis
		sh t1,2(t0)			# salva
		ret
		
CHAR_BAIXO:    la t0,CHAR_POS			# carrega em t0 o endereco de CHAR_POS
		la t1,OLD_CHAR_POS		# carrega em t1 o endereco de OLD_CHAR_POS
		lw t2,0(t0)
		sw t2,0(t1)			# salva a posicao atual do personagem em OLD_CHAR_POS
		
		la t0,CHAR_POS
		lh t1,2(t0)			# carrega o y atual do personagem
		addi t1,t1,16			# decrementa 16 pixeis
		sh t1,2(t0)			# salva
		ret
SETUP2:
  ret
.include "Print.s"
.include "SYSTEMv24.s"

