PROGRAM Section5
VAR
	PVT_401_Voted_Pressure : real;
	TVT_402_Voted_Temperature : real;
	PT_401A : ANALOG_IN;
	PT_401B : ANALOG_IN;
	PT_401C : ANALOG_IN;
	TT_105 : ANALOG_IN;
	TT_106 : ANALOG_IN;
	TT_107 : ANALOG_IN;
	PVT_401 : VOTING_ANALOG;
	TVT_402 : VOTING_ANALOG;
	PIC_401 : PID_BASIC;
	TIC_402 : PID_BASIC;
	PV_102 : VALVE_ELECTRIC;
	FV_107 : VALVE_ELECTRIC;
	XV_104 : VALVE_ON_OFF;
	I_401 : BOOL_INPUT;
	I_402 : BOOL_INPUT;
	MA_401 : BOOL_INPUT;
	PV102_Inhibit_OR : bool;
	AllPTBad_AND : bool;
	FV107_Inhibit_OR : bool;
	MasterAlarm_OR : bool;
END_VAR

PT_401A(
    PV_High := 2.0,
    PV_Low := 1.6,
    Alarm_Enable := TRUE);
PT_401B(
    PV_High := 2.0,
    PV_Low := 1.6,
    Alarm_Enable := TRUE);
PT_401C(
    PV_High := 2.0,
    PV_Low := 1.6,
    Alarm_Enable := TRUE);
TT_105(
    Alarm_Enable := TRUE);
TT_106(
    Alarm_Enable := TRUE);
TT_107(
    Alarm_Enable := TRUE);
PVT_401(
    Input1 := PT_401A.PV,
    Input2 := PT_401B.PV,
    Input3 := PT_401C.PV,
    Deviation_Limit := 0.09,
    Voting_Scheme := '2oo3',
    EnableAlarm := TRUE);
TVT_402(
    Input1 := TT_105.PV,
    Input2 := TT_106.PV,
    Input3 := TT_107.PV,
    Deviation_Limit := 2.0,
    Voting_Scheme := 'Median',
    EnableAlarm := TRUE);
PIC_401(
    AUTO := TRUE,
    PV := PVT_401.Voted_Output,
    SP := 1.8,
    MV_MIN := 0.0,
    MV_MAX := 100.0);
TIC_402(
    AUTO := TRUE,
    PV := TVT_402.Voted_Output,
    SP := 65.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0);
PV102_Inhibit_OR := PVT_401.Alarm_Voting_Error OR PIC_401.PV_High_Alarm OR PIC_401.PV_Low_Alarm;
I_401(
    Bool_In := PV102_Inhibit_OR,
    Alarm_OnTrue := TRUE,
    Latch_Enable := TRUE);
PV_102(
    Control_Signal := PIC_401.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s,
    Inhibit := I_401.Bool_Out);
FV107_Inhibit_OR := TVT_402.Alarm_Voting_Error OR TIC_402.PV_High_Alarm OR TIC_402.PV_Low_Alarm;
I_402(
    Bool_In := FV107_Inhibit_OR,
    Alarm_OnTrue := TRUE,
    Latch_Enable := TRUE);
FV_107(
    Control_Signal := TIC_402.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s,
    Inhibit := I_402.Bool_Out);
AllPTBad_AND := PT_401A.General_Fault AND PT_401B.General_Fault AND PT_401C.General_Fault;
XV_104(
    Open_Cmd := FALSE,
    Close_Cmd := AllPTBad_AND,
    Timeout := T#5s,
    Inhibit := AllPTBad_AND);
MasterAlarm_OR := PV102_Inhibit_OR OR FV107_Inhibit_OR OR PT_401A.General_Fault OR PT_401B.General_Fault OR PT_401C.General_Fault OR TT_105.General_Fault OR TT_106.General_Fault OR TT_107.General_Fault;
MA_401(
    Bool_In := MasterAlarm_OR,
    Alarm_OnTrue := TRUE,
    Latch_Enable := TRUE);

(* Outputs published to other sections / HMI. *)
PVT_401_Voted_Pressure := PVT_401.Voted_Output;
TVT_402_Voted_Temperature := TVT_402.Voted_Output;

END_PROGRAM
