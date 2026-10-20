PROGRAM Section2
VAR
	FT404_GasFlow_PV : real;
	FT406_LiqFlow_PV : real;
	PT403_SepPressure_PV : real;
	PT408_AuxPressure_PV : real;
	FIC406_LiqFlow_SP_From_FFIC402 : real;
	FT_404 : ANALOG_IN;
	FT_406 : ANALOG_IN;
	PT_403 : ANALOG_IN;
	PT_408 : ANALOG_IN;
	FFIC_402 : RATIO_CONTROL;
	FIC_406 : PID_BASIC;
	PIC_401 : PID_BASIC;
	CV_406 : VALVE_ELECTRIC;
	CV_401 : VALVE_ELECTRIC;
	ValveInhibit_OR : bool;
	RatioInhibit_OR : bool;
END_VAR

FT_404(
    PV_Low := 50.0);
FT_406(
    PV_Low := 20.0);
PT_403();
PT_408();
RatioInhibit_OR := PT_403.High_Alarm OR PT_403.Low_Alarm OR FT_404.Low_Alarm OR FT_404.General_Fault OR FT_406.General_Fault OR PT_408.Low_Alarm;
FFIC_402(
    Auto := TRUE,
    PrimaryPV := FT_404.PV,
    SecondaryPV := FT_406.PV,
    RatioSP := 2.5,
    MV_MIN := 0.0,
    MV_MAX := 500.0,
    Inhibit := RatioInhibit_OR);
FIC_406(
    AUTO := TRUE,
    PV := FT_406.PV,
    SP := FFIC_402.SlaveSP);
PIC_401(
    AUTO := TRUE,
    PV := PT_403.PV,
    SP := 5.0,
    PV_High := 6.0,
    PV_Low := 4.0);
ValveInhibit_OR := PT_403.High_Alarm OR PT_403.Low_Alarm OR FT_404.Low_Alarm OR FT_406.Low_Alarm;
CV_406(
    Control_Signal := FIC_406.XOUT,
    Inhibit := ValveInhibit_OR);
CV_401(
    Control_Signal := PIC_401.XOUT);

(* Outputs published to other sections / HMI. *)
FT404_GasFlow_PV := FT_404.PV;
FT406_LiqFlow_PV := FT_406.PV;
PT403_SepPressure_PV := PT_403.PV;
PT408_AuxPressure_PV := PT_408.PV;
FIC406_LiqFlow_SP_From_FFIC402 := FFIC_402.SlaveSP;

END_PROGRAM
