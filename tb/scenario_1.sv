// Write processor num 0 and wait for an interrupt
#100
apb_wr(32'd4,32'h1111_1111,0);
#100
apb_wr(32'd8,32'h2222_2222,0);
#100
apb_wr(32'd12,32'h3333_3333,0);
#100
apb_wr(32'd0,32'h4444_4444,0);
wait(irq == 4'hF)
$display("All irq work");
//read for kill irq
#100
apb_r(32'd4,1);  
#100
apb_r(32'd8,2);
#100
apb_r(32'd12,3);
#100
apb_r(32'd0,0);
wait(irq == 4'h0)
$display("All irq down");
//try to write in READ-ONLY registers
#100
apb_wr(32'd5,32'h1111_1111,0);
#100
apb_wr(32'd9,32'h2222_2222,0);
#100
apb_wr(32'd13,32'h3333_3333,0);
#100
apb_wr(32'd1,32'h4444_4444,0);
#1000
$finish   ;