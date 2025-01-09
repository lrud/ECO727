***** data_check.do: creates a data set of summary statistics to be submitted and checked for errors
  preserve
  tabstat *, statistics(count min max mean) save
  matrix a=r(StatTotal)'
  clear
  svmat2 a, names(col) rnames(variable)
  order variable, before(N)
  describe
  format N %9.0fc
  format Mean %10.4fc
  note: $lname
  save results/Exercise_${ex}_${lname}, replace
  restore
