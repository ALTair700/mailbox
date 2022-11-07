module fifo_ctrl #(
    parameter   [31:0]  W_WIDTH_SYS     =   32  ,
    parameter   [31:0]  WIDTH_ADDR      =   32  ,
    parameter           FIFO_DATA       =   0   ,
    parameter   [31:0]  N_NUMB_CPU      =   4   
    )
    (
        input                                           clk             ,
        input                                           rstn            ,
        output  reg                                     err_fifo_full_o ,
        input                                           req_i           ,
        input       [WIDTH_ADDR-1:0]                    addr_i          ,
        input       [W_WIDTH_SYS-1:0]                   data_i          ,
        input                                           wren_i          ,
        input       [31:0]                              numb_cpu_i      ,
        output  reg [W_WIDTH_SYS-1:0]                   rdata_o         ,
        output  reg [N_NUMB_CPU-1 : 0]                  ack_o           ,
        output  reg [FIFO_DATA-1:0]                     s_tdata_o       ,
        output  reg                                     s_tvalid_o      ,
        input                                           s_tready_i          
    );

    reg [1:0]   c_delay ;

    enum logic [3:0] {
        REQ ,
        WR  ,
        ERR ,
        FIN ,
        DEL 
    } state ;

    always @(posedge clk)
        if (!rstn)
            begin
                err_fifo_full_o <=  '0  ;         
                rdata_o         <=  '0  ;
                ack_o           <=  '0  ;
                s_tdata_o       <=  '0  ;    
                s_tvalid_o      <=  '0  ;
                c_delay         <=  '0  ;
                state           <=  REQ ;    
            end
        else
            begin
                case(state)
                REQ :
                    begin
                        if(req_i && s_tready_i && wren_i)
                            state   <=  WR  ;
                        else
                            if(req_i && !s_tready_i)
                                state   <=  ERR ;
                    end
                WR  :
                    begin
                        s_tdata_o   <=  {numb_cpu_i,addr_i,data_i}  ;
                        s_tvalid_o  <=  1'b1                        ;
                        state       <=  FIN                         ;
                    end
                ERR :
                    begin
                        err_fifo_full_o <=  1'b1        ;
                        ack_o [numb_cpu_i]  <=  1'b1    ;
                        state   <=  DEL                 ;
                    end
                FIN :
                    begin
                        s_tvalid_o          <=  1'b0    ;
                        ack_o [numb_cpu_i]  <=  1'b1    ;
                        state               <=  DEL     ;
                    end
                DEL :
                    begin
                        if(c_delay != 2'b11)
                            c_delay <=  c_delay +   1'b1    ;
                        else
                            begin
                                ack_o [numb_cpu_i]  <=  1'b0    ;
                                if(!req_i)
                                state               <=  REQ     ;
                                c_delay             <=  '0      ;
                                err_fifo_full_o     <=  1'b0    ;
                            end
                    end
                default :   state   <=  REQ ;
                endcase
            end

endmodule