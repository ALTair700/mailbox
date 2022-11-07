// Write processor num 2 and wait for an interrupt
#100
apb_wr(32'd2,32'h2222_0000,2);
#100
apb_wr(32'd14,32'h2222_3333,2);
#100
apb_wr(32'd6,32'h2222_1111,2);
#100
apb_wr(32'd10,32'h2222_2222,2);
wait(irq == 4'hF)
$display("All irq work");
//read for kill irq
#100
apb_r(32'd2,0);  
#100
apb_r(32'd10,2);
#100
apb_r(32'd14,3);
#100
apb_r(32'd6,1);
wait(irq == 4'h0)
$display("All irq down");
//try to write in READ-ONLY registers
#100
apb_wr(32'd1,32'h4444_4444,2);
#100
apb_wr(32'd8,32'h2222_2222,2);
#100
apb_wr(32'd5,32'h3333_3333,2);
#100
apb_wr(32'd15,32'h1111_1111,2);
#1000
$finish   ;