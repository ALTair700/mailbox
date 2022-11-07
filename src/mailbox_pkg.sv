`ifndef MAILBOX_DEF
   `define MAILBOX_DEF
        package mailbox_pkg;
            parameter   [31:0]  W_WIDTH_SYS     =   32  ;
            parameter   [31:0]  N_NUMB_CPU      =   4   ;
            parameter   [31:0]  K_FIFO_DEPTH    =   32  ;
            parameter   [31:0]  WIDTH_ADDR      =   32  ;
            parameter           FIFO_DATA   =   W_WIDTH_SYS + WIDTH_ADDR + 32   ;
        endpackage

	import mailbox_pkg::*;
    
`endif