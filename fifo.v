module fifo(
    input wire clk,
    input wire rstn,
    input wire wr_en,
    input wire rd_en,
    input wire [7:0] data_in,
    output reg [7:0] data_out,
    output full,
    output empty
);

    localparam DEPTH = 4;
    localparam PTR_W = 2; 

    reg [7:0] mem [0:DEPTH-1];
    reg [PTR_W-1:0] w_ptr, r_ptr;
    reg full_reg, empty_reg;

    assign full = full_reg;
    assign empty = empty_reg;

    wire [PTR_W-1:0] w_ptr_next = (w_ptr + 1'b1) % DEPTH;
    wire [PTR_W-1:0] r_ptr_next = (r_ptr + 1'b1) % DEPTH;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            w_ptr <= 0;
            r_ptr <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
            data_out <= 8'b0;
        end else begin
            if (rd_en && !empty_reg) begin
                data_out <= mem[r_ptr];
                r_ptr <= r_ptr_next;
            end

            if (wr_en && !full_reg) begin
                mem[w_ptr] <= data_in;
                w_ptr <= w_ptr_next;
            end

            case ({wr_en && !full_reg, rd_en && !empty_reg})
                2'b10: begin 
                    full_reg  <= (w_ptr_next == r_ptr) ? 1'b1 : 1'b0;
                    empty_reg <= 1'b0;
                end
                2'b01: begin 
                    full_reg  <= 1'b0;
                    empty_reg <= (w_ptr == r_ptr_next) ? 1'b1 : 1'b0;
                end
                2'b11: begin 
                    full_reg  <= full_reg;
                    empty_reg <= empty_reg;
                end
                default: begin 
                    full_reg  <= full_reg;
                    empty_reg <= empty_reg;
                end
            endcase
        end
    end

endmodule