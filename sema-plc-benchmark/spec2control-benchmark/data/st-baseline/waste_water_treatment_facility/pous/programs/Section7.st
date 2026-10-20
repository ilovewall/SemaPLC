PROGRAM Section7
VAR
	PT_601A_DischargePressure_PV : real;
	PT_601B_DischargePressure_PV : real;
	CL_601_ActiveIsA : bool;
	PS_601_ActiveIsA : bool;
	CL_601A : MOTOR_ON_OFF;
	CL_601B : MOTOR_ON_OFF;
	PS_601A : MOTOR_ON_OFF;
	PS_601B : MOTOR_ON_OFF;
	PT_601A : ANALOG_IN;
	PT_601B : ANALOG_IN;
	LS_601 : DIGITAL_IN;
	VS_601A : VALVE_ELECTRIC;
	VS_601B : VALVE_ELECTRIC;
	CL_601A_CL_601B : DUTY_STANDBY;
	PS_601A_PS_601B : DUTY_STANDBY;
	Clar_MinRunTimer_TON : TON;
	Clar_DutyTimer_TON : TON;
	Clar_SwitchoverDelay_TON : TON;
	Pump_MinRunTimer_TON : TON;
	Pump_DutyTimer_TON : TON;
	Pump_SwitchoverDelay_TON : TON;
	ClarifierAnyRunning_OR : bool;
	ClarifierNoneRunning_NOT : bool;
	PumpAnyRunning_OR : bool;
	PumpNoneRunning_NOT : bool;
	PS601A_Inhibit_OR : bool;
	PS601B_Inhibit_OR : bool;
END_VAR

LS_601();
CL_601B(
    Start_Cmd := CL_601A_CL_601B.CmdPumpB,
    Start_Delay := T#5s,
    MinRunTime := T#30m,
    Inhibit := LS_601.DI_Out);
ClarifierAnyRunning_OR := CL_601A.FB_Running OR CL_601B.FB_Running;
Clar_DutyTimer_TON(
    IN := ClarifierAnyRunning_OR,
    PT := T#72h);
Clar_MinRunTimer_TON(
    IN := ClarifierAnyRunning_OR,
    PT := T#30m);
ClarifierNoneRunning_NOT := NOT ClarifierAnyRunning_OR;
Clar_SwitchoverDelay_TON(
    IN := ClarifierNoneRunning_NOT,
    PT := T#10s);
CL_601A_CL_601B(
    Enable := TRUE,
    StartRequest := TRUE,
    AlternateEnable := TRUE,
    DutyElapsed := Clar_DutyTimer_TON.Q,
    MinRunElapsed := Clar_MinRunTimer_TON.Q,
    SwitchoverDelayElapsed := Clar_SwitchoverDelay_TON.Q,
    PumpA_RunFB := CL_601A.FB_Running,
    PumpB_RunFB := CL_601B.FB_Running,
    PumpA_Fault := CL_601A.FB_Trip,
    PumpB_Fault := CL_601B.FB_Trip,
    Inhibit := LS_601.DI_Out);
CL_601A(
    Start_Cmd := CL_601A_CL_601B.CmdPumpA,
    Start_Delay := T#5s,
    MinRunTime := T#30m,
    Inhibit := LS_601.DI_Out);
PT_601A(
    PV_Low := 25.0,
    Alarm_Enable := TRUE);
PS601A_Inhibit_OR := PT_601A.Low_Alarm OR LS_601.DI_Out;
PT_601B(
    PV_Low := 25.0,
    Alarm_Enable := TRUE);
PS601B_Inhibit_OR := PT_601B.Low_Alarm OR LS_601.DI_Out;
PS_601B(
    Start_Cmd := PS_601A_PS_601B.CmdPumpB,
    Start_Delay := T#5s,
    MinRunTime := T#30m,
    Inhibit := PS601B_Inhibit_OR);
PumpAnyRunning_OR := PS_601A.FB_Running OR PS_601B.FB_Running;
Pump_DutyTimer_TON(
    IN := PumpAnyRunning_OR,
    PT := T#72h);
Pump_MinRunTimer_TON(
    IN := PumpAnyRunning_OR,
    PT := T#30m);
PumpNoneRunning_NOT := NOT PumpAnyRunning_OR;
Pump_SwitchoverDelay_TON(
    IN := PumpNoneRunning_NOT,
    PT := T#10s);
PS_601A_PS_601B(
    Enable := TRUE,
    StartRequest := TRUE,
    AlternateEnable := TRUE,
    DutyElapsed := Pump_DutyTimer_TON.Q,
    MinRunElapsed := Pump_MinRunTimer_TON.Q,
    SwitchoverDelayElapsed := Pump_SwitchoverDelay_TON.Q,
    PumpA_RunFB := PS_601A.FB_Running,
    PumpB_RunFB := PS_601B.FB_Running,
    PumpA_Fault := PS_601A.FB_Trip,
    PumpB_Fault := PS_601B.FB_Trip,
    Inhibit := LS_601.DI_Out);
PS_601A(
    Start_Cmd := PS_601A_PS_601B.CmdPumpA,
    Start_Delay := T#5s,
    MinRunTime := T#30m,
    Inhibit := PS601A_Inhibit_OR);
VS_601A(
    Open_Limit := 100.0,
    Close_Limit := 0.0);
VS_601B(
    Open_Limit := 100.0,
    Close_Limit := 0.0);

(* Outputs published to other sections / HMI. *)
PT_601A_DischargePressure_PV := PT_601A.PV;
PT_601B_DischargePressure_PV := PT_601B.PV;
CL_601_ActiveIsA := CL_601A_CL_601B.ActiveIsA;
PS_601_ActiveIsA := PS_601A_PS_601B.ActiveIsA;

END_PROGRAM
