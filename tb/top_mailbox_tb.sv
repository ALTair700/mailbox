`timescale 10ns/1ns
`include "mailbox_pkg.sv"
`define RST_MODULE					    \
    #100								\
    presetn_i	=	0	;			    \
    #100								\
    presetn_i	=	1	;

module top_mailbox_tb();

    reg                                          pclk_i     = '0 ;
    reg                                          presetn_i  = '1 ;
    reg  [N_NUMB_CPU-1: 0]   [0:0]               psel_i     = '0 ;
    reg  [N_NUMB_CPU-1: 0]   [0:0]               penable_i  = '0 ;
    reg  [N_NUMB_CPU-1: 0]   [0:0]               pwrite_i   = '0 ;
    reg  [N_NUMB_CPU-1: 0]   [W_WIDTH_SYS-1:0]   paddr_i    = '0 ;
    reg  [N_NUMB_CPU-1: 0]   [WIDTH_ADDR-1:0]    pwdata_i   = '0 ;
    wire [N_NUMB_CPU-1: 0]   [W_WIDTH_SYS-1:0]   prdata_o        ;
    wire [N_NUMB_CPU-1: 0]   [0:0]               pslverr_o       ;
    wire [N_NUMB_CPU-1: 0]   [0:0]               pready_o        ;
    wire [N_NUMB_CPU-1: 0]   [0:0]               irq             ;

    always #10 pclk_i <= !pclk_i    ;

    task apb_wr;
        input   [31:0]  adr_wr  ;
        input   [31:0]  data_wr ;
        input   [31:0]       i  ;
            begin
                @(posedge pclk_i);
                    begin
                        pwdata_i[i]	    <=	data_wr		;		
                        paddr_i[i]	    <=	adr_wr  	;		
                        psel_i[i]	    <=	1			;		
                        penable_i[i]	<=	0			;		
                        pwrite_i[i]	    <=	1			;
                    end
                @(posedge pclk_i);
                        penable_i[i]	=	1			;
                @(posedge pclk_i);
                        wait (pready_o[i] == 1)
                            begin
                                penable_i[i]	=	0		;		
    	                        psel_i[i]		=	0		;		
                            end 
            end
    endtask

    task apb_r;
        input   [31:0]  adr_wr  ;
        input   [31:0]       i  ;
            begin
                @(posedge pclk_i);
                    begin		
                        paddr_i[i]	    <=	adr_wr  	;		
                        psel_i[i]	    <=	1			;		
                        penable_i[i]	<=	0			;		
                        pwrite_i[i]	    <=	0			;
                    end
                @(posedge pclk_i);
                        penable_i[i]	=	1			;
                @(posedge pclk_i);
                        wait (pready_o[i] == 1)
                            begin
                                penable_i[i]	=	0		;		
    	                        psel_i[i]		=	0		;		
                            end 
            end
    endtask

    initial
        begin
            `RST_MODULE
            #100
            `ifndef  SCENARIO
                `include "scenario_6.sv"
            `endif

        end
    top_mailbox top_mailbox_test (
        .pclk_i     (pclk_i     ),
        .presetn_i  (presetn_i  ),
        .psel_i     (psel_i     ),
        .penable_i  (penable_i  ),
        .pwrite_i   (pwrite_i   ),
        .paddr_i    (paddr_i    ),
        .pwdata_i   (pwdata_i   ),
        .prdata_o   (prdata_o   ),
        .pslverr_o  (pslverr_o  ),
        .pready_o   (pready_o   ),
        .irq        (irq        )
    );

endmodule