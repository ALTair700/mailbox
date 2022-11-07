// Write processor num 3 and wait for an interrupt
#100
apb_wr(32'd3,32'h3333_0000,3);
#100
apb_wr(32'd7,32'h3333_1111,3);
#100
apb_wr(32'd11,32'h3333_2222,3);
#100
apb_wr(32'd15,32'h3333_3333,3);
wait(irq == 4'hF)
$display("All irq work");
//read for kill irq
#100
apb_r(32'd3,0);  
#100
apb_r(32'd11,2);
#100
apb_r(32'd7,1);
#100
apb_r(32'd15,3);
wait(irq == 4'h0)
$display("All irq down");
//try to write in READ-ONLY registers
#100
apb_wr(32'd0,32'h4444_4444,3);
#100
apb_wr(32'd6,32'h2222_2222,3);
#100
apb_wr(32'd8,32'h3333_3333,3);
#100
apb_wr(32'd14,32'h1111_1111,3);
#1000
$finish   ;