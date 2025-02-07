# main.s
# Include tile data



# Matrix defining the map layout


# Framebuffer base address 


.text
.globl PrintMap

PrintMap:
    # Load matrix address
    la a0, matriz_mapa1
    # Load tiles address
    la a1, tiles
    # Load framebuffer address
    la a2, framebuffer
    lw a2, 0(a2)

    # Initialize counters
    li s0, 0                  # s0 = row counter (y position)
    li s1, 0                  # s1 = column counter (x position)
    li s2, 13                 # s2 = number of tiles
    li s3, 1120               # s3 = width of the map
    li s4, 160                # s4 = height of the map

LoopRows:
    bge s0, s4, EndPrintMap   # If row counter >= height, end
    li s1, 0                  # Reset column counter

LoopColumns:
    bge s1, s3, NextRow       # If column counter >= width, go to next row

    # Calculate tile index
    lw t0, 0(a0)              # Load current matrix value
    addi a0, a0, 4            # Move to next matrix value

    # Calculate tile address
    slli t1, t0, 4         # Multiply tile index by 4 (word size)
    add t1, a1, t1            # Add to tiles base address
    lw t2, 0(t1)              # Load tile address

    # Print tile at (s1, s0)
    mv a2, s1                 # x position
    mv a3, s0                 # y position
    mv a4, t2                 # tile address
    jal PrintTile             # Call PrintTile function

    addi s1, s1, 16           # Move to next column (16 pixels per tile)
    j LoopColumns

NextRow:
    addi s0, s0, 16           # Move to next row (16 pixels per tile)
    j LoopRows

EndPrintMap:
    ret

# Function to print a 16x16 tile at (x, y)
PrintTile:
    # Inputs:
    # a2 = x position
    # a3 = y position
    # a4 = tile address

    # Calculate framebuffer address for (x, y)
    li t0, 1120               # Screen width
    mul t1, a3, t0            # y * screen width
    add t1, t1, a2            # y * screen width + x
    slli t1, t1, 2            # Multiply by 4 (32-bit pixels)
    la t2, framebuffer
    lw t2, 0(t2)              # Load framebuffer base address
    add t2, t2, t1            # Framebuffer address for (x, y)

    # Loop through tile rows
    li t3, 0                  # t3 = row counter
TileRowLoop:
    li t6, 16
    bge t3, t6, EndTile       # If row counter >= 16, end

    # Loop through tile columns
    li t4, 0                  # t4 = column counter
TileColLoop:
    li t6, 16
    bge t4, t6, NextTileRow   # If column counter >= 16, go to next row

    # Load pixel from tile
    lw t5, 0(a4)              # Load pixel from tile
    sw t5, 0(t2)              # Store pixel in framebuffer

    # Increment addresses and counters
    addi a4, a4, 4            # Move to next pixel in tile
    addi t2, t2, 4            # Move to next pixel in framebuffer
    addi t4, t4, 1            # Increment column counter
    j TileColLoop

NextTileRow:
    addi t2, t2, 1088         # Move to next row in framebuffer (1120 - 16 * 4)
    addi t3, t3, 1            # Increment row counter
    j TileRowLoop

EndTile:
    ret