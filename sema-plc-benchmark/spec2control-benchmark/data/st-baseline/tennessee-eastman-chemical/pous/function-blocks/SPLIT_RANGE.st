FUNCTION_BLOCK SPLIT_RANGE
VAR_INPUT
	IN : real;
	Split_Point : real;
	Output1_Start : real;
	Output1_End : real;
	Output2_Start : real;
	Output2_End : real;
END_VAR

VAR_OUTPUT
	OUT1 : real;
	OUT2 : real;
END_VAR

IF IN <= Split_Point THEN
    OUT1 := Output1_End;
    OUT2 := Output2_Start;
ELSE
    OUT1 := Output1_Start;
    OUT2 := Output2_End;
END_IF;

END_FUNCTION_BLOCK
