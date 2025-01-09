***** Exercise_3_Rueda.do
***** 
***** 

*preliminary instructions
cd "~/OneDrive/ECO 727/Analysis"
// log using "Exercise_3_Rueda.smcl", replace 
global ex=3
global lname="Rueda"
global endyear=2024

* Append the three files into one stacked dataset using relative paths
append using "../Data/morg79.dta" "../Data/morg80.dta" "../Data/morg81.dta", ///
    keep(year intmonth minsamp classer esr age race sex gradeat uhours earnwke earnwt)

* Run data_check 
// run data_check

* Rename variables for consistency with IPUMS data
rename intmonth month
rename minsamp inmonth