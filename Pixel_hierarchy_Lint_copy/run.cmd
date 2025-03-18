
ECHO "Creating working library"
vlib work
IF errorlevel 2 (
	ECHO failed to create library
	GOTO done:
)

ECHO "invoking ==============> vlog adc_calibration.sv adc_calibration_tb.sv"
vlog lib_arbiter_pkg.sv top_pixel_hierarchy.sv tb_level_1.sv +acc 
IF errorlevel 2 (
	ECHO there was an error, fix it and try again
	GOTO done:
)

ECHO "invoking ==============> vsim adc_calibration_tb"
vsim -do "add wave -r *; run -all; quit" tb_level_1
IF errorlevel 2 (
	ECHO there was an error, fix it and try again
	GOTO done:
)

:done
ECHO Done

