PROGRAM Section4
VAR
	FIT103_FlowRate : real;
	LT104_Level : real;
	LIC101_PV102_ValveCommand : real;
	LAH101_Alarm : bool;
	LAL101_Alarm : bool;
	LT104_FaultAlarm : bool;
	OverCapacity_Active : bool;
	LevelAbove10_OK : bool;
	FIT_103 : ANALOG_IN;
	LT_104 : ANALOG_IN;
	LIC_101 : PID_BASIC;
	PV_102 : VALVE_ELECTRIC;
	OverCapCompare : bool;
	SPOverrideSelector : real;
	LevelAbove10Compare : bool;
	LevelLowInvert : bool;
	PV102InhibitLogic : bool;
	LT104AutoInvert : bool;
END_VAR

FIT_103(
    Scaling_Slope := 3.125,
    Scaling_Offset := -12.5,
    Alarm_Enable := TRUE);
LT_104(
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
LT104AutoInvert := NOT LT_104.General_Fault;
OverCapCompare := (FIT_103.PV > 60.0);
SPOverrideSelector := SEL(G := OverCapCompare, IN0 := 65.0, IN1 := 50.0);
LIC_101(
    AUTO := LT104AutoInvert,
    PV := LT_104.PV,
    SP := SPOverrideSelector,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 1.8,
    TR := 0.6,
    TD := 0.1,
    PV_High := 90.0,
    PV_Low := 15.0,
    Deviation_Limit := 5.0);
LevelAbove10Compare := (LT_104.PV > 10.0);
LevelLowInvert := NOT LevelAbove10Compare;
PV102InhibitLogic := LevelLowInvert OR LT_104.General_Fault;
PV_102(
    Control_Signal := LIC_101.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s,
    Inhibit := PV102InhibitLogic);

(* Outputs published to other sections / HMI. *)
FIT103_FlowRate := FIT_103.PV;
LT104_Level := LT_104.PV;
LIC101_PV102_ValveCommand := LIC_101.XOUT;
LAH101_Alarm := LIC_101.PV_High_Alarm;
LAL101_Alarm := LIC_101.PV_Low_Alarm;
LT104_FaultAlarm := LT_104.General_Fault;
OverCapacity_Active := OverCapCompare;
LevelAbove10_OK := LevelAbove10Compare;

END_PROGRAM
