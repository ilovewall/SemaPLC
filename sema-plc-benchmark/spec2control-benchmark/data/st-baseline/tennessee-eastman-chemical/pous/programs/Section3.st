PROGRAM Section3
VAR
	TIT_103_Temperature_C : real;
	LT_105_Level_Percent : real;
	TIC_101_Output_Percent : real;
	LIC_106_Output_Percent : real;
	TIT_103 : ANALOG_IN;
	LT_105 : ANALOG_IN;
	TIC_101 : PID_BASIC;
	LIC_106 : PID_BASIC;
	FC_004 : PID_BASIC;
	LV_104 : VALVE_ELECTRIC;
	XV_102 : VALVE_ON_OFF;
	TIC101_Inhibit_OR : bool;
	SteamNotOpen_NOT : bool;
	LIC106_Inhibit_OR : bool;
END_VAR

TIT_103(
    PV_High := 200.0,
    PV_Low := 160.0,
    Scaling_Slope := 15.625,
    Scaling_Offset := -62.5,
    Alarm_Enable := TRUE);
LT_105(
    PV_High := 80.0,
    PV_Low := 20.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
FC_004();
XV_102(
    Timeout := T#5s,
    Inhibit := TIT_103.High_Alarm);
TIC101_Inhibit_OR := TIT_103.High_Alarm OR XV_102.Alarm_Position_Error OR FC_004.PV_Low_Alarm OR TIT_103.General_Fault;
TIC_101(
    PV := TIT_103.PV,
    SP := 180.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 3.0,
    TR := 1.2,
    TD := 0.1,
    Inhibit := TIC101_Inhibit_OR);
LV_104(
    Control_Signal := LIC_106.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := LT_105.High_Alarm);
SteamNotOpen_NOT := NOT XV_102.FB_Opened;
LIC106_Inhibit_OR := SteamNotOpen_NOT OR LV_104.Alarm OR LT_105.General_Fault;
LIC_106(
    PV := LT_105.PV,
    SP := 50.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 2.5,
    TR := 0.9,
    TD := 0.0,
    Inhibit := LIC106_Inhibit_OR);

(* Outputs published to other sections / HMI. *)
TIT_103_Temperature_C := TIT_103.PV;
LT_105_Level_Percent := LT_105.PV;
TIC_101_Output_Percent := TIC_101.XOUT;
LIC_106_Output_Percent := LIC_106.XOUT;

END_PROGRAM
