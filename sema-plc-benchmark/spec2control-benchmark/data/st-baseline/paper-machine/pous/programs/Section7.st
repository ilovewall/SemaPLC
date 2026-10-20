PROGRAM Section7
VAR
	CT_601_PV : real;
	FT_601_PV : real;
	FT_601_SP : real;
	PIT_601_PV : real;
	VT_601_PV : real;
	FS_601_MinFlow_OK : bool;
	P_601_Run_OK : bool;
	FFIC601_Bias : real;
	ALM_601 : bool;
	ALM_601_High : bool;
	ALM_601_Low : bool;
	ALM_602 : bool;
	ALM_603 : bool;
	ALM_604 : bool;
	Process_Permissives_OK : bool;
	MasterInhibit : bool;
	CT601_RateHigh : bool;
	CT_601 : ANALOG_IN;
	FT_601 : ANALOG_IN;
	PIT_601 : ANALOG_IN;
	VT_601 : ANALOG_IN;
	FS_601 : BOOL_INPUT;
	P_601_RUN : BOOL_INPUT;
	FV_601 : VALVE_ELECTRIC;
	FIC_601 : PID_BASIC;
	FFIC_601 : RATIO_CONTROL;
	ProcessUpset_Timer : TON;
	PumpRun_Fault : bool;
	MinFlow_Fault : bool;
	CT_Failure : bool;
	FT_Failure : bool;
	Inhibit_Any : bool;
	Auto_Enable : bool;
	SlaveSP_TooHigh : bool;
	SlaveSP_TooLow : bool;
	SlaveSP_LimitAlarm : bool;
END_VAR

CT_601(
    Alarm_Enable := TRUE);
FT_601(
    PV_High := 500.0,
    PV_Low := 10.0,
    Alarm_Enable := TRUE);
PIT_601(
    PV_Low := 300.0,
    Alarm_Enable := TRUE);
VT_601(
    Alarm_Enable := TRUE);
FS_601(
    Alarm_OnFalse := TRUE);
P_601_RUN(
    Alarm_OnFalse := TRUE);
CT_Failure := CT_601.High_Alarm OR CT_601.Low_Alarm OR CT_601.General_Fault;
FT_Failure := FT_601.High_Alarm OR FT_601.Low_Alarm OR FT_601.General_Fault;
MinFlow_Fault := NOT FS_601.Bool_Out;
PumpRun_Fault := NOT P_601_RUN.Bool_Out;
Inhibit_Any := PumpRun_Fault OR MinFlow_Fault OR PIT_601.Low_Alarm OR VT_601.Low_Alarm OR CT_Failure OR FT_Failure;
Auto_Enable := NOT Inhibit_Any;
FFIC_601(
    Auto := Auto_Enable,
    PrimaryPV := CT_601.PV,
    SecondaryPV := FT_601.PV,
    RatioSP := 2.5,
    Bias := FFIC601_Bias,
    TrimKp := 0.1,
    TrimTi := T#2s,
    MV_MIN := 10.0,
    MV_MAX := 500.0,
    Inhibit := Inhibit_Any);
FIC_601(
    AUTO := Auto_Enable,
    PV := FT_601.PV,
    SP := FFIC_601.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 20.0,
    Inhibit := Inhibit_Any);
FV_601(
    Control_Signal := FIC_601.XOUT,
    Manual_Mode := Inhibit_Any,
    Manual_Position := 20.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := Inhibit_Any);
ProcessUpset_Timer(
    IN := CT601_RateHigh,
    PT := T#10s);
SlaveSP_TooHigh := (FFIC_601.SlaveSP > 500.0);
SlaveSP_TooLow := (FFIC_601.SlaveSP < 10.0);
SlaveSP_LimitAlarm := SlaveSP_TooHigh OR SlaveSP_TooLow;

(* Outputs published to other sections / HMI. *)
ALM_601 := SlaveSP_LimitAlarm;
ALM_602 := CT_Failure;
ALM_603 := FT_Failure;
ALM_604 := ProcessUpset_Timer.Q;
CT_601_PV := CT_601.PV;
FT_601_PV := FT_601.PV;
FT_601_SP := FFIC_601.SlaveSP;
PIT_601_PV := PIT_601.PV;
VT_601_PV := VT_601.PV;
FS_601_MinFlow_OK := FS_601.Bool_Out;
P_601_Run_OK := P_601_RUN.Bool_Out;
MasterInhibit := Inhibit_Any;
Process_Permissives_OK := Auto_Enable;

END_PROGRAM
