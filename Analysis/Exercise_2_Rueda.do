***** Exercise_2_Rueda.do
***** Use the Edited CPS-ORG Data
***** CPS-ORG data extracted from IPUMS

* Preliminary instructions
cd "~/OneDrive/ECO 727/Analysis"
log using "Exercise_2_Rueda.smcl", replace 
global ex=2
global lname="Rueda"
global endyear=2024

* Importing data
use "../Data/CPS ORGs, 1982-2024.dta", clear

* Running data check and dropping variables
run data_check 
drop serial cpsid cpsidp pernum hwtfinl wtfinl

*** End part A

* Recode missing values for categorical variables
replace region = . if region == 97
replace earnweek2 = . if inlist(earnweek2, 999999.98, 999999.97) // Recode missing values for earnweek2
replace hourwage2 = . if hourwage2 == 999.99
replace sex = . if sex == 9
replace race = . if race == 999
replace empstat = . if empstat == 00
replace occ1950 = . if inlist(occ1950, 997, 999)
replace ind1950 = . if inlist(ind1950, 000, 001, 998, 999)
replace classwkr = . if inlist(classwkr, 00, 99)
replace uhrswork1 = . if uhrswork1 == 999
replace educ = . if inlist(educ, 000, 001, 999)
replace hourwage = . if hourwage == 999.99
replace paidhour = . if inlist(paidhour, 0, 6, 7) // Recode invalid responses as missing
replace union = . if union == 0
replace earnweek = . if earnweek == 9999.99
replace uhrsworkorg = . if inlist(uhrsworkorg, 998, 999)

* Generate female dummy variable
generate female = (sex == 2)
label variable female "female (1=yes, 0=no)"

* Create a proper dummy variable for paidhour
generate paidhour_dummy = (paidhour == 1) if !missing(paidhour)
label variable paidhour_dummy "paid hourly (1=yes, 0=no)"

* Generate new race variable with consistent categories
generate race_orig = race  // Save original coding
generate race_recode = .   // Create new variable for recoded race

* Recode to consistent categories across all years
replace race_recode = 1 if race == 100 // 1. white (non-hispanic)
replace race_recode = 2 if race == 200 // 2. black
replace race_recode = 3 if race == 300 // 3. american indian/aleut/eskimo
replace race_recode = 4 if inlist(race, 650, 651, 652) // 4. asian/pacific islander
replace race_recode = 5 if race == 700 // 5. other race
replace race_recode = 6 if inrange(race, 801, 830) // 6. multiple races (combining all mixed categories)

* Label new race variable
label define race_label 1 "white" 2 "black" 3 "american indian" ///
                        4 "asian/pacific islander" 5 "other" 6 "multiple races"
label values race_recode race_label
label variable race_recode "race - consistent coding across years"

* Initialize occupation, industry, and grade variables
generate occupation = .
generate industry = .
generate grade = .

* Grade variable recoding
* 1982-1991 grade recoding
replace grade = 0 if educ == 2 & year <= 1991 // none or preschool
replace grade = 1 if educ == 11 & year <= 1991
replace grade = 2 if educ == 12 & year <= 1991
replace grade = 3 if educ == 13 & year <= 1991
replace grade = 4 if educ == 14 & year <= 1991
replace grade = 5 if educ == 21 & year <= 1991
replace grade = 6 if educ == 22 & year <= 1991
replace grade = 7 if educ == 31 & year <= 1991
replace grade = 8 if educ == 32 & year <= 1991
replace grade = 9 if educ == 40 & year <= 1991
replace grade = 10 if educ == 50 & year <= 1991
replace grade = 11 if educ == 60 & year <= 1991
replace grade = 12 if (educ == 72 | educ == 73) & year <= 1991 // 72 is 'diploma unclear'
replace grade = 13 if educ == 80 & year <= 1991
replace grade = 14 if educ == 90 & year <= 1991
replace grade = 15 if educ == 100 & year <= 1991
replace grade = 16 if educ == 110 & year <= 1991
replace grade = 17 if educ == 121 & year <= 1991
replace grade = 18 if educ == 122 & year <= 1991

* 1992-2024 grade recoding (Jaeger 1997)
replace grade = 0 if educ == 2 & year >= 1992
replace grade = 2.5 if educ == 10 & year >= 1992 // grades 1-4
replace grade = 5.5 if educ == 20 & year >= 1992 // grades 5-6
replace grade = 7.5 if educ == 30 & year >= 1992 // grades 7-8
replace grade = 9 if educ == 40 & year >= 1992 // grade 9
replace grade = 10 if educ == 50 & year >= 1992 // grade 10
replace grade = 11 if educ == 60 & year >= 1992 // grade 11
replace grade = 12 if (educ == 71 | educ == 73) & year >= 1992 // 71 is 'no diploma'
replace grade = 13 if educ == 81 & year >= 1992 // some college, no degree
replace grade = 14 if (educ == 91 | educ == 92) & year >= 1992 // academic or vocational associate's degree
replace grade = 16 if educ == 111 & year >= 1992
replace grade = 18 if inlist(educ, 123, 124, 125) & year >= 1992

* Order grade, before(educ)
label variable grade "education (years)"

