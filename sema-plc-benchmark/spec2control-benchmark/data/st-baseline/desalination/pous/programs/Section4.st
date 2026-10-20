PROGRAM Section4
VAR
	FT_101_Flow_PV_m3ph : real;
	LT_101_SumpLevel_m : real;
	FIC_101_MV_Percent : real;
	FIC_101_SP_m3ph : real;
	Flow_Deviation_Alarm : bool;
	FT_101 : ANALOG_IN;
	LT_101 : ANALOG_IN;
	FIC_101 : PID_BASIC;
	VFD_101A : MOTOR_VSD;
	VFD_101B : MOTOR_VSD;
	VFD_101C : MOTOR_VSD;
	VFD_101D : MOTOR_VSD;
	SPUMP_201A : MOTOR_ON_OFF;
	SPUMP_201B : MOTOR_ON_OFF;
	M103A : DIGITAL_IN;
	M103B : DIGITAL_IN;
	M103C : DIGITAL_IN;
	M103D : DIGITAL_IN;
	FlowDeviationHold : TON;
	SumpLevelOutOfRange : bool;
	Inhibit_101A : bool;
	Inhibit_101B : bool;
	Inhibit_101C : bool;
	Inhibit_101D : bool;
END_VAR

FT_101(
    Scaling_Slope := 31.25,
    Scaling_Offset := -125.0,
    Alarm_Enable := TRUE);
LT_101(
    PV_High := 9.0,
    PV_Low := 1.5,
    Scaling_Slope := 0.625,
    Scaling_Offset := -2.5,
    Alarm_Enable := TRUE);
SumpLevelOutOfRange := LT_101.Low_Alarm OR LT_101.High_Alarm;
FIC_101(
    AUTO := TRUE,
    PV := FT_101.PV,
    SP := FIC_101_SP_m3ph,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 2.5,
    TR := 0.8,
    TD := 0.2,
    Deviation_Limit := 10.0,
    Inhibit := SumpLevelOutOfRange);
M103A();
Inhibit_101A := SumpLevelOutOfRange OR M103A.DI_Out OR VFD_101A.FB_Fault;
VFD_101A(
    Speed_SP := FIC_101.XOUT,
    Inhibit := Inhibit_101A);
M103B();
Inhibit_101B := SumpLevelOutOfRange OR M103B.DI_Out OR VFD_101B.FB_Fault;
VFD_101B(
    Inhibit := Inhibit_101B);
M103C();
Inhibit_101C := SumpLevelOutOfRange OR M103C.DI_Out OR VFD_101C.FB_Fault;
VFD_101C(
    Inhibit := Inhibit_101C);
M103D();
Inhibit_101D := SumpLevelOutOfRange OR M103D.DI_Out OR VFD_101D.FB_Fault;
VFD_101D(
    Inhibit := Inhibit_101D);
SPUMP_201A();
SPUMP_201B();
FlowDeviationHold(
    IN := FIC_101.Deviation_Alarm,
    PT := T#30s);

(* Outputs published to other sections / HMI. *)
Flow_Deviation_Alarm := FlowDeviationHold.Q;
FT_101_Flow_PV_m3ph := FT_101.PV;
LT_101_SumpLevel_m := LT_101.PV;
FIC_101_MV_Percent := FIC_101.XOUT;

END_PROGRAM
