PROGRAM Section3
VAR
	PIT_103_PV_mmHg : real;
	PIC_102_MV_Percent : real;
	PIT_103 : ANALOG_IN;
	PIC_102 : PID_BASIC;
	PV_101 : VALVE_ELECTRIC;
	VDU_START_OK : BOOL_INPUT;
	MAINT_BYPASS_OK : BOOL_INPUT;
	PIC102Inhibit_OR : bool;
	PV101Inhibit_OR : bool;
	VDUStartPermissive_NOT : bool;
END_VAR

PIT_103(
    PV_High := 80.0,
    PV_Low := 20.0,
    Scaling_Slope := 47.5,
    Scaling_Offset := -190.0,
    Alarm_Enable := TRUE);
MAINT_BYPASS_OK();
VDU_START_OK();
VDUStartPermissive_NOT := NOT VDU_START_OK.Bool_Out;
PIC102Inhibit_OR := VDUStartPermissive_NOT OR MAINT_BYPASS_OK.Bool_Out OR PIT_103.General_Fault OR PIC_102.PV_Low_Alarm;
PIC_102(
    AUTO := TRUE,
    PV := PIT_103.PV,
    SP := 50.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 1.8,
    TR := 2.0,
    TD := 0.5,
    Deviation_Limit := 5.0,
    Inhibit := PIC102Inhibit_OR);
PV101Inhibit_OR := PIC_102.PV_High_Alarm OR PV_101.Position_Error;
PV_101(
    Control_Signal := PIC_102.XOUT,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := PV101Inhibit_OR);

(* Outputs published to other sections / HMI. *)
PIT_103_PV_mmHg := PIT_103.PV;
PIC_102_MV_Percent := PIC_102.XOUT;

END_PROGRAM
