set more off
capture log close
capture clear

log using anitareg, t replace

u anitav1

*t1=province
*t2==1 urban; t2==2 rural
*l100 TV
*t2 1=urban 2=rural
*t5 household number
bysort t2:sum nsib hienroll edunorm fathera11 mothera11 indinc_cpi hhinc_cpi gender minority l100

*fertility rate
*urban
*cluster for community 
reg nsib fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==1,cluster(commid)
*include birth year FE

gen byte samp1=1 if e(sample)
bysort t2: sum nsib hienroll edunorm fathera11 mothera11 indinc_cpi hhinc_cpi gender minority l100 if samp1==1

xtset west_dob_y
xtreg nsib fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==1,fe i( west_dob_y) 
*rural
*cluster for community 
reg nsib fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==2,cluster(commid)
*include birth year FE

gen byte samp2=1 if e(sample)
bysort t2: sum nsib hienroll edunorm fathera11 mothera11 indinc_cpi hhinc_cpi gender minority l100 if samp2==1

xtset west_dob_y
xtreg nsib fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==2,fe i( west_dob_y) 


*high school enrollment
*urban
*cluster for community 
reg hienroll fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==1,cluster(commid)
*include birth year FE
xtset west_dob_y
xtreg hienroll fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==1,fe i( west_dob_y) 
*rural
*cluster for community 
reg hienroll fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==2,cluster(commid)
*include birth year FE
xtset west_dob_y
xtreg hienroll fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==2,fe i( west_dob_y) 

*normalized educational level 
*urban
*cluster for community 
reg edunorm fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==1,cluster(commid)
*include birth year FE
xtset west_dob_y
xtreg edunorm fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==1,fe i( west_dob_y) 
*rural
*cluster for community 
reg edunorm fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==2,cluster(commid)
*include birth year FE
xtset west_dob_y
xtreg edunorm fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==2,fe i( west_dob_y) 


*try 2015 cross-section
reg nsib fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani soc mart trans health i.t1 if t2==1 &wave ==2015, cluster (commid)
reg nsib fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani soc mart trans health i.t1 if t2==2 &wave ==2015, cluster (commid)

reg edunorm fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani soc mart trans health i.t1 if t2==1 &wave ==2015, cluster (commid)
reg edunorm fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani soc mart trans health i.t1 if t2==2 &wave ==2015, cluster (commid)



xtreg nsib fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==1,fe i( west_dob_y)
estimates store fixed
quietly xtreg nsib fine minority finexna fathera11 mothera11 lnhhinc_cpi gender sani l100 soc mart trans health i.t1 if t2==1,re i( west_dob_y)
hausman fixed ., sigmamore

