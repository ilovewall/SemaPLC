PROGRAM Section6
VAR
	FT103_H2Flow_PV : real;
	FC103_MV_Percent : real;
	TT101_Temp_PV : real;
	TC501_MV_Percent : real;
	PT501_Pressure_PV : real;
	PT502_InletPressure_PV : real;
	FC103_SP_Operator : real;
	FC103_SP_Clamped : real;
	FC103_SP_Reduced : real;
	FT_103 : ANALOG_IN;
	FC_103 : PID_BASIC;
	FV_103 : VALVE_ELECTRIC;
	TT_101 : ANALOG_IN;
	TC_501 : PID_BASIC;
	TV_501 : VALVE_ELECTRIC;
	PT_501 : ANALOG_IN;
	PC_501 : PID_BASIC;
	PT_502 : ANALOG_IN;
	ESD_501 : DIGITAL_IN;
	TV501_OpenDelay_TON : TON;
	FC103_Inhibit_OR : bool;
	TV501_Inhibit_OR : bool;
	TC501_Inhibit_OR : bool;
	PT501_OverLimit_GT : bool;
	FC103_SP_Half_MULT : real;
	FC103_SP_SEL : real;
	H2_Shutdown_OR : bool;
	H2_Auto_NOT : bool;
	ESD_NOT : bool;
	PT502_Permissive_GT : bool;
	TV501_Permissive_AND : bool;
	TV501_AutoReady_NOT : bool;
	TV501_ManualMode_OR : bool;
	TV501_ManualPos_SEL : real;
	FC103_SP_Max_MAX : real;
	FC103_SP_Clamp_MIN : real;
END_VAR

FT_103(
    Scaling_Slope := 125.0,
    Scaling_Offset := -500.0,
    Alarm_Enable := TRUE);
ESD_501();
TT_101(
    Alarm_Enable := TRUE);
FC103_Inhibit_OR := ESD_501.DI_Out OR TT_101.High_Alarm OR FT_103.General_Fault;
FC103_SP_Max_MAX := MAX(FC103_SP_Operator, 500.0);
FC103_SP_Clamp_MIN := MIN(FC103_SP_Max_MAX, 1500.0);
FC103_SP_Half_MULT := FC103_SP_Clamp_MIN * 0.5;
PT_501();
PT501_OverLimit_GT := (PT_501.PV > 50.0);
FC103_SP_SEL := SEL(G := PT501_OverLimit_GT, IN0 := FC103_SP_Clamp_MIN, IN1 := FC103_SP_Half_MULT);
H2_Shutdown_OR := ESD_501.DI_Out OR TT_101.High_Alarm;
H2_Auto_NOT := NOT H2_Shutdown_OR;
FC_103(
    AUTO := H2_Auto_NOT,
    PV := FT_103.PV,
    SP := FC103_SP_SEL,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 1.8,
    TR := 0.5,
    TD := 0.1,
    PV_High := 1600.0,
    PV_Low := 400.0,
    Inhibit := FC103_Inhibit_OR);
FV_103(
    Control_Signal := FC_103.XOUT,
    Manual_Mode := H2_Shutdown_OR,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FC103_Inhibit_OR);
ESD_NOT := NOT ESD_501.DI_Out;
TC501_Inhibit_OR := ESD_501.DI_Out OR TT_101.General_Fault;
TC_501(
    AUTO := ESD_NOT,
    PV := TT_101.PV,
    SP := 375.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 2.5,
    TR := 0.8,
    TD := 0.2,
    PV_High := 415.0,
    PV_Low := 290.0,
    Inhibit := TC501_Inhibit_OR);
PT_502(
    Alarm_Enable := TRUE);
TV501_Inhibit_OR := ESD_501.DI_Out OR PT_502.Low_Alarm OR TT_101.General_Fault;
PT502_Permissive_GT := (PT_502.PV > 10.0);
TV501_Permissive_AND := ESD_NOT AND PT502_Permissive_GT;
TV501_OpenDelay_TON(
    IN := TV501_Permissive_AND,
    PT := T#15s);
TV501_AutoReady_NOT := NOT TV501_OpenDelay_TON.Q;
TV501_ManualMode_OR := TV501_AutoReady_NOT OR ESD_501.DI_Out;
TV501_ManualPos_SEL := SEL(G := ESD_501.DI_Out, IN0 := 0.0, IN1 := 100.0);
TV_501(
    Control_Signal := TC_501.XOUT,
    Manual_Mode := TV501_ManualMode_OR,
    Manual_Position := TV501_ManualPos_SEL,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := TV501_Inhibit_OR);
PC_501(
    PV := PT_501.PV,
    Inhibit := ESD_501.DI_Out);

(* Outputs published to other sections / HMI. *)
FT103_H2Flow_PV := FT_103.PV;
FC103_MV_Percent := FC_103.XOUT;
TT101_Temp_PV := TT_101.PV;
TC501_MV_Percent := TC_501.XOUT;
PT501_Pressure_PV := PT_501.PV;
PT502_InletPressure_PV := PT_502.PV;

END_PROGRAM
