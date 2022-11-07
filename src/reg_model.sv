module reg_model #(
    parameter   FIFO_DATA   =   0,
    parameter   WIDTH_ADDR  =   0,
    parameter   W_WIDTH_SYS =   0,
    parameter   N_NUMB_CPU  =   4
    )
    (
        input                               clk         ,
        input                               rstn        ,
        input           [FIFO_DATA-1:0]     m_tdata_i   ,
        input                               m_tvalid_i  ,
        output  reg                         m_tready_o  ,
        input                               req_i       ,
        input           [WIDTH_ADDR-1:0]    addr_r_i    ,
        input           [W_WIDTH_SYS-1:0]   data_r_i    ,
        input                               write_r_i   ,
        input           [31:0]              numb_r_cpu_i,
        output  reg     [W_WIDTH_SYS-1:0]   rdata_r_o   ,
        output  reg                         err_r_o     ,
        output  reg     [N_NUMB_CPU-1:0]    ack_r_o     ,
        output  reg     [N_NUMB_CPU-1:0]    irq_o       
    );

    reg [(N_NUMB_CPU*N_NUMB_CPU)-1:0]   r_irq   ;

    genvar j;
    genvar i;
    generate
        assign  irq_o[0] =  |r_irq[(N_NUMB_CPU-1):0] ;
        for(j = 1; j < N_NUMB_CPU; j = j + 1)
        begin
            assign  irq_o[j] =  |r_irq[(j*N_NUMB_CPU)+N_NUMB_CPU-1:j*N_NUMB_CPU] ;
        end
    endgenerate

    reg [(N_NUMB_CPU*N_NUMB_CPU+N_NUMB_CPU + N_NUMB_CPU)-1:0] [W_WIDTH_SYS - 1: 0]  mem         ;
    reg                                                                             f_wr        ;
    reg [(N_NUMB_CPU*N_NUMB_CPU)-1:0]                                               f_busy      ;
    reg [1:0]                                                                       c_delay     ;
    reg [1:0]                                                                       c_delay_w   ;

    wire    [WIDTH_ADDR-1:0]    addr    ;
    wire    [W_WIDTH_SYS-1:0]   data    ;
    wire    [31:0]              numb    ;

    reg    [WIDTH_ADDR-1:0]     r_addr  ;
    reg    [W_WIDTH_SYS-1:0]    r_data  ;
    reg    [31:0]               r_numb  ;

    generate
    for(i = 0; i < WIDTH_ADDR; i++)
        begin
            assign addr[i] =  m_tdata_i[i+W_WIDTH_SYS] ;
        end
    for(i = 0; i < W_WIDTH_SYS; i++)
        begin
            assign data[i] =  m_tdata_i[i] ;
        end
    for(i = 0; i < 32; i++)
        begin
            assign numb[i] =  m_tdata_i[i+W_WIDTH_SYS+WIDTH_ADDR] ;
        end
    endgenerate

    enum logic [3:0] {
        RDY ,
        WR  ,
        WAIT,
        WAIT_RD 
    } state_wr  ;

    enum logic [3:0] {
        REQ         ,
        ERR_ADDR    ,
        READ        ,
        WAIT_R
    } state_r   ;

    always @(posedge clk) 
        if(!rstn)
            begin
                mem         <=  '0  ;
                m_tready_o  <=  '1  ;
                rdata_r_o   <=  '0  ;
                err_r_o     <=  '0  ;
                ack_r_o     <=  '0  ;
                f_wr        <=  '0  ;
                state_wr    <=  RDY ;
                r_addr      <=  '0  ;
                r_data      <=  '0  ;
                r_numb      <=  '0  ;
                f_busy      <=  '0  ;
                state_r     <=  REQ ;
                c_delay     <=  '0  ;
                c_delay_w   <=  '0  ;
                r_irq       <=  '0  ;
            end
        else
            begin
                case(state_wr)
                    RDY     :
                        begin
                            if(m_tvalid_i)
                                begin
                                    m_tready_o  <=  1       ;
                                    state_wr    <=  WR      ;
                                    r_addr      <=  addr    ;
                                    r_data      <=  data    ;
                                    r_numb      <=  numb    ;
                                end
                        end
                    WR      :
                        begin
                            m_tready_o  <=  0       ;
                            f_wr        <=  1       ;
                            if(((r_addr % N_NUMB_CPU) == 0) && r_numb == 0)
                                begin
                                    if(f_busy[r_addr])
                                        begin
                                            state_wr    <=  WAIT_RD ;
                                        end
                                    else
                                        begin
                                            mem[r_addr]   <=  r_data    ; 
                                            mem[N_NUMB_CPU*N_NUMB_CPU+ (r_addr / N_NUMB_CPU)][r_numb] <= 1'b1  ;
                                            r_irq[r_addr] <=  1'b1    ;
                                            state_wr    <=  WAIT    ;
                                            f_busy[r_addr] <=   1'b1    ;
                                        end
                                end
                            else if (r_numb == (r_addr % N_NUMB_CPU))
                                begin
                                    if(f_busy[r_addr])
                                        begin
                                            state_wr    <=  WAIT_RD ;
                                        end
                                    else
                                        begin
                                            mem[r_addr]   <=  r_data    ; 
                                            mem[N_NUMB_CPU*N_NUMB_CPU+(r_addr / N_NUMB_CPU)][r_numb] <= 1'b1  ;
                                            r_irq[r_addr] <=  1'b1    ;
                                            state_wr    <=  WAIT    ;
                                            f_busy[r_addr] <=   1'b1    ;
                                        end
                                end
                                    else
                                        begin
                                           mem[N_NUMB_CPU*N_NUMB_CPU+N_NUMB_CPU+r_numb] <= mem[N_NUMB_CPU*N_NUMB_CPU+N_NUMB_CPU+r_numb] + 1 ;
                                           state_wr    <=  WAIT    ;
                                        end
                        end
                    WAIT    :
                        begin
                            f_wr        <=  1'b0    ;
                            if(c_delay_w    != 2'b11)
                                c_delay_w   <=  c_delay_w   +   1'b1    ;
                            else
                                begin
                                    c_delay_w   <=  '0      ;
                                    //m_tready_o  <=  1'b1    ;
                                    state_wr    <=  RDY     ;
                                end
                        end
                    WAIT_RD :
                        begin
                            f_wr        <=  1'b0    ;
                            if(!f_busy[r_addr])
                                state_wr    <= WR       ;
                        end
                    default : state_wr <=  RDY;
                endcase

                case(state_r)
                    REQ :
                        begin
                            if(req_i)
                                state_r   <=  ERR_ADDR    ;
                        end
                    ERR_ADDR :
                        begin
                            if(addr_r_i > ((N_NUMB_CPU*N_NUMB_CPU+N_NUMB_CPU + N_NUMB_CPU)-1))
                                begin
                                    ack_r_o[numb_r_cpu_i]   <=  1'b1    ;
                                    err_r_o                 <=  1'b1    ;
                                    state_r                 <=  WAIT_R  ;
                                end
                            else if(!f_wr)
                                state_r <=  READ    ;
                        end
                    READ:
                        begin
                            if ((addr_r_i >= (N_NUMB_CPU*numb_r_cpu_i)) && (addr_r_i <= ((N_NUMB_CPU*numb_r_cpu_i) + N_NUMB_CPU - 1)))
                                begin
                                    rdata_r_o               <=  mem[addr_r_i]   ;
                                    r_irq[addr_r_i]         <=  1'b0    ;
                                    state_r                 <=  WAIT_R  ;
                                    f_busy[addr_r_i]        <=  1'b0    ;
                                    ack_r_o[numb_r_cpu_i]   <=  1'b1    ;
                                    mem[N_NUMB_CPU*N_NUMB_CPU+(numb_r_cpu_i)][addr_r_i % N_NUMB_CPU] <= 1'b0  ; 
                                end
                            else
                                begin
                                    rdata_r_o               <=  mem[addr_r_i]   ;
                                    state_r                 <=  WAIT_R          ;
                                    ack_r_o[numb_r_cpu_i]   <=  1'b1            ; 
                                end

                        end
                    WAIT_R:
                        begin
                            if (c_delay != 2'b11)
                                c_delay <=  c_delay + 1;
                            else
                                begin
                                    c_delay                 <=  '0      ;
                                    ack_r_o[numb_r_cpu_i]   <=  1'b0    ;
                                    err_r_o                 <=  1'b0    ;
                                    if(!req_i)
                                    state_r                 <=  REQ     ;
                                end
                        end
                    default : state_r                 <=  REQ     ;
                endcase
            end
        
        

endmodule