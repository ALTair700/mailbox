//check full fifo for error 
#100
apb_wr(32'd4,32'h1111_1111,0); 
#100
repeat (39) apb_wr(32'd4,32'hFFFF_FFFF,0); 
wait (pslverr_o[0])
$display("Error work");
#1000
$finish   ;