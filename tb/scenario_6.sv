//check error read addr
#100
apb_r(32'd500,0); 
wait (pslverr_o[0])
$display("Error work");
#1000
$finish   ;