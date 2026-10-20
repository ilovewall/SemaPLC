PROGRAM Section2
VAR
	FT_101_Flow_PV : real;
	IT_102_Flow_PV : real;
	DP_101_DiffP_PV : real;
	DP_102_DiffP_PV : real;
	LT_101_Level_PV : real;
	IIC_101_LiqSepFlow_SP : real;
	DP_101 : ANALOG_IN;
	DP_102 : ANALOG_IN;
	FT_101 : ANALOG_IN;
	IT_102 : ANALOG_IN;
	LT_101 : ANALOG_IN;
	IIC_101 : RATIO_CONTROL;
	LCV_101 : VALVE_ELECTRIC;
	LCV101_Inhibit_OR : bool;
	IIC101_Inhibit_OR : bool;
END_VAR

DP_101(
    Alarm_Enable := TRUE);
DP_102(
    Alarm_Enable := TRUE);
FT_101(
    Scaling_Slope := 312.5,
    Scaling_Offset := -1250.0,
    Alarm_Enable := TRUE);
IT_102(
    Scaling_Slope := 125.0,
    Scaling_Offset := -500.0,
    Alarm_Enable := TRUE);
LT_101(
    Alarm_Enable := TRUE);
IIC101_Inhibit_OR := LT_101.High_Alarm OR FT_101.Low_Alarm OR DP_101.High_Alarm OR DP_102.High_Alarm;
IIC_101(
    Auto := TRUE,
    PrimaryPV := FT_101.PV,
    SecondaryPV := IT_102.PV,
    RatioSP := 2.5,
    Bias := 0.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Inhibit := IIC101_Inhibit_OR);
LCV101_Inhibit_OR := FT_101.Low_Alarm OR IT_102.High_Alarm OR IT_102.Low_Alarm OR DP_101.High_Alarm OR DP_102.High_Alarm;
LCV_101(
    Control_Signal := IIC_101.SlaveSP,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := LCV101_Inhibit_OR);

(* Outputs published to other sections / HMI. *)
FT_101_Flow_PV := FT_101.PV;
IT_102_Flow_PV := IT_102.PV;
DP_101_DiffP_PV := DP_101.PV;
DP_102_DiffP_PV := DP_102.PV;
LT_101_Level_PV := LT_101.PV;
IIC_101_LiqSepFlow_SP := IIC_101.SlaveSP;

END_PROGRAM
