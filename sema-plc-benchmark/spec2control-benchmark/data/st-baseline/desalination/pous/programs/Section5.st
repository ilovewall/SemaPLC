PROGRAM Section5
VAR
	FT_301_FlowRate_PV : real;
	LT_301_Level_PV : real;
	FIC_301_MV_FlowControl_Percent : real;
	XV_107_Open_FB : bool;
	FT_301 : ANALOG_IN;
	LT_301 : ANALOG_IN;
	FIC_301 : PID_BASIC;
	FV_301 : VALVE_ELECTRIC;
	XV_107 : VALVE_ON_OFF;
	UMP_301A : MOTOR_VSD;
	UMP_301B : MOTOR_VSD;
	ANK_301 : BOOL_INPUT;
	PAH_103 : DIGITAL_IN;
	TAH_101 : DIGITAL_IN;
	NotXVOpen_NOT : bool;
	PumpsAvailable_OR : bool;
	NotPumpsAvailable_NOT : bool;
	LevelNotAbove20_NOT : bool;
	PumpInhibit_OR : bool;
	ValveTrips_OR : bool;
	PIDInhibit_OR : bool;
END_VAR

FT_301(
    PV_High := 48.0,
    PV_Low := 8.0,
    Scaling_Slope := 3.125,
    Scaling_Offset := -12.5,
    Alarm_Enable := TRUE);
LT_301(
    Alarm_Enable := TRUE);
ANK_301();
LevelNotAbove20_NOT := NOT LT_301.High_Alarm;
UMP_301A(
    Speed_SP := FIC_301.XOUT,
    Inhibit := PumpInhibit_OR);
UMP_301B(
    Inhibit := PumpInhibit_OR);
PumpsAvailable_OR := UMP_301A.FB_Ready OR UMP_301B.FB_Ready;
NotPumpsAvailable_NOT := NOT PumpsAvailable_OR;
XV_107();
NotXVOpen_NOT := NOT XV_107.FB_Opened;
PumpInhibit_OR := NotXVOpen_NOT OR NotPumpsAvailable_NOT OR ANK_301.Bool_Out OR LT_301.Low_Alarm OR LevelNotAbove20_NOT;
PAH_103();
TAH_101();
ValveTrips_OR := PAH_103.DI_Out OR TAH_101.DI_Out OR LT_301.Low_Alarm OR ANK_301.Bool_Out;
PIDInhibit_OR := PumpInhibit_OR OR ValveTrips_OR;
FIC_301(
    PV := FT_301.PV,
    SP := 30.0,
    MV_MIN := 5.0,
    MV_MAX := 95.0,
    X0 := UMP_301A.FB_ActualSpeed,
    KP := 1.8,
    TR := 0.5,
    TD := 0.05,
    Inhibit := PIDInhibit_OR);
FV_301(
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := ValveTrips_OR);

(* Outputs published to other sections / HMI. *)
FT_301_FlowRate_PV := FT_301.PV;
LT_301_Level_PV := LT_301.PV;
FIC_301_MV_FlowControl_Percent := FIC_301.XOUT;
XV_107_Open_FB := XV_107.FB_Opened;

END_PROGRAM
