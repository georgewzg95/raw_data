`define M     97          // M is the degree of the irreducible polynomial
`define WIDTH (2*`M-1)    // width for a GF(3^M) element
`define W2    (4*`M-1)    // width for a GF(3^{2*M}) element
`define W3    (6*`M-1)    // width for a GF(3^{3*M}) element
`define W6    (12*`M-1)   // width for a GF(3^{6*M}) element
`define PX    196'h4000000000000000000000000000000000000000001000002 // PX is the irreducible polynomial
`define ZERO {(2*`M){1'b0}}
`define TWO {(2*`M-2){1'b0}},2'b10
`define MOST 2*`M+1:2*`M

module f3m_mux3(v1, l1, v2, l2, v3, l3, out);
    input [`WIDTH:0] v1, v2, v3;
    input l1, l2, l3;
    output [`WIDTH:0] out;
    genvar i;
    generate
        for(i=0;i<=`WIDTH;i=i+1)
          begin : label
            assign out[i] = (v1[i] & l1) | (v2[i] & l2) | (v3[i] & l3);
          end 
    endgenerate
endmodule
