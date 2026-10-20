PROGRAM Section2
VAR
	LT_101_Flow_PV : real;
	FC_101_MV_to_FV106 : real;
	M_102_VSD_Speed_Out : real;
	Flow_Deviation_Alarm_30s : bool;
	Flow_High_Alarm : bool;
	Flow_Low_Alarm : bool;
	M_102_Start_Request : bool;
	M_102_Stop_Request : bool;
	LT_101 : ANALOG_IN;
	FC_101 : PID_BASIC;
	M_102 : MOTOR_VSD;
	FV_106 : VALVE_ELECTRIC;
	LV_103 : VALVE_ELECTRIC;
	XV_102 : VALVE_ON_OFF;
	XV_104 : VALVE_ON_OFF;
	XV_105 : VALVE_ON_OFF;
	FlowDeviationAlarm_TON : TON;
	M102_RestartDelay_TON : TON;
	FC101_ValvesOpen_AND : bool;
	FC101_ValvesNotOpen_NOT : bool;
	FC101_Inhibit_OR : bool;
	M102_XV105NotClosed_NOT : bool;
	M102_Inhibit_OR : bool;
	M102_InhibitNot_NOT : bool;
	M102_StartPermissive_AND : bool;
	M102_StopCmd_OR : bool;
	HopperLevelAbove20_GT : bool;
END_VAR

LT_101(
    PV_High := 380.0,
    PV_Low := 20.0,
    Scaling_Slope := 25.0,
    Scaling_Offset := -100.0,
    Alarm_Enable := TRUE);
XV_105(
    Timeout := T#5s);
M102_XV105NotClosed_NOT := NOT XV_105.FB_Closed;
M102_Inhibit_OR := M102_XV105NotClosed_NOT OR LT_101.General_Fault;
LV_103(
    Open_Limit := 100.0,
    Close_Limit := 0.0);
HopperLevelAbove20_GT := (LV_103.Feedback_Pos > 20.0);
M102_InhibitNot_NOT := NOT M102_Inhibit_OR;
M102_RestartDelay_TON(
    IN := M102_InhibitNot_NOT,
    PT := T#60s);
M102_StartPermissive_AND := HopperLevelAbove20_GT AND XV_105.FB_Closed AND M102_RestartDelay_TON.Q AND M_102_Start_Request;
M102_StopCmd_OR := M_102_Stop_Request OR M102_Inhibit_OR;
M_102(
    Start_Cmd := M102_StartPermissive_AND,
    Stop_Cmd := M102_StopCmd_OR,
    Accel_Ramp := T#2s,
    Decel_Ramp := T#2s,
    Inhibit := M102_Inhibit_OR);
XV_102(
    Timeout := T#5s,
    Inhibit := M_102.FB_Fault);
XV_104(
    Timeout := T#5s,
    Inhibit := M_102.FB_Fault);
FC101_ValvesOpen_AND := XV_102.FB_Opened AND XV_104.FB_Opened;
FC101_ValvesNotOpen_NOT := NOT FC101_ValvesOpen_AND;
FC101_Inhibit_OR := FC101_ValvesNotOpen_NOT OR LT_101.General_Fault OR M_102.FB_Fault;
FC_101(
    AUTO := TRUE,
    PV := LT_101.PV,
    SP := 250.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 3.0,
    TR := 1.2,
    TD := 0.3,
    Deviation_Limit := 5.0,
    Inhibit := FC101_Inhibit_OR);
FV_106(
    Control_Signal := FC_101.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#5s,
    Inhibit := LT_101.General_Fault);
FlowDeviationAlarm_TON(
    IN := FC_101.Deviation_Alarm,
    PT := T#30s);

(* Outputs published to other sections / HMI. *)
FC_101_MV_to_FV106 := FC_101.XOUT;
LT_101_Flow_PV := LT_101.PV;
Flow_High_Alarm := LT_101.High_Alarm;
Flow_Low_Alarm := LT_101.Low_Alarm;
Flow_Deviation_Alarm_30s := FlowDeviationAlarm_TON.Q;
M_102_VSD_Speed_Out := M_102.Speed_Out;

END_PROGRAM
