


class stimulus;  /// stimulus generation class
  randc bit a_sign,b_sign;
  randc bit [7:0] a_exponent,b_exponent;
  randc bit [22:0] a_mantissa, b_mantissa;
  
  
  //creating constraints
  constraint con{a_exponent>0 ;
                  a_exponent<255;
                b_exponent>0 ;
                  b_exponent<255;}

endclass

import specialcases::*; // import package



module top;
fp  a_operand ;
fp  b_operand;
logic  [31:0] dut_result;


        
int pass_count =0;
int fail_count = 0;
int flag_count=0;
logic [31:0]Expected_output;
  
  
Multiplication DUT( a_operand,b_operand, dut_result); 
	
	
//Task for creating direct test cases 
task iteration(
			input [31:0] operand_a,operand_b
			    );
	begin
		#5;
		a_operand = operand_a;
		b_operand = operand_b;
		#1;
		$display("time=%0t ,Corner test case for %s , DUT_Overflow_flag=%d, DUT_Underflow_flag=%d, DUT_Nan_flag=%d, DUT_PositivityInfinity_flag=%d, DUT_NegativeInfinity_flag=%d, DUT_Zero_flag=%d ",$time, DUT.Number_form,DUT.overflow_flag,DUT.underflow_flag,DUT.nan_flag, DUT.positive_infinity_flag,DUT.negative_infinity_flag, DUT.zero_flag);
	end

endtask

  
 initial begin
    
	  iteration({1'b0,8'd1,23'd0},{1'b0,8'd126,23'd0});
	  iteration({1'b0,8'd254,23'd0},{1'b0,8'd128,23'd0});
	  iteration({1'b0,8'd255,23'd474624},{1'b0,8'd131,23'd0});
	  iteration({1'b0,8'd0,23'd0},{1'b0,8'd155,23'd0});
	  iteration({1'b0,8'd255,23'd0},{1'b0,8'd155,23'd0});
	  iteration({1'b1,8'd255,23'd0},{1'b0,8'd155,23'd0});
     
  end
  
  
  
		
stimulus s; //creating object handle for class
  initial begin
     #50; 
    
    for(int i =0;i<500;i++)
      begin
        s=new();
        assert(s.randomize())
          else $fatal("error in randomization");
        
        a_operand = {s.a_sign,s.a_exponent,s.a_mantissa};
        b_operand = {s.b_sign,s.b_exponent,s.b_mantissa};
        Expected_output = $shortrealtobits(($bitstoshortreal(a_operand)*$bitstoshortreal(b_operand)));
        
        
        #10;     
        
       
        if(( DUT.overflow_flag ) || (DUT.underflow_flag)  ||( DUT.nan_flag ) || (DUT.positive_infinity_flag) || (DUT.negative_infinity_flag) || (DUT.zero_flag))
        		flag_count = flag_count+1; //If any flags are activated we are not self  checking
        
        else if( Expected_output === dut_result) begin
          		pass_count = pass_count+1;
           	end
       	else  begin
          	   fail_count = fail_count+1;
                   $display(" time=%t failed at a_sign = %b , a_exponent = %b, a_mantissa= %b , b_sign = %b , b_exponent = %b, b_mantissa= %b ",$time,s.a_sign,s.a_exponent,s.a_mantissa,s.b_sign,s.b_exponent,s.b_mantissa);
                                                         
        	  end
       end
    
    
    $display(" time=%0t pass_count %0d, fail_count %0d , flag_count %0d",$time,pass_count,fail_count,flag_count);
        
#1000;
    
  end
  
 
 


endmodule




