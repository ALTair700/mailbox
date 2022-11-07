// Write processor num 1 and wait for an interrupt
#100
apb_wr(32'd1,32'h1111_0000,1);
#100
apb_wr(32'd9,32'h1111_2222,1);
#100
apb_wr(32'd13,32'h1111_3333,1);
#100
apb_wr(32'd5,32'h1111_FFFF,1);
wait(irq == 4'hF)
$display("All irq work");
//read for kill irq
#100
apb_r(32'd1,0);  
#100
apb_r(32'd9,2);
#100
apb_r(32'd13,3);
#100
apb_r(32'd5,1);
wait(irq == 4'h0)
$display("All irq down");
//try to write in READ-ONLY registers
#100
apb_wr(32'd2,32'h4444_4444,1);
#100
apb_wr(32'd10,32'h2222_2222,1);
#100
apb_wr(32'd14,32'h3333_3333,1);
#100
apb_wr(32'd6,32'h1111_1111,1);
#1000
$finish   ;