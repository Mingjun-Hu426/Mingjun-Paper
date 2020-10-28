set more off
capture log close
capture clear

log using anitamerge, t replace

use Rst_12
drop a6 a7 a10 a16 a17 a18 a22 a23 a24 a25 a26 a27 a28 a29 a30 a31 a15a a26a a5a a5a1 a5b a5c a5c1 a5d a5e a5f a8a a8b a8b1 aa11 aa12 aa13 ab5 ab6 ab7 ab8 adult agri child job_wage pe roster line a20a a20b
save,replace

use en_00
keep idind u3_en u2_en wave hhid
sort idind wave
save, replace

use Rst_12
merge 1:1 idind wave using en_00.dta
drop _merge
save anitav1

use HHINC_10
keep wave hhid hhsize hhinc_cpi hhincpc_cpi hhincgross_cpi hhexpense_cpi
sort hhid wave
save, replace

use anitav1
merge m:1 hhid wave using HHINC_10
drop _merge
save, replace

use Mast_pub_12 
drop dod_rpt cause chns_m1 moon_dob_y dod_y
save, replace

use anitav1
merge m:1 idind using Mast_pub_12
drop _merge
save,replace

use Urban_11
keep commid t1 t2 wave index comm denc div econ health house market soc trans edc mart sani
sort commid wave
save, replace
use anitav1
merge m:1 commid wave using Urban_11
drop _merge
save,replace

use Birthmast_pub_12
*drop children died before 5 yrs old (2.43% dropped)
gen age= s56- west_dob_y
drop if age<=5
*count number of siblings
by idind_m, sort: gen nvals=_n
egen nsib = max( nvals ), by( idind_m ) 
label var nsib "number of siblings" 
replace nsib= nsib-1
ren idind_c idind
duplicates report idind
bysort idind: gen copies=_N
browse if copies>1
drop if copies>1
keep idind_m idind nsib
save nsib1

use Relationmast_pub_00
gen sib = 1 if rel_1==11
egen nsib = total(sib==1), by( idind_1 )
label var nsib "number of siblings"
keep idind_1 nsib
duplicates drop
ren idind_1 idind
save nsib2

use anitav1
merge m:1 idind using nsib1
drop _merge
save,replace

use fine-ebenstein
ren province t1
label var t1 "province"
ren birthyear west_dob_y
drop premium bonus
save, replace

use anitav1
merge m:1 t1 west_dob_y using fine-Ebenstein
drop _merge
save, replace

use EDUC_12
keep idind wave a11 a12
save,replace
use anitav1
merge m:1 idind wave using EDUC_12
drop _merge
save, replace

use Carec_HH_12
keep wave k44a hhid k34_hh k35_hh k36_hh k37_hh k38_hh k39_hh k40_hh k41_hh k42_hh
sort hhid wave
save, replace
use anitav1
merge m:1 hhid wave using Carec_HH_12
drop _merge
save, replace

use anitav1
merge m:1 idind using nsib2, update
drop _merge
save, replace

use Jobs_12
keep idind wave b2 hhid b4 b5 b10
save, replace
use anitav1
merge m:m idind wave using Jobs_12
drop _merge
save, replace

use HH_asset_12
keep l9 l16 l20 l24 l28 l32 l19 l23 l27 l31 l82 l83 l100 l101 l105 l106 l110 l111 l115 l116 l120 l121 l125 l126 l140 l141 wave l140e l141e l202 hhid
save, replace
use anitav1
merge m:m hhid wave using HH_asset_12
drop _merge
save, replace

use INDINC_10
keep hhid idind wave index_new indinc_cpi
save, replace
use anitav1
merge m:m idind wave using INDINC_10
drop _merge
save, replace

use anitav1
replace a11 = a11-10 if a11>=10 & a11<=17
replace a11=. if a11==-9
replace a11 = a11-14 if a11>=21 & a11<=29
replace a11 = a11-16 if a11>=31 & a11<=36
save, replace

use anitav1
replace nationality=. if nationality==-9
replace nationality=0 if nationality>=2 & nationality<=20
label var nationality "1=han 0=minority"
save, replace

use anitav1
gen nchild = nsib +1
gen finerate = 0
replace finerate = fine if  policy==1 &nchild==2
replace finerate=fine*0.25 if policy ==1.5 & nchild==2
replace finerate=fine*0.1 if nationality==0 & nchild==2
replace finerate=fine*3 if policy==1 & nchild==3
replace finerate=fine*2.5 if policy==1.5 & nchild==3
replace finerate=fine*0.5 if nationality==0 & nchild==3
replace finerate=fine*nchild if nchild>=4
replace finerate=finerate*1.5 if t2==1
label var finerate "finerate at province level"
label var nchild "number of children in the HH"
gen prefinecom = finerate* denc
label var prefinecom "predicted fine at community level"
save, replace

