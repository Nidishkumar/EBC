#Clean 
#rm -rf spyglass-1 
#close_project -force 
#----------------------------------------------- 
set top_module top_arb.sv
#set lnt lint_rtl 
set lnt lint_rtl_enhanced 
#----------------------------------------------- 
#----------------------------------------------- 
new_project spyglass-1 -force 
set_option enableSV yes 
#----------------------------------------------- 
#----------------------------------------------- 
read_file -type sourcelist files.f
read_file -type verilog $top_module.sv 
set_option top {$top_module} 
#-----------------------------------------------
#----------------------------------------------- 
current_goal lint/$lnt -top $top_module 
#current_goal lint/lint_rtl_enhanced -top $top_module 
run_goal 
write_report spyglass_violations 
write_report moresimple 
write_report score 
write_report summary 
#----------------------------------------------- 
close_project -force 
#gui_start
