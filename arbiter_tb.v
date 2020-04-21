module test;
wire wakeA;
wire wakeB;
wire wakeC;



 assign wakeA =1'b1;
 assign wakeB =1'b1;
 assign wakeC =1'b0;   

initial
begin
#1000;
$finish;
end

 arbiter a(.wakeA(wakeA),.wakeB(wakeB),.wakeC(wakeC));
 
initial 
	begin
        $dumpfile("arbiter.vcd");
        $dumpvars();
    end 

endmodule

