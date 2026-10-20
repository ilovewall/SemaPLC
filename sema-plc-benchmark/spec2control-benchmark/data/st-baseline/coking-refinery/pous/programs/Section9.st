PROGRAM Section9
VAR
	PT106_PV_Pct : real;
	PIC101_MV_Pct : real;
	FV102_Feedback_Pos_Pct : real;
	PT_106 : ANALOG_IN;
	PIC_101 : PID_BASIC;
	FV_102 : VALVE_ELECTRIC;
	LC_801_LEVEL_OK : BOOL_INPUT;
	FLARE_IGNITION_OK : BOOL_INPUT;
	PT_106_VALID : BOOL_INPUT;
	FlareIgnitionFail_NOT : bool;
	PT106_Invalid_NOT : bool;
	PIC101_Inhibit_OR : bool;
	LevelNotOK_NOT : bool;
	FV102_Inhibit_OR : bool;
	DeadbandHold_SEL : real;
END_VAR

PT_106(
    Scaling_Slope := 0.3125,
    Scaling_Offset := -1.25,
    Alarm_Enable := TRUE);
DeadbandHold_SEL := SEL(G := PIC_101.Deviation_Alarm, IN0 := FV_102.Feedback_Pos, IN1 := PIC_101.XOUT);
LC_801_LEVEL_OK();
LevelNotOK_NOT := NOT LC_801_LEVEL_OK.Bool_Out;
FV102_Inhibit_OR := LevelNotOK_NOT OR PIC_101.PV_High_Alarm OR PIC_101.PV_Low_Alarm;
FV_102(
    Control_Signal := DeadbandHold_SEL,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FV102_Inhibit_OR);
FLARE_IGNITION_OK();
FlareIgnitionFail_NOT := NOT FLARE_IGNITION_OK.Bool_Out;
PT_106_VALID();
PT106_Invalid_NOT := NOT PT_106_VALID.Bool_Out;
PIC101_Inhibit_OR := FlareIgnitionFail_NOT OR FV_102.Position_Error OR PT106_Invalid_NOT OR PT_106.General_Fault;
PIC_101(
    AUTO := TRUE,
    PV := PT_106.PV,
    SP := 1.5,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := FV_102.Feedback_Pos,
    KP := -3.2,
    TR := 0.5,
    TD := 0.1,
    PV_High := 1.8,
    PV_Low := 1.2,
    Deviation_Limit := 0.15,
    Inhibit := PIC101_Inhibit_OR);

(* Outputs published to other sections / HMI. *)
PT106_PV_Pct := PT_106.PV;
PIC101_MV_Pct := PIC_101.XOUT;
FV102_Feedback_Pos_Pct := FV_102.Feedback_Pos;

END_PROGRAM
