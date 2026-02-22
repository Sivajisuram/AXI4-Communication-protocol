`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 16:40:02
// Design Name: 
// Module Name: axi_top
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


module axi_top(
    input clk,
    input rst,

    input start_write,
    input start_read,

    input [31:0] base_write_addr,
    input [31:0] base_read_addr,
    input [31:0] write_data,

    input [7:0]  burst_len,
    input [2:0]  burst_size,
    input [1:0]  burst_type,

    output done,
    output error
);

// AXI INTERCONNECT WIRES

wire [31:0] AWADDR;
wire [7:0]  AWLEN;
wire [2:0]  AWSIZE;
wire [1:0]  AWBURST;
wire        AWVALID;
wire        AWREADY;

wire [31:0] WDATA;
wire [3:0]  WSTRB;
wire        WVALID;
wire        WLAST;
wire        WREADY;

wire [1:0]  BRESP;
wire        BVALID;
wire        BREADY;

wire [31:0] ARADDR;
wire [7:0]  ARLEN;
wire [2:0]  ARSIZE;
wire [1:0]  ARBURST;
wire        ARVALID;
wire        ARREADY;

wire [31:0] RDATA;
wire [1:0]  RRESP;
wire        RVALID;
wire        RLAST;
wire        RREADY;


// MASTER INSTANCE

axi_master master_inst (
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
    .error(error),

    .AWADDR(AWADDR),
    .AWLEN(AWLEN),
    .AWSIZE(AWSIZE),
    .AWBURST(AWBURST),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),

    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WVALID(WVALID),
    .WLAST(WLAST),
    .WREADY(WREADY),

    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),

    .ARADDR(ARADDR),
    .ARLEN(ARLEN),
    .ARSIZE(ARSIZE),
    .ARBURST(ARBURST),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),

    .RDATA(RDATA),
    .RRESP(RRESP),
    .RVALID(RVALID),
    .RLAST(RLAST),
    .RREADY(RREADY)
);


// SLAVE INSTANCE

axi_slave slave_inst (
    .clk(clk),
    .rst(rst),

    .AWADDR(AWADDR),
    .AWLEN(AWLEN),
    .AWSIZE(AWSIZE),
    .AWBURST(AWBURST),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),

    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WVALID(WVALID),
    .WLAST(WLAST),
    .WREADY(WREADY),

    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),

    .ARADDR(ARADDR),
    .ARLEN(ARLEN),
    .ARSIZE(ARSIZE),
    .ARBURST(ARBURST),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),

    .RDATA(RDATA),
    .RRESP(RRESP),
    .RVALID(RVALID),
    .RLAST(RLAST),
    .RREADY(RREADY)
);

endmodule