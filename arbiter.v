module rangen(input[31:0] count, input[31:0] count1, output[3:0] OUT1, output[3:0]OUT2);
 
     reg [3:0]a,OUT1;
     reg [3:0] b,OUT2;
      integer j,c,d;
initial begin
    assign c=count;
    assign d=count1;
    assign OUT1=a;
    assign OUT2=b;
   end
always begin
           a={$urandom(c)}%14+1;
           b={$urandom(d)}%14+2;
    for (j=0; a>=b; j=j+1)
    begin
        b={$urandom}%14+2;
    end
#1 ;
end

endmodule


module arbiter(input wire wakeA,input wire wakeB,input wire wakeC);

//creating awake registers to store values in the wire wake
reg awakeA;
reg awakeB;
reg awakeC;

//request signals are created which take input from the awake signals
reg reqA;
reg reqB;
reg reqC;

//grant signals are created
reg grantA;
reg grantB;
reg grantC;

//with attend signals we can feed values into grant
reg attendA;
reg attendB;
reg attendC;

//creating a resource as 2 bit memory block
reg [1:0]memory;
reg r;
reg [3:0]R1,R2;

//creating variables to store randomnumbers
reg [3:0]r1_1,r2_1;
reg [3:0]r1_2,r2_2;
reg [3:0]r1_3,r2_3;

wire[3:0] d,e ;



//queue 
reg [5:0]queue=0;
reg[1:0]current;
integer j;

initial
begin
//assigning values into awake from wake
awakeA=wakeA;
awakeB=wakeB;
awakeC=wakeC;
end

integer i=0;
integer q=1,dummy=5;
rangen Y (((q+dummy)*100),((q+dummy)*50),d,e) ;
initial
 
//generating random numbers
        begin
        r1_1 = d ;
        r2_1 = e ;
	
        dummy = dummy +1 ;
        r1_2 = d ;
        r2_2 = e ;
	
        dummy = dummy +1 ;
        r1_3 = d ;
        r2_3 = e ;
end

always 
begin
#1;
//entering the values from awake to req and we will be furthur acessing code only from req
reqA =awakeA;
reqB =awakeB;
reqC =awakeC;
end

always @(reqA)
begin
	#1;
	if(reqA==1) //if reqA=1 then entering 01 into the queue
	begin
	queue[i]=1;
	#1;
	queue[i+1]=0;
	#1;
	i=i+2;
	end
	else
	begin
	i=i;
	end
end

always @(reqB)
begin
	#5;
	if(reqB==1) //if reqB=1 then entering 10 into the queue
	begin
	queue[i]=0;
	#1;
	queue[i+1]=1;
	#1;
	i=i+2;
	end
	else
	begin
	i=i;
	end
end

always @(reqC)
begin
	#10;
	if(reqC==1) //if reqC=1 then entering 11 into the queue
	begin
	queue[i]=1;
	#1;
	queue[i+1]=1;
	#1;
	i=i+2;
	end
	else
	begin
	i=i;
	end
end

always @(reqA,reqB,reqC)
begin
  #10;
  if(reqA==1)
  begin
  if({queue[1],queue[0]} == 2'b01)
    begin
    attendA=1'b1;
    attendB=1'b0;
    attendC=1'b0;
    $display("attend A :%b",attendA);
    //if both are same then make attend 1
    end
  else
    begin
    attendA=1'b0;
    $display("attend A :%b",attendA);
    end
 
  end
  

  if(reqB==1)
  begin
  if({queue[1],queue[0]} == 2'b10)
    begin
    attendA=1'b0;
    attendB=1'b1;
    attendC=1'b0;
    $display("attend B :%b",attendB);
    //if both are same then make attend 1
    end
  else
    begin
    attendB=1'b0;
    $display("attend B :%b",attendB);
    end

  end
 

  if(reqC==1)
  begin
    if({queue[1],queue[0]} == 2'b11)
    begin
    attendA=1'b0;
    attendB=1'b0;
    attendC=1'b1;
    $display("attend C :%b",attendC);
    //if both are same then make attend 1
    end
    else
    begin
    attendC=1'b0;
    $display("attend C :%b",attendC);
    end

  end
end




always @(attendA or attendB or attendC )
begin
#20;
case({queue[1],queue[0]})

2'b01 :   begin
    if(attendA==1)
    begin
    //if attend is high make grate to high
    grantA = 1'b1;
    $display("grant A :%b",grantA);
    q=q+1;
    end
    end
2'b10 :   begin
    if(attendB==1)
    begin
    //if attend is high make grate to high
    grantB = 1'b1;
    q=q+1;
    $display("grant B :%b",grantB);
    end
    end
2'b11 :   begin
    if(attendC==1)
    begin
    //if attend is high make grate to high
    grantC = 1'b1;
    q=q+1;
    $display("grant C :%b",grantC);
    end
    end
2'b00 :
         $display("resource is free");
         //free to get accessed to the resource
endcase
end


always @(grantA,grantB,grantC)
begin
  #25;
  if(grantA==1 )
  begin
  //assigning memory(resource) to 01 for A
  memory = {queue[1],queue[0]};
  $display("Access granted value is : %b",memory);
  #r1_1;
  //making the grant and awake zero
  grantA = 1'b0;
  awakeA = 1'b0;
  //wait for r1_2 seconds
  #r1_2;
  attendA=1'b0;
  //we will shift queue towards right by 2
  queue = queue >> 2;
  $display("queue status after poping A: %b%b",queue[1],queue[0]);
  $display("awakeA ==%b",awakeA);
  i=i-2;
  end

  #25;
  if(grantB==1)
  begin
  //assigning memory(resource) to 10 for B
  memory = {queue[1],queue[0]};
  $display("Access granted value is : %b",memory);
  #r1_2;
  //making the grant and awake zero
  grantB = 1'b0;
  awakeB = 1'b0;
  //wait for r2_2 seconds
  #r2_2;
  attendB=1'b0;
  //we will shift queue towards right by 2
  queue = queue >> 2;
  $display("queue status after poping B: %b%b",queue[1],queue[0]);
  $display("awakeB ==%b",awakeB);
  i=i-2;
  end

  #25;
  if(grantC == 1 )
  begin
  //assigning memory(resource) to 11 for C
  memory = {queue[1],queue[0]};
  $display("Access granted value is : %b",memory);
  #r1_3;
  //making the grant and awake zero
  grantC = 1'b0;
  awakeC = 1'b0;
  //wait for r3_2 seconds
  #r2_3;
  attendC=1'b0;
  //we will shift queue towards right by 2
  queue = queue >> 2;
  $display("queue status after popingC: %b,%b",queue[1],queue[0]);
  $display("awakeC ==%b",awakeC);
  i=i-2;
  end
end
  
endmodule
