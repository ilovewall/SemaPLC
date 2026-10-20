PROGRAM Section7
VAR
	FT601A_Raw_mA : real;
	FT601B_Raw_mA : real;
	LIT601_Raw_mA : real;
	LT601_Raw_mA : real;
	HS601_HandSwitch_IN : bool;
	FT601A_LNG_Flow_PV : real;
	FT601B_BOG_Flow_PV : real;
	FT601B_BOG_Flow_SP : real;
	LIT601_TankLevel_PV : real;
	LT601_TankLevel_PV : real;
	FT_601A : ANALOG_IN;
	FT_601B : ANALOG_IN;
	LIT_601 : ANALOG_IN;
	LT_601 : ANALOG_IN;
	HS_601 : BOOL_INPUT;
	FFIC_601 : RATIO_CONTROL;
	FIC_601B : PID_BASIC;
	FV_601B : VALVE_ELECTRIC;
	C_601 : MOTOR_ON_OFF;
	RatioControlInhibit : bool;
	CompressorInhibit : bool;
END_VAR

FT_601A(
    Raw_Signal := FT601A_Raw_mA,
    PV_High := 4500.0,
    PV_Low := 100.0,
    Scaling_Slope := 312.5,
    Scaling_Offset := -1250.0,
    Alarm_Enable := TRUE);
FT_601B(
    Raw_Signal := FT601B_Raw_mA,
    PV_High := 900.0,
    PV_Low := 50.0,
    Scaling_Slope := 62.5,
    Scaling_Offset := -250.0,
    Alarm_Enable := TRUE);
LIT_601(
    Raw_Signal := LIT601_Raw_mA,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
LT_601(
    Raw_Signal := LT601_Raw_mA,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0);
HS_601(
    Bool_In := HS601_HandSwitch_IN,
    Alarm_OnTrue := TRUE);
FIC_601B(
    AUTO := TRUE,
    PV := FT_601B.PV,
    SP := FFIC_601.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    Deviation_Limit := 100.0,
    Inhibit := LIT_601.High_Alarm);
RatioControlInhibit := HS_601.Alarm_Active OR LIT_601.High_Alarm OR FT_601A.Low_Alarm OR FT_601A.General_Fault OR FT_601B.General_Fault OR FIC_601B.Deviation_Alarm;
FFIC_601(
    Auto := TRUE,
    PrimaryPV := FT_601A.PV,
    SecondaryPV := FT_601B.PV,
    RatioSP := 0.2,
    Bias := 0.0,
    TrimKp := 0.0,
    TrimTi := T#0s,
    MV_MIN := 0.0,
    MV_MAX := 1000.0,
    ManOut := 0.0,
    Inhibit := RatioControlInhibit);
FV_601B(
    Control_Signal := FIC_601B.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#5s,
    Inhibit := LIT_601.High_Alarm);
CompressorInhibit := LIT_601.Low_Alarm OR FV_601B.Alarm OR FT_601A.General_Fault OR FV_601B.Position_Error;
C_601(
    Inhibit := CompressorInhibit);

(* Outputs published to other sections / HMI. *)
FT601A_LNG_Flow_PV := FT_601A.PV;
FT601B_BOG_Flow_PV := FT_601B.PV;
FT601B_BOG_Flow_SP := FFIC_601.SlaveSP;
LIT601_TankLevel_PV := LIT_601.PV;
LT601_TankLevel_PV := LT_601.PV;

END_PROGRAM
