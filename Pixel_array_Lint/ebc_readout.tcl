#Clean 
#rm -rf spyglass-1 
#close_project -force 
#-----------------------------------------------
set proj ebc5
new_project $proj
#----------------------------------------------- 
set top_module top_single_pixel
set lnt1 lint_rtl 
set lnt2 lint_rtl_enhanced 
#----------------------------------------------- 
#----------------------------------------------- 
#new_project spyglass-1 -force 
set_option enableSV yes 
#----------------------------------------------- 
#----------------------------------------------- 
read_file -type sourcelist files.f
#read_file -type verilog $top_module.sv 
set_option top {$top_module} 
#-----------------------------------------------
#----------------------------------------------- 
current_goal lint/$lnt1 -top $top_module 
#current_goal lint/lint_rtl_enhanced -top $top_module 
run_goal 
write_report spyglass_violations 
write_report moresimple 
write_report score 
write_report summary 
#----------------------------------------------- 
#close_project -force 
#gui_start
#exit -save
write_report moresimple > lint_$proj.txt

#-----------------------------------------------
current_goal lint/$lnt2 -top $top_module
#current_goal lint/lint_rtl_enhanced -top $top_module
run_goal
write_report spyglass_violations
write_report moresimple
write_report score
write_report summary
#-----------------------------------------------

write_report moresimple > lint_adv_$proj.txt
exit -save
