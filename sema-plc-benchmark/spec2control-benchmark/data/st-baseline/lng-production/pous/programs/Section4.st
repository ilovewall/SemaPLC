PROGRAM Section4
VAR
	AI302_H2O_Outlet_PV : real;
	AI303_Hg_Permissive_PV : real;
	AI304_H2O_RatioOpt_PV : real;
	FT301_FeedGasFlow_PV : real;
	DP301_MolSieveBed_DP_PV : real;
	FFIC303_RegenFlow_SP_to_FIC302 : real;
	AI_302 : ANALOG_IN;
	AI_303 : ANALOG_IN;
	AI_304 : ANALOG_IN;
	DI_301 : DIGITAL_IN;
	DP_301 : ANALOG_IN;
	FIC_302 : PID_BASIC;
	FT_301 : ANALOG_IN;
	FV_302 : VALVE_ELECTRIC;
	FFIC_303 : RATIO_CONTROL;
	Inhibit_OR : bool;
END_VAR

AI_302(
    Alarm_Enable := TRUE);
AI_303(
    Alarm_Enable := TRUE);
AI_304(
    PV_High := 10.0,
    Alarm_Enable := TRUE);
DI_301();
DP_301(
    PV_High := 20.0,
    Alarm_Enable := TRUE);
FT_301(
    PV_Low := 500.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
Inhibit_OR := AI_302.High_Alarm OR AI_303.High_Alarm OR AI_302.General_Fault OR AI_303.General_Fault OR DI_301.DI_Out OR FT_301.Low_Alarm OR DP_301.High_Alarm;
FFIC_303(
    Auto := TRUE,
    PrimaryPV := FT_301.PV,
    RatioSP := 0.25,
    Bias := 0.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Inhibit := Inhibit_OR);
FIC_302(
    AUTO := TRUE,
    SP := FFIC_303.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Inhibit := Inhibit_OR);
FV_302(
    Control_Signal := FIC_302.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := Inhibit_OR);

(* Outputs published to other sections / HMI. *)
AI302_H2O_Outlet_PV := AI_302.PV;
AI303_Hg_Permissive_PV := AI_303.PV;
AI304_H2O_RatioOpt_PV := AI_304.PV;
FT301_FeedGasFlow_PV := FT_301.PV;
DP301_MolSieveBed_DP_PV := DP_301.PV;
FFIC303_RegenFlow_SP_to_FIC302 := FFIC_303.SlaveSP;

END_PROGRAM
