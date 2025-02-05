keyboard_input:		
# guarda o tempo da leitura atual
	la t0, changeTime2
	sw t2, 0(t0)

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)				# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,NONE   	   	# Se nao ha tecla pressionada entao vai para FIM
  	lw t2,4(t1)  			# le o valor da tecla tecla
	
	li t0,'a'
	beq t2,t0,MAP_ESQ		# se tecla pressionada for 'a', chama CHAR_ESQ
	
	li t0,'d'
	beq t2,t0,MAP_DIR		# se tecla pressionada for 'd', chama CHAR_DIR
	
NONE:	
# se nenhuma tecla foi pressionada, atualiza o estado do pers. para parado
	la t0, char_parameters
	lh t1, 4(t0)
	beqz t1, FIM
	sh zero, 4(t0)
	sh zero, 0(t0)
FIM: ret				# retorna

MAP_ESQ:	
	la t0, char_pos				 
	lh t1, 0(t0)				# posição x do personagem
	li t2, 120					# se pos > 120
	bgt t1, t2, KIR_MOV_ESQ		# decrememnte a pos do personagem
	
	la t0, deslocamento_x_mapa			 
	lw t1, 0(t0)					# posição horizontal atual 
	beqz t1, KIR_MOV_ESQ			# se o mapa já estiver na posição 0, decrememnte a pos. do kirby
	addi t1, t1, -4					# caso contrario, decrememnte a posição do mapa
	j CON1
	
# decrementa a posição do kirby
KIR_MOV_ESQ:
	la t0, char_pos
	lh t1, 0(t0)
	beqz t1, CON1
	addi t1, t1, -4
	sh  t1,0(t0)
# guarda a posição atual e atualiza o estado para movimentando
CON1:	
	sh t1, 0(t0)	
	la t0, char_parameters
	li t1, 1
	sh t1, 2(t0)		
	sh t1, 4(t0)	
	ret
	
	##########
	#ADD se deslocamento < 30 ou > 680
MAP_DIR:	
	la t0, char_pos
	lh t1, 0(t0)		# pos atual do kirby
	li t2, 296			# pos maxima do kirby
	bge t1, t2, CON2	# se o kirby esta na posição maxima, nao altere nada
	li t2, 120			
	ble t1, t2, KIR_MOV_DIR	# se kirby tiver abaixo da posição inicial, incremente a pos. do kirby
	la t0, deslocamento_x_mapa	
	lw t1, 0(t0)
	li t2, 696
	bge t1, t2, KIR_MOV_DIR
	addi t1, t1, 4			# incrememnta a posição do mapa
	j CON2
# incrementa a posição do kirby 
KIR_MOV_DIR:
	la t0, char_pos
	lh t1, 0(t0)
	addi t1, t1, 4
# guarda os paramteros atualizados
CON2:
	sh t1, 0(t0)
	la t0, char_parameters
	li t1, 0
	sh t1, 2(t0)
	li t1, 1
	sh t1, 4(t0)
	ret	