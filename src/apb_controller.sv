module apb_controller 
#(
    parameter   [31:0]  W_WIDTH_SYS     =   32  ,
    parameter   [31:0]  WIDTH_ADDR      =   32  
)
(
    input                        pclk_i     ,
    input                        psel_i     ,
    input                        penable_i  ,
    input                        presetn_i  ,
    input                        ack_w_i    ,
    input                        ack_r_i    ,
    input                        pwrite_i   ,
    input      [WIDTH_ADDR-1:0]  paddr_i    ,
    input      [W_WIDTH_SYS-1:0] pwdata_i   ,
    input                        err_w_i    ,
    input                        err_r_i    ,
    input      [W_WIDTH_SYS-1:0] rdata_i    ,
    input                        irq        ,
    output reg [W_WIDTH_SYS-1:0] prdata_o   ,
    output reg                   pslverr_o  ,
    output reg                   req_w_o    ,
    output reg                   req_r_o    ,
    output reg                   pready_o   ,
    output reg [WIDTH_ADDR-1:0]  addr_o     ,
    output reg [W_WIDTH_SYS-1:0] data_o     ,
    output reg                   write_o    
);

    reg                     r_err_i     ;

  enum logic [3:0] {
    CHECK_PSEL_PEN  ,
    CHECK_PWEN      ,
    REQ_WRITE       ,
    ACK_WRITE       ,
    WRITE_RDY       ,
    WRITE_ERR       ,
    REQ_READ        ,
    ACK_READ        ,
    READ_RDY        
  } state;

  always @(posedge pclk_i)
    if (!presetn_i) 
      begin
        state     <= CHECK_PSEL_PEN     ;
        req_w_o   <= 1'b0               ;
        req_r_o   <= 1'b0               ;
        pready_o  <= 1'b1               ;
        addr_o    <= {WIDTH_ADDR {1'b0}};
        data_o    <= {W_WIDTH_SYS{1'b0}};
        prdata_o  <= {W_WIDTH_SYS{1'b0}};
        write_o   <= 1'b0               ;
        pslverr_o <= 1'b1               ;
        r_err_i   <= '0                 ;  
      end 
    else
      case (state)
        CHECK_PSEL_PEN:
            begin
                pslverr_o   <=  1'b0    ;
                if(psel_i && penable_i)
                    begin
                        addr_o      <=  paddr_i         ;
                        data_o      <=  pwdata_i        ;
                        write_o     <=  pwrite_i        ;
                        state       <=  CHECK_PWEN      ;
                        pready_o    <=  1'b0            ;
                    end
                else
                    begin
                        state       <=  CHECK_PSEL_PEN  ;
                        pready_o    <=  1'b1            ;
                    end
            end
        CHECK_PWEN    :
            begin
                if(irq && write_o)
                    state   <=  WRITE_ERR   ;
                else    if(write_o)
                            state   <=  REQ_WRITE   ;
                        else
                            state   <=  REQ_READ    ;
            end
        REQ_WRITE     :
            begin
                if(req_w_o && ack_w_i)
                    begin
                        r_err_i <=  err_w_i     ;
                        req_w_o <=  1'b0        ;
                        state   <=  ACK_WRITE   ;
                    end
                else
                    req_w_o <=  1'b1    ;
            end
        ACK_WRITE     :
            begin
                if(!ack_w_i)
                    state   <=  WRITE_RDY   ;
            end
        WRITE_RDY     :
            begin
                addr_o      <=  '0              ;
                data_o      <=  '0              ;
                write_o     <=  '0              ;
                pready_o    <=  1'b1            ;
                pslverr_o   <=  r_err_i         ;
                state       <=  CHECK_PSEL_PEN  ;
            end
        WRITE_ERR     :
            begin
                addr_o      <=  '0              ;
                data_o      <=  '0              ;
                write_o     <=  '0              ;
                pready_o    <=  1'b1            ;
                pslverr_o   <=  1'b1            ;
                state       <=  CHECK_PSEL_PEN  ;
            end

        REQ_READ      :
            begin
                if(req_r_o && ack_r_i)
                    begin
                        prdata_o    <=  rdata_i     ;
                        r_err_i     <=  err_r_i     ;
                        req_r_o     <=  1'b0        ;
                        state       <=  ACK_READ    ;
                    end
                else
                    req_r_o <=  1'b1    ;
            end
        ACK_READ      :
            begin
                if(!ack_r_i)
                    state   <=  READ_RDY    ;
            end
        READ_RDY      :
            begin
                addr_o      <=  '0              ;
                data_o      <=  '0              ;
                write_o     <=  '0              ;
                pready_o    <=  1'b1            ;
                pslverr_o   <=  r_err_i         ;
                state       <=  CHECK_PSEL_PEN  ;
            end
        default: state <= CHECK_PSEL_PEN;
      endcase

endmodule
