
.text

PrintTile:
    # Inputs:
    # a2 = x position
    # a3 = y position
    # a4 = tile address

    # Calculate framebuffer address for (x, y)
    li t0, 1120         # Screen width
    mul t1, a3, t0      # y * screen width
    add t1, t1, a2      # y * screen_width + x
    slli t1, t1, 2      # Multiply by 4 (bytes per pixel)
    add t1, a2, t1      # Add to framebuffer base address

    # Loop through tile rows and columns
    li t3, 0            # Row counter
    li t4, 0            # Column counter
TileLoop:
    li t6, 16
    bge t3, t6, EndTile  # If row counter >= 16, end
    bge t4, t6, NextRow  # If column counter >= 16, go to next row

    # Load pixel from tile data
    lw t5, 0(a4)        # Load pixel from tile
    sw t5, 0(t1)        # Write pixel to framebuffer

    # Increment addresses and counters
    addi a4, a4, 4      # Move to next pixel in tile
    addi t1, t1, 4      # Move to next pixel in framebuffer
    addi t4, t4, 1      # Increment column counter
    j TileLoop

NextRow:
    addi t1, t1, 1088   # Move to next row in framebuffer (1120 - 16 * 4)
    addi t3, t3, 1      # Increment row counter
    j TileLoop

EndTile:
    ret