***** Exercise_3_Rueda.do
***** CPS_ORG + CPI Data Merge
***** Exploration

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

*import CPI data 
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

*save, describe and summarize the reshaped data
save "../Data/CPI_data.dta", replace
describe
summarize

***end part b

*load cleaned CPS_ORG data, sort and describe
use "../Data/CPS ORGs, 1982-2024, Cleaned.dta", clear
sort year month
describe

**many to one merge
merge m:1 year month using "../Data/CPI_data.dta", keep(match)
tabulate _merge
drop _merge

*meanonly summary & scalar store
summarize cpi if year == 2024 & month == 11, meanonly
scalar cpi_nov2024 = r(mean)
scalar list cpi_nov2024

*create real weekly wage var
generate rwage = (earnweek * cpi_nov2024) / cpi
label variable rwage "Real weekly wage in November 2024 dollars"

*save dataset, review results
save "../Data/CPS-ORG with CPI, 1982-2024.dta", replace
describe
summarize 

**end part c

*collapse the data to annual statistics
collapse (mean) mean = rwage (p10) p10 = rwage (p50) p50 = rwage (p90) p90 = rwage, by(year)

*create the log difference variable (ldiff)
generate ldiff = log(p90) - log(p10)

*label the variables
label variable mean "Mean real weekly wage"
label variable p10 "10th percentile of real weekly wage"
label variable p50 "50th percentile of real weekly wage"
label variable p90 "90th percentile of real weekly wage"
label variable ldiff "Log difference between 90th and 10th percentiles"

*save the collapsed dataset, describe and summarize 
save "../Data/CPS-ORG, Wage Percentiles, 1982-2024.dta", replace
describe
summarize

*plot the mean and percentiles over time
twoway (line mean year, lcolor(blue)) ///
       (line p10 year, lcolor(red)) ///
       (line p50 year, lcolor(green)) ///
       (line p90 year, lcolor(orange)), ///
       xtitle(Year) xlabel(1980(10)2020) xtick(1985(5)2015) ///
       ytitle("Real Weekly Wage (November 2024 dollars)") ylabel(, noticks) ///
       legend(label(1 "Mean") label(2 "10th Percentile") label(3 "50th Percentile") label(4 "90th Percentile")) ///
       scheme(s2color) name(g1, replace)

*plot ldiff over time
twoway (line ldiff year, lcolor(blue)), ///
       xtitle(Year) xlabel(1980(10)2020) xtick(1985(5)2015) ///
       ytitle("Log Difference (ldiff)") ylabel(, noticks) ///
       scheme(s2color) name(g2, replace)

***end part d

