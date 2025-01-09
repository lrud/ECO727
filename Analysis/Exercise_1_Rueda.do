***** Exercise 1.do
***** accessing the cps outgoing rotation group files, 1982-2024
***** cps-org data extracted from ipums

*preliminary instructions
cd "~/OneDrive/ECO 727/Analysis"
log using "Exercise_1_Rueda.smcl", replace
global ex=1
global lname="Rueda"

*importing data 
use "../Data/cps_00001.dta", clear

*running data check and doing preliminary tabulation
run data_check
tabulate mish, missing
tabulate eligorg, missing
tabulate labforce, missing
tabulate year mish, missing

*drop mish condition and data structure confirmation
keep if mish==4 | mish==8
tabulate month mish

*general data analysis 
describe
summarize
list year month race sex region educ empstat union in 1/10  // first set of variables
list year classwkr qearnwee paidhour mish region empstat in 1/10  // second set of variables
tab1 asecflag labforce eligorg month mish region sex race empstat classwkr educ qearnwee paidhour union, missing // Categorical Variable < 50 categories

* from results above - eligorg, asecflag & labforce have one category, so we can drop these variables.
drop asecflag eligorg labforce

* Check when American Indians and Asians first appear in race variable
numlabel RACE, add
tab race, missing
tabulate year race if race==300 | race==650 | race==651, nol

*** end part d

* Compressing and Saving the Data
compress
save "../Data/CPS ORGs, 1982-2024", replace
describe
summarize

*** end part e

log close results


