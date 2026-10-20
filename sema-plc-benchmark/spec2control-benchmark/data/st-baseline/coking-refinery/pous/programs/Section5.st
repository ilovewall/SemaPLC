PROGRAM Section5
VAR
	TIT101_FurnaceOutletTemp_PV_C : real;
	TC401_FV401_FuelGas_MV_Pct : real;
	PT402_FurnaceDraft_PV_kPa : real;
	PT403_DischargePressure_PV_bar : real;
	PC401_FuelGasPressure_PV_bar : real;
	TIT101_HighTempAlarm_3s : bool;
	TIT101_LowTempAlarm_3s : bool;
	TIT_101 : ANALOG_IN;
	TC_401 : PID_BASIC;
	FV_401 : VALVE_ELECTRIC;
	PT_402 : ANALOG_IN;
	PT_403 : ANALOG_IN;
	PC_401 : PID_BASIC;
	FT_401A : DIGITAL_IN;
	FT_401B : DIGITAL_IN;
	FuelGasInterlockDelay_TON : TON;
	TIT101_HighAlarmDelay_TON : TON;
	TIT101_LowAlarmDelay_TON : TON;
	FlameLitPermissive_AND : bool;
	FlameNotLit_NOT : bool;
	FuelGasPermissiveViolations_OR : bool;
	MasterInhibit_OR : bool;
END_VAR

TIT_101(
    PV_High := 510.0,
    PV_Low := 480.0,
    Scaling_Slope := 9.375,
    Scaling_Offset := 362.5,
    Alarm_Enable := TRUE);
FT_401A();
FT_401B();
FlameLitPermissive_AND := FT_401A.DI_Out AND FT_401B.DI_Out;
FlameNotLit_NOT := NOT FlameLitPermissive_AND;
PC_401(
    PV := PC401_FuelGasPressure_PV_bar);
PT_402(
    Alarm_Enable := TRUE);
PT_403(
    Alarm_Enable := TRUE);
FuelGasPermissiveViolations_OR := PC_401.PV_High_Alarm OR PC_401.PV_Low_Alarm OR PT_402.High_Alarm OR PT_402.Low_Alarm OR PT_403.Low_Alarm;
FuelGasInterlockDelay_TON(
    IN := FuelGasPermissiveViolations_OR,
    PT := T#5s);
MasterInhibit_OR := TC_401.PV_High_Alarm OR FuelGasInterlockDelay_TON.Q OR FlameNotLit_NOT OR TIT_101.General_Fault;
FV_401(
    Control_Signal := TC_401.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := MasterInhibit_OR);
TC_401(
    AUTO := TRUE,
    PV := TIT_101.PV,
    SP := 495.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := FV_401.Feedback_Pos,
    KP := 3.2,
    TR := 0.9,
    TD := 0.3,
    Deviation_Limit := 2.0,
    Inhibit := MasterInhibit_OR);
TIT101_HighAlarmDelay_TON(
    IN := TIT_101.High_Alarm,
    PT := T#3s);
TIT101_LowAlarmDelay_TON(
    IN := TIT_101.Low_Alarm,
    PT := T#3s);

(* Outputs published to other sections / HMI. *)
TIT101_FurnaceOutletTemp_PV_C := TIT_101.PV;
TC401_FV401_FuelGas_MV_Pct := TC_401.XOUT;
PT402_FurnaceDraft_PV_kPa := PT_402.PV;
PT403_DischargePressure_PV_bar := PT_403.PV;
TIT101_HighTempAlarm_3s := TIT101_HighAlarmDelay_TON.Q;
TIT101_LowTempAlarm_3s := TIT101_LowAlarmDelay_TON.Q;

END_PROGRAM
