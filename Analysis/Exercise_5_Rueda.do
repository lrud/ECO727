***** Exercise_5_Rueda.do
***** Angrist and Krueger (1991) Analysis: Effect of Schooling on Wages
***** 

* Preliminary instructions
cd "C:\Users\melin\OneDrive\ECO 727\Analysis"
//log using "Exercise_5_Rueda.smcl", name(results) replace
set scheme s2color
global ex=5
global lname="Rueda"

* Part A: Data Preparation
use "../Data/Birth Quarter.dta" if cohort == 4, clear
//run data_check

* Ensure the data is from the 1980 Census and the 1940s cohort
assert census == 80 // Check that the data is from the 1980 Census
assert cohort == 4    // Check that the data is for the 1940s cohort
assert _N == 486926   // Correct sample size for 1940s cohort in 1980 Census

generate q1 = (qob == 1) // Dummy for birth in the first quarter
generate ageqsq = ageq^2 // Squared term for age

***end part a

* Part B: Estimate OLS and 2SLS
* OLS regression of lwklywge on educ
regress lwklywge educ
eststo ols

* Wald estimator using 2SLS (q1 as instrument)
ivregress 2sls lwklywge (educ = q1)
eststo wald
estat firststage // Check for weak instruments

* 2SLS regression of lwklywge on educ, using qob as instrument and controlling for yob
ivregress 2sls lwklywge (educ = ib4.qob) ib49.yob
eststo qob_iv
estat firststage // Check for weak instruments

*** end part b

* Part C: Reproduce Table 6
* Loop to estimate models for columns 1-8
forvalues i = 1/8 {
    if `i' == 1 {
        regress lwklywge educ ib49.yob // Column 1: OLS with year-of-birth dummies
    }
    else if `i' == 2 {
        ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob // Column 2: TSLS with qob#yob interactions
    }
    else if `i' == 3 {
        regress lwklywge educ ageq ageqsq ib49.yob // Column 3: OLS with age, age-squared, and year-of-birth dummies
    }
    else if `i' == 4 {
        regress lwklywge educ ageq ageqsq ib49.yob i.race i.region i.smsa i.married // Column 4: OLS with additional controls
    }
    else if `i' == 5 {
        ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob // Column 5: TSLS with qob#yob interactions
    }
    else if `i' == 6 {
        ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ageq ageqsq ib49.yob // Column 6: TSLS with qob#yob interactions
    }
    else if `i' == 7 {
        ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ageq ageqsq ib49.yob i.race i.region i.smsa i.married // Column 7: TSLS with qob#yob interactions
    }
    else if `i' == 8 {
        ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob // Column 8: TSLS with qob#yob interactions
    }
    eststo column_`i'
    
    * Call estat firststage only for 2SLS models (columns 2, 5, 6, 7, and 8)
    if inlist(`i', 2, 5, 6, 7, 8) {
        estat firststage // Check for weak instruments in TSLS models
        estat overid     // Test overidentifying restrictions
    }
}

*** end part c