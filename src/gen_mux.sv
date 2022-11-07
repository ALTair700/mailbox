module mux #(
        parameter   [31:0]  W_WIDTH_SYS     =   32  ,
        parameter   [31:0]  N_NUMB_CPU      =   3   
    ) 
    (
        input                                                   clk             ,
        input                                                   rstn            ,
        input           [N_NUMB_CPU-1 : 0]  [0:0]               req_i           ,
        input           [N_NUMB_CPU-1 : 0]  [W_WIDTH_SYS-1:0]   addr_i          ,
        input           [N_NUMB_CPU-1 : 0]  [W_WIDTH_SYS-1:0]   data_i          ,
        input           [N_NUMB_CPU-1 : 0]  [0:0]               write_i         ,
        output  reg     [N_NUMB_CPU-1: 0]                       mux_err_o       ,
        output  reg     [N_NUMB_CPU-1: 0]                       mux_req_o       ,
        output  reg     [W_WIDTH_SYS-1: 0]                      mux_addr_o      ,
        output  reg     [W_WIDTH_SYS-1: 0]                      mux_data_o      ,
        output  reg                                             mux_write_o     ,
        output  reg     [31:0]                                  mux_numb_cpu_o  ,
        input           [W_WIDTH_SYS-1: 0]                      rdata_i         ,
        output  reg     [N_NUMB_CPU-1 : 0]  [W_WIDTH_SYS-1: 0]  mux_rdata_o     ,
        input                                                   mux_err_i       ,
        input           [N_NUMB_CPU-1 : 0]                      ack_i           ,
        output  reg     [N_NUMB_CPU-1 : 0]                      mux_ack_o   
    );
	enum logic [N_NUMB_CPU-1:0] {
		CHECK_REQ_0,
		CHECK_REQ_1,
		CHECK_REQ_2,
		CHECK_REQ_3
		} state ;

	always @(posedge clk)
		if(!rstn)
			begin
				state		<=	CHECK_REQ_0	;
				mux_err_o	<=	'0	;
				mux_req_o	<=	'0	;
				mux_addr_o	<=	'0	;
				mux_data_o	<=	'0	;
				mux_write_o	<=	'0	;
				mux_rdata_o	<=	'0	;
				mux_ack_o	<=	'0	;
				mux_numb_cpu_o	<=	'0	;
			end
		else
			begin
				case(state)
					CHECK_REQ_0 :
						begin
						if(req_i[0])
							begin
							mux_err_o	[0]	<=	mux_err_i	;
							mux_req_o		<=	req_i	[0]	;
							mux_addr_o		<=	addr_i	[0]	;
							mux_data_o		<=	data_i	[0]	;
							mux_write_o		<=	write_i	[0]	;
							mux_rdata_o	[0]	<=	rdata_i		;
							mux_ack_o	[0]	<=	ack_i	[0]	;
							mux_numb_cpu_o	<=	32'd0		;
							end
						else if(!ack_i[0])
							begin
								mux_ack_o	[0]	<=	ack_i	[0]	;
								mux_req_o	[0]	<=	1'b0		;
								state	<=	CHECK_REQ_1		;
							end
						end
					CHECK_REQ_1 :
						begin
						if(req_i[1])
							begin
							mux_err_o	[1]	<=	mux_err_i	;
							mux_req_o		<=	req_i	[1]	;
							mux_addr_o		<=	addr_i	[1]	;
							mux_data_o		<=	data_i	[1]	;
							mux_write_o		<=	write_i	[1]	;
							mux_rdata_o	[1]	<=	rdata_i		;
							mux_ack_o	[1]	<=	ack_i	[1]	;
							mux_numb_cpu_o	<=	32'd1		;
							end
						else if(!ack_i[1])
							begin
								mux_ack_o	[1]	<=	ack_i	[1]	;
								mux_req_o	[1]	<=	1'b0		;
								state	<=	CHECK_REQ_2		;
							end
						end
					CHECK_REQ_2 :
						begin
						if(req_i[2])
							begin
							mux_err_o	[2]	<=	mux_err_i	;
							mux_req_o		<=	req_i	[2]	;
							mux_addr_o		<=	addr_i	[2]	;
							mux_data_o		<=	data_i	[2]	;
							mux_write_o		<=	write_i	[2]	;
							mux_rdata_o	[2]	<=	rdata_i		;
							mux_ack_o	[2]	<=	ack_i	[2]	;
							mux_numb_cpu_o	<=	32'd2		;
							end
						else if(!ack_i[2])
							begin
								mux_ack_o	[2]	<=	ack_i	[2]	;
								mux_req_o	[2]	<=	1'b0		;
								state	<=	CHECK_REQ_3		;
							end
						end
					CHECK_REQ_3 :
						begin
						if(req_i[3])
							begin
							mux_err_o	[3]	<=	mux_err_i	;
							mux_req_o		<=	req_i	[3]	;
							mux_addr_o		<=	addr_i	[3]	;
							mux_data_o		<=	data_i	[3]	;
							mux_write_o		<=	write_i	[3]	;
							mux_rdata_o	[3]	<=	rdata_i		;
							mux_ack_o	[3]	<=	ack_i	[3]	;
							mux_numb_cpu_o	<=	32'd3		;
							end
						else if(!ack_i[3])
							begin
								mux_ack_o	[3]	<=	ack_i	[3]	;
								mux_req_o	[3]	<=	1'b0		;
								state	<=	CHECK_REQ_0		;
							end
						end
					default:	state	<=	CHECK_REQ_0	;
				endcase
			end
endmodule