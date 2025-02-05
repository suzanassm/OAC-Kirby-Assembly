.include "MACROSv24.s"
.data
	.include "Map-One-Vegetable-Valley.s"
	.include "sprites_kirby_mov.s"
	
	deslocamento_x_mapa:	.word 0
	char_parameters:		.half 0, 0, 0		# estado, esq./dir., mov/parado
	char_pos: 				.half 120, 140, 0
	old_char_pos:			.half 120, 140
	
	changeTime: 			.word 0x00000000
	changeTime2: 			.word 0x00000000
		
	.eqv stnd1 500
	.eqv mov   300
	.eqv sleep 100
.text

# GAME SETUP
SETUP:	
	# printa o mapa no frame 0
	la t0, deslocamento_x_mapa		# label do deslocamento horizontal do mapa
	la a0, MapOneVegetableValley	# label do mapa 
	li a1, 0						# posição X inicial no bitmap 
	li a2, 30						# posição Y inicial no bitmap
	li a3, 0						# frame 
	lw a4, 0(t0)					# deslocamento horizontal 
	call print_map
# printa o mapa no frame 1	
	li a3, 1						# frame 
	call print_map
# printa o personagem no frame 0	
	la t0, char_pos					# label da posição inicial do personagem 
	la a0, sprites_kirby_mov		# label com sprites do personagem 
	lh a1, 0(t0)					# posição X inicial no bitmap  
	lh a2, 2(t0)					# posição Y inicial no bitmap
	li a3, 0 						# frame 
	la t0, char_parameters 			# label com parametros do personagem
	lh a4, 0(t0)					# estado atual do personagem
	lh a5, 2(t0)					# mov. para direita ou esquerda 
	call print_char
# printa o personagem no frame 1	
	li a3, 1
	call print_char
	
	
	
	
# GAME LOOP
GAME_LOOP:	
	la t0, changeTime2	
	lw t1, 0(t0)		# t1 <- tempo da ultima leitura de teclado
	csrr t2, time		# t2 <- tempo atual
	sub t3, t2, t1 		# t3 <- quanto tempo entre a ult leitura e o temp atual
	li t1, sleep			# tempo de pausa entre as leituras
	bgeu t3, t1 keyboard_input 	# deu o tempo ? le do tecaldo
	
		
# atualiza estado do personagem 
	la t0, char_parameters		
	lh a0, 0(t0)				# estado atual do personagem
	lh a1, 4(t0)				# parado ou em movimento
	call AtualizaEstado			
	la t0, char_parameters	
	sh a0, 0(t0)				# guarda o estado atualizado 
	
# inversão de frame
	mv a3, s0					# carrega o frame atual 
	xori a3, a3, 1				# inverte o frame
	 
# atualiza o mapa no frame que vai ser mostrado  
	la t0, deslocamento_x_mapa
	la a0, MapOneVegetableValley	# label do mapa a ser impress
	li a1, 0			# Define a posiÃ§Ã£o X no BITMAP onde o mapa comeÃ§a a ser printado 
	li a2, 30			# Define a posiÃ§Ã£o Y no BITMAP onde o mapa comeÃ§a a ser printado 
	lw a4, 0(t0)
	call print_map
# printa personagem atualizado no frame que vai ser mostrado 
	la t0, char_pos					# label da posição inicial do personagem 
	la a0, sprites_kirby_mov		# label com sprites do personagem 
	lh a1, 0(t0)					# posição X inicial no bitmap  
	lh a2, 2(t0)					# posição Y inicial no bitmap
	la t0, char_parameters 			# label com parametros do personagem
	lh a4, 0(t0)					# estado atual do personagem
	lh a5, 2(t0)					# mov. para direita ou esquerda 
	call print_char
# troca o frame 
	mv s0,a3
	li t0, 0xFF200604				# carrega em t0 o endereço de troca de frame 
	sw s0, 0(t0)					# mostra o sprite pronto 
# refaz o processo 
	j GAME_LOOP

.include "SYSTEMv24.s"	
.include "print_map.s"	
.include "print_char"
.include "AtualizaEstado.s"
.include "keyboard_input.s"
		
		
		
		
