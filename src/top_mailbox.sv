`include "mailbox_pkg.sv"

module top_mailbox
    (
        input  wire                                         pclk_i     ,
        input  wire                                         presetn_i  ,
        input  wire [N_NUMB_CPU-1: 0]   [0:0]               psel_i     ,
        input  wire [N_NUMB_CPU-1: 0]   [0:0]               penable_i  ,
        input  wire [N_NUMB_CPU-1: 0]   [0:0]               pwrite_i   ,
        input  wire [N_NUMB_CPU-1: 0]   [W_WIDTH_SYS-1:0]   paddr_i    ,
        input  wire [N_NUMB_CPU-1: 0]   [WIDTH_ADDR-1:0]    pwdata_i   ,
        output wire [N_NUMB_CPU-1: 0]   [W_WIDTH_SYS-1:0]   prdata_o   ,
        output wire [N_NUMB_CPU-1: 0]   [0:0]               pslverr_o  ,
        output wire [N_NUMB_CPU-1: 0]   [0:0]               pready_o   ,
        output wire [N_NUMB_CPU-1: 0]   [0:0]               irq        
    );

    genvar  i   ;
    wire                        [N_NUMB_CPU-1 : 0]  w_ack_apb_ctrl      ;
    wire                        [N_NUMB_CPU-1 : 0]  w_err_w_apb_ctrl    ;
    wire                        [N_NUMB_CPU-1 : 0]  w_err_r_apb_ctrl    ;
    wire    [N_NUMB_CPU-1 : 0]  [W_WIDTH_SYS-1: 0]  w_rdata_apb_ctrl    ;
    wire    [N_NUMB_CPU-1 : 0]  [WIDTH_ADDR-1: 0]   w_addr_mux          ;
    wire                        [WIDTH_ADDR-1: 0]   w_addr_w_mux        ;
    wire                        [WIDTH_ADDR-1: 0]   w_addr_r_mux        ;
    wire    [N_NUMB_CPU-1 : 0]  [W_WIDTH_SYS-1: 0]  w_data_mux          ;
    wire                        [W_WIDTH_SYS-1: 0]  w_data_w_mux        ;
    wire                        [W_WIDTH_SYS-1: 0]  w_data_r_mux        ;
    wire                        [N_NUMB_CPU-1 : 0]  w_wren_mux          ;
    wire                        [N_NUMB_CPU-1 : 0]  w_req_mux           ;

    wire    [N_NUMB_CPU-1:0]                        w_req_w_mx          ;
    wire    [N_NUMB_CPU-1:0]                        w_req_r_mx          ;
    wire    [N_NUMB_CPU-1:0]                        w_req_w_mx_reg      ;
    wire    [N_NUMB_CPU-1:0]                        w_req_r_mx_reg      ;
    wire    [WIDTH_ADDR-1: 0]                       w_addr_mx           ;
    wire    [W_WIDTH_SYS-1: 0]                      w_data_mx           ;
    wire                                            w_write_w_mx        ;
    wire                                            w_write_r_mx        ;
    wire    [W_WIDTH_SYS-1: 0]                      w_rdata_w_mx        ;
    wire    [W_WIDTH_SYS-1: 0]                      w_rdata_r_mx        ;
    wire                                            w_err_w_mx          ;
    wire    [N_NUMB_CPU-1:0]                        w_ack_w_mx          ;
    wire    [N_NUMB_CPU-1:0]                        w_ack_r_mx          ;
    wire    [31:0]                                  w_mux_numb_w_cpu    ;
    wire    [31:0]                                  w_mux_numb_r_cpu    ;
    wire    [N_NUMB_CPU-1:0]                        w_irq               ;
    wire    [N_NUMB_CPU-1 : 0]                      w_ack_w             ;
    wire    [FIFO_DATA-1:0]                         w_fifo_sdata        ;
    wire                                            w_fifo_stvalid      ;
    wire                                            w_fifo_stready      ;
    wire    [FIFO_DATA-1:0]                         w_m_tdata           ; 
    wire                                            w_m_tvalid          ;
    wire                                            w_m_tready          ;
    wire                                            w_err_r             ;
    wire    [N_NUMB_CPU-1:0]                        w_ack_r             ;
    wire    [W_WIDTH_SYS-1: 0]                      w_rdata_r           ;

    wire                                            w_req_r             ;
    wire                                            w_req_w             ;    

    assign  w_req_w = |w_req_w_mx_reg [N_NUMB_CPU-1:0];
    assign  w_req_r = |w_req_r_mx_reg [N_NUMB_CPU-1:0];

    assign  irq =   w_irq   ;

    if(W_WIDTH_SYS > 1024 || W_WIDTH_SYS < 8)
            begin : instances_width_error
                initial
                begin
                $error("Error: Incorrect number of parameter 8 > W_WIDTH_SYS < 1024");
                $finish;
                end
            end   : instances_width_error
    
    if(2**$clog2(W_WIDTH_SYS) != W_WIDTH_SYS)
            begin : instances_width1_error
                initial
                begin
                $error("Error: W_WIDTH_SYS word must be even power of two");
                $finish;
                end
            end   : instances_width1_error

    if(K_FIFO_DEPTH != 32)
            begin : instances_fifo_error
                initial
                begin
                $error("Error: Incorrect number of parameter K_FIFO_DEPTH != 32 Prostite");
                $finish;
                end
            end   : instances_fifo_error

    if(N_NUMB_CPU < 1)
            begin : instances_cpu_error
                initial
                begin
                $error("Error: Incorrect number of parameter N_NUMB_CPU < 1");
                $finish;
                end
            end   : instances_cpu_error

    generate
        for (i = 0; i < N_NUMB_CPU; i=i+1)
        begin   :   gen_apb_ctrl
            apb_controller #(
                .W_WIDTH_SYS(W_WIDTH_SYS),
                .WIDTH_ADDR (WIDTH_ADDR )
            ) 
            apb_ctrl_inst
            (
                .pclk_i     (pclk_i                )   ,
                .presetn_i  (presetn_i             )   ,
                .psel_i     (psel_i             [i])   ,
                .penable_i  (penable_i          [i])   ,
                .pwrite_i   (pwrite_i           [i])   ,
                .paddr_i    (paddr_i            [i])   ,
                .pwdata_i   (pwdata_i           [i])   ,
                .prdata_o   (prdata_o           [i])   ,
                .pslverr_o  (pslverr_o          [i])   ,
                .pready_o   (pready_o           [i])   ,
                .ack_w_i    (w_ack_w_mx         [i])   ,
                .ack_r_i    (w_ack_r_mx         [i])   ,
                .req_w_o    (w_req_w_mx         [i])   ,
                .req_r_o    (w_req_r_mx         [i])   ,
                .err_w_i    (w_err_w_apb_ctrl   [i])   ,
                .err_r_i    (w_err_r_apb_ctrl   [i])   ,
                .rdata_i    (w_rdata_apb_ctrl   [i])   ,
                .irq        (w_irq              [i])   ,    
                .addr_o     (w_addr_mux         [i])   ,
                .data_o     (w_data_mux         [i])   ,
                .write_o    (w_wren_mux         [i])    
            );
        end     :   gen_apb_ctrl
    endgenerate
    
    mux 
    #(
        .W_WIDTH_SYS(W_WIDTH_SYS),  
        .N_NUMB_CPU (N_NUMB_CPU) 
    ) write_mux
    (
        .clk            (pclk_i             ),
        .rstn           (presetn_i          ),
        .req_i          (w_req_w_mx         ),
        .addr_i         (w_addr_mux         ),
        .data_i         (w_data_mux         ),
        .write_i        (w_wren_mux         ),
        .mux_err_o      (w_err_w_apb_ctrl   ),
        .mux_req_o      (w_req_w_mx_reg     ), // to slave
        .mux_addr_o     (w_addr_w_mux       ), // to slave
        .mux_data_o     (w_data_w_mux       ), // to slave
        .mux_write_o    (w_write_w_mx       ), // to slave
        .mux_numb_cpu_o (w_mux_numb_w_cpu   ), // to slave
        .rdata_i        (w_rdata_w_mx       ), // from slave
        .mux_rdata_o    (/*not used*/       ),
        .mux_err_i      (w_err_w_mx         ), // from slave
        .ack_i          (w_ack_w            ), // from slave 
        .mux_ack_o      (w_ack_w_mx         )  
    );

    fifo_ctrl #(
        .W_WIDTH_SYS    (W_WIDTH_SYS),
        .WIDTH_ADDR     (WIDTH_ADDR ),
        .FIFO_DATA      (FIFO_DATA  ), 
        .N_NUMB_CPU     (N_NUMB_CPU ) 
    ) fifo_ctrl
    (
        .clk            (pclk_i),
        .rstn           (presetn_i),
        .err_fifo_full_o(w_err_w_mx),
        .req_i          (w_req_w),
        .addr_i         (w_addr_w_mux),
        .data_i         (w_data_w_mux),
        .wren_i         (w_write_w_mx),
        .numb_cpu_i     (w_mux_numb_w_cpu),
        .rdata_o        (w_rdata_w_mx),
        .ack_o          (w_ack_w),
        .s_tdata_o      (w_fifo_sdata),
        .s_tvalid_o     (w_fifo_stvalid),
        .s_tready_i     (w_fifo_stready)
    );

    axis_fifo #(
        .DATA_WIDTH(FIFO_DATA),
        .DEPTH(K_FIFO_DEPTH)      
    )   fifo_wr
    (
        .clk             (pclk_i         ),
        .rst             (!presetn_i     ),
        .s_axis_tdata    (w_fifo_sdata   ),
        .s_axis_tvalid   (w_fifo_stvalid ),
        .s_axis_tkeep    ('1),
        .s_axis_tlast    (1'b1) ,
        .s_axis_tid      ('0),
        .s_axis_tdest    ('0),
        .s_axis_tuser    ('0),
        .s_axis_tready   (w_fifo_stready ),
        .m_axis_tdata    (w_m_tdata      ),
        .m_axis_tvalid   (w_m_tvalid     ),
        .m_axis_tready   (w_m_tready     )
    );

    mux 
    #(
        .W_WIDTH_SYS(W_WIDTH_SYS),  
        .N_NUMB_CPU (N_NUMB_CPU) 
    ) read_mux
    (
        .clk            (pclk_i             ),
        .rstn           (presetn_i          ),
        .req_i          (w_req_r_mx         ),
        .addr_i         (w_addr_mux         ),
        .data_i         (w_data_mux         ),
        .write_i        (w_wren_mux         ),
        .mux_err_o      (w_err_r_apb_ctrl   ),
        .mux_req_o      (w_req_r_mx_reg     ), // to slave
        .mux_addr_o     (w_addr_r_mux       ), // to slave
        .mux_data_o     (w_data_r_mux       ), // to slave
        .mux_write_o    (w_write_r_mx       ), // to slave
        .mux_numb_cpu_o (w_mux_numb_r_cpu   ), // to slave
        .rdata_i        (w_rdata_r          ), // from slave
        .mux_rdata_o    (w_rdata_apb_ctrl   ),
        .mux_err_i      (w_err_r            ), // from slave
        .ack_i          (w_ack_r            ), // from slave 
        .mux_ack_o      (w_ack_r_mx         )  
    );

    reg_model
    #(
        .FIFO_DATA(FIFO_DATA),
        .WIDTH_ADDR(WIDTH_ADDR),
        .W_WIDTH_SYS(W_WIDTH_SYS),
        .N_NUMB_CPU (N_NUMB_CPU)    
    ) reg_model_inst
    (
        .clk            (pclk_i             ),
        .rstn           (presetn_i          ),
        .m_tdata_i      (w_m_tdata          ),
        .m_tvalid_i     (w_m_tvalid         ),
        .m_tready_o     (w_m_tready         ),
        .req_i          (w_req_r            ),
        .addr_r_i       (w_addr_r_mux       ),
        .data_r_i       (w_data_r_mux       ),
        .write_r_i      (w_write_r_mx       ),
        .numb_r_cpu_i   (w_mux_numb_r_cpu   ),
        .rdata_r_o      (w_rdata_r          ),
        .err_r_o        (w_err_r            ),
        .ack_r_o        (w_ack_r            ),
        .irq_o          (w_irq              )
    );

endmodule