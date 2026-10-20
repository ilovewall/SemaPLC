PROGRAM Section4
VAR
	RTD302_BedTemp_PV : real;
	FT301_Flow_PV : real;
	TIC302_RSP_to_FIC301 : real;
	FIC301_MV_Out_to_FV301 : real;
	AT303_Humidity_PV : real;
	PR305_TowerPressure_PV : real;
	VS304_Vibration_PV : real;
	AT_303 : ANALOG_IN;
	FIC_301 : PID_BASIC;
	FT_301 : ANALOG_IN;
	FV_301 : VALVE_ELECTRIC;
	PR_305 : ANALOG_IN;
	RTD_302 : ANALOG_IN;
	TIC_302 : PID_BASIC;
	VS_304 : ANALOG_IN;
	GR_306 : BOOL_INPUT;
	NotCollecting_NOT : bool;
	FICInterlock_OR : bool;
	CascadeInterlock_OR : bool;
END_VAR

AT_303(
    Alarm_Enable := TRUE);
FT_301(
    Alarm_Enable := TRUE);
FV_301(
    Control_Signal := FIC_301.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FV_301.Position_Error);
FICInterlock_OR := FT_301.High_Alarm OR FV_301.Position_Error OR FT_301.General_Fault OR FT_301.Low_Alarm;
GR_306(
    Alarm_OnTrue := FALSE,
    Alarm_OnFalse := TRUE,
    Latch_Enable := FALSE);
NotCollecting_NOT := NOT GR_306.Bool_Out;
RTD_302(
    PV_High := 200.0,
    PV_Low := 150.0,
    Alarm_Enable := TRUE);
VS_304();
CascadeInterlock_OR := RTD_302.High_Alarm OR AT_303.High_Alarm OR VS_304.General_Fault OR FT_301.General_Fault OR RTD_302.General_Fault OR NotCollecting_NOT OR RTD_302.Low_Alarm;
TIC_302(
    AUTO := TRUE,
    PV := RTD_302.PV,
    SP := 185.0,
    MV_MIN := 2.5,
    MV_MAX := 5.0,
    KP := 1.2,
    TR := 2.0,
    TD := 0.0,
    Deviation_Limit := 5.0,
    Inhibit := CascadeInterlock_OR);
FIC_301(
    AUTO := TRUE,
    PV := FT_301.PV,
    SP := TIC_302.XOUT,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 3.5,
    TR := 0.3,
    TD := 0.0,
    Deviation_Limit := 0.1,
    Inhibit := FICInterlock_OR);
PR_305();

(* Outputs published to other sections / HMI. *)
RTD302_BedTemp_PV := RTD_302.PV;
FT301_Flow_PV := FT_301.PV;
TIC302_RSP_to_FIC301 := TIC_302.XOUT;
FIC301_MV_Out_to_FV301 := FIC_301.XOUT;
AT303_Humidity_PV := AT_303.PV;
PR305_TowerPressure_PV := PR_305.PV;
VS304_Vibration_PV := VS_304.PV;

END_PROGRAM
