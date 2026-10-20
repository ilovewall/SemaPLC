PROGRAM Section4
VAR
	LT_105_Level_PV : real;
	FT_107_Flow_PV : real;
	PT_104_Pressure_PV : real;
	LIC_104_RSP_to_FIC_107_GPM : real;
	FIC_107_Control_Signal_to_LV_107 : real;
	XV103_NotOpen : bool;
	Cascade_Inhibit : bool;
	Permissive_OK : bool;
	LT_105 : ANALOG_IN;
	FT_107 : ANALOG_IN;
	PT_104 : ANALOG_IN;
	LIC_104 : PID_BASIC;
	FIC_107 : PID_BASIC;
	PIC_104 : PID_BASIC;
	LV_107 : VALVE_ELECTRIC;
	XV_103 : VALVE_ON_OFF;
	CascadeStartDelay_TON : TON;
	CascadeInhibit_OR : bool;
	XV103NotOpen_NOT : bool;
	CascadePermissive_NOT : bool;
	LIC_to_FIC_SP_MULT : real;
END_VAR

LT_105(
    Alarm_Enable := TRUE);
FT_107(
    Alarm_Enable := TRUE);
PT_104(
    PV_High := 30.0,
    Alarm_Enable := TRUE);
LIC_to_FIC_SP_MULT := LIC_104.XOUT * 0.5;
FIC_107(
    AUTO := Permissive_OK,
    PV := FT_107.PV,
    SP := LIC_to_FIC_SP_MULT,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 4.0,
    TR := 0.5,
    TD := 0.0,
    Inhibit := CascadeInhibit_OR);
LV_107(
    Control_Signal := FIC_107.XOUT,
    Manual_Mode := PT_104.High_Alarm,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := PT_104.High_Alarm);
XV_103();
XV103NotOpen_NOT := NOT XV_103.FB_Opened;
CascadeInhibit_OR := XV103NotOpen_NOT OR LT_105.Low_Alarm OR PT_104.Low_Alarm OR PT_104.High_Alarm OR FT_107.General_Fault OR LV_107.Alarm;
CascadeStartDelay_TON(
    IN := Permissive_OK,
    PT := T#30s);
LIC_104(
    AUTO := CascadeStartDelay_TON.Q,
    PV := LT_105.PV,
    SP := 65.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 40.0,
    KP := 1.5,
    TR := 2.5,
    TD := 0.0,
    PV_High := 90.0,
    PV_Low := 10.0,
    Inhibit := CascadeInhibit_OR);
PIC_104(
    PV := PT_104.PV);
CascadePermissive_NOT := NOT Cascade_Inhibit;

(* Outputs published to other sections / HMI. *)
LT_105_Level_PV := LT_105.PV;
FT_107_Flow_PV := FT_107.PV;
PT_104_Pressure_PV := PT_104.PV;
LIC_104_RSP_to_FIC_107_GPM := LIC_to_FIC_SP_MULT;
FIC_107_Control_Signal_to_LV_107 := FIC_107.XOUT;
XV103_NotOpen := XV103NotOpen_NOT;
Cascade_Inhibit := CascadeInhibit_OR;
Permissive_OK := CascadePermissive_NOT;

END_PROGRAM