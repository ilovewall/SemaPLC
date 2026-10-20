PROGRAM Section4
VAR
	PC301_SP_Operator : real;
	PT_301_RegeneratorPressure_PV : real;
	PT_302_BlowerDischargePressure_PV : real;
	PT_303_FractionatorOverheadPressure_PV : real;
	TT_301_RegeneratorTemperature_PV : real;
	PTF_301_FilteredPressure_PV : real;
	PC_301_Output_to_PV_105_Percent : real;
	PV_105_Valve_Position_Command_Percent : real;
	PV_105_Valve_Position_Feedback_Percent : real;
	P_301A_Running_Status : bool;
	XV_108_Closed_Status : bool;
	PT_301 : ANALOG_IN;
	PT_302 : ANALOG_IN;
	PT_303 : ANALOG_IN;
	PTF_301 : ANALOG_IN;
	TT_301 : ANALOG_IN;
	PC_301 : PID_BASIC;
	PV_105 : VALVE_ELECTRIC;
	PV_106 : VALVE_ON_OFF;
	XV_108 : VALVE_ON_OFF;
	P_301A : MOTOR_ON_OFF;
	SteadyState_TON : TON;
	SetpointClamp_LIMIT : real;
	StartupSP_Select_SEL : real;
	ErrorCalc_SUB : real;
	ErrorPos_GT : bool;
	ErrorNeg_LT : bool;
	ErrorOutsideBand_OR : bool;
	DeadbandApply_SEL : real;
	PV_Reconstruct_ADD : real;
	BlowerNotRunning_NOT : bool;
	Permissives_OR1 : bool;
	Permissives_OR2 : bool;
	Permissives_OR3 : bool;
	PV105Inhibit_OR : bool;
	AutoHold_OR : bool;
	AutoEnable_NOT : bool;
	ESD_HighPressure_GT : bool;
	ReliefValve_GT : bool;
	ReliefValve_Close_NOT : bool;
	OutsideBand_NOT : bool;
END_VAR

PT_301(
    PV_High := 2.8,
    PV_Low := 2.2,
    Scaling_Slope := 0.3125,
    Scaling_Offset := -1.25,
    Alarm_Enable := TRUE);
PT_302(
    Scaling_Slope := 0.3125,
    Scaling_Offset := -1.25,
    Alarm_Enable := TRUE);
PT_303(
    Scaling_Slope := 0.3125,
    Scaling_Offset := -1.25,
    Alarm_Enable := TRUE);
PTF_301(
    Scaling_Slope := 0.3125,
    Scaling_Offset := -1.25);
TT_301(
    Scaling_Slope := 62.5,
    Scaling_Offset := -250.0,
    Alarm_Enable := TRUE);
ESD_HighPressure_GT := (PT_301.PV > 3.0);
XV_108(
    Open_Cmd := FALSE,
    Close_Cmd := ESD_HighPressure_GT,
    Timeout := T#5s);
AutoHold_OR := PT_301.General_Fault OR XV_108.FB_Closed;
AutoEnable_NOT := NOT AutoHold_OR;
ErrorNeg_LT := (ErrorCalc_SUB < -0.05);
ErrorPos_GT := (ErrorCalc_SUB > 0.05);
ErrorOutsideBand_OR := ErrorPos_GT OR ErrorNeg_LT;
OutsideBand_NOT := NOT ErrorOutsideBand_OR;
SteadyState_TON(
    IN := OutsideBand_NOT,
    PT := T#60s);
StartupSP_Select_SEL := SEL(G := SteadyState_TON.Q, IN0 := 2.5, IN1 := 0.0);
ErrorCalc_SUB := PT_301.PV - StartupSP_Select_SEL;
DeadbandApply_SEL := SEL(G := ErrorOutsideBand_OR, IN0 := 0.0, IN1 := ErrorCalc_SUB);
PV_Reconstruct_ADD := StartupSP_Select_SEL + DeadbandApply_SEL;
PC_301(
    AUTO := AutoEnable_NOT,
    PV := PV_Reconstruct_ADD,
    SP := StartupSP_Select_SEL,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 3.0,
    TR := 1.2,
    TD := 0.1);
P_301A();
BlowerNotRunning_NOT := NOT P_301A.FB_Running;
Permissives_OR1 := TT_301.Low_Alarm OR BlowerNotRunning_NOT;
Permissives_OR2 := PT_302.Low_Alarm OR PT_303.High_Alarm;
Permissives_OR3 := Permissives_OR1 OR Permissives_OR2;
PV105Inhibit_OR := Permissives_OR3 OR XV_108.FB_Closed;
PV_105(
    Control_Signal := PC_301.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s,
    Inhibit := PV105Inhibit_OR);
ReliefValve_GT := (PT_301.PV > 3.5);
ReliefValve_Close_NOT := NOT ReliefValve_GT;
PV_106(
    Open_Cmd := ReliefValve_GT,
    Close_Cmd := ReliefValve_Close_NOT,
    Timeout := T#5s);
SetpointClamp_LIMIT := LIMIT(MN := 2.0, IN := PC301_SP_Operator, MX := 3.0);

(* Outputs published to other sections / HMI. *)
PT_301_RegeneratorPressure_PV := PT_301.PV;
PT_302_BlowerDischargePressure_PV := PT_302.PV;
PT_303_FractionatorOverheadPressure_PV := PT_303.PV;
TT_301_RegeneratorTemperature_PV := TT_301.PV;
PTF_301_FilteredPressure_PV := PTF_301.PV;
PC_301_Output_to_PV_105_Percent := PC_301.XOUT;
PV_105_Valve_Position_Command_Percent := PV_105.Valve_Position;
PV_105_Valve_Position_Feedback_Percent := PV_105.Feedback_Pos;
P_301A_Running_Status := P_301A.FB_Running;
XV_108_Closed_Status := XV_108.FB_Closed;

END_PROGRAM
