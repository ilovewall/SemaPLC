PROGRAM Section3
VAR
	Reboiler_Temperature_PV_TI106 : real;
	Steam_Flow_PV_FIT101 : real;
	Column_Pressure_PV_PT101 : real;
	FIC104_MV_SteamValveCmd : real;
	LIC002_LowLevel_Trip : bool;
	TI_106 : ANALOG_IN;
	FIT_101 : ANALOG_IN;
	PT_101 : ANALOG_IN;
	FIC_104 : PID_BASIC;
	TCV_106 : VALVE_ELECTRIC;
	LIC_002 : BOOL_INPUT;
	TAH_106 : BOOL_INPUT;
	TAL_106 : BOOL_INPUT;
	FAH_104 : BOOL_INPUT;
	ReboilerTrip_OR : bool;
END_VAR

TI_106(
    PV_High := 190.0,
    PV_Low := 170.0,
    Scaling_Slope := 9.375,
    Scaling_Offset := 62.5,
    Alarm_Enable := TRUE);
FIT_101(
    PV_Low := 10.0,
    Alarm_Enable := TRUE);
PT_101(
    Alarm_Enable := TRUE);
LIC_002(
    Bool_In := LIC002_LowLevel_Trip,
    Alarm_OnTrue := TRUE);
ReboilerTrip_OR := LIC_002.Bool_Out OR FIC_104.PV_High_Alarm OR TI_106.General_Fault OR PT_101.Low_Alarm;
TCV_106(
    Control_Signal := FIC_104.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := ReboilerTrip_OR);
FIC_104(
    AUTO := TRUE,
    PV := TI_106.PV,
    SP := 180.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := TCV_106.Feedback_Pos,
    KP := 3.0,
    TR := 1.2,
    TD := 0.3,
    Inhibit := ReboilerTrip_OR);
TAH_106(
    Bool_In := TI_106.High_Alarm,
    Alarm_OnTrue := TRUE);
TAL_106(
    Bool_In := TI_106.Low_Alarm,
    Alarm_OnTrue := TRUE);
FAH_104(
    Bool_In := FIT_101.Low_Alarm,
    Alarm_OnTrue := TRUE);

(* Outputs published to other sections / HMI. *)
Reboiler_Temperature_PV_TI106 := TI_106.PV;
Steam_Flow_PV_FIT101 := FIT_101.PV;
Column_Pressure_PV_PT101 := PT_101.PV;
FIC104_MV_SteamValveCmd := FIC_104.XOUT;

END_PROGRAM