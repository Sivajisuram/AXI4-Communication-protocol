`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 16:42:22
// Design Name: 
// Module Name: tb_axi_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module tb_axi_top;

reg clk = 0;
reg rst;

always #5 clk = ~clk;


// INPUTS
reg start_write;
reg start_read;
reg [31:0] base_write_addr;
reg [31:0] base_read_addr;
reg [31:0] write_data;
reg [7:0]  burst_len;
reg [2:0]  burst_size;
reg [1:0]  burst_type;

wire done;
wire error;


// DUT
axi_top DUT (
    .clk(clk),
    .rst(rst),
    .start_write(start_write),
    .start_read(start_read),
    .base_write_addr(base_write_addr),
    .base_read_addr(base_read_addr),
    .write_data(write_data),
    .burst_len(burst_len),
    .burst_size(burst_size),
    .burst_type(burst_type),
    .done(done),
    .error(error)
);


// ================= MONITORS =================

// WRITE ADDRESS HANDSHAKE
always @(posedge clk)
if(DUT.AWVALID && DUT.AWREADY)
    $display("[%0t] MASTER -> SLAVE : WRITE ADDR = %h LEN=%0d BURST=%b",
              $time, DUT.AWADDR, DUT.AWLEN, DUT.AWBURST);


// WRITE DATA HANDSHAKE
always @(posedge clk)
if(DUT.WVALID && DUT.WREADY)
    $display("[%0t] MASTER -> SLAVE : WRITE DATA = %h WLAST=%b",
              $time, DUT.WDATA, DUT.WLAST);


// WRITE RESPONSE
always @(posedge clk)
if(DUT.BVALID && DUT.BREADY)
    $display("[%0t] SLAVE  -> MASTER: WRITE RESP = %b",
              $time, DUT.BRESP);


// READ ADDRESS HANDSHAKE
always @(posedge clk)
if(DUT.ARVALID && DUT.ARREADY)
    $display("[%0t] MASTER -> SLAVE : READ ADDR  = %h LEN=%0d BURST=%b",
              $time, DUT.ARADDR, DUT.ARLEN, DUT.ARBURST);


// READ DATA HANDSHAKE
always @(posedge clk)
if(DUT.RVALID && DUT.RREADY)
    $display("[%0t] SLAVE  -> MASTER: READ DATA  = %h RLAST=%b",
              $time, DUT.RDATA, DUT.RLAST);



// ================= TEST =================
initial
begin
    rst = 1;
    start_write = 0;
    start_read  = 0;

    #20 rst = 0;

    // WRITE TRANSACTION
    @(posedge clk);
    base_write_addr = 32'h20;
    write_data      = 32'hA0000000;
    burst_len       = 3;
    burst_size      = 3'b010;
    burst_type      = 2'b01;

    start_write = 1;
    @(posedge clk);
    start_write = 0;

    wait(done);

    #20;

    // READ TRANSACTION
    @(posedge clk);
    base_read_addr = 32'h20;
    burst_len      = 3;
    burst_size     = 3'b010;
    burst_type     = 2'b01;

    start_read = 1;
    @(posedge clk);
    start_read = 0;

    wait(done);
    
    #20;
  
    

    #100 $stop;
end

endmodule
