PROGRAM Section3
VAR
	TT201_Temperature_PV : real;
	PT201_FlashTankPressure_PV : real;
	LT201_AbsorberLevel_PV : real;
	AI201_CO2_PV : real;
	TIC201_MV_SteamValveCmd : real;
	AI_201 : ANALOG_IN;
	LT_201 : ANALOG_IN;
	PT_201 : ANALOG_IN;
	TT_201 : ANALOG_IN;
	TIC_201 : PID_BASIC;
	FV_101 : VALVE_ELECTRIC;
	TIC201_Inhibit_OR : bool;
	FV101_Inhibit_OR : bool;
END_VAR

AI_201(
    Alarm_Enable := TRUE);
LT_201(
    Alarm_Enable := TRUE);
PT_201(
    PV_Low := 0.5,
    Alarm_Enable := TRUE);
TT_201(
    PV_High := 50.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
TIC201_Inhibit_OR := TT_201.High_Alarm OR PT_201.Low_Alarm OR AI_201.High_Alarm OR TT_201.General_Fault;
FV101_Inhibit_OR := TIC201_Inhibit_OR OR LT_201.Low_Alarm;
FV_101(
    Control_Signal := TIC_201.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FV101_Inhibit_OR);
TIC_201(
    AUTO := TRUE,
    PV := TT_201.PV,
    SP := 45.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := FV_101.Feedback_Pos,
    KP := 3.0,
    TR := 1.5,
    TD := 0.0,
    Deviation_Limit := 5.0,
    Inhibit := TIC201_Inhibit_OR);

(* Outputs published to other sections / HMI. *)
TT201_Temperature_PV := TT_201.PV;
PT201_FlashTankPressure_PV := PT_201.PV;
LT201_AbsorberLevel_PV := LT_201.PV;
AI201_CO2_PV := AI_201.PV;
TIC201_MV_SteamValveCmd := TIC_201.XOUT;

END_PROGRAM
