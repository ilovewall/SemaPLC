PROGRAM Section2
VAR
	TE101_Temperature_PV : real;
	LIT101_Level_PV : real;
	PIT102_Pressure_PV : real;
	TIC104_MV_Percent : real;
	PV103_Position_FB : real;
	TE_101 : ANALOG_IN;
	LIT_101 : ANALOG_IN;
	PIT_102 : ANALOG_IN;
	TIC_104 : PID_BASIC;
	PV_103 : VALVE_ELECTRIC;
	XV_105 : VALVE_ON_OFF;
	LAH_101 : DIGITAL_IN;
	LAL_101 : DIGITAL_IN;
	XV105_NotOpen_NOT : bool;
	TIC104_Inhibit_OR : bool;
	LA_LevelTrip_OR : bool;
END_VAR

TE_101(
    Scaling_Slope := 9.375,
    Scaling_Offset := 12.5,
    Alarm_Enable := TRUE);
LIT_101(
    PV_High := 80.0,
    PV_Low := 20.0,
    Alarm_Enable := TRUE);
PIT_102(
    Alarm_Enable := TRUE);
PV_103(
    Control_Signal := TIC_104.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0);
LAH_101();
LAL_101();
LA_LevelTrip_OR := LAH_101.DI_Out OR LAL_101.DI_Out;
XV_105(
    Inhibit := LA_LevelTrip_OR);
XV105_NotOpen_NOT := NOT XV_105.FB_Opened;
TIC104_Inhibit_OR := PIT_102.High_Alarm OR PIT_102.Low_Alarm OR TE_101.High_Alarm OR TE_101.Low_Alarm OR TE_101.General_Fault OR LIT_101.High_Alarm OR LIT_101.Low_Alarm OR XV105_NotOpen_NOT OR PV_103.Alarm;
TIC_104(
    PV := TE_101.PV,
    SP := 150.0,
    MV_MIN := 10.0,
    MV_MAX := 90.0,
    KP := 3.0,
    TR := 0.5,
    TD := 0.1,
    PV_High := 180.0,
    PV_Low := 130.0,
    Inhibit := TIC104_Inhibit_OR);

(* Outputs published to other sections / HMI. *)
TE101_Temperature_PV := TE_101.PV;
LIT101_Level_PV := LIT_101.PV;
PIT102_Pressure_PV := PIT_102.PV;
TIC104_MV_Percent := TIC_104.XOUT;
PV103_Position_FB := PV_103.Feedback_Pos;

END_PROGRAM