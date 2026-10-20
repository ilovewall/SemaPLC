PROGRAM Section3
VAR
	TT_103_Temperature_PV : real;
	PT_101_Pressure_PV : real;
	TIC_104_RSP_to_FC_203 : real;
	PIC_101_RSP_to_FC_202 : real;
	FC_203_MV_to_SV_203 : real;
	FC_202_MV_to_FV_202 : real;
	TT_103 : ANALOG_IN;
	PT_101 : ANALOG_IN;
	TIC_104 : PID_BASIC;
	PIC_101 : PID_BASIC;
	FC_203 : PID_BASIC;
	FC_202 : PID_BASIC;
	SV_203 : VALVE_ELECTRIC;
	FV_202 : VALVE_ELECTRIC;
	SV203Trip_OR : bool;
	CascadeInhibit_OR : bool;
END_VAR

TT_103(
    PV_High := 180.0,
    PV_Low := 160.0,
    Scaling_Slope := 11.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
PT_101(
    Alarm_Enable := TRUE);
PIC_101(
    AUTO := TRUE,
    PV := PT_101.PV,
    SP := 800.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    PV_High := 850.0,
    PV_Low := 750.0,
    Inhibit := CascadeInhibit_OR);
FC_202(
    AUTO := TRUE,
    SP := PIC_101.XOUT,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Inhibit := PIC_101.PV_Low_Alarm);
FV_202(
    Control_Signal := FC_202.XOUT);
FC_203(
    AUTO := TRUE,
    SP := TIC_104.XOUT,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 3.5,
    TR := 0.3,
    Inhibit := TT_103.General_Fault);
SV203Trip_OR := PIC_101.PV_High_Alarm OR TIC_104.PV_High_Alarm;
SV_203(
    Control_Signal := FC_203.XOUT,
    Inhibit := SV203Trip_OR);
CascadeInhibit_OR := TT_103.General_Fault OR PT_101.General_Fault OR SV_203.Alarm OR FV_202.Alarm;
TIC_104(
    AUTO := TRUE,
    PV := TT_103.PV,
    SP := 170.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 1.2,
    TR := 2.0,
    Inhibit := CascadeInhibit_OR);

(* Outputs published to other sections / HMI. *)
TT_103_Temperature_PV := TT_103.PV;
PT_101_Pressure_PV := PT_101.PV;
TIC_104_RSP_to_FC_203 := TIC_104.XOUT;
PIC_101_RSP_to_FC_202 := PIC_101.XOUT;
FC_203_MV_to_SV_203 := FC_203.XOUT;
FC_202_MV_to_FV_202 := FC_202.XOUT;

END_PROGRAM