* this file aims at getting the information from the parents' educatiuon and then merge it back with the anita12 data set
* the goal is to have on the same row, the education of the individual as well as the parents' education levels.  


* first getting information from the father
* taking maximum level of education of parent* in
* Now, I will use anita14 (with a11 being the numbers of years ,rather than the classification of education categories
* 

use anitav1
sort idind
collapse (max) fathera11=a11,by(idind)
sum
rename idind idind_f
save educationfather

* second, getting information from the mother

use anitav1
sort idind
collapse (max) mothera11=a11,by(idind)
rename idind idind_m
sort idind_m
save educationmother

use anitav1
sort idind_f
merge m:m idind_f using educationfather
drop _merge
sort idind_m
merge m:m idind_m using educationmother
drop _merge

sort hhid idind wave
sum hhid idind  wave a11  fathera11 idind_f  mothera11  idind_m idind_s t1 a9 gender hhincpc_cpi

* Now, one has to check whether one should take the union of the information on parents education : i.e. either the father's 
* education or the mother's education, or whether one wants the intersection of the information, i.e. the case where one has both
* parents' education level.  I leave this for you to check

* For instance, one can look at:

sum a11 father mother

sum a11 father mother if father==.
sum a11 father mother if mother==.
sum a11 father mother if mother~=. & father~=.

* once you determine this, you will need to code properly the variable a11 into the proper categories.
save, replace

gen finexna= fine* nationality
label var finexna "fine* nationality"
save, replace

*create province dummy
gen byte beijing=1 if t1==11
replace beijing=0 if t1==.

gen byte liaoning=1 if t1==21
replace liaoning=0 if t1==.

gen byte heilongjiang=1 if t1==23
replace heilongjiang=0 if t1==.

gen byte shanghai=1 if t1==31
replace shanghai=0 if t1==.

gen byte jiangsu=1 if t1==32
replace jiangsu=0 if t1==.

gen byte shandong=1 if t1==37
replace shandong=0 if t1==.

gen byte henan=1 if t1==41
replace henan=0 if t1==.

gen byte hubei=1 if t1==42
replace hubei=0 if t1==.

gen byte hunan=1 if t1==43
replace hunan=0 if t1==.

gen byte guangxi=1 if t1==45
replace guangxi=0 if t1==.

gen byte guizhou=1 if t1==52
replace guizhou=0 if t1==.

gen byte chongqing=1 if t1==55
replace chongqing=0 if t1==.

keep if west_dob_y >=1976 & west_dob_y <=2000

*normalized years of schooling
mean a11, over ( west_dob_y)
gen edumean = .
replace edumean = 8.785902 if west_dob_y ==1976
replace edumean = 8.941511 if west_dob_y ==1977
replace edumean = 8.986345 if west_dob_y ==1978
replace edumean = 8.766871 if west_dob_y ==1979
replace edumean = 8.238923 if west_dob_y ==1980
replace edumean = 8.046891 if west_dob_y ==1981
replace edumean = 7.41334 if west_dob_y ==1982
replace edumean = 6.95528 if west_dob_y ==1983
replace edumean = 7.266622 if west_dob_y ==1984
replace edumean = 7.348125 if west_dob_y ==1985
replace edumean = 7.704792 if west_dob_y ==1986
replace edumean = 7.909613 if west_dob_y ==1987
replace edumean = 7.78593 if west_dob_y ==1988
replace edumean = 7.903657 if west_dob_y ==1989
replace edumean = 7.37698 if west_dob_y ==1990
replace edumean = 7.234293 if west_dob_y ==1991
replace edumean = 6.900277 if west_dob_y ==1992
replace edumean = 7.516315 if west_dob_y ==1993
replace edumean = 7.654189 if west_dob_y ==1994
replace edumean = 7.129983 if west_dob_y ==1995
replace edumean = 6.521151 if west_dob_y ==1996
replace edumean = 6.069767 if west_dob_y ==1997
replace edumean = 5.365234 if west_dob_y ==1998
replace edumean = 5.293478 if west_dob_y ==1999
replace edumean = 5.047945 if west_dob_y ==2000
gen edunorm=a11/edumean
 
gen hienroll=1 if a11>9
replace hienroll=0 if a11<=9

replace gender=0 if gender ==2
replace nationality=2 if nationality==0
replace nationality=3 if nationality==1
replace nationality=0 if nationality==3
replace nationality=1 if nationality==2
ren nationality minority
label var minor "1=minority 0=han"

gen lnhhinc_cpi=ln(hhinc_cpi)


save, replace























