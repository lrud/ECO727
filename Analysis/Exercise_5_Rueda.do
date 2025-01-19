***** Exercise_5_Rueda.do
***** Angrist and Krueger (1991) Analysis: Effect of Schooling on Wages
***** Replication of Table 6

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

*** end part b

* Part C: Reproduce Table 6
* alternating OLS and TSLS columns

 eststo column_1: regress lwklywge educ i.yob // OLS (1)
  eststo column_2: ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob, first // TSLS (2)
   estat firststage
   estat overid
  eststo column_3: regress lwklywge educ i.yob ageq ageqsq // OLS (3)
  eststo column_4: ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) ib49.yob ageq ageqsq, first // TSLS (4)
   estat firststage
   estat overid
  eststo column_5: regress lwklywge educ i.race i.smsa i.married i.yob i.region // OLS (5)
  eststo column_6: ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) i.race i.smsa i.married ib49.yob ib9.region, first // TSLS (6)
   estat firststage
   estat overid
  eststo column_7: regress lwklywge educ i.race i.smsa i.married i.yob i.region ageq ageqsq // OLS (7)
  eststo column_8: ivregress 2sls lwklywge (educ = ib4.qob#ib49.yob) i.race i.smsa i.married ib49.yob ib9.region ageq ageqsq, first // TSLS (8)
   estat firststage
   estat overid
   
*** end part c

* Part D: Compare the Estimates
esttab wald, b(4) se(4)

* Compare 2SLS estimates
esttab qob_iv column_2 column_5 column_6 column_7 column_8, b(4) se(4)

*** end part d

* Part E: Display and Export Results
eststo dir

* Write estimates to log file
esttab ols wald qob_iv, b(4) se(4) stats(r2 N, fmt(%4.3f %9.0fc) labels("R2" "N")) ///
    nodepvars nostar obslast noomitted nobaselevels varwidth(24) alignment(D{.}{.}{-1}) ///
    title("Least-Squares Estimates of the log-Wage Regression") ///
    mtitles("OLS" "Wald" "IVQOB") ///
    order(_cons educ) ///
    coeflabels(_cons Constant ///
               educ "Years of Education") ///
    indicate("Year-of-Birth = *.yob", labels("\checkmark" "")) ///
    nonotes addnotes("Standard errors in parentheses." "Source:~Angrist and Krueger (1991).")

* Write to tex file
esttab ols wald qob_iv using "results/Exercise_5_table_a_Rueda.tex", ///
    b(4) se(4) stats(r2 N, fmt(%4.3f %9.0fc) labels("\$R^2\$" "\$N\$")) ///
    nodepvars nostar obslast noomitted nobaselevels varwidth(24) alignment(D{.}{.}{-1}) ///
    replace booktabs ///
    title("Least-Squares Estimates of the log-Wage Regression") ///
    mtitles("OLS" "Wald" "IVQOB") ///
    order(_cons educ) ///
    coeflabels(_cons Constant ///
               educ "Years of Education") ///
    indicate("Year-of-Birth = *.yob", labels("\checkmark" "")) ///
    nonotes addnotes("Standard errors in parentheses." "Source:~Angrist and Krueger (1991).")
	
*** end part e

* Part F: Reproduce First Half of Table 6
esttab column_1 column_2 column_3 column_4, ///
    b(4) se(4) stats(r2, fmt(%4.3f) labels("R2")) ///
    nodepvars nostar obslast noomitted nobaselevels varwidth(24) alignment(D{.}{.}{-1}) ///
    title("Re urns to Education: Alternative Estimates") ///
    mtitles("OLS" "TSLS" "OLS" "TSLS") ///
    order(educ race smsa married) ///
    coeflabels(educ "Years of Education" ///
               race "Race (1 = black)" ///
               smsa "SMSA (1 = center city)" ///
               married "Married (1 = married)") ///
    indicate("Year-of-Birth = *.yob", labels("Yes" "")) 

* Write to tex file
esttab column_1 column_2 column_3 column_4 using "results/Exercise_5_table_b_Rueda.tex", ///
    b(4) se(4) stats(r2, fmt(%4.3f) labels("\$R^2\$")) ///
    noconstant nodepvars nostar obslast noomitted nobaselevels varwidth(24) alignment(D{.}{.}{-1}) ///
    replace booktabs ///
    title("Returns to Education: Alternative Estimates") ///
    mtitles("OLS" "TSLS" "OLS" "TSLS") ///
    order(educ race smsa married) ///
    coeflabels(educ "Years of Education" ///
               race "Race (1 = black)" ///
               smsa "SMSA (1 = center city)" ///
               married "Married (1 = married)") ///
    indicate("Year-of-Birth = *.yob", labels("Yes" "")) ///
    nonotes addnotes("a. Standard errors in parentheses. Sample size is 486,926. Instruments are a full set of quarter-of-birth times year-of-birth interactions." ///
     "Sample consists of males born in the United States. The sample is drawn from the 5 percent samples of the 1980 Census." ///
     "The dependent variable is the log of weekly earnings. Age and age-squared are measured in quarters of years." ///
     "Each equation also includes an intercept.")
	 
*** end part f

log close results