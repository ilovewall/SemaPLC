PROGRAM Section4
VAR
	LI201_Raw_mA : real;
	XV010_OpenSw_Raw : bool;
	XV011_OpenSw_Raw : bool;
	LI201_Level_PV_Pct : real;
	FIC302_MV_To_FV101_Pct : real;
	FV101_Feedback_Position_Pct : real;
	FIC_302 : PID_BASIC;
	FV_101 : VALVE_ELECTRIC;
	LI_201 : ANALOG_IN;
	XV_010_OPEN_FB : DIGITAL_IN;
	XV_011_OPEN_FB : DIGITAL_IN;
	FlowPathOpen_AND : bool;
	NotFlowPathOpen_NOT : bool;
	FV101ManualMode_OR : bool;
	LIFaultInvert_NOT : bool;
	LoopAutoPermissive_AND : bool;
END_VAR

LI_201(
    Raw_Signal := LI201_Raw_mA,
    PV_High := 80.0,
    PV_Low := 20.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0);
XV_010_OPEN_FB(
    DI_Raw := XV010_OpenSw_Raw);
XV_011_OPEN_FB(
    DI_Raw := XV011_OpenSw_Raw);
FlowPathOpen_AND := XV_010_OPEN_FB.DI_Out AND XV_011_OPEN_FB.DI_Out;
LIFaultInvert_NOT := NOT LI_201.General_Fault;
LoopAutoPermissive_AND := LIFaultInvert_NOT AND FlowPathOpen_AND;
FIC_302(
    AUTO := LoopAutoPermissive_AND,
    PV := LI_201.PV,
    SP := 70.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 25.0,
    KP := 1.8,
    TR := 2.0,
    TD := 0.3);
NotFlowPathOpen_NOT := NOT FlowPathOpen_AND;
FV101ManualMode_OR := NotFlowPathOpen_NOT OR FIC_302.PV_High_Alarm;
FV_101(
    Control_Signal := FIC_302.XOUT,
    Manual_Mode := FV101ManualMode_OR,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0);

(* Outputs published to other sections / HMI. *)
LI201_Level_PV_Pct := LI_201.PV;
FIC302_MV_To_FV101_Pct := FIC_302.XOUT;
FV101_Feedback_Position_Pct := FV_101.Feedback_Pos;

END_PROGRAM
