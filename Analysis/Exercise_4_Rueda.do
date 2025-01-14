***** Exercise_4_Rueda.do
***** Factor Variables, CPS-ORG/CPI Data, 1982–2024 
***** Exploration

*preliminary instructions
cd "~/OneDrive/ECO 727/Analysis"
//log using "Exercise_4_Rueda.smcl", name(results) replace 
set scheme s2color
global ex=4
global lname="Rueda"
global endyear=2024
global month=11

//run data_check

*import CPS & CPI Data, keep earnweek 
use "../Data/CPS-ORG with CPI, 1982-2024.dta", clear
keep if !mi(earnweek)

*gen working variables
gen experience = age - grade + 6
gen exp2 = (experience)^2
gen lrwage = log(rwage)

***end part A
