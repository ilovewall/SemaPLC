PROGRAM Section3
VAR
	TIC201_RSP_to_FIC102 : real;
	TT_103 : ANALOG_IN;
	TT_104 : ANALOG_IN;
	PT_203 : ANALOG_IN;
	TIC_201 : PID_BASIC;
	FIC_102 : PID_BASIC;
	FV_102 : VALVE_ELECTRIC;
	PV_106 : VALVE_ELECTRIC;
	XV_101 : VALVE_ON_OFF;
	P_205 : MOTOR_ON_OFF;
	HS_204 : DIGITAL_IN;
	VS_206 : DIGITAL_IN;
	SteamTrip_OR : bool;
	XVNotOpen_NOT : bool;
	FV102_Inhibit_OR : bool;
	FV102_Final_OR : bool;
	SensorsFault_OR : bool;
	TIC201_Inhibit1_OR : bool;
	VacuumOutOfRange_OR : bool;
	TIC201_Inhibit_OR : bool;
	FIC102_Inhibit_OR : bool;
	PV106_Inhibit_OR : bool;
	P205_Inhibit_OR : bool;
END_VAR

TT_103(
    PV_High := 210.0,
    PV_Low := 190.0,
    Alarm_Enable := TRUE);
TT_104(
    Alarm_Enable := TRUE);
PT_203(
    PV_High := 0.5,
    PV_Low := 0.2,
    Alarm_Enable := TRUE);
SensorsFault_OR := TT_103.General_Fault OR TT_104.General_Fault;
HS_204();
SteamTrip_OR := HS_204.DI_Out OR TT_103.High_Alarm;
TIC201_Inhibit1_OR := SteamTrip_OR OR SensorsFault_OR;
VacuumOutOfRange_OR := PT_203.High_Alarm OR PT_203.Low_Alarm;
TIC201_Inhibit_OR := TIC201_Inhibit1_OR OR VacuumOutOfRange_OR;
TIC_201(
    AUTO := TRUE,
    PV := TT_103.PV,
    SP := 198.0,
    MV_MIN := 1.0,
    MV_MAX := 96.0,
    X0 := 0.0,
    KP := 1.2,
    TR := 2.0,
    Deviation_Limit := 0.2,
    Inhibit := TIC201_Inhibit_OR);
FIC102_Inhibit_OR := TIC201_Inhibit1_OR OR TT_104.Low_Alarm;
FIC_102(
    AUTO := TRUE,
    PV := TT_104.PV,
    SP := TIC_201.XOUT,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 3.5,
    TR := 0.3,
    Inhibit := FIC102_Inhibit_OR);
FV102_Inhibit_OR := TIC201_Inhibit1_OR OR TT_104.Low_Alarm;
XV_101(
    Inhibit := TIC201_Inhibit1_OR);
XVNotOpen_NOT := NOT XV_101.FB_Opened;
FV102_Final_OR := FV102_Inhibit_OR OR XVNotOpen_NOT;
FV_102(
    Control_Signal := FIC_102.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FV102_Final_OR);
PV106_Inhibit_OR := VacuumOutOfRange_OR OR SensorsFault_OR;
PV_106(
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := PV106_Inhibit_OR);
P205_Inhibit_OR := TIC_201.PV_Low_Alarm OR SensorsFault_OR;
P_205(
    Inhibit := P205_Inhibit_OR);
VS_206();

(* Outputs published to other sections / HMI. *)
TIC201_RSP_to_FIC102 := TIC_201.XOUT;

END_PROGRAM
