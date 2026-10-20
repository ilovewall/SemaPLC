PROGRAM Section7
VAR
	TI_008_Temp_PV : real;
	LI_003_Level_PV : real;
	TIC_106_MV_Pct : real;
	LIC_103_MV_Pct : real;
	XV_105_Valve_Position_Pct : real;
	XV_104_Valve_Position_Pct : real;
	Column3_Start_CMD : bool;
	TIC106_DeviationFault : bool;
	LIC101_Condensate_High : bool;
	LI_003 : ANALOG_IN;
	TI_008 : ANALOG_IN;
	LIC_103 : PID_BASIC;
	TIC_106 : PID_BASIC;
	XV_104 : VALVE_ELECTRIC;
	XV_105 : VALVE_ELECTRIC;
	LIC_101_HI : BOOL_INPUT;
	StartDelay_TON : TON;
	TIC106_DevTON : TON;
	TI8_GT_200 : bool;
	InhibitFinal_OR : bool;
	LI3_Above30_GT : bool;
	SteamStartPermissive_AND : bool;
	InhibitNot_NOT : bool;
	TIC106_Auto_AND : bool;
	LI3_Below15_GT : bool;
	XV104_Close_OR : bool;
	XV104_AutoNot_NOT : bool;
END_VAR

LI_003(
    PV_Low := 10.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
TI_008(
    PV_High := 195.0,
    Scaling_Slope := 15.625,
    Scaling_Offset := -62.5,
    Alarm_Enable := TRUE);
LI3_Below15_GT := (15.0 > LI_003.PV);
XV104_Close_OR := LI_003.Low_Alarm OR LI3_Below15_GT;
XV104_AutoNot_NOT := NOT XV104_Close_OR;
LIC_103(
    AUTO := XV104_AutoNot_NOT,
    PV := LI_003.PV,
    SP := 70.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 2.5,
    TR := 0.8,
    TD := 0.1);
LIC_101_HI(
    Bool_In := LIC101_Condensate_High,
    Alarm_OnTrue := TRUE);
TI8_GT_200 := (TI_008.PV > 200.0);
InhibitFinal_OR := TI8_GT_200 OR LIC_101_HI.Bool_Out;
InhibitNot_NOT := NOT InhibitFinal_OR;
LI3_Above30_GT := (LI_003.PV > 30.0);
StartDelay_TON(
    IN := Column3_Start_CMD,
    PT := T#12s);
SteamStartPermissive_AND := StartDelay_TON.Q AND LI3_Above30_GT;
TIC106_Auto_AND := SteamStartPermissive_AND AND InhibitNot_NOT;
TIC_106(
    AUTO := TIC106_Auto_AND,
    PV := TI_008.PV,
    SP := 180.0,
    MV_MIN := 5.0,
    MV_MAX := 95.0,
    X0 := 0.0,
    KP := -3.2,
    TR := 1.0,
    TD := 0.3,
    Deviation_Limit := 10.0,
    Inhibit := InhibitFinal_OR);
XV_104(
    Control_Signal := LIC_103.XOUT,
    Manual_Mode := XV104_Close_OR,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s);
XV_105(
    Control_Signal := TIC_106.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s,
    Inhibit := InhibitFinal_OR);
TIC106_DevTON(
    IN := TIC_106.Deviation_Alarm,
    PT := T#30s);

(* Outputs published to other sections / HMI. *)
TIC106_DeviationFault := TIC106_DevTON.Q;
TI_008_Temp_PV := TI_008.PV;
LI_003_Level_PV := LI_003.PV;
TIC_106_MV_Pct := TIC_106.XOUT;
LIC_103_MV_Pct := LIC_103.XOUT;
XV_105_Valve_Position_Pct := XV_105.Valve_Position;
XV_104_Valve_Position_Pct := XV_104.Valve_Position;

END_PROGRAM
