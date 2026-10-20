PROGRAM Section10
VAR
	FT_901_FlowRate : real;
	LS_901_LevelPercent : real;
	P_901A_Running : bool;
	P_901B_Running : bool;
	P_901AB_DutyActiveIsA : bool;
	P_901AB_SwitchedDueToDuty : bool;
	P_901AB_SwitchedDueToFailure : bool;
	FT_901 : ANALOG_IN;
	LS_901 : ANALOG_IN;
	P_901A : MOTOR_ON_OFF;
	P_901B : MOTOR_ON_OFF;
	XV_102 : VALVE_ON_OFF;
	P_901AB : DUTY_STANDBY;
	DutyTimer_TON : TON;
	FailA_TON : TON;
	FailB_TON : TON;
	SwitchoverDelay_TON : TON;
	AnyRunning_OR : bool;
	StartBand_AND : bool;
	LevelAbove60_GT : bool;
	LevelAbove40_GT : bool;
	LevelAbove85_GT : bool;
	StartRequest_OR : bool;
	FlowLessThan15_GT : bool;
	FailCondA_AND : bool;
	FailCondB_AND : bool;
	Failure_OR : bool;
	StartCmdA_OR : bool;
	StartCmdB_OR : bool;
	PumpA_Inhibit_OR : bool;
	PumpB_Inhibit_OR : bool;
	BothPumpsFailed_AND : bool;
END_VAR

FT_901(
    Alarm_Enable := TRUE);
LS_901(
    PV_High := 90.0,
    Alarm_Enable := TRUE);
FlowLessThan15_GT := (REAL#15.0 > FT_901.PV);
FailCondA_AND := P_901A.FB_Running AND FlowLessThan15_GT;
FailA_TON(
    IN := FailCondA_AND,
    PT := T#10s);
PumpA_Inhibit_OR := LS_901.Low_Alarm OR FailA_TON.Q OR P_901A.FB_Trip;
LevelAbove85_GT := (LS_901.PV > REAL#85.0);
FailCondB_AND := P_901B.FB_Running AND FlowLessThan15_GT;
FailB_TON(
    IN := FailCondB_AND,
    PT := T#10s);
PumpB_Inhibit_OR := LS_901.Low_Alarm OR FailB_TON.Q OR P_901B.FB_Trip;
StartCmdB_OR := LevelAbove85_GT OR P_901AB.CmdPumpB;
P_901B(
    Start_Cmd := StartCmdB_OR,
    MinRunTime := T#30m,
    Inhibit := PumpB_Inhibit_OR);
AnyRunning_OR := P_901A.FB_Running OR P_901B.FB_Running;
DutyTimer_TON(
    IN := AnyRunning_OR,
    PT := T#48h);
LevelAbove60_GT := (LS_901.PV > REAL#60.0);
LevelAbove40_GT := (LS_901.PV > REAL#40.0);
StartBand_AND := AnyRunning_OR AND LevelAbove40_GT;
StartRequest_OR := LevelAbove60_GT OR StartBand_AND;
Failure_OR := FailA_TON.Q OR FailB_TON.Q;
SwitchoverDelay_TON(
    IN := Failure_OR,
    PT := T#5s);
P_901AB(
    Enable := TRUE,
    StartRequest := StartRequest_OR,
    AlternateEnable := TRUE,
    DutyElapsed := DutyTimer_TON.Q,
    SwitchoverDelayElapsed := SwitchoverDelay_TON.Q,
    PumpA_RunFB := P_901A.FB_Running,
    PumpB_RunFB := P_901B.FB_Running,
    PumpA_Fault := FailA_TON.Q,
    PumpB_Fault := FailB_TON.Q);
StartCmdA_OR := LevelAbove85_GT OR P_901AB.CmdPumpA;
P_901A(
    Start_Cmd := StartCmdA_OR,
    MinRunTime := T#30m,
    Inhibit := PumpA_Inhibit_OR);
BothPumpsFailed_AND := FailA_TON.Q AND FailB_TON.Q;
XV_102(
    Inhibit := BothPumpsFailed_AND);

(* Outputs published to other sections / HMI. *)
FT_901_FlowRate := FT_901.PV;
LS_901_LevelPercent := LS_901.PV;
P_901A_Running := P_901A.FB_Running;
P_901B_Running := P_901B.FB_Running;
P_901AB_DutyActiveIsA := P_901AB.ActiveIsA;
P_901AB_SwitchedDueToDuty := P_901AB.SwitchedDueToDuty;
P_901AB_SwitchedDueToFailure := P_901AB.SwitchedDueToFailure;

END_PROGRAM
