// top.v
// Started 2020-10-23
// Breadboard implementation for ICE40UP5K

module top(
	input gpio_23,
	output led_red,
	output led_green,
	output led_blue,
	output serial_txd,
	input serial_rxd,
	output spi_cs,
	output gpio_2
);

	assign spi_cs = 1; // it is necessary to turn off the SPI flash chip
	wire debug0 = gpio_2;

  // assign led_red   = 1'b1;
  assign led_green = 1'b1;
  // assign led_blue  = 1'b1;
  
  assign serial_txd = xout;
  wire rin, reset;
  assign  rin = serial_rxd;
  assign  reset = gpio_23;



  // Internal high frequency oscillator.
  // Parameter CLKHF_DIV = 2’b00 : 00 = div1, 01 = div2, 10 = div4, 11 = div8 ; Default = “00”
  wire clk_48;
	SB_HFOSC 
    #(.CLKHF_DIV("0b10"))  // Divide by 4 to get 12MHz
    // #(.CLKHF_DIV("0b11"))  // Divide by 8 to get 6MHz
    u_hfosc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(clk_48)    // 48 MHz high frequency clock
	);

wire clk;
assign clk = clk_48;

wire [15:0] addr, data_out;
wire [15:0] data_in;
wire rd, wr, rd_now, iaq, as;
reg cache_hit = 1'b0;
reg use_ready = 1'b0;
reg ready = 1'b0;
reg int_req = 1'b0;
reg [3:0] ic03 = 4'd2;
wire int_ack, cruclk, cruout, holda, stuck;
wire cruin;
reg hold = 1'b0;
reg [7:0] waits = 8'd0;
// wire [7:0] cpu_state, cpu_state_next, cpu_state_operand_return;

// Flash one of the LEDs with 1M IAQs
reg [19:0] counter;
reg last_iaq;
assign led_red = counter[18];
assign led_blue = !stuck; // LED lits when the assigned value is zero.

always @(posedge clk)
begin
  last_iaq <= iaq;
  if(!last_iaq && iaq)
    counter <= counter + 1;
end

wire [15:0] ir_out, pc_ir_out, pc_ir_out2;

tms9900 cpu(    
        clk, 
        reset,
        addr,
        data_in,
        data_out,
        rd, 
        wr, 
        rd_now,
        cache_hit,
        use_ready,
        ready,
        iaq, 
        as, 
        int_req,
        ic03,
        int_ack,
        cruin,
        cruout,
        cruclk,
        hold,
        holda,
        waits,
        stuck,
     ir_out,
    pc_ir_out,
    pc_ir_out2    // previous
);

// RAM and ROM from PNR's design
wire [15:0] rom_o, ram_o;
wire RAMCE = addr[15] & (wr | rd ); // active high
wire nROMCE =  addr[15];            // active low
wire nACACE = !(addr[15:6]==0);

spram_32k_16 ram( 
  .clk(clk),
  .reset(1'b0),
  .cs(RAMCE),
  .wren(wr),
  .addr(addr[14:1]),
  .write_data(data_out), 
  .read_data(ram_o)
);

// RAM      ram(clk, nRAMCE, !wr, addr[12:1], data_out, ram_o);
ROM      rom(clk, nROMCE,      addr[12:1], rom_o);
wire nrts; // , ncts;
reg ndsr = 0, ncts = 0;
wire xout;
tms9902  aca(clk, nrts, ndsr, ncts, /*int*/, nACACE, cruout, cruin, cruclk, xout, rin, addr[5:1]);

assign data_in = (nROMCE) ? ram_o : rom_o;


endmodule