PROGRAM Section5
VAR
	TT401_CoolerOutletTemp_PV : real;
	FT402_AntiCakingFlow_PV : real;
	TIC401_RSP_to_FIC402 : real;
	FIC402_MV_to_FV402 : real;
	FIC402_SP_Manual : real;
	TIC_401 : PID_BASIC;
	TT_401 : ANALOG_IN;
	FIC_402 : PID_BASIC;
	FT_402 : ANALOG_IN;
	FV_402 : VALVE_ELECTRIC;
	MP_405 : MOTOR_ON_OFF;
	PS_403 : BOOL_INPUT;
	PSA_404 : DIGITAL_IN;
	TempError_SUB : real;
	ErrorAbs_ABS : real;
	Deadband_GT : bool;
	RSP_Scale_MUL : real;
	RSP_Select_SEL : real;
	TT401_OutOfRange_OR : bool;
	TT401_Bad_OR : bool;
	FT402_OutOfRange_OR : bool;
	FT402_Bad_OR : bool;
	PermissiveFaults_OR1 : bool;
	PermissiveFaults_OR2 : bool;
	CascadeInhibit_OR : bool;
END_VAR

FT_402(
    Scaling_Slope := 1.0,
    Scaling_Offset := 0.0,
    Alarm_Enable := TRUE);
FT402_OutOfRange_OR := FT_402.High_Alarm OR FT_402.Low_Alarm;
FT402_Bad_OR := FT402_OutOfRange_OR OR FT_402.General_Fault;
TT_401(
    Scaling_Slope := 1.0,
    Scaling_Offset := 0.0,
    Alarm_Enable := TRUE);
TT401_OutOfRange_OR := TT_401.High_Alarm OR TT_401.Low_Alarm;
TT401_Bad_OR := TT401_OutOfRange_OR OR TT_401.General_Fault;
PermissiveFaults_OR1 := TT401_Bad_OR OR FT402_Bad_OR;
PSA_404();
PS_403();
PermissiveFaults_OR2 := PS_403.Bool_Out OR PSA_404.DI_Out;
CascadeInhibit_OR := PermissiveFaults_OR1 OR PermissiveFaults_OR2;
TIC_401(
    AUTO := TRUE,
    PV := TT_401.PV,
    SP := 45.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 1.2,
    TR := 2.0,
    PV_High := 50.0,
    PV_Low := 40.0,
    Deviation_Limit := 2.0,
    Inhibit := CascadeInhibit_OR);
TempError_SUB := 45.0 - TT_401.PV;
ErrorAbs_ABS := ABS(TempError_SUB);
Deadband_GT := (ErrorAbs_ABS > 0.5);
RSP_Scale_MUL := TIC_401.XOUT * 0.1;
RSP_Select_SEL := SEL(G := Deadband_GT, IN0 := FIC402_SP_Manual, IN1 := RSP_Scale_MUL);
FIC_402(
    AUTO := TRUE,
    PV := FT_402.PV,
    SP := RSP_Select_SEL,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 3.5,
    TR := 0.3,
    PV_High := 10.0,
    PV_Low := 0.5,
    Inhibit := CascadeInhibit_OR);
FV_402(
    Control_Signal := FIC_402.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := CascadeInhibit_OR);
MP_405(
    Inhibit := CascadeInhibit_OR);

(* Outputs published to other sections / HMI. *)
TT401_CoolerOutletTemp_PV := TT_401.PV;
FT402_AntiCakingFlow_PV := FT_402.PV;
TIC401_RSP_to_FIC402 := TIC_401.XOUT;
FIC402_MV_to_FV402 := FIC_402.XOUT;

END_PROGRAM
