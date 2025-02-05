.text
# ----> Summary: render.s stores rendering related procedures
# 1 - RENDER (Renders image when address is given. It renders byte by byte (slow))
# 2 - RENDER WORD (Renders image when address is given. It renders word by word )
# 3 - RENDER COLOR (Renders a given color on a given space)
# 4 - RENDER PLAYER (Renders player based on its PLAYER_STATUS)

# N-2 - RENDER DOOR UPDATE (will render door after update is requested)
# N-1 - RENDER DOOR FRAMES (will render door frames over player)
# N - RENDER MAP (Takes a given map matrix and renders tiles acoording to the value stored on it)



#############################     RENDER     ############################
#   Renders image when address is given. It renders byte by byte (slow) #
#     -----------           argument registers           -----------    #
#       a0 = Image Address                                              #
#       a1 = X coordinate where rendering will start (top left)         #
#       a2 = Y coordinate where rendering will start (top left)         #
#       a3 = width of rendering area (usually the size of the sprite)   #
#       a4 = height of rendering area (usually the size of the sprite)  #
#       a5 = frame (0 or 1)                                             #
#       a6 = status of sprite (usually 0 for sprites that are alone)    #
#       a7 = operation (0 if normal printing, 1 cropped print)          #
# -- saved registers (recieved as arguments - only when on crop mode)-- #
#       s1 = X coordinate relative to sprite (top left)                 #
#       s2 = Y coordinate relative to sprite (top left)                 #
#       s3 = sprite width                                               #
#       s4 = sprite height                                              #
#     -----------          temporary registers           -----------    #
#       t0 = bitmap display printing address                            #
#       t1 = image address                                              #
#       t2 = line counter                                               #
#       t3 = column counter                                             #
#       t4 = temporary operations                                       #
#########################################################################
RENDER:
beqz a7,NORMAL
	CROP_MODE:	# When rendering cropped sprite 				
		add a0,a0,s1	# Image address + X on sprite 
		mul t3,s3,s2	# t3 = sprite width * Y on sprite
		add a0,a0,t3	# a0 = Image address + X on sprite + sprite widht * Y on sprite
		mul t4,a6,s4	# t4 = sprite status x height of rendering area (for files that have more than one sprite)
		mul t4,t4,s3	# t4 = sprite status x height of rendering area x sprite's width
		j START_RENDER
	NORMAL:
		mul t4,a6,a4	# t4 = sprite status x height of rendering area (for files that have more than one sprite)
		mul t4,t4,a3	# t4 = sprite status x height of rendering area x width of rendering area (on NORMAL_RENDER: a3 = sprite's width)
	
	START_RENDER:
		add a0,a0,t4	# Adds the dislocation calculated on t4 to the sprite's address
	#Propper rendering
	li t0,0x0FF0	#t0 = 0x0FF0
	add t0,t0,a5	# Rendering Address corresponds to 0x0FF0 + frame
	slli t0,t0,20	# Shifts 20 bits, making printing adress correct (0xFF00 0000 or 0xFF10 0000)
	add t0,t0,a1	# t0 = 0xFF00 0000 + X or 0xFF10 0000 + X
	li t1,320	# t1 = 320
	mul t1,t1,a2	# t1 = 320 * Y 
	add t0,t0,t1	# t0 = 0xFF00 0000 + X + (Y * 320) or 0xFF10 0000 + X + (Y * 320)
	
	mv t2,zero	# t2 = 0 (Resets line counter)
	mv t3,zero	# t3 = 0 (Resets column counter)
	
	PRINT_LINE:	
		lb t4,0(a0)	# loads byte(1 pixel) on t4
		
		# Comparing if samus is on missile mode
		li t5,green # Loads 32 (value of green pixel in samus)
		bne t5,t4,SKIP_SWITCH
			la t5, PLYR_INFO_2    # Loads address to PLYR_INFO_2
			lbu t5,0(t5)          # Loads missile enable byte
			beqz t5,SKIP_SWITCH   # If player isn't in missile mode
				li t4 cyan        # Otherwise render cyan instead of green
		SKIP_SWITCH:
		
		sb t4,0(t0)	# prints 1 pixel from t4
		
		addi t0,t0,1	# increments bitmap address
		addi a0,a0,1	# increments image address
		
		addi t3,t3,1		# increments column counter
		blt t3,a3,PRINT_LINE	# if column counter < width, repeat
		
		addi t0,t0,320	# goes to next line on bitmap display
		sub t0,t0,a3	# goes to right X on bitmap display (current address - width)
		
		beqz a7, NORMAL_RENDER	# If not on crop mode
		CROP_RENDER:
			add a0,a0,s3	# a0 += sprite width	
			sub a0,a0,a3	# a0 -= rendering width

		NORMAL_RENDER: 
			mv t3,zero		# t3 = 0 (Resets column counter)
			addi t2,t2,1		# increments line counter
			bgt a4,t2,PRINT_LINE	# if height > line counter, repeat
			ret

###########################    RENDER WORD    ###########################
#   Renders image when address is given. It renders word by word        #
#     -----------           argument registers           -----------    #
#       a0 = Image Address                                              #
#       a1 = X coordinate where rendering will start (top left)         #
#       a2 = Y coordinate where rendering will start (top left)         #
#       a3 = width of rendering area (usually the size of the sprite)   #
#       a4 = height of rendering area (usually the size of the sprite)  #
#       a5 = frame (0 or 1)                                             #
#       a6 = status of sprite (usually 0 for sprites that are alone)    #
#       a7 = operation (0 if normal printing, 1 cropped print)          #
# -- saved registers (recieved as arguments - only when on crop mode)-- #
#       s1 = X coordinate relative to sprite (top left)                 #
#       s2 = Y coordinate relative to sprite (top left)                 #
#       s3 = sprite width                                               #
#       s4 = sprite height                                              #
#     -----------          temporary registers           -----------    #
#       t0 = bitmap display printing address                            #
#       t1 = image address                                              #
#       t2 = line counter                                               #
#       t3 = column counter                                             #
#       t4 = temporary operations                                       #
#########################################################################
RENDER_WORD:
beqz a7,NORMAL_WORD
	CROP_MODE_WORD:	# When rendering cropped sprite	
		add a0,a0,s1	# Image address + X on sprite 
		mul t3,s3,s2	# t3 = sprite width * Y on sprite
		add a0,a0,t3	# a0 = Image address + X on sprite + sprite widht * Y on sprite
		mul t4,a6,s4	# t4 = sprite status x height of rendering area (for files that have more than one sprite)
		mul t4,t4,s3	# t4 = sprite status x height of rendering area x sprite's width
		j START_RENDER_WORD
	NORMAL_WORD:		# Executed even if on crop mode
		mul t4,a6,a4	# t4 = sprite status x height of rendering area (for files that have more than one sprite)
		mul t4,t4,a3	# t4 = sprite status x height of rendering area x width of rendering area (on NORMAL_RENDER: a3 = sprite's width)

	START_RENDER_WORD:
		add a0,a0,t4	# Adds the dislocation calculated on t4 to the sprite's address
	#Propper rendering
	li t0,0x0FF0	#t0 = 0x0FF0
	add t0,t0,a5	# Rendering Address corresponds to 0x0FF0 + frame
	slli t0,t0,20	# Shifts 20 bits, making printing adress correct (0xFF00 0000 or 0xFF10 0000)
	add t0,t0,a1	# t0 = 0xFF00 0000 + X or 0xFF10 0000 + X
	li t1,320	# t1 = 320
	mul t1,t1,a2	# t1 = 320 * Y 
	add t0,t0,t1	# t0 = 0xFF00 0000 + X + (Y * 320) or 0xFF10 0000 + X + (Y * 320)
	
	mv t2,zero	# t2 = 0 (Resets line counter)
	mv t3,zero	# t3 = 0 (Resets column counter)
	
	
	PRINT_LINE_WORD:	
		lb t4,0(a0)	# loads word(4 pixels) on t4
		sb t4,0(t0)	# prints 4 pixels from t4
		
		addi t0,t0,1	# increments bitmap address
		addi a0,a0,1	# increments image address
		
		addi t3,t3,1		# increments column counter
		blt t3,a3,PRINT_LINE_WORD	# if column counter < width, repeat
		
		addi t0,t0,320	# goes to next line on bitmap display
		sub t0,t0,a3	# goes to right X on bitmap display (current address - width)
		
		beqz a7, NORMAL_RENDER_WORD	# If not on crop mode
		CROP_RENDER_WORD:
			add a0,a0,s3	# a0 += sprite width	
			sub a0,a0,a3	# a0 -= rendering width

		NORMAL_RENDER_WORD: 
			mv t3,zero		# t3 = 0 (Resets column counter)
			addi t2,t2,1		# increments line counter
			bgt a4,t2,PRINT_LINE_WORD	# if height > line counter, repeat
			ret



############################## RENDER COLOR #############################
#                Renders a given color on a given space                 #
#     -----------           argument registers           -----------    #
#       a0 = color                                                      #
#       a1 = X coordinate where rendering will start (top left)         #	
#       a2 = Y coordinate where rendering will start (top left)         #
#       a3 = width of printing area (usually the size of the sprite)    #
#       a4 = height of printing area (usually the size of the sprite)   #
#       a5 = frame (0 or 1)                                             #
#       a6 = operation (0 - rendering 4 pixels at once;                 #
#                       1 -  rendering 2 pixels at once)                #	
#     -----------          temporary registers           -----------    #
#       t0 = bitmap display printing address                            #
#       t1 = temporary operations                                       #
#       t2 = line counter                                               #
#       t3 = column counter                                             # 
#########################################################################

RENDER_COLOR:
	li t0,0xFF0	# t0 = 0xFF0
	add t0,t0,a5	# Rendering Address corresponds to 0x0FF0 + frame
	slli t0,t0,20	# Shifts 20 bits, making printing adress correct (0xFF00 0000 or 0xFF10 0000)
	
	add t0,t0,a1	# t0 = 0xFF00 0000 + X or 0xFF10 0000 + X
	
	li t1,320	# t1 = 320
	mul t1,t1,a2	# t1 = 320 * Y 
	add t0,t0,t1	# t0 = 0xFF00 0000 + X + (Y * 320) or 0xFF10 0000 + X + (Y * 320)
	
	mv t2,zero	# t2 = 0 (Resets line counter)
	mv t3,zero	# t3 = 0 (Resets column counter)
	
	slli t1,a0,8	# Shifts 8 bits on a0
	add a0,a0,t1	# a0 now stores two bytes of the same color (e.g.: 0x000000FF -> 0x0000FFFF)
	
	bnez a6, PRINT_LINE_COLOR_HALF # If not printing 4 pixels at once
		slli t1,a0,16	       # Shifts 16 bits on a0
		add a0,a0,t1	       # a0 now stores four bytes of the same color (e.g.: 0x0000FFFF -> 0xFFFFFFFF)
		j PRINT_LINE_COLOR_WORD
		
	PRINT_LINE_COLOR_HALF:	
		sh a0,0(t0)	# Renders two color pixels at once
		addi t0,t0,2	# increments bitmap address by 2 bytes
		
		addi t3,t3,2			# increments column counter
		blt t3,a3,PRINT_LINE_COLOR_HALF	# if column counter < width, repeat
		
		addi t0,t0,320	# goes to next line on bitmap display
		sub t0,t0,a3	# goes to right X on bitmap display (current address - width)
		
		mv t3,zero			# t3 = 0 (resets column counter)
		addi t2,t2,1			# increments line counter
		bgt a4,t2,PRINT_LINE_COLOR_HALF	# if height > line counter, repeat
		ret			
		
	PRINT_LINE_COLOR_WORD:
		sw a0,0(t0)	# Renders four color pixels at once
		addi t0,t0,4	# increments bitmap address by 4 bytes
		
		addi t3,t3,4			# increments column counter
		blt t3,a3,PRINT_LINE_COLOR_WORD	# if column counter < width, repeat
		addi t0,t0,320	# goes to next line on bitmap display
		sub t0,t0,a3	# goes to right X on bitmap display (current address - width)
		
		mv t3,zero			# t3 = 0 (resets column counter)
		addi t2,t2,1			# increments line counter
		bgt a4,t2,PRINT_LINE_COLOR_WORD	# if height > line counter, repeat
		ret