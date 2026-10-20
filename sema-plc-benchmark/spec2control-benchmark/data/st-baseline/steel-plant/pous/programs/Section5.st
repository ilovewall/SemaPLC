PROGRAM Section5
VAR
	TT_401_V_Temp_PV : real;
	PT_401_V_Pressure_PV : real;
	FT_401_Flow_PV : real;
	FT_401 : ANALOG_IN;
	PT_401A : ANALOG_IN;
	PT_401B : ANALOG_IN;
	PT_401C : ANALOG_IN;
	TT_401 : ANALOG_IN;
	TT_401A : ANALOG_IN;
	TT_401B : ANALOG_IN;
	TT_401C : ANALOG_IN;
	TT_401_V : VOTING_ANALOG;
	PT_401_V : VOTING_ANALOG;
	BOF_401_TempControl : PID_BASIC;
	BOF_402 : VALVE_ELECTRIC;
	I_401 : BOOL_INPUT;
	MA_401 : BOOL_INPUT;
	DA_401 : BOOL_INPUT;
	FA_401 : BOOL_INPUT;
	FlowPermissive_NOT : bool;
	PTA_HighAlarm_OK_NOT : bool;
	PTA_LowAlarm_OK_NOT : bool;
	PTB_HighAlarm_OK_NOT : bool;
	PTB_LowAlarm_OK_NOT : bool;
	PTC_HighAlarm_OK_NOT : bool;
	PTC_LowAlarm_OK_NOT : bool;
	PTA_WithinRange_AND : bool;
	PTB_WithinRange_AND : bool;
	PTC_WithinRange_AND : bool;
	PT_AB_Within_AND : bool;
	PT_AC_Within_AND : bool;
	PT_BC_Within_AND : bool;
	PT_2oo3_OK_OR1 : bool;
	PT_2oo3_OK_OR : bool;
	TempVoted_GT : bool;
	HealthySensors_GT : bool;
	TempPermit_AND : bool;
	AllPermissives_OK_AND1 : bool;
	AllPermissives_OK_AND : bool;
	PermissivesFail_NOT : bool;
	SensorFaults_OR1 : bool;
	SensorFaults_OR2 : bool;
	SensorFaults_OR3 : bool;
	SensorFaults_OR4 : bool;
	SensorFaults_OR5 : bool;
	SensorFaults_OR6 : bool;
	SensorFaults_OR7 : bool;
	Inhibit_OR1 : bool;
	Inhibit_OR : bool;
END_VAR

FT_401(
    Alarm_Enable := TRUE);
PT_401A(
    Alarm_Enable := TRUE);
PT_401B(
    Alarm_Enable := TRUE);
PT_401C(
    Alarm_Enable := TRUE);
TT_401(
    Alarm_Enable := TRUE);
TT_401A(
    Alarm_Enable := TRUE);
TT_401B(
    Alarm_Enable := TRUE);
TT_401C(
    Alarm_Enable := TRUE);
TT_401_V(
    Input1 := TT_401A.PV,
    Input2 := TT_401B.PV,
    Input3 := TT_401C.PV,
    Deviation_Limit := 0.05,
    Voting_Scheme := 'Median',
    EnableAlarm := TRUE);
PT_401_V(
    Input1 := PT_401A.PV,
    Input2 := PT_401B.PV,
    Input3 := PT_401C.PV,
    Voting_Scheme := '2oo3',
    EnableAlarm := TRUE);
BOF_401_TempControl(
    AUTO := TRUE,
    PV := TT_401_V.Voted_Output,
    SP := 1650.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 1.0,
    TR := 60.0,
    TD := 0.0);
SensorFaults_OR1 := TT_401A.General_Fault OR TT_401B.General_Fault;
SensorFaults_OR2 := SensorFaults_OR1 OR TT_401C.General_Fault;
SensorFaults_OR3 := SensorFaults_OR2 OR TT_401.General_Fault;
SensorFaults_OR4 := SensorFaults_OR3 OR PT_401A.General_Fault;
SensorFaults_OR5 := SensorFaults_OR4 OR PT_401B.General_Fault;
SensorFaults_OR6 := SensorFaults_OR5 OR PT_401C.General_Fault;
SensorFaults_OR7 := SensorFaults_OR6 OR FT_401.General_Fault;
FA_401(
    Bool_In := SensorFaults_OR7);
DA_401(
    Bool_In := TT_401_V.Alarm_Voting_Error);
PTA_HighAlarm_OK_NOT := NOT PT_401A.High_Alarm;
PTA_LowAlarm_OK_NOT := NOT PT_401A.Low_Alarm;
PTA_WithinRange_AND := PTA_HighAlarm_OK_NOT AND PTA_LowAlarm_OK_NOT;
PTB_HighAlarm_OK_NOT := NOT PT_401B.High_Alarm;
PTB_LowAlarm_OK_NOT := NOT PT_401B.Low_Alarm;
PTB_WithinRange_AND := PTB_HighAlarm_OK_NOT AND PTB_LowAlarm_OK_NOT;
PT_AB_Within_AND := PTA_WithinRange_AND AND PTB_WithinRange_AND;
PTC_HighAlarm_OK_NOT := NOT PT_401C.High_Alarm;
PTC_LowAlarm_OK_NOT := NOT PT_401C.Low_Alarm;
PTC_WithinRange_AND := PTC_HighAlarm_OK_NOT AND PTC_LowAlarm_OK_NOT;
PT_AC_Within_AND := PTA_WithinRange_AND AND PTC_WithinRange_AND;
PT_2oo3_OK_OR1 := PT_AB_Within_AND OR PT_AC_Within_AND;
PT_BC_Within_AND := PTB_WithinRange_AND AND PTC_WithinRange_AND;
PT_2oo3_OK_OR := PT_2oo3_OK_OR1 OR PT_BC_Within_AND;
HealthySensors_GT := (TT_401_V.Healthy_Sensors_Count > 1);
TempVoted_GT := (TT_401_V.Voted_Output > 1450.0);
TempPermit_AND := TempVoted_GT AND HealthySensors_GT;
AllPermissives_OK_AND1 := TempPermit_AND AND PT_2oo3_OK_OR;
FlowPermissive_NOT := NOT FT_401.Low_Alarm;
AllPermissives_OK_AND := AllPermissives_OK_AND1 AND FlowPermissive_NOT;
PermissivesFail_NOT := NOT AllPermissives_OK_AND;
Inhibit_OR1 := PermissivesFail_NOT OR DA_401.Bool_Out;
Inhibit_OR := Inhibit_OR1 OR FA_401.Bool_Out;
I_401(
    Bool_In := Inhibit_OR);
BOF_402(
    Control_Signal := BOF_401_TempControl.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s,
    Inhibit := I_401.Bool_Out);
MA_401();

(* Outputs published to other sections / HMI. *)
TT_401_V_Temp_PV := TT_401_V.Voted_Output;
PT_401_V_Pressure_PV := PT_401_V.Voted_Output;
FT_401_Flow_PV := FT_401.PV;

END_PROGRAM
