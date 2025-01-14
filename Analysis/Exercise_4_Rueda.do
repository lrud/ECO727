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

*regression and joint statistical significance
regress lrwage grade experience exp2
testparm experience exp2

// Note the concace relatiionship b/t exp2 and lrwage. exp2 coef. is negative. p-value==0 as well

*display to find exp val where f'=0
display -(_b[experience]) / (2 * _b[exp2]) //about 41 years

***end part b

*secondary regression to include race, region, occupation, industry and year effects and joint s.s test
regress lrwage grade experience exp2 i.female##c.race i.region##c.year i.occupation##c.industry##c.year
testparm race
testparm i.region
testparm i.occupation
testparm industry
testparm year

*** end part c