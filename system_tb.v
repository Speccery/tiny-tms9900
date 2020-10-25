// system_tb.v
// Started 2019-09-03
// test bench for my CPU

`timescale 1ns/1ns
module system_tb();

reg  clk=0, reset=1;
always #166 clk = !clk; // 3 MHz clock

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
wire nRAMCE = !addr[15];
wire nROMCE =  addr[15];
wire nACACE = !(addr[15:6]==0);
RAM      ram(clk, nRAMCE, !wr, addr[12:1], data_out, ram_o);
ROM      rom(clk, nROMCE,      addr[12:1], rom_o);
wire nrts; // , ncts;
reg ndsr = 0, ncts = 0;
reg rin = 1;
wire xout;
tms9902  aca(clk, nrts, ndsr, ncts, /*int*/, nACACE, cruout, cruin, cruclk, xout, rin, addr[5:1]);
// PNR tms9902  aca(clk, nrts, /*dsr*/, ncts, /*int*/, nACACE, cruout, cruin, cruclk, xout, rin, addr[5:1]);

assign data_in = (nROMCE) ? ram_o : rom_o;

initial begin
    $dumpfile("system_tb.vcd");
    $dumpvars(0, system_tb);

    #500 reset = 1'b0;

    #100000 // Give my CPU some time to get ready

    #40000 rin = 0;
    #20000 rin = 1;
    // #10000 rin = 1;
    
    #1200000

    #3000000 // Give my CPU some time to get ready
    // send(13);
    // #6000000
/*
    send("I");
    send("R");
    send(13);
    #1000000
    send(" ");
    #2000000
    send(" ");
    #2000000
    send(" ");
    #2000000
*/


  send("X");
  send("R");
  send("A");
  send(" ");
  #200000
  send("2");
  #200000
  send("2");  
  send("6");
  send(",");
  send("2");
  send("3");
  send("6");  // used to be up to 270
  send(13);
  #60000000


  // Test XA command to assemble a few instructions
     send("X");
    send("A");
    send(" ");
    #200000   // EP add
    send("8"); 
    send("0"); 
    send("0"); 
    send("0"); 
    send(13);
    #1900000

    send(" ");
    #1900000 // EP mode from 900000
    send("A");
    #1900000
    send("I");
    #1900000
    send(" ");
    #1900000

    send("R");
    #1900000
    send("0");
    #1900000
    send(",");
    #1900000
    send(">");
    #1900000
    send("1");
    #1900000
    send("0");
    #1900000
    send("0");
    #1900000
    send("0");
    #1900000
    send(13);
    #1900000

    send("L");
    #900000
    send(" ");
    #900000
    send("I");
    #900000
    send("D");
    #900000
    send("L");
    #900000
    send("E");
    #900000
    send(13);
    #900000


    $display("done");
    $display("total clocks: %d", $time);
    $finish;

end

// initial begin
//     @(negedge reset);    // wait for reset
//     repeat(16) @(posedge clk);
//     $display("display: t=%3d addr=%x", $time, addr);
//     repeat(1500) @(posedge clk);
//     $display("display: t=%3d addr=%x", $time, addr);
// //    $display("display: t=%3d i_arg1=%d i_arg2=%d alu_result=%d result=%d", $time, i_arg1, i_arg2, alu_result, result);
// //    $write(alu_result, int);
//     $finish;
// end

// initial begin
//     $monitor("t=%3d cpu_state=%d", $time, cpu_state);
// end

  always @(posedge clk)
  begin : uart_in
    reg [7:0] char;
    if (!xout) begin
      char = 0;
      #3000
      char[0] = xout;
      #2000
      char[1] = xout;
      #2002
      char[2] = xout;
      #2000
      char[3] = xout;
      #2000
      char[4] = xout;
      #2000
      char[5] = xout;
      #2000
      char[6] = xout;
      #4000
      $write("%c", char);
    end else
      #200;
  end


  reg last_cruclk, last_wr;

  // always @(posedge cruclk)
  // begin
  //   $display("cruclk addr=%04X data=%d", addr, cruout);
  // end

  // always @(negedge clk)
  // begin
  //    if(wr && !last_wr)
  //       $display("write addr=%04X data=%04X time=%4d", addr, data_out, $time);
  //    last_wr = wr;
  // end

  // always @(posedge clk)
  // begin
  //   // Here let's print all writes to memory
  //   if (wr==1 && last_wr == 0) begin
  //     $display("write addr=%04X data=%04X", addr, data_out);
  //   end
  //   if (cruclk==1 && last_cruclk == 0) begin
  //     $display("cruclk addr=%04X data=%d", addr, cruout);
  //   end
  //   last_wr = wr;
  //   last_cruclk = cruclk;
  // end

  task send;
    input  [7:0]  char;
  
    integer i;
    reg par;
    begin
      // $display("\nSend task: time=%4d %d %c", $time, char, char);
      rin = 0; #2000 par = 0;
      for(i=0; i<7; i=i+1) begin
        rin = char[i];
        par = par ^ rin;
        #2000;
      end
      rin = par; #2000;
      rin = 1; #260000;
    end
  endtask


endmodule