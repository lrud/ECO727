***** Exercise_3_Rueda.do
***** 
***** 

*preliminary instructions
cd "~/OneDrive/ECO 727/Analysis"
// log using "Exercise_3_Rueda.smcl", replace 
set scheme s2color
tempfile temp1
tempfile temp2
global ex=3
global lname="Rueda"
global endyear=2024

*append the three files into one stacked dataset using relative paths
append using "../Data/morg79.dta" "../Data/morg80.dta" "../Data/morg81.dta", ///
    keep(year intmonth minsamp classer esr age race sex gradeat uhours earnwke earnwt)

*run data_check 
// run data_check

*rename variables for consistency with IPUMS data
rename intmonth month
rename minsamp inmonth

*filter data
keep if age >= 18 & age <= 64 & esr == 1 & (classer == 1 | classer == 2)

*describe and summarize the data
describe
summarize earnwke, detail
tab year if missing(earnwke)

***end part a

*import CPI data using a relative path
import excel "../Data/SeriesReport-20250109185653_d21c9e.xlsx", cellrange(A12:O124) firstrow clear

*rename variables to have common stub 'v'
rename Year year
rename Jan v1
rename Feb v2
rename Mar v3
rename Apr v4
rename May v5
rename Jun v6
rename Jul v7
rename Aug v8
rename Sep v9
rename Oct v10
rename Nov v11
rename Dec v12

*drop HALF1 and HALF2 for reshape operation
drop HALF1 HALF2

*reshape data from wide to long format
reshape long v, i(year) j(month)

*rename the reshaped CPI variable
rename v cpi

*create month labels
label define months 1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" ///
    7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec"
label values month months

*label variables
label variable year "Year"
label variable month "Month"
label variable cpi "Consumer Price Index (CPI)"

*format the CPI variable
format cpi %9.2f

*sort the data by year and month
sort year month

*save the reshaped data
save "../Data/CPI_data.dta", replace

*describe the data
describe

*summarize the data
summarize cpi

***end part b