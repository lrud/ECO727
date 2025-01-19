***** Exercise_5_Rueda.do
***** Angrist and Krueger (1991) Analysis: Effect of Schooling on Wages

* Preliminary instructions
cd "C:\Users\melin\OneDrive\ECO 727\Analysis"
log using "Exercise_5_Rueda.smcl", name(results) replace
set scheme s2color
global ex=5
global lname="Rueda"

* Part A: Data Preparation
use "../Data/Birth Quarter.dta" if cohort == 4, clear
run data_check

* Verify data conditions
assert census == 80 
assert cohort == 4  
assert _N == 486926 

* Generate required variables
generate q1 = (qob == 1)   
generate ageqsq = ageq^2   

***end part a

* Part B: Estimate OLS and 2SLS
* OLS regression
regress lwklywge educ
eststo ols

* Wald estimator using 2SLS
ivregress 2sls lwklywge (educ = q1)
eststo wald
estat firststage    

* 2SLS with quarter of birth instruments
ivregress 2sls lwklywge (educ = ib4.qob) ib49.yob
eststo qob_iv
estat firststage    
estat overid        

testparm i.yob

*** end part b

* Part C: Reproduce Table 6
forvalues i = 1/8 {
    if `i' == 1 {
        regress lwklywge educ ib49.yob 
        eststo column_`i'
        testparm i.yob
    }
    else if `i' == 2 {
        ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob 
        eststo column_`i'
        estat firststage
        estat overid
        estadd scalar overid = r(p)
        testparm i.yob
    }
    else if `i' == 3 {
        regress lwklywge educ ageq ageqsq ib49.yob 
        eststo column_`i'
        testparm ageq ageqsq
        testparm i.yob
    }
    else if `i' == 4 {
        regress lwklywge educ ageq ageqsq ib49.yob i.race i.region i.smsa i.married 
        eststo column_`i'
        testparm ageq ageqsq
        testparm i.yob
        testparm i.race
        testparm i.region
    }
    else if `i' == 5 {
        ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob 
        eststo column_`i'
        estat firststage
        estat overid
        estadd scalar overid = r(p)
        testparm i.yob
    }
    else if `i' == 6 {
        ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ageq ageqsq ib49.yob 
        eststo column_`i'
        estat firststage
        estat overid
        estadd scalar overid = r(p)
        testparm i.yob
    }
    else if `i' == 7 {
        ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ageq ageqsq ib49.yob i.race i.region i.smsa i.married 
        eststo column_`i'
        estat firststage
        estat overid
        estadd scalar overid = r(p)
        testparm i.yob
    }
    else if `i' == 8 {
        ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob 
        eststo column_`i'
        estat firststage
        estat overid
        estadd scalar overid = r(p)
        testparm i.yob
    }
}

*** end part c

* Part D: Compare the Estimates
esttab wald, b(4) se(4)

* Compare 2SLS estimates
esttab qob_iv column_2 column_5 column_6 column_7 column_8, b(4) se(4)

foreach model in qob_iv column_2 column_5 column_6 column_7 column_8 {
    est restore `model'
    estat firststage
    estat overid
}

*** end part d

* Part E: Display and Export Results
eststo dir

* Write estimates to log file
esttab ols wald qob_iv, b(4) se(4) stats(r2 N, fmt(%4.3f %9.0fc) labels("R2" "N")) ///
    nodepvars nostar obslast noomitted nobaselevels varwidth(24) alignment(r) ///
    title("Least-Squares Estimates of the log-Wage Regression") ///
    mtitles("OLS" "Wald" "2SLS") ///
    order(_cons educ) ///
    coeflabels(_cons Constant educ "Years of Education") ///
    indicate("Birth-Year Dummies = *.yob", labels("\checkmark" "")) ///
    nonotes addnotes("Standard errors in parentheses." "Source:~Angrist and Krueger (1991).")

* Write to tex file
esttab ols wald qob_iv using "results/Exercise_5_table_a_Rueda.tex", ///
    b(4) se(4) stats(r2 N, fmt(%4.3f %9.0fc) labels("\$R^2\$" "\$N\$")) ///
    nodepvars nostar obslast noomitted nobaselevels varwidth(24) alignment(D{.}{.}{-1}) ///
    replace booktabs ///
    title("Least-Squares Estimates of the log-Wage Regression") ///
    mtitles("OLS" "Wald" "2SLS") ///
    order(_cons educ) ///
    coeflabels(_cons Constant educ "Years of Education") ///
    indicate("Birth-Year Dummies = *.yob", labels("\checkmark" "")) ///
    nonotes addnotes("Standard errors in parentheses." "Source:~Angrist and Krueger (1991).")

*** end part e

* Part F: Reproduce First Half of Table 6
esttab column_1 column_2 column_3 column_4, ///
    b(4) se(4) stats(r2 N, fmt(%4.3f %9.0fc) labels("R2" "N")) ///
    nodepvars nostar obslast noomitted nobaselevels varwidth(24) alignment(r) ///
    title("Returns to Education: Alternative Estimates") ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    order(_cons educ race smsa married) ///
    coeflabels(_cons Constant ///
               educ "Years of Education" ///
               race "Race (1 = black)" ///
               smsa "SMSA (1 = center city)" ///
               married "Married (1 = married)") ///
    indicate("Year-of-Birth = *.yob" "Age Controls = ageq ageqsq" ///
            "Additional Controls = *.race *.region *.smsa *.married", ///
    labels("Yes" "No")) ///
    nonotes addnotes("Standard errors in parentheses") 

* Write to tex file
esttab column_1 column_2 column_3 column_4 using "results/Exercise_5_table_b_Rueda.tex", ///
    b(4) se(4) stats(r2 N, fmt(%4.3f %9.0fc) labels("\$R^2\$" "\$N\$")) ///
    nodepvars nostar obslast noomitted nobaselevels varwidth(24) alignment(D{.}{.}{-1}) ///
    replace booktabs ///
    title("Returns to Education: Alternative Estimates") ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    order(_cons educ race smsa married) ///
    coeflabels(_cons Constant ///
               educ "Years of Education" ///
               race "Race (1 = black)" ///
               smsa "SMSA (1 = center city)" ///
               married "Married (1 = married)") ///
    indicate("Year-of-Birth = *.yob" "Age Controls = ageq ageqsq" ///
            "Additional Controls = *.race *.region *.smsa *.married", ///
    labels("Yes" "No")) ///
    nonotes addnotes("Standard errors in parentheses")

*** end part f

log close results