PROGRAM Section5
VAR
	AT102_pH_PV : real;
	AT107_pH_PV : real;
	TIT106_Temperature_PV : real;
	LIC102_MV_to_FV101 : real;
	TIC106_MV_to_FV103 : real;
	LIC104_MV_to_XV104 : real;
	AT_102 : ANALOG_IN;
	AT_107 : ANALOG_IN;
	TIT_106 : ANALOG_IN;
	LIC_102 : PID_BASIC;
	TIC_106 : PID_BASIC;
	LIC_104 : PID_BASIC;
	FV_101 : VALVE_ELECTRIC;
	FV_103 : VALVE_ELECTRIC;
	XV_104 : VALVE_ELECTRIC;
	PHExtremeTrip_OR : bool;
END_VAR

AT_102(
    Scaling_Slope := 0.875,
    Scaling_Offset := -3.5,
    Alarm_Enable := TRUE);
AT_107(
    Alarm_Enable := TRUE);
TIT_106(
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
FV_101(
    Control_Signal := LIC_102.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s,
    Inhibit := AT_107.General_Fault);
PHExtremeTrip_OR := LIC_102.PV_High_Alarm OR LIC_102.PV_Low_Alarm;
LIC_102(
    AUTO := TRUE,
    PV := AT_102.PV,
    SP := 9.25,
    MV_MIN := 10.0,
    MV_MAX := 90.0,
    X0 := FV_101.Feedback_Pos,
    KP := 1.8,
    TR := 0.5,
    TD := 0.1,
    PV_High := 10.5,
    PV_Low := 8.5,
    Deviation_Limit := 1.0,
    Inhibit := PHExtremeTrip_OR);
FV_103(
    Control_Signal := TIC_106.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s);
TIC_106(
    AUTO := TRUE,
    PV := TIT_106.PV,
    SP := 65.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := FV_103.Feedback_Pos,
    KP := 2.0,
    TR := 0.4,
    TD := 0.05,
    PV_High := 75.0,
    PV_Low := 55.0,
    Inhibit := TIC_106.PV_High_Alarm);
XV_104(
    Control_Signal := LIC_104.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s);
LIC_104(
    AUTO := TRUE,
    SP := 120.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := XV_104.Feedback_Pos,
    KP := 1.5,
    TR := 1.0,
    TD := 0.2,
    Deviation_Limit := 10.0);

(* Outputs published to other sections / HMI. *)
AT102_pH_PV := AT_102.PV;
AT107_pH_PV := AT_107.PV;
TIT106_Temperature_PV := TIT_106.PV;
LIC102_MV_to_FV101 := LIC_102.XOUT;
TIC106_MV_to_FV103 := TIC_106.XOUT;
LIC104_MV_to_XV104 := LIC_104.XOUT;

END_PROGRAM
