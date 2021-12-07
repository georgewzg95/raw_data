////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	axilrd2wbsp.v (AXI lite to wishbone slave, read channel)
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	Bridge an AXI lite read channel pair to a single wishbone read
//		channel.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2016-2019, Gisselquist Technology, LLC
//
// This file is part of the pipelined Wishbone to AXI converter project, a
// project that contains multiple bus bridging designs and formal bus property
// sets.
//
// The bus bridge designs and property sets are free RTL designs: you can
// redistribute them and/or modify any of them under the terms of the GNU
// Lesser General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// The bus bridge designs and property sets are distributed in the hope that
// they will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module	axilrd2wbsp(i_clk, i_axi_reset_n,
	// AXI read address channel signals
	o_axi_arready, i_axi_araddr, i_axi_arcache, i_axi_arprot, i_axi_arvalid,
	// AXI read data channel signals   
	o_axi_rresp, o_axi_rvalid, o_axi_rdata, i_axi_rready,
	// We'll share the clock and the reset
	o_wb_cyc, o_wb_stb, o_wb_addr,
		i_wb_ack, i_wb_stall, i_wb_data, i_wb_err
`ifdef	FORMAL
	, f_first, f_mid, f_last
`endif
	);
	localparam C_AXI_DATA_WIDTH	= 32;// Width of the AXI R&W data
	parameter C_AXI_ADDR_WIDTH	= 28;	// AXI Address width
	localparam AW			= C_AXI_ADDR_WIDTH-2;// WB Address width
	parameter LGFIFO                =  3;

	input	wire			i_clk;	// Bus clock
	input	wire			i_axi_reset_n;	// Bus reset

// AXI read address channel signals
	output	reg			o_axi_arready;	// Read address ready
	input	wire	[C_AXI_ADDR_WIDTH-1:0]	i_axi_araddr;	// Read address
	input	wire	[3:0]		i_axi_arcache;	// Read Cache type
	input	wire	[2:0]		i_axi_arprot;	// Read Protection type
	input	wire			i_axi_arvalid;	// Read address valid
  
// AXI read data channel signals   
	output	reg [1:0]		o_axi_rresp;   // Read response
	output	reg			o_axi_rvalid;  // Read reponse valid
	output	wire [C_AXI_DATA_WIDTH-1:0] o_axi_rdata;    // Read data
	input	wire			i_axi_rready;  // Read Response ready

	// We'll share the clock and the reset
	output	reg				o_wb_cyc;
	output	reg				o_wb_stb;
	output	reg [(AW-1):0]			o_wb_addr;
	input	wire				i_wb_ack;
	input	wire				i_wb_stall;
	input	[(C_AXI_DATA_WIDTH-1):0]	i_wb_data;
	input	wire				i_wb_err;
`ifdef	FORMAL
	// Output connections only used in formal mode
	output	wire	[LGFIFO:0]		f_first;
	output	wire	[LGFIFO:0]		f_mid;
	output	wire	[LGFIFO:0]		f_last;
`endif

	localparam	DW = C_AXI_DATA_WIDTH;

	wire	w_reset;
	assign	w_reset = (!i_axi_reset_n);

	reg			r_stb;
	reg	[AW-1:0]	r_addr;

	localparam	FLEN=(1<<LGFIFO);

	reg	[DW-1:0]	dfifo		[0:(FLEN-1)];
	reg			fifo_full, fifo_empty;

	reg	[LGFIFO:0]	r_first, r_mid, r_last, r_next;
	wire	[LGFIFO:0]	w_first_plus_one;
	wire	[LGFIFO:0]	next_first, next_last, next_mid, fifo_fill;
	reg			wb_pending, last_ack;
	reg	[LGFIFO:0]	wb_outstanding;


	initial	o_wb_cyc = 1'b0;
	initial	o_wb_stb = 1'b0;
	always @(posedge i_clk)
	if ((w_reset)||((o_wb_cyc)&&(i_wb_err))||(err_state))
		o_wb_stb <= 1'b0;
	else if (r_stb || ((i_axi_arvalid)&&(o_axi_arready)))
		o_wb_stb <= 1'b1;
	else if ((o_wb_cyc)&&(!i_wb_stall))
		o_wb_stb <= 1'b0;

	always @(*)
		o_wb_cyc = (wb_pending)||(o_wb_stb);

	always @(posedge i_clk)
	if (r_stb && !i_wb_stall)
		o_wb_addr <= r_addr;
	else if ((o_axi_arready)&&((!o_wb_stb)||(!i_wb_stall)))
		o_wb_addr <= i_axi_araddr[AW+1:2];

	// Shadow request
	// r_stb, r_addr
	initial	r_stb = 1'b0;
	always @(posedge i_clk)
	begin
		if ((i_axi_arvalid)&&(o_axi_arready)&&(o_wb_stb)&&(i_wb_stall))
		begin
			r_stb  <= 1'b1;
			r_addr <= i_axi_araddr[AW+1:2];
		end else if ((!i_wb_stall)||(!o_wb_cyc))
			r_stb <= 1'b0;

		if ((w_reset)||(o_wb_cyc)&&(i_wb_err)||(err_state))
			r_stb <= 1'b0;
	end

	initial	wb_pending     = 0;
	initial	wb_outstanding = 0;
	initial	last_ack    = 1;
	always @(posedge i_clk)
	if ((w_reset)||(!o_wb_cyc)||(i_wb_err)||(err_state))
	begin
		wb_pending     <= 1'b0;
		wb_outstanding <= 0;
		last_ack       <= 1;
	end else case({ (o_wb_stb)&&(!i_wb_stall), i_wb_ack })
	2'b01: begin
		wb_outstanding <= wb_outstanding - 1'b1;
		wb_pending <= (wb_outstanding >= 2);
		last_ack <= (wb_outstanding <= 2);
		end
	2'b10: begin
		wb_outstanding <= wb_outstanding + 1'b1;
		wb_pending <= 1'b1;
		last_ack <= (wb_outstanding == 0);
		end
	default: begin end
	endcase

	assign	next_first = r_first + 1'b1;
	assign	next_last  = r_last + 1'b1;
	assign	next_mid   = r_mid + 1'b1;
	assign	fifo_fill  = (r_first - r_last);

	initial	fifo_full  = 1'b0;
	initial	fifo_empty = 1'b1;
	always @(posedge i_clk)
	if (w_reset)
	begin
		fifo_full  <= 1'b0;
		fifo_empty <= 1'b1;
	end else case({ (o_axi_rvalid)&&(i_axi_rready),
				(i_axi_arvalid)&&(o_axi_arready) })
	2'b01: begin
		fifo_full  <= (next_first[LGFIFO-1:0] == r_last[LGFIFO-1:0])
					&&(next_first[LGFIFO]!=r_last[LGFIFO]);
		fifo_empty <= 1'b0;
		end
	2'b10: begin
		fifo_full <= 1'b0;
		fifo_empty <= 1'b0;
		end
	default: begin end
	endcase

	initial	o_axi_arready = 1'b1;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_arready <= 1'b1;
	else if ((o_wb_cyc && i_wb_err) || err_state)
		// On any error, drop the ready flag until it's been flushed
		o_axi_arready <= 1'b0;
	else if ((i_axi_arvalid)&&(o_axi_arready)&&(o_wb_stb)&&(i_wb_stall))
		// On any request where we are already busy, r_stb will get
		// set and we drop arready
		o_axi_arready <= 1'b0;
	else if (!o_axi_arready && o_wb_stb && i_wb_stall)
		// If we've already stalled on o_wb_stb, remain stalled until
		// the bus clears
		o_axi_arready <= 1'b0;
	else if (fifo_full && (!o_axi_rvalid || !i_axi_rready))
		// If the FIFO is full, we must remain not ready until at
		// least one acknowledgment is accepted 
		o_axi_arready <= 1'b0;
	else if ( (!o_axi_rvalid || !i_axi_rready)
			&& (i_axi_arvalid && o_axi_arready))
		o_axi_arready  <= (next_first[LGFIFO-1:0] != r_last[LGFIFO-1:0])
					||(next_first[LGFIFO]==r_last[LGFIFO]);
	else
		o_axi_arready <= 1'b1;

	initial	r_first = 0;
	always @(posedge i_clk)
	if (w_reset)
		r_first <= 0;
	else if ((i_axi_arvalid)&&(o_axi_arready))
		r_first <= r_first + 1'b1;

	initial	r_mid = 0;
	always @(posedge i_clk)
	if (w_reset)
		r_mid <= 0;
	else if ((o_wb_cyc)&&((i_wb_ack)||(i_wb_err)))
		r_mid <= r_mid + 1'b1;
	else if ((err_state)&&(r_mid != r_first))
		r_mid <= r_mid + 1'b1;

	initial	r_last = 0;
	always @(posedge i_clk)
	if (w_reset)
		r_last <= 0;
	else if ((o_axi_rvalid)&&(i_axi_rready))
		r_last <= r_last + 1'b1;

	always @(posedge i_clk)
	if ((o_wb_cyc)&&((i_wb_ack)||(i_wb_err)))
		dfifo[r_mid[(LGFIFO-1):0]] <= i_wb_data;

	reg	[LGFIFO:0]	err_loc;
	always @(posedge i_clk)
	if ((o_wb_cyc)&&(i_wb_err))
		err_loc <= r_mid;

	wire	[DW-1:0]	read_data;

	assign	read_data = dfifo[r_last[LGFIFO-1:0]];
	assign	o_axi_rdata = read_data[DW-1:0];
	initial	o_axi_rresp = 2'b00;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_rresp <= 0;
	else if ((!o_axi_rvalid)||(i_axi_rready))
	begin
		if ((!err_state)&&((!o_wb_cyc)||(!i_wb_err)))
			o_axi_rresp <= 2'b00;
		else if ((!err_state)&&(o_wb_cyc)&&(i_wb_err))
		begin
			if (o_axi_rvalid)
				o_axi_rresp <= (r_mid == next_last) ? 2'b10 : 2'b00;
			else
				o_axi_rresp <= (r_mid == r_last) ? 2'b10 : 2'b00;
		end else if (err_state)
		begin
			if (next_last == err_loc)
				o_axi_rresp <= 2'b10;
			else if (o_axi_rresp[1])
				o_axi_rresp <= 2'b11;
		end else
			o_axi_rresp <= 0;
	end


	reg	err_state;	
	initial err_state  = 0;
	always @(posedge i_clk)
	if (w_reset)
		err_state <= 0;
	else if (r_first == r_last)
		err_state <= 0;
	else if ((o_wb_cyc)&&(i_wb_err))
		err_state <= 1'b1;

	initial	o_axi_rvalid = 1'b0;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_rvalid <= 0;
	else if ((o_wb_cyc)&&((i_wb_ack)||(i_wb_err)))
		o_axi_rvalid <= 1'b1;
	else if ((o_axi_rvalid)&&(i_axi_rready))
	begin
		if (err_state)
			o_axi_rvalid <= (next_last != r_first);
		else
			o_axi_rvalid <= (next_last != r_mid);
	end

	// Make Verilator happy
	// verilator lint_off UNUSED
	// verilator lint_on  UNUSED

`ifdef	FORMAL
	reg	f_past_valid;
	initial f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	always @(*)
	if (!f_past_valid)
		assume(w_reset);

	always @(*)
	if (err_state)
		assert(!o_axi_arready);

	always @(*)
	if (err_state)
		assert((!o_wb_cyc)&&(!o_axi_arready));

	always @(*)
	if ((fifo_empty)&&(!w_reset))
		assert((!fifo_full)&&(r_first == r_last)&&(r_mid == r_last));

	always @(*)
	if (fifo_full)
		assert((!fifo_empty)
			&&(r_first[LGFIFO-1:0] == r_last[LGFIFO-1:0])
			&&(r_first[LGFIFO] != r_last[LGFIFO]));

	always @(*)
	assert(fifo_fill <= (1<<LGFIFO));

	always @(*)
	if (fifo_full)
		assert(!o_axi_arready);
	always @(*)
		assert(fifo_full == (fifo_fill == (1<<LGFIFO)));
	always @(*)
	if (fifo_fill == (1<<LGFIFO))
		assert(!o_axi_arready);
	always @(*)
		assert(wb_pending == (wb_outstanding != 0));

	always @(*)
		assert(last_ack == (wb_outstanding <= 1));


	assign	f_first = r_first;
	assign	f_mid   = r_mid;
	assign	f_last  = r_last;

	wire	[LGFIFO:0]	f_wb_nreqs, f_wb_nacks, f_wb_outstanding;
	fwb_master #(
		.AW(AW), .DW(DW), .F_LGDEPTH(LGFIFO+1)
		) fwb(i_clk, w_reset,
		o_wb_cyc, o_wb_stb, 1'b0, o_wb_addr, 32'h0, 4'h0,
			i_wb_ack, i_wb_stall, i_wb_data, i_wb_err,
		f_wb_nreqs,f_wb_nacks, f_wb_outstanding);

	always @(*)
	if (o_wb_cyc)
		assert(f_wb_outstanding == wb_outstanding);

	always @(*)
	if (o_wb_cyc)
		assert(wb_outstanding <= (1<<LGFIFO));

	wire	[LGFIFO:0]	wb_fill;
	assign	wb_fill = r_first - r_mid;
	always @(*)
		assert(wb_fill <= fifo_fill);
	always @(*)
	if (o_wb_stb)
		assert(wb_outstanding+1+((r_stb)?1:0) == wb_fill);

	else if (o_wb_cyc)
		assert(wb_outstanding == wb_fill);

	always @(*)
	if (r_stb)
	begin
		assert(o_wb_stb);
		assert(!o_axi_arready);
	end

	wire	[LGFIFO:0]	f_axi_rd_outstanding,
				f_axi_wr_outstanding,
				f_axi_awr_outstanding;

	faxil_slave #(
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.F_LGDEPTH(LGFIFO+1),
		.F_OPT_NO_WRITES(1'b1),
		.F_AXI_MAXWAIT(0),
		.F_AXI_MAXDELAY(0)
		) faxil(i_clk, i_axi_reset_n,
		//
		// AXI write address channel signals
		1'b0, i_axi_araddr, i_axi_arcache, i_axi_arprot, 1'b0,
		// AXI write data channel signals
		1'b0, 32'h0, 4'h0, 1'b0,
		// AXI write response channel signals
		2'b00, 1'b0, 1'b0,
		// AXI read address channel signals
		o_axi_arready, i_axi_araddr, i_axi_arcache, i_axi_arprot,
			i_axi_arvalid,
		// AXI read data channel signals
		o_axi_rresp, o_axi_rvalid, o_axi_rdata, i_axi_rready,
		f_axi_rd_outstanding, f_axi_wr_outstanding,
		f_axi_awr_outstanding);

	always @(*)
		assert(f_axi_wr_outstanding == 0);
	always @(*)
		assert(f_axi_awr_outstanding == 0);
	always @(*)
		assert(f_axi_rd_outstanding == fifo_fill);

	wire	[LGFIFO:0]	f_mid_minus_err, f_err_minus_last,
				f_first_minus_err;
	assign	f_mid_minus_err  = f_mid - err_loc;
	assign	f_err_minus_last = err_loc - f_last;
	assign	f_first_minus_err = f_first - err_loc;
	always @(*)
	if (o_axi_rvalid)
	begin
		if (!err_state)
			assert(!o_axi_rresp[1]);
		else if (err_loc == f_last)
			assert(o_axi_rresp == 2'b10);
		else if (f_err_minus_last < (1<<LGFIFO))
			assert(!o_axi_rresp[1]);
		else
			assert(o_axi_rresp[1]);
	end

	always @(*)
	if (err_state)
		assert(o_axi_rvalid == (r_first != r_last));
	else
		assert(o_axi_rvalid == (r_mid != r_last));

	always @(*)
	if (err_state)
		assert(f_first_minus_err <= (1<<LGFIFO));

	always @(*)
	if (err_state)
		assert(f_first_minus_err != 0);

	always @(*)
	if (err_state)
		assert(f_mid_minus_err <= f_first_minus_err);

	always @(*)
	if ((f_past_valid)&&(i_axi_reset_n)&&(f_axi_rd_outstanding > 0))
	begin
		if (err_state)
			assert((!o_wb_cyc)&&(f_wb_outstanding == 0));
		else if (!o_wb_cyc)
			assert((o_axi_rvalid)&&(f_axi_rd_outstanding>0)
					&&(wb_fill == 0));
	end

	// WB covers
	always @(*)
		cover(o_wb_cyc && o_wb_stb);

	always @(*)
	if (LGFIFO > 2)
		cover(o_wb_cyc && f_wb_outstanding > 2);

	always @(posedge i_clk)
		cover(o_wb_cyc && i_wb_ack
			&& $past(o_wb_cyc && i_wb_ack)
			&& $past(o_wb_cyc && i_wb_ack,2));

	// AXI covers
	always @(*)
		cover(o_axi_rvalid && i_axi_rready);

	always @(posedge i_clk)
		cover(i_axi_arvalid && o_axi_arready
			&& $past(i_axi_arvalid && o_axi_arready)
			&& $past(i_axi_arvalid && o_axi_arready,2));

	always @(posedge i_clk)
		cover(o_axi_rvalid && i_axi_rready
			&& $past(o_axi_rvalid && i_axi_rready)
			&& $past(o_axi_rvalid && i_axi_rready,2));
`endif
endmodule
////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	axilwr2wbsp.v (AXI lite to wishbone slave, read channel)
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	Bridge an AXI lite write channel triplet to a single wishbone
//		write channel.  A full AXI lite to wishbone bridge will also
//	require the read channel and an arbiter.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2016-2019, Gisselquist Technology, LLC
//
// This file is part of the pipelined Wishbone to AXI converter project, a
// project that contains multiple bus bridging designs and formal bus property
// sets.
//
// The bus bridge designs and property sets are free RTL designs: you can
// redistribute them and/or modify any of them under the terms of the GNU
// Lesser General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// The bus bridge designs and property sets are distributed in the hope that
// they will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module	axilwr2wbsp(i_clk, i_axi_reset_n,
	// AXI write address channel signals
	o_axi_awready, i_axi_awaddr, i_axi_awcache, i_axi_awprot, i_axi_awvalid,
	// AXI write data channel signals
	o_axi_wready, i_axi_wdata, i_axi_wstrb, i_axi_wvalid,
	// AXI write response channel signals
	o_axi_bresp, o_axi_bvalid, i_axi_bready,
	// We'll share the clock and the reset
	o_wb_cyc, o_wb_stb, o_wb_addr, o_wb_data, o_wb_sel,
		i_wb_ack, i_wb_stall, i_wb_err
`ifdef	FORMAL
	, f_first, f_mid, f_last, f_wpending
`endif
	);
	parameter C_AXI_DATA_WIDTH	= 32;// Width of the AXI R&W data
	parameter C_AXI_ADDR_WIDTH	= 28;	// AXI Address width
	localparam AW			= C_AXI_ADDR_WIDTH-2;// WB Address width
	parameter LGFIFO                =  3;
	localparam	DW = C_AXI_DATA_WIDTH;
	localparam	FLEN=(1<<LGFIFO);


	input	wire			i_clk;	// Bus clock
	input	wire			i_axi_reset_n;	// Bus reset

	// AXI write address channel signals
	output	reg			o_axi_awready;//Slave is ready to accept
	input	wire	[AW+1:0]	i_axi_awaddr;	// Write address
	input	wire	[3:0]		i_axi_awcache;	// Write Cache type
	input	wire	[2:0]		i_axi_awprot;	// Write Protection type
	input	wire			i_axi_awvalid;	// Write address valid

	// AXI write data channel signals
	output	reg			o_axi_wready;  // Write data ready
	input	wire	[DW-1:0]	i_axi_wdata;	// Write data
	input	wire	[DW/8-1:0]	i_axi_wstrb;	// Write strobes
	input	wire			i_axi_wvalid;	// Write valid

	// AXI write response channel signals
	output	reg	[1:0]		o_axi_bresp;	// Write response
	output	reg			o_axi_bvalid;  // Write reponse valid
	input	wire			i_axi_bready;  // Response ready

	// We'll share the clock and the reset
	output	reg				o_wb_cyc;
	output	reg				o_wb_stb;
	output	reg	[(AW-1):0]		o_wb_addr;
	output	reg	[(DW-1):0]		o_wb_data;
	output	reg	[(DW/8-1):0]		o_wb_sel;
	input	wire				i_wb_ack;
	input	wire				i_wb_stall;
	input	wire				i_wb_err;
`ifdef	FORMAL
	// Output connections only used in formal mode
	output	wire	[LGFIFO:0]		f_first;
	output	wire	[LGFIFO:0]		f_mid;
	output	wire	[LGFIFO:0]		f_last;
	output	wire	[1:0]			f_wpending;
`endif

	wire	w_reset;
	assign	w_reset = (!i_axi_reset_n);

	reg			r_awvalid, r_wvalid;
	reg	[AW-1:0]	r_addr;
	reg	[DW-1:0]	r_data;
	reg	[DW/8-1:0]	r_sel;

	reg			fifo_full, fifo_empty;

	reg	[LGFIFO:0]	r_first, r_mid, r_last, r_next;
	wire	[LGFIFO:0]	w_first_plus_one;
	wire	[LGFIFO:0]	next_first, next_last, next_mid, fifo_fill;
	reg			wb_pending, last_ack;
	reg	[LGFIFO:0]	wb_outstanding;

	wire	axi_write_accepted, pending_axi_write;

	assign	pending_axi_write =
		((r_awvalid) || (i_axi_awvalid && o_axi_awready))
		&&((r_wvalid)|| (i_axi_wvalid && o_axi_wready));

	assign	axi_write_accepted =
		(!o_wb_stb || !i_wb_stall) && (!fifo_full) && (!err_state)
			&& (pending_axi_write);

	initial	o_wb_cyc = 1'b0;
	initial	o_wb_stb = 1'b0;
	always @(posedge i_clk)
	if ((w_reset)||((o_wb_cyc)&&(i_wb_err))||(err_state))
		o_wb_stb <= 1'b0;
	else if (axi_write_accepted)
		o_wb_stb <= 1'b1;
	else if ((o_wb_cyc)&&(!i_wb_stall))
		o_wb_stb <= 1'b0;

	always @(*)
		o_wb_cyc = (wb_pending)||(o_wb_stb);

	always @(posedge i_clk)
	if (!o_wb_stb || !i_wb_stall)
	begin
		if (r_awvalid)
			o_wb_addr <= r_addr;
		else
			o_wb_addr <= i_axi_awaddr[AW+1:2];

		if (r_wvalid)
		begin
			o_wb_data <= r_data;
			o_wb_sel  <= r_sel;
		end else begin
			o_wb_data <= i_axi_wdata;
			o_wb_sel  <= i_axi_wstrb;
		end
	end

	initial	r_awvalid <= 1'b0;
	always @(posedge i_clk)
	begin
		if ((i_axi_awvalid)&&(o_axi_awready))
		begin
			r_addr <= i_axi_awaddr[AW+1:2];
			r_awvalid <= (!axi_write_accepted);
		end else if (axi_write_accepted)
			r_awvalid <= 1'b0;

		if (w_reset)
			r_awvalid <= 1'b0;
	end

	initial	r_wvalid <= 1'b0;
	always @(posedge i_clk)
	begin
		if ((i_axi_wvalid)&&(o_axi_wready))
		begin
			r_data <= i_axi_wdata;
			r_sel  <= i_axi_wstrb;
			r_wvalid <= (!axi_write_accepted);
		end else if (axi_write_accepted)
			r_wvalid <= 1'b0;

		if (w_reset)
			r_wvalid <= 1'b0;
	end

	initial	o_axi_awready = 1'b1;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_awready <= 1'b1;
	else if ((o_wb_stb && i_wb_stall)
			&&(r_awvalid || (i_axi_awvalid && o_axi_awready)))
		// Once a request has been received while the interface is
		// stalled, we must stall and wait for it to clear
		o_axi_awready <= 1'b0;
	else if (err_state && (r_awvalid || (i_axi_awvalid && o_axi_awready)))
		o_axi_awready <= 1'b0;
	else if ((r_awvalid || (i_axi_awvalid && o_axi_awready))
		&&(!r_wvalid && (!i_axi_wvalid || !o_axi_wready)))
		// If the write address is given without any corresponding
		// write data, immediately stall and wait for the write data
		o_axi_awready <= 1'b0;
	else if (!o_axi_awready && o_wb_stb && i_wb_stall)
		// Once stalled, remain stalled while the WB bus is stalled
		o_axi_awready <= 1'b0;
	else if (fifo_full && (r_awvalid || (!o_axi_bvalid || !i_axi_bready)))
		// Once the FIFO is full, we must remain stalled until at
		// least one acknowledgment has been accepted
		o_axi_awready <= 1'b0;
	else if ((!o_axi_bvalid || !i_axi_bready)
			&& (r_awvalid || (i_axi_awvalid && o_axi_awready)))
		// If ever the FIFO becomes full, we must immediately drop
		// the o_axi_awready signal
		o_axi_awready  <= (next_first[LGFIFO-1:0] != r_last[LGFIFO-1:0])
					&&(next_first[LGFIFO]==r_last[LGFIFO]);
	else
		o_axi_awready <= 1'b1;

	initial	o_axi_wready = 1'b1;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_wready <= 1'b1;
	else if ((o_wb_stb && i_wb_stall)
			&&(r_wvalid || (i_axi_wvalid && o_axi_wready)))
		// Once a request has been received while the interface is
		// stalled, we must stall and wait for it to clear
		o_axi_wready <= 1'b0;
	else if (err_state && (r_wvalid || (i_axi_wvalid && o_axi_wready)))
		o_axi_wready <= 1'b0;
	else if ((r_wvalid || (i_axi_wvalid && o_axi_wready))
		&&(!r_awvalid && (!i_axi_awvalid || !o_axi_awready)))
		// If the write address is given without any corresponding
		// write data, immediately stall and wait for the write data
		o_axi_wready <= 1'b0;
	else if (!o_axi_wready && o_wb_stb && i_wb_stall)
		// Once stalled, remain stalled while the WB bus is stalled
		o_axi_wready <= 1'b0;
	else if (fifo_full && (r_wvalid || (!o_axi_bvalid || !i_axi_bready)))
		// Once the FIFO is full, we must remain stalled until at
		// least one acknowledgment has been accepted
		o_axi_wready <= 1'b0;
	else if ((!o_axi_bvalid || !i_axi_bready)
			&& (i_axi_wvalid && o_axi_wready))
		// If ever the FIFO becomes full, we must immediately drop
		// the o_axi_wready signal
		o_axi_wready  <= (next_first[LGFIFO-1:0] != r_last[LGFIFO-1:0])
					&&(next_first[LGFIFO]==r_last[LGFIFO]);
	else
		o_axi_wready <= 1'b1;


	initial	wb_pending     = 0;
	initial	wb_outstanding = 0;
	initial	last_ack    = 1;
	always @(posedge i_clk)
	if ((w_reset)||(!o_wb_cyc)||(i_wb_err)||(err_state))
	begin
		wb_pending     <= 1'b0;
		wb_outstanding <= 0;
		last_ack       <= 1;
	end else case({ (o_wb_stb)&&(!i_wb_stall), i_wb_ack })
	2'b01: begin
		wb_outstanding <= wb_outstanding - 1'b1;
		wb_pending <= (wb_outstanding >= 2);
		last_ack <= (wb_outstanding <= 2);
		end
	2'b10: begin
		wb_outstanding <= wb_outstanding + 1'b1;
		wb_pending <= 1'b1;
		last_ack <= (wb_outstanding == 0);
		end
	default: begin end
	endcase

	assign	next_first = r_first + 1'b1;
	assign	next_last  = r_last + 1'b1;
	assign	next_mid   = r_mid + 1'b1;
	assign	fifo_fill  = (r_first - r_last);

	initial	fifo_full  = 1'b0;
	initial	fifo_empty = 1'b1;
	always @(posedge i_clk)
	if (w_reset)
	begin
		fifo_full  <= 1'b0;
		fifo_empty <= 1'b1;
	end else case({ (o_axi_bvalid)&&(i_axi_bready),
				(axi_write_accepted) })
	2'b01: begin
		fifo_full  <= (next_first[LGFIFO-1:0] == r_last[LGFIFO-1:0])
					&&(next_first[LGFIFO]!=r_last[LGFIFO]);
		fifo_empty <= 1'b0;
		end
	2'b10: begin
		fifo_full <= 1'b0;
		fifo_empty <= 1'b0;
		end
	default: begin end
	endcase

	initial	r_first = 0;
	always @(posedge i_clk)
	if (w_reset)
		r_first <= 0;
	else if (axi_write_accepted)
		r_first <= r_first + 1'b1;

	initial	r_mid = 0;
	always @(posedge i_clk)
	if (w_reset)
		r_mid <= 0;
	else if ((o_wb_cyc)&&((i_wb_ack)||(i_wb_err)))
		r_mid <= r_mid + 1'b1;
	else if ((err_state)&&(r_mid != r_first))
		r_mid <= r_mid + 1'b1;

	initial	r_last = 0;
	always @(posedge i_clk)
	if (w_reset)
		r_last <= 0;
	else if ((o_axi_bvalid)&&(i_axi_bready))
		r_last <= r_last + 1'b1;

	reg	[LGFIFO:0]	err_loc;
	always @(posedge i_clk)
	if ((o_wb_cyc)&&(i_wb_err))
		err_loc <= r_mid;

	wire	[DW:0]	read_data;

	initial	o_axi_bresp = 2'b00;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_bresp <= 0;
	else if ((!o_axi_bvalid)||(i_axi_bready))
	begin
		if ((!err_state)&&((!o_wb_cyc)||(!i_wb_err)))
			o_axi_bresp <= 2'b00;
		else if ((!err_state)&&(o_wb_cyc)&&(i_wb_err))
		begin
			if (o_axi_bvalid)
				o_axi_bresp <= (r_mid == next_last) ? 2'b10 : 2'b00;
			else
				o_axi_bresp <= (r_mid == r_last) ? 2'b10 : 2'b00;
		end else if (err_state)
		begin
			if (next_last == err_loc)
				o_axi_bresp <= 2'b10;
			else if (o_axi_bresp[1])
				o_axi_bresp <= 2'b11;
		end else
			o_axi_bresp <= 0;
	end


	reg	err_state;	
	initial err_state  = 0;
	always @(posedge i_clk)
	if (w_reset)
		err_state <= 0;
	else if (r_first == r_last)
		err_state <= 0;
	else if ((o_wb_cyc)&&(i_wb_err))
		err_state <= 1'b1;

	initial	o_axi_bvalid = 1'b0;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_bvalid <= 0;
	else if ((o_wb_cyc)&&((i_wb_ack)||(i_wb_err)))
		o_axi_bvalid <= 1'b1;
	else if ((o_axi_bvalid)&&(i_axi_bready))
	begin
		if (err_state)
			o_axi_bvalid <= (next_last != r_first);
		else
			o_axi_bvalid <= (next_last != r_mid);
	end

	// Make Verilator happy
	// verilator lint_off UNUSED
	// verilator lint_on  UNUSED

