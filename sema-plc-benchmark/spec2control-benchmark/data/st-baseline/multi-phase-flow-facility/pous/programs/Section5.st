PROGRAM Section5
VAR
	FIC101_MV_PCT : real;
	FIC102_MV_PCT : real;
	P001_Speed_AO_PCT : real;
	P001_Start_Cmd : bool;
	P001_Stop_Cmd : bool;
	FT102_FlowOK_Thresh : real;
	ValveOpenFB_Threshold : real;
	LevelOK_Threshold : real;
	FIC101_Deviation_Alarm_15s : bool;
	FIC102_Deviation_Alarm_15s : bool;
	FT_102 : ANALOG_IN;
	FT_104 : ANALOG_IN;
	LI_101 : ANALOG_IN;
	FIC_101 : PID_BASIC;
	FIC_102 : PID_BASIC;
	FV_103 : VALVE_ELECTRIC;
	P_001 : MOTOR_VSD;
	FlowOK_TON : TON;
	FIC101_Dev_TON : TON;
	FIC102_Dev_TON : TON;
	FIC101_ForceManual_OR : bool;
	FIC102_ForceManual_OR : bool;
	FIC101_AutoEnable_NOT : bool;
	FIC102_AutoEnable_NOT : bool;
	FT102_GT_10GPM : bool;
	ValveOpenPermissive_AND : bool;
	ValveOpenInhibit_NOT : bool;
	ValveInhibit_OR : bool;
	LevelOK_GT25 : bool;
	ValveFB_GT_90PCT : bool;
	P001_StartPermissive_AND : bool;
	P001_Stop_OR : bool;
END_VAR

(* Constant configuration values. *)
FT102_FlowOK_Thresh := 10.0;
ValveOpenFB_Threshold := 90.0;
LevelOK_Threshold := 25.0;

FT_102(
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0);
FT_104(
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0);
LI_101(
    PV_High := 90.0,
    PV_Low := 20.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0);
FIC101_ForceManual_OR := LI_101.Low_Alarm OR LI_101.High_Alarm OR FT_102.General_Fault;
FIC101_AutoEnable_NOT := NOT FIC101_ForceManual_OR;
FIC_101(
    AUTO := FIC101_AutoEnable_NOT,
    PV := FT_102.PV,
    SP := 50.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 2.0,
    TR := 1.0,
    TD := 0.1,
    Deviation_Limit := 10.0);
FIC102_ForceManual_OR := LI_101.Low_Alarm OR LI_101.High_Alarm OR FT_104.General_Fault;
FIC102_AutoEnable_NOT := NOT FIC102_ForceManual_OR;
FIC_102(
    AUTO := FIC102_AutoEnable_NOT,
    PV := FT_104.PV,
    SP := 45.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 2.0,
    TR := 1.0,
    TD := 0.1,
    Deviation_Limit := 8.0);
FT102_GT_10GPM := (FT_102.PV > FT102_FlowOK_Thresh);
FlowOK_TON(
    IN := FT102_GT_10GPM,
    PT := T#8s);
LevelOK_GT25 := (LI_101.PV > LevelOK_Threshold);
ValveFB_GT_90PCT := (FV_103.Feedback_Pos > ValveOpenFB_Threshold);
P001_StartPermissive_AND := P001_Start_Cmd AND LevelOK_GT25 AND ValveFB_GT_90PCT;
P001_Stop_OR := P001_Stop_Cmd OR LI_101.General_Fault;
P_001(
    Start_Cmd := P001_StartPermissive_AND,
    Stop_Cmd := P001_Stop_OR,
    Speed_SP := FIC_102.XOUT,
    Inhibit := LI_101.General_Fault);
ValveOpenPermissive_AND := P_001.FB_Running AND FlowOK_TON.Q;
ValveOpenInhibit_NOT := NOT ValveOpenPermissive_AND;
ValveInhibit_OR := ValveOpenInhibit_NOT OR LI_101.General_Fault;
FV_103(
    Control_Signal := FIC_101.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 25.0,
    Close_Limit := 0.0,
    Inhibit := ValveInhibit_OR);
FIC101_Dev_TON(
    IN := FIC_101.Deviation_Alarm,
    PT := T#15s);
FIC102_Dev_TON(
    IN := FIC_102.Deviation_Alarm,
    PT := T#15s);

(* Outputs published to other sections / HMI. *)
FIC101_Deviation_Alarm_15s := FIC101_Dev_TON.Q;
FIC102_Deviation_Alarm_15s := FIC102_Dev_TON.Q;
FIC101_MV_PCT := FIC_101.XOUT;
FIC102_MV_PCT := FIC_102.XOUT;
P001_Speed_AO_PCT := P_001.Speed_Out;

END_PROGRAM
