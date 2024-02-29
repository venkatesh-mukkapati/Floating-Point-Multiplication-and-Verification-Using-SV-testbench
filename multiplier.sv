package specialcases;

//All SpecialCases are considered here
typedef enum {overflow,underflow,nan, positive_infinity,negative_infinity, zero ,normalizedNumber } SpecialCases;

typedef struct packed{ 
  	logic sign;
    	logic [7:0]exponent;
  	logic [22:0]mantissa;
	 }fp;

endpackage

  
import specialcases::*;

module Multiplication(
		input  wire fp a,
		input  wire fp b,
  		output fp result
        );
 
  
  	SpecialCases Number_form; // specialcases datatype declaration
  
  	logic [8:0]exponent_sum;
    	logic [47:0]product,product_normalised;
	logic normalised;
  	logic [22:0]product_mantissa;
        logic overflow_flag,underflow_flag,nan_flag, positive_infinity_flag,negative_infinity_flag, zero_flag;
	
  	
    
 

assign sign = a.sign ^ b.sign;                                   //xor of a and b
 
// check for special cases and exceptions  
always_comb
    begin
      
      //assertion to check the inputs are known
      a1: assert ((!$isunknown(a)) && (!$isunknown(b)))
       else $error("one of the input is unknown a=%b, b=%b",a,b); 
      
      //assertion to check exponent is in  range of 1-254
      a2: assert(a.exponent[7:0] > 0 && b.exponent [7:0]>0 && a.exponent[7:0]<255 && b.exponent<255)
       else $error("exponents for a  or b  is out of range  a = %b b = %b",a.exponent,b.exponent);
      
      exponent_sum = (a.exponent+b.exponent) - 8'd127 + normalised;      //sum of exponents after normalisation
      
      product = {1'b1,a.mantissa} *{1'b1, b.mantissa};                   //48 bit result
      
      
     
      //  NAN  flag condition           
      if((a.exponent == '1  && a.mantissa != '0) || (b.exponent == '1 && b.mantissa != '0))
        begin
        	Number_form = nan;
          	{nan_flag, positive_infinity_flag,negative_infinity_flag, zero_flag ,overflow_flag,underflow_flag} = 6'b100000;
		end
		
      // Positive Infinity Condition
      else if(( a.sign == 1'b0  && a.exponent == '1  && a.mantissa == '0) || ( b.sign == 1'b0  &&  b.exponent == '1 && b.mantissa == '0) ) 
        begin
      			Number_form = positive_infinity;
			{nan_flag, positive_infinity_flag,negative_infinity_flag, zero_flag ,overflow_flag,underflow_flag} = 6'b010000;
		end
			
       //Negative_infinity condition     
      else if((a.sign == 1'b1 && a.exponent == '1  && a.mantissa == '0) || (b.sign == 1'b1 && b.exponent == '1 && b.mantissa == '0) ) 
        begin
           	   Number_form = negative_infinity;
		   {nan_flag, positive_infinity_flag,negative_infinity_flag, zero_flag ,overflow_flag,underflow_flag} = 6'b001000;
		end
          
	  //ZeroFlag condition
      else if ((a.exponent == '0 && a.mantissa == '0) || (b.exponent == '0 &&  b.mantissa == '0))
        begin
         	   Number_form = zero;
		  {nan_flag, positive_infinity_flag,negative_infinity_flag, zero_flag ,overflow_flag,underflow_flag} = 6'b000100;
        end
		
      //overflow condition
      else if(exponent_sum[8] == 1'b1 && !(exponent_sum[7])   || exponent_sum[7:0] == '1 )
        begin
			Number_form = overflow;
            		{nan_flag, positive_infinity_flag,negative_infinity_flag, zero_flag ,overflow_flag,underflow_flag} = 6'b000010;
		end
		
	 //underflow condition	
      else if(exponent_sum[8] == 1'b1 && (exponent_sum[7])  || exponent_sum[7:0] == '0 )
	  begin       
         	  Number_form = underflow;
		 {nan_flag, positive_infinity_flag,negative_infinity_flag, zero_flag ,overflow_flag,underflow_flag}= 6'b000001;
      end
      
       else 
         begin
          	  Number_form = normalizedNumber;
		  {nan_flag, positive_infinity_flag,negative_infinity_flag, zero_flag ,overflow_flag,underflow_flag} = 6'b000000;
		end
      
      
    end
      
  
  
  
//normalisation

assign normalised = product[47] ? 1'b1 : 1'b0;	               //check if MSB bit of 48 bit product is 1
assign product_normalised = normalised ? product : product << 1;       //If msb is zero ,left shift the 48 bit product
  
//rounding
assign product_round = |product_normalised[22:0];                                              //or of sticky bits 
assign product_mantissa = product_normalised[46:24] + (product_normalised[23] & product_round); //check if guard bit is one then round even


  
//result

  always_comb 
    begin
      
      if (Number_form == normalizedNumber) 
        begin 
        
        result = {sign,exponent_sum[7:0], product_mantissa};
          
          //assertion to check the dut result is inifity 
            a3:assert(((a.exponent != '1  && a.mantissa != '0) || (b.sign != 1'b1 && b.exponent != '1 && b.mantissa != '0)) && (!positive_infinity_flag || !negative_infinity_flag))
            else $error("dut_result is infinity");
         
        end
          
       else
         result = 'x;
    end
 
  
endmodule