* 1982-2023 occupation recoding
replace occupation = 1 if occ1950 >= 000 & occ1950 <= 099 // professional, technical
replace occupation = 2 if occ1950 >= 100 & occ1950 <= 290 // managers, officials, proprietors
replace occupation = 3 if occ1950 >= 300 & occ1950 <= 390 // clerical, kindred
replace occupation = 4 if occ1950 >= 400 & occ1950 <= 490 // sales
replace occupation = 5 if occ1950 >= 500 & occ1950 <= 594 // craftsmen
replace occupation = 6 if occ1950 >= 600 & occ1950 <= 690 // operatives
replace occupation = 7 if occ1950 >= 700 & occ1950 <= 720 // service (private hh)
replace occupation = 8 if occ1950 >= 730 & occ1950 <= 790 // service (other)
replace occupation = 9 if occ1950 >= 810 & occ1950 <= 970 // laborers
replace occupation = 10 if occ1950 == 595 // armed forces

* 1982-2023 industry recoding
replace industry = 1 if ind1950 >= 105 & ind1950 <= 239 // agriculture, fisheries, mining
replace industry = 2 if ind1950 == 246 // construction
replace industry = 3 if ind1950 >= 306 & ind1950 <= 399 // durable manufacturing
replace industry = 4 if ind1950 >= 406 & ind1950 <= 499 // nondurable manufacturing
replace industry = 5 if ind1950 >= 506 & ind1950 <= 598 // communications, transportation, utilities
replace industry = 6 if ind1950 >= 606 & ind1950 <= 627 // wholesale trade
replace industry = 7 if ind1950 >= 636 & ind1950 <= 699 // retail trade
replace industry = 8 if (ind1950 >= 716 & ind1950 <= 746) | (ind1950 >= 868 & ind1950 <= 879) | (ind1950 >= 897 & ind1950 <= 899) // professional services, fire
replace industry = 9 if inlist(ind1950, 888, 896) // education, welfare services
replace industry = 10 if ind1950 >= 906 & ind1950 <= 936 // public administration
replace industry = 11 if (ind1950 >= 806 & ind1950 <= 859) | inlist(ind1950, 997, 998) // other services

* Add value labels
label define occupation 1 "professional, technical" 2 "managers, officials, proprietors" ///
                        3 "clerical, kindred" 4 "sales" 5 "craftsmen" 6 "operatives" ///
                        7 "service (private hh)" 8 "service (other)" 9 "laborers" ///
                        10 "armed forces"

label define industry 1 "agriculture, fisheries, mining" 2 "construction" ///
                      3 "durable manufacturing" 4 "nondurable manufacturing" ///
                      5 "communications, transportation, utilities" 6 "wholesale trade" ///
                      7 "retail trade" 8 "professional services, fire" ///
                      9 "education, welfare services" 10 "public administration" ///
                      11 "other services"

* Apply labels
label values occupation occupation
label values industry industry

* Add variable labels
label variable occupation "occupation (1-10)"
label variable industry "industry (1-11)"

* Error checking for recoding
assert inlist(occupation, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, .) if !missing(occ1950)
assert inlist(industry, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, .) if !missing(ind1950)

* Verify recoding
tabulate year occupation if occupation != ., missing
tabulate year industry if industry != ., missing

* Check that industry contains all instances of ind1950
count if !missing(ind1950) & missing(industry)
if r(N) > 0 {
    display "WARNING: There are " r(N) " instances where ind1950 is non-missing but industry is missing."
}
else {
    display "All instances of ind1950 have been successfully recoded into industry."
}

* Check that no instances are missing from industry compared to ind1950
count if !missing(industry) & missing(ind1950)
if r(N) > 0 {
    display "WARNING: There are " r(N) " instances where industry is non-missing but ind1950 is missing."
}
else {
    display "No instances are missing from industry compared to ind1950."
}

* Get max value of earnweek2 for recent period before any replacements
summarize earnweek2 if (year==2023 & month>=4) | (year==2024 & month<=3), detail
return list
scalar max_earnweek2 = r(max)

* Store the max value for verification
gen max_val = r(max) if _n == 1
display "Maximum value of earnweek2 for recent period: " max_earnweek2

* Replace missing values with rounded values from earnweek2 and hourwage2
replace earnweek = earnweek2 if missing(earnweek) & month>=4 & year>=2023
replace hourwage = hourwage2 if missing(hourwage) & month>=4 & year>=2023

* Create topcode variable for earnweek
generate topcode = .
label variable topcode "top-coded earnweek (1=yes, 0=no)"

* Identify topcoded values by period
replace topcode = 1 if earnweek >= 9999.99   // topcode for earnweek
replace topcode = 1 if earnweek >= 999 & inrange(year, 1982, 1988) // 1982-1988
replace topcode = 1 if earnweek >= 1923 & inrange(year, 1989, 1997) // 1989-1997
replace topcode = 1 if earnweek >= 2884.61 & (inrange(year, 1998, 2022) | (year==2023 & month<=3)) // 1998-March 2023
replace topcode = 1 if earnweek >= max_earnweek2 & ((year==2023 & month>=4) | (year==2024 & month<=3)) & mish==4 // April 2023-March 2024, MISH 4
replace topcode = 1 if earnweek >= 2884.61 & ((year==2023 & month>=4) | (year==2024 & month<=3)) & mish==8 // April 2023-March 2024, MISH 8
replace topcode = 0 if missing(topcode) & !missing(earnweek)

* Verify topcoding implementation
display "Verifying topcode implementation..."
count if missing(topcode) & !missing(earnweek)
tab year topcode if year >= 2023, col
tab month topcode if year == 2024, col
tab mish topcode if year == 2024, col

* Now safe to drop earnweek2 and hourwage2
drop earnweek2 hourwage2

*** End part B

* Compress and save the cleaned data
compress
save "../Data/CPS ORGs, 1982-2024, Cleaned.dta", replace

* Describe and summarize the final dataset
describe
summarize

*** End part C

log close