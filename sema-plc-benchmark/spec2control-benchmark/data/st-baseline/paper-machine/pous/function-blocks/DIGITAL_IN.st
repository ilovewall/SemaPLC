FUNCTION_BLOCK DIGITAL_IN
VAR_INPUT
	DI_Raw : bool;
	DebounceTime : time;
	EnableAlarm : bool;
END_VAR

VAR_OUTPUT
	DI_Out : bool;
	Fault_State : bool;
END_VAR

(* Pass-through of the field contact (debounce not modeled). *)
DI_Out := DI_Raw;
Fault_State := FALSE;

END_FUNCTION_BLOCK
