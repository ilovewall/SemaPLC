PROGRAM Section2
VAR
	LS_101_WetWellLevel_PV_m : real;
	FT_101_InfluentFlow_PV_m3ph : real;
	PIC_101_WetWellLevel_MV_Pct : real;
	P_101A_Speed_Command_Pct : real;
	P_101B_Speed_Command_Pct : real;
	P101_LevelTrips_Active : bool;
	VG101_Inhibit_Active : bool;
	BS101_Disable_Active : bool;
	P_101A_Start_Cmd : bool;
	P_101B_Start_Cmd : bool;
	FT_101 : ANALOG_IN;
	LS_101 : ANALOG_IN;
	PIC_101 : PID_BASIC;
	P_101A : MOTOR_VSD;
	P_101B : MOTOR_VSD;
	XV_101 : VALVE_ON_OFF;
	BS_101 : BOOL_INPUT;
	VG_101 : MOTOR_ON_OFF;
	P101_LevelTrips_OR : bool;
	VG101_Inhibit_OR : bool;
	BS101_Disable_OR : bool;
	PID_Output_Positive_GT : bool;
	P101_LevelTrips_NOT : bool;
	PumpRunEnable_AND : bool;
	StartA_NOT : bool;
	StartB_NOT : bool;
	P101A_Running_NOT : bool;
	P101A_Failure_OR : bool;
	P101B_Start_AND : bool;
	LS101_HighAlarm_NOT : bool;
END_VAR

FT_101(
    Scaling_Slope := 31.25,
    Scaling_Offset := -125.0,
    Alarm_Enable := TRUE);
LS_101(
    PV_High := 8.5,
    PV_Low := 1.5,
    Scaling_Slope := 0.625,
    Scaling_Offset := -2.5,
    Alarm_Enable := TRUE);
PIC_101(
    AUTO := TRUE,
    PV := LS_101.PV,
    SP := 5.5,
    MV_MIN := 30.0,
    MV_MAX := 90.0,
    X0 := 0.0,
    KP := -2.0,
    TR := 1.5,
    TD := 0.3,
    Deviation_Limit := 0.1);
P101_LevelTrips_OR := PIC_101.PV_Low_Alarm OR PIC_101.PV_High_Alarm OR LS_101.High_Alarm;
P101_LevelTrips_NOT := NOT P101_LevelTrips_OR;
PumpRunEnable_AND := P101_LevelTrips_NOT;
StartA_NOT := NOT PumpRunEnable_AND;
P_101A(
    Start_Cmd := PumpRunEnable_AND,
    Stop_Cmd := StartA_NOT,
    Speed_SP := PIC_101.XOUT,
    Inhibit := P101_LevelTrips_OR);
P101A_Running_NOT := NOT P_101A.FB_Running;
P101A_Failure_OR := P_101A.FB_Fault OR P101A_Running_NOT;
P101B_Start_AND := PumpRunEnable_AND AND P101A_Failure_OR;
StartB_NOT := NOT P101B_Start_AND;
P_101B(
    Start_Cmd := P101B_Start_AND,
    Stop_Cmd := StartB_NOT,
    Speed_SP := PIC_101.XOUT,
    Inhibit := P101_LevelTrips_OR);
LS101_HighAlarm_NOT := NOT LS_101.High_Alarm;
XV_101(
    Open_Cmd := LS101_HighAlarm_NOT,
    Close_Cmd := LS_101.High_Alarm);
BS101_Disable_OR := PIC_101.PV_Low_Alarm OR LS_101.Low_Alarm;
BS_101(
    Bool_In := BS101_Disable_OR);
VG101_Inhibit_OR := LS_101.Low_Alarm OR FT_101.Low_Alarm;
VG_101(
    Inhibit := VG101_Inhibit_OR);
PID_Output_Positive_GT := (0.0 > 0.0);

(* Outputs published to other sections / HMI. *)
P101_LevelTrips_Active := P101_LevelTrips_OR;
VG101_Inhibit_Active := VG101_Inhibit_OR;
BS101_Disable_Active := BS101_Disable_OR;
P_101A_Start_Cmd := PumpRunEnable_AND;
P_101B_Start_Cmd := P101B_Start_AND;
LS_101_WetWellLevel_PV_m := LS_101.PV;
FT_101_InfluentFlow_PV_m3ph := FT_101.PV;
PIC_101_WetWellLevel_MV_Pct := PIC_101.XOUT;
P_101A_Speed_Command_Pct := P_101A.Speed_Out;
P_101B_Speed_Command_Pct := P_101B.Speed_Out;

END_PROGRAM
