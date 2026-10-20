PROGRAM Section5
VAR
	TIT106_ReboilerTemp_PV : real;
	LT107_Column2Level_PV : real;
	TIC106_FV105_SteamFlow_MV : real;
	LIC107_LV102_Outflow_MV : real;
	TIT_106 : ANALOG_IN;
	LT_107 : ANALOG_IN;
	TIC_106 : PID_BASIC;
	LIC_107 : PID_BASIC;
	FV_105 : VALVE_ELECTRIC;
	LV_102 : VALVE_ELECTRIC;
	CONDENSATE_RETURN_VALVE_OPEN_LS : DIGITAL_IN;
	SteamValveInhibitLogic : bool;
	CondensateNotOpen : bool;
END_VAR

TIT_106(
    PV_High := 260.0,
    Scaling_Slope := 18.75,
    Scaling_Offset := -75.0,
    Alarm_Enable := TRUE);
LT_107(
    PV_High := 80.0,
    PV_Low := 20.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
TIC_106(
    AUTO := TRUE,
    PV := TIT_106.PV,
    SP := 200.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := -3.0,
    TR := 1.2,
    TD := 0.2);
LIC_107(
    AUTO := TRUE,
    PV := LT_107.PV,
    SP := 50.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 2.5,
    TR := 1.0,
    TD := 0.0);
CONDENSATE_RETURN_VALVE_OPEN_LS();
CondensateNotOpen := NOT CONDENSATE_RETURN_VALVE_OPEN_LS.DI_Out;
SteamValveInhibitLogic := CondensateNotOpen OR TIC_106.PV_High_Alarm;
FV_105(
    Control_Signal := TIC_106.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := SteamValveInhibitLogic);
LV_102(
    Control_Signal := LIC_107.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := LIC_107.PV_Low_Alarm);

(* Outputs published to other sections / HMI. *)
TIT106_ReboilerTemp_PV := TIT_106.PV;
LT107_Column2Level_PV := LT_107.PV;
TIC106_FV105_SteamFlow_MV := TIC_106.XOUT;
LIC107_LV102_Outflow_MV := LIC_107.XOUT;

END_PROGRAM
