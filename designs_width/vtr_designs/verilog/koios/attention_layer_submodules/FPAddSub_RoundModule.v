`define SIMULATION_MEMORY
//`define SIMULATION_addfp
`define VECTOR_DEPTH 64 //Q,K,V vector size
`define DATA_WIDTH 16
`define VECTOR_BITS 1024 // 16 bit each (16x64)
`define NUM_WORDS 32   //num of words in the sentence
`define BUF_AWIDTH 4 //16 entries in each buffer ram
`define BUF_LOC_SIZE 4 //4 words in each addr location
`define OUT_RAM_DEPTH 512 //512 entries in output bram
`define EXPONENT 8
`define MANTISSA 7
`define EXPONENT 5
`define MANTISSA 10
`define SIGN 1
`define DWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define DEFINES_DONE
`define DATAWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define IEEE_COMPLIANCE 1
`define NUM 4
`define ADDRSIZE 4

module FPAddSub_RoundModule(
		ZeroSum,
		NormE,
		NormM,
		R,
		S,
		G,
		Sa,
		Sb,
		Ctrl,
		MaxAB,
		Z,
		EOF
    );

	// Input ports
	input ZeroSum ;					// Sum is zero
	input [`EXPONENT:0] NormE ;				// Normalized exponent
	input [`MANTISSA-1:0] NormM ;				// Normalized mantissa
	input R ;							// Round bit
	input S ;							// Sticky bit
	input G ;
	input Sa ;							// A's sign bit
	input Sb ;							// B's sign bit
	input Ctrl ;						// Control bit (operation)
	input MaxAB ;
	
	// Output ports
	output [`DWIDTH-1:0] Z ;					// Final result
	output EOF ;
	
	// Internal signals
	wire [`MANTISSA:0] RoundUpM ;			// Rounded up sum with room for overflow
	wire [`MANTISSA-1:0] RoundM ;				// The final rounded sum
	wire [`EXPONENT:0] RoundE ;				// Rounded exponent (note extra bit due to poential overflow	)
	wire RoundUp ;						// Flag indicating that the sum should be rounded up
        wire FSgn;
	wire ExpAdd ;						// May have to add 1 to compensate for overflow 
	wire RoundOF ;						// Rounding overflow
	
	wire [`EXPONENT:0]temp_2;
	assign temp_2 = 0;
	// The cases where we need to round upwards (= adding one) in Round to nearest, tie to even
	assign RoundUp = (G & ((R | S) | NormM[0])) ;
	
	// Note that in the other cases (rounding down), the sum is already 'rounded'
	assign RoundUpM = (NormM + 1) ;								// The sum, rounded up by 1
	assign RoundM = (RoundUp ? RoundUpM[`MANTISSA-1:0] : NormM) ; 	// Compute final mantissa	
	assign RoundOF = RoundUp & RoundUpM[`MANTISSA] ; 				// Check for overflow when rounding up

	// Calculate post-rounding exponent
	assign ExpAdd = (RoundOF ? 1'b1 : 1'b0) ; 				// Add 1 to exponent to compensate for overflow
	assign RoundE = ZeroSum ? temp_2 : (NormE + ExpAdd) ; 							// Final exponent

	// If zero, need to determine sign according to rounding
	assign FSgn = (ZeroSum & (Sa ^ Sb)) | (ZeroSum ? (Sa & Sb & ~Ctrl) : ((~MaxAB & Sa) | ((Ctrl ^ Sb) & (MaxAB | Sa)))) ;

	// Assign final result
	assign Z = {FSgn, RoundE[`EXPONENT-1:0], RoundM[`MANTISSA-1:0]} ;
	
	// Indicate exponent overflow
	assign EOF = RoundE[`EXPONENT];
	
endmodule
