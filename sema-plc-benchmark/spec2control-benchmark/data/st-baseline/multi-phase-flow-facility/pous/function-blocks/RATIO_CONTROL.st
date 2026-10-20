FUNCTION_BLOCK RATIO_CONTROL
VAR_INPUT
	Auto : bool;
	PrimaryPV : real;
	SecondaryPV : real;
	RatioSP : real;
	Bias : real;
	TrimKp : real;
	TrimTi : time;
	MV_MIN : real;
	MV_MAX : real;
	ManOut : real;
	Inhibit : bool;
END_VAR

VAR_OUTPUT
	SlaveSP : real;
	ActiveRatio : real;
	RatioErr : real;
END_VAR

IF PrimaryPV > 0.0 THEN
    ActiveRatio := SecondaryPV / PrimaryPV;
ELSE
    ActiveRatio := 0.0;
END_IF;
RatioErr := ActiveRatio - RatioSP;
IF Inhibit THEN
    SlaveSP := MV_MIN;
ELSIF Auto THEN
    SlaveSP := LIMIT(MV_MIN, PrimaryPV * RatioSP + Bias, MV_MAX);
ELSE
    SlaveSP := ManOut;
END_IF;

END_FUNCTION_BLOCK
