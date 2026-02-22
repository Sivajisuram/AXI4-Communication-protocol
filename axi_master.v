`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 16:36:31
// Design Name: 
// Module Name: axi_master
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


module axi_master(
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

    output reg done,
    output reg error,              // ? Error flag added

    // WRITE ADDRESS CHANNEL
    output reg [31:0] AWADDR,
    output reg [7:0]  AWLEN,
    output reg [2:0]  AWSIZE,
    output reg [1:0]  AWBURST,
    output reg        AWVALID,
    input             AWREADY,

    // WRITE DATA CHANNEL
    output reg [31:0] WDATA,
    output reg [3:0]  WSTRB,       // ? Added
    output reg        WVALID,
    output reg        WLAST,
    input             WREADY,

    // WRITE RESPONSE CHANNEL
    input  [1:0] BRESP,
    input        BVALID,
    output reg   BREADY,

    // READ ADDRESS CHANNEL
    output reg [31:0] ARADDR,
    output reg [7:0]  ARLEN,
    output reg [2:0]  ARSIZE,
    output reg [1:0]  ARBURST,
    output reg        ARVALID,
    input             ARREADY,

    // READ DATA CHANNEL
    input  [31:0] RDATA,
    input  [1:0]  RRESP,          // ? Added
    input         RVALID,
    input         RLAST,
    output reg    RREADY
);

reg [2:0] state;
reg [7:0] beat_count;
reg [7:0] burst_len_reg;

localparam IDLE=0, AW=1, W=2, B=3, AR=4, R=5;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        state <= IDLE;
        done  <= 0;
        error <= 0;

        AWVALID <= 0;
        WVALID  <= 0;
        WLAST   <= 0;
        WSTRB   <= 0;
        BREADY  <= 0;
        ARVALID <= 0;
        RREADY  <= 0;

        beat_count <= 0;
        burst_len_reg <= 0;
    end
    else
    begin
        done  <= 0;
        error <= 0;

        case(state)

        // ================= IDLE =================
        IDLE:
        begin
            if(start_write)
            begin
                burst_len_reg <= burst_len;

                AWADDR  <= base_write_addr;
                AWLEN   <= burst_len;
                AWSIZE  <= burst_size;
                AWBURST <= burst_type;
                AWVALID <= 1;

                state <= AW;
            end
            else if(start_read)
            begin
                burst_len_reg <= burst_len;

                ARADDR  <= base_read_addr;
                ARLEN   <= burst_len;
                ARSIZE  <= burst_size;
                ARBURST <= burst_type;
                ARVALID <= 1;

                state <= AR;
            end
        end

        // ================= WRITE ADDRESS =================
        AW:
        begin
            if(AWVALID && AWREADY)
            begin
                AWVALID <= 0;

                beat_count <= 0;

                WVALID <= 1;
                WDATA  <= write_data;
                WSTRB  <= 4'b1111;    // Full word write
                WLAST  <= (0 == burst_len_reg);

                state <= W;
            end
        end

        // ================= WRITE DATA =================
        W:
        begin
            if(WVALID && WREADY)
            begin
                if(beat_count == burst_len_reg)
                begin
                    WVALID <= 0;
                    WLAST  <= 0;
                    WSTRB  <= 0;
                    BREADY <= 1;
                    state  <= B;
                end
                else
                begin
                    beat_count <= beat_count + 1;
                    WDATA <= write_data + beat_count + 1;
                    WLAST <= (beat_count + 1 == burst_len_reg);
                end
            end
        end

        // ================= WRITE RESPONSE =================
        B:
        begin
            if(BVALID && BREADY)
            begin
                BREADY <= 0;

                if(BRESP != 2'b00)     // ? BRESP check
                    error <= 1;

                done  <= 1;
                state <= IDLE;
            end
        end

        // ================= READ ADDRESS =================
        AR:
        begin
            if(ARVALID && ARREADY)
            begin
                ARVALID <= 0;
                beat_count <= 0;
                RREADY  <= 1;
                state   <= R;
            end
        end

        // ================= READ DATA =================
        R:
        begin
            if(RVALID && RREADY)
            begin
                if(RRESP != 2'b00)     // ? RRESP check
                    error <= 1;

                if(beat_count == burst_len_reg)
                begin
                    RREADY <= 0;
                    done   <= 1;
                    state  <= IDLE;
                end
                else
                begin
                    beat_count <= beat_count + 1;
                end
            end
        end

        endcase
    end
end

endmodule
    
