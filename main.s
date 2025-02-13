.include "MACROSv24.s"
.data
	.include "Map-One-Vegetable-Valley.s"
	.include "sprites_kirby_mov.s"
	.include "tiles.s"
	
	
	deslocamento_x_mapa:	.word 0
	char_parameters:		.half 0, 0, 0		# estado, esq./dir., mov/parado
	char_pos: 				.half 120, 140, 0
	old_char_pos:			.half 120, 140
	
	changeTime: 			.word 0x00000000
	changeTime2: 			.word 0x00000000
	framebuffer: 			.word 0xFF200604
		
	.eqv stnd1 500
	.eqv mov   300
	.eqv sleep 100
.text

.text
# GAME SETUP
SETUP:
    # Load framebuffer address
    la a2, framebuffer
    lw a2, 0(a2)

    # Print the map on frame 0
    li a3, 0  # Frame 0
    jal PrintMap

    # Print the map on frame 1
    li a3, 1  # Frame 1
    jal PrintMap

    # Print the character on frame 0
    la t0, char_pos
    la a0, sprites_kirby_mov
    lh a1, 0(t0)  # x position
    lh a2, 2(t0)  # y position
    li a3, 0      # Frame 0
    la t0, char_parameters
    lh a4, 0(t0)  # state
    lh a5, 2(t0)  # direction
    jal PrintChar

    # Print the character on frame 1
    li a3, 1      # Frame 1
    jal PrintChar

# GAME LOOP
GAME_LOOP:
    # Check for keyboard input
    la t0, changeTime2
    lw t1, 0(t0)  # Last input time
    csrr t2, time # Current time
    sub t3, t2, t1
    li t1, sleep
    bgeu t3, t1, keyboard_input

    # Update character state
    la t0, char_parameters
    lh a0, 0(t0)  # Current state
    lh a1, 4(t0)  # Moving/stopped
    jal AtualizaEstado
    sh a0, 0(t0)  # Save updated state

    # Swap frames
    mv a3, s0     # Current frame
    xori a3, a3, 1  # Toggle frame

    # Update map on the new frame
    la t0, deslocamento_x_mapa
    lw a4, 0(t0)  # Map offset
    jal PrintMap

    # Print updated character on the new frame
    la t0, char_pos
    la a0, sprites_kirby_mov
    lh a1, 0(t0)  # x position
    lh a2, 2(t0)  # y position
    la t0, char_parameters
    lh a4, 0(t0)  # state
    lh a5, 2(t0)  # direction
    jal PrintChar

    # Swap frames
    li t0, 0xFF200604  # Frame swap address
    sw s0, 0(t0)       # Show the new frame

    # Repeat the loop
    j GAME_LOOP
.include "SYSTEMv24.s"	
.include "print_map.s"	
.include "print_char"
.include "AtualizaEstado.s"
.include "keyboard_input.s"
.include "PrintTiles.s"
.include "PrintMap.s"
		
		
		
		
