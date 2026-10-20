PROGRAM Section3
VAR
	PT_201_VOTE_PV : real;
	TT_201_VOTE_PV : real;
	PT_201A : ANALOG_IN;
	PT_201B : ANALOG_IN;
	PT_201C : ANALOG_IN;
	TT_201A : ANALOG_IN;
	TT_201B : ANALOG_IN;
	TT_201C : ANALOG_IN;
	PT_201_VOTE : VOTING_ANALOG;
	TT_201_VOTE : VOTING_ANALOG;
	P_201 : MOTOR_ON_OFF;
	MO_201 : DIGITAL_IN;
	MO_202 : DIGITAL_IN;
	I_201 : BOOL_INPUT;
	I_202 : BOOL_INPUT;
	SI_201 : BOOL_INPUT;
	SI_202 : BOOL_INPUT;
	PT_GeneralFault : bool;
	MO201_Invert : bool;
	PT_SummaryPre : bool;
	PT_SummaryMasked : bool;
	TT_GeneralFault : bool;
	MO202_Invert : bool;
	TT_SummaryPre : bool;
	TT_SummaryMasked : bool;
	PressureInhibit : bool;
	TemperatureInhibit : bool;
	PumpInhibit : bool;
	PT_PressureHigh : bool;
	TT_TemperatureHigh : bool;
	PT_PressurePermissive : bool;
	TT_TemperaturePermissive : bool;
	StartPermissiveOK : bool;
	StartPermissiveNot : bool;
END_VAR

PT_201A(
    PV_High := 100.0,
    Alarm_Enable := TRUE);
PT_201B(
    PV_High := 100.0,
    Alarm_Enable := TRUE);
PT_201C(
    PV_High := 100.0,
    Alarm_Enable := TRUE);
TT_201A(
    Alarm_Enable := TRUE);
TT_201B(
    Alarm_Enable := TRUE);
TT_201C(
    Alarm_Enable := TRUE);
PT_PressureHigh := (PT_201_VOTE_PV > 100.0);
I_201(
    Bool_In := PT_PressureHigh,
    Alarm_OnTrue := TRUE,
    Latch_Enable := TRUE);
MO_201();
MO201_Invert := NOT MO_201.DI_Out;
PT_GeneralFault := PT_201A.General_Fault OR PT_201B.General_Fault OR PT_201C.General_Fault;
PT_SummaryPre := PT_GeneralFault OR PT_201_VOTE.Alarm_Voting_Error;
PT_SummaryMasked := PT_SummaryPre AND MO201_Invert;
SI_201(
    Bool_In := PT_SummaryMasked,
    Alarm_OnTrue := TRUE,
    Latch_Enable := TRUE);
PressureInhibit := I_201.Bool_Out OR SI_201.Bool_Out;
PT_201_VOTE(
    Input1 := PT_201A.PV,
    Input2 := PT_201B.PV,
    Input3 := PT_201C.PV,
    Deviation_Limit := 5.0,
    Voting_Scheme := '"2oo3"',
    EnableAlarm := TRUE,
    Inhibit := PressureInhibit);
TT_TemperatureHigh := (TT_201_VOTE_PV > 75.0);
I_202(
    Bool_In := TT_TemperatureHigh,
    Alarm_OnTrue := TRUE,
    Latch_Enable := TRUE);
MO_202();
MO202_Invert := NOT MO_202.DI_Out;
TT_GeneralFault := TT_201A.General_Fault OR TT_201B.General_Fault OR TT_201C.General_Fault;
TT_SummaryPre := TT_GeneralFault OR TT_201_VOTE.Alarm_Voting_Error;
TT_SummaryMasked := TT_SummaryPre AND MO202_Invert;
SI_202(
    Bool_In := TT_SummaryMasked,
    Alarm_OnTrue := TRUE,
    Latch_Enable := TRUE);
TemperatureInhibit := I_202.Bool_Out OR SI_202.Bool_Out;
TT_201_VOTE(
    Input1 := TT_201A.PV,
    Input2 := TT_201B.PV,
    Input3 := TT_201C.PV,
    Deviation_Limit := 5.0,
    Voting_Scheme := '"Median"',
    EnableAlarm := TRUE,
    Inhibit := TemperatureInhibit);
PT_PressurePermissive := (PT_201_VOTE_PV >= 21.0);
TT_TemperaturePermissive := (TT_201_VOTE_PV < 75.0);
StartPermissiveOK := PT_PressurePermissive AND TT_TemperaturePermissive;
StartPermissiveNot := NOT StartPermissiveOK;
PumpInhibit := TemperatureInhibit OR StartPermissiveNot;
P_201(
    Inhibit := PumpInhibit);

(* Outputs published to other sections / HMI. *)
PT_201_VOTE_PV := PT_201_VOTE.Voted_Output;
TT_201_VOTE_PV := TT_201_VOTE.Voted_Output;

END_PROGRAM
