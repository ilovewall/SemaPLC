PROGRAM Section7
VAR
	LIT101_MoldLevel_PV_mm : real;
	FT601_CoolingWaterFlow_PV_m3h : real;
	TT601_MoldTemp_PV_C : real;
	LIC101_ControllerOutput_Pct : real;
	LIT_101 : ANALOG_IN;
	FT_601 : ANALOG_IN;
	TT_601 : ANALOG_IN;
	LIC_101 : PID_BASIC;
	MV_101 : VALVE_ELECTRIC;
	ILK_FT_601_LOW : BOOL_INPUT;
	ILK_TT_601_HIGH : BOOL_INPUT;
	PERM_LIT_101_UNDER_250 : BOOL_INPUT;
	ILK_LIT_101_HIGH_HIGH_280 : BOOL_INPUT;
	ILK_LIT_101_FAULT : BOOL_INPUT;
	CC601_LoopTrips_OR : bool;
	MV101_Inhibit_OR : bool;
END_VAR

LIT_101(
    PV_High := 280.0,
    Scaling_Slope := 18.75,
    Scaling_Offset := -75.0,
    Alarm_Enable := TRUE);
FT_601(
    Alarm_Enable := TRUE);
TT_601(
    PV_High := 950.0,
    Alarm_Enable := TRUE);
ILK_FT_601_LOW(
    Bool_In := FT_601.Low_Alarm);
ILK_LIT_101_FAULT(
    Bool_In := LIT_101.General_Fault);
ILK_TT_601_HIGH(
    Bool_In := TT_601.High_Alarm);
CC601_LoopTrips_OR := ILK_FT_601_LOW.Bool_Out OR ILK_TT_601_HIGH.Bool_Out OR ILK_LIT_101_FAULT.Bool_Out;
ILK_LIT_101_HIGH_HIGH_280(
    Bool_In := LIT_101.High_Alarm);
PERM_LIT_101_UNDER_250(
    Bool_In := LIC_101.PV_High_Alarm);
MV101_Inhibit_OR := ILK_LIT_101_HIGH_HIGH_280.Bool_Out OR PERM_LIT_101_UNDER_250.Bool_Out OR CC601_LoopTrips_OR;
MV_101(
    Control_Signal := LIC_101.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := MV101_Inhibit_OR);
LIC_101(
    AUTO := TRUE,
    PV := LIT_101.PV,
    SP := 150.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := MV_101.Feedback_Pos,
    KP := -3.0,
    TR := 1.2,
    TD := 0.1,
    Deviation_Limit := 20.0,
    Inhibit := CC601_LoopTrips_OR);

(* Outputs published to other sections / HMI. *)
LIT101_MoldLevel_PV_mm := LIT_101.PV;
FT601_CoolingWaterFlow_PV_m3h := FT_601.PV;
TT601_MoldTemp_PV_C := TT_601.PV;
LIC101_ControllerOutput_Pct := LIC_101.XOUT;

END_PROGRAM
