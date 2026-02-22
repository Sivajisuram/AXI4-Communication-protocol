`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 16:38:07
// Design Name: 
// Module Name: axi_slave
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


module axi_slave(
    input clk,
    input rst,

    // WRITE ADDRESS CHANNEL
    input  [31:0] AWADDR,
    input  [7:0]  AWLEN,
    input  [2:0]  AWSIZE,
    input  [1:0]  AWBURST,
    input         AWVALID,
    output reg    AWREADY,

    // WRITE DATA CHANNEL
    input  [31:0] WDATA,
    input  [3:0]  WSTRB,     // NEW
    input         WVALID,
    input         WLAST,
    output reg    WREADY,

    // WRITE RESPONSE
    output reg [1:0] BRESP,
    output reg       BVALID,
    input            BREADY,

    // READ ADDRESS CHANNEL
    input  [31:0] ARADDR,
    input  [7:0]  ARLEN,
    input  [2:0]  ARSIZE,
    input  [1:0]  ARBURST,
    input         ARVALID,
    output reg    ARREADY,

    // READ DATA CHANNEL
    output reg [31:0] RDATA,
    output reg [1:0]  RRESP,   // NEW
    output reg        RVALID,
    output reg        RLAST,
    input             RREADY
);

reg [31:0] mem [0:255];

reg [31:0] wr_addr;
reg [31:0] rd_addr;
reg [7:0]  wr_count;
reg [7:0]  rd_count;

reg write_active;
reg read_active;

integer i;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        AWREADY <= 0;
        WREADY  <= 0;
        BVALID  <= 0;
        BRESP   <= 0;

        ARREADY <= 0;
        RVALID  <= 0;
        RLAST   <= 0;
        RRESP   <= 0;

        write_active <= 0;
        read_active  <= 0;

        for(i=0;i<256;i=i+1)
            mem[i] <= 0;
    end
    else
    begin

        //---------------- WRITE ADDRESS ----------------//
        if(AWVALID && !write_active)
        begin
            AWREADY <= 1;
            wr_addr <= AWADDR;
            wr_count <= 0;
            write_active <= 1;
        end
        else
            AWREADY <= 0;

        //---------------- WRITE DATA ----------------//
        if(write_active)
        begin
            WREADY <= 1;

            if(WVALID && WREADY)
            begin
                // Byte-wise write using WSTRB
                if(WSTRB[0]) mem[wr_addr[9:2]][7:0]   <= WDATA[7:0];
                if(WSTRB[1]) mem[wr_addr[9:2]][15:8]  <= WDATA[15:8];
                if(WSTRB[2]) mem[wr_addr[9:2]][23:16] <= WDATA[23:16];
                if(WSTRB[3]) mem[wr_addr[9:2]][31:24] <= WDATA[31:24];

                wr_addr <= wr_addr + 4;
                wr_count <= wr_count + 1;

                if(WLAST)
                begin
                    WREADY <= 0;
                    BVALID <= 1;
                    BRESP  <= 2'b00; // OKAY
                    write_active <= 0;
                end
            end
        end

        //---------------- WRITE RESPONSE ----------------//
        if(BVALID && BREADY)
            BVALID <= 0;

        //---------------- READ ADDRESS ----------------//
        if(ARVALID && !read_active)
        begin
            ARREADY <= 1;
            rd_addr <= ARADDR;
            rd_count <= 0;
            read_active <= 1;
        end
        else
            ARREADY <= 0;

        //---------------- READ DATA ----------------//
        if(read_active)
        begin
            if(!RVALID)
            begin
                RDATA <= mem[rd_addr[9:2]];
                RRESP <= 2'b00; // OKAY
                RVALID <= 1;
                RLAST  <= (rd_count == ARLEN);
            end

            if(RVALID && RREADY)
            begin
                rd_addr <= rd_addr + 4;
                rd_count <= rd_count + 1;

                if(RLAST)
                begin
                    RVALID <= 0;
                    RLAST  <= 0;
                    read_active <= 0;
                end
                else
                    RVALID <= 0;
            end
        end
    end
end

endmodule