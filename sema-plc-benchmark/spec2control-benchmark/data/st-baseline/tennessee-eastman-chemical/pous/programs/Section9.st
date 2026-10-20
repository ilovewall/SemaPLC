PROGRAM Section9
VAR
	TIT101_Temperature_PV_C : real;
	FI103_Flow_PV : real;
	FIC103_Output_MV_Percent : real;
	LV102_ValvePositionCmd_Percent : real;
	XV104_Open_FB : bool;
	LC002_ValidLevel : bool;
	LC002_LevelValid_In : bool;
	TIT_101 : ANALOG_IN;
	FI_103 : ANALOG_IN;
	FIC_103 : PID_BASIC;
	LV_102 : VALVE_ELECTRIC;
	XV_104 : VALVE_ON_OFF;
	LC_002 : BOOL_INPUT;
	XV104NotOpen_NOT : bool;
	LC002NotActive_NOT : bool;
	LV102Inhibit_OR : bool;
	XV104Inhibit_OR : bool;
	FIC103Inhibit_OR : bool;
	XV104OpenCmd_NOT : bool;
END_VAR

TIT_101(
    PV_High := 55.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
FI_103(
    PV_Low := 5.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
LC_002(
    Bool_In := LC002_LevelValid_In);
LC002NotActive_NOT := NOT LC_002.Bool_Out;
FIC103Inhibit_OR := TIT_101.General_Fault OR TIT_101.Low_Alarm OR LC002NotActive_NOT;
FIC_103(
    AUTO := TRUE,
    PV := TIT_101.PV,
    SP := 45.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 3.0,
    TR := 1.2,
    TD := 0.3,
    Inhibit := FIC103Inhibit_OR);
XV104Inhibit_OR := FI_103.Low_Alarm OR TIT_101.High_Alarm;
XV104OpenCmd_NOT := NOT XV104Inhibit_OR;
XV_104(
    Open_Cmd := XV104OpenCmd_NOT,
    Close_Cmd := XV104Inhibit_OR,
    Timeout := T#2s,
    Inhibit := XV104Inhibit_OR);
XV104NotOpen_NOT := NOT XV_104.FB_Opened;
LV102Inhibit_OR := XV104NotOpen_NOT OR FI_103.Low_Alarm OR TIT_101.General_Fault OR LC002NotActive_NOT OR TIT_101.High_Alarm OR XV_104.Alarm_General;
LV_102(
    Control_Signal := FIC_103.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#2s,
    Inhibit := LV102Inhibit_OR);

(* Outputs published to other sections / HMI. *)
TIT101_Temperature_PV_C := TIT_101.PV;
FI103_Flow_PV := FI_103.PV;
FIC103_Output_MV_Percent := FIC_103.XOUT;
LV102_ValvePositionCmd_Percent := LV_102.Valve_Position;
XV104_Open_FB := XV_104.FB_Opened;
LC002_ValidLevel := LC_002.Bool_Out;

END_PROGRAM
