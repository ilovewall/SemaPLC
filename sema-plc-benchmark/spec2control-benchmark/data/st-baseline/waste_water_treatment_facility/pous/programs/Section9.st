PROGRAM Section9
VAR
	FT_801_EffluentFlow_PV : real;
	CL_801_ChlorineFlow_SP : real;
	DC_801_DechlorFlow_SP : real;
	XV_106_FullyOpen_FB : bool;
	CL_801_Running_FB : bool;
	DC_801_Running_FB : bool;
	FT_801 : ANALOG_IN;
	FIC_101 : RATIO_CONTROL;
	FIC_102 : RATIO_CONTROL;
	CL_801 : MOTOR_VSD;
	DC_801 : MOTOR_VSD;
	LV_105 : VALVE_ELECTRIC;
	XV_106 : VALVE_ON_OFF;
	UV_801 : MOTOR_ON_OFF;
	CL_RatioMinCalc : real;
	CL_RatioMaxCalc : real;
	DC_RatioMinCalc : real;
	DC_RatioMaxCalc : real;
	ValveNotOpen : bool;
	CL_NotRunning : bool;
	ChemActive : bool;
	LV_105_AnyAlarm : bool;
	XV_106_AnyAlarm : bool;
	CL_801_Inh_OR1 : bool;
	CL_801_Inh_OR2 : bool;
	CL_801_Inh_OR3 : bool;
	DC_801_Inh_OR1 : bool;
	DC_801_Inh_OR2 : bool;
	FT_801_AnyFault_OR1 : bool;
	FT_801_AnyFault_OR2 : bool;
	FIC_102_Inh_OR1 : bool;
END_VAR

FT_801(
    Scaling_Slope := 62.5,
    Scaling_Offset := -250.0,
    Alarm_Enable := TRUE);
XV_106(
    Timeout := T#5s);
ValveNotOpen := NOT XV_106.FB_Opened;
CL_801_Inh_OR1 := ValveNotOpen OR FT_801.Low_Alarm;
XV_106_AnyAlarm := XV_106.Alarm_Position_Error OR XV_106.Alarm_General;
CL_801_Inh_OR2 := CL_801_Inh_OR1 OR XV_106_AnyAlarm;
LV_105(
    Timeout := T#5s);
LV_105_AnyAlarm := LV_105.Position_Error OR LV_105.Alarm;
CL_801_Inh_OR3 := CL_801_Inh_OR2 OR LV_105_AnyAlarm;
CL_801(
    Speed_SP := FIC_101.SlaveSP,
    Inhibit := CL_801_Inh_OR3);
CL_RatioMaxCalc := FT_801.PV * 3.0;
CL_RatioMinCalc := FT_801.PV * 2.0;
FT_801_AnyFault_OR1 := FT_801.Low_Alarm OR FT_801.High_Alarm;
FT_801_AnyFault_OR2 := FT_801_AnyFault_OR1 OR FT_801.General_Fault;
FIC_101(
    Auto := TRUE,
    PrimaryPV := FT_801.PV,
    SecondaryPV := CL_801.FB_ActualSpeed,
    RatioSP := 2.5,
    MV_MIN := CL_RatioMinCalc,
    MV_MAX := CL_RatioMaxCalc,
    Inhibit := FT_801_AnyFault_OR2);
CL_NotRunning := NOT CL_801.FB_Running;
DC_801_Inh_OR1 := LV_105_AnyAlarm OR FT_801.Low_Alarm;
DC_801_Inh_OR2 := DC_801_Inh_OR1 OR CL_NotRunning;
DC_801(
    Speed_SP := FIC_102.SlaveSP,
    Inhibit := DC_801_Inh_OR2);
DC_RatioMaxCalc := FT_801.PV * 1.5;
DC_RatioMinCalc := FT_801.PV * 1.0;
FIC_102_Inh_OR1 := FT_801_AnyFault_OR2 OR CL_NotRunning;
FIC_102(
    Auto := TRUE,
    PrimaryPV := FT_801.PV,
    SecondaryPV := DC_801.FB_ActualSpeed,
    RatioSP := 1.2,
    MV_MIN := DC_RatioMinCalc,
    MV_MAX := DC_RatioMaxCalc,
    Inhibit := FIC_102_Inh_OR1);
ChemActive := CL_801.FB_Running OR DC_801.FB_Running;
UV_801(
    Inhibit := ChemActive);

(* Outputs published to other sections / HMI. *)
FT_801_EffluentFlow_PV := FT_801.PV;
CL_801_ChlorineFlow_SP := FIC_101.SlaveSP;
DC_801_DechlorFlow_SP := FIC_102.SlaveSP;
XV_106_FullyOpen_FB := XV_106.FB_Opened;
CL_801_Running_FB := CL_801.FB_Running;
DC_801_Running_FB := DC_801.FB_Running;

END_PROGRAM
