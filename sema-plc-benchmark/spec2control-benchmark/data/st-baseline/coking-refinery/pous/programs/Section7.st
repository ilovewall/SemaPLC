PROGRAM Section7
VAR
	FT601_Raw_mA : real;
	LT601_Raw_mA : real;
	TT104_Raw_mA : real;
	FT601_FlowRate_m3h_PV : real;
	LT601_SiloLevel_Pct_PV : real;
	TT104_Temperature_C_PV : real;
	FIC601_MV_Pct : real;
	P601A_SpeedCmd_Pct : real;
	P601B_SpeedCmd_Pct : real;
	SP_Operator_m3h : real;
	FA601_LowFlow_Alarm : bool;
	LAH601_HighLevel_Alarm : bool;
	TAH104_HighTemp_Alarm : bool;
	Start_Pumps_Cmd : bool;
	Stop_Pumps_Cmd : bool;
	MCC601_Status_In : bool;
	MCC602_Status_In : bool;
	Crusher_RunPermissive : bool;
	Permissive_All_OK : bool;
	FT601_Signal_OK : bool;
	FT_601 : ANALOG_IN;
	LT_601 : ANALOG_IN;
	TT_104 : ANALOG_IN;
	FIC_601 : PID_BASIC;
	P_601A : MOTOR_VSD;
	P_601B : MOTOR_VSD;
	MCC_601 : BOOL_INPUT;
	MCC_602 : BOOL_INPUT;
	StartDelay_TON : TON;
	LowFlowDelay_TON : TON;
	PumpsInhibit_OR : bool;
	LevelPermissive_GE : bool;
	TempPermissive_LE : bool;
	PumpsPermissive_AND : bool;
	FT601Fault_NOT : bool;
	LowFlow_LT : bool;
	PumpA_Start_AND : bool;
	PumpB_Start_AND : bool;
	PumpA_Stop_OR : bool;
	B_StartSource_OR : bool;
	CrusherPermissive_AND : bool;
	SP_ClampHigh_MIN : real;
	SP_ClampLow_MAX : real;
	HighLevel_LT601_GT : bool;
END_VAR

FT_601(
    Raw_Signal := FT601_Raw_mA,
    PV_Low := 80.0,
    Scaling_Slope := 15.625,
    Scaling_Offset := -62.5,
    Alarm_Enable := TRUE);
LT_601(
    Raw_Signal := LT601_Raw_mA,
    PV_High := 90.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
TT_104(
    Raw_Signal := TT104_Raw_mA,
    PV_High := 85.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
FT601Fault_NOT := NOT FT_601.General_Fault;
SP_ClampHigh_MIN := MIN(SP_Operator_m3h, 200.0);
SP_ClampLow_MAX := MAX(SP_ClampHigh_MIN, 100.0);
FIC_601(
    AUTO := FT601Fault_NOT,
    PV := FT_601.PV,
    SP := SP_ClampLow_MAX,
    MV_MIN := 20.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 2.0,
    TR := 1.5,
    TD := 0.3,
    Inhibit := FT_601.General_Fault);
LevelPermissive_GE := (LT_601.PV >= 10.0);
TempPermissive_LE := (TT_104.PV <= 80.0);
PumpsPermissive_AND := LevelPermissive_GE AND TempPermissive_LE;
StartDelay_TON(
    IN := PumpsPermissive_AND,
    PT := T#5s);
PumpA_Start_AND := Start_Pumps_Cmd AND StartDelay_TON.Q;
PumpsInhibit_OR := LT_601.Low_Alarm OR TT_104.High_Alarm;
PumpA_Stop_OR := PumpsInhibit_OR OR Stop_Pumps_Cmd;
P_601A(
    Start_Cmd := PumpA_Start_AND,
    Stop_Cmd := PumpA_Stop_OR,
    Speed_SP := FIC_601.XOUT,
    Accel_Ramp := T#2s,
    Decel_Ramp := T#2s,
    Inhibit := PumpsInhibit_OR);
B_StartSource_OR := P_601A.FB_Fault OR Start_Pumps_Cmd;
PumpB_Start_AND := B_StartSource_OR AND StartDelay_TON.Q;
P_601B(
    Start_Cmd := PumpB_Start_AND,
    Stop_Cmd := PumpA_Stop_OR,
    Speed_SP := FIC_601.XOUT,
    Accel_Ramp := T#2s,
    Decel_Ramp := T#2s,
    Inhibit := PumpsInhibit_OR);
MCC_601(
    Bool_In := MCC601_Status_In);
MCC_602(
    Bool_In := MCC602_Status_In);
LowFlow_LT := (FT_601.PV < 80.0);
LowFlowDelay_TON(
    IN := LowFlow_LT,
    PT := T#10s);
CrusherPermissive_AND := MCC_601.Bool_Out AND MCC_602.Bool_Out;
HighLevel_LT601_GT := (LT_601.PV > 90.0);

(* Outputs published to other sections / HMI. *)
FT601_FlowRate_m3h_PV := FT_601.PV;
LT601_SiloLevel_Pct_PV := LT_601.PV;
TT104_Temperature_C_PV := TT_104.PV;
FIC601_MV_Pct := FIC_601.XOUT;
Permissive_All_OK := StartDelay_TON.Q;
Crusher_RunPermissive := CrusherPermissive_AND;
P601A_SpeedCmd_Pct := P_601A.Speed_Out;
P601B_SpeedCmd_Pct := P_601B.Speed_Out;
FA601_LowFlow_Alarm := LowFlowDelay_TON.Q;
LAH601_HighLevel_Alarm := HighLevel_LT601_GT;
TAH104_HighTemp_Alarm := TT_104.High_Alarm;
FT601_Signal_OK := FT601Fault_NOT;

END_PROGRAM
