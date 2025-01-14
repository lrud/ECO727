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
global startyear=1982
global numyear=$endyear-$startyear+1

//run data_check

*import CPS & CPI Data, keep earnweek 
use "../Data/CPS-ORG with CPI, 1982-2024.dta", clear
keep if !mi(earnweek)

*gen working variables
gen experience = age - grade + 6
drop if experience <=0 // experience < 0 not possible
gen exp2 = (experience)^2
gen lrwage = log(rwage)

***end part A

*regression and joint statistical significance
regress lrwage grade experience exp2 [pw=earnwt]
testparm experience exp2

// Note the concace relatiionship b/t exp2 and lrwage. exp2 coef. is negative. p-value==0 as well

*display to find exp val where f'=0
display -(_b[experience]) / (2 * _b[exp2]) //about 41 years

***end part b

*secondary regression to include race, region, occupation, industry and year effects and joint s.s test
regress lrwage grade experience exp2 i.female i.race i.region i.occupation i.industry i.year [pw=earnwt]
testparm i.race
testparm i.region
testparm i.occupation
testparm i.industry
testparm i.year

*** end part c

// update previous regression to include interaction term b/t grade and year
regress lrwage experience exp2 i.year i.female i.race i.region i.occupation i.industry year#c.grade [pw=earnwt]

// Save the coefficients to a dataset using matrix and svmat2 commands
matrix b = e(b)[1, 1..$numyear]'
clear
svmat2 b, names(grade_coef) rnames(tag)
list, noobs

//extract yeer from tag and rename
generate y = real(substr(tag, 1, 4))
drop tag
order y grade_coef
replace grade_coef = grade_coef * 100

// Describe and summarize the data
describe
summarize

*** end part d