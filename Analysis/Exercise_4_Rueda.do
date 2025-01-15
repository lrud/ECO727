***** Exercise_4_Rueda.do
***** Factor Variables, CPS-ORG/CPI Data, 1982–2024 
***** Exploration

*preliminary instructions
cd "~/OneDrive/ECO 727/Analysis"
log using "Exercise_4_Rueda.smcl", name(results) replace 
set scheme s2color
global ex=4
global lname="Rueda"
global endyear=2024
global startyear=1982
global numyear=$endyear-$startyear+1

*import CPS & CPI Data, keep earnweek 
use "../Data/CPS-ORG with CPI, 1982-2024.dta", clear
run data_check
keep if !mi(earnweek)

*gen working variables
gen experience = age - grade + 6
drop if experience <=0 // experience < 0 not possible
gen exp2 = (experience)^2
gen lrwage = log(rwage)

***end part a

*regression and joint statistical significance
regress lrwage grade experience exp2 [pw=earnwt]
testparm experience exp2

// Note the concave relatiionship b/t exp2 and lrwage. exp2 coef. is negative. p-value==0 as well

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

*update previous regression to include interaction term b/t grade and year
regress lrwage year#c.grade experience exp2 i.year i.female i.race i.region i.occupation i.industry [pw=earnwt]

*save the coefficients to a dataset using matrix and svmat2 commands
matrix b = e(b)[1, 1..$numyear]'
clear
svmat2 b, names(grade_coef) rnames(tag)
list, noobs

*extract year from tag and rename
generate year = real(substr(tag, 1, 4))
drop tag
order year grade_coef
replace grade_coef = grade_coef * 100

*describe and summarize the data
describe
summarize
tempfile temp1
save `temp1', replace

*** end part d

*importing wage differential data
use "../Data/CPS-ORG, Wage Percentiles, 1982-2024.dta", clear
keep year ldiff
tempfile temp2
save `temp2', replace
use `temp1', clear
merge 1:1 year using `temp2'

*saving
save "../Data/Grade_coef and ldiff, 1982-2024.dta", replace
describe
summarize
list

*** end part e

*create a line plot of the two series
line ldiff y, yaxis(1) || line grade_coef y, yaxis(2) ///
xtitle("Year") xlabel(1980(10)2025) xtick(1980(5)2015) ///
ytitle("90-10 log-Wage Differential (%)", axis(1)) ylabel(150(10)200, noticks axis(1)) ///
ytitle("Rate of Return to Schooling (%)", axis(2)) ylabel(5(2)10, noticks axis(2)) ///
text(182 1985 "90-10 Differential") text(155 1985 "Return to Schooling") ///
scheme(Wide727Scheme) name(g1, replace)
graph export results/inequality_schooling_line.png, name (g1) width(600) replace 

*create a scatterplot of ldiff and grade_coef
scatter ldiff grade_coef || lfit ldiff grade_coef ||, ///
xtitle("Rate of Return to Schooling (%)") xlabel(4(1)10) ///
ytitle("90-10 log-Wage Differential (%)") ylabel(160(20)200, noticks) ///
scheme(Squarish727Scheme) name(g2, replace)
graph export results/inequality_schooling_scatter.png, name (g2) width(450) replace 

*** end part f

log close results




