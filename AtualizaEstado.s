AtualizaEstado:
	beqz a1, estado0	# estado = 0
	la t0, changeTime	# estado = 5
	lw t1, 0(t0)		# t1 <- tempo da ultima troca de pose
	csrr t2, time		# t2 <- tempo atual
	sub t3, t2, t1 		# t3 <- quanto tempo a pose atual esta na tela
	li t1, mov			# tempo que a pose atual deve ficar
	bgeu t3, t1 mudaEstadoMov 	# deu o tempo ? muda o estado
fimAtualizaEstado: 
	ret

estado0:
	la t0, changeTime	# estado = 5
	lw t1, 0(t0)		# t1 <- tempo da ultima troca de pose
	csrr t2, time		# t2 <- tempo atual
	sub t3, t2, t1 		# t3 <- quanto tempo a pose atual esta na tela
	li t1, stnd1			# tempo que a pose atual deve ficar
	bgeu t3, t1 mudaEstadoParado 	# deu o tempo ? muda o estado
	j  fimAtualizaEstado
		
mudaEstadoParado:
	xori a0, a0, 1
	la t0, changeTime
	sw t2, 0(t0)
	j fimAtualizaEstado
mudaEstadoMov:
	la t0, changeTime
	sw t2, 0(t0)
	li t0, 5
	bge  a0, t0, frst_mov_stt
	addi a0, a0, 1
	j fimAtualizaEstado
frst_mov_stt:
	mv a0, zero
	addi a0, a0, 2
	j fimAtualizaEstado
	