`ifdef	FORMAL
	reg			f_past_valid;
	wire			f_axi_stalled;
	wire	[LGFIFO:0]	f_wb_nreqs, f_wb_nacks, f_wb_outstanding;
	wire	[LGFIFO:0]	wb_fill;
	wire	[LGFIFO:0]	f_axi_rd_outstanding,
				f_axi_wr_outstanding,
				f_axi_awr_outstanding;
	wire	[LGFIFO:0]	f_mid_minus_err, f_err_minus_last,
				f_first_minus_err;


	initial f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

`ifdef	AXILWR2WBSP
`define	ASSUME	assume
`else
`define	ASSUME	assert
`endif

	always @(*)
	if (!f_past_valid)
		`ASSUME(w_reset);

	always @(*)
	if (err_state)
	begin
		assert(!r_awvalid || !o_axi_awready);
		assert(!r_wvalid  || !o_axi_wready);

		assert(!o_wb_cyc);
	end

	always @(*)
	if ((fifo_empty)&&(!w_reset))
		assert((!fifo_full)&&(r_first == r_last)&&(r_mid == r_last));

	always @(*)
	if (fifo_full)
	begin
		assert(!fifo_empty);
		assert(r_first[LGFIFO-1:0] == r_last[LGFIFO-1:0]);
		assert(r_first[LGFIFO] != r_last[LGFIFO]);
	end

	always @(*)
		assert(fifo_fill <= (1<<LGFIFO));

	always @(*)
	if (fifo_full)
	begin
		assert(!r_awvalid || !o_axi_awready);
		assert(!r_wvalid  || !o_axi_wready);
	end

	always @(*)
		assert(fifo_full == (fifo_fill >= (1<<LGFIFO)));
	always @(*)
		assert(wb_pending == (wb_outstanding != 0));

	always @(*)
		assert(last_ack == (wb_outstanding <= 1));


	assign	f_first    = r_first;
	assign	f_mid      = r_mid;
	assign	f_last     = r_last;
	assign	f_wpending = { r_awvalid, r_wvalid };

	fwb_master #(
		.AW(AW), .DW(DW), .F_LGDEPTH(LGFIFO+1)
		) fwb(i_clk, w_reset,
		o_wb_cyc, o_wb_stb, 1'b1, o_wb_addr, o_wb_data, o_wb_sel,
			i_wb_ack, i_wb_stall, {(DW){1'b0}}, i_wb_err,
		f_wb_nreqs,f_wb_nacks, f_wb_outstanding);

	always @(*)
	if (o_wb_cyc)
		assert(f_wb_outstanding == wb_outstanding);

	always @(*)
	if (o_wb_cyc)
		assert(wb_outstanding <= (1<<LGFIFO));

	assign	wb_fill = r_first - r_mid;
	always @(*)
		assert(wb_fill <= fifo_fill);
	always @(*)
	if (!w_reset)
	begin
		if (o_wb_stb)
			assert(wb_outstanding+1 == wb_fill);
		else if (o_wb_cyc)
			assert(wb_outstanding == wb_fill);
		else if (!err_state)
			assert((wb_fill == 0)&&(wb_outstanding == 0));
	end

	faxil_slave #(
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.F_LGDEPTH(LGFIFO+1),
		.F_OPT_NO_READS(1),
		.F_AXI_MAXWAIT(0),
		.F_AXI_MAXDELAY(0)
		) faxil(i_clk, i_axi_reset_n,
		//
		// AXI write address channel signals
		o_axi_awready, i_axi_awaddr, i_axi_awcache, i_axi_awprot, i_axi_awvalid,
		// AXI write data channel signals
		o_axi_wready, i_axi_wdata, i_axi_wstrb, i_axi_wvalid,
		// AXI write response channel signals
		o_axi_bresp, o_axi_bvalid, i_axi_bready,
		// AXI read address channel signals
		1'b0, i_axi_awaddr, i_axi_awcache, i_axi_awprot,
			1'b0,
		// AXI read data channel signals
		o_axi_bresp, 1'b0, {(DW){1'b0}}, 1'b0,
		f_axi_rd_outstanding, f_axi_wr_outstanding,
		f_axi_awr_outstanding);

	always @(*)
		assert(f_axi_wr_outstanding - (r_wvalid ? 1:0)
				== f_axi_awr_outstanding - (r_awvalid ? 1:0));
	always @(*)
		assert(f_axi_rd_outstanding == 0);
	always @(*)
		assert(f_axi_wr_outstanding - (r_wvalid ? 1:0) == fifo_fill);
	always @(*)
		assert(f_axi_awr_outstanding - (r_awvalid ? 1:0) == fifo_fill);
	always @(*)
		if (r_wvalid)  assert(f_axi_wr_outstanding > 0);
	always @(*)
		if (r_awvalid) assert(f_axi_awr_outstanding > 0);

	assign	f_mid_minus_err  = f_mid - err_loc;
	assign	f_err_minus_last = err_loc - f_last;
	assign	f_first_minus_err = f_first - err_loc;
	always @(*)
	if (o_axi_bvalid)
	begin
		if (!err_state)
			assert(!o_axi_bresp[1]);
		else if (err_loc == f_last)
			assert(o_axi_bresp == 2'b10);
		else if (f_err_minus_last < (1<<LGFIFO))
			assert(!o_axi_bresp[1]);
		else
			assert(o_axi_bresp[1]);
	end

	always @(*)
	if (err_state)
		assert(o_axi_bvalid == (r_first != r_last));
	else
		assert(o_axi_bvalid == (r_mid != r_last));

	always @(*)
	if (err_state)
		assert(f_first_minus_err <= (1<<LGFIFO));

	always @(*)
	if (err_state)
		assert(f_first_minus_err != 0);

	always @(*)
	if (err_state)
		assert(f_mid_minus_err <= f_first_minus_err);

	assign	f_axi_stalled = (fifo_full)||(err_state)
				||((o_wb_stb)&&(i_wb_stall));

	always @(*)
	if ((r_awvalid)&&(f_axi_stalled))
		assert(!o_axi_awready);
	always @(*)
	if ((r_wvalid)&&(f_axi_stalled))
		assert(!o_axi_wready);


	// WB covers
	always @(*)
		cover(o_wb_cyc && o_wb_stb && !i_wb_stall);
	always @(*)
		cover(o_wb_cyc && i_wb_ack);

	always @(posedge i_clk)
		cover(o_wb_cyc && $past(o_wb_cyc && o_wb_stb && !i_wb_stall));//

	always @(posedge i_clk)
		cover(o_wb_cyc && o_wb_stb && !i_wb_stall
			&& $past(o_wb_cyc && o_wb_stb && !i_wb_stall,2)
			&& $past(o_wb_cyc && o_wb_stb && !i_wb_stall,4)); //

	always @(posedge i_clk)
		cover(o_wb_cyc && o_wb_stb && !i_wb_stall
			&& $past(o_wb_cyc && o_wb_stb && !i_wb_stall)
			&& $past(o_wb_cyc && o_wb_stb && !i_wb_stall)); //

	always @(posedge i_clk)
		cover(o_wb_cyc && i_wb_ack
			&& $past(o_wb_cyc && i_wb_ack)
			&& $past(o_wb_cyc && i_wb_ack)); //

	// AXI covers
	always @(posedge i_clk)
		cover(o_axi_bvalid && i_axi_bready
			&& $past(o_axi_bvalid && i_axi_bready,1)
			&& $past(o_axi_bvalid && i_axi_bready,2)); //

`endif
endmodule
`error This full featured AXI to WB converter does not (yet) work
////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	axim2wbsp.v
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	So ... this converter works in the other direction from
//		wbm2axisp.  This converter takes AXI commands, and organizes
//	them into pipelined wishbone commands.
//
//
//	We'll treat AXI as two separate busses: one for writes, another for
//	reads, further, we'll insist that the two channels AXI uses for writes
//	combine into one channel for our purposes.
//
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2016-2019, Gisselquist Technology, LLC
//
// This file is part of the pipelined Wishbone to AXI converter project, a
// project that contains multiple bus bridging designs and formal bus property
// sets.
//
// The bus bridge designs and property sets are free RTL designs: you can
// redistribute them and/or modify any of them under the terms of the GNU
// Lesser General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// The bus bridge designs and property sets are distributed in the hope that
// they will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module axim2wbsp( i_clk, i_axi_reset_n,
	//
	o_axi_awready, // Slave is ready to accept
	i_axi_awid, i_axi_awaddr, i_axi_awlen, i_axi_awsize, i_axi_awburst,
	i_axi_awlock, i_axi_awcache, i_axi_awprot, i_axi_awqos, i_axi_awvalid,
	//
	o_axi_wready, i_axi_wdata, i_axi_wstrb, i_axi_wlast, i_axi_wvalid,
	//
	o_axi_bid, o_axi_bresp, o_axi_bvalid, i_axi_bready,
	//
	o_axi_arready,	// Read address ready
	i_axi_arid,	// Read ID
	i_axi_araddr,	// Read address
	i_axi_arlen,	// Read Burst Length
	i_axi_arsize,	// Read Burst size
	i_axi_arburst,	// Read Burst type
	i_axi_arlock,	// Read lock type
	i_axi_arcache,	// Read Cache type
	i_axi_arprot,	// Read Protection type
	i_axi_arqos,	// Read Protection type
	i_axi_arvalid,	// Read address valid
	//
	o_axi_rid,	// Response ID
	o_axi_rresp,	// Read response
	o_axi_rvalid,	// Read reponse valid
	o_axi_rdata,	// Read data
	o_axi_rlast,	// Read last
	i_axi_rready,	// Read Response ready
	// Wishbone interface
	o_reset, o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data, o_wb_sel,
	i_wb_ack, i_wb_stall, i_wb_data, i_wb_err);
	//
	parameter C_AXI_ID_WIDTH	= 2; // The AXI id width used for R&W
                                             // This is an int between 1-16
	parameter C_AXI_DATA_WIDTH	= 32;// Width of the AXI R&W data
	parameter C_AXI_ADDR_WIDTH	= 28;	// AXI Address width
	localparam DW = C_AXI_DATA_WIDTH;
	localparam AW =   (C_AXI_DATA_WIDTH==  8) ? (C_AXI_ADDR_WIDTH)
			:((C_AXI_DATA_WIDTH== 16) ? (C_AXI_ADDR_WIDTH-1)
			:((C_AXI_DATA_WIDTH== 32) ? (C_AXI_ADDR_WIDTH-2)
			:((C_AXI_DATA_WIDTH== 64) ? (C_AXI_ADDR_WIDTH-3)
			:((C_AXI_DATA_WIDTH==128) ? (C_AXI_ADDR_WIDTH-4)
			:(C_AXI_ADDR_WIDTH-5)))));
	parameter	LGFIFO = 4;
	parameter	[0:0]	F_STRICT_ORDER    = 0;
	parameter	[0:0]	F_CONSECUTIVE_IDS = 0;
	parameter	[0:0]	F_OPT_BURSTS      = 1'b0;
	parameter	[0:0]	F_OPT_CLK2FFLOGIC = 1'b0;
	parameter		F_MAXSTALL = 3;
	parameter		F_MAXDELAY = 3;
	parameter	[0:0]	OPT_READONLY  = 1'b1;
	parameter	[0:0]	OPT_WRITEONLY = 1'b0;
	parameter	[7:0]	OPT_MAXBURST = 8'h3;
	//
	input	wire			i_clk;	// System clock
	input	wire			i_axi_reset_n;

// AXI write address channel signals
	output	wire			o_axi_awready; // Slave is ready to accept
	input	wire	[C_AXI_ID_WIDTH-1:0]	i_axi_awid;	// Write ID
	input	wire	[C_AXI_ADDR_WIDTH-1:0]	i_axi_awaddr;	// Write address
	input	wire	[7:0]		i_axi_awlen;	// Write Burst Length
	input	wire	[2:0]		i_axi_awsize;	// Write Burst size
	input	wire	[1:0]		i_axi_awburst;	// Write Burst type
	input	wire	[0:0]		i_axi_awlock;	// Write lock type
	input	wire	[3:0]		i_axi_awcache;	// Write Cache type
	input	wire	[2:0]		i_axi_awprot;	// Write Protection type
	input	wire	[3:0]		i_axi_awqos;	// Write Quality of Svc
	input	wire			i_axi_awvalid;	// Write address valid

// AXI write data channel signals
	output	wire			o_axi_wready;  // Write data ready
	input	wire	[C_AXI_DATA_WIDTH-1:0]	i_axi_wdata;	// Write data
	input	wire	[C_AXI_DATA_WIDTH/8-1:0] i_axi_wstrb;	// Write strobes
	input	wire			i_axi_wlast; // Last write transaction
	input	wire			i_axi_wvalid;	// Write valid

// AXI write response channel signals
	output	wire [C_AXI_ID_WIDTH-1:0] o_axi_bid;	// Response ID
	output	wire [1:0]		o_axi_bresp;	// Write response
	output	wire 			o_axi_bvalid;  // Write reponse valid
	input	wire			i_axi_bready;  // Response ready

// AXI read address channel signals
	output	wire			o_axi_arready;	// Read address ready
	input	wire	[C_AXI_ID_WIDTH-1:0]	i_axi_arid;	// Read ID
	input	wire	[C_AXI_ADDR_WIDTH-1:0]	i_axi_araddr;	// Read address
	input	wire	[7:0]		i_axi_arlen;	// Read Burst Length
	input	wire	[2:0]		i_axi_arsize;	// Read Burst size
	input	wire	[1:0]		i_axi_arburst;	// Read Burst type
	input	wire	[0:0]		i_axi_arlock;	// Read lock type
	input	wire	[3:0]		i_axi_arcache;	// Read Cache type
	input	wire	[2:0]		i_axi_arprot;	// Read Protection type
	input	wire	[3:0]		i_axi_arqos;	// Read Protection type
	input	wire			i_axi_arvalid;	// Read address valid

// AXI read data channel signals
	output	wire [C_AXI_ID_WIDTH-1:0] o_axi_rid;     // Response ID
	output	wire [1:0]		o_axi_rresp;   // Read response
	output	wire			o_axi_rvalid;  // Read reponse valid
	output	wire [C_AXI_DATA_WIDTH-1:0] o_axi_rdata;    // Read data
	output	wire			o_axi_rlast;    // Read last
	input	wire			i_axi_rready;  // Read Response ready

	// We'll share the clock and the reset
	output	wire			o_reset;
	output	wire			o_wb_cyc;
	output	wire			o_wb_stb;
	output	wire			o_wb_we;
	output	wire [(AW-1):0]	o_wb_addr;
	output	wire [(C_AXI_DATA_WIDTH-1):0]	o_wb_data;
	output	wire [(C_AXI_DATA_WIDTH/8-1):0]	o_wb_sel;
	input	wire			i_wb_ack;
	input	wire			i_wb_stall;
	input	wire [(C_AXI_DATA_WIDTH-1):0]	i_wb_data;
	input	wire			i_wb_err;


	//
	//
	//


	wire	[(AW-1):0]			w_wb_addr, r_wb_addr;
	wire	[(C_AXI_DATA_WIDTH-1):0]	w_wb_data;
	wire	[(C_AXI_DATA_WIDTH/8-1):0]	w_wb_sel;
	wire	r_wb_err, r_wb_cyc, r_wb_stb, r_wb_stall, r_wb_ack;
	wire	w_wb_err, w_wb_cyc, w_wb_stb, w_wb_stall, w_wb_ack;

	// verilator lint_off UNUSED
	wire	r_wb_we, w_wb_we;

	assign	r_wb_we = 1'b0;
	assign	w_wb_we = 1'b1;
	// verilator lint_on  UNUSED

`ifdef	FORMAL
	wire	[(LGFIFO-1):0]	f_wr_fifo_ahead, f_wr_fifo_dhead,
				f_wr_fifo_neck, f_wr_fifo_torso,
				f_wr_fifo_tail,
				f_rd_fifo_head, f_rd_fifo_neck,
				f_rd_fifo_torso, f_rd_fifo_tail;
	wire	[(LGFIFO-1):0]		f_wb_nreqs, f_wb_nacks,
					f_wb_outstanding;
	wire	[(LGFIFO-1):0]		f_wb_wr_nreqs, f_wb_wr_nacks,
					f_wb_wr_outstanding;
	wire	[(LGFIFO-1):0]		f_wb_rd_nreqs, f_wb_rd_nacks,
					f_wb_rd_outstanding;
`endif

	generate if (!OPT_READONLY)
	begin : AXI_WR
	aximwr2wbsp #(
		.C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
		.C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH), .AW(AW),
		.LGFIFO(LGFIFO))
		axi_write_decoder(
			.i_axi_clk(i_clk), .i_axi_reset_n(i_axi_reset_n),
			//
			.o_axi_awready(o_axi_awready),
			.i_axi_awid(   i_axi_awid),
			.i_axi_awaddr( i_axi_awaddr),
			.i_axi_awlen(  i_axi_awlen),
			.i_axi_awsize( i_axi_awsize),
			.i_axi_awburst(i_axi_awburst),
			.i_axi_awlock( i_axi_awlock),
			.i_axi_awcache(i_axi_awcache),
			.i_axi_awprot( i_axi_awprot),
			.i_axi_awqos(  i_axi_awqos),
			.i_axi_awvalid(i_axi_awvalid),
			//
			.o_axi_wready( o_axi_wready),
			.i_axi_wdata(  i_axi_wdata),
			.i_axi_wstrb(  i_axi_wstrb),
			.i_axi_wlast(  i_axi_wlast),
			.i_axi_wvalid( i_axi_wvalid),
			//
			.o_axi_bid(o_axi_bid),
			.o_axi_bresp(o_axi_bresp),
			.o_axi_bvalid(o_axi_bvalid),
			.i_axi_bready(i_axi_bready),
			//
			.o_wb_cyc(  w_wb_cyc),
			.o_wb_stb(  w_wb_stb),
			.o_wb_addr( w_wb_addr),
			.o_wb_data( w_wb_data),
			.o_wb_sel(  w_wb_sel),
			.i_wb_ack(  w_wb_ack),
			.i_wb_stall(w_wb_stall),
			.i_wb_err(  w_wb_err)
`ifdef	FORMAL
			,
			.f_fifo_ahead(f_wr_fifo_ahead),
			.f_fifo_dhead(f_wr_fifo_dhead),
			.f_fifo_neck( f_wr_fifo_neck),
			.f_fifo_torso(f_wr_fifo_torso),
			.f_fifo_tail( f_wr_fifo_tail)
`endif
		);
	end else begin
		assign	w_wb_cyc  = 0;
		assign	w_wb_stb  = 0;
		assign	w_wb_addr = 0;
		assign	w_wb_data = 0;
		assign	w_wb_sel  = 0;
		assign	o_axi_awready = 0;
		assign	o_axi_wready  = 0;
		assign	o_axi_bvalid  = (i_axi_wvalid)&&(i_axi_wlast);
		assign	o_axi_bresp   = 2'b11;
		assign	o_axi_bid     = i_axi_awid;
`ifdef	FORMAL
		assign	f_wr_fifo_ahead  = 0;
		assign	f_wr_fifo_dhead  = 0;
		assign	f_wr_fifo_neck  = 0;
		assign	f_wr_fifo_torso = 0;
		assign	f_wr_fifo_tail  = 0;
`endif
	end endgenerate
	assign	w_wb_we = 1'b1;

	generate if (!OPT_WRITEONLY)
	begin : AXI_RD
	aximrd2wbsp #(
		.C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
		.C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH), .AW(AW),
		.LGFIFO(LGFIFO))
		axi_read_decoder(
			.i_axi_clk(i_clk), .i_axi_reset_n(i_axi_reset_n),
			//
			.o_axi_arready(o_axi_arready),
			.i_axi_arid(   i_axi_arid),
			.i_axi_araddr( i_axi_araddr),
			.i_axi_arlen(  i_axi_arlen),
			.i_axi_arsize( i_axi_arsize),
			.i_axi_arburst(i_axi_arburst),
			.i_axi_arlock( i_axi_arlock),
			.i_axi_arcache(i_axi_arcache),
			.i_axi_arprot( i_axi_arprot),
			.i_axi_arqos(  i_axi_arqos),
			.i_axi_arvalid(i_axi_arvalid),
			//
			.o_axi_rid(   o_axi_rid),
			.o_axi_rresp( o_axi_rresp),
			.o_axi_rvalid(o_axi_rvalid),
			.o_axi_rdata( o_axi_rdata),
			.o_axi_rlast( o_axi_rlast),
			.i_axi_rready(i_axi_rready),
			//
			.o_wb_cyc(  r_wb_cyc),
			.o_wb_stb(  r_wb_stb),
			.o_wb_addr( r_wb_addr),
			.i_wb_ack(  r_wb_ack),
			.i_wb_stall(r_wb_stall),
			.i_wb_data( i_wb_data),
			.i_wb_err(  r_wb_err)
`ifdef	FORMAL
			,
			.f_fifo_head(f_rd_fifo_head),
			.f_fifo_neck(f_rd_fifo_neck),
			.f_fifo_torso(f_rd_fifo_torso),
			.f_fifo_tail(f_rd_fifo_tail)
`endif
			);
	end else begin
		assign	r_wb_cyc  = 0;
		assign	r_wb_stb  = 0;
		assign	r_wb_addr = 0;
		//
		assign o_axi_arready = 1'b1;
		assign o_axi_rvalid  = (i_axi_arvalid)&&(o_axi_arready);
		assign o_axi_rid    = (i_axi_arid);
		assign o_axi_rvalid  = (i_axi_arvalid);
		assign o_axi_rlast   = (i_axi_arvalid);
		assign o_axi_rresp   = (i_axi_arvalid) ? 2'b11 : 2'b00;
		assign o_axi_rdata   = 0;
`ifdef	FORMAL
		assign	f_rd_fifo_head  = 0;
		assign	f_rd_fifo_neck  = 0;
		assign	f_rd_fifo_torso = 0;
		assign	f_rd_fifo_tail  = 0;
`endif
	end endgenerate

	generate if (OPT_READONLY)
	begin : ARB_RD
		assign	o_wb_cyc  = r_wb_cyc;
		assign	o_wb_stb  = r_wb_stb;
		assign	o_wb_we   = 1'b0;
		assign	o_wb_addr = r_wb_addr;
		assign	o_wb_data = 32'h0;
		assign	o_wb_sel  = 0;
		assign	r_wb_ack  = i_wb_ack;
		assign	r_wb_stall= i_wb_stall;
		assign	r_wb_ack  = i_wb_ack;
		assign	r_wb_err  = i_wb_err;

`ifdef	FORMAL
		fwb_master #(.DW(DW), .AW(AW),
			.F_LGDEPTH(LGFIFO),
			.F_MAX_STALL(F_MAXSTALL),
			.F_MAX_ACK_DELAY(F_MAXDELAY),
			.F_OPT_CLK2FFLOGIC(F_OPT_CLK2FFLOGIC))
		f_wb(i_clk, !i_axi_reset_n,
			o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data,
				o_wb_sel,
			i_wb_ack, i_wb_stall, i_wb_data, i_wb_err,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding);

		assign f_wb_rd_nreqs = f_wb_nreqs;
		assign f_wb_rd_nacks = f_wb_nacks;
		assign f_wb_rd_outstanding = f_wb_outstanding;
`endif
	end else if (OPT_WRITEONLY)
	begin : ARB_WR
		assign	o_wb_cyc  = w_wb_cyc;
		assign	o_wb_stb  = w_wb_stb;
		assign	o_wb_we   = 1'b1;
		assign	o_wb_addr = w_wb_addr;
		assign	o_wb_data = w_wb_data;
		assign	o_wb_sel  = w_wb_sel;
		assign	w_wb_ack  = i_wb_ack;
		assign	w_wb_stall= i_wb_stall;
		assign	w_wb_ack  = i_wb_ack;
		assign	w_wb_err  = i_wb_err;

`ifdef FORMAL
		fwb_master #(.DW(DW), .AW(AW),
			.F_LGDEPTH(LGFIFO),
			.F_MAX_STALL(F_MAXSTALL),
			.F_MAX_ACK_DELAY(F_MAXDELAY))
		f_wb(i_clk, !i_axi_reset_n,
			o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data,
				o_wb_sel,
			i_wb_ack, i_wb_stall, i_wb_data, i_wb_err,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding);

		assign f_wb_wr_nreqs = f_wb_nreqs;
		assign f_wb_wr_nacks = f_wb_nacks;
		assign f_wb_wr_outstanding = f_wb_outstanding;
`endif
	end else begin : ARB_WB
		wbarbiter	#(.DW(DW), .AW(AW),
			.F_LGDEPTH(LGFIFO),
			.F_MAX_STALL(F_MAXSTALL),
			.F_OPT_CLK2FFLOGIC(F_OPT_CLK2FFLOGIC),
			.F_MAX_ACK_DELAY(F_MAXDELAY))
			readorwrite(i_clk, !i_axi_reset_n,
			r_wb_cyc, r_wb_stb, 1'b0, r_wb_addr, w_wb_data, w_wb_sel,
				r_wb_ack, r_wb_stall, r_wb_err,
			w_wb_cyc, w_wb_stb, 1'b1, w_wb_addr, w_wb_data, w_wb_sel,
				w_wb_ack, w_wb_stall, w_wb_err,
			o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data, o_wb_sel,
				i_wb_ack, i_wb_stall, i_wb_err
`ifdef	FORMAL
			,
			f_wb_rd_nreqs, f_wb_rd_nacks, f_wb_rd_outstanding,
			f_wb_wr_nreqs, f_wb_wr_nacks, f_wb_wr_outstanding,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding
`endif
			);
	end endgenerate

	assign	o_reset = (i_axi_reset_n == 1'b0);

`ifdef	FORMAL

`ifdef	AXIM2WBSP
	generate if (F_OPT_CLK2FFLOGIC)
	begin
		reg	f_last_clk;

		initial	f_last_clk = 0;
		always @($global_clock)
		begin
			assume(i_clk == f_last_clk);
			f_last_clk <= !f_last_clk;

			if ((f_past_valid)&&(!$rose(i_clk)))
				assume($stable(i_axi_reset_n));
		end
	end endgenerate
`else
`endif

	reg	f_past_valid;

	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid = 1'b1;

	initial	assume(!i_axi_reset_n);
	always @(*)
		if (!f_past_valid)
			assume(!i_axi_reset_n);

	generate if (F_OPT_CLK2FFLOGIC)
	begin

		always @($global_clock)
			if ((f_past_valid)&&(!$rose(i_clk)))
				assert($stable(i_axi_reset_n));
	end endgenerate

	wire	[(C_AXI_ID_WIDTH-1):0]		f_axi_rd_outstanding,
						f_axi_wr_outstanding,
						f_axi_awr_outstanding;
	wire	[((1<<C_AXI_ID_WIDTH)-1):0]	f_axi_rd_id_outstanding,
						f_axi_awr_id_outstanding,
						f_axi_wr_id_outstanding;
	wire	[8:0]				f_axi_wr_pending,
						f_axi_rd_count,
						f_axi_wr_count;

	/*
	generate if (!OPT_READONLY)
	begin : F_WB_WRITE
	fwb_slave #(.DW(DW), .AW(AW),
			.F_MAX_STALL(0),
			.F_MAX_ACK_DELAY(0),
			.F_LGDEPTH(C_AXI_ID_WIDTH),
			.F_OPT_RMW_BUS_OPTION(1),
			.F_OPT_DISCONTINUOUS(1))
		f_wb_wr(i_clk, !i_axi_reset_n,
			w_wb_cyc, w_wb_stb, w_wb_we, w_wb_addr, w_wb_data,
				w_wb_sel,
			w_wb_ack, w_wb_stall, i_wb_data, w_wb_err,
			f_wb_wr_nreqs, f_wb_wr_nacks, f_wb_wr_outstanding);
	end else begin
		assign	f_wb_wr_nreqs = 0;
		assign	f_wb_wr_nacks = 0;
		assign	f_wb_wr_outstanding = 0;
	end endgenerate
	*/

	/*
	generate if (!OPT_WRITEONLY)
	begin : F_WB_READ
	fwb_slave #(.DW(DW), .AW(AW),
			.F_MAX_STALL(0),
			.F_MAX_ACK_DELAY(0),
			.F_LGDEPTH(C_AXI_ID_WIDTH),
			.F_OPT_RMW_BUS_OPTION(1),
			.F_OPT_DISCONTINUOUS(1))
		f_wb_rd(i_clk, !i_axi_reset_n,
			r_wb_cyc, r_wb_stb, r_wb_we, r_wb_addr, w_wb_data, w_wb_sel,
				r_wb_ack, r_wb_stall, i_wb_data, r_wb_err,
			f_wb_rd_nreqs, f_wb_rd_nacks, f_wb_rd_outstanding);
	end else begin
		assign	f_wb_rd_nreqs = 0;
		assign	f_wb_rd_nacks = 0;
		assign	f_wb_rd_outstanding = 0;
	end endgenerate
	*/

	/*
	fwb_master #(.DW(DW), .AW(AW),
			.F_MAX_STALL(F_MAXSTALL),
			.F_MAX_ACK_DELAY(F_MAXDELAY),
			.F_LGDEPTH(C_AXI_ID_WIDTH))
		f_wb(i_clk, !i_axi_reset_n,
			o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data,
				o_wb_sel,
			i_wb_ack, i_wb_stall, i_wb_data, i_wb_err,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding);
	*/

	faxi_slave #(
			.C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
			.C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
			.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
			.F_AXI_MAXSTALL(0),
			.F_AXI_MAXDELAY(0),
			.F_AXI_MAXBURST(OPT_MAXBURST),
			.F_OPT_CLK2FFLOGIC(F_OPT_CLK2FFLOGIC))
		f_axi(.i_clk(i_clk), .i_axi_reset_n(i_axi_reset_n),
			// AXI write address channnel
			.i_axi_awready(o_axi_awready),
			.i_axi_awid(   i_axi_awid),
			.i_axi_awaddr( i_axi_awaddr),
			.i_axi_awlen(  i_axi_awlen),
			.i_axi_awsize( i_axi_awsize),
			.i_axi_awburst(i_axi_awburst),
			.i_axi_awlock( i_axi_awlock),
			.i_axi_awcache(i_axi_awcache),
			.i_axi_awprot( i_axi_awprot),
			.i_axi_awqos(  i_axi_awqos),
			.i_axi_awvalid(i_axi_awvalid),
			// AXI write data channel
			.i_axi_wready( o_axi_wready),
			.i_axi_wdata(  i_axi_wdata),
			.i_axi_wstrb(  i_axi_wstrb),
			.i_axi_wlast(  i_axi_wlast),
			.i_axi_wvalid( i_axi_wvalid),
			// AXI write acknowledgement channel
			.i_axi_bid(   o_axi_bid),
			.i_axi_bresp( o_axi_bresp),
			.i_axi_bvalid(o_axi_bvalid),
			.i_axi_bready(i_axi_bready),
			// AXI read address channel
			.i_axi_arready(o_axi_arready),
			.i_axi_arid(   i_axi_arid),
			.i_axi_araddr( i_axi_araddr),
			.i_axi_arlen(  i_axi_arlen),
			.i_axi_arsize( i_axi_arsize),
			.i_axi_arburst(i_axi_arburst),
			.i_axi_arlock( i_axi_arlock),
			.i_axi_arcache(i_axi_arcache),
			.i_axi_arprot( i_axi_arprot),
			.i_axi_arqos(  i_axi_arqos),
			.i_axi_arvalid(i_axi_arvalid),
			// AXI read data return
			.i_axi_rid(    o_axi_rid),
			.i_axi_rresp(  o_axi_rresp),
			.i_axi_rvalid( o_axi_rvalid),
			.i_axi_rdata(  o_axi_rdata),
			.i_axi_rlast(  o_axi_rlast),
			.i_axi_rready( i_axi_rready),
			// Quantify where we are within a transaction
			.f_axi_rd_outstanding( f_axi_rd_outstanding),
			.f_axi_wr_outstanding( f_axi_wr_outstanding),
			.f_axi_awr_outstanding(f_axi_awr_outstanding),
			.f_axi_rd_id_outstanding(f_axi_rd_id_outstanding),
			.f_axi_awr_id_outstanding(f_axi_awr_id_outstanding),
			.f_axi_wr_id_outstanding(f_axi_wr_id_outstanding),
			.f_axi_wr_pending(f_axi_wr_pending),
			.f_axi_rd_count(f_axi_rd_count),
			.f_axi_wr_count(f_axi_wr_count));

	wire	f_axi_ard_req, f_axi_awr_req, f_axi_wr_req,
		f_axi_rd_ack, f_axi_wr_ack;

	assign	f_axi_ard_req = (i_axi_arvalid)&&(o_axi_arready);
	assign	f_axi_awr_req = (i_axi_awvalid)&&(o_axi_awready);
	assign	f_axi_wr_req  = (i_axi_wvalid)&&(o_axi_wready);
	assign	f_axi_wr_ack  = (o_axi_bvalid)&&(i_axi_bready);
	assign	f_axi_rd_ack  = (o_axi_rvalid)&&(i_axi_rready);

	wire	[(LGFIFO-1):0]	f_awr_fifo_axi_used,
				f_dwr_fifo_axi_used,
				f_rd_fifo_axi_used,
				f_wr_fifo_wb_outstanding,
				f_rd_fifo_wb_outstanding;

	assign	f_awr_fifo_axi_used = f_wr_fifo_ahead - f_wr_fifo_tail;
	assign	f_dwr_fifo_axi_used  = f_wr_fifo_dhead - f_wr_fifo_tail;
	assign	f_rd_fifo_axi_used  = f_rd_fifo_head  - f_rd_fifo_tail;
	assign	f_wr_fifo_wb_outstanding = f_wr_fifo_neck  - f_wr_fifo_torso;
	assign	f_rd_fifo_wb_outstanding = f_rd_fifo_neck  - f_rd_fifo_torso;

	// The number of outstanding requests must always be greater than
	// the number of AXI requests creating them--since the AXI requests
	// may be burst requests.
	//
	always @(*)
		if (OPT_READONLY)
		begin
			assert(f_axi_awr_outstanding == 0);
			assert(f_axi_wr_outstanding  == 0);
			assert(f_axi_awr_id_outstanding == 0);
			assert(f_axi_wr_id_outstanding  == 0);
			assert(f_axi_wr_pending == 0);
			assert(f_axi_wr_count == 0);
		end else begin
			assert(f_awr_fifo_axi_used >= f_axi_awr_outstanding);
			assert(f_dwr_fifo_axi_used >= f_axi_wr_outstanding);
			assert(f_wr_fifo_ahead >= f_axi_awr_outstanding);
		end

	/*
	always @(*)
		assert((!w_wb_cyc)
			||(f_wr_fifo_wb_outstanding
			// -(((w_wb_stall)&&(w_wb_stb))? 1'b1:1'b0)
			+(((w_wb_ack)&&(w_wb_err))? 1'b1:1'b0)
			== f_wb_wr_outstanding));
	*/

	wire	f_r_wb_req, f_r_wb_ack, f_r_wb_stall;
	assign	f_r_wb_req = (r_wb_stb)&&(!r_wb_stall);
	assign	f_r_wb_ack = (r_wb_cyc)&&((r_wb_ack)||(r_wb_err));
	assign	f_r_wb_stall=(r_wb_stb)&&(r_wb_stall);

/*
	always @(*)
		if ((i_axi_reset_n)&&(r_wb_cyc))
			assert(f_rd_fifo_wb_outstanding
				// -((f_r_wb_req)? 1'b1:1'b0)
				-((r_wb_stb)? 1'b1:1'b0)
				//+(((f_r_wb_ack)&&(!f_r_wb_req))? 1'b1:1'b0)
					== f_wb_rd_outstanding);
*/


	//
	assert property((!OPT_READONLY)||(!OPT_WRITEONLY));

	always @(*)
		if (OPT_READONLY)
		begin
			assume(i_axi_awvalid == 0);
			assume(i_axi_wvalid == 0);
		end
	always @(*)
		if (OPT_WRITEONLY)
			assume(i_axi_arvalid == 0);

	always @(*)
		if (i_axi_awvalid)
			assume(i_axi_awburst[1] == 1'b0);
	always @(*)
		if (i_axi_arvalid)
			assume(i_axi_arburst[1] == 1'b0);

	always @(*)
		if (F_OPT_BURSTS)
		begin
			assume((!i_axi_arvalid)||(i_axi_arlen<= OPT_MAXBURST));
			assume((!i_axi_awvalid)||(i_axi_awlen<= OPT_MAXBURST));
		end else begin
			assume((!i_axi_arvalid)||(i_axi_arlen == 0));
			assume((!i_axi_awvalid)||(i_axi_awlen == 0));
		end

`endif
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	aximrd2wbsp.v
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	Bridge an AXI read channel pair to a single wishbone read
//		channel.
//
// Rules:
// 	1. Any read channel error *must* be returned to the correct
//		read channel ID.  In other words, we can't pipeline between IDs
//	2. A FIFO must be used on getting a WB return, to make certain that
//		the AXI return channel is able to stall with no loss
//	3. No request can be accepted unless there is room in the return
//		channel for it
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2019, Gisselquist Technology, LLC
//
// This file is part of the pipelined Wishbone to AXI converter project, a
// project that contains multiple bus bridging designs and formal bus property
// sets.
//
// The bus bridge designs and property sets are free RTL designs: you can
// redistribute them and/or modify any of them under the terms of the GNU
// Lesser General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// The bus bridge designs and property sets are distributed in the hope that
// they will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
// module	aximrd2wbsp #(
module	aximrd2wbsp #(
	parameter C_AXI_ID_WIDTH	= 6, // The AXI id width used for R&W
                                             // This is an int between 1-16
	parameter C_AXI_DATA_WIDTH	= 32,// Width of the AXI R&W data
	parameter C_AXI_ADDR_WIDTH	= 28,	// AXI Address width
	parameter AW			= 26,	// AXI Address width
	parameter LGFIFO                =  9	// Must be >= 8
	// parameter	WBMODE		= "B4PIPELINE"
		// Could also be "BLOCK"
	) (
	input	wire			i_axi_clk,	// Bus clock
	input	wire			i_axi_reset_n,	// Bus reset

// AXI read address channel signals
	output	reg			o_axi_arready,	// Read address ready
	input wire	[C_AXI_ID_WIDTH-1:0]	i_axi_arid,	// Read ID
	input	wire	[C_AXI_ADDR_WIDTH-1:0]	i_axi_araddr,	// Read address
	input	wire	[7:0]		i_axi_arlen,	// Read Burst Length
	input	wire	[2:0]		i_axi_arsize,	// Read Burst size
	input	wire	[1:0]		i_axi_arburst,	// Read Burst type
	input	wire	[0:0]		i_axi_arlock,	// Read lock type
	input	wire	[3:0]		i_axi_arcache,	// Read Cache type
	input	wire	[2:0]		i_axi_arprot,	// Read Protection type
	input	wire	[3:0]		i_axi_arqos,	// Read Protection type
	input	wire			i_axi_arvalid,	// Read address valid
  
// AXI read data channel signals   
	output	wire [C_AXI_ID_WIDTH-1:0] o_axi_rid,     // Response ID
	output	wire [1:0]		o_axi_rresp,   // Read response
	output	reg			o_axi_rvalid,  // Read reponse valid
	output	wire [C_AXI_DATA_WIDTH-1:0] o_axi_rdata,    // Read data
	output	wire 			o_axi_rlast,    // Read last
	input	wire			i_axi_rready,  // Read Response ready

	// We'll share the clock and the reset
	output	reg				o_wb_cyc,
	output	reg				o_wb_stb,
	output	reg [(AW-1):0]			o_wb_addr,
	input	wire				i_wb_ack,
	input	wire				i_wb_stall,
	input	wire [(C_AXI_DATA_WIDTH-1):0]	i_wb_data,
	input	wire				i_wb_err
`ifdef	FORMAL
	// ,
	// output	wire	[LGFIFO-1:0]		f_fifo_head,
	// output	wire	[LGFIFO-1:0]		f_fifo_neck,
	// output	wire	[LGFIFO-1:0]		f_fifo_torso,
	// output	wire	[LGFIFO-1:0]		f_fifo_tail
`endif
	);

	localparam	DW = C_AXI_DATA_WIDTH;

	wire	w_reset;
	assign	w_reset = (i_axi_reset_n == 1'b0);


	wire	[C_AXI_ID_WIDTH+C_AXI_ADDR_WIDTH+25-1:0]	i_rd_request;
	reg	[C_AXI_ID_WIDTH+C_AXI_ADDR_WIDTH+25-1:0]	r_rd_request;
	wire	[C_AXI_ID_WIDTH+C_AXI_ADDR_WIDTH+25-1:0]	w_rd_request;

	reg	[LGFIFO:0]	next_ackptr, next_rptr;

	reg	[C_AXI_ID_WIDTH:0]	request_fifo	[0:((1<<LGFIFO)-1)];
	reg	[C_AXI_ID_WIDTH:0]	rsp_data;

	reg	[C_AXI_DATA_WIDTH:0]	response_fifo	[0:((1<<LGFIFO)-1)];
	reg	[C_AXI_DATA_WIDTH:0]	ack_data;

	reg				advance_ack;


	reg			r_valid, last_stb, last_ack, err_state;
	reg	[C_AXI_ID_WIDTH-1:0]	axi_id;
	reg	[LGFIFO:0]	fifo_wptr, fifo_ackptr, fifo_rptr;
	reg		incr;
	reg	[7:0]	stblen;

	wire	[C_AXI_ID_WIDTH-1:0]	w_id;//    r_id;
	wire	[C_AXI_ADDR_WIDTH-1:0]	w_addr;//  r_addr;
	wire	[7:0]			w_len;//   r_len;
	wire	[2:0]			w_size;//  r_size;
	wire	[1:0]			w_burst;// r_burst;
	wire	[0:0]			w_lock;//  r_lock;
	wire	[3:0]			w_cache;// r_cache;
	wire	[2:0]			w_prot;//  r_prot;
	wire	[3:0]			w_qos;//   r_qos;
	wire	[LGFIFO:0]		fifo_fill;
	wire	[LGFIFO:0]		max_fifo_fill;
	wire				accept_request;



	assign	fifo_fill = (fifo_wptr - fifo_rptr);
	assign	max_fifo_fill = (1<<LGFIFO);

	assign	accept_request = (i_axi_reset_n)&&(!err_state)
			&&((!o_wb_cyc)||(!i_wb_err))
			&&((!o_wb_stb)||(last_stb && !i_wb_stall))
			&&(r_valid ||((i_axi_arvalid)&&(o_axi_arready)))
			// The request must fit into our FIFO before making
			// it
			&&(fifo_fill + {{(LGFIFO-8){1'b0}},w_len} +1
					< max_fifo_fill)
			// One ID at a time, lest we return a bus error
			// to the wrong AXI master
			&&((fifo_fill == 0)||(w_id == axi_id));


	assign	i_rd_request = { i_axi_arid, i_axi_araddr, i_axi_arlen,
				i_axi_arsize, i_axi_arburst, i_axi_arcache,
				i_axi_arlock, i_axi_arprot, i_axi_arqos };

	initial	r_rd_request = 0;
	initial	r_valid      = 0;
	always @(posedge i_axi_clk)
	if (!i_axi_reset_n)
	begin
		r_rd_request <= 0;
		r_valid <= 1'b0;
	end else if ((i_axi_arvalid)&&(o_axi_arready))
	begin
		r_rd_request <= i_rd_request;
		if (!accept_request)
			r_valid <= 1'b1;
	end else if (accept_request)
		r_valid <= 1'b0;

	always @(*)
		o_axi_arready = !r_valid;

	/*
	assign	r_id    = r_rd_request[25 + C_AXI_ADDR_WIDTH +: C_AXI_ID_WIDTH];
	assign	r_addr  = r_rd_request[25 +: C_AXI_ADDR_WIDTH];
	assign	r_len   = r_rd_request[17 +: 8];
	assign	r_size  = r_rd_request[14 +: 3];
	assign	r_burst = r_rd_request[12 +: 2];
	assign	r_lock  = r_rd_request[11 +: 1];
	assign	r_cache = r_rd_request[ 7 +: 4];
	assign	r_prot  = r_rd_request[ 4 +: 3];
	assign	r_qos   = r_rd_request[ 0 +: 4];
	*/

	assign	w_rd_request = (r_valid) ? (r_rd_request) : i_rd_request;

	assign	w_id    = w_rd_request[25 + C_AXI_ADDR_WIDTH +: C_AXI_ID_WIDTH];
	assign	w_addr  = w_rd_request[25 +: C_AXI_ADDR_WIDTH];
	assign	w_len   = w_rd_request[17 +: 8];
	assign	w_size  = w_rd_request[14 +: 3];
	assign	w_burst = w_rd_request[12 +: 2];
	assign	w_lock  = w_rd_request[11 +: 1];
	assign	w_cache = w_rd_request[ 7 +: 4];
	assign	w_prot  = w_rd_request[ 4 +: 3];
	assign	w_qos   = w_rd_request[ 0 +: 4];

	initial o_wb_cyc        = 0;
	initial o_wb_stb        = 0;
	initial stblen          = 0;
	initial incr            = 0;
	initial last_stb        = 0;
	always @(posedge i_axi_clk)
	if (w_reset)
	begin
		o_wb_stb <= 1'b0;
		o_wb_cyc <= 1'b0;
		incr     <= 1'b0;
		stblen   <= 0;
		last_stb <= 0;
	end else if ((!o_wb_stb)||(!i_wb_stall))
	begin
		if (accept_request)
		begin
			// Process the new request
			o_wb_cyc <= 1'b1;
			o_wb_stb <= 1'b1;
			last_stb <= (w_len == 0);

			o_wb_addr <= w_addr[(C_AXI_ADDR_WIDTH-1):(C_AXI_ADDR_WIDTH-AW)];
			incr <= w_burst[0];
			stblen <= w_len;
			axi_id <= w_id;
		// end else if ((o_wb_cyc)&&(i_wb_err)||(err_state))
		end else if (o_wb_stb && !last_stb)
		begin
			// Step forward on the burst request
			last_stb <= (stblen == 1);

			o_wb_addr <= o_wb_addr + ((incr)? 1'b1:1'b0);
			stblen <= stblen - 1'b1;

			if (i_wb_err)
			begin
				stblen <= 0;
				o_wb_stb <= 1'b0;
				o_wb_cyc <= 1'b0;
			end
		end else if (!o_wb_stb || last_stb)
		begin
			// End the request
			o_wb_stb <= 1'b0;
			last_stb <= 1'b0;
			stblen <= 0;

			// Check for the last acknowledgment
			if ((i_wb_ack)&&(last_ack))
				o_wb_cyc <= 1'b0;
			if (i_wb_err)
				o_wb_cyc <= 1'b0;
		end
	end else if ((o_wb_cyc)&&(i_wb_err))
	begin
		stblen <= 0;
		o_wb_stb <= 1'b0;
		o_wb_cyc <= 1'b0;
		last_stb <= 1'b0;
	end

	always @(*)
		next_ackptr = fifo_ackptr + 1'b1;

	always @(*)
	begin
		last_ack = 1'b0;
		if (err_state)
			last_ack = 1'b1;
		else if ((o_wb_stb)&&(stblen == 0)&&(fifo_wptr == fifo_ackptr))
			last_ack = 1'b1;
		else if ((fifo_wptr == next_ackptr)&&(!o_wb_stb))
			last_ack = 1'b1;
	end

	initial	fifo_wptr = 0;
	always @(posedge i_axi_clk)
	if (w_reset)
		fifo_wptr <= 0;
	else if (o_wb_cyc && i_wb_err)
		fifo_wptr <= fifo_wptr + {{(LGFIFO-8){1'b0}},stblen}
				+ ((o_wb_stb)? 1:0);
	else if ((o_wb_stb)&&(!i_wb_stall))
		fifo_wptr <= fifo_wptr + 1'b1;

	initial	fifo_ackptr = 0;
	always @(posedge i_axi_clk)
	if (w_reset)
		fifo_ackptr <= 0;
	else if ((o_wb_cyc)&&((i_wb_ack)||(i_wb_err)))
		fifo_ackptr <= fifo_ackptr + 1'b1;
	else if (err_state && (fifo_ackptr != fifo_wptr))
		fifo_ackptr <= fifo_ackptr + 1'b1;

	always @(posedge i_axi_clk)
	if ((o_wb_stb)&&(!i_wb_stall))
		request_fifo[fifo_wptr[LGFIFO-1:0]] <= { last_stb, axi_id };

	always @(posedge i_axi_clk)
	if ((o_wb_cyc && ((i_wb_ack)||(i_wb_err)))
		||(err_state && (fifo_ackptr != fifo_wptr)))
		response_fifo[fifo_ackptr[LGFIFO-1:0]]
			<= { (err_state||i_wb_err), i_wb_data };

	initial	fifo_rptr = 0;
	always @(posedge i_axi_clk)
	if (w_reset)
		fifo_rptr <= 0;
	else if ((o_axi_rvalid)&&(i_axi_rready))
		fifo_rptr <= fifo_rptr + 1'b1;

	always @(*)
		next_rptr = fifo_rptr + 1'b1;

	always @(posedge i_axi_clk)
	if (advance_ack)
		ack_data <= response_fifo[fifo_rptr[LGFIFO-1:0]];

	always @(posedge i_axi_clk)
	if (advance_ack)
		rsp_data <= request_fifo[fifo_rptr[LGFIFO-1:0]];

	always @(*)
	if ((o_axi_rvalid)&&(i_axi_rready))
		advance_ack = (fifo_ackptr != next_rptr);
	else if ((!o_axi_rvalid)&&(fifo_ackptr != fifo_rptr))
		advance_ack = 1'b1;
	else
		advance_ack = 1'b0;

	initial	o_axi_rvalid = 0;
	always @(posedge i_axi_clk)
	if (w_reset)
		o_axi_rvalid <= 1'b0;
	else if (advance_ack)
		o_axi_rvalid <= 1'b1;
	else if (i_axi_rready)
		o_axi_rvalid <= 1'b0;

	initial	err_state = 0;
	always @(posedge i_axi_clk)
	if (w_reset)
		err_state <= 1'b0;
	else if ((o_wb_cyc)&&(i_wb_err))
		err_state <= 1'b1;
	else if ((!o_wb_stb)&&(fifo_wptr == fifo_rptr))
		err_state <= 1'b0;

	assign	o_axi_rlast = rsp_data[C_AXI_ID_WIDTH];
	assign	o_axi_rid   = rsp_data[0 +: C_AXI_ID_WIDTH];
	assign	o_axi_rresp = {(2){ack_data[C_AXI_DATA_WIDTH]}};
	assign	o_axi_rdata = ack_data[0 +: C_AXI_DATA_WIDTH];

	// Make Verilator happy
	// verilator lint_off UNUSED
	wire	[(C_AXI_ID_WIDTH+1)+(C_AXI_ADDR_WIDTH-AW)
		+27-1:0]	unused;
	assign	unused = { i_axi_arsize, i_axi_arburst[1],
		i_axi_arlock, i_axi_arcache, i_axi_arprot, i_axi_arqos,
		w_burst[1], w_size, w_lock, w_cache, w_prot, w_qos, w_addr[1:0],
			i_axi_araddr[(C_AXI_ADDR_WIDTH-AW-1):0] };
	// verilator lint_on  UNUSED

`ifdef	FORMAL
	reg	f_past_valid;
	initial f_past_valid = 1'b0;
	always @(posedge i_axi_clk)
		f_past_valid <= 1'b1;

	////////////////////////////////////////////////////////////////////////
	//
	// Assumptions
	//
	//
	always @(*)
	if (!f_past_valid)
		assume(w_reset);


	////////////////////////////////////////////////////////////////////////
	//
	// Ad-hoc assertions
	//
	//
	always @(*)
	if (o_wb_stb)
		assert(last_stb == (stblen == 0));
	else
		assert((!last_stb)&&(stblen == 0));

	////////////////////////////////////////////////////////////////////////
	//
	// Error state
	//
	//
	/*
	always @(*)
		assume(!i_wb_err);
	always @(*)
		assert(!err_state);
	*/
	always @(*)
	if ((!err_state)&&(o_axi_rvalid))
		assert(o_axi_rresp == 2'b00);

	////////////////////////////////////////////////////////////////////////
	//
	// FIFO pointers
	//
	//
	wire	[LGFIFO:0]	f_fifo_wb_used, f_fifo_ackremain, f_fifo_used;
	assign	f_fifo_used       = fifo_wptr   - fifo_rptr;
	assign	f_fifo_wb_used    = fifo_wptr   - fifo_ackptr;
	assign	f_fifo_ackremain  = fifo_ackptr - fifo_rptr;

	always @(*)
	if (o_wb_stb)
		assert(f_fifo_used + stblen + 1 < {(LGFIFO){1'b1}});
	else
		assert(f_fifo_used < {(LGFIFO){1'b1}});
	always @(*)
		assert(f_fifo_wb_used   <= f_fifo_used);
	always @(*)
		assert(f_fifo_ackremain <= f_fifo_used);

	// Reset properties
	always @(posedge i_axi_clk)
	if ((!f_past_valid)||($past(w_reset)))
	begin
		assert(fifo_wptr   == 0);
		assert(fifo_ackptr == 0);
		assert(fifo_rptr   == 0);
	end

	localparam	F_LGDEPTH = LGFIFO+1, F_LGRDFIFO = 72; // 9*F_LGFIFO;
	wire	[(9-1):0]		f_axi_rd_count;
	wire	[(F_LGRDFIFO-1):0]	f_axi_rdfifo;
	wire	[(F_LGDEPTH-1):0]	f_axi_rd_nbursts, f_axi_rd_outstanding,
					f_axi_awr_outstanding,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding;

	fwb_master #(.AW(AW), .DW(C_AXI_DATA_WIDTH), .F_MAX_STALL(2),
		.F_MAX_ACK_DELAY(3), .F_LGDEPTH(F_LGDEPTH),
		.F_OPT_DISCONTINUOUS(1))
		fwb(i_axi_clk, w_reset,
			o_wb_cyc, o_wb_stb, 1'b0, o_wb_addr, {(DW){1'b0}}, 4'hf,
			i_wb_ack, i_wb_stall, i_wb_data, i_wb_err,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding);

	always @(*)
	if (err_state)
		assert(f_wb_outstanding == 0);
	else
		assert(f_wb_outstanding == f_fifo_wb_used);


	faxi_slave	#(.C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
			.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
			.F_OPT_BURSTS(1'b0),
			.F_LGDEPTH(F_LGDEPTH),
			.F_AXI_MAXSTALL(0),
			.F_AXI_MAXDELAY(0))
		faxi(.i_clk(i_axi_clk), .i_axi_reset_n(!w_reset),
			.i_axi_awready(1'b0),
			.i_axi_awaddr(0),
			.i_axi_awlen(0),
			.i_axi_awsize(0),
			.i_axi_awburst(0),
			.i_axi_awlock(0),
			.i_axi_awcache(0),
			.i_axi_awprot(0),
			.i_axi_awqos(0),
			.i_axi_awvalid(1'b0),
			//
			.i_axi_wready(1'b0),
			.i_axi_wdata(0),
			.i_axi_wstrb(0),
			.i_axi_wlast(0),
			.i_axi_wvalid(1'b0),
			//
			.i_axi_bresp(0),
			.i_axi_bvalid(1'b0),
			.i_axi_bready(1'b0),
			//
			.i_axi_arready(o_axi_arready),
			.i_axi_araddr(i_axi_araddr),
			.i_axi_arlen(i_axi_arlen),
			.i_axi_arsize(i_axi_arsize),
			.i_axi_arburst(i_axi_arburst),
			.i_axi_arlock(i_axi_arlock),
			.i_axi_arcache(i_axi_arcache),
			.i_axi_arprot(i_axi_arprot),
			.i_axi_arqos(i_axi_arqos),
			.i_axi_arvalid(i_axi_arvalid),
			//
			.i_axi_rresp(o_axi_rresp),
			.i_axi_rvalid(o_axi_rvalid),
			.i_axi_rdata(o_axi_rdata),
			.i_axi_rlast(o_axi_rlast),
			.i_axi_rready(i_axi_rready),
			//
			.f_axi_rd_nbursts(f_axi_rd_nbursts),
			.f_axi_rd_outstanding(f_axi_rd_outstanding),
			.f_axi_wr_nbursts(),
			.f_axi_awr_outstanding(f_axi_awr_outstanding),
			.f_axi_awr_nbursts(),
			//
			.f_axi_rd_count(f_axi_rd_count),
			.f_axi_rdfifo(f_axi_rdfifo));

	always @(*)
		assert(f_axi_awr_outstanding == 0);

`endif
endmodule
`error This full featured AXI to WB converter does not (yet) work
////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	aximwr2wbsp.v
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	Convert the three AXI4 write channels to a single wishbone
//		channel to write the results.
//
//	Still need to implement the lock feature.
//
	// We're going to need to keep track of transaction bursts in progress,
	// since the wishbone doesn't.  For this, we'll use a FIFO, but with
	// multiple pointers:
	//
	//	fifo_ahead	- pointer to where to write the next incoming
	//				bus request .. adjusted when
	//				(o_axi_awready)&&(i_axi_awvalid)
	//	fifo_neck	- pointer to where to read from the FIFO in
	//				order to issue another request.  Used
	//				when (o_wb_stb)&&(!i_wb_stall)
	//	fifo_torso	- pointer to where to write a wishbone
	//				transaction upon return.
	//				when (i_ack)
	//	fifo_tail	- pointer to where the last transaction is to
	//				be retired when
	//					(i_axi_rvalid)&&(i_axi_rready)
	//
	// All of these are to be set to zero upon a reset signal.
	//
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015-2019, Gisselquist Technology, LLC
//
// This file is part of the pipelined Wishbone to AXI converter project, a
// project that contains multiple bus bridging designs and formal bus property
// sets.
//
// The bus bridge designs and property sets are free RTL designs: you can
// redistribute them and/or modify any of them under the terms of the GNU
// Lesser General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// The bus bridge designs and property sets are distributed in the hope that
// they will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
//
module aximwr2wbsp #(
	parameter C_AXI_ID_WIDTH	= 6, // The AXI id width used for R&W
                                             // This is an int between 1-16
	parameter C_AXI_DATA_WIDTH	= 32,// Width of the AXI R&W data
	parameter C_AXI_ADDR_WIDTH	= 28,	// AXI Address width
	parameter AW			= 26,
	parameter LGFIFO                =  4
	) (
	input	wire			i_axi_clk,	// System clock
	input	wire			i_axi_reset_n,

// AXI write address channel signals
	output	wire			o_axi_awready, // Slave is ready to accept
	input	wire	[C_AXI_ID_WIDTH-1:0]	i_axi_awid,	// Write ID
	input	wire	[C_AXI_ADDR_WIDTH-1:0]	i_axi_awaddr,	// Write address
	input	wire	[7:0]		i_axi_awlen,	// Write Burst Length
	input	wire	[2:0]		i_axi_awsize,	// Write Burst size
	input	wire	[1:0]		i_axi_awburst,	// Write Burst type
	input	wire	[0:0]		i_axi_awlock,	// Write lock type
	input	wire	[3:0]		i_axi_awcache,	// Write Cache type
	input	wire	[2:0]		i_axi_awprot,	// Write Protection type
	input	wire	[3:0]		i_axi_awqos,	// Write Quality of Svc
	input	wire			i_axi_awvalid,	// Write address valid
  
// AXI write data channel signals
	output	wire			o_axi_wready,  // Write data ready
	input	wire	[C_AXI_DATA_WIDTH-1:0]	i_axi_wdata,	// Write data
	input	wire	[C_AXI_DATA_WIDTH/8-1:0] i_axi_wstrb,	// Write strobes
	input	wire			i_axi_wlast,	// Last write transaction   
	input	wire			i_axi_wvalid,	// Write valid
  
// AXI write response channel signals
	output	wire [C_AXI_ID_WIDTH-1:0] o_axi_bid,	// Response ID
	output	wire [1:0]		o_axi_bresp,	// Write response
	output	wire			o_axi_bvalid,  // Write reponse valid
	input	wire			i_axi_bready,  // Response ready
  
	// We'll share the clock and the reset
	output	reg			o_wb_cyc,
	output	reg			o_wb_stb,
	output	wire [(AW-1):0]		o_wb_addr,
	output	wire [(C_AXI_DATA_WIDTH-1):0]	o_wb_data,
	output	wire [(C_AXI_DATA_WIDTH/8-1):0]	o_wb_sel,
	input	wire			i_wb_ack,
	input	wire			i_wb_stall,
	// input	[(C_AXI_DATA_WIDTH-1):0]	i_wb_data,
	input	wire			i_wb_err
`ifdef	FORMAL
	,
	output	wire	[LGFIFO-1:0]	f_fifo_ahead,
	output	wire	[LGFIFO-1:0]	f_fifo_dhead,
	output	wire	[LGFIFO-1:0]	f_fifo_neck,
	output	wire	[LGFIFO-1:0]	f_fifo_torso,
	output	wire	[LGFIFO-1:0]	f_fifo_tail
`endif
);

	localparam	DW = C_AXI_DATA_WIDTH;

	wire	w_reset;
	assign	w_reset = (i_axi_reset_n == 1'b0);

	//
	//
	//
	reg	[LGFIFO-1:0]	fifo_ahead, fifo_dhead, fifo_neck, fifo_torso,
				fifo_tail;
	wire	[LGFIFO-1:0]	next_ahead, next_dhead, next_neck, next_torso,
				next_tail;
	assign	next_ahead = fifo_ahead + 1;
	assign	next_dhead = fifo_dhead + 1;
	assign	next_neck  = fifo_neck  + 1;
	assign	next_torso = fifo_torso + 1;
	assign	next_tail  = fifo_tail  + 1;

	reg	[(C_AXI_ID_WIDTH+AW)-1:0]	afifo	[0:((1<<(LGFIFO))-1)];
	reg	[(DW + DW/8)-1:0]		dfifo	[0:((1<<(LGFIFO))-1)];
	reg	[((1<<(LGFIFO))-1):0]		efifo;

	reg	[(C_AXI_ID_WIDTH+AW)-1:0]	afifo_at_neck, afifo_at_tail;
	reg	[(DW + DW/8)-1:0]		dfifo_at_neck;
	reg					efifo_at_tail;

	reg	filling_fifo, incr;
	reg	[7:0]	len;
	reg	[(AW-1):0]	wr_fifo_addr;
	reg	[(C_AXI_ID_WIDTH-1):0]	wr_fifo_id;

	wire	axi_aw_req, axi_wr_req, axi_wr_ack;
	assign	axi_aw_req = (o_axi_awready)&&(i_axi_awvalid);
	assign	axi_wr_req = (o_axi_wready)&&(i_axi_wvalid);
	assign	axi_wr_ack = (o_axi_bvalid)&&(i_axi_bready);

	wire	fifo_full;
	assign	fifo_full = (next_ahead == fifo_tail)||(next_dhead ==fifo_tail);

	initial	fifo_ahead = 0;
	initial	fifo_dhead = 0;
	always @(posedge i_axi_clk)
	begin
		if (filling_fifo)
		begin
			if (!fifo_full)
			begin
				len <= len - 1;
				if (len == 1)
					filling_fifo <= 1'b0;
				fifo_ahead <= next_ahead;
				wr_fifo_addr <= wr_fifo_addr
					+ {{(AW-1){1'b0}},incr};
			end
		end else begin
			wr_fifo_addr <= i_axi_awaddr[(C_AXI_ADDR_WIDTH-1):(C_AXI_ADDR_WIDTH-AW)];
			wr_fifo_id   <= i_axi_awid;
			incr         <= i_axi_awburst[0];
			if (axi_aw_req)
			begin
				fifo_ahead <= next_ahead;
				len <= i_axi_awlen;
				filling_fifo <= (i_axi_awlen != 0);
			end
		end

		if (w_reset)
		begin
			fifo_ahead <= 0;
			len <= 0;
			filling_fifo <= 0;
		end
	end

	always @(posedge i_axi_clk)
		afifo[fifo_ahead] <= { wr_fifo_id, wr_fifo_addr };

	initial	fifo_dhead = 0;
	always @(posedge i_axi_clk)
		if (w_reset)
			fifo_dhead <= 0;
		else if (axi_wr_req)
			fifo_dhead <= next_dhead;

	always @(posedge i_axi_clk)
		dfifo[fifo_dhead] <= { i_axi_wstrb, i_axi_wdata };


	reg	err_state;

	initial	o_wb_cyc   = 0;
	initial o_wb_stb   = 0;
	initial fifo_neck  = 0;
	initial fifo_torso = 0;
	initial err_state  = 0;
	always @(posedge i_axi_clk)
	begin
		if (w_reset)
		begin
			o_wb_cyc <= 0;
			o_wb_stb <= 0;

			fifo_neck <= 0;
			fifo_torso <= 0;

			err_state <= 0;
		end else if (o_wb_stb)
		begin
			if (i_wb_err)
			begin
				o_wb_cyc <= 1'b0;
				o_wb_stb <= 1'b0;
				err_state <= 1'b1;
			end else if (!i_wb_stall)
				o_wb_stb <= (fifo_ahead != next_neck)
					&&(fifo_dhead != next_neck);

			if ((!i_wb_stall)&&(fifo_neck != fifo_ahead)&&(fifo_neck != fifo_dhead))
				fifo_neck <= next_neck;

			if (i_wb_ack)
				fifo_torso <= next_torso;

			if (fifo_neck == next_torso)
				o_wb_cyc <= 1'b0;
		end else if ((err_state)||(i_wb_err))
		begin
			o_wb_cyc <= 1'b0;
			o_wb_stb <= 1'b0;
			err_state <= (err_state)||(i_wb_err);
			if ((o_wb_cyc)&&(fifo_torso != fifo_neck))
				fifo_torso <= next_torso;
			if (fifo_neck == next_torso)
				err_state <= 1'b0;
		end else if (o_wb_cyc)
		begin
			if (i_wb_ack)
				fifo_torso <= next_torso;
			if (fifo_neck == next_torso)
				o_wb_cyc <= 1'b0;
		end else if((fifo_ahead!= fifo_neck)
				&&(fifo_dhead != fifo_neck))
		begin
			o_wb_cyc <= 1;
			o_wb_stb <= 1;
		end
	end

	initial	efifo = 0;
	always @(posedge i_axi_clk)
		if(w_reset)
			efifo <= 0;
		else
			efifo[fifo_torso] <= (i_wb_err)||(err_state);

	always @(posedge i_axi_clk)
		afifo_at_neck <= afifo[fifo_neck];
	assign	o_wb_addr = afifo_at_neck[(AW-1):0];

	always @(posedge i_axi_clk)
		dfifo_at_neck <= dfifo[fifo_neck];
	assign	o_wb_data = dfifo_at_neck[DW-1:0];
	assign	o_wb_sel  = dfifo_at_neck[(DW+(DW/8))-1:DW];

	initial	fifo_tail = 0;
	always @(posedge i_axi_clk)
		if (w_reset)
			fifo_tail <= 0;
		else if (axi_wr_ack)
			fifo_tail <= next_tail;

	always @(posedge i_axi_clk)
		afifo_at_tail <= afifo[fifo_tail];
	always @(posedge i_axi_clk)
		efifo_at_tail <= efifo[fifo_tail];

	assign	o_axi_bid   = afifo_at_tail[(C_AXI_ID_WIDTH+AW)-1:AW];
	assign	o_axi_bresp = {(2){efifo_at_tail}};

	assign	o_axi_bvalid  = (fifo_tail  != fifo_torso);
	assign	o_axi_awready = (next_ahead != fifo_tail);
	assign	o_axi_wready  = (next_dhead != fifo_tail);

	// Make Verilator happy
	// verilator lint_on  UNUSED
	wire	[(C_AXI_ID_WIDTH+AW+C_AXI_ADDR_WIDTH-AW)
		+(1)+1+3+1+4+3+4-1:0]	unused;
	assign	unused = { i_axi_awburst[1], i_axi_awsize,
			i_axi_awlock, i_axi_awcache, i_axi_awprot,
			i_axi_awqos, i_axi_wlast,
			afifo_at_neck[(C_AXI_ID_WIDTH+AW-1):AW],
			afifo_at_tail[(AW-1):0],
			i_axi_awaddr[(C_AXI_ADDR_WIDTH-AW)-1:0] };
	// verilator lint_off UNUSED

`ifdef	FORMAL
	always @(*)
		assume(!i_axi_awburst[1]);

	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge i_axi_clk)
		f_past_valid <= 1'b1;

	wire	[LGFIFO-1:0]	f_afifo_used, f_dfifo_used,
				f_fifo_neck_used, f_fifo_torso_used;

	assign	f_afifo_used      = fifo_ahead - fifo_tail;
	assign	f_dfifo_used      = fifo_dhead - fifo_tail;
	assign	f_fifo_neck_used  = fifo_dhead - fifo_neck;
	assign	f_fifo_torso_used = fifo_dhead - fifo_torso;

	always @(*)
		assert((f_afifo_used < {(LGFIFO){1'b1}})||(!o_axi_awready));
	always @(*)
		assert((f_dfifo_used < {(LGFIFO){1'b1}})||(!o_axi_wready));
	always @(*)
		assert(f_fifo_neck_used  <= f_dfifo_used);
	always @(*)
		assert(f_fifo_torso_used <= f_dfifo_used);
	always @(*)
		assert((!o_wb_stb)||
			((fifo_neck != fifo_ahead)
				&&(fifo_neck != fifo_dhead)));

	assign	f_fifo_ahead = fifo_ahead;
	assign	f_fifo_dhead = fifo_dhead;
	assign	f_fifo_neck  = fifo_neck;
	assign	f_fifo_torso = fifo_torso;
	assign	f_fifo_tail  = fifo_tail;

	always @(*)
		if (i_axi_awvalid)
			assert(!i_axi_awburst[1]);
`endif
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	axlite2wbsp.v
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	Take an AXI lite input, and convert it into WB.
//
//	We'll treat AXI as two separate busses: one for writes, another for
//	reads, further, we'll insist that the two channels AXI uses for writes
//	combine into one channel for our purposes.
//
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2016-2019, Gisselquist Technology, LLC
//
// This file is part of the pipelined Wishbone to AXI converter project, a
// project that contains multiple bus bridging designs and formal bus property
// sets.
//
// The bus bridge designs and property sets are free RTL designs: you can
// redistribute them and/or modify any of them under the terms of the GNU
// Lesser General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// The bus bridge designs and property sets are distributed in the hope that
// they will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module axlite2wbsp( i_clk, i_axi_reset_n,
	//
	o_axi_awready, i_axi_awaddr, i_axi_awcache, i_axi_awprot,i_axi_awvalid,
	//
	o_axi_wready, i_axi_wdata, i_axi_wstrb, i_axi_wvalid,
	//
	o_axi_bresp, o_axi_bvalid, i_axi_bready,
	//
	o_axi_arready, i_axi_araddr, i_axi_arcache, i_axi_arprot, i_axi_arvalid,
	//
	o_axi_rresp, o_axi_rvalid, o_axi_rdata, i_axi_rready,
	//
	// Wishbone interface
	o_reset, o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data, o_wb_sel,
	i_wb_ack, i_wb_stall, i_wb_data, i_wb_err);
	//
	parameter C_AXI_DATA_WIDTH	= 32;// Width of the AXI R&W data
	parameter C_AXI_ADDR_WIDTH	= 28;	// AXI Address width
	parameter		LGFIFO = 4;
	parameter		F_MAXSTALL = 3;
	parameter		F_MAXDELAY = 3;
	parameter	[0:0]	OPT_READONLY  = 1'b0;
	parameter	[0:0]	OPT_WRITEONLY = 1'b0;
	localparam	F_LGDEPTH = LGFIFO+1;
	//
	input	wire			i_clk;	// System clock
	input	wire			i_axi_reset_n;

// AXI write address channel signals
	output	wire			o_axi_awready;//Slave is ready to accept
	input	wire	[C_AXI_ADDR_WIDTH-1:0]	i_axi_awaddr;	// Write address
	input	wire	[3:0]		i_axi_awcache;	// Write Cache type
	input	wire	[2:0]		i_axi_awprot;	// Write Protection type
	input	wire			i_axi_awvalid;	// Write address valid

// AXI write data channel signals
	output	wire			o_axi_wready;  // Write data ready
	input	wire	[C_AXI_DATA_WIDTH-1:0]	i_axi_wdata;	// Write data
	input	wire	[C_AXI_DATA_WIDTH/8-1:0] i_axi_wstrb;	// Write strobes
	input	wire			i_axi_wvalid;	// Write valid

// AXI write response channel signals
	output	wire [1:0]		o_axi_bresp;	// Write response
	output	wire 			o_axi_bvalid;  // Write reponse valid
	input	wire			i_axi_bready;  // Response ready

// AXI read address channel signals
	output	wire			o_axi_arready;	// Read address ready
	input	wire	[C_AXI_ADDR_WIDTH-1:0]	i_axi_araddr;	// Read address
	input	wire	[3:0]		i_axi_arcache;	// Read Cache type
	input	wire	[2:0]		i_axi_arprot;	// Read Protection type
	input	wire			i_axi_arvalid;	// Read address valid

// AXI read data channel signals
	output	wire [1:0]		o_axi_rresp;   // Read response
	output	wire			o_axi_rvalid;  // Read reponse valid
	output	wire [C_AXI_DATA_WIDTH-1:0] o_axi_rdata;    // Read data
	input	wire			i_axi_rready;  // Read Response ready

	// We'll share the clock and the reset
	output	wire			o_reset;
	output	wire			o_wb_cyc;
	output	wire			o_wb_stb;
	output	wire			o_wb_we;
	output	wire [(C_AXI_ADDR_WIDTH-3):0]		o_wb_addr;
	output	wire [(C_AXI_DATA_WIDTH-1):0]		o_wb_data;
	output	wire [(C_AXI_DATA_WIDTH/8-1):0]	o_wb_sel;
	input	wire			i_wb_ack;
	input	wire			i_wb_stall;
	input	wire [(C_AXI_DATA_WIDTH-1):0]		i_wb_data;
	input	wire			i_wb_err;


	localparam DW = C_AXI_DATA_WIDTH;
	localparam AW = C_AXI_ADDR_WIDTH-2;
	//
	//
	//

	wire	[(AW-1):0]			w_wb_addr, r_wb_addr;
	wire	[(C_AXI_DATA_WIDTH-1):0]	w_wb_data;
	wire	[(C_AXI_DATA_WIDTH/8-1):0]	w_wb_sel;
	wire	r_wb_err, r_wb_cyc, r_wb_stb, r_wb_stall, r_wb_ack;
	wire	w_wb_err, w_wb_cyc, w_wb_stb, w_wb_stall, w_wb_ack;

	// verilator lint_off UNUSED
	wire	r_wb_we, w_wb_we;

	assign	r_wb_we = 1'b0;
	assign	w_wb_we = 1'b1;
	// verilator lint_on  UNUSED

`ifdef	FORMAL
	wire	[LGFIFO:0]	f_wr_fifo_first, f_rd_fifo_first,
				f_wr_fifo_mid,   f_rd_fifo_mid,
				f_wr_fifo_last,  f_rd_fifo_last;
	wire	[(F_LGDEPTH-1):0]	f_wb_nreqs, f_wb_nacks,
					f_wb_outstanding;
	wire	[(F_LGDEPTH-1):0]	f_wb_wr_nreqs, f_wb_wr_nacks,
					f_wb_wr_outstanding;
	wire	[(F_LGDEPTH-1):0]	f_wb_rd_nreqs, f_wb_rd_nacks,
					f_wb_rd_outstanding;
	wire			f_pending_awvalid, f_pending_wvalid;
`endif

	//
	// AXI-lite write channel to WB processing
	//
	generate if (!OPT_READONLY)
	begin : AXI_WR
	axilwr2wbsp #(
		// .F_LGDEPTH(F_LGDEPTH),
		// .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH), // .AW(AW),
		.LGFIFO(LGFIFO))
		axi_write_decoder(
			.i_clk(i_clk), .i_axi_reset_n(i_axi_reset_n),
			//
			.o_axi_awready(o_axi_awready),
			.i_axi_awaddr( i_axi_awaddr),
			.i_axi_awcache(i_axi_awcache),
			.i_axi_awprot( i_axi_awprot),
			.i_axi_awvalid(i_axi_awvalid),
			//
			.o_axi_wready( o_axi_wready),
			.i_axi_wdata(  i_axi_wdata),
			.i_axi_wstrb(  i_axi_wstrb),
			.i_axi_wvalid( i_axi_wvalid),
			//
			.o_axi_bresp(o_axi_bresp),
			.o_axi_bvalid(o_axi_bvalid),
			.i_axi_bready(i_axi_bready),
			//
			.o_wb_cyc(  w_wb_cyc),
			.o_wb_stb(  w_wb_stb),
			.o_wb_addr( w_wb_addr),
			.o_wb_data( w_wb_data),
			.o_wb_sel(  w_wb_sel),
			.i_wb_ack(  w_wb_ack),
			.i_wb_stall(w_wb_stall),
			.i_wb_err(  w_wb_err)
`ifdef	FORMAL
			,
			.f_first(f_wr_fifo_first),
			.f_mid(  f_wr_fifo_mid),
			.f_last( f_wr_fifo_last),
			.f_wpending({ f_pending_awvalid, f_pending_wvalid })
`endif
		);
	end else begin
		assign	w_wb_cyc  = 0;
		assign	w_wb_stb  = 0;
		assign	w_wb_addr = 0;
		assign	w_wb_data = 0;
		assign	w_wb_sel  = 0;
		assign	o_axi_awready = 0;
		assign	o_axi_wready  = 0;
		assign	o_axi_bvalid  = (i_axi_wvalid);
		assign	o_axi_bresp   = 2'b11;
`ifdef	FORMAL
		assign	f_wr_fifo_first = 0;
		assign	f_wr_fifo_mid   = 0;
		assign	f_wr_fifo_last  = 0;
		assign	f_pending_awvalid=0;
		assign	f_pending_wvalid =0;
`endif
	end endgenerate
	assign	w_wb_we = 1'b1;

	//
	// AXI-lite read channel to WB processing
	//
	generate if (!OPT_WRITEONLY)
	begin : AXI_RD
	axilrd2wbsp #(
		// .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.LGFIFO(LGFIFO))
		axi_read_decoder(
			.i_clk(i_clk), .i_axi_reset_n(i_axi_reset_n),
			//
			.o_axi_arready(o_axi_arready),
			.i_axi_araddr( i_axi_araddr),
			.i_axi_arcache(i_axi_arcache),
			.i_axi_arprot( i_axi_arprot),
			.i_axi_arvalid(i_axi_arvalid),
			//
			.o_axi_rresp( o_axi_rresp),
			.o_axi_rvalid(o_axi_rvalid),
			.o_axi_rdata( o_axi_rdata),
			.i_axi_rready(i_axi_rready),
			//
			.o_wb_cyc(  r_wb_cyc),
			.o_wb_stb(  r_wb_stb),
			.o_wb_addr( r_wb_addr),
			.i_wb_ack(  r_wb_ack),
			.i_wb_stall(r_wb_stall),
			.i_wb_data( i_wb_data),
			.i_wb_err(  r_wb_err)
`ifdef	FORMAL
			,
			.f_first(f_rd_fifo_first),
			.f_mid(  f_rd_fifo_mid),
			.f_last( f_rd_fifo_last)
`endif
			);
	end else begin
		assign	r_wb_cyc  = 0;
		assign	r_wb_stb  = 0;
		assign	r_wb_addr = 0;
		//
		assign o_axi_arready = 1'b1;
		assign o_axi_rvalid  = (i_axi_arvalid)&&(o_axi_arready);
		assign o_axi_rresp   = (i_axi_arvalid) ? 2'b11 : 2'b00;
		assign o_axi_rdata   = 0;
`ifdef	FORMAL
		assign	f_rd_fifo_first = 0;
		assign	f_rd_fifo_mid   = 0;
		assign	f_rd_fifo_last  = 0;
`endif
	end endgenerate

	//
	//
	// The arbiter that pastes the two sides together
	//
	//
	generate if (OPT_READONLY)
	begin : ARB_RD
		assign	o_wb_cyc  = r_wb_cyc;
		assign	o_wb_stb  = r_wb_stb;
		assign	o_wb_we   = 1'b0;
		assign	o_wb_addr = r_wb_addr;
		assign	o_wb_data = 32'h0;
		assign	o_wb_sel  = 0;
		assign	r_wb_ack  = i_wb_ack;
		assign	r_wb_stall= i_wb_stall;
		assign	r_wb_ack  = i_wb_ack;
		assign	r_wb_err  = i_wb_err;

`ifdef	FORMAL
		fwb_master #(.DW(DW), .AW(AW),
			.F_LGDEPTH(F_LGDEPTH),
			.F_MAX_STALL(F_MAXSTALL),
			.F_MAX_ACK_DELAY(F_MAXDELAY))
		f_wb(i_clk, !i_axi_reset_n,
			o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data,
				o_wb_sel,
			i_wb_ack, i_wb_stall, i_wb_data, i_wb_err,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding);

		assign f_wb_rd_nreqs = f_wb_nreqs;
		assign f_wb_rd_nacks = f_wb_nacks;
		assign f_wb_rd_outstanding = f_wb_outstanding;
		//
		assign f_wb_wr_nreqs = 0;
		assign f_wb_wr_nacks = 0;
		assign f_wb_wr_outstanding = 0;
`endif
	end else if (OPT_WRITEONLY)
	begin : ARB_WR
		assign	o_wb_cyc  = w_wb_cyc;
		assign	o_wb_stb  = w_wb_stb;
		assign	o_wb_we   = 1'b1;
		assign	o_wb_addr = w_wb_addr;
		assign	o_wb_data = w_wb_data;
		assign	o_wb_sel  = w_wb_sel;
		assign	w_wb_ack  = i_wb_ack;
		assign	w_wb_stall= i_wb_stall;
		assign	w_wb_ack  = i_wb_ack;
		assign	w_wb_err  = i_wb_err;

`ifdef FORMAL
		fwb_master #(.DW(DW), .AW(AW),
			.F_LGDEPTH(F_LGDEPTH),
			.F_MAX_STALL(F_MAXSTALL),
			.F_MAX_ACK_DELAY(F_MAXDELAY))
		f_wb(i_clk, !i_axi_reset_n,
			o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data,
				o_wb_sel,
			i_wb_ack, i_wb_stall, i_wb_data, i_wb_err,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding);

		assign f_wb_wr_nreqs = f_wb_nreqs;
		assign f_wb_wr_nacks = f_wb_nacks;
		assign f_wb_wr_outstanding = f_wb_outstanding;
		//
		assign f_wb_rd_nreqs = 0;
		assign f_wb_rd_nacks = 0;
		assign f_wb_rd_outstanding = 0;
`endif
	end else begin : ARB_WB
		wbarbiter	#(.DW(DW), .AW(AW),
			.F_LGDEPTH(F_LGDEPTH),
			.F_MAX_STALL(F_MAXSTALL),
			.F_MAX_ACK_DELAY(F_MAXDELAY))
			readorwrite(i_clk, !i_axi_reset_n,
			r_wb_cyc, r_wb_stb, 1'b0, r_wb_addr, w_wb_data, w_wb_sel,
				r_wb_ack, r_wb_stall, r_wb_err,
			w_wb_cyc, w_wb_stb, 1'b1, w_wb_addr, w_wb_data, w_wb_sel,
				w_wb_ack, w_wb_stall, w_wb_err,
			o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data, o_wb_sel,
				i_wb_ack, i_wb_stall, i_wb_err
`ifdef	FORMAL
			,
			f_wb_rd_nreqs, f_wb_rd_nacks, f_wb_rd_outstanding,
			f_wb_wr_nreqs, f_wb_wr_nacks, f_wb_wr_outstanding,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding
`endif
			);
	end endgenerate

	assign	o_reset = (i_axi_reset_n == 1'b0);

`ifdef	FORMAL
	reg	f_past_valid;

	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid = 1'b1;

	initial	assume(!i_axi_reset_n);
	always @(*)
	if (!f_past_valid)
		assume(!i_axi_reset_n);

	wire	[(F_LGDEPTH-1):0]	f_axi_rd_outstanding,
					f_axi_wr_outstanding,
					f_axi_awr_outstanding;
	wire	[(F_LGDEPTH-1):0]	f_axi_rd_id_outstanding,
					f_axi_awr_id_outstanding,
					f_axi_wr_id_outstanding;
	wire	[8:0]			f_axi_wr_pending,
					f_axi_rd_count,
					f_axi_wr_count;

	faxil_slave #(
			// .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
			.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
			.F_LGDEPTH(F_LGDEPTH),
			.F_AXI_MAXWAIT(0),
			.F_AXI_MAXDELAY(0))
		f_axi(.i_clk(i_clk), .i_axi_reset_n(i_axi_reset_n),
			// AXI write address channnel
			.i_axi_awready(o_axi_awready),
			.i_axi_awaddr( i_axi_awaddr),
			.i_axi_awcache(i_axi_awcache),
			.i_axi_awprot( i_axi_awprot),
			.i_axi_awvalid(i_axi_awvalid),
			// AXI write data channel
			.i_axi_wready( o_axi_wready),
			.i_axi_wdata(  i_axi_wdata),
			.i_axi_wstrb(  i_axi_wstrb),
			.i_axi_wvalid( i_axi_wvalid),
			// AXI write acknowledgement channel
			.i_axi_bresp( o_axi_bresp),
			.i_axi_bvalid(o_axi_bvalid),
			.i_axi_bready(i_axi_bready),
			// AXI read address channel
			.i_axi_arready(o_axi_arready),
			.i_axi_araddr( i_axi_araddr),
			.i_axi_arcache(i_axi_arcache),
			.i_axi_arprot( i_axi_arprot),
			.i_axi_arvalid(i_axi_arvalid),
			// AXI read data return
			.i_axi_rresp(  o_axi_rresp),
			.i_axi_rvalid( o_axi_rvalid),
			.i_axi_rdata(  o_axi_rdata),
			.i_axi_rready( i_axi_rready),
			// Quantify where we are within a transaction
			.f_axi_rd_outstanding( f_axi_rd_outstanding),
			.f_axi_wr_outstanding( f_axi_wr_outstanding),
			.f_axi_awr_outstanding(f_axi_awr_outstanding));

	wire	f_axi_ard_req, f_axi_awr_req, f_axi_wr_req,
		f_axi_rd_ack, f_axi_wr_ack;

	assign	f_axi_ard_req = (i_axi_arvalid)&&(o_axi_arready);
	assign	f_axi_awr_req = (i_axi_awvalid)&&(o_axi_awready);
	assign	f_axi_wr_req  = (i_axi_wvalid)&&(o_axi_wready);
	assign	f_axi_wr_ack  = (o_axi_bvalid)&&(i_axi_bready);
	assign	f_axi_rd_ack  = (o_axi_rvalid)&&(i_axi_rready);

	wire	[LGFIFO:0]	f_awr_fifo_axi_used,
				f_dwr_fifo_axi_used,
				f_rd_fifo_axi_used,
				f_wr_fifo_wb_outstanding,
				f_rd_fifo_wb_outstanding;

	assign	f_awr_fifo_axi_used = f_wr_fifo_first - f_wr_fifo_last;
	assign	f_rd_fifo_axi_used  = f_rd_fifo_first - f_rd_fifo_last;
	assign	f_wr_fifo_wb_outstanding = f_wr_fifo_first - f_wr_fifo_last;
	assign	f_rd_fifo_wb_outstanding = f_rd_fifo_first - f_rd_fifo_last;

	always @(*)
	begin
		assert(f_axi_rd_outstanding  == f_rd_fifo_axi_used);
		assert(f_axi_awr_outstanding == f_awr_fifo_axi_used+ (f_pending_awvalid?1:0));
		assert(f_axi_wr_outstanding  == f_awr_fifo_axi_used+ (f_pending_wvalid?1:0));
	end

	always @(*)
	if (OPT_READONLY)
	begin
		assert(f_axi_awr_outstanding == 0);
		assert(f_axi_wr_outstanding  == 0);
	end

	always @(*)
	if (OPT_WRITEONLY)
	begin
		assert(f_axi_ard_outstanding == 0);
	end

	//
	initial assert((!OPT_READONLY)||(!OPT_WRITEONLY));

	always @(*)
	if (OPT_READONLY)
	begin
		assume(i_axi_awvalid == 0);
		assume(i_axi_wvalid == 0);

		assert(o_axi_bvalid == 0);
	end

	always @(*)
	if (OPT_WRITEONLY)
	begin
		assume(i_axi_arvalid == 0);
		assert(o_axi_rvalid == 0);
	end
`endif
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	demoaxi.v
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	Demonstrate an AXI-lite bus design.  The goal of this design
//		is to support a completely pipelined AXI-lite transaction
//	which can transfer one data item per clock.
//
//	Note that the AXI spec requires that there be no combinatorial
//	logic between input ports and output ports.  Hence all of the *valid
//	and *ready signals produced here are registered.  This forces us into
//	the buffered handshake strategy.
//
//	Some curious variable meanings below:
//
//	!axi_arvalid is synonymous with having a request, but stalling because
//		of a current request sitting in axi_rvalid with !axi_rready
//	!axi_awvalid is also synonymous with having an axi address being
//		received, but either the axi_bvalid && !axi_bready, or
//		no write data has been received
//	!axi_wvalid is similar to axi_awvalid.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2018-2019, Gisselquist Technology, LLC
//
// This file is part of the pipelined Wishbone to AXI converter project, a
// project that contains multiple bus bridging designs and formal bus property
// sets.
//
// The bus bridge designs and property sets are free RTL designs: you can
// redistribute them and/or modify any of them under the terms of the GNU
// Lesser General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// The bus bridge designs and property sets are distributed in the hope that
// they will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype none

`timescale 1 ns / 1 ps

module	demoaxi
	#(
		// Users to add parameters here
		parameter [0:0] OPT_READ_SIDEEFFECTS = 1,
		// User parameters ends
		// Do not modify the parameters beyond this line
		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 8
	) (
		// Users to add ports here
		// No user ports (yet) in this design
		// User ports ends

		// Do not modify the ports beyond this line
		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master
		// signaling valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave
		// is ready to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave)
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg		axi_awready;
	reg		axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg		axi_bvalid;
	reg		axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg		axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = 2;
	localparam integer AW = C_S_AXI_ADDR_WIDTH-2;
	localparam integer DW = C_S_AXI_DATA_WIDTH;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	reg [DW-1:0]	slv_mem	[0:63];

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_*wready generation

	//////////////////////////////////////
	//
	// Read processing
	//
	//
	initial	axi_rvalid = 1'b0;
	always @( posedge S_AXI_ACLK )
	if (!S_AXI_ARESETN)
		axi_rvalid <= 0;
	else if (S_AXI_ARVALID)
		axi_rvalid <= 1'b1;
	else if ((S_AXI_RVALID)&&(!S_AXI_RREADY))
		axi_rvalid <= 1'b1;
	else if (!axi_arready)
		axi_rvalid <= 1'b1;
	else
		axi_rvalid <= 1'b0;

	always @(*)
		axi_rresp  = 0;	// "OKAY" response

	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	dly_addr, rd_addr;

	always @(posedge S_AXI_ACLK)
	if (S_AXI_ARREADY)
		dly_addr <= S_AXI_ARADDR;

	always @(*)
	if (!axi_arready)
		rd_addr = dly_addr;
	else
		rd_addr = S_AXI_ARADDR;

	always @(posedge S_AXI_ACLK)
	if (((!S_AXI_RVALID)||(S_AXI_RREADY))
		&&(!OPT_READ_SIDEEFFECTS
			||(!S_AXI_ARREADY || S_AXI_ARVALID)))
		// If the outgoing channel is not stalled (above)
		// then read
		axi_rdata <= slv_mem[rd_addr[AW+ADDR_LSB-1:ADDR_LSB]];

	initial	axi_arready = 1'b0;
	always @(posedge S_AXI_ACLK)
	if (!S_AXI_ARESETN)
		axi_arready <= 1'b1;
	else if ((S_AXI_RVALID)&&(!S_AXI_RREADY))
	begin
		// Outgoing channel is stalled
		if (!axi_arready)
			// If something is already in the buffer,
			// axi_arready needs to stay low
			axi_arready <= 1'b0;
		else
			axi_arready <= (!S_AXI_ARVALID);
	end else
		axi_arready <= 1'b1;

	//////////////////////////////////////
	//
	// Write processing
	//
	//
	reg [C_S_AXI_ADDR_WIDTH-1 : 0]		pre_waddr, waddr;
	reg [C_S_AXI_DATA_WIDTH-1 : 0]		pre_wdata, wdata;
	reg [(C_S_AXI_DATA_WIDTH/8)-1 : 0]	pre_wstrb, wstrb;

	//
	// The write address channel ready signal
	//
	initial	axi_awready = 1'b1;
	always @(posedge S_AXI_ACLK)
	if (!S_AXI_ARESETN)
		axi_awready <= 1'b1;
	else if ((S_AXI_BVALID)&&(!S_AXI_BREADY))
	begin
		// The output channel is stalled
		if (!axi_awready)
			// If our buffer is full, remain stalled
			axi_awready <= 1'b0;
		else
			// If the buffer is empty, accept one transaction
			// to fill it and then stall
			axi_awready <= (!S_AXI_AWVALID);
	end else if ((!axi_wready)||((S_AXI_WVALID)&&(S_AXI_WREADY)))
		// The output channel is clear, and write data
		// are available
		axi_awready <= 1'b1;
	else
		// If we were ready before, then remain ready unless an
		// address unaccompanied by data shows up
		axi_awready <= ((axi_awready)&&(!S_AXI_AWVALID));

	//
	// The write data channel ready signal
	//
	initial	axi_wready = 1'b1;
	always @(posedge S_AXI_ACLK)
	if (!S_AXI_ARESETN)
		axi_wready <= 1'b1;
	else if ((S_AXI_BVALID)&&(!S_AXI_BREADY))
	begin
		// The output channel is stalled
		if (!axi_wready)
			axi_wready <= 1'b0;
		else
			axi_wready <= (!S_AXI_WVALID);
	end else if ((!axi_awready)||((S_AXI_AWVALID)&&(S_AXI_AWREADY)))
		// The output channel is clear, and a write address
		// is available
		axi_wready <= 1'b1;
	else
		// if we were ready before, and there's no new data avaialble
		// to cause us to stall, remain ready
		axi_wready <= (axi_wready)&&(!S_AXI_WVALID);


	// Buffer the address
	always @(posedge S_AXI_ACLK)
	if ((S_AXI_AWREADY)&&(S_AXI_AWVALID))
		pre_waddr <= S_AXI_AWADDR;

	// Buffer the data
	always @(posedge S_AXI_ACLK)
	if ((S_AXI_WREADY)&&(S_AXI_WVALID))
	begin
		pre_wdata <= S_AXI_WDATA;
		pre_wstrb <= S_AXI_WSTRB;
	end

	always @(*)
	if (!axi_awready)
		// Read the write address from our "buffer"
		waddr = pre_waddr;
	else
		waddr = S_AXI_AWADDR;

	always @(*)
	if (!axi_wready)
	begin
		// Read the write data from our "buffer"
		wstrb = pre_wstrb;
		wdata = pre_wdata;
	end else begin
		wstrb = S_AXI_WSTRB;
		wdata = S_AXI_WDATA;
	end


	always @( posedge S_AXI_ACLK )
	// If the output channel isn't stalled, and
	if (((!S_AXI_BVALID)||(S_AXI_BREADY))
		// If we have a valid address, and
		&&((!axi_awready)||(S_AXI_AWVALID))
		// If we have valid data
		&&((!axi_wready)||((S_AXI_WVALID))))
	begin
		if (wstrb[0])
			slv_mem[waddr[AW+ADDR_LSB-1:ADDR_LSB]][7:0]
				<= wdata[7:0];
		if (wstrb[1])
			slv_mem[waddr[AW+ADDR_LSB-1:ADDR_LSB]][15:8]
				<= wdata[15:8];
		if (wstrb[2])
			slv_mem[waddr[AW+ADDR_LSB-1:ADDR_LSB]][23:16]
				<= wdata[23:16];
		if (wstrb[3])
			slv_mem[waddr[AW+ADDR_LSB-1:ADDR_LSB]][31:24]
				<= wdata[31:24];
	end

	initial	axi_bvalid = 1'b0;
	always @( posedge S_AXI_ACLK )
	if (!S_AXI_ARESETN)
		axi_bvalid <= 1'b0;
	//
	// The outgoing response channel should indicate a valid write if ...
		// 1. We have a valid address, and
	else if (((!axi_awready)||(S_AXI_AWVALID))
			// 2. We had valid data
			&&((!axi_wready)||((S_AXI_WVALID))))
		// It doesn't matter here if we are stalled or not
		// We can keep setting ready as often as we want
		axi_bvalid <= 1'b1;
	else if (S_AXI_BREADY)
		axi_bvalid <= 1'b0;

	always @(*)
		axi_bresp = 2'b0;	// "OKAY" response

	// Make Verilator happy
	// Verilator lint_off UNUSED
	wire	[5*ADDR_LSB+5:0]	unused;
	assign	unused = { S_AXI_AWPROT, S_AXI_ARPROT,
				S_AXI_AWADDR[ADDR_LSB-1:0],
				dly_addr[ADDR_LSB-1:0],
				rd_addr[ADDR_LSB-1:0],
				waddr[ADDR_LSB-1:0],
				S_AXI_ARADDR[ADDR_LSB-1:0] };
	// Verilator lint_on UNUSED

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
`ifdef	FORMAL
	localparam	F_LGDEPTH = 4;

	wire	[(F_LGDEPTH-1):0]	f_axi_awr_outstanding,
					f_axi_wr_outstanding,
					f_axi_rd_outstanding;

	faxil_slave #(// .C_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
			.C_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
			// .F_OPT_NO_READS(1'b0),
			// .F_OPT_NO_WRITES(1'b0),
			.F_LGDEPTH(F_LGDEPTH))
		properties (
		.i_clk(S_AXI_ACLK),
		.i_axi_reset_n(S_AXI_ARESETN),
		//
		.i_axi_awaddr(S_AXI_AWADDR),
		.i_axi_awcache(4'h0),
		.i_axi_awprot(S_AXI_AWPROT),
		.i_axi_awvalid(S_AXI_AWVALID),
		.i_axi_awready(S_AXI_AWREADY),
		//
		.i_axi_wdata(S_AXI_WDATA),
		.i_axi_wstrb(S_AXI_WSTRB),
		.i_axi_wvalid(S_AXI_WVALID),
		.i_axi_wready(S_AXI_WREADY),
		//
		.i_axi_bresp(S_AXI_BRESP),
		.i_axi_bvalid(S_AXI_BVALID),
		.i_axi_bready(S_AXI_BREADY),
		//
		.i_axi_araddr(S_AXI_ARADDR),
		.i_axi_arprot(S_AXI_ARPROT),
		.i_axi_arcache(4'h0),
		.i_axi_arvalid(S_AXI_ARVALID),
		.i_axi_arready(S_AXI_ARREADY),
		//
		.i_axi_rdata(S_AXI_RDATA),
		.i_axi_rresp(S_AXI_RRESP),
		.i_axi_rvalid(S_AXI_RVALID),
		.i_axi_rready(S_AXI_RREADY),
		//
		.f_axi_rd_outstanding(f_axi_rd_outstanding),
		.f_axi_wr_outstanding(f_axi_wr_outstanding),
		.f_axi_awr_outstanding(f_axi_awr_outstanding));

	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge S_AXI_ACLK)
		f_past_valid <= 1'b1;

	///////
	//
	// Properties necessary to pass induction
	always @(*)
	if (S_AXI_ARESETN)
	begin
		if (!S_AXI_RVALID)
			assert(f_axi_rd_outstanding == 0);
		else if (!S_AXI_ARREADY)
			assert((f_axi_rd_outstanding == 2)||(f_axi_rd_outstanding == 1));
		else
			assert(f_axi_rd_outstanding == 1);
	end

	always @(*)
	if (S_AXI_ARESETN)
	begin
		if (axi_bvalid)
		begin
			assert(f_axi_awr_outstanding == 1+(axi_awready ? 0:1));
			assert(f_axi_wr_outstanding  == 1+(axi_wready  ? 0:1));
		end else begin
			assert(f_axi_awr_outstanding == (axi_awready ? 0:1));
			assert(f_axi_wr_outstanding  == (axi_wready  ? 0:1));
		end
	end


	////////////////////////////////////////////////////////////////////////
	//
	// Cover properties
	//
	// In addition to making sure the design returns a value, any value,
	// let's cover returning three values on adjacent clocks--just to prove
	// we can.
	//
	////////////////////////////////////////////////////////////////////////
	//
	//
	always @( posedge S_AXI_ACLK )
	if ((f_past_valid)&&(S_AXI_ARESETN))
		cover(($past((S_AXI_BVALID && S_AXI_BREADY)))
			&&($past((S_AXI_BVALID && S_AXI_BREADY),2))
			&&(S_AXI_BVALID && S_AXI_BREADY));

	always @( posedge S_AXI_ACLK )
	if ((f_past_valid)&&(S_AXI_ARESETN))
		cover(($past((S_AXI_RVALID && S_AXI_RREADY)))
			&&($past((S_AXI_RVALID && S_AXI_RREADY),2))
			&&(S_AXI_RVALID && S_AXI_RREADY));

	// Let's go just one further, and verify we can do three returns in a
	// row.  Why?  It might just be possible that one value was waiting
	// already, and so we haven't yet tested that two requests could be
	// made in a row.
	always @( posedge S_AXI_ACLK )
	if ((f_past_valid)&&(S_AXI_ARESETN))
		cover(($past((S_AXI_BVALID && S_AXI_BREADY)))
			&&($past((S_AXI_BVALID && S_AXI_BREADY),2))
			&&($past((S_AXI_BVALID && S_AXI_BREADY),3))
			&&(S_AXI_BVALID && S_AXI_BREADY));

	always @( posedge S_AXI_ACLK )
	if ((f_past_valid)&&(S_AXI_ARESETN))
		cover(($past((S_AXI_RVALID && S_AXI_RREADY)))
			&&($past((S_AXI_RVALID && S_AXI_RREADY),2))
			&&($past((S_AXI_RVALID && S_AXI_RREADY),3))
			&&(S_AXI_RVALID && S_AXI_RREADY));

	//
	// Let's create a sophisticated cover statement designed to show off
	// how our core can handle stalls and non-valids, synchronizing
	// across multiple scenarios
	reg	[22:0]	fw_wrdemo_pipe, fr_wrdemo_pipe;
	always @(*)
	if (!S_AXI_ARESETN)
		fw_wrdemo_pipe = 0;
	else begin
		fw_wrdemo_pipe[0] = (S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[1] = fr_wrdemo_pipe[0]
				&&(!S_AXI_AWVALID)
				&&(!S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[2] = fr_wrdemo_pipe[1]
				&&(!S_AXI_AWVALID)
				&&(!S_AXI_WVALID)
				&&(S_AXI_BREADY);
		//
		//
		fw_wrdemo_pipe[3] = fr_wrdemo_pipe[2]
				&&(S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[4] = fr_wrdemo_pipe[3]
				&&(S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[5] = fr_wrdemo_pipe[4]
				&&(!S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[6] = fr_wrdemo_pipe[5]
				&&(S_AXI_AWVALID)
				&&( S_AXI_WVALID)
				&&( S_AXI_BREADY);
		fw_wrdemo_pipe[7] = fr_wrdemo_pipe[6]
				&&(!S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&( S_AXI_BREADY);
		fw_wrdemo_pipe[8] = fr_wrdemo_pipe[7]
				&&(S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[9] = fr_wrdemo_pipe[8]
//				&&(S_AXI_AWVALID)
//				&&(!S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[10] = fr_wrdemo_pipe[9]
//				&&(S_AXI_AWVALID)
//				&&(S_AXI_WVALID)
				// &&(S_AXI_BREADY);
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[11] = fr_wrdemo_pipe[10]
				&&(S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(!S_AXI_BREADY);
		fw_wrdemo_pipe[12] = fr_wrdemo_pipe[11]
				&&(!S_AXI_AWVALID)
				&&(!S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[13] = fr_wrdemo_pipe[12]
				&&(!S_AXI_AWVALID)
				&&(!S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[14] = fr_wrdemo_pipe[13]
				&&(!S_AXI_AWVALID)
				&&(!S_AXI_WVALID)
				&&(f_axi_awr_outstanding == 0)
				&&(f_axi_wr_outstanding == 0)
				&&(S_AXI_BREADY);
		//
		//
		//
		fw_wrdemo_pipe[15] = fr_wrdemo_pipe[14]
				&&(S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[16] = fr_wrdemo_pipe[15]
				&&(S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[17] = fr_wrdemo_pipe[16]
				&&(S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[18] = fr_wrdemo_pipe[17]
				&&(S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(!S_AXI_BREADY);
		fw_wrdemo_pipe[19] = fr_wrdemo_pipe[18]
				&&(S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[20] = fr_wrdemo_pipe[19]
				&&(S_AXI_AWVALID)
				&&(S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[21] = fr_wrdemo_pipe[20]
				&&(!S_AXI_AWVALID)
				&&(!S_AXI_WVALID)
				&&(S_AXI_BREADY);
		fw_wrdemo_pipe[22] = fr_wrdemo_pipe[21]
				&&(!S_AXI_AWVALID)
				&&(!S_AXI_WVALID)
				&&(S_AXI_BREADY);
	end

	always @(posedge S_AXI_ACLK)
		fr_wrdemo_pipe <= fw_wrdemo_pipe;

	always @(*)
	if (S_AXI_ARESETN)
	begin
		cover(fw_wrdemo_pipe[0]);
		cover(fw_wrdemo_pipe[1]);
		cover(fw_wrdemo_pipe[2]);
		cover(fw_wrdemo_pipe[3]);
		cover(fw_wrdemo_pipe[4]);
		cover(fw_wrdemo_pipe[5]);
		cover(fw_wrdemo_pipe[6]);
		cover(fw_wrdemo_pipe[7]); //
		cover(fw_wrdemo_pipe[8]);
		cover(fw_wrdemo_pipe[9]);
		cover(fw_wrdemo_pipe[10]);
		cover(fw_wrdemo_pipe[11]);
		cover(fw_wrdemo_pipe[12]);
		cover(fw_wrdemo_pipe[13]);
		cover(fw_wrdemo_pipe[14]);
		cover(fw_wrdemo_pipe[15]);
		cover(fw_wrdemo_pipe[16]);
		cover(fw_wrdemo_pipe[17]);
		cover(fw_wrdemo_pipe[18]);
		cover(fw_wrdemo_pipe[19]);
		cover(fw_wrdemo_pipe[20]);
		cover(fw_wrdemo_pipe[21]);
		cover(fw_wrdemo_pipe[22]);
	end

	//
	// Now let's repeat, but for a read demo
	reg	[10:0]	fw_rddemo_pipe, fr_rddemo_pipe;
	always @(*)
	if (!S_AXI_ARESETN)
		fw_rddemo_pipe = 0;
	else begin
		fw_rddemo_pipe[0] = (S_AXI_ARVALID)
				&&(S_AXI_RREADY);
		fw_rddemo_pipe[1] = fr_rddemo_pipe[0]
				&&(!S_AXI_ARVALID)
				&&(S_AXI_RREADY);
		fw_rddemo_pipe[2] = fr_rddemo_pipe[1]
				&&(!S_AXI_ARVALID)
				&&(S_AXI_RREADY);
		//
		//
		fw_rddemo_pipe[3] = fr_rddemo_pipe[2]
				&&(S_AXI_ARVALID)
				&&(S_AXI_RREADY);
		fw_rddemo_pipe[4] = fr_rddemo_pipe[3]
				&&(S_AXI_ARVALID)
				&&(S_AXI_RREADY);
		fw_rddemo_pipe[5] = fr_rddemo_pipe[4]
				&&(S_AXI_ARVALID)
				&&(S_AXI_RREADY);
		fw_rddemo_pipe[6] = fr_rddemo_pipe[5]
				&&(S_AXI_ARVALID)
				&&(!S_AXI_RREADY);
		fw_rddemo_pipe[7] = fr_rddemo_pipe[6]
				&&(S_AXI_ARVALID)
				&&(S_AXI_RREADY);
		fw_rddemo_pipe[8] = fr_rddemo_pipe[7]
				&&(S_AXI_ARVALID)
				&&(S_AXI_RREADY);
		fw_rddemo_pipe[9] = fr_rddemo_pipe[8]
				&&(!S_AXI_ARVALID)
				&&(S_AXI_RREADY);
		fw_rddemo_pipe[10] = fr_rddemo_pipe[9]
				&&(f_axi_rd_outstanding == 0);
	end

	initial	fr_rddemo_pipe = 0;
	always @(posedge S_AXI_ACLK)
		fr_rddemo_pipe <= fw_rddemo_pipe;

	always @(*)
	begin
		cover(fw_rddemo_pipe[0]);
		cover(fw_rddemo_pipe[1]);
		cover(fw_rddemo_pipe[2]);
		cover(fw_rddemo_pipe[3]);
		cover(fw_rddemo_pipe[4]);
		cover(fw_rddemo_pipe[5]);
		cover(fw_rddemo_pipe[6]);
		cover(fw_rddemo_pipe[7]);
		cover(fw_rddemo_pipe[8]);
		cover(fw_rddemo_pipe[9]);
		cover(fw_rddemo_pipe[10]);
	end
`endif
endmodule
////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	migsdram.v
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	This file isn't really a part of the synthesis implementation 
//		of the wb2axip project itself, but rather it is an example
//	of how the wb2axip project can be used to connect a MIG generated
//	IP component.
//
//	This implementation depends upon the existence of a MIG generated
//	core, named "mig_axis", and illustrates how such a core might be
//	connected to the wbm2axip bridge.  Specific options of the mig_axis
//	setup include 6 identifier bits, and a full-sized bus width of 128
//	bits.   These two settings are both appropriate for driving a DDR3
//	memory (whose minimum transfer size is 128 bits), but may need to be
//	adjusted to support other memories.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015-2017, Gisselquist Technology, LLC
//
// This file is part of the pipelined Wishbone to AXI converter project, a
// project that contains multiple bus bridging designs and formal bus property
// sets.
//
// The bus bridge designs and property sets are free RTL designs: you can
// redistribute them and/or modify any of them under the terms of the GNU
// Lesser General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// The bus bridge designs and property sets are distributed in the hope that
// they will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module	migsdram(i_clk, i_clk_200mhz, o_sys_clk, i_rst, o_sys_reset,
	// Wishbone components
		i_wb_cyc, i_wb_stb, i_wb_we, i_wb_addr, i_wb_data, i_wb_sel,
		o_wb_ack, o_wb_stall, o_wb_data, o_wb_err,
	// SDRAM connections
		o_ddr_ck_p, o_ddr_ck_n,
		o_ddr_reset_n, o_ddr_cke,
		o_ddr_cs_n, o_ddr_ras_n, o_ddr_cas_n, o_ddr_we_n,
		o_ddr_ba, o_ddr_addr, 
		o_ddr_odt, o_ddr_dm,
		io_ddr_dqs_p, io_ddr_dqs_n,
		io_ddr_data
	);
	parameter	DDRWIDTH = 16, WBDATAWIDTH=32;
	parameter	AXIDWIDTH = 6;
	// The SDRAM address bits (RAMABITS) are a touch more difficult to work
	// out.  Here we leave them as a fixed parameter, but there are 
	// consequences to this.  Specifically, the wishbone data width, the
	// wishbone address width, and this number have interactions not
	// well captured here.
	parameter	RAMABITS = 28;
	// All DDR3 memories have 8 timeslots.  This, if the DDR3 memory
	// has 16 bits to it (as above), the entire transaction must take
	// AXIWIDTH bits ...
	localparam	AXIWIDTH= DDRWIDTH *8;
	localparam	DW=WBDATAWIDTH;
	localparam	AW=(WBDATAWIDTH==32)? RAMABITS-2
				:((WBDATAWIDTH==64) ? RAMABITS-3
				:((WBDATAWIDTH==128) ? RAMABITS-4
				: RAMABITS-5)); // (WBDATAWIDTH==256)
	localparam	SELW= (WBDATAWIDTH/8);
	//
	input	wire		i_clk, i_clk_200mhz, i_rst;
	output	wire		o_sys_clk;
	output	reg		o_sys_reset;
	//
	input	wire		i_wb_cyc, i_wb_stb, i_wb_we;
	input	wire	[(AW-1):0]	i_wb_addr;
	input	wire	[(DW-1):0]	i_wb_data;
	input	wire	[(SELW-1):0]	i_wb_sel;
	output	wire			o_wb_ack, o_wb_stall;
	output	wire	[(DW-1):0]	o_wb_data;
	output	wire			o_wb_err;
	//
	output	wire	[0:0]		o_ddr_ck_p, o_ddr_ck_n;
	output	wire	[0:0]		o_ddr_cke;
	output	wire			o_ddr_reset_n,
					o_ddr_ras_n, o_ddr_cas_n, o_ddr_we_n;
	output	wire	[0:0]			o_ddr_cs_n;
	output	wire	[2:0]			o_ddr_ba;
	output	wire	[13:0]			o_ddr_addr;
	output	wire	[0:0]			o_ddr_odt;
	output	wire	[(DDRWIDTH/8-1):0]	o_ddr_dm;
	inout	wire	[1:0]			io_ddr_dqs_p, io_ddr_dqs_n;
	inout	wire	[(DDRWIDTH-1):0]	io_ddr_data;


`define	SDRAM_ACCESS
`ifdef	SDRAM_ACCESS

	wire	aresetn;
	assign	aresetn = 1'b1; // Never reset

	// Write address channel
	wire	[(AXIDWIDTH-1):0]	s_axi_awid;
	wire	[(RAMABITS-1):0]	s_axi_awaddr;
	wire	[7:0]			s_axi_awlen;
	wire	[2:0]			s_axi_awsize;
	wire	[1:0]			s_axi_awburst;
	wire	[0:0]			s_axi_awlock;
	wire	[3:0]			s_axi_awcache;
	wire	[2:0]			s_axi_awprot;
	wire	[3:0]			s_axi_awqos;
	wire				s_axi_awvalid;
	wire				s_axi_awready;
	// Writei data channel
	wire	[(AXIWIDTH-1):0]	s_axi_wdata;
	wire	[(AXIWIDTH/8-1):0]	s_axi_wstrb;
	wire				s_axi_wlast, s_axi_wvalid, s_axi_wready;
	// Write response channel
	wire				s_axi_bready;
	wire	[(AXIDWIDTH-1):0]	s_axi_bid;
	wire	[1:0]			s_axi_bresp;
	wire				s_axi_bvalid;

	// Read address channel
	wire	[(AXIDWIDTH-1):0]	s_axi_arid;
	wire	[(RAMABITS-1):0]	s_axi_araddr;
	wire	[7:0]			s_axi_arlen;
	wire	[2:0]			s_axi_arsize;
	wire	[1:0]			s_axi_arburst;
	wire	[0:0]			s_axi_arlock;
	wire	[3:0]			s_axi_arcache;
	wire	[2:0]			s_axi_arprot;
	wire	[3:0]			s_axi_arqos;
	wire				s_axi_arvalid;
	wire				s_axi_arready;
	// Read response/data channel
	wire	[(AXIDWIDTH-1):0]	s_axi_rid;
	wire	[(AXIWIDTH-1):0]	s_axi_rdata;
	wire	[1:0]			s_axi_rresp;
	wire				s_axi_rlast;
	wire				s_axi_rvalid;
	wire				s_axi_rready;

	// Other wires ...
	wire		init_calib_complete, mmcm_locked;
	wire		app_sr_active, app_ref_ack, app_zq_ack;
	wire		app_sr_req, app_ref_req, app_zq_req;
	wire		w_sys_reset;
	wire	[11:0]	w_device_temp;


	mig_axis	mig_sdram(
		.ddr3_ck_p(o_ddr_ck_p),		.ddr3_ck_n(o_ddr_ck_n),
		.ddr3_reset_n(o_ddr_reset_n),	.ddr3_cke(o_ddr_cke),
		.ddr3_cs_n(o_ddr_cs_n),		.ddr3_ras_n(o_ddr_ras_n),
		.ddr3_we_n(o_ddr_we_n),		.ddr3_cas_n(o_ddr_cas_n),
		.ddr3_ba(o_ddr_ba),		.ddr3_addr(o_ddr_addr),
		.ddr3_odt(o_ddr_odt),
		.ddr3_dqs_p(io_ddr_dqs_p),	.ddr3_dqs_n(io_ddr_dqs_n),
		.ddr3_dq(io_ddr_data),		.ddr3_dm(o_ddr_dm),
		//
		.sys_clk_i(i_clk),
		.clk_ref_i(i_clk_200mhz),
		.ui_clk(o_sys_clk),
		.ui_clk_sync_rst(w_sys_reset),
		.mmcm_locked(mmcm_locked),
		.aresetn(aresetn),
		.app_sr_req(1'b0),
		.app_ref_req(1'b0),
		.app_zq_req(1'b0),
		.app_sr_active(app_sr_active),
		.app_ref_ack(app_ref_ack),
		.app_zq_ack(app_zq_ack),
		//
		.s_axi_awid(s_axi_awid),	.s_axi_awaddr(s_axi_awaddr),
		.s_axi_awlen(s_axi_awlen),	.s_axi_awsize(s_axi_awsize),
		.s_axi_awburst(s_axi_awburst),	.s_axi_awlock(s_axi_awlock),
		.s_axi_awcache(s_axi_awcache),	.s_axi_awprot(s_axi_awprot),
		.s_axi_awqos(s_axi_awqos),	.s_axi_awvalid(s_axi_awvalid),
		.s_axi_awready(s_axi_awready),
		//
		.s_axi_wready(	s_axi_wready),
		.s_axi_wdata(	s_axi_wdata),
		.s_axi_wstrb(	s_axi_wstrb),
		.s_axi_wlast(	s_axi_wlast),
		.s_axi_wvalid(	s_axi_wvalid),
		//
		.s_axi_bready(s_axi_bready),	.s_axi_bid(s_axi_bid),
		.s_axi_bresp(s_axi_bresp),	.s_axi_bvalid(s_axi_bvalid),
		//
		.s_axi_arid(s_axi_arid),	.s_axi_araddr(s_axi_araddr),
		.s_axi_arlen(s_axi_arlen),	.s_axi_arsize(s_axi_arsize),
		.s_axi_arburst(s_axi_arburst),	.s_axi_arlock(s_axi_arlock),
		.s_axi_arcache(s_axi_arcache),	.s_axi_arprot(s_axi_arprot),
		.s_axi_arqos(s_axi_arqos),	.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),
		// 
		.s_axi_rready(s_axi_rready),	.s_axi_rid(s_axi_rid),
		.s_axi_rdata(s_axi_rdata),	.s_axi_rresp(s_axi_rresp),
		.s_axi_rlast(s_axi_rlast),	.s_axi_rvalid(s_axi_rvalid),
		.init_calib_complete(init_calib_complete),
		.sys_rst(i_rst),
		.device_temp(w_device_temp)
		);

	wbm2axisp	#( 
			.C_AXI_ID_WIDTH(AXIDWIDTH),
			.C_AXI_DATA_WIDTH(AXIWIDTH),
			.C_AXI_ADDR_WIDTH(RAMABITS),
			.AW(AW), .DW(DW)
			)
			bus_translator(
				.i_clk(o_sys_clk),
				// .i_reset(i_rst), // internally unused
				// Write address channel signals
				.o_axi_awid(	s_axi_awid), 
				.o_axi_awaddr(	s_axi_awaddr), 
				.o_axi_awlen(	s_axi_awlen), 
				.o_axi_awsize(	s_axi_awsize), 
				.o_axi_awburst(	s_axi_awburst), 
				.o_axi_awlock(	s_axi_awlock), 
				.o_axi_awcache(	s_axi_awcache), 
				.o_axi_awprot(	s_axi_awprot),  // s_axi_awqos
				.o_axi_awqos(	s_axi_awqos),  // s_axi_awqos
				.o_axi_awvalid(	s_axi_awvalid), 
				.i_axi_awready(	s_axi_awready), 
			//
				.i_axi_wready(	s_axi_wready),
				.o_axi_wdata(	s_axi_wdata),
				.o_axi_wstrb(	s_axi_wstrb),
				.o_axi_wlast(	s_axi_wlast),
				.o_axi_wvalid(	s_axi_wvalid),
			//
				.o_axi_bready(	s_axi_bready),
				.i_axi_bid(	s_axi_bid),
				.i_axi_bresp(	s_axi_bresp),
				.i_axi_bvalid(	s_axi_bvalid),
			//
				.i_axi_arready(	s_axi_arready),
				.o_axi_arid(	s_axi_arid),
				.o_axi_araddr(	s_axi_araddr),
				.o_axi_arlen(	s_axi_arlen),
				.o_axi_arsize(	s_axi_arsize),
				.o_axi_arburst(	s_axi_arburst),
				.o_axi_arlock(	s_axi_arlock),
				.o_axi_arcache(	s_axi_arcache),
				.o_axi_arprot(	s_axi_arprot),
				.o_axi_arqos(	s_axi_arqos),
				.o_axi_arvalid(	s_axi_arvalid),
			//
				.o_axi_rready(	s_axi_rready),
				.i_axi_rid(	s_axi_rid),
				.i_axi_rdata(	s_axi_rdata),
				.i_axi_rresp(	s_axi_rresp),
				.i_axi_rlast(	s_axi_rlast),
				.i_axi_rvalid(	s_axi_rvalid),
			//
				.i_wb_cyc(	i_wb_cyc),
				.i_wb_stb(	i_wb_stb),
				.i_wb_we(	i_wb_we),
				.i_wb_addr(	i_wb_addr),
				.i_wb_data(	i_wb_data),
				.i_wb_sel(	i_wb_sel),
			//
				.o_wb_ack(	o_wb_ack),
				.o_wb_stall(	o_wb_stall),
				.o_wb_data(	o_wb_data),
				.o_wb_err(	o_wb_err)
		);

	// Convert from active low to active high, *and* hold the system in
	// reset until the memory comes up.	
	initial	o_sys_reset = 1'b1;
	always @(posedge o_sys_clk)
		o_sys_reset <= (!w_sys_reset)
				||(!init_calib_complete)
				||(!mmcm_locked);
`else
	BUFG	sysclk(i_clk, o_sys_clk);
	initial	o_sys_reset <= 1'b1;
	always	@(posedge i_clk)
		o_sys_reset <= 1'b1;

	OBUFDS ckobuf(.I(i_clk), .O(o_ddr_ck_p), .OB(o_ddr_ck_n));

	assign	o_ddr_reset_n	= 1'b0;
	assign	o_ddr_cke[0]	= 1'b0;
	assign	o_ddr_cs_n[0]	= 1'b1;
	assign	o_ddr_cas_n	= 1'b1;
	assign	o_ddr_ras_n	= 1'b1;
	assign	o_ddr_we_n	= 1'b1;
	assign	o_ddr_ba	= 3'h0;
	assign	o_ddr_addr	= 14'h00;
	assign	o_ddr_dm	= 2'b00;
	assign	io_ddr_data	= 16'h0;

	OBUFDS	dqsbufa(.I(i_clk), .O(io_ddr_dqs_p[1]), .OB(io_ddr_dqs_n[1]));
	OBUFDS	dqsbufb(.I(i_clk), .O(io_ddr_dqs_p[0]), .OB(io_ddr_dqs_n[0]));

`endif

endmodule


////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	wbarbiter.v
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	This is a priority bus arbiter.  It allows two separate wishbone
//		masters to connect to the same bus, while also guaranteeing
//	that the last master can have the bus with no delay any time it is
//	idle.  The goal is to minimize the combinatorial logic required in this
//	process, while still minimizing access time.
//
//	The core logic works like this:
//
//		1. If 'A' or 'B' asserts the o_cyc line, a bus cycle will begin,
//			with acccess granted to whomever requested it.
//		2. If both 'A' and 'B' assert o_cyc at the same time, only 'A'
//			will be granted the bus.  (If the alternating parameter 
//			is set, A and B will alternate who gets the bus in
//			this case.)
//		3. The bus will remain owned by whomever the bus was granted to
//			until they deassert the o_cyc line.
//		4. At the end of a bus cycle, o_cyc is guaranteed to be
//			deasserted (low) for one clock.
//		5. On the next clock, bus arbitration takes place again.  If
//			'A' requests the bus, no matter how long 'B' was
//			waiting, 'A' will then be granted the bus.  (Unless
//			again the alternating parameter is set, then the
//			access is guaranteed to switch to B.)
//
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015-2019, Gisselquist Technology, LLC
//
// This file is part of the pipelined Wishbone to AXI converter project, a
// project that contains multiple bus bridging designs and formal bus property
// sets.
//
// The bus bridge designs and property sets are free RTL designs: you can
// redistribute them and/or modify any of them under the terms of the GNU
// Lesser General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// The bus bridge designs and property sets are distributed in the hope that
// they will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
`define	WBA_ALTERNATING
//
module	wbarbiter(i_clk, i_reset,
	// Bus A -- the priority bus
	i_a_cyc, i_a_stb, i_a_we, i_a_adr, i_a_dat, i_a_sel,
		o_a_ack, o_a_stall, o_a_err,
	// Bus B
	i_b_cyc, i_b_stb, i_b_we, i_b_adr, i_b_dat, i_b_sel,
		o_b_ack, o_b_stall, o_b_err,
	// Combined/arbitrated bus
	o_cyc, o_stb, o_we, o_adr, o_dat, o_sel, i_ack, i_stall, i_err
`ifdef	FORMAL
	,
	f_a_nreqs, f_a_nacks, f_a_outstanding,
	f_b_nreqs, f_b_nacks, f_b_outstanding,
	f_nreqs,   f_nacks,   f_outstanding
`endif
	);
	parameter			DW=32, AW=32;
	parameter			SCHEME="ALTERNATING";
	parameter	[0:0]		OPT_ZERO_ON_IDLE = 1'b0;
	parameter			F_MAX_STALL = 3;
	parameter			F_MAX_ACK_DELAY = 3;
	parameter			F_LGDEPTH=3;

	//
	input	wire			i_clk, i_reset;
	// Bus A
	input	wire			i_a_cyc, i_a_stb, i_a_we;
	input	wire	[(AW-1):0]	i_a_adr;
	input	wire	[(DW-1):0]	i_a_dat;
	input	wire	[(DW/8-1):0]	i_a_sel;
	output	wire			o_a_ack, o_a_stall, o_a_err;
	// Bus B
	input	wire			i_b_cyc, i_b_stb, i_b_we;
	input	wire	[(AW-1):0]	i_b_adr;
	input	wire	[(DW-1):0]	i_b_dat;
	input	wire	[(DW/8-1):0]	i_b_sel;
	output	wire			o_b_ack, o_b_stall, o_b_err;
	//
	output	wire			o_cyc, o_stb, o_we;
	output	wire	[(AW-1):0]	o_adr;
	output	wire	[(DW-1):0]	o_dat;
	output	wire	[(DW/8-1):0]	o_sel;
	input	wire			i_ack, i_stall, i_err;
	//
`ifdef	FORMAL
	output	wire	[(F_LGDEPTH-1):0] f_nreqs, f_nacks, f_outstanding,
			f_a_nreqs, f_a_nacks, f_a_outstanding,
			f_b_nreqs, f_b_nacks, f_b_outstanding;
`endif

	// Go high immediately (new cycle) if ...
	//	Previous cycle was low and *someone* is requesting a bus cycle
	// Go low immadiately if ...
	//	We were just high and the owner no longer wants the bus
	// WISHBONE Spec recommends no logic between a FF and the o_cyc
	//	This violates that spec.  (Rec 3.15, p35)
	reg	r_a_owner;

	assign o_cyc = (r_a_owner) ? i_a_cyc : i_b_cyc;
	initial	r_a_owner = 1'b1;

	generate if (SCHEME == "PRIORITY")
	begin : PRI

		always @(posedge i_clk)
			if (!i_b_cyc)
				r_a_owner <= 1'b1;
			// Allow B to set its CYC line w/o activating this
			// interface
			else if ((i_b_stb)&&(!i_a_cyc))
				r_a_owner <= 1'b0;

	end else if (SCHEME == "ALTERNATING")
	begin : ALT

		reg	last_owner;
		initial	last_owner = 1'b0;
		always @(posedge i_clk)
			if ((i_a_cyc)&&(r_a_owner))
				last_owner <= 1'b1;
			else if ((i_b_cyc)&&(!r_a_owner))
				last_owner <= 1'b0;

		always @(posedge i_clk)
			if ((!i_a_cyc)&&(!i_b_cyc))
				r_a_owner <= !last_owner;
			else if ((r_a_owner)&&(!i_a_cyc))
			begin

				if (i_b_stb)
					r_a_owner <= 1'b0;

			end else if ((!r_a_owner)&&(!i_b_cyc))
			begin

				if (i_a_stb)
					r_a_owner <= 1'b1;

			end

	end else // if (SCHEME == "LAST")
	begin : LST
		always @(posedge i_clk)
			if ((!i_a_cyc)&&(i_b_stb))
				r_a_owner <= 1'b0;
			else if ((!i_b_cyc)&&(i_a_stb))
				r_a_owner <= 1'b1;
	end endgenerate


	// Realistically, if neither master owns the bus, the output is a
	// don't care.  Thus we trigger off whether or not 'A' owns the bus.
	// If 'B' owns it all we care is that 'A' does not.  Likewise, if
	// neither owns the bus than the values on the various lines are
	// irrelevant.
	assign o_we  = (r_a_owner) ? i_a_we  : i_b_we;

	generate if (OPT_ZERO_ON_IDLE)
	begin
		//
		// OPT_ZERO_ON_IDLE will use up more logic and may even slow
		// down the master clock if set.  However, it may also reduce
		// the power used by the FPGA by preventing things from toggling
		// when the bus isn't in use.  The option is here because it
		// also makes it a lot easier to look for when things happen
		// on the bus via VERILATOR when timing and logic counts
		// don't matter.
		//
		assign o_stb     = (o_cyc)? ((r_a_owner) ? i_a_stb : i_b_stb):0;
		assign o_adr     = (o_stb)? ((r_a_owner) ? i_a_adr : i_b_adr):0;
		assign o_dat     = (o_stb)? ((r_a_owner) ? i_a_dat : i_b_dat):0;
		assign o_sel     = (o_stb)? ((r_a_owner) ? i_a_sel : i_b_sel):0;
		assign o_a_ack   = (o_cyc)&&( r_a_owner) ? i_ack   : 1'b0;
		assign o_b_ack   = (o_cyc)&&(!r_a_owner) ? i_ack   : 1'b0;
		assign o_a_stall = (o_cyc)&&( r_a_owner) ? i_stall : 1'b1;
		assign o_b_stall = (o_cyc)&&(!r_a_owner) ? i_stall : 1'b1;
		assign o_a_err   = (o_cyc)&&( r_a_owner) ? i_err : 1'b0;
		assign o_b_err   = (o_cyc)&&(!r_a_owner) ? i_err : 1'b0;
	end else begin

		assign o_stb = (r_a_owner) ? i_a_stb : i_b_stb;
		assign o_adr = (r_a_owner) ? i_a_adr : i_b_adr;
		assign o_dat = (r_a_owner) ? i_a_dat : i_b_dat;
		assign o_sel = (r_a_owner) ? i_a_sel : i_b_sel;

		// We cannot allow the return acknowledgement to ever go high if
		// the master in question does not own the bus.  Hence we force
		// it low if the particular master doesn't own the bus.
		assign	o_a_ack   = ( r_a_owner) ? i_ack   : 1'b0;
		assign	o_b_ack   = (!r_a_owner) ? i_ack   : 1'b0;

		// Stall must be asserted on the same cycle the input master
		// asserts the bus, if the bus isn't granted to him.
		assign	o_a_stall = ( r_a_owner) ? i_stall : 1'b1;
		assign	o_b_stall = (!r_a_owner) ? i_stall : 1'b1;

		//
		//
		assign	o_a_err = ( r_a_owner) ? i_err : 1'b0;
		assign	o_b_err = (!r_a_owner) ? i_err : 1'b0;
	end endgenerate

	// Make Verilator happy
	// verilator lint_off UNUSED
	wire	unused;
	assign	unused = i_reset;
	// verilator lint_on  UNUSED

`ifdef	FORMAL

`ifdef	WBARBITER

`define	ASSUME	assume
`else
`define	ASSUME	assert
`endif

	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	initial	`ASSUME(!i_a_cyc);
	initial	`ASSUME(!i_a_stb);

	initial	`ASSUME(!i_b_cyc);
	initial	`ASSUME(!i_b_stb);

	initial	`ASSUME(!i_ack);
	initial	`ASSUME(!i_err);

	always @(*)
	if (!f_past_valid)
		`ASSUME(i_reset);

	always @(posedge i_clk)
	begin
		if (o_cyc)
			assert((i_a_cyc)||(i_b_cyc));
		if ((f_past_valid)&&($past(o_cyc))&&(o_cyc))
			assert($past(r_a_owner) == r_a_owner);
	end

	fwb_master #(.DW(DW), .AW(AW),
			.F_MAX_STALL(F_MAX_STALL),
			.F_LGDEPTH(F_LGDEPTH),
			.F_MAX_ACK_DELAY(F_MAX_ACK_DELAY),
			.F_OPT_RMW_BUS_OPTION(1),
			.F_OPT_DISCONTINUOUS(1))
		f_wbm(i_clk, i_reset,
			o_cyc, o_stb, o_we, o_adr, o_dat, o_sel,
			i_ack, i_stall, 32'h0, i_err,
			f_nreqs, f_nacks, f_outstanding);

	fwb_slave  #(.DW(DW), .AW(AW),
			.F_MAX_STALL(0),
			.F_LGDEPTH(F_LGDEPTH),
			.F_MAX_ACK_DELAY(0),
			.F_OPT_RMW_BUS_OPTION(1),
			.F_OPT_DISCONTINUOUS(1))
		f_wba(i_clk, i_reset,
			i_a_cyc, i_a_stb, i_a_we, i_a_adr, i_a_dat, i_a_sel, 
			o_a_ack, o_a_stall, 32'h0, o_a_err,
			f_a_nreqs, f_a_nacks, f_a_outstanding);

	fwb_slave  #(.DW(DW), .AW(AW),
			.F_MAX_STALL(0),
			.F_LGDEPTH(F_LGDEPTH),
			.F_MAX_ACK_DELAY(0),
			.F_OPT_RMW_BUS_OPTION(1),
			.F_OPT_DISCONTINUOUS(1))
		f_wbb(i_clk, i_reset,
			i_b_cyc, i_b_stb, i_b_we, i_b_adr, i_b_dat, i_b_sel,
			o_b_ack, o_b_stall, 32'h0, o_b_err,
			f_b_nreqs, f_b_nacks, f_b_outstanding);

	always @(posedge i_clk)
		if (r_a_owner)
		begin
			assert(f_b_nreqs == 0);
			assert(f_b_nacks == 0);
			assert(f_a_outstanding == f_outstanding);
		end else begin
			assert(f_a_nreqs == 0);
			assert(f_a_nacks == 0);
			assert(f_b_outstanding == f_outstanding);
		end

	always @(posedge i_clk)
	if ((f_past_valid)&&(!$past(i_reset))
			&&($past(i_a_stb))&&(!$past(i_b_cyc)))
		assert(r_a_owner);
	always @(posedge i_clk)
	if ((f_past_valid)&&(!$past(i_reset))
			&&(!$past(i_a_cyc))&&($past(i_b_stb)))
		assert(!r_a_owner);

	always @(posedge i_clk)
		if ((f_past_valid)&&(r_a_owner != $past(r_a_owner)))
			assert(!$past(o_cyc));

	reg	f_prior_a_ack, f_prior_b_ack;

	initial	f_prior_a_ack = 1'b0;
	always @(posedge i_clk)
	if ((i_reset)||(o_a_err)||(o_b_err))
		f_prior_a_ack = 1'b0;
	else if ((o_cyc)&&(o_a_ack))
		f_prior_a_ack <= 1'b1;

	initial	f_prior_b_ack = 1'b0;
	always @(posedge i_clk)
	if ((i_reset)||(o_a_err)||(o_b_err))
		f_prior_b_ack = 1'b0;
	else if ((o_cyc)&&(o_b_ack))
		f_prior_b_ack <= 1'b1;

	always @(posedge i_clk)
	begin
		cover(f_prior_b_ack && o_cyc && o_a_ack);

		cover((o_cyc && o_a_ack)
			&&($past(o_cyc && o_a_ack))
			&&($past(o_cyc && o_a_ack,2)));


		cover(f_prior_a_ack && o_cyc && o_b_ack);

		cover((o_cyc && o_b_ack)
			&&($past(o_cyc && o_b_ack))
			&&($past(o_cyc && o_b_ack,2)));
	end

	always @(*)
		cover(o_cyc && o_b_ack);
`endif
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	wbm2axilite.v (Wishbone master to AXI slave, pipelined)
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	Convert from a wishbone master to an AXI lite interface.  The
//		big difference is that AXI lite doesn't support bursting,
//	or transaction ID's.  This actually makes the task a *LOT* easier.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2018-2019, Gisselquist Technology, LLC
//
// This file is part of the pipelined Wishbone to AXI converter project, a
// project that contains multiple bus bridging designs and formal bus property
// sets.
//
// The bus bridge designs and property sets are free RTL designs: you can
// redistribute them and/or modify any of them under the terms of the GNU
// Lesser General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// The bus bridge designs and property sets are distributed in the hope that
// they will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module wbm2axilite (
	i_clk, i_reset,
	// AXI write address channel signals
	i_axi_awready, o_axi_awaddr, o_axi_awcache, o_axi_awprot, o_axi_awvalid,
	// AXI write data channel signals
	i_axi_wready, o_axi_wdata, o_axi_wstrb, o_axi_wvalid,
	// AXI write response channel signals
	i_axi_bresp, i_axi_bvalid, o_axi_bready,
	// AXI read address channel signals
	i_axi_arready, o_axi_araddr, o_axi_arcache, o_axi_arprot, o_axi_arvalid,
	// AXI read data channel signals   
	i_axi_rresp, i_axi_rvalid, i_axi_rdata, o_axi_rready,
	// We'll share the clock and the reset
	i_wb_cyc, i_wb_stb, i_wb_we, i_wb_addr, i_wb_data, i_wb_sel,
		o_wb_ack, o_wb_stall, o_wb_data, o_wb_err);

	localparam C_AXI_DATA_WIDTH	=  32;// Width of the AXI R&W data
	parameter C_AXI_ADDR_WIDTH	=  28;// AXI Address width
	localparam DW			=  C_AXI_DATA_WIDTH;// Wishbone data width
	parameter AW			=  C_AXI_ADDR_WIDTH-2;// WB addr width (log wordsize)
	input	wire			i_clk;	// System clock
	input	wire			i_reset;// Reset signal,drives AXI rst

// AXI write address channel signals
	input	wire			i_axi_awready;//Slave is ready to accept
	output	reg	[C_AXI_ADDR_WIDTH-1:0]	o_axi_awaddr;	// Write address
	output	wire	[3:0]		o_axi_awcache;	// Write Cache type
	output	wire	[2:0]		o_axi_awprot;	// Write Protection type
	output	reg			o_axi_awvalid;	// Write address valid

// AXI write data channel signals
	input	wire			i_axi_wready;  // Write data ready
	output	reg	[C_AXI_DATA_WIDTH-1:0]	o_axi_wdata;	// Write data
	output	reg	[C_AXI_DATA_WIDTH/8-1:0] o_axi_wstrb;	// Write strobes
	output	reg			o_axi_wvalid;	// Write valid

// AXI write response channel signals
	input	wire [1:0]		i_axi_bresp;	// Write response
	input	wire			i_axi_bvalid;  // Write reponse valid
	output	wire			o_axi_bready;  // Response ready

// AXI read address channel signals
	input	wire			i_axi_arready;	// Read address ready
	output	reg	[C_AXI_ADDR_WIDTH-1:0]	o_axi_araddr;	// Read address
	output	wire	[3:0]		o_axi_arcache;	// Read Cache type
	output	wire	[2:0]		o_axi_arprot;	// Read Protection type
	output	reg			o_axi_arvalid;	// Read address valid

// AXI read data channel signals   
	input	wire	[1:0]		i_axi_rresp;   // Read response
	input	wire			i_axi_rvalid;  // Read reponse valid
	input wire [C_AXI_DATA_WIDTH-1:0] i_axi_rdata;    // Read data
	output	wire			o_axi_rready;  // Read Response ready

	// We'll share the clock and the reset
	input	wire			i_wb_cyc;
	input	wire			i_wb_stb;
	input	wire			i_wb_we;
	input	wire	[(AW-1):0]	i_wb_addr;
	input	wire	[(DW-1):0]	i_wb_data;
	input	wire	[(DW/8-1):0]	i_wb_sel;
	output	reg			o_wb_ack;
	output	wire			o_wb_stall;
	output	reg	[(DW-1):0]	o_wb_data;
	output	reg			o_wb_err;

//*****************************************************************************
// Local Parameter declarations
//*****************************************************************************

	localparam	LG_AXI_DW	= ( C_AXI_DATA_WIDTH ==   8) ? 3
					: ((C_AXI_DATA_WIDTH ==  16) ? 4
					: ((C_AXI_DATA_WIDTH ==  32) ? 5
					: ((C_AXI_DATA_WIDTH ==  64) ? 6
					: ((C_AXI_DATA_WIDTH == 128) ? 7
					: 8))));

	localparam	LG_WB_DW	= ( DW ==   8) ? 3
					: ((DW ==  16) ? 4
					: ((DW ==  32) ? 5
					: ((DW ==  64) ? 6
					: ((DW == 128) ? 7
					: 8))));
	localparam	LGFIFOLN = 5;
	localparam	FIFOLN = (1<<LGFIFOLN);


//*****************************************************************************
// Internal register and wire declarations
//*****************************************************************************

// Things we're not changing ...
	assign o_axi_awcache = 4'h3;	// Normal: no cache, no buffer
	assign o_axi_arcache = 4'h3;	// Normal: no cache, no buffer
	assign o_axi_awprot  = 3'b000;	// Unpriviledged, unsecure, data access
	assign o_axi_arprot  = 3'b000;	// Unpriviledged, unsecure, data access

	reg	full_fifo, err_state, axi_reset_state, wb_we;
	reg	[3:0]	reset_count;
	reg			pending;
	reg	[LGFIFOLN-1:0]	outstanding, err_pending;


// Master bridge logic
	assign	o_wb_stall = (full_fifo)
			||((!i_wb_we)&&( wb_we)&&(pending))
			||(( i_wb_we)&&(!wb_we)&&(pending))
			||(err_state)||(axi_reset_state)
			||(o_axi_arvalid)&&(!i_axi_arready)
			||(o_axi_awvalid)&&(!i_axi_awready)
			||(o_axi_wvalid)&&(!i_axi_wready);

	initial	axi_reset_state = 1'b1;
	initial	reset_count = 4'hf;
	always @(posedge i_clk)
	if (i_reset)
	begin
		axi_reset_state <= 1'b1;
		if (reset_count > 0)
			reset_count <= reset_count - 1'b1;
	end else if ((axi_reset_state)&&(reset_count > 0))
		reset_count <= reset_count - 1'b1;
	else begin
		axi_reset_state <= 1'b0;
		reset_count <= 4'hf;
	end

	// Count outstanding transactions
	initial	pending = 0;
	initial	outstanding = 0;
	always @(posedge i_clk)
	if ((i_reset)||(axi_reset_state))
	begin
		pending <= 0;
		outstanding <= 0;
		full_fifo <= 0;
	end else if ((err_state)||(!i_wb_cyc))
	begin
		pending <= 0;
		outstanding <= 0;
		full_fifo <= 0;
	end else case({ ((i_wb_stb)&&(!o_wb_stall)), (o_wb_ack) })
	2'b01: begin
		outstanding <= outstanding - 1'b1;
		pending <= (outstanding >= 2);
		full_fifo <= 1'b0;
		end
	2'b10: begin
		outstanding <= outstanding + 1'b1;
		pending <= 1'b1;
		full_fifo <= (outstanding >= {{(LGFIFOLN-2){1'b1}},2'b01});;
		end
	default: begin end
	endcase

	always @(posedge i_clk)
	if ((i_wb_stb)&&(!o_wb_stall))
		wb_we <= i_wb_we;

	//
	//
	// Write address logic
	//
	initial	o_axi_awvalid = 0;
	always @(posedge i_clk)
	if (i_reset)
		o_axi_awvalid <= 0;
	else
		o_axi_awvalid <= (!o_wb_stall)&&(i_wb_stb)&&(i_wb_we)
			||(o_axi_awvalid)&&(!i_axi_awready);

	always @(posedge i_clk)
	if (!o_wb_stall)
		o_axi_awaddr <= { i_wb_addr, 2'b00 };

	//
	//
	// Read address logic
	//
	initial	o_axi_arvalid = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		o_axi_arvalid <= 1'b0;
	else
		o_axi_arvalid <= (!o_wb_stall)&&(i_wb_stb)&&(!i_wb_we)
			||((o_axi_arvalid)&&(!i_axi_arready));
	always @(posedge i_clk)
	if (!o_wb_stall)
		o_axi_araddr <= { i_wb_addr, 2'b00 };

	//
	//
	// Write data logic
	//
	always @(posedge i_clk)
	if (!o_wb_stall)
	begin
		o_axi_wdata <= i_wb_data;
		o_axi_wstrb <= i_wb_sel;
	end

	initial	o_axi_wvalid = 0;
	always @(posedge i_clk)
	if (i_reset)
		o_axi_wvalid <= 0;
	else
		o_axi_wvalid <= ((!o_wb_stall)&&(i_wb_stb)&&(i_wb_we))
			||((o_axi_wvalid)&&(!i_axi_wready));

	initial	o_wb_ack = 1'b0;
	always @(posedge i_clk)
	if ((i_reset)||(!i_wb_cyc)||(err_state))
		o_wb_ack <= 1'b0;
	else if (err_state)
		o_wb_ack <= 1'b0;
	else if ((i_axi_bvalid)&&(!i_axi_bresp[1]))
		o_wb_ack <= 1'b1;
	else if ((i_axi_rvalid)&&(!i_axi_rresp[1]))
		o_wb_ack <= 1'b1;
	else
		o_wb_ack <= 1'b0;

	always @(posedge i_clk)
		o_wb_data <= i_axi_rdata;

	// Read data channel / response logic
	assign	o_axi_rready = 1'b1;
	assign	o_axi_bready = 1'b1;

	initial	o_wb_err = 1'b0;
	always @(posedge i_clk)
	if ((i_reset)||(!i_wb_cyc)||(err_state))
		o_wb_err <= 1'b0;
	else if ((i_axi_bvalid)&&(i_axi_bresp[1]))
		o_wb_err <= 1'b1;
	else if ((i_axi_rvalid)&&(i_axi_rresp[1]))
		o_wb_err <= 1'b1;
	else
		o_wb_err <= 1'b0;

	initial	err_state = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		err_state <= 0;
	else if ((i_axi_bvalid)&&(i_axi_bresp[1]))
		err_state <= 1'b1;
	else if ((i_axi_rvalid)&&(i_axi_rresp[1]))
		err_state <= 1'b1;
	else if ((pending)&&(!i_wb_cyc))
		err_state <= 1'b1;
	else if (err_pending == 0)
		err_state <= 0;

	initial	err_pending = 0;
	always @(posedge i_clk)
	if (i_reset)
		err_pending <= 0;
	else case({ ((i_wb_stb)&&(!o_wb_stall)),
					((i_axi_bvalid)||(i_axi_rvalid)) })
	2'b01: err_pending <= err_pending - 1'b1;
	2'b10: err_pending <= err_pending + 1'b1;
	default: begin end
	endcase

	// Make verilator happy
	// verilator lint_off UNUSED
	wire	[2:0]	unused;
	assign	unused = { i_wb_cyc, i_axi_bresp[0], i_axi_rresp[0] };
	// verilator lint_on  UNUSED

/////////////////////////////////////////////////////////////////////////
//
//
//
// Formal methods section
//
// These are only relevant when *proving* that this translator works
//
//
//
/////////////////////////////////////////////////////////////////////////
`ifdef	FORMAL
	reg	f_past_valid;
//
`define	ASSUME	assume
`define	ASSERT	assert

	// Parameters
	initial	assert(DW == 32);
	initial	assert(C_AXI_ADDR_WIDTH == AW+2);
	//

	//
	// Setup
	//
	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	always @(*)
	if (!f_past_valid)
		`ASSUME(i_reset);

	//////////////////////////////////////////////
	//
	//
	// Assumptions about the WISHBONE inputs
	//
	//
	//////////////////////////////////////////////
	assume property(f_past_valid || i_reset);

	wire	[(LGFIFOLN-1):0]	f_wb_nreqs, f_wb_nacks,f_wb_outstanding;
	fwb_slave #(.DW(DW),.AW(AW),
			.F_MAX_STALL(0),
			.F_MAX_ACK_DELAY(0),
			.F_LGDEPTH(LGFIFOLN),
			.F_MAX_REQUESTS(FIFOLN-2))
		f_wb(i_clk, i_reset, i_wb_cyc, i_wb_stb, i_wb_we, i_wb_addr,
					i_wb_data, i_wb_sel,
				o_wb_ack, o_wb_stall, o_wb_data, o_wb_err,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding);

	wire	[(LGFIFOLN-1):0]	f_axi_rd_outstanding,
					f_axi_wr_outstanding,
					f_axi_awr_outstanding;

	faxil_master #(
		// .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.F_LGDEPTH(LGFIFOLN),
		.F_AXI_MAXWAIT(3),
		.F_OPT_HAS_CACHE(1'b1),
		.F_AXI_MAXDELAY(3))
		f_axil(.i_clk(i_clk),
			.i_axi_reset_n((!i_reset)&&(!axi_reset_state)),
			// Write address channel
			.i_axi_awready(i_axi_awready), 
			.i_axi_awaddr( o_axi_awaddr), 
			.i_axi_awcache(o_axi_awcache), 
			.i_axi_awprot( o_axi_awprot), 
			.i_axi_awvalid(o_axi_awvalid), 
			// Write data channel
			.i_axi_wready( i_axi_wready),
			.i_axi_wdata(  o_axi_wdata),
			.i_axi_wstrb(  o_axi_wstrb),
			.i_axi_wvalid( o_axi_wvalid),
			// Write response channel
			.i_axi_bresp(  i_axi_bresp),
			.i_axi_bvalid( i_axi_bvalid),
			.i_axi_bready( o_axi_bready),
			// Read address channel
			.i_axi_arready(i_axi_arready),
			.i_axi_araddr( o_axi_araddr),
			.i_axi_arcache(o_axi_arcache),
			.i_axi_arprot( o_axi_arprot),
			.i_axi_arvalid(o_axi_arvalid),
			// Read data channel
			.i_axi_rresp(  i_axi_rresp),
			.i_axi_rvalid( i_axi_rvalid),
			.i_axi_rdata(  i_axi_rdata),
			.i_axi_rready( o_axi_rready),
			// Counts
			.f_axi_rd_outstanding( f_axi_rd_outstanding),
			.f_axi_wr_outstanding( f_axi_wr_outstanding),
			.f_axi_awr_outstanding( f_axi_awr_outstanding)
		);

	//////////////////////////////////////////////
	//
	//
	// Assumptions about the AXI inputs
	//
	//
	//////////////////////////////////////////////


	//////////////////////////////////////////////
	//
	//
	// Assertions about the AXI4 ouputs
	//
	//
	//////////////////////////////////////////////

	// Write response channel
	always @(posedge i_clk)
		// We keep bready high, so the other condition doesn't
		// need to be checked
		assert(o_axi_bready);

	// AXI read data channel signals
	always @(posedge i_clk)
		// We keep o_axi_rready high, so the other condition's
		// don't need to be checked here
		assert(o_axi_rready);

	//
	// Let's look into write requests
	//
	initial	assert(!o_axi_awvalid);
	initial	assert(!o_axi_wvalid);
	always @(posedge i_clk)
	if ((!f_past_valid)||($past(i_reset))||($past(axi_reset_state)))
	begin
		assert(!o_axi_awvalid);
		assert(!o_axi_wvalid);
	end

	always @(posedge i_clk)
	if ((f_past_valid)&&(!$past(i_reset))
		&&($past((i_wb_stb)&&(i_wb_we)&&(!o_wb_stall))))
	begin
		// Following any write request that we accept, awvalid
		// and wvalid should both be true
		assert(o_axi_awvalid);
		assert(o_axi_wvalid);
		assert(wb_we);
	end else if ((f_past_valid)&&($past(i_reset)))
	begin
		if ($past(i_axi_awready))
			assert(!o_axi_awvalid);
		if ($past(i_axi_wready))
			assert(!o_axi_wvalid);
	end

	//
	// AXI write address channel
	//
	always @(posedge i_clk)
	if ((f_past_valid)&&($past((i_wb_stb)&&(i_wb_we)&&(!o_wb_stall))))
		assert(o_axi_awaddr == { $past(i_wb_addr[AW-1:0]), 2'b00 });

	//
	// AXI write data channel
	//
	always @(posedge i_clk)
	if ((f_past_valid)&&($past(i_wb_stb)&&(i_wb_we)&&(!$past(o_wb_stall))))
	begin
		assert(o_axi_wdata == $past(i_wb_data));
		assert(o_axi_wstrb == $past(i_wb_sel));
	end

	//
	// AXI read address channel
	//
	initial	assert(!o_axi_arvalid);
	always @(posedge i_clk)
	if ((f_past_valid)&&(!$past(i_reset))
		&&($past((i_wb_stb)&&(!i_wb_we)&&(!o_wb_stall))))
	begin
		assert(o_axi_arvalid);
		assert(o_axi_araddr == { $past(i_wb_addr), 2'b00 });
	end
	//

	//
	// AXI write response channel
	//

	//
	// AXI read data channel signals
	//
	always @(posedge i_clk)
	if ((f_past_valid)&&(($past(i_reset))||($past(axi_reset_state))))
	begin
		// Relate err_pending to outstanding
		assert(outstanding == 0);
		assert(err_pending == 0);
	end else if (!err_state)
		assert(err_pending == outstanding - ((o_wb_ack)||(o_wb_err)));

	always @(posedge i_clk)
	if ((f_past_valid)&&(($past(i_reset))||($past(axi_reset_state))))
	begin
		assert(f_axi_awr_outstanding == 0);
		assert(f_axi_wr_outstanding == 0);
		assert(f_axi_rd_outstanding == 0);

		assert(f_wb_outstanding == 0);
		assert(!pending);
		assert(outstanding == 0);
		assert(err_pending == 0);
	end else if (wb_we)
	begin
		case({o_axi_awvalid,o_axi_wvalid})
		2'b00: begin
			`ASSERT(f_axi_awr_outstanding   == err_pending);
			`ASSERT(f_axi_wr_outstanding    == err_pending);
			end
		2'b01: begin
			`ASSERT(f_axi_awr_outstanding   == err_pending);
			`ASSERT(f_axi_wr_outstanding +1 == err_pending);
			end
		2'b10: begin
			`ASSERT(f_axi_awr_outstanding+1 == err_pending);
			`ASSERT(f_axi_wr_outstanding    == err_pending);
			end
		2'b11: begin
			`ASSERT(f_axi_awr_outstanding+1 == err_pending);
			`ASSERT(f_axi_wr_outstanding +1 == err_pending);
			end
		endcase

		//
		`ASSERT(!o_axi_arvalid);
		`ASSERT(f_axi_rd_outstanding == 0);
	end else begin
		if (!o_axi_arvalid)
			`ASSERT(f_axi_rd_outstanding == err_pending);
		else
			`ASSERT(f_axi_rd_outstanding+1 == err_pending);

		`ASSERT(!o_axi_awvalid);
		`ASSERT(!o_axi_wvalid);
		`ASSERT(f_axi_awr_outstanding == 0);
		`ASSERT(f_axi_wr_outstanding == 0);
	end

	always @(*)
	if ((!i_reset)&&(i_wb_cyc)&&(!err_state))
		`ASSERT(f_wb_outstanding == outstanding);

	always @(posedge i_clk)
	if ((f_past_valid)&&(err_state))
		`ASSERT((o_wb_err)||(f_wb_outstanding == 0));

	always @(posedge i_clk)
		`ASSERT(pending == (outstanding != 0));
	//
	// Make sure we only create one request at a time
	always @(posedge i_clk)
		`ASSERT((!o_axi_arvalid)||(!o_axi_wvalid));
	always @(posedge i_clk)
		`ASSERT((!o_axi_arvalid)||(!o_axi_awvalid));
	always @(posedge i_clk)
	if (wb_we)
		`ASSERT(!o_axi_arvalid);
	else
		`ASSERT((!o_axi_awvalid)&&(!o_axi_wvalid));

	always @(*)
	if (&outstanding[LGFIFOLN-1:1])
		`ASSERT(full_fifo);
	always @(*)
		assert(outstanding < {(LGFIFOLN){1'b1}});

	// AXI cover results
	always @(*)
		cover(i_axi_bvalid && o_axi_bready);
	always @(*)
		cover(i_axi_rvalid && o_axi_rready);

	always @(posedge i_clk)
		cover(i_axi_bvalid && o_axi_bready
			&& $past(i_axi_bvalid && o_axi_bready)
			&& $past(i_axi_bvalid && o_axi_bready,2));

	always @(posedge i_clk)
		cover(i_axi_rvalid && o_axi_rready
			&& $past(i_axi_rvalid && o_axi_rready)
			&& $past(i_axi_rvalid && o_axi_rready,2));

	// AXI cover requests
	always @(posedge i_clk)
		cover(o_axi_arvalid && i_axi_arready
			&& $past(o_axi_arvalid && i_axi_arready)
			&& $past(o_axi_arvalid && i_axi_arready,2));

	always @(posedge i_clk)
		cover(o_axi_awvalid && i_axi_awready
			&& $past(o_axi_awvalid && i_axi_awready)
			&& $past(o_axi_awvalid && i_axi_awready,2));

	always @(posedge i_clk)
		cover(o_axi_wvalid && i_axi_wready
			&& $past(o_axi_wvalid && i_axi_wready)
			&& $past(o_axi_wvalid && i_axi_wready,2));

	always @(*)
		cover(i_axi_rvalid && o_axi_rready);

	// Wishbone cover results
	always @(*)
		cover(i_wb_cyc && o_wb_ack);

	always @(posedge i_clk)
		cover(i_wb_cyc && o_wb_ack
			&& $past(o_wb_ack)&&$past(o_wb_ack,2));

`endif
endmodule
////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	wbm2axisp.v (Wishbone master to AXI slave, pipelined)
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	The B4 Wishbone SPEC allows transactions at a speed as fast as
//		one per clock.  The AXI bus allows transactions at a speed of
//	one read and one write transaction per clock.  These capabilities work
//	by allowing requests to take place prior to responses, such that the
//	requests might go out at once per clock and take several clocks, and
//	the responses may start coming back several clocks later.  In other
//	words, both protocols allow multiple transactions to be "in flight" at
//	the same time.  Current wishbone to AXI converters, however, handle only
//	one transaction at a time: initiating the transaction, and then waiting
//	for the transaction to complete before initiating the next.
//
//	The purpose of this core is to maintain the speed of both busses, while
//	transiting from the Wishbone (as master) to the AXI bus (as slave) and
//	back again.
//
//	Since the AXI bus allows transactions to be reordered, whereas the
//	wishbone does not, this core can be configured to reorder return
//	transactions as well.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2016-2019, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory, run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module wbm2axisp #(
	parameter C_AXI_ID_WIDTH	=   3, // The AXI id width used for R&W
                                             // This is an int between 1-16
	parameter C_AXI_DATA_WIDTH	= 128,// Width of the AXI R&W data
	parameter C_AXI_ADDR_WIDTH	=  28,	// AXI Address width (log wordsize)
	parameter DW			=  32,	// Wishbone data width
	parameter AW			=  26,	// Wishbone address width (log wordsize)
	parameter [0:0] STRICT_ORDER	= 1 	// Reorder, or not? 0 -> Reorder
	) (
	input	wire			i_clk,	// System clock
	input	wire			i_reset,// Reset signal,drives AXI rst

// AXI write address channel signals
	input	wire			i_axi_awready, // Slave is ready to accept
	output	reg	[C_AXI_ID_WIDTH-1:0]	o_axi_awid,	// Write ID
	output	reg	[C_AXI_ADDR_WIDTH-1:0]	o_axi_awaddr,	// Write address
	output	wire	[7:0]		o_axi_awlen,	// Write Burst Length
	output	wire	[2:0]		o_axi_awsize,	// Write Burst size
	output	wire	[1:0]		o_axi_awburst,	// Write Burst type
	output	wire	[0:0]		o_axi_awlock,	// Write lock type
	output	wire	[3:0]		o_axi_awcache,	// Write Cache type
	output	wire	[2:0]		o_axi_awprot,	// Write Protection type
	output	wire	[3:0]		o_axi_awqos,	// Write Quality of Svc
	output	reg			o_axi_awvalid,	// Write address valid

// AXI write data channel signals
	input	wire			i_axi_wready,  // Write data ready
	output	reg	[C_AXI_DATA_WIDTH-1:0]	o_axi_wdata,	// Write data
	output	reg	[C_AXI_DATA_WIDTH/8-1:0] o_axi_wstrb,	// Write strobes
	output	wire			o_axi_wlast,	// Last write transaction   
	output	reg			o_axi_wvalid,	// Write valid

// AXI write response channel signals
	input wire [C_AXI_ID_WIDTH-1:0]	i_axi_bid,	// Response ID
	input	wire [1:0]		i_axi_bresp,	// Write response
	input	wire			i_axi_bvalid,  // Write reponse valid
	output	wire			o_axi_bready,  // Response ready

// AXI read address channel signals
	input	wire			i_axi_arready,	// Read address ready
	output	wire	[C_AXI_ID_WIDTH-1:0]	o_axi_arid,	// Read ID
	output	wire	[C_AXI_ADDR_WIDTH-1:0]	o_axi_araddr,	// Read address
	output	wire	[7:0]		o_axi_arlen,	// Read Burst Length
	output	wire	[2:0]		o_axi_arsize,	// Read Burst size
	output	wire	[1:0]		o_axi_arburst,	// Read Burst type
	output	wire	[0:0]		o_axi_arlock,	// Read lock type
	output	wire	[3:0]		o_axi_arcache,	// Read Cache type
	output	wire	[2:0]		o_axi_arprot,	// Read Protection type
	output	wire	[3:0]		o_axi_arqos,	// Read Protection type
	output	reg			o_axi_arvalid,	// Read address valid

// AXI read data channel signals   
	input wire [C_AXI_ID_WIDTH-1:0]	i_axi_rid,     // Response ID
	input	wire	[1:0]		i_axi_rresp,   // Read response
	input	wire			i_axi_rvalid,  // Read reponse valid
	input wire [C_AXI_DATA_WIDTH-1:0] i_axi_rdata,    // Read data
	input	wire			i_axi_rlast,    // Read last
	output	wire			o_axi_rready,  // Read Response ready

	// We'll share the clock and the reset
	input	wire			i_wb_cyc,
	input	wire			i_wb_stb,
	input	wire			i_wb_we,
	input	wire	[(AW-1):0]	i_wb_addr,
	input	wire	[(DW-1):0]	i_wb_data,
	input	wire	[(DW/8-1):0]	i_wb_sel,
	output	reg			o_wb_ack,
	output	wire			o_wb_stall,
	output	reg	[(DW-1):0]	o_wb_data,
	output	reg			o_wb_err
);

//*****************************************************************************
// Parameter declarations
//*****************************************************************************

	localparam	LG_AXI_DW	= ( C_AXI_DATA_WIDTH ==   8) ? 3
					: ((C_AXI_DATA_WIDTH ==  16) ? 4
					: ((C_AXI_DATA_WIDTH ==  32) ? 5
					: ((C_AXI_DATA_WIDTH ==  64) ? 6
					: ((C_AXI_DATA_WIDTH == 128) ? 7
					: 8))));

	localparam	LG_WB_DW	= ( DW ==   8) ? 3
					: ((DW ==  16) ? 4
					: ((DW ==  32) ? 5
					: ((DW ==  64) ? 6
					: ((DW == 128) ? 7
					: 8))));
	localparam	LGFIFOLN = C_AXI_ID_WIDTH;
	localparam	FIFOLN = (1<<LGFIFOLN);


//*****************************************************************************
// Internal register and wire declarations
//*****************************************************************************

// Things we're not changing ...
	assign o_axi_awlen   = 8'h0;	// Burst length is one
	assign o_axi_awsize  = 3'b101;	// maximum bytes per burst is 32
	assign o_axi_awburst = 2'b01;	// Incrementing address (ignored)
	assign o_axi_arburst = 2'b01;	// Incrementing address (ignored)
	assign o_axi_awlock  = 1'b0;	// Normal signaling
	assign o_axi_arlock  = 1'b0;	// Normal signaling
	assign o_axi_awcache = 4'h2;	// Normal: no cache, no buffer
	assign o_axi_arcache = 4'h2;	// Normal: no cache, no buffer
	assign o_axi_awprot  = 3'b010;	// Unpriviledged, unsecure, data access
	assign o_axi_arprot  = 3'b010;	// Unpriviledged, unsecure, data access
	assign o_axi_awqos   = 4'h0;	// Lowest quality of service (unused)
	assign o_axi_arqos   = 4'h0;	// Lowest quality of service (unused)

	reg	wb_mid_cycle, wb_last_cyc_stb, wb_mid_abort, wb_cyc_stb;
	wire	wb_abort;

// Command logic
// Transaction ID logic
	wire	[(LGFIFOLN-1):0]	fifo_head;
	reg	[(C_AXI_ID_WIDTH-1):0]	transaction_id;

	initial	transaction_id = 0;
	always @(posedge i_clk)
	if (i_reset)
		transaction_id <= 0;
	else if ((i_wb_stb)&&(!o_wb_stall))
		transaction_id <= transaction_id + 1'b1;

	assign	fifo_head = transaction_id;

	wire	[(DW/8-1):0]			no_sel;
	wire	[(LG_AXI_DW-4):0]	axi_bottom_addr;
	assign	no_sel = 0;
	assign	axi_bottom_addr = 0;


// Write address logic

	initial	o_axi_awvalid = 0;
	always @(posedge i_clk)
	if (i_reset)
		o_axi_awvalid <= 0;
	else
		o_axi_awvalid <= (!o_wb_stall)&&(i_wb_stb)&&(i_wb_we)
			||(o_axi_awvalid)&&(!i_axi_awready);

	generate

	initial	o_axi_awid = -1;
	always @(posedge i_clk)
	if (i_reset)
		o_axi_awid <= -1;
	else if ((i_wb_stb)&&(!o_wb_stall))
		o_axi_awid <= transaction_id;

	if (C_AXI_DATA_WIDTH == DW)
	begin
		always @(posedge i_clk)
		if ((i_wb_stb)&&(!o_wb_stall)) // 26 bit address becomes 28 bit ...
			o_axi_awaddr <= { i_wb_addr[AW-1:0], axi_bottom_addr };
	end else if (C_AXI_DATA_WIDTH / DW == 2)
	begin

		always @(posedge i_clk)
		if ((i_wb_stb)&&(!o_wb_stall)) // 26 bit address becomes 28 bit ...
			o_axi_awaddr <= { i_wb_addr[AW-1:1], axi_bottom_addr };

	end else if (C_AXI_DATA_WIDTH / DW == 4)
	begin
		always @(posedge i_clk)
		if ((i_wb_stb)&&(!o_wb_stall)) // 26 bit address becomes 28 bit ...
			o_axi_awaddr <= { i_wb_addr[AW-1:2], axi_bottom_addr };
	end endgenerate


// Read address logic
	assign	o_axi_arid   = o_axi_awid;
	assign	o_axi_araddr = o_axi_awaddr;
	assign	o_axi_arlen  = o_axi_awlen;
	assign	o_axi_arsize = 3'b101;	// maximum bytes per burst is 32
	initial	o_axi_arvalid = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		o_axi_arvalid <= 1'b0;
	else
		o_axi_arvalid <= (!o_wb_stall)&&(i_wb_stb)&&(!i_wb_we)
			||(o_axi_arvalid)&&(!i_axi_arready);

// Write data logic
	generate
	if (C_AXI_DATA_WIDTH == DW)
	begin

		always @(posedge i_clk)
			if ((i_wb_stb)&&(!o_wb_stall))
				o_axi_wdata <= i_wb_data;

		always @(posedge i_clk)
			if ((i_wb_stb)&&(!o_wb_stall))
				o_axi_wstrb<= i_wb_sel;

	end else if (C_AXI_DATA_WIDTH/2 == DW)
	begin

		always @(posedge i_clk)
			if ((i_wb_stb)&&(!o_wb_stall))
				o_axi_wdata <= { i_wb_data, i_wb_data };

		always @(posedge i_clk)
			if ((i_wb_stb)&&(!o_wb_stall))
			case(i_wb_addr[0])
			1'b0:o_axi_wstrb<={  no_sel,i_wb_sel };
			1'b1:o_axi_wstrb<={i_wb_sel,  no_sel };
			endcase

	end else if (C_AXI_DATA_WIDTH/4 == DW)
	begin

		always @(posedge i_clk)
			if ((i_wb_stb)&&(!o_wb_stall))
				o_axi_wdata <= { i_wb_data, i_wb_data, i_wb_data, i_wb_data };

		always @(posedge i_clk)
			if ((i_wb_stb)&&(!o_wb_stall))
			case(i_wb_addr[1:0])
			2'b00:o_axi_wstrb<={   no_sel,   no_sel,   no_sel, i_wb_sel };
			2'b01:o_axi_wstrb<={   no_sel,   no_sel, i_wb_sel,   no_sel };
			2'b10:o_axi_wstrb<={   no_sel, i_wb_sel,   no_sel,   no_sel };
			2'b11:o_axi_wstrb<={ i_wb_sel,   no_sel,   no_sel,   no_sel };
			endcase

	end endgenerate

	assign	o_axi_wlast = 1'b1;
	initial	o_axi_wvalid = 0;
	always @(posedge i_clk)
	if (i_reset)
		o_axi_wvalid <= 0;
	else
		o_axi_wvalid <= ((!o_wb_stall)&&(i_wb_stb)&&(i_wb_we))
			||(o_axi_wvalid)&&(!i_axi_wready);

	// Read data channel / response logic
	assign	o_axi_rready = 1'b1;
	assign	o_axi_bready = 1'b1;

	wire	[(LGFIFOLN-1):0]	n_fifo_head, nn_fifo_head;
	assign	n_fifo_head = fifo_head+1'b1;
	assign	nn_fifo_head = { fifo_head[(LGFIFOLN-1):1]+1'b1, fifo_head[0] };


	wire	w_fifo_full;
	reg	[(LGFIFOLN-1):0]	fifo_tail;

	generate
	if (C_AXI_DATA_WIDTH == DW)
	begin
		if (STRICT_ORDER == 0)
		begin
			reg	[(C_AXI_DATA_WIDTH-1):0] reorder_fifo_data [0:(FIFOLN-1)];

			always @(posedge i_clk)
				if ((o_axi_rready)&&(i_axi_rvalid))
					reorder_fifo_data[i_axi_rid] <= i_axi_rdata;
			always @(posedge i_clk)
				o_wb_data <= reorder_fifo_data[fifo_tail];
		end else begin
			reg	[(C_AXI_DATA_WIDTH-1):0] reorder_fifo_data;

			always @(posedge i_clk)
				reorder_fifo_data <= i_axi_rdata;
			always @(posedge i_clk)
				o_wb_data <= reorder_fifo_data;
		end
	end else if (C_AXI_DATA_WIDTH / DW == 2)
	begin
		reg		reorder_fifo_addr [0:(FIFOLN-1)];

		reg		low_addr;
		always @(posedge i_clk)
			if ((i_wb_stb)&&(!o_wb_stall))
				low_addr <= i_wb_addr[0];
		always @(posedge i_clk)
			if ((o_axi_arvalid)&&(i_axi_arready))
				reorder_fifo_addr[o_axi_arid] <= low_addr;

		if (STRICT_ORDER == 0)
		begin
			reg	[(C_AXI_DATA_WIDTH-1):0] reorder_fifo_data [0:(FIFOLN-1)];

			always @(posedge i_clk)
				if ((o_axi_rready)&&(i_axi_rvalid))
					reorder_fifo_data[i_axi_rid] <= i_axi_rdata;
			always @(posedge i_clk)
				reorder_fifo_data[i_axi_rid] <= i_axi_rdata;
			always @(posedge i_clk)
			case(reorder_fifo_addr[fifo_tail])
			1'b0: o_wb_data <=reorder_fifo_data[fifo_tail][(  DW-1):    0 ];
			1'b1: o_wb_data <=reorder_fifo_data[fifo_tail][(2*DW-1):(  DW)];
			endcase
		end else begin
			reg	[(C_AXI_DATA_WIDTH-1):0] reorder_fifo_data;

			always @(posedge i_clk)
				reorder_fifo_data <= i_axi_rdata;
			always @(posedge i_clk)
			case(reorder_fifo_addr[fifo_tail])
			1'b0: o_wb_data <=reorder_fifo_data[(  DW-1):    0 ];
			1'b1: o_wb_data <=reorder_fifo_data[(2*DW-1):(  DW)];
			endcase
		end
	end else if (C_AXI_DATA_WIDTH / DW == 4)
	begin
		reg	[1:0]	reorder_fifo_addr [0:(FIFOLN-1)];


		reg	[1:0]	low_addr;
		always @(posedge i_clk)
			if ((i_wb_stb)&&(!o_wb_stall))
				low_addr <= i_wb_addr[1:0];
		always @(posedge i_clk)
			if ((o_axi_arvalid)&&(i_axi_arready))
				reorder_fifo_addr[o_axi_arid] <= low_addr;

		if (STRICT_ORDER == 0)
		begin
			reg	[(C_AXI_DATA_WIDTH-1):0] reorder_fifo_data [0:(FIFOLN-1)];

			always @(posedge i_clk)
				if ((o_axi_rready)&&(i_axi_rvalid))
					reorder_fifo_data[i_axi_rid] <= i_axi_rdata;
			always @(posedge i_clk)
			case(reorder_fifo_addr[fifo_tail][1:0])
			2'b00: o_wb_data <=reorder_fifo_data[fifo_tail][(  DW-1):    0 ];
			2'b01: o_wb_data <=reorder_fifo_data[fifo_tail][(2*DW-1):(  DW)];
			2'b10: o_wb_data <=reorder_fifo_data[fifo_tail][(3*DW-1):(2*DW)];
			2'b11: o_wb_data <=reorder_fifo_data[fifo_tail][(4*DW-1):(3*DW)];
			endcase
		end else begin
			reg	[(C_AXI_DATA_WIDTH-1):0] reorder_fifo_data;

			always @(posedge i_clk)
				reorder_fifo_data <= i_axi_rdata;
			always @(posedge i_clk)
			case(reorder_fifo_addr[fifo_tail][1:0])
			2'b00: o_wb_data <=reorder_fifo_data[(  DW-1): 0];
			2'b01: o_wb_data <=reorder_fifo_data[(2*DW-1):(  DW)];
			2'b10: o_wb_data <=reorder_fifo_data[(3*DW-1):(2*DW)];
			2'b11: o_wb_data <=reorder_fifo_data[(4*DW-1):(3*DW)];
			endcase
		end
	end

	endgenerate

	// verilator lint_off UNUSED
	wire	axi_rd_ack, axi_wr_ack, axi_ard_req, axi_awr_req, axi_wr_req,
		axi_rd_err, axi_wr_err;
	// verilator lint_on  UNUSED
	//
	assign	axi_ard_req = (o_axi_arvalid)&&(i_axi_arready);
	assign	axi_awr_req = (o_axi_awvalid)&&(i_axi_awready);
	assign	axi_wr_req  = (o_axi_wvalid )&&(i_axi_wready);
	//
	assign	axi_rd_ack = (i_axi_rvalid)&&(o_axi_rready);
	assign	axi_wr_ack = (i_axi_bvalid)&&(o_axi_bready);
	assign	axi_rd_err = (axi_rd_ack)&&(i_axi_rresp[1]);
	assign	axi_wr_err = (axi_wr_ack)&&(i_axi_bresp[1]);

	//
	// We're going to need a FIFO on the return to make certain that we can
	// select the right bits from the return value, in the case where
	// DW != the axi data width.
	//
	// If we aren't using a strict order, this FIFO is can be used as a
	// reorder buffer as well, to place our out of order bus responses
	// back into order.  Responses on the wishbone, however, are *always*
	// done in order.
`ifdef	FORMAL
	reg	[31:0]	reorder_count;
`endif
	integer	k;
	generate
	if (STRICT_ORDER == 0)
	begin
		// Reorder FIFO
		//
		// FIFO reorder buffer
		reg	[(FIFOLN-1):0]	reorder_fifo_valid;
		reg	[(FIFOLN-1):0]	reorder_fifo_err;

		initial reorder_fifo_valid = 0;
		initial reorder_fifo_err = 0;


		initial	fifo_tail = 0;
		initial	o_wb_ack  = 0;
		initial	o_wb_err  = 0;
		always @(posedge i_clk)
		if (i_reset)
		begin
			reorder_fifo_valid <= 0;
			reorder_fifo_err <= 0;
			o_wb_ack  <= 0;
			o_wb_err  <= 0;
			fifo_tail <= 0;
		end else begin
			if (axi_rd_ack)
			begin
				reorder_fifo_valid[i_axi_rid] <= 1'b1;
				reorder_fifo_err[i_axi_rid] <= axi_rd_err;
			end
			if (axi_wr_ack)
			begin
				reorder_fifo_valid[i_axi_bid] <= 1'b1;
				reorder_fifo_err[i_axi_bid] <= axi_wr_err;
			end

			if (reorder_fifo_valid[fifo_tail])
			begin
				o_wb_ack <= (!wb_abort)&&(!reorder_fifo_err[fifo_tail]);
				o_wb_err <= (!wb_abort)&&( reorder_fifo_err[fifo_tail]);
				fifo_tail <= fifo_tail + 1'b1;
				reorder_fifo_valid[fifo_tail] <= 1'b0;
				reorder_fifo_err[fifo_tail]   <= 1'b0;
			end else begin
				o_wb_ack <= 1'b0;
				o_wb_err <= 1'b0;
			end

			if (!i_wb_cyc)
			begin
				// reorder_fifo_valid <= 0;
				// reorder_fifo_err   <= 0;
				o_wb_err <= 1'b0;
				o_wb_ack <= 1'b0;
			end
		end

`ifdef	FORMAL
		always @(*)
		begin
			reorder_count = 0;
			for(k=0; k<FIFOLN; k=k+1)
				if (reorder_fifo_valid[k])
					reorder_count = reorder_count + 1;
		end

		reg	[(FIFOLN-1):0]	f_reorder_fifo_valid_zerod,
					f_reorder_fifo_err_zerod;
		always @(*)
			f_reorder_fifo_valid_zerod <=
				((reorder_fifo_valid >> fifo_tail)
				| (reorder_fifo_valid << (FIFOLN-fifo_tail)));
		always @(*)
			assert((f_reorder_fifo_valid_zerod & (~((1<<f_fifo_used)-1)))==0);
		//
		always @(*)
			f_reorder_fifo_err_zerod <=
				((reorder_fifo_valid >> fifo_tail)
				| (reorder_fifo_valid << (FIFOLN-fifo_tail)));
		always @(*)
			assert((f_reorder_fifo_err_zerod & (~((1<<f_fifo_used)-1)))==0);
`endif

		reg	r_fifo_full;
		initial	r_fifo_full = 0;
		always @(posedge i_clk)
		if (i_reset)
			r_fifo_full <= 0;
		else begin
			if ((i_wb_stb)&&(!o_wb_stall)
					&&(reorder_fifo_valid[fifo_tail]))
				r_fifo_full <= (fifo_tail==n_fifo_head);
			else if ((i_wb_stb)&&(!o_wb_stall))
				r_fifo_full <= (fifo_tail==nn_fifo_head);
			else if (reorder_fifo_valid[fifo_tail])
				r_fifo_full <= 1'b0;
			else
				r_fifo_full <= (fifo_tail==n_fifo_head);
		end
		assign w_fifo_full = r_fifo_full;
	end else begin
		//
		// Strict ordering
		//
		reg	reorder_fifo_valid;
		reg	reorder_fifo_err;

		initial	reorder_fifo_valid = 1'b0;
		initial	reorder_fifo_err   = 1'b0;
		always @(posedge i_clk)
		if (i_reset)
		begin
			reorder_fifo_valid <= 0;
			reorder_fifo_err   <= 0;
		end else begin
			if (axi_rd_ack)
			begin
				reorder_fifo_valid <= 1'b1;
				reorder_fifo_err   <= axi_rd_err;
			end else if (axi_wr_ack)
			begin
				reorder_fifo_valid <= 1'b1;
				reorder_fifo_err   <= axi_wr_err;
			end else begin
				reorder_fifo_valid <= 1'b0;
				reorder_fifo_err   <= 1'b0;
			end
		end

`ifdef	FORMAL
		always @(*)
			reorder_count = (reorder_fifo_valid) ? 1 : 0;
`endif

		initial	fifo_tail = 0;
		always @(posedge i_clk)
		if (i_reset)
			fifo_tail <= 0;
		else if (reorder_fifo_valid)
			fifo_tail <= fifo_tail + 1'b1;

		initial	o_wb_ack  = 0;
		always @(posedge i_clk)
		if (i_reset)
			o_wb_ack <= 0;
		else
			o_wb_ack <= (reorder_fifo_valid)&&(i_wb_cyc)&&(!wb_abort);

		initial	o_wb_err  = 0;
		always @(posedge i_clk)
		if (i_reset)
			o_wb_err <= 0;
		else
			o_wb_err <= (reorder_fifo_err)&&(i_wb_cyc)&&(!wb_abort);

		reg	r_fifo_full;
		initial	r_fifo_full = 0;
		always @(posedge i_clk)
		if (i_reset)
			r_fifo_full <= 0;
		else begin
			if ((i_wb_stb)&&(!o_wb_stall)
					&&(reorder_fifo_valid))
				r_fifo_full <= (fifo_tail==n_fifo_head);
			else if ((i_wb_stb)&&(!o_wb_stall))
				r_fifo_full <= (fifo_tail==nn_fifo_head);
			else if (reorder_fifo_valid)
				r_fifo_full <= 1'b0;
			else
				r_fifo_full <= (fifo_tail==n_fifo_head);
		end

		assign w_fifo_full = r_fifo_full;
	end endgenerate

	//
	// Wishbone abort logic
	//

	// Did we just accept something?
	initial	wb_cyc_stb = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		wb_cyc_stb <= 1'b0;
	else
		wb_cyc_stb <= (i_wb_cyc)&&(i_wb_stb)&&(!o_wb_stall);

	// Else, are we mid-cycle?
	initial	wb_mid_cycle = 0;
	always @(posedge i_clk)
	if (i_reset)
		wb_mid_cycle <= 0;
	else if ((fifo_head != fifo_tail)
			||(o_axi_arvalid)||(o_axi_awvalid)
			||(o_axi_wvalid)
			||(i_wb_cyc)&&(i_wb_stb)&&(!o_wb_stall))
		wb_mid_cycle <= 1'b1;
	else
		wb_mid_cycle <= 1'b0;

	initial	wb_mid_abort = 0;
	always @(posedge i_clk)
	if (i_reset)
		wb_mid_abort <= 0;
	else if (wb_mid_cycle)
		wb_mid_abort <= (wb_mid_abort)||(!i_wb_cyc);
	else
		wb_mid_abort <= 1'b0;

	assign	wb_abort = ((wb_mid_cycle)&&(!i_wb_cyc))||(wb_mid_abort);

	// Now, the difficult signal ... the stall signal
	// Let's build for a single cycle input ... and only stall if something
	// outgoing is valid and nothing is ready.
	assign	o_wb_stall = (i_wb_cyc)&&(
				(w_fifo_full)||(wb_mid_abort)
				||((o_axi_awvalid)&&(!i_axi_awready))
				||((o_axi_wvalid )&&(!i_axi_wready ))
				||((o_axi_arvalid)&&(!i_axi_arready)));


/////////////////////////////////////////////////////////////////////////
//
//
//
// Formal methods section
//
// These are only relevant when *proving* that this translator works
//
//
//
/////////////////////////////////////////////////////////////////////////
`ifdef	FORMAL
	reg	f_err_state;
//
`ifdef	WBM2AXISP
// If we are the top-level of the design ...
`define	ASSUME	assume
`define	FORMAL_CLOCK	assume(i_clk == !f_last_clk); f_last_clk <= i_clk;
`else
`define	ASSUME	assert
`define	FORMAL_CLOCK	f_last_clk <= i_clk; // Clock will be given to us valid already
`endif

	reg	[4:0]	f_reset_counter;
	initial	f_reset_counter = 1'b0;
	always @(posedge i_clk)
	if ((i_reset)&&(f_reset_counter < 5'h1f))
		f_reset_counter <= f_reset_counter + 1'b1;
	else if (!i_reset)
		f_reset_counter <= 0;

	always @(posedge i_clk)
	if ((f_past_valid)&&($past(i_reset))&&($past(f_reset_counter < 5'h10)))
		assume(i_reset);

	// Parameters
	initial	assert(	  (C_AXI_DATA_WIDTH / DW == 4)
			||(C_AXI_DATA_WIDTH / DW == 2)
			||(C_AXI_DATA_WIDTH      == DW));
	//
	initial	assert( C_AXI_ADDR_WIDTH - LG_AXI_DW + LG_WB_DW == AW);

	//
	// Setup
	//

	reg	f_past_valid, f_last_clk;

	always @($global_clock)
	begin
		`FORMAL_CLOCK

		// Assume our inputs will only change on the positive edge
		// of the clock
		if (!$rose(i_clk))
		begin
			// AXI inputs
			`ASSUME($stable(i_axi_awready));
			`ASSUME($stable(i_axi_wready));
			`ASSUME($stable(i_axi_bid));
			`ASSUME($stable(i_axi_bresp));
			`ASSUME($stable(i_axi_bvalid));
			`ASSUME($stable(i_axi_arready));
			`ASSUME($stable(i_axi_rid));
			`ASSUME($stable(i_axi_rresp));
			`ASSUME($stable(i_axi_rvalid));
			`ASSUME($stable(i_axi_rdata));
			`ASSUME($stable(i_axi_rlast));
			// Wishbone inputs
			`ASSUME((i_reset)||($stable(i_reset)));
			`ASSUME($stable(i_wb_cyc));
			`ASSUME($stable(i_wb_stb));
			`ASSUME($stable(i_wb_we));
			`ASSUME($stable(i_wb_addr));
			`ASSUME($stable(i_wb_data));
			`ASSUME($stable(i_wb_sel));
		end
	end

	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	//////////////////////////////////////////////
	//
	//
	// Assumptions about the WISHBONE inputs
	//
	//
	//////////////////////////////////////////////
	assume property(f_past_valid || i_reset);

	wire	[(C_AXI_ID_WIDTH-1):0]	f_wb_nreqs, f_wb_nacks,f_wb_outstanding;
	fwb_slave #(.DW(DW),.AW(AW),
			.F_MAX_STALL(0),
			.F_MAX_ACK_DELAY(0),
			.F_LGDEPTH(C_AXI_ID_WIDTH),
			.F_MAX_REQUESTS((1<<(C_AXI_ID_WIDTH))-2))
		f_wb(i_clk, i_reset, i_wb_cyc, i_wb_stb, i_wb_we, i_wb_addr,
					i_wb_data, i_wb_sel,
				o_wb_ack, o_wb_stall, o_wb_data, o_wb_err,
			f_wb_nreqs, f_wb_nacks, f_wb_outstanding);

	wire	[(C_AXI_ID_WIDTH-1):0]	f_axi_rd_outstanding,
					f_axi_wr_outstanding,
					f_axi_awr_outstanding;

	wire	[((1<<C_AXI_ID_WIDTH)-1):0]	f_axi_rd_id_outstanding,
						f_axi_wr_id_outstanding,
						f_axi_awr_id_outstanding;

	faxi_master #(
		.C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
		.C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.F_AXI_MAXSTALL(3),
		.F_AXI_MAXDELAY(3),
		.F_STRICT_ORDER(STRICT_ORDER),
		.F_CONSECUTIVE_IDS(1'b1),
		.F_OPT_BURSTS(1'b0),
		.F_CHECK_IDS(1'b1))
		f_axi(.i_clk(i_clk), .i_axi_reset_n(!i_reset),
			// Write address channel
			.i_axi_awready(i_axi_awready), 
			.i_axi_awid(   o_axi_awid), 
			.i_axi_awaddr( o_axi_awaddr), 
			.i_axi_awlen(  o_axi_awlen), 
			.i_axi_awsize( o_axi_awsize), 
			.i_axi_awburst(o_axi_awburst), 
			.i_axi_awlock( o_axi_awlock), 
			.i_axi_awcache(o_axi_awcache), 
			.i_axi_awprot( o_axi_awprot), 
			.i_axi_awqos(  o_axi_awqos), 
			.i_axi_awvalid(o_axi_awvalid), 
			// Write data channel
			.i_axi_wready( i_axi_wready),
			.i_axi_wdata(  o_axi_wdata),
			.i_axi_wstrb(  o_axi_wstrb),
			.i_axi_wlast(  o_axi_wlast),
			.i_axi_wvalid( o_axi_wvalid),
			// Write response channel
			.i_axi_bid(    i_axi_bid),
			.i_axi_bresp(  i_axi_bresp),
			.i_axi_bvalid( i_axi_bvalid),
			.i_axi_bready( o_axi_bready),
			// Read address channel
			.i_axi_arready(i_axi_arready),
			.i_axi_arid(   o_axi_arid),
			.i_axi_araddr( o_axi_araddr),
			.i_axi_arlen(  o_axi_arlen),
			.i_axi_arsize( o_axi_arsize),
			.i_axi_arburst(o_axi_arburst),
			.i_axi_arlock( o_axi_arlock),
			.i_axi_arcache(o_axi_arcache),
			.i_axi_arprot( o_axi_arprot),
			.i_axi_arqos(  o_axi_arqos),
			.i_axi_arvalid(o_axi_arvalid),
			// Read data channel
			.i_axi_rid(    i_axi_rid),
			.i_axi_rresp(  i_axi_rresp),
			.i_axi_rvalid( i_axi_rvalid),
			.i_axi_rdata(  i_axi_rdata),
			.i_axi_rlast(  i_axi_rlast),
			.i_axi_rready( o_axi_rready),
			// Counts
			.f_axi_rd_outstanding( f_axi_rd_outstanding),
			.f_axi_wr_outstanding( f_axi_wr_outstanding),
			.f_axi_awr_outstanding( f_axi_awr_outstanding),
			// Outstanding ID's
			.f_axi_rd_id_outstanding( f_axi_rd_id_outstanding),
			.f_axi_wr_id_outstanding( f_axi_wr_id_outstanding),
			.f_axi_awr_id_outstanding(f_axi_awr_id_outstanding)
		);



	//////////////////////////////////////////////
	//
	//
	// Assumptions about the AXI inputs
	//
	//
	//////////////////////////////////////////////


	//////////////////////////////////////////////
	//
	//
	// Assertions about the AXI4 ouputs
	//
	//
	//////////////////////////////////////////////

	wire	[(LGFIFOLN-1):0]	f_last_transaction_id;
	assign	f_last_transaction_id = transaction_id- 1;
	always @(posedge i_clk)
	if ((f_past_valid)&&(!$past(i_reset)))
	begin
		assert(o_axi_awid == f_last_transaction_id);
		if ($past(o_wb_stall))
			assert($stable(o_axi_awid));
	end

	// Write response channel
	always @(posedge i_clk)
		// We keep bready high, so the other condition doesn't
		// need to be checked
		assert(o_axi_bready);

	// AXI read data channel signals
	always @(posedge i_clk)
		// We keep o_axi_rready high, so the other condition's
		// don't need to be checked here
		assert(o_axi_rready);

	//
	// Let's look into write requests
	//
	initial	assert(!o_axi_awvalid);
	initial	assert(!o_axi_wvalid);
	always @(posedge i_clk)
	if ((f_past_valid)&&($past(i_wb_stb))&&($past(i_wb_we))&&(!$past(o_wb_stall)))
	begin
		if ($past(i_reset))
		begin
			assert(!o_axi_awvalid);
			assert(!o_axi_wvalid);
		end else begin
			// Following any write request that we accept, awvalid
			// and wvalid should both be true
			assert(o_axi_awvalid);
			assert(o_axi_wvalid);
		end
	end

	// Let's assume all responses will come within 120 clock ticks
	parameter	[(C_AXI_ID_WIDTH-1):0]	F_AXI_MAXDELAY = 3,
						F_AXI_MAXSTALL = 3; // 7'd120;
	localparam	[(C_AXI_ID_WIDTH):0]	F_WB_MAXDELAY = F_AXI_MAXDELAY + 4;

	//
	// AXI write address channel
	//
	always @(posedge i_clk)
	if ((f_past_valid)&&($past(i_wb_cyc))&&(!$past(o_wb_stall)))
	begin
		if (($past(i_reset))||(!$past(i_wb_stb)))
			assert(!o_axi_awvalid);
		else
			assert(o_axi_awvalid == $past(i_wb_we));
	end
	//
	generate
	if (C_AXI_DATA_WIDTH      == DW)
	begin
		always @(posedge i_clk)
		if ((f_past_valid)&&($past(i_wb_cyc))&&($past(i_wb_stb))&&($past(i_wb_we))
			&&(!$past(o_wb_stall)))
			assert(o_axi_awaddr == { $past(i_wb_addr[AW-1:0]), axi_bottom_addr });

	end else if (C_AXI_DATA_WIDTH / DW == 2)
	begin

		always @(posedge i_clk)
		if ((f_past_valid)&&($past(i_wb_cyc))&&($past(i_wb_stb))&&($past(i_wb_we))
			&&(!$past(o_wb_stall)))
			assert(o_axi_awaddr == { $past(i_wb_addr[AW-1:1]), axi_bottom_addr });

	end else if (C_AXI_DATA_WIDTH / DW == 4)
	begin

		always @(posedge i_clk)
		if ((f_past_valid)&&($past(i_wb_cyc))&&($past(i_wb_stb))&&($past(i_wb_we))
			&&(!$past(o_wb_stall)))
			assert(o_axi_awaddr == { $past(i_wb_addr[AW-1:2]), axi_bottom_addr });

	end endgenerate

	//
	// AXI write data channel
	//
	always @(posedge i_clk)
	if ((f_past_valid)&&($past(i_wb_cyc))&&(!$past(o_wb_stall)))
	begin
		if (($past(i_reset))||(!$past(i_wb_stb)))
			assert(!o_axi_wvalid);
		else
			assert(o_axi_wvalid == $past(i_wb_we));
	end
	//
	generate
	if (C_AXI_DATA_WIDTH == DW)
	begin

		always @(posedge i_clk)
		if ((f_past_valid)&&($past(i_wb_stb))&&($past(i_wb_we)))
		begin
			assert(o_axi_wdata == $past(i_wb_data));
			assert(o_axi_wstrb == $past(i_wb_sel));
		end

	end else if (C_AXI_DATA_WIDTH / DW == 2)
	begin

		always @(posedge i_clk)
		if ((f_past_valid)&&($past(i_wb_stb))&&($past(i_wb_we)))
		begin
			case($past(i_wb_addr[0]))
			1'b0: assert(o_axi_wdata[(  DW-1): 0] == $past(i_wb_data));
			1'b1: assert(o_axi_wdata[(2*DW-1):DW] == $past(i_wb_data));
			endcase

			case($past(i_wb_addr[0]))
			1'b0: assert(o_axi_wstrb == {  no_sel,$past(i_wb_sel)});
			1'b1: assert(o_axi_wstrb == {  $past(i_wb_sel),no_sel});
			endcase
		end

	end else if (C_AXI_DATA_WIDTH / DW == 4)
	begin

		always @(posedge i_clk)
		if ((f_past_valid)&&($past(i_wb_stb))&&(!$past(o_wb_stall))&&($past(i_wb_we)))
		begin
			case($past(i_wb_addr[1:0]))
			2'b00: assert(o_axi_wdata[  (DW-1):    0 ] == $past(i_wb_data));
			2'b00: assert(o_axi_wdata[(2*DW-1):(  DW)] == $past(i_wb_data));
			2'b00: assert(o_axi_wdata[(3*DW-1):(2*DW)] == $past(i_wb_data));
			2'b11: assert(o_axi_wdata[(4*DW-1):(3*DW)] == $past(i_wb_data));
			endcase

			case($past(i_wb_addr[1:0]))
			2'b00: assert(o_axi_wstrb == { {(3){no_sel}},$past(i_wb_sel)});
			2'b01: assert(o_axi_wstrb == { {(2){no_sel}},$past(i_wb_sel), {(1){no_sel}}});
			2'b10: assert(o_axi_wstrb == { {(1){no_sel}},$past(i_wb_sel), {(2){no_sel}}});
			2'b11: assert(o_axi_wstrb == {       $past(i_wb_sel),{(3){no_sel}}});
			endcase
		end
	end endgenerate

	//
	// AXI read address channel
	//
	initial	assert(!o_axi_arvalid);
	always @(posedge i_clk)
	if ((f_past_valid)&&($past(i_wb_cyc))&&(!$past(o_wb_stall)))
	begin
		if (($past(i_reset))||(!$past(i_wb_stb)))
			assert(!o_axi_arvalid);
		else
			assert(o_axi_arvalid == !$past(i_wb_we));
	end
	//
	generate
	if (C_AXI_DATA_WIDTH == DW)
	begin
		always @(posedge i_clk)
			if ((f_past_valid)&&($past(i_wb_stb))&&($past(!i_wb_we))
				&&(!$past(o_wb_stall)))
				assert(o_axi_araddr == $past({ i_wb_addr[AW-1:0], axi_bottom_addr }));

	end else if (C_AXI_DATA_WIDTH / DW == 2)
	begin

		always @(posedge i_clk)
			if ((f_past_valid)&&($past(i_wb_stb))&&($past(!i_wb_we))
				&&(!$past(o_wb_stall)))
				assert(o_axi_araddr == $past({ i_wb_addr[AW-1:1], axi_bottom_addr }));

	end else if (C_AXI_DATA_WIDTH / DW == 4)
	begin
		always @(posedge i_clk)
			if ((f_past_valid)&&($past(i_wb_stb))&&($past(!i_wb_we))
				&&(!$past(o_wb_stall)))
				assert(o_axi_araddr == $past({ i_wb_addr[AW-1:2], axi_bottom_addr }));

	end endgenerate

	//
	// AXI write response channel
	//


	//
	// AXI read data channel signals
	//
	always @(posedge i_clk)
		`ASSUME(f_axi_rd_outstanding <= f_wb_outstanding);
	//
	always @(posedge i_clk)
		`ASSUME(f_axi_rd_outstanding + f_axi_wr_outstanding  <= f_wb_outstanding);
	always @(posedge i_clk)
		`ASSUME(f_axi_rd_outstanding + f_axi_awr_outstanding <= f_wb_outstanding);
	//
	always @(posedge i_clk)
		`ASSUME(f_axi_rd_outstanding + f_axi_wr_outstanding +2 > f_wb_outstanding);
	always @(posedge i_clk)
		`ASSUME(f_axi_rd_outstanding + f_axi_awr_outstanding +2 > f_wb_outstanding);

	// Make sure we only create one request at a time
	always @(posedge i_clk)
		assert((!o_axi_arvalid)||(!o_axi_wvalid));
	always @(posedge i_clk)
		assert((!o_axi_arvalid)||(!o_axi_awvalid));

	// Now, let's look into that FIFO.  Without it, we know nothing about the ID's

	// Error handling
	always @(posedge i_clk)
		if (!i_wb_cyc)
			f_err_state <= 0;
		else if (o_wb_err)
			f_err_state <= 1;
	always @(posedge i_clk)
		if ((f_past_valid)&&($past(f_err_state))&&(
				(!$past(o_wb_stall))||(!$past(i_wb_stb))))
			`ASSUME(!i_wb_stb);

	// Head and tail pointers

	// The head should only increment when something goes through
	always @(posedge i_clk)
		if ((f_past_valid)&&(!$past(i_reset))
				&&((!$past(i_wb_stb))||($past(o_wb_stall))))
			assert($stable(fifo_head));

	// Can't overrun the FIFO
	wire	[(LGFIFOLN-1):0]	f_fifo_tail_minus_one;
	assign	f_fifo_tail_minus_one = fifo_tail - 1'b1;
	always @(posedge i_clk)
	if ((!f_past_valid)||($past(i_reset)))
		assert(fifo_head == fifo_tail);
	else if ((f_past_valid)&&($past(fifo_head == f_fifo_tail_minus_one)))
		assert(fifo_head != fifo_tail);

	reg			f_pre_ack;

	wire	[(LGFIFOLN-1):0]	f_fifo_used;
	assign	f_fifo_used = fifo_head - fifo_tail;

	initial	assert(fifo_tail == 0);
	initial assert(reorder_fifo_valid        == 0);
	initial assert(reorder_fifo_err          == 0);
	initial f_pre_ack = 1'b0;
	always @(posedge i_clk)
	begin
		f_pre_ack <= (!wb_abort)&&((axi_rd_ack)||(axi_wr_ack));
		if (STRICT_ORDER)
		begin
			`ASSUME((!axi_rd_ack)||(!axi_wr_ack));

			if ((f_past_valid)&&(!$past(i_reset)))
				assert((!$past(i_wb_cyc))
					||(o_wb_ack == $past(f_pre_ack)));
		end
	end

	//
	// Verify that there are no outstanding requests outside of the FIFO
	// window.  This should never happen, but the formal tools need to know
	// that.
	//
	always @(*)
	begin
		assert((f_axi_rd_id_outstanding&f_axi_wr_id_outstanding)==0);
		assert((f_axi_rd_id_outstanding&f_axi_awr_id_outstanding)==0);

		if (fifo_head == fifo_tail)
		begin
			assert(f_axi_rd_id_outstanding  == 0);
			assert(f_axi_wr_id_outstanding  == 0);
			assert(f_axi_awr_id_outstanding == 0);
		end

		for(k=0; k<(1<<LGFIFOLN); k=k+1)
		begin
			if (      ((fifo_tail < fifo_head)&&(k <  fifo_tail))
				||((fifo_tail < fifo_head)&&(k >= fifo_head))
				||((fifo_head < fifo_tail)&&(k >= fifo_head)&&(k < fifo_tail))
				//||((fifo_head < fifo_tail)&&(k >=fifo_tail))
				)
			begin
				assert(f_axi_rd_id_outstanding[k]==0);
				assert(f_axi_wr_id_outstanding[k]==0);
				assert(f_axi_awr_id_outstanding[k]==0);
			end
		end
	end

	generate
	if (STRICT_ORDER)
	begin : STRICTREQ

		reg	[C_AXI_ID_WIDTH-1:0]	f_last_axi_id;
		wire	[C_AXI_ID_WIDTH-1:0]	f_next_axi_id,
						f_expected_last_id;
		assign	f_next_axi_id = f_last_axi_id + 1'b1;
		assign	f_expected_last_id = fifo_head - 1'b1 - f_fifo_used;

		initial	f_last_axi_id = -1;
		always @(posedge i_clk)
			if (i_reset)
				f_last_axi_id = -1;
			else if ((axi_rd_ack)||(axi_wr_ack))
				f_last_axi_id <= f_next_axi_id;
			else if (f_fifo_used == 0)
				assert(f_last_axi_id == fifo_head-1'b1);

		always @(posedge i_clk)
			if (axi_rd_ack)
				`ASSUME(i_axi_rid == f_next_axi_id);
			else if (axi_wr_ack)
				`ASSUME(i_axi_bid == f_next_axi_id);
	end endgenerate

	reg	f_pending, f_returning;
	initial	f_pending = 1'b0;
	always @(*)
		f_pending <= (o_axi_arvalid)||(o_axi_awvalid);
	always @(*)
		f_returning <= (axi_rd_ack)||(axi_wr_ack);

	reg	[(LGFIFOLN):0]	f_pre_count;

	always @(*)
		f_pre_count <= f_axi_awr_outstanding
		 	+ f_axi_rd_outstanding
			+ reorder_count
			+ { {(LGFIFOLN){1'b0}}, (o_wb_ack) }
			+ { {(LGFIFOLN){1'b0}}, (f_pending) };
	always @(posedge i_clk)
		assert((wb_abort)||(o_wb_err)||(f_pre_count == f_wb_outstanding));

	always @(posedge i_clk)
		assert((wb_abort)||(o_wb_err)||(f_fifo_used == f_wb_outstanding
					// + {{(LGFIFOLN){1'b0}},f_past_valid)(i_wb_stb)&&(!o_wb_ack)}
					- {{(LGFIFOLN){1'b0}},(o_wb_ack)}));

	always @(posedge i_clk)
		if (o_axi_wvalid)
			assert(f_fifo_used != 0);
	always @(posedge i_clk)
		if (o_axi_arvalid)
			assert(f_fifo_used != 0);
	always @(posedge i_clk)
		if (o_axi_awvalid)
			assert(f_fifo_used != 0);

`endif
endmodule
////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	wbxbar.v
//
// Project:	Pipelined Wishbone to AXI converter
//
// Purpose:	A Configurable wishbone cross-bar interconnect
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2019, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory, run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype none
//
module	wbxbar(i_clk, i_reset,
	i_mcyc, i_mstb, i_mwe, i_maddr, i_mdata, i_msel,
		o_mstall, o_mack, o_mdata, o_merr,
	o_scyc, o_sstb, o_swe, o_saddr, o_sdata, o_ssel,
		i_sstall, i_sack, i_sdata, i_serr);
	parameter	NM = 4, NS=8;
	parameter	AW = 20, DW=32;
	parameter	[NS*AW-1:0]	SADDR = {
				3'b111, 17'h0,
				3'b110, 17'h0,
				3'b101, 17'h0,
				3'b100, 17'h0,
				3'b011, 17'h0,
				3'b010, 17'h0,
				4'b0010, 16'h0,
				4'b0000, 16'h0 };
	parameter	[NS*AW-1:0]	SMASK = (NS <= 1) ? 0
		: { {(NS-2){ 3'b111, 17'h0 }}, {(2){ 4'b1111, 16'h0 }} };
	// parameter	[AW-1:0]	SADDR = 0;
	// parameter	[AW-1:0]	SMASK = 0;
	//
	// LGMAXBURST is the log_2 of the length of the longest burst that
	// might be seen.  It's used to set the size of the internal
	// counters that are used to make certain that the cross bar doesn't
	// switch while still waiting on a response.
	parameter	LGMAXBURST=6;
	//
	// OPT_TIMEOUT is used to help recover from a misbehaving slave.  If
	// set, this value will determine the number of clock cycles to wait
	// for a misbehaving slave before returning a bus error.  Alternatively,
	// if set to zero, this functionality will be removed.
	parameter	OPT_TIMEOUT = 0; // 1023;
	//
	// If OPT_TIMEOUT is set, then OPT_STARVATION_TIMEOUT may also be set.
	// The starvation timeout adds to the bus error timeout generation
	// the possibility that a master will wait OPT_TIMEOUT counts without
	// receiving the bus.  This may be the case, for example, if one
	// bus master is consuming a peripheral to such an extent that there's
	// no time/room for another bus master to use it.  In that case, when
	// the timeout runs out, the waiting bus master will be given a bus
	// error.
	parameter [0:0]	OPT_STARVATION_TIMEOUT = 1'b0 && (OPT_TIMEOUT > 0);
	//
	// TIMEOUT_WIDTH is the number of bits in counter used to check on a
	// timeout.
	localparam	TIMEOUT_WIDTH = $clog2(OPT_TIMEOUT);
	//
	// OPT_DBLBUFFER is used to register all of the outputs, and thus
	// avoid adding additional combinational latency through the core
	// that might require a slower clock speed.
	parameter [0:0]	OPT_DBLBUFFER = 1'b1;
	//
	// OPT_LOWPOWER adds logic to try to force unused values to zero,
	// rather than to allow a variety of logic optimizations that could
	// be used to reduce the logic count of the device.  Hence, OPT_LOWPOWER
	// will use more logic, but it won't drive bus wires unless there's a
	// value to drive onto them.
	parameter [0:0]	OPT_LOWPOWER = 1'b1;
	//
	// LGNM is the log (base two) of the number of bus masters connecting
	// to this crossbar
	localparam	LGNM = (NM>1) ? $clog2(NM) : 1;
	//
	// LGNM is the log (base two) of the number of slaves plus one come
	// out of the system.  The extra "plus one" is used for a pseudo slave
	// representing the case where the given address doesn't connect to
	// any of the slaves.  This address will generate a bus error.
	localparam	LGNS = $clog2(NS+1);
	//
	//
	input	wire			i_clk, i_reset;
	//
	// Here are the bus inputs from each of the WB bus masters
	input	wire	[NM-1:0]	i_mcyc, i_mstb, i_mwe;
	input	wire	[NM*AW-1:0]	i_maddr;
	input	wire	[NM*DW-1:0]	i_mdata;
	input	wire	[NM*DW/8-1:0]	i_msel;
	//
	// .... and their return data
	output	reg	[NM-1:0]	o_mstall, o_mack, o_merr;
	output	reg	[NM*DW-1:0]	o_mdata;
	//
	//
	// Here are the output ports, used to control each of the various
	// slave ports that we are connected to
	output	reg	[NS-1:0]	o_scyc, o_sstb, o_swe;
	output	reg	[NS*AW-1:0]	o_saddr;
	output	reg	[NS*DW-1:0]	o_sdata;
	output	reg	[NS*DW/8-1:0]	o_ssel;
	//
	// ... and their return data back to us.
	input	wire	[NS-1:0]	i_sstall, i_sack, i_serr;
	input	wire	[NS*DW-1:0]	i_sdata;
	//
	//

	// At one time I used o_macc and o_sacc to put into the outgoing
	// trace file, just enough logic to tell me if a transaction was
	// taking place on the given clock.
	//
	// assign	o_macc = (i_mstb & ~o_mstall);
	// assign	o_sacc = (o_sstb & ~i_sstall);
	//
	// These definitions work with Verilator, just not with Yosys
	// reg	[NM-1:0][NS:0]		request;
	// reg	[NM-1:0][NS-1:0]	requested;
	// reg	[NM-1:0][NS:0]		grant;
	//
	// These definitions work with both
	reg	[NS:0]			request		[0:NM-1];
	reg	[NS-1:0]		requested	[0:NM-1];
	reg	[NS:0]			grant		[0:NM-1];
	reg	[NM-1:0]		mgrant;
	reg	[NS-1:0]		sgrant;

	wire	[LGMAXBURST-1:0]	w_mpending [0:NM-1];
	reg	[NM-1:0]		mfull;
	reg	[NM-1:0]		mnearfull;
	reg	[NM-1:0]		mempty, timed_out;

	localparam	NMFULL = (NM > 1) ? (1<<LGNM) : 1;
	localparam	NSFULL = (1<<LGNS);
	reg	[NMFULL-1:0]	r_stb;
	reg	[NMFULL-1:0]	r_we;
	reg	[AW-1:0]	r_addr		[0:NMFULL-1];
	reg	[DW-1:0]	r_data		[0:NMFULL-1];
	reg	[DW/8-1:0]	r_sel		[0:NMFULL-1];
	wire	[TIMEOUT_WIDTH-1:0]	w_deadlock_timer [0:NM-1];


	reg	[LGNS-1:0]	mindex		[0:NMFULL-1];
	reg	[LGNM-1:0]	sindex		[0:NSFULL-1];

	reg	[NMFULL-1:0]	m_cyc;
	reg	[NMFULL-1:0]	m_stb;
	reg	[NMFULL-1:0]	m_we;
	reg	[AW-1:0]	m_addr		[0:NMFULL-1];
	reg	[DW-1:0]	m_data		[0:NMFULL-1];
	reg	[DW/8-1:0]	m_sel		[0:NMFULL-1];
	//
	reg	[NSFULL-1:0]	s_stall;
	reg	[DW-1:0]	s_data		[0:NSFULL-1];
	reg	[NSFULL-1:0]	s_ack;
	reg	[NSFULL-1:0]	s_err;

	genvar	N, M;
	integer	iN, iM;
	generate for(N=0; N<NM; N=N+1)
	begin : DECODE_REQUEST
		reg	none_sel;

		always @(*)
		begin
			none_sel = !m_stb[N];
			for(iM=0; iM<NS; iM=iM+1)
			begin

				none_sel = none_sel
					|| (((m_addr[N] ^ SADDR[iM*AW +: AW])
						&SMASK[iM*AW +: AW])==0);
			end


			none_sel = !none_sel;
		end

		always @(*)
		begin
			for(iM=0; iM<NS; iM=iM+1)
				request[N][iM] = m_stb[N]
					&&(((m_addr[N] ^ SADDR[iM*AW +: AW])
						&SMASK[iM*AW +: AW])==0);

			// Is this address non-existant?
			request[N][NS] = m_stb[N] && none_sel;
		end

		always @(*)
			m_cyc[N] = i_mcyc[N];
		always @(*)
		if (mfull[N])
			m_stb[N] = 1'b0;
		else if (mnearfull[N])
			m_stb[N] = i_mstb[N] && !r_stb[N];
		else
			m_stb[N] = i_mstb[N] || (i_mcyc[N] && r_stb[N]);
		always @(*)
			m_we[N]   = r_stb[N] ? r_we[N] : i_mwe[N];
		always @(*)
			m_addr[N] = r_stb[N] ? r_addr[N] : i_maddr[N*AW +: AW];
		always @(*)
			m_data[N] = r_stb[N] ? r_data[N] : i_mdata[N*DW +: DW];
		always @(*)
			m_sel[N]  = r_stb[N] ? r_sel[N]: i_msel[N*DW/8 +: DW/8];

	end for(N=NM; N<NMFULL; N=N+1)
	begin
		// in case NM isn't one less than a power of two, complete
		// the set
		always @(*)
			m_cyc[N] = 0;
		always @(*)
			m_stb[N] = 0;
		always @(*)
			m_we[N]   = 0;
		always @(*)
			m_addr[N] = 0;
		always @(*)
			m_data[N] = 0;
		always @(*)
			m_sel[N]  = 0;

	end endgenerate

	always @(*)
	begin
		for(iM=0; iM<NS; iM=iM+1)
		begin
			requested[0][iM] = 0;
			for(iN=1; iN<NM; iN=iN+1)
			requested[iN][iM]
				= (request[iN-1][iM] || requested[iN-1][iM]);
		end
	end

	generate for(M=0; M<NS; M=M+1)
	begin

		always @(*)
		begin
			sgrant[M] = 0;
			for(iN=0; iN<NM; iN=iN+1)
				if (grant[iN][M])
					sgrant[M] = 1;
		end

		always @(*)
			s_data[M]  = i_sdata[M*DW +: DW];
		always @(*)
			s_stall[M] = o_sstb[M] && i_sstall[M];
		always @(*)
			s_ack[M]   = o_scyc[M] && i_sack[M];
		always @(*)
			s_err[M]   = o_scyc[M] && i_serr[M];
	end for(M=NS; M<NSFULL; M=M+1)
	begin

		always @(*)
			s_data[M]  = 0;
		always @(*)
			s_stall[M] = 1;
		always @(*)
			s_ack[M]   = 0;
		always @(*)
			s_err[M]   = 1;
		// always @(*) sgrant[M]  = 0;

	end endgenerate

	//
	// Arbitrate among masters to determine who gets to access a given
	// channel
	generate for(N=0; N<NM; N=N+1)
	begin : ARBITRATE_REQUESTS

		// This is done using a couple of variables.
		//
		// request[N][M]
		//	This is true if master N is requesting to access slave
		//	M.  It is combinatorial, so it will be true if the
		//	request is being made on the current clock.
		//
		// requested[N][M]
		//	True if some other master, prior to N, has requested
		//	channel M.  This creates a basic priority arbiter,
		//	such that lower numbered masters have access before
		//	a greater numbered master
		//
		// grant[N][M]
		//	True if a grant has been made for master N to access
		//	slave channel M
		//
		// mgrant[N]
		//	True if master N has been granted access to some slave
		//	channel, any channel.
		//
		// mindex[N]
		//	This is the number of the slave channel that master
		//	N has been given access to
		//
		// sgrant[M]
		//	True if there exists some master, N, that has been
		// 	granted access to this slave, hence grant[N][M] must
		//	also be true
		//
		// sindex[M]
		//	This is the index of the master that has access to
		//	slave M, assuming sgrant[M].  Hence, if sgrant[M]
		//	then grant[sindex[M]][M] must be true
		//
		reg	stay_on_channel;

		always @(*)
		begin
			stay_on_channel = 0;
			for(iM=0; iM<NS; iM=iM+1)
			begin
				if (request[N][iM] && grant[N][iM])
					stay_on_channel = 1;
			end
		end

		reg	requested_channel_is_available;

		always @(*)
		begin
			requested_channel_is_available = 0;
			for(iM=0; iM<NS; iM=iM+1)
			begin
				if (request[N][iM] && !sgrant[iM]
						&& !requested[N][iM])
					requested_channel_is_available = 1;
			end
		end

		initial	grant[N] = 0;
		initial	mgrant[N] = 0;
		always @(posedge i_clk)
		if (i_reset || !i_mcyc[N])
		begin
			grant[N] <= 0;
			mgrant[N] <= 0;
		end else if (!mgrant[N] || mempty[N])
		begin
			if (stay_on_channel)
				mgrant[N] <= 1'b1;
			else if (requested_channel_is_available)
				mgrant[N] <= 1'b1;
			else if (i_mstb[N] || r_stb[N])
				mgrant[N] <= 1'b0;

			for(iM=0; iM<NS; iM=iM+1)
			begin

				if (request[N][iM] && grant[N][iM])
					// Maintain any open channels
					grant[N][iM] <= 1;
				else if (request[N][iM] && !sgrant[iM]
						&& !requested[N][iM])
					// Open a new channel if necessary
					grant[N][iM] <= 1;
				else if (i_mstb[N] || r_stb[N])
					grant[N][iM] <= 0;

			end
			if (request[N][NS])
			begin
				grant[N][NS] <= 1'b1;
				mgrant[N] <= 1'b1;
			end else begin
				grant[N][NS] <= 1'b0;
				if (grant[N][NS])
					mgrant[N] <= 1'b1;
			end
		end

		if (NS == 1)
		begin

			always @(*)
				mindex[N] = 0;

		end else begin

			always @(posedge i_clk)
			if (!mgrant[N] || mempty[N])
			begin

				for(iM=0; iM<NS; iM=iM+1)
				begin
					if (request[N][iM] && grant[N][iM])
					begin
						// Maintain any open channels
						mindex[N] <= iM;
					end else if (request[N][iM]
							&& !sgrant[iM]
							&& !requested[N][iM])
					begin
						// Open a new channel
						// if necessary
						mindex[N] <= iM;
					end
				end
			end
		end

	end for (N=NM; N<NMFULL; N=N+1)
	begin

		always @(*)
			mindex[N] = 0;

	end endgenerate

	// Calculate sindex.  sindex[M] (indexed by slave ID)
	// references the master controlling this slave.  This makes for
	// faster/cheaper logic on the return path, since we can now use
	// a fully populated LUT rather than a priority based return scheme
	generate for(M=0; M<NS; M=M+1)
	begin

		if (NM <= 1)
		begin

			// If there will only ever be one master, then we
			// can assume all slave indexes point to that master
			always @(*)
				sindex[M] = 0;

		end else begin : SINDEX_MORE_THAN_ONE_MASTER

			always @(posedge i_clk)
			for (iN=0; iN<NM; iN=iN+1)
			begin
				if (!mgrant[iN] || mempty[iN])
				begin
					if (request[iN][M] && grant[iN][M])
						sindex[M] <= iN;
					else if (request[iN][M] && !sgrant[M]
							&& !requested[iN][M])
						sindex[M] <= iN;
				end
			end
		end

	end for(M=NS; M<NSFULL; M=M+1)
	begin
		// Assign the unused slave indexes to zero
		//
		// Remember, to full out a full 2^something set of slaves,
		// we may have more slave indexes than we actually have slaves

		always @(*)
			sindex[M] = 0;

	end endgenerate


	//
	// Assign outputs to the slaves, part one
	//
	// In this part, we assign the difficult outputs: o_scyc and o_sstb
	generate for(M=0; M<NS; M=M+1)
	begin

		initial	o_scyc[M] = 0;
		initial	o_sstb[M] = 0;
		always @(posedge i_clk)
		begin
			if (sgrant[M])
			begin

				if (!i_mcyc[sindex[M]])
				begin
					o_scyc[M] <= 1'b0;
					o_sstb[M] <= 1'b0;
				end else begin
					o_scyc[M] <= 1'b1;

					if (!s_stall[M])
						o_sstb[M] <= m_stb[sindex[M]]
						  && request[sindex[M]][M]
						  && !mnearfull[sindex[M]];
				end
			end else begin
				o_scyc[M]  <= 1'b0;
				o_sstb[M]  <= 1'b0;
			end

			if (i_reset || s_err[M])
			begin
				o_scyc[M] <= 1'b0;
				o_sstb[M] <= 1'b0;
			end
		end
	end endgenerate

	//
	// Assign outputs to the slaves, part two
	//
	// These are the easy(er) outputs, since there are fewer properties
	// riding on them
	generate if ((NM == 1) && (!OPT_LOWPOWER))
	begin
		//
		// This is the low logic version of our bus data outputs.
		// It only works if we only have one master.
		//
		// The basic idea here is that we share all of our bus outputs
		// between all of the various slaves.  Since we only have one
		// bus master, this works.
		//
		always @(posedge i_clk)
		begin
			o_swe[0]        <= o_swe[0];
			o_saddr[0+: AW] <= o_saddr[0+:AW];
			o_sdata[0+: DW] <= o_sdata[0+:DW];
			o_ssel[0+:DW/8] <=o_ssel[0+:DW/8];

			if (sgrant[mindex[0]] && !s_stall[mindex[0]])
			begin
				o_swe[0]        <= m_we[0];
				o_saddr[0+: AW] <= m_addr[0];
				o_sdata[0+: DW] <= m_data[0];
				o_ssel[0+:DW/8] <= m_sel[0];
			end
		end

		for(M=1; M<NS; M=M+1)
		always @(*)
		begin
			o_swe[M]            = o_swe[0];
			o_saddr[M*AW +: AW] = o_saddr[0 +: AW];
			o_sdata[M*DW +: DW] = o_sdata[0 +: DW];
			o_ssel[M*DW/8+:DW/8]= o_ssel[0 +: DW/8];
		end

	end else for(M=0; M<NS; M=M+1)
	begin
		always @(posedge i_clk)
		begin
			if (OPT_LOWPOWER && !sgrant[M])
			begin
				o_swe[M]              <= 1'b0;
				o_saddr[M*AW   +: AW] <= 0;
				o_sdata[M*DW   +: DW] <= 0;
				o_ssel[M*(DW/8)+:DW/8]<= 0;
			end else if (!s_stall[M]) begin
				o_swe[M]              <= m_we[sindex[M]];
				o_saddr[M*AW   +: AW] <= m_addr[sindex[M]];
				if (OPT_LOWPOWER && !m_we[sindex[M]])
					o_sdata[M*DW   +: DW] <= 0;
				else
					o_sdata[M*DW   +: DW] <= m_data[sindex[M]];
				o_ssel[M*(DW/8)+:DW/8]<= m_sel[sindex[M]];
			end

		end
	end endgenerate

	//
	// Assign return values to the masters
	generate if (OPT_DBLBUFFER)
	begin : DOUBLE_BUFFERRED_STALL

		for(N=0; N<NM; N=N+1)
		begin
			initial	o_mstall[N] = 0;
			initial	o_mack[N]   = 0;
			initial	o_merr[N]   = 0;
			always @(posedge i_clk)
			begin
				iM = mindex[N];
				o_mstall[N] <= o_mstall[N]
						|| (i_mstb[N] && !o_mstall[N]);
				o_mack[N]   <= mgrant[N] && s_ack[mindex[N]];
				o_merr[N]   <= mgrant[N] && s_err[mindex[N]];
				if (OPT_LOWPOWER && !mgrant[N])
					o_mdata[N*DW +: DW] <= 0;
				else
					o_mdata[N*DW +: DW] <= s_data[mindex[N]];

				if (mgrant[N])
				begin
					if ((i_mstb[N]||o_mstall[N])
								&& mnearfull[N])
						o_mstall[N] <= 1'b1;
					else if ((i_mstb[N] || o_mstall[N])
							&& !request[N][iM])
						// Requesting another channel
						o_mstall[N] <= 1'b1;
					else if (!s_stall[iM])
						// Downstream channel is clear
						o_mstall[N] <= 1'b0;
					else // if (o_sstb[mindex[N]]
						//   && i_sstall[mindex[N]])
						// Downstream channel is stalled
						o_mstall[N] <= i_mstb[N];
				end

				if (mnearfull[N] && i_mstb[N])
					o_mstall[N] <= 1'b1;

				if ((o_mstall[N] && grant[N][NS])
					||(timed_out[N] && !o_mack[N]))
				begin
					o_mstall[N] <= 1'b0;
					o_mack[N]   <= 1'b0;
					o_merr[N]   <= 1'b1;
				end

				if (i_reset || !i_mcyc[N])
				begin
					o_mstall[N] <= 1'b0;
					o_mack[N]   <= 1'b0;
					o_merr[N]   <= 1'b0;
				end
			end

			always @(*)
				r_stb[N] = o_mstall[N];

			always @(posedge i_clk)
			if (OPT_LOWPOWER && !i_mcyc[N])
			begin
				r_we[N]   <= 0;
				r_addr[N] <= 0;
				r_data[N] <= 0;
				r_sel[N]  <= 0;
			end else if ((!OPT_LOWPOWER || i_mstb[N]) && !o_mstall[N])
			begin
				r_we[N]   <= i_mwe[N];
				r_addr[N] <= i_maddr[N*AW +: AW];
				r_data[N] <= i_mdata[N*DW +: DW];
				r_sel[N]  <= i_msel[N*(DW/8) +: DW/8];
			end
		end

		for(N=NM; N<NMFULL; N=N+1)
		begin

			always @(*)
				r_stb[N] <= 1'b0;

			always @(*)
			begin
				r_we[N]   = 0;
				r_addr[N] = 0;
				r_data[N] = 0;
				r_sel[N]  = 0;
			end
		end


	end else if (NS == 1) // && !OPT_DBLBUFFER
	begin : SINGLE_SLAVE

		for(N=0; N<NM; N=N+1)
		begin
			always @(*)
			begin
				o_mstall[N] = !mgrant[N] || s_stall[0]
					|| (i_mstb[N] && !request[N][0]);
				o_mack[N]   =  mgrant[N] && i_sack[0];
				o_merr[N]   =  mgrant[N] && i_serr[0];
				o_mdata[N*DW +: DW]  = (!mgrant[N] && OPT_LOWPOWER)
					? 0 : i_sdata;

				if (mnearfull[N])
					o_mstall[N] = 1'b1;

				if (timed_out[N]&&!o_mack[0])
				begin
					o_mstall[N] = 1'b0;
					o_mack[N]   = 1'b0;
					o_merr[N]   = 1'b1;
				end

				if (grant[N][NS] && m_stb[N])
				begin
					o_mstall[N] = 1'b0;
					o_mack[N]   = 1'b0;
					o_merr[N]   = 1'b1;
				end

				if (!m_cyc[N])
				begin
					o_mack[N] = 1'b0;
					o_merr[N] = 1'b0;
				end
			end
		end

		for(N=0; N<NMFULL; N=N+1)
		begin

			always @(*)
				r_stb[N] <= 1'b0;

			always @(*)
			begin
				r_we[N]   = 0;
				r_addr[N] = 0;
				r_data[N] = 0;
				r_sel[N]  = 0;
			end
		end

	end else begin : SINGLE_BUFFER_STALL
		for(N=0; N<NM; N=N+1)
		begin
			// initial	o_mstall[N] = 0;
			// initial	o_mack[N]   = 0;
			always @(*)
			begin
				o_mstall[N] = 1;
				o_mack[N]   = mgrant[N] && s_ack[mindex[N]];
				o_merr[N]   = mgrant[N] && s_err[mindex[N]];
				if (OPT_LOWPOWER && !mgrant[N])
					o_mdata[N*DW +: DW] = 0;
				else
					o_mdata[N*DW +: DW] = s_data[mindex[N]];

				if (mgrant[N])
				begin
					iM = mindex[N];
					o_mstall[N]       = (s_stall[mindex[N]])
					    || (i_mstb[N] && !request[N][iM]);
				end

				if (mnearfull[N])
					o_mstall[N] = 1'b1;

				if (grant[N][NS] ||(timed_out[N]&&!o_mack[0]))
				begin
					o_mstall[N] = 1'b0;
					o_mack[N]   = 1'b0;
					o_merr[N]   = 1'b1;
				end

				if (!m_cyc[N])
				begin
					o_mack[N] = 1'b0;
					o_merr[N] = 1'b0;
				end
			end
		end

		for(N=0; N<NMFULL; N=N+1)
		begin

			always @(*)
				r_stb[N] <= 1'b0;

			always @(*)
			begin
				r_we[N]   = 0;
				r_addr[N] = 0;
				r_data[N] = 0;
				r_sel[N]  = 0;
			end
		end

	end endgenerate

	//
	// Count the pending transactions per master
	generate for(N=0; N<NM; N=N+1)
	begin
		reg	[LGMAXBURST-1:0]	lclpending;
		initial	lclpending  = 0;
		initial	mempty[N]    = 1;
		initial	mnearfull[N] = 0;
		initial	mfull[N]     = 0;
		always @(posedge i_clk)
		if (i_reset || !i_mcyc[N] || o_merr[N])
		begin
			lclpending <= 0;
			mfull[N]    <= 0;
			mempty[N]   <= 1'b1;
			mnearfull[N]<= 0;
		end else case({ (i_mstb[N] && !o_mstall[N]), o_mack[N] })
		2'b01: begin
			lclpending <= lclpending - 1'b1;
			mnearfull[N]<= mfull[N];
			mfull[N]    <= 1'b0;
			mempty[N]   <= (lclpending == 1);
			end
		2'b10: begin
			lclpending <= lclpending + 1'b1;
			mnearfull[N]<= (&lclpending[LGMAXBURST-1:2])&&(lclpending[1:0] != 0);
			mfull[N]    <= mnearfull[N];
			mempty[N]   <= 1'b0;
			end
		default: begin end
		endcase

		assign w_mpending[N] = lclpending;

	end endgenerate


	generate if (OPT_TIMEOUT > 0)
	begin : CHECK_TIMEOUT

		for(N=0; N<NM; N=N+1)
		begin

			reg	[TIMEOUT_WIDTH-1:0]	deadlock_timer;

			initial	deadlock_timer = OPT_TIMEOUT;
			initial	timed_out[N] = 1'b0;
			always @(posedge i_clk)
			if (i_reset || !i_mcyc[N]
					||((w_mpending[N] == 0)
						&&(!i_mstb[N] && !r_stb[N]))
					||((i_mstb[N] || r_stb[N])
						&&(!o_mstall[N]))
					||(o_mack[N] || o_merr[N])
					||(!OPT_STARVATION_TIMEOUT&&!mgrant[N]))
			begin
				deadlock_timer <= OPT_TIMEOUT;
				timed_out[N] <= 0;
			end else if (deadlock_timer > 0)
			begin
				deadlock_timer <= deadlock_timer - 1;
				timed_out[N] <= (deadlock_timer <= 1);
			end

			assign	w_deadlock_timer[N] = deadlock_timer;
		end

	end else begin

		always @(*)
			timed_out = 0;

	end endgenerate

`ifdef	FORMAL
	localparam	F_MAX_DELAY = 4;
	localparam	F_LGDEPTH = LGMAXBURST;
	//
	reg			f_past_valid;
	//
	// Our bus checker keeps track of the number of requests,
	// acknowledgments, and the number of outstanding transactions on
	// every channel, both the masters driving us
	wire	[F_LGDEPTH-1:0]	f_mreqs		[0:NM-1];
	wire	[F_LGDEPTH-1:0]	f_macks		[0:NM-1];
	wire	[F_LGDEPTH-1:0]	f_moutstanding	[0:NM-1];
	//
	// as well as the slaves that we drive ourselves
	wire	[F_LGDEPTH-1:0]	f_sreqs		[0:NS-1];
	wire	[F_LGDEPTH-1:0]	f_sacks		[0:NS-1];
	wire	[F_LGDEPTH-1:0]	f_soutstanding	[0:NS-1];


	initial	assert(!OPT_STARVATION_TIMEOUT || OPT_TIMEOUT > 0);

	reg	f_past_valid;
	initial	f_past_valid = 0;
	always @(posedge i_clk)
		f_past_valid = 1'b1;

	always @(*)
	if (!f_past_valid)
		assume(i_reset);

	generate for(N=0; N<NM; N=N+1)
	begin
		always @(*)
		if (f_past_valid)
		for(iN=N+1; iN<NM; iN=iN+1)
			// Can't grant the same channel to two separate
			// masters.  This applies to all but the error or
			// no-slave-selected channel
			assert((grant[N][NS-1:0] & grant[iN][NS-1:0])==0);

		for(M=1; M<=NS; M=M+1)
		begin
			// Can't grant two channels to the same master
			always @(*)
			if (f_past_valid && grant[N][M])
				assert(grant[N][M-1:0] == 0);
		end


		always @(*)
		if (&w_mpending[N])
			assert(o_merr[N] || o_mstall[N]);

		reg	checkgrant;
		always @(*)
		if (f_past_valid)
		begin
			checkgrant = 0;
			for(iM=0; iM<NS; iM=iM+1)
				if (grant[N][iM])
					checkgrant = 1;
			if (grant[N][NS])
				checkgrant = 1;

			assert(checkgrant == mgrant[N]);
		end

	end endgenerate

	// Double check the grant mechanism and its dependent variables
	generate for(N=0; N<NM; N=N+1)
	begin

		for(M=0; M<NS; M=M+1)
		begin
			always @(*)
			if ((f_past_valid)&&grant[N][M])
			begin
				assert(mgrant[N]);
				assert(mindex[N] == M);
				assert(sindex[M] == N);
			end
		end
	end endgenerate

	// Double check the timeout flags for consistency
	generate for(N=0; N<NM; N=N+1)
	begin
		always @(*)
		if (f_past_valid)
		begin
			assert(mempty[N] == (w_mpending[N] == 0));
			assert(mnearfull[N]==(&w_mpending[N][LGMAXBURST-1:1]));
			assert(mfull[N] == (&w_mpending[N]));
		end
	end endgenerate

`ifdef	VERIFIC
	//
	// The Verific parser is currently broken, and doesn't allow
	// initial assumes or asserts.  The following lines get us around that
	//
	always @(*)
	if (!f_past_valid)
		assume(sgrant == 0);

	generate for(M=0; M<NS; M=M+1)
	begin
		always @(*)
		if (!f_past_valid)
		begin
			assume(o_scyc[M] == 0);
			assume(o_sstb[M] == 0);
		end
	end endgenerate

	generate for(N=0; N<NM; N=N+1)
	begin
		always @(*)
		if (!f_past_valid)
		begin
			assume(grant[N] == 0);
			assume(mgrant[N] == 0);
		end
	end
`endif

	////////////////////////////////////////////////////////////////////////
	//
	//	BUS CHECK
	//
	// Verify that every channel, whether master or slave, follows the rules
	// of the WB road.
	//
	////////////////////////////////////////////////////////////////////////
	generate for(N=0; N<NM; N=N+1)
	begin : WB_SLAVE_CHECK

		fwb_slave #(
			.AW(AW), .DW(DW),
			.F_LGDEPTH(LGMAXBURST),
			.F_MAX_ACK_DELAY(0),
			.F_MAX_STALL(0)
			) slvi(i_clk, i_reset,
				i_mcyc[N], i_mstb[N], i_mwe[N],
				i_maddr[N*AW +: AW], i_mdata[N*DW +: DW],					i_msel[N*(DW/8) +: (DW/8)],
			o_mack[N], o_mstall[N], o_mdata[N*DW +: DW], o_merr[N],
			f_mreqs[N], f_macks[N], f_moutstanding[N]);

		always @(*)
		if ((f_past_valid)&&(grant[N][NS]))
			assert(f_moutstanding[N] <= 1);

		always @(*)
		if ((f_past_valid)&&(grant[N][NS] && i_mcyc[N]))
			assert(o_mstall[N] || o_merr[N]);

	end endgenerate

	generate for(M=0; M<NS; M=M+1)
	begin : WB_MASTER_CHECK
		fwb_master #(
			.AW(AW), .DW(DW),
			.F_LGDEPTH(LGMAXBURST),
			.F_MAX_ACK_DELAY(F_MAX_DELAY),
			.F_MAX_STALL(2)
			) mstri(i_clk, i_reset,
				o_scyc[M], o_sstb[M], o_swe[M],
				o_saddr[M*AW +: AW], o_sdata[M*DW +: DW],
				o_ssel[M*(DW/8) +: (DW/8)],
			i_sack[M], i_sstall[M], s_data[M], i_serr[M],
			f_sreqs[M], f_sacks[M], f_soutstanding[M]);
	end endgenerate

	////////////////////////////////////////////////////////////////////////
	//
	////////////////////////////////////////////////////////////////////////
	generate for(N=0; N<NM; N=N+1)
	begin : CHECK_OUTSTANDING

		always @(posedge i_clk)
		if (i_mcyc[N])
			assert(f_moutstanding[N] == w_mpending[N]);

		reg	[LGMAXBURST:0]	n_outstanding;
		always @(*)
		if (i_mcyc[N])
			assert(f_moutstanding[N] >=
				(o_mstall[N] && OPT_DBLBUFFER) ? 1:0
				+ (o_mack[N] && OPT_DBLBUFFER) ? 1:0);

		always @(*)
			n_outstanding = f_moutstanding[N]
				- ((o_mstall[N] && OPT_DBLBUFFER) ? 1:0)
				- ((o_mack[N] && OPT_DBLBUFFER) ? 1:0);
		always @(posedge i_clk)
		if (i_mcyc[N] && !mgrant[N] && !o_merr[N])
			assert(f_moutstanding[N]
					== (o_mstall[N]&&OPT_DBLBUFFER ? 1:0));
		else if (i_mcyc[N] && mgrant[N])
		for(iM=0; iM<NS; iM=iM+1)
		if (grant[N][iM] && o_scyc[iM] && !i_serr[iM] && !o_merr[N])
			assert(n_outstanding
				== {1'b0,f_soutstanding[iM]}+(o_sstb[iM] ? 1:0));

		always @(*)
		if (i_mcyc[N] && r_stb[N] && OPT_DBLBUFFER)
			assume(i_mwe[N] == r_we[N]);

		always @(*)
		if (!OPT_DBLBUFFER && !mnearfull[N])
			assert(i_mstb[N] == m_stb[N]);

		always @(*)
		if (!OPT_DBLBUFFER)
			assert(i_mwe[N] == m_we[N]);

		always @(*)
		for(iM=0; iM<NS; iM=iM+1)
		if (grant[N][iM] && i_mcyc[N])
		begin
			if (f_soutstanding[iM] > 0)
				assert(i_mwe[N] == o_swe[iM]);
			if (o_sstb[iM])
				assert(i_mwe[N] == o_swe[iM]);
			if (o_mack[N])
				assert(i_mwe[N] == o_swe[iM]);
			if (o_scyc[iM] && i_sack[iM])
				assert(i_mwe[N] == o_swe[iM]);
			if (o_merr[N] && !timed_out[N])
				assert(i_mwe[N] == o_swe[iM]);
			if (o_scyc[iM] && i_serr[iM])
				assert(i_mwe[N] == o_swe[iM]);
		end

	end endgenerate

	generate for(M=0; M<NS; M=M+1)
	begin
		always @(posedge i_clk)
		if (!$past(sgrant[M]))
			assert(!o_scyc[M]);
	end endgenerate

	////////////////////////////////////////////////////////////////////////
	//
	//	CONTRACT SECTION
	//
	// Here's the contract, in two parts:
	//
	//	1. Should ever a master (any master) wish to read from a slave
	//		(any slave), he should be able to read a known value
	//		from that slave (any value) from any arbitrary address
	//		he might wish to read from (any address)
	//
	//	2. Should ever a master (any master) wish to write to a slave
	//		(any slave), he should be able to write the exact
	//		value he wants (any value) to the exact address he wants
	//		(any address)
	//
	//	special_master	is an arbitrary constant chosen by the solver,
	//		which can reference *any* possible master
	//	special_address	is an arbitrary constant chosen by the solver,
	//		which can reference *any* possible address the master
	//		might wish to access
	//	special_value	is an arbitrary value (at least during
	//		induction) representing the current value within the
	//		slave at the given address
	//
	//
	////////////////////////////////////////////////////////////////////////
	//
	// Now let's pay attention to a special bus master and a special
	// address referencing a special bus slave.  We'd like to assert
	// that we can access the values of every slave from every master.
	(* anyconst *) reg	[(NM<=1)?0:(LGNM-1):0]	special_master;
			reg	[(NS<=1)?0:(LGNS-1):0]	special_slave;
	(* anyconst *) reg	[AW-1:0]	special_address;
			reg	[DW-1:0]	special_value;

	always @(*)
	if (NM <= 1)
		assume(special_master == 0);
	always @(*)
	if (NS <= 1)
		assume(special_slave == 0);

	//
	// Decode the special address to discover the slave associated with it
	always @(*)
	begin
		special_slave = NS;
		for(iM=0; iM<NS; iM = iM+1)
		begin
			if (((special_address ^ SADDR[iM*AW +: AW])
					&SMASK[iM*AW +: AW]) == 0)
				special_slave = iM;
		end
	end

	generate if (NS > 1)
	begin : DOUBLE_ADDRESS_CHECK
		//
		// Check that no slave address has been assigned twice.
		// This check only needs to be done once at the beginning
		// of the run, during the BMC section.
		reg	address_found;

		always @(*)
		if (!f_past_valid)
		begin
			address_found = 0;
			for(iM=0; iM<NS; iM = iM+1)
			begin
				if (((special_address ^ SADDR[iM*AW +: AW])
						&SMASK[iM*AW +: AW]) == 0)
				begin
					assert(address_found == 0);
					address_found = 1;
				end
			end
		end

	end endgenerate
	//
	// Let's assume this slave will acknowledge any request on the next
	// bus cycle after the stall goes low.  Further, lets assume that
	// it never creates an error, and that it always responds to our special
	// address with the special data value given above.  To do this, we'll
	// also need to make certain that the special value will change
	// following any write.
	//
	// These are the "assumptions" associated with our fictitious slave.
	initial	assume(special_value == 0);
	always @(posedge i_clk)
	if (special_slave < NS)
	begin
		if ($past(o_sstb[special_slave] && !i_sstall[special_slave]))
		begin
			assume(i_sack[special_slave]);

			if ($past(!o_swe[special_slave])
					&&($past(o_saddr[special_slave*AW +: AW]) == special_address))
				assume(i_sdata[special_slave*DW+: DW]
						== special_value);
		end else
			assume(!i_sack[special_slave]);
		assume(!i_serr[special_slave]);

		if (o_scyc[special_slave])
			assert(f_soutstanding[special_slave]
				== i_sack[special_slave]);

		if (o_sstb[special_slave] && !i_sstall[special_slave]
			&& o_swe[special_slave])
		begin
			for(iM=0; iM < DW/8; iM=iM+1)
			if (o_ssel[special_slave * DW/8 + iM])
				special_value[iM*8 +: 8] <= o_sdata[special_slave * DW + iM*8 +: 8];
		end
	end

	//
	// Now its time to make some assertions.  Specifically, we want to
	// assert that any time we read from this special slave, the special
	// value is returned.
	reg	[2:0]	read_seq;
	initial	read_seq = 0;
	always @(posedge i_clk)
	if ((special_master < NM)&&(special_slave < NS)
			&&(i_mcyc[special_master])
			&&(!timed_out[special_master]))
	begin
		read_seq <= 0;
		if ((grant[special_master][special_slave])
			&&(m_stb[special_master])
			&&(m_addr[special_master] == special_address)
			&&(!m_we[special_master])
			)
		begin
			read_seq[0] <= 1;
		end

		if (|read_seq)
		begin
			assert(grant[special_master][special_slave]);
			assert(mgrant[special_master]);
			assert(sgrant[special_slave]);
			assert(mindex[special_master] == special_slave);
			assert(sindex[special_slave] == special_master);
			assert(!o_merr[special_master]);
		end

		if (read_seq[0] && !$past(s_stall[special_slave]))
		begin
			assert(o_scyc[special_slave]);
			assert(o_sstb[special_slave]);
			assert(!o_swe[special_slave]);
			assert(o_saddr[special_slave*AW +: AW] == special_address);

			read_seq[1] <= 1;

		end else if (read_seq[0] && $past(s_stall[special_slave]))
		begin
			assert($stable(m_stb[special_master]));
			assert(!m_we[special_master]);
			assert(m_addr[special_master] == special_address);

			read_seq[0] <= 1;
		end

		if (read_seq[1] && $past(s_stall[special_slave]))
		begin
			assert(o_scyc[special_slave]);
			assert(o_sstb[special_slave]);
			assert(!o_swe[special_slave]);
			assert(o_saddr[special_slave*AW +: AW] == special_address);
			read_seq[1] <= 1;
		end else if (read_seq[1] && !$past(s_stall[special_slave]))
		begin
			assert(i_sack[special_slave]);
			assert(i_sdata[special_slave*DW +: DW] == $past(special_value));
			if (OPT_DBLBUFFER)
				read_seq[2] <= 1;
		end

		if (read_seq[2] || ((!OPT_DBLBUFFER)&&read_seq[1]
					&& !$past(s_stall[special_slave])))
		begin
			assert(o_mack[special_master]);
			assert(o_mdata[special_master * DW +: DW]
				== $past(special_value,2));
		end
	end else
		read_seq <= 0;

	//
	// Let's try a write assertion now.  Specifically, on any request to
	// write to our special address, we want to assert that the special
	// value at that address can be written.
	reg	[2:0]	write_seq;
	initial	write_seq = 0;
	always @(posedge i_clk)
	if ((special_master < NM)&&(special_slave < NS)
			&&(i_mcyc[special_master])
			&&(!timed_out[special_master]))
	begin
		write_seq <= 0;
		if ((grant[special_master][special_slave])
			&&(m_stb[special_master])
			&&(m_addr[special_master] == special_address)
			&&(m_we[special_master]))
		begin
			// Our write sequence begins when our special master
			// has access to the bus, *and* he is trying to write
			// to our special address.
			write_seq[0] <= 1;
		end

		if (|write_seq)
		begin
			assert(grant[special_master][special_slave]);
			assert(mgrant[special_master]);
			assert(sgrant[special_slave]);
			assert(mindex[special_master] == special_slave);
			assert(sindex[special_slave] == special_master);
			assert(!o_merr[special_master]);
		end

		if (write_seq[0] && !$past(s_stall[special_slave]))
		begin
			assert(o_scyc[special_slave]);
			assert(o_sstb[special_slave]);
			assert(o_swe[special_slave]);
			assert(o_saddr[special_slave*AW +: AW] == special_address);
			assert(o_sdata[special_slave*DW +: DW]
				== $past(m_data[special_master]));
			assert(o_ssel[special_slave*DW/8 +: DW/8]
				== $past(m_sel[special_master]));

			write_seq[1] <= 1;

		end else if (write_seq[0] && $past(s_stall[special_slave]))
		begin
			assert($stable(m_stb[special_master]));
			assert(m_we[special_master]);
			assert(m_addr[special_master] == special_address);
			assert($stable(m_data[special_master]));
			assert($stable(m_sel[special_master]));

			write_seq[0] <= 1;
		end

		if (write_seq[1] && $past(s_stall[special_slave]))
		begin
			assert(o_scyc[special_slave]);
			assert(o_sstb[special_slave]);
			assert(o_swe[special_slave]);
			assert(o_saddr[special_slave*AW +: AW] == special_address);
			assert($stable(o_sdata[special_slave*DW +: DW]));
			assert($stable(o_ssel[special_slave*DW/8 +: DW/8]));
			write_seq[1] <= 1;
		end else if (write_seq[1] && !$past(s_stall[special_slave]))
		begin
			for(iM=0; iM<DW/8; iM=iM+1)
			begin
				if ($past(o_ssel[special_slave * DW/8 + iM]))
					assert(special_value[iM*8 +: 8]
						== $past(o_sdata[special_slave*DW+iM*8 +: 8]));
			end

			assert(i_sack[special_slave]);
			if (OPT_DBLBUFFER)
				write_seq[2] <= 1;
		end

		if (write_seq[2] || ((!OPT_DBLBUFFER)&&write_seq[1]
					&& !$past(s_stall[special_slave])))
			assert(o_mack[special_master]);
	end else
		write_seq <= 0;

`endif
endmodule
