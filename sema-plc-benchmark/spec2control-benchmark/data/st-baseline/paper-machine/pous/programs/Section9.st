PROGRAM Section9
VAR
	F801_ExhaustFan_Speed_CMD_PCT : real;
	FV801_SteamFlowValve_Position_CMD_PCT : real;
	XV802_HotAirDamper_Position_CMD_PCT : real;
	WT801_DownstreamDriveRoll_Torque_CMD_PCT : real;
	XV802_Open_FB : bool;
	IR801_Available : bool;
	TT_801 : ANALOG_IN;
	TT_802 : ANALOG_IN;
	PT_801 : ANALOG_IN;
	IR_801 : ANALOG_IN;
	WT_801 : ANALOG_IN;
	F_801 : MOTOR_VSD;
	M_801 : MOTOR_ON_OFF;
	FV_801 : VALVE_ELECTRIC;
	XV_802 : VALVE_ELECTRIC;
	SC_801 : PID_BASIC;
	TC_801 : PID_BASIC;
	F_801_CTRL : PID_BASIC;
	WT_801_CTRL : PID_BASIC;
	SteamFlowInterlock : bool;
	XV802NotOpen : bool;
	HoodTempInhibit : bool;
	IR801NotAvailable : bool;
	FanControlInhibit : bool;
	M801NotRunning : bool;
	WebTensionInhibit : bool;
	DriveStop : bool;
END_VAR

TT_801(
    Scaling_Slope := 9.375,
    Scaling_Offset := -37.5,
    Alarm_Enable := TRUE);
TT_802(
    Scaling_Slope := 4.375,
    Scaling_Offset := 32.5,
    Alarm_Enable := TRUE);
PT_801(
    PV_Low := 600.0,
    Alarm_Enable := TRUE);
IR_801(
    PV_High := 5.0,
    Scaling_Slope := 0.625,
    Scaling_Offset := -2.5,
    Alarm_Enable := TRUE);
WT_801(
    Scaling_Slope := 31.25,
    Scaling_Offset := -125.0,
    Alarm_Enable := TRUE);
IR801NotAvailable := NOT IR801_Available;
FanControlInhibit := IR801NotAvailable OR IR_801.High_Alarm OR IR_801.Low_Alarm OR IR_801.General_Fault;
F_801_CTRL(
    AUTO := TRUE,
    PV := IR_801.PV,
    SP := 4.5,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 1.8,
    TR := 0.6,
    TD := 0.05,
    Deviation_Limit := 0.2,
    Inhibit := FanControlInhibit);
F_801(
    Speed_SP := F_801_CTRL.XOUT,
    Inhibit := FanControlInhibit);
DriveStop := WT_801.High_Alarm OR WT_801.Low_Alarm;
M_801(
    Inhibit := DriveStop);
SteamFlowInterlock := PT_801.High_Alarm OR PT_801.Low_Alarm OR SC_801.PV_High_Alarm;
SC_801(
    AUTO := TRUE,
    PV := TT_801.PV,
    SP := 115.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 3.0,
    TR := 0.5,
    TD := 0.1,
    PV_High := 125.0,
    Inhibit := SteamFlowInterlock);
FV_801(
    Control_Signal := SC_801.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := SteamFlowInterlock);
XV802NotOpen := NOT XV802_Open_FB;
HoodTempInhibit := XV802NotOpen OR TT_802.High_Alarm OR TT_802.Low_Alarm;
TC_801(
    AUTO := TRUE,
    PV := TT_802.PV,
    SP := 85.0,
    MV_MIN := 10.0,
    MV_MAX := 90.0,
    KP := 2.5,
    TR := 0.8,
    TD := 0.2,
    PV_High := 95.0,
    Inhibit := HoodTempInhibit);
XV_802(
    Control_Signal := TC_801.XOUT,
    Open_Limit := 90.0,
    Close_Limit := 10.0,
    Inhibit := TC_801.PV_High_Alarm);
M801NotRunning := NOT M_801.FB_Running;
WebTensionInhibit := M801NotRunning OR WT_801.High_Alarm OR WT_801.Low_Alarm;
WT_801_CTRL(
    AUTO := TRUE,
    PV := WT_801.PV,
    SP := 250.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 4.0,
    TR := 1.0,
    TD := 0.3,
    PV_High := 400.0,
    Inhibit := WebTensionInhibit);

(* Outputs published to other sections / HMI. *)
WT801_DownstreamDriveRoll_Torque_CMD_PCT := WT_801_CTRL.XOUT;
F801_ExhaustFan_Speed_CMD_PCT := F_801.Speed_Out;
FV801_SteamFlowValve_Position_CMD_PCT := FV_801.Valve_Position;
XV802_HotAirDamper_Position_CMD_PCT := XV_802.Valve_Position;

END_PROGRAM
