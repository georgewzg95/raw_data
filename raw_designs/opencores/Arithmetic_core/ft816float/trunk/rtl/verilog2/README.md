# Verilog2

This directory is a newer version of the cores with the 'WID' parameter renamed to 'FPWID' to avoid conflicts with other modules.
Also experimental and not completely implemented is the 'EXTRA_BITS' definition. EXTRA_BITS defines the number of extra precision bits to maintain for a given precision. Setting this to zero should generate the usual cores. It's sometimes desirable to maintain extra precision bits in registers which are trimmed off when a transfer to memory occurs. The EXTRA_BITS definition must be a multiple of four.

