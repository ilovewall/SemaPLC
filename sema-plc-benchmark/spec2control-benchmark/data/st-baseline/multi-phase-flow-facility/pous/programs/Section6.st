PROGRAM Section6
VAR
	FT105_FlowRate_gpm : real;
	LI503_Level_Pct : real;
	P001_Running_Permissive : bool;
	FT_105 : ANALOG_IN;
	LI_503 : ANALOG_IN;
	LIC_502 : PID_BASIC;
	LIC_503 : PID_BASIC;
	LVC_502 : VALVE_ELECTRIC;
	LVC_507 : VALVE_ELECTRIC;
	P_001 : MOTOR_ON_OFF;
	PumpNotRunning : bool;
	LevelOverride : bool;
	FlowOverride : bool;
END_VAR

FT_105(
    PV_High := 45.0,
    PV_Low := 5.0,
    Scaling_Slope := 3.125,
    Scaling_Offset := -12.5,
    Alarm_Enable := TRUE);
LI_503(
    PV_High := 90.0,
    PV_Low := 10.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
P_001();
PumpNotRunning := NOT P_001.FB_Running;
FlowOverride := FT_105.Low_Alarm OR FT_105.High_Alarm OR PumpNotRunning OR FT_105.General_Fault;
LIC_502(
    AUTO := TRUE,
    PV := FT_105.PV,
    SP := 35.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 1.8,
    TR := 2.0,
    TD := 0.0,
    Inhibit := FlowOverride);
LevelOverride := LI_503.High_Alarm OR LI_503.Low_Alarm OR PumpNotRunning OR LI_503.General_Fault;
LIC_503(
    AUTO := TRUE,
    PV := LI_503.PV,
    SP := 65.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := -2.0,
    TR := 1.5,
    TD := 0.1,
    Inhibit := LevelOverride);
LVC_502(
    Control_Signal := LIC_502.XOUT,
    Manual_Mode := FlowOverride,
    Manual_Position := 100.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FlowOverride);
LVC_507(
    Control_Signal := LIC_503.XOUT,
    Manual_Mode := LevelOverride,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := LevelOverride);

(* Outputs published to other sections / HMI. *)
FT105_FlowRate_gpm := FT_105.PV;
LI503_Level_Pct := LI_503.PV;
P001_Running_Permissive := P_001.FB_Running;

END_PROGRAM
