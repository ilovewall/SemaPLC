PROGRAM Section12
VAR
	IIC101_Raw_mA : real;
	LV104_Raw_mA : real;
	IIC101_Solids_PV : real;
	IIC103_MV_to_PV102 : real;
	LV104_Level_PV : real;
	IIC_101 : ANALOG_IN;
	LV_104 : ANALOG_IN;
	IIC_103 : PID_BASIC;
	IIC_105 : BOOL_INPUT;
	PV_102 : VALVE_ELECTRIC;
	OC_1101 : VALVE_ON_OFF;
	OdorNotActive_NOT : bool;
	PIDInhibit_OR : bool;
	ValveInhibit_OR : bool;
END_VAR

IIC_101(
    Raw_Signal := IIC101_Raw_mA,
    Scaling_Slope := 0.625,
    Scaling_Offset := -2.5,
    Alarm_Enable := TRUE);
LV_104(
    Raw_Signal := LV104_Raw_mA,
    PV_High := 85.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
PIDInhibit_OR := LV_104.High_Alarm OR IIC_101.General_Fault;
OC_1101(
    Timeout := T#10s);
IIC_105(
    Bool_In := OC_1101.FB_Opened);
OdorNotActive_NOT := NOT IIC_105.Bool_Out;
ValveInhibit_OR := OdorNotActive_NOT OR PV_102.Position_Error;
PV_102(
    Control_Signal := IIC_103.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#30s,
    Inhibit := ValveInhibit_OR);
IIC_103(
    AUTO := TRUE,
    PV := IIC_101.PV,
    SP := 6.5,
    MV_MIN := 10.0,
    MV_MAX := 90.0,
    X0 := PV_102.Feedback_Pos,
    KP := 3.0,
    TR := 1.2,
    TD := 0.3,
    PV_High := 8.0,
    PV_Low := 4.0,
    Inhibit := PIDInhibit_OR);

(* Outputs published to other sections / HMI. *)
IIC101_Solids_PV := IIC_101.PV;
IIC103_MV_to_PV102 := IIC_103.XOUT;
LV104_Level_PV := LV_104.PV;

END_PROGRAM
