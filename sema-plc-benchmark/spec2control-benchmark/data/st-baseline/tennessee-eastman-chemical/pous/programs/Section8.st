PROGRAM Section8
VAR
	LT102_Level_PV_Pct : real;
	FIT105_Flow_PV_LPM : real;
	LIC106_MV_To_XV101_Pct : real;
	FC008_MV_To_PV104_Pct : real;
	Decanter2_Online : bool;
	FIT_105 : ANALOG_IN;
	LT_102 : ANALOG_IN;
	LT_103 : ANALOG_IN;
	LT_107 : ANALOG_IN;
	LIC_106 : PID_BASIC;
	FC_008 : PID_BASIC;
	XV_101 : VALVE_ELECTRIC;
	PV_104 : VALVE_ELECTRIC;
	LIC106_StartupDelay : TON;
	FC8_StartupDelay : TON;
	LT102_SignalFaults_A : bool;
	LT102_SignalFaults : bool;
	LT103_Above90Check : bool;
	LIC106_ForceClose_A : bool;
	LIC106_ForceClose : bool;
	LIC106_ForceCloseClear : bool;
	LIC106_AutoEnable : bool;
	FIT105_HighLow : bool;
	FIT105_Invalid : bool;
	FC8_SignalValid : bool;
	LT107_Below20Check : bool;
	FC8_NoForceClose : bool;
	FC8_AutoBase : bool;
	FC8_AutoInterlocks : bool;
	FC8_AutoEnable : bool;
	FC8_ForceOpen : bool;
	FC8_InhibitLogic : bool;
END_VAR

FIT_105(
    Scaling_Slope := 9.375,
    Scaling_Offset := -37.5,
    Alarm_Enable := TRUE);
LT_102(
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
LT_103(
    PV_High := 85.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
LT_107(
    PV_Low := 15.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
LT102_SignalFaults_A := LT_102.High_Alarm OR LT_102.Low_Alarm;
LT102_SignalFaults := LT102_SignalFaults_A OR LT_102.General_Fault;
LT103_Above90Check := (LT_103.PV > 90.0);
LIC106_ForceClose_A := LT103_Above90Check OR LT102_SignalFaults;
XV_101(
    Control_Signal := LIC_106.XOUT,
    Manual_Mode := LIC106_ForceClose,
    Manual_Position := 0.0,
    Timeout := T#10s,
    Inhibit := LIC106_ForceClose);
LIC106_ForceClose := LIC106_ForceClose_A OR XV_101.Alarm;
LIC106_ForceCloseClear := NOT LIC106_ForceClose;
LIC106_StartupDelay(
    IN := TRUE,
    PT := T#14s);
LIC106_AutoEnable := LIC106_StartupDelay.Q AND LIC106_ForceCloseClear;
LIC_106(
    AUTO := LIC106_AutoEnable,
    PV := LT_102.PV,
    SP := 65.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := -3.0,
    TR := 1.2,
    TD := 0.0,
    Inhibit := LIC106_ForceClose);
FIT105_HighLow := FIT_105.High_Alarm OR FIT_105.Low_Alarm;
FIT105_Invalid := FIT105_HighLow OR FIT_105.General_Fault;
FC8_SignalValid := NOT FIT105_Invalid;
FC8_StartupDelay(
    IN := TRUE,
    PT := T#14s);
FC8_AutoBase := FC8_StartupDelay.Q AND FC8_SignalValid;
LT107_Below20Check := (LT_107.PV < 20.0);
FC8_NoForceClose := NOT LT107_Below20Check;
FC8_AutoInterlocks := Decanter2_Online AND FC8_NoForceClose;
FC8_AutoEnable := FC8_AutoBase AND FC8_AutoInterlocks;
PV_104(
    Control_Signal := FC_008.XOUT,
    Manual_Mode := LT107_Below20Check,
    Manual_Position := 0.0,
    Inhibit := FC8_InhibitLogic);
FC8_ForceOpen := FIT_105.General_Fault OR PV_104.Alarm;
FC8_InhibitLogic := LT107_Below20Check OR FC8_ForceOpen;
FC_008(
    AUTO := FC8_AutoEnable,
    PV := FIT_105.PV,
    SP := 120.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 100.0,
    KP := 2.5,
    TR := 0.8,
    TD := 0.2,
    Deviation_Limit := 12.0,
    Inhibit := FC8_InhibitLogic);

(* Outputs published to other sections / HMI. *)
LT102_Level_PV_Pct := LT_102.PV;
FIT105_Flow_PV_LPM := FIT_105.PV;
LIC106_MV_To_XV101_Pct := LIC_106.XOUT;
FC008_MV_To_PV104_Pct := FC_008.XOUT;

END_PROGRAM
