/******************************************************************************************
***     Programmer: XXXX
***     Begin Date: 1/22/2022
***		Modified Data: 1/12/2022
***     Purpose:
***             This program conducts analysis for revisions of Polish Immigrants in Netherlands
***				paper submitted to European Societies
***
***		Status: Completed     
***
***     Input Data: GGS_Wave1_Poland_V.4.3.dta, FPN data_April 2016_1.dta, 
***		GGS_Wave1_Netherlands_V.4.3.dta
***
***     Output Data: 
***
***
***
***
*******************************************************************************************/

clear all

*************************
*** Install Ado Files ***
*************************

/*
findit brant
net from http://fmwww.bc.edu/RePEc/bocode/o
net install oparallel, replace
*/

/*
findit brant
net from https://jslsoc.sitehost.iu.edu/stata
net install spost13_ado, replace
*/

/*
findit gologit2 
net from http://fmwww.bc.edu/RePEc/bocode/g
net install gologit2, replace
*/

********************************
*** set preprocessor options ***
********************************

clear all
cd "[path]\Analysis\Revisions"

*********************
*** Bring in Data ***
*********************

//Wave 1 Data	
use arid ayear aweight ///
	a119 a122 adwell ///
	a105 a106a_1 a106b ///
	a1107_a a1107_b a1107_c a1107_d a1107_e a1107_f a1107_g a1107_h a1107_i a1107_j ///
	a1101 a1102 a1102mnth a1102u ///
	a550 a302a a106a_1 aage asex ahhtype ahhsize adwell aeduc aactstat ///
	amarstat ankids anpartner aparstat numpartnerships a870 a148 ///
	aplace aregion atype a209 a211a a314a a332 a333 ///
	numdissol numdivorce nummarriage numpartnerships livingwithpartner a372a ///
	coreschild numbiol numres numnonres ahg9_1 a106b a107AgeR a107y a111 ///
	a5108_1 a5108_2 ///
	using "../GGS_Wave1_Poland_V.4.3.dta", clear

desc

************************
*** Recode Variables ***
************************

clonevar id = arid
clonevar yearW1 = ayear

gen sample = 1 //PL

******************************************
*Dependent Variables (Marriage Attitudes)*
******************************************

*tab1 a1107_a a1107_b a1107_c a1107_d a1107_h if aage >= 21 & aage <= 58
tab1 a1107_b a1107_d a1107_h if aage >= 21 & aage <= 58

*** Reverse code so that non-traditional attitudes is high value ***

revrs a1107_a a1107_b a1107_d a1107_h

*tab1 reva1107_a reva1107_b a1107_c reva1107_d reva1107_h, miss

*** Rename and Label Variables ***

/*
//Create New Label
label define tradlbl ///
	1 "Most Trad" ///
	2 "Traditional" ///
	3 "Neutral" ///
	4 "Non-Trad" ///
	5 "Most Non-Trad"
*/
//Create New Label
label define accptlbl ///
	1 "Least Accepting" ///
	2 "Less Accepting" ///
	3 "Neutral" ///
	4 "More Accepting" ///
	5 "Most Accepting"

//Macros	
local oldnames "reva1107_a reva1107_b a1107_c reva1107_d reva1107_h"
local newnames "maroutdateW1 cohabW1 marlifeW1 divorceW1 singlemomW1" 

forvalues i = 1/5 {
	local var1 = word("`oldnames'", `i')
	local var2 = word("`newnames'", `i')

	gen `var2' = `var1'
		
	label var `var2' "Recode of `var1'"
	label values `var2' accptlbl
	
	}

*tab1 maroutdateW1 cohabW1 marlifeW1 divorceW1 singlemomW1
tab1 cohabW1 divorceW1 singlemomW1

***********************
*Independent Variables*
***********************

*tab1 aage ahhtype aeduc ahhsize adwell 

//Sex (Male)
recode asex (1 = 1 "Male") (2 = 0 "Female") , gen(maleW1)

tab2 asex maleW1

//Age
clonevar ageW1 = aage

su ageW1

//Education
recode aeduc (0 1 	= 1 "Primary or Below") ///
			 (2 3 4 = 2 "Secondary") ///
			 (5 6 	= 3 "Tertiary"), ///
			  gen(educcatW1)
			  
tab2 aeduc educcatW1 

//Activity Status
recode aactstat (1 = 1 "Employed") ///
				(3 = 2 "Unemployed") ///
				(4 = 3 "Student or Training") ///
				(5 = 4 "Other") ///
				(2 6 7 8 9 10 = 5 "Other"), ///
				 gen(empstatW1)

tab2 aactstat empstatW1
				
//Marital Status
clonevar maritalW1 = amarstat

tab2 maritalW1 amarstat

//Partnership Status
clonevar partnerW1 = aparstat

//Number of Marriages
clonevar nummarriageW1 = nummarriage

//Ever Divorced
recode numdivorce (0   = 0 "Never Divorced") ///
				  (1/3 = 1 "Ever Divorced"), ///
				   gen(everdivorcW1)

tab2 numdivorce everdivorcW1

//Ever Cohabited
gen diff_tmp = numpartnerships - nummarriage 

tab diff_tmp

recode diff_tmp (1/max = 1 "Ever Cohabited") ///
				(0 	   = 0 "Never Cohabited"), ///
				 gen(evercohabW1)

tab2 diff_tmp evercohabW1
tab evercohabW1

/*
//Religious Attendence
recode a1102 (0   	= 1 "Never") ///
			 (1   	= 2 "Once") ///
			 (2/4 	= 3 "2-4 Times") ///
			 (5/max = 4 "5+ Times"), ///
			  gen(religattW1)
*/

//Religious Denomination
recode a1101 (2 = 1 "Catholic") ///
			 (3 = 2 "Protestant") ///
			 (1 = 3 "Orthodox") ///
			 (8 = 4 "Other") ///
			 (9 = 5 "None"), ///
			  gen(religW1)

tab a1101 religW1
			  
//HH Size
clonevar hhsizeW1 = ahhsize

//HH Arrangement
*Living Alone
recode ahhtype (1 	= 1 "Living Alone") ///
			   (2/9 = 0 "Not Alone") ///
				, gen(livealoneW1)
				
tab2 ahhtype livealoneW1 

*Single Parent
recode ahhtype (2 4 	= 1 "Single Parent") ///
			   (1 3 5/9 = 0 "Not Single Parent") ///
				, gen(singleparW1)

tab2 ahhtype singleparW1 

/*
*With Parents
recode ahhtype (3 4 7 8   = 1 "Live with Parent") ///
			   (1 2 5 6 9 = 0 "Do not Live with Parent") ///
				, gen(livewparW1)

tab2 ahhtype livewparW1
*/

//Number of Children
clonevar nchildsW1 = ankids

recode nchildsW1 (0 	= 1 "No Children") ///
				 (1 	= 2 "1 Child") ///
				 (2    	= 3 "2 Children") ///
				 (3/max = 4 "3 or More Children") ///
				  , gen(nchildcatW1)			   

tab2 nchildsW1 nchildcatW1

/*				
//Settlement Type
recode atype (2601 = 1 "Rural") ///
			 (2602 = 2 "Urban") ///
			 (2603 = 3 "Capital"), ///
			  gen(plactypeW1)

tab2 atype plactypeW1
*/

//Home Ownership Status
recode a122 (1 2601 		 = 1 "Owner") ///
			(2 3 4 2602/2604 = 0 "Not Owner"), ///
			 gen(homeownW1)

tab2 a122 homeownW1
			 
//Nativity Status
recode a105 (1 = 1 "Native-Born") ///
			(2 = 0 "Non-Native"), ///
			 gen(nativeW1)

tab2 nativeW1 a105

**************************
*** Sample Limitations ***
***************************

//Keep only native-born age 21-58
keep if nativeW1 == 1
keep if ageW1 >= 21 & ageW1 <= 58

//Keep only analysis variables
keep id sample ///
	 cohabW1 divorceW1 singlemomW1 ///
	 maleW1 ageW1 educcatW1 empstatW1 ///
	 maritalW1 partnerW1 everdivorcW1 evercohabW1 singleparW1 ///
	 religW1 ///
	 hhsizeW1 nchildsW1 nchildcatW1 ///
	 homeownW1


********************
*** Missing Data ***
********************

//Make Indicator Variable for Missing Data Case
gen missW1 = 0
 replace missW1 = 1 if missing(cohabW1)   | missing(divorceW1)    | missing(singlemomW1) | ///
					   missing(maleW1)	  | missing(ageW1)        | missing(educcatW1)   | missing(empstatW1) | ///
					   missing(maritalW1) | missing(everdivorcW1) | missing(evercohabW1) | missing(singleparW1) | missing(partnerW1) | ///
					   missing(hhsizeW1)  | missing(nchildsW1) 	  | missing(homeownW1)   | missing(religW1 )

tab missW1

*****************
*** Save Data ***
*****************

save GGSPLW1sam, replace

**************************************
*** Bring in Data (Migrant Wave 1) ***
**************************************

//Wave 1 Data /* Note: 18-49 (actual 21-58) age range (differs from 18-79 age range of GGS */
use RESPNR ///
	ad408 ad409a ad409b ad409c ///
	al1206a al1206b al1206c al1206d al1206e al1206f al1206g al1206h al1206i ///
	aa002 aa003 aa004m aa004y aa101 ab201 ab208 ab209 ab211 ab212 ///
	aa105 aa106 aa102m aa102y aa103 ///
	ac301 ac302 ac303 ac304a ac304b ac304c ///
	ac307 ac310a ac323 ac324 ad401b ///
	ac326_01 ac327_01 ac328_01 ac329_01 ///
	ac326_02 ac327_02 ac328_02 ac329_02 ///
	ac326_03 ac327_03 ac328_03 ac329_03 ///
	ac301 ac304c ///
	ac319 ac320 ac322 ac332_01 ac333_01 ac332_02 ac333_02 ac332_03 ac333_03 ac335 ac336a ac337 ///
	ac340_101 ac340_102 ac340_103 ac340_104 ac340_105 ac340_2101 ac340_2102 ///
	ac340_2103 ac340_2104 ac340_2201 ac340_2202 ac340_2301 ac340_301 ac340_302 ///
	aj1001a aj1001b aj1001c aj1001d aj1002 ///
	aj1003a aj1003b ///
	aj1004a aj1004b aj1004c aj1004d aj1004e Language_questionnaire ///
	aj1005 aj1006 aj1007 ///
	al1201 al1201_open al1202 ///
	aj1008a aj1008b aj1008c aj1008d aj1008e aj1008f ///
	aj1005 aj1006 aj1007 ///
	ak1101 ak1102 ak1103 ///
	using "../FPN data_April 2016_1.dta", clear

desc

*tab1 aa004m aa004y
*tab1 aj1003a aj1003b aj1004a-aj1004e
*tab1 ab211 ab212 
tab1 ac301 ac302 ac303 ac304a ac304b

************************
*** Recode Variables ***
************************

clonevar id = RESPNR
gen sample = 2 //PFN

******************************************
*Dependent Variables (Marriage Attitudes)*
******************************************

*tab1 al1206a al1206b al1206c al1206d al1206h
*tab1 al1206b al1206d al1206h

*** Reverse code so that non-traditional attitudes is high value ***

revrs al1206b al1206d al1206h

*** Rename and Label Variables ***

/*
//Create New Label
label define tradlbl ///
	1 "Most Trad" ///
	2 "Traditional" ///
	3 "Neutral" ///
	4 "Non-Trad" ///
	5 "Most Non-Trad"
*/
//Create New Label
label define accptlbl ///
	1 "Least Accepting" ///
	2 "Less Accepting" ///
	3 "Neutral" ///
	4 "More Accepting" ///
	5 "Most Accepting"
	
//Macros	
local oldnames "reval1206b reval1206d reval1206h"
local newnames "cohabW1 divorceW1 singlemomW1" 

forvalues i = 1/3 {
	local var1 = word("`oldnames'", `i')
	local var2 = word("`newnames'", `i')

	gen `var2' = `var1'
		
	label var `var2' "Recode of `var1'"
	label values `var2' accptlbl
	
	}

tab1 cohabW1 divorceW1 singlemomW1

***********************
*Independent Variables*
***********************

*label list aa101

//Sex (Male)
recode aa101 (1 = 1 "Male") (2 = 0 "Female") , gen(maleW1)

tab2 aa101 maleW1

//Age
gen ageW1 = 2014 - aa102y

su ageW1

drop if age < 21 /*2 cases had very low age*/

//Education
recode aa106 (1 2  = 1 "Primary or Below") ///
			 (3/7  = 2 "Secondary") ///
			 (8/10 = 3 "Tertiary"), ///
			  gen(educcatW1)
			  
tab2 aa106 educcatW1 

//Activity Status
recode aa105 (2/4 = 1 "Employed") ///
			 (6 = 2 "Unemployed") ///
			 (1 = 3 "Student or Training") ///
			 (7 = 4 "Other") ///
			 (5 8 9 10 11 12 13 = 5 "Other"), ///
			  gen(empstatW1)
			  
tab2 aa105 empstatW1

//Marital Status (Constructed)
gen maritalW1 = .

replace maritalW1 = 1 if (ac307 != 1 & ac307 != 2) & ///
						 (ac327_01 != 1 & ac327_02 != 1 & ac327_03 != 1) // Never-Married 
replace maritalW1 = 2 if ac307 == 1 | ac307 == 2 // Married
replace maritalW1 = 4 if (maritalW1 != 1 & maritalW1 != 2) & ///
						 (ac329_01 == 2 | ac329_02 == 2 | ac329_03 == 2) //Widowed
replace maritalW1 = 3 if (maritalW1 != 1 & maritalW1 != 2 & maritalW1 != 4) & ///
						 (ac329_01 == 1 | ac329_02 == 1 | ac329_03 == 1) //Divorced

tab maritalW1, miss

//Marital Status and Partner Location
gen maritalPW1 = .

replace maritalPW1 = 1 if maritalW1 == 1 //Never-Married
replace maritalPW1 = 2 if (maritalW1 == 2 & ac304a == 1) //Married to PL Partner
replace maritalPW1 = 3 if (maritalW1 == 2 & ac304b == 1) //Married to NL Partner
replace maritalPW1 = 4 if (maritalW1 == 2 & ac304b != 1 & ac304b != .) //Married to Partner Other Country
replace maritalPW1 = 5 if maritalW1 == 3 | maritalW1 == 4 //Divorced or Widowed

//Label Values
label define maritalPlbl ///
	1 "Never Married" /// 
	2 "Married, Polish Partner" /// 
	3 "Married, Dutch Partner" /// 
	4 "Married, Other Ethnicity Partner" /// 
	5 "Divorced or Widowed"

label values maritalPW1 maritalPlbl

tab maritalPW1, miss
tab2 maritalPW1 maritalW1
	
/*
list maritalW1 ac301 ac307 ///
	 ac327_01 ac327_02 ac327_03 ///
	 ac329_01 ac329_02 ac329_03 ///
	 if maritalW1 == 3
*/

//partner status -- Still Working on this 
gen partnerW1 = .

replace partnerW1 = 3 if ac301 == 2 /* No Partner */
replace partnerW1 = 1 if ac301 == 1 & (ac307 == 1 | ac307 == 3 | ac307 == 5 | ac307 == 7) /* Co-Resident Partner */
replace partnerW1 = 2 if ac301 == 1 & (ac307 == 2 | ac307 == 4 | ac307 == 6 | ac307 == 8) /* Non-Resident Partner */ 

tab partnerW1 ac304a
tab partnerW1 ac304b

gen partnerPW1 = 4
 replace partnerPW1 = 1 if ac304a == 1 /* Yes, Polish Partner */
  replace partnerPW1 = 2 if ac304b == 1 /* Yes, Dutch Partner */
   replace partnerPW1 = 3 if (ac304b != 1) & (ac304b != .) /* Yes, Partner from Elsewhere */

label define partnerPlbl ///
	1 "Polish Partner" ///
	2 "Dutch Partner" ///
	3 "Partner Other Ethn." ///
	4 "No Partner"

label values partnerPW1 partnerPlbl
	
tab partnerPW1, miss
/*
tab2 partnerPW1 ac304a
tab2 partnerPW1 ac304b
tab2 partnerPW1 partnerW1
*/   
//Number of Marriages/Divorces/etc
gen married_tmp = .
replace married_tmp = 1 if maritalW1 == 2

forvalues i = 1/3 {
	
	gen married`i'_tmp = .
		replace married`i'_tmp = 1 if ac327_0`i' == 1

	gen divorced`i'_tmp = .	
		replace divorced`i'_tmp = 1 if ac329_0`i' == 1 & ac327_0`i' == 1
		
	gen cohabited`i'_tmp = .
		replace cohabited`i'_tmp = 1 if ac329_0`i' == 1 & ac327_0`i' == 2
	}

egen nummarriage = rownonmiss(married_tmp married1_tmp married2_tmp married3_tmp)

tab nummarriage

*list nummarriage married*

egen numdivorce = rownonmiss(divorced1_tmp divorced2_tmp divorced3_tmp)

recode numdivorce (0 = 0 "Never Divorced") ///
				  (1/max = 1 "Ever Divorced") ///
					, gen(everdivorcW1)

tab1 everdivorcW1 numdivorce

//Ever Cohabited
recode ac307 (5 6 = 1) ///
			 (1/4 7/8 = 0), ///
			  gen(cohabit_tmp)

tab2 ac307 cohabit_tmp

egen numcohab = rowtotal(cohabit_tmp cohabited1_tmp cohabited2_tmp cohabited3_tmp)

recode numcohab (1/max = 1 "Ever Cohabited") ///
				(0 	   = 0 "Never Cohabited"), ///
				 gen(evercohabW1)

tab evercohabW1, miss
*list evercohabW1 numcohab cohabit_tmp cohabited1_tmp cohabited2_tmp cohabited3_tmp in 1/50
	
*list everdivorcW1 ac327_01 ac329_01 ac327_02 ac329_02 ac327_03 ac329_03 in 1/50

/*
//Religious Attendence
tostring al1202, gen(relatts_tmp)
destring relatts_tmp, gen(relatt_tmp)

*tab relatt_tmp

recode relatt_tmp (0   	= 1 "Never") ///
				  (1   	= 2 "Once") ///
				  (2/4 	= 3 "2-4 Times") ///
				  (5/max = 4 "5+ Times"), ///
				   gen(religattW1)

tab2 relatt_tmp religattW1
*/

//Religious Denomination
recode al1201 (1 = 1 "Catholic") ///
			  (2 = 2 "Protestant") ///
			  (3 = 3 "Orthodox") ///
			  (4 = 4 "Other") ///
			  (5 = 5 "None"), ///
			  gen(religW1)

tab2 al1201 religW1 

//HH Size
gen count1_tmp = 0
replace count1_tmp = 1 if (ac307 == 1 | ac307 == 3 | ac307 == 5 | ac307 == 7)

*tab count1_tmp, miss

egen count_chd = anycount(ac340_101 ac340_102 ac340_103 ac340_104 ac340_105 ///
						  ac340_2101 ac340_2102 ac340_2103 ac340_2104 ac340_2201 ///
						  ac340_2202 ac340_2301 ac340_301 ac340_302), values(1 2)

/*						  
list count_chd ac340_101 ac340_102 ac340_103 ac340_104 ac340_105 ///
	 ac340_2101 ac340_2102 ac340_2103 ac340_2104 ac340_2201 ///
	 ac340_2202 ac340_2301 ac340_301 ac340_302 in 1/25
*/
*tab count_chd, miss

gen otherHH = ad401b
replace otherHH = 0 if ad401b == .

gen hhsizeW1 = (1 + count1_tmp + count_chd + otherHH)

tab hhsizeW1

//HH Arrangement
*Live Alone
recode hhsizeW1 (1 	= 1 "Living Alone") ///
				(2/max = 0 "Not Alone") ///
				 , gen(livealoneW1)

tab2 hhsizeW1 livealoneW1

/*
*With Parents
*/

//Number of Children
tab1 ac320 ac333_01 ac333_02 ac333_03 ac336a, miss

egen nchildsW1 = rowtotal(ac320 ac333_01 ac333_02 ac333_03 ac336a)

list nchildsW1 ac320 ac333_01 ac333_02 ac333_03 ac336a in 1/50

tab nchildsW1

recode nchildsW1 (0 	= 1 "No Children") ///
				 (1 	= 2 "1 Child") ///
				 (2    	= 3 "2 Children") ///
				 (3/max = 4 "3 or More Children") ///
				  , gen(nchildcatW1)			   

tab2 nchildsW1 nchildcatW1

*Single Parent

recode ac307 (1 3 5 7 = 0 "Living Together w/ Parter") ///
			 (2 4 6 8 = 1 "Living Apart from Partner"), ///
			  gen(notlivepar_tmp)
			  
tab2 ac307 notlivepar_tmp

gen singleparW1 = 0
replace singleparW1 = 1 if (count_chd >= 1 & (notlivepar_tmp == 1 | ac301 == 2)) /* Has at least one co-resident child, not living w/ partner or no partner */

tab singleparW1
list singleparW1 count_chd ac307 ac301 if singleparW1 == 1, nol 

//Home Ownership Status
recode ad409a (1= 1 "Owner") ///
			  (2 3 4 = 0 "Not Owner"), ///
			   gen(homeownW1)

tab2 ad409a homeownW1

/*
//Settlement Type
*/

*** Assimilation Strategy Variables ***

*tab1 aj1001a aj1001b aj1001c aj1001d aj1002 aj1003a aj1003b aj1005 aj1004a aj1004b aj1004c aj1004d aj1004e Language_questionnaire

//Macros	
local oldnames "aj1001a aj1001b aj1001c aj1001d"
local newnames "undstdutch spksdutch readdutch writdutch" 

forvalues i = 1/4 {
	local var1 = word("`oldnames'", `i')
	local var2 = word("`newnames'", `i')

	//Reverse Code Language Variables
	revrs `var1'
	
	clonevar `var2' = rev`var1'
	
	tab2 `var1' `var2' 
	
	label var `var2' "Recode of `var1'"
	
	}

//Took Dutch Course
clonevar dutchclass = aj1002

recode dutchclass (1 2 = 1) ///
				  (3   = 0), ///
				  gen(dutchclassd)

tab2 dutchclass dutchclassd
				  
//Dutch/Polish TV Watching
clonevar poltv = aj1003a

clonevar dutchtv = aj1003b

//Language Used with Boss/Manager, Friends, Neighbors, Partner
local oldnames "aj1004a aj1004b aj1004c aj1004d aj1004e"
local newnames "langboss langfrnds langneigh langpartnr landchd" 

forvalues i = 1/5 {
	local var1 = word("`oldnames'", `i')
	local var2 = word("`newnames'", `i')

	recode `var1' (1 = 1 "Polish")  ///
				  (2 = 2 "Dutch")   ///
				  (3 = 3 "English") ///
				  (4 = 4 "Other") ///
				  (5 = 5 "Missing") ///
				   , gen(`var2')
	
	tab2 `var1' `var2' 
	
	label var `var2' "Recode of `var1'"
	
	}

*Count Occurrence of Language Use across Relationship Domains (Boss, Friends, Neighbors) [2 NAs coded with whatever lang listed]
egen polishcnt = anycount(langboss langfrnds langneigh), values(1) //Polish
egen dutchcnt  = anycount(langboss langfrnds langneigh), values(2) //Dutch
egen englcnt   = anycount(langboss langfrnds langneigh), values(3) //English
egen othrcnt   = anycount(langboss langfrnds langneigh), values(4) //Other
egen misscnt   = anycount(langboss langfrnds langneigh), values(5) //Missing

tab1 polishcnt dutchcnt englcnt othrcnt misscnt if sample==2

egen langrmin = rowmin(langboss langfrnds langneigh) 

gen langpref = 4
 replace langpref = 1 if polishcnt == 3 | polishcnt == 2
  replace langpref = 2 if dutchcnt == 3 | dutchcnt == 2
   replace langpref = 3 if englcnt == 3 | englcnt == 2
    replace langpref = langrmin if misscnt == 2 
   
label define langlbl ///
	1 "Polish" ///
	2 "Dutch" ///
	3 "English" ///
	4 "None"

label values langpref langlbl

tab langpref if sample == 2, miss

*list langpref langboss langfrnds langneigh langrmin if sample == 2
	
//Living Situation NL Compared to PL
revrs aj1005	

recode revaj1005 (1 2 = 1 "Worse or Much Worse") ///
				 (3   = 2 "About the Same") ///
				 (4	  = 3 "Better") ///
				 (5	  = 4 "Much Better"), ///
				  gen(livesitcomp)

tab2 revaj1005 livesitcomp
				  
//Language Questionnaire
recode Language_questionnaire (1 = 1 "Polish") ///
							  (2 = 0 "Dutch"), ///
							   gen(langques)

tab2 Language_questionnaire langques
							   
//Descriptive Statistics
tab1 undstdutch spksdutch readdutch writdutch dutchclass dutchclassd ///
	 langboss langfrnds langneigh langpartnr landchd langques livesitcomp 
	 
//Duration of Stay
gen durmig = 2014 - aa004y

tab durmig, miss

//Times Visited PL, Last 12 Months
clonevar visitPL = ab211
	 
**************************
*** Sample Limitations ***
***************************

//Keep only analysis variables
keep id sample ///
	 cohabW1 divorceW1 singlemomW1 ///
	 maleW1 ageW1 educcatW1 empstatW1 ///
	 maritalW1 maritalPW1 partnerW1 partnerPW1 everdivorcW1 evercohabW1 singleparW1 ///
	 religW1 al1201 al1201_open ///
	 hhsizeW1 nchildsW1 nchildcatW1 ///
	 homeownW1 ///
	 spksdutch /*undstdutch readdutch writdutch dutchclass dutchclassd*/ ///
	 langpref /*langboss langfrnds langneigh langpartnr landchd langques poltv dutchtv livesitcomp*/ ///
	 durmig visitPL

********************
*** Missing Data ***
********************

//Make Indicator Variable for Missing Data Case
gen missW1 = 0
 replace missW1 = 1 if missing(cohabW1)   | missing(divorceW1)    | missing(singlemomW1) | ///
					   missing(maleW1)	  | missing(ageW1)        | missing(educcatW1)   | missing(empstatW1) | ///
					   missing(maritalW1) | missing(everdivorcW1) | missing(evercohabW1) | missing(singleparW1) | missing(partnerW1) | ///
					   missing(hhsizeW1)  | missing(nchildsW1) 	  | missing(homeownW1)   | missing(religW1)

tab missW1

tab1 al1201 al1201_open if religW1 == 3 | religW1 == 4

*****************
*** Save Data ***
*****************
 
save GGSPFNW1sam, replace
										  
*******************************************
*** Bring in Data (Netherlands, Wave 1) *** 
*******************************************

//Wave 1 Data
use arid ayear aweight ///
	a119 a122 adwell ///
	a1107_b a1107_d a1107_h ///
	a1101 ///
	a550 a302a aage asex ahhtype ahhsize adwell aeduc aactstat ///
	amarstat ankids anpartner aparstat a870 a148 ///
	aplace aregion atype a209 a211a a314a a332 a333 ///
	numdissol numdivorce nummarriage numpartnerships livingwithpartner a372a ///
	numbiol numres numnonres ahg9_1 a106b ///
	a105 a1101 ///
	using "../GGS_Wave1_Netherlands_V.4.3.dta", clear

desc

tab1 a1107_b a1107_d a1107_h if aage >= 21 & aage <= 58, miss

*tab1 numdivorce nummarriage numpartnerships if aage >= 21 & aage <= 58, miss

************************
*** Recode Variables ***
************************

clonevar id = arid
clonevar yearW1 = ayear
gen sample = 3 //NL

******************************************
*Dependent Variables (Marriage Attitudes)*
******************************************

tab1 a1107_b a1107_d a1107_h if aage >= 21 & aage <= 58

*** Reverse code so that non-traditional attitudes is high value ***

revrs a1107_b a1107_d a1107_h

*** Rename and Label Variables ***

/*
//Create New Label
label define tradlbl ///
	1 "Most Trad" ///
	2 "Traditional" ///
	3 "Neutral" ///
	4 "Non-Trad" ///
	5 "Most Non-Trad"
*/
//Create New Label
label define accptlbl ///
	1 "Least Accepting" ///
	2 "Less Accepting" ///
	3 "Neutral" ///
	4 "More Accepting" ///
	5 "Most Accepting"

//Macros	
local oldnames "reva1107_b reva1107_d reva1107_h"
local newnames "cohabW1 divorceW1 singlemomW1" 

forvalues i = 1/3 {
	local var1 = word("`oldnames'", `i')
	local var2 = word("`newnames'", `i')

	gen `var2' = `var1'
		
	label var `var2' "Recode of `var1'"
	label values `var2' accptlbl
	
	}

tab1 cohabW1 divorceW1 singlemomW1, miss

***********************
*Independent Variables*
***********************

*tab1 aage ahhtype aeduc ahhsize adwell 

//Sex (Male)
recode asex (1 = 1 "Male") (2 = 0 "Female") , gen(maleW1)

tab2 asex maleW1

//Age
clonevar ageW1 = aage

su age

//Education
recode aeduc (0 1 	= 1 "Primary or Below") ///
			 (2 3 4 = 2 "Secondary") ///
			 (5 6 	= 3 "Tertiary"), ///
			  gen(educcatW1)
			  
tab2 aeduc educcatW1 

//Activity Status
recode aactstat (1 = 1 "Employed") ///
				(3 = 2 "Unemployed") ///
				(4 = 3 "Student or Training") ///
				(5 = 4 "Other") ///
				(2 6 7 8 9 10 = 5 "Other"), ///
				 gen(empstatW1)

tab2 aactstat empstatW1

//Marital Status
clonevar maritalW1 = amarstat

tab2 maritalW1 amarstat

//Partnership Status
clonevar partnerW1 = aparstat

//Number of Marriages/Divorces/etc
clonevar nummarriageW1 = nummarriage

tab nummarriageW1

//Ever Divorced
recode numdivorce (0   = 0 "Never Divorced") ///
				  (1/4 = 1 "Ever Divorced"), ///
				   gen(everdivorcW1)

tab2 numdivorce everdivorcW1

//Ever Cohabited
gen diff_tmp = numpartnerships - nummarriage 

tab diff_tmp

recode diff_tmp (1/max = 1 "Ever Cohabited") ///
				(0 	   = 0 "Never Cohabited"), ///
				 gen(evercohabW1)

tab2 diff_tmp evercohabW1
tab evercohabW1

//Religious Denomination
recode a1101 (2 = 1 "Catholic") ///
			 (1802/1806  = 2 "Protestant") ///
			 (4 5 8 1809 = 4 "Other") ///
			 (9 .a = 5 "None"), /// Including non-response/NA
			  gen(religW1)

tab religW1, nol
tab2 a1101 religW1, miss

//HH Size
clonevar hhsizeW1 = ahhsize

su hhsizeW1

//HH Arrangement
*Living Alone
recode ahhtype (1 	= 1 "Living Alone") ///
			   (2/9 = 0 "Not Alone") ///
				, gen(livealoneW1)
				
tab2 ahhtype livealoneW1 

*Single Parent
recode ahhtype (2 4 	= 1 "Single Parent") ///
			   (1 3 5/9 = 0 "Not Single Parent") ///
				, gen(singleparW1)

tab2 ahhtype singleparW1 

/*
*With Parents
recode ahhtype (3 4 7 8   = 1 "Live with Parent") ///
			   (1 2 5 6 9 = 0 "Do not Live with Parent") ///
				, gen(livewparW1)

tab2 ahhtype livewparW1
*/

//Number of Children
clonevar nchildsW1 = ankids

recode nchildsW1 (0 	= 1 "No Children") ///
				 (1 	= 2 "1 Child") ///
				 (2    	= 3 "2 Children") ///
				 (3/max = 4 "3 or More Children") ///
				  , gen(nchildcatW1)			   

tab2 nchildsW1 nchildcatW1

/*
//Settlement Type
recode atype (2601 = 1 "Rural") ///
			 (2602 = 2 "Urban") ///
			 (2603 = 3 "Capital"), ///
			  gen(plactypeW1)

tab2 atype plactypeW1
*/

//Home Ownership Status
recode a122 (1 	  = 1 "Owner") ///
			(1801 = 0 "Not Owner"), ///
			 gen(homeownW1)

tab2 a122 homeownW1			 
			 
//Nativity Status
recode a105 (1 = 1 "Native-Born") ///
			(2 = 0 "Non-Native"), ///
			 gen(nativeW1)

tab2 nativeW1 a105

**************************
*** Sample Limitations ***
***************************

//Keep only native-born age 21-58
keep if nativeW1 == 1
keep if ageW1 >= 21 & ageW1 <= 58

//Keep only analysis variables
keep id sample ///
	 cohabW1 divorceW1 singlemomW1 ///
	 maleW1 ageW1 educcatW1 empstatW1 ///
	 maritalW1 partnerW1 everdivorcW1 evercohabW1 singleparW1 ///
	 religW1 ///
	 hhsizeW1 nchildsW1 nchildcatW1 ///
	 homeownW1
	 
********************
*** Missing Data ***
********************

//Make Indicator Variable for Missing Data Case
gen missW1 = 0
 replace missW1 = 1 if missing(cohabW1)   | missing(divorceW1)    | missing(singlemomW1) | ///
					   missing(maleW1)	  | missing(ageW1)        | missing(educcatW1)   | missing(empstatW1) | ///
					   missing(maritalW1) | missing(everdivorcW1) | missing(evercohabW1) | missing(singleparW1) | missing(partnerW1) | ///
					   missing(hhsizeW1)  | missing(nchildsW1) 	  | missing(homeownW1)   | missing(religW1)

tab missW1

*****************
*** Save Data ***
*****************
 
save GGSNLW1sam, replace

//Examine Attrition Rate for NE Sample	 
preserve
	
	use brid using "[path]\Netherlands_Wave2_V.1.3.dta"
	
	clonevar id = brid
	
	sort id
	
	save GGSNLW2, replace
	
	use GGSNLW1sam, clear

	sort id
	
	merge id using "GGSNLW2"

	tab _merge
	
restore	 


************************************				
*** Concatenate Sample Data Sets ***
************************************

use GGSPLW1sam, clear
append using GGSPFNW1sam 
append using GGSNLW1sam		

desc

*******************
*** Recode Vars ***
*******************

//Religion
recode religW1 (1 	= 1 "Catholic") ///
			   (2 	= 2 "Protestant") ///
			   (3 4 = 3 "Other") ///
			   (5 	= 4 "None/NA"), ///
				gen(religrcW1)

//Employment Status
recode empstatW1 (1 = 1 "Employed") ///
				 (2 = 2 "Unemployed") ///
				 (3 = 3 "Student or Training") ///
				 (5 = 4 "Other"), ///
				  gen(empstatRW1)	

//Marital Status				  
recode maritalW1 (1 = 1   "Never Married") ///
				  (2 = 2   "Married") ///
				  (3 4 = 3 "Divorced or Widowed"), ///
				  gen(maritalRW1)
				  
******************************
*** Descriptive Statistics ***
******************************

tab sample

//Examine Proportion Missing
tab missW1

mdesc

bysort sample: mdesc

*** Table Frequency Distributions Dependent Variables ***

*New Table Format (Transposed, includes Chi-Square)
frmttable, clear

//Make Starmaker Program
capture program drop starmaker
program define starmaker, rclass
	args chi2 df p
	*local chi2 = round(`chi2', .01)
	local chi2: display %5.2f `chi2'
	if `p' < .001 {
		local result = "`chi2'(`df')***"
	}
	else if `p' < .01 {
		local result = "`chi2'(`df')**"
	}
	else if `p' < .05 {
		local result = "`chi2'(`df')*"
	}
	else {
		local result = "`chi2'(`df')"
	}
	return local chidfp = "`result'"
end


//Relabel Attitude Categories
label define likert ///
	1 "\quad Least Accepting" ///
	2 "\quad Less Accepting" ///
	3 "\quad Neutral" ///
	4 "\quad More Accepting" ///
	5 "\quad Most Accepting"

label values cohabW1 divorceW1 singlemomW1 likert

//Loop Through Variables and Samples, Make Matrices for Each
foreach var in cohabW1 divorceW1 singlemomW1 {
	 
	 forvalues i = 1/3  {

		//Sample Size for Samples
		quietly tab cohabW1 if miss == 0  & sample == `i'
		local NS = round(r(N), 1)
	 
		di "`var'"

		//Sample Equation Headings
		if `i' == 1 {
			local samplename = "Polish (N = `NS')"
		}
		else if `i' == 2 {
			local samplename = "Polish Migrants (N = `NS')"
		}
		else if `i' == 3 {
			local samplename = "Dutch (N = `NS')"
		}
		
		//Sample Matrices
		estpost tab `var' if miss == 0 & sample == `i'
		
		mat define MCS`i'`var' = e(pct)'
		
		mat roweq MCS`i'`var' = "`samplename'" "`samplename'" "`samplename'" "`samplename'" "`samplename'" "`samplename'"
		
		mat list MCS`i'`var'
		
		}

		//Total Sample Size
		quietly tab cohabW1 if miss == 0
		local NTOT = round(r(N) ,1)
		
		estpost tab `var' if miss == 0 
		
		mat define MC`var' = e(pct)'

		//Total Equation Heading
		mat roweq MC`var' = "Total (N = `NTOT')" "Total (N = `NTOT')" "Total (N = `NTOT')" ///
							"Total (N = `NTOT')" "Total (N = `NTOT')" "Total (N = `NTOT')"
		
		mat list MC`var'
		
		//Chi-Square
		tab2 `var' sample, chi2
		
		*return list

		local nc = r(c)
		local nr = r(r)
		local chi2 = r(chi2)
		local p = r(p)

		local df = `=`nc'-1' * `=`nr'-1'

		di "`chi2', `df', `p', `nc', `nr'"

		starmaker `chi2' `df' `p'

		local chidfp`i' = r(chidfp)
		estadd local chidfp `chidfp`i''		
		
		//Stack Matrices into Tables per Variable
		frmttable, statmat(MCS1`var')
		frmttable, statmat(MCS2`var') append
		frmttable, statmat(MCS3`var') append
		frmttable, addrows("" "Chi Square" `chidfp`i'')
		frmttable, statmat(MC`var') append store(T`var')
}	

//Merge Tables Across Variables
frmttable, replay(TsinglemomW1)
frmttable, replay(TdivorceW1) merge
frmttable, replay(TcohabW1) merge ctitles("Sample" "Category" "Cohabitation" "Divorce" "Single Motherhood") store(Tfinal)
frmttable using table1b, replay(Tfinal) tex frag replace coljust(llrrr) note("Note: \sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

*** Means and SDs for Independent Variables ***

xi, noomit: estpost tabstat ///
	 maleW1 ageW1 i.educcatW1 i.empstatRW1 ///
	 i.maritalRW1 i.partnerW1 everdivorcW1 evercohabW1 singleparW1 ///
	 i.religrcW1 ///
	 hhsizeW1 i.nchildcatW1 ///
	 homeownW1 if missW1 == 0 ///
	 , s(mean sd) c(s)	 
	 
eststo descstatsTot	 

forvalues i = 1(2)3 {

//Distribution of Independent Variables, Across Samples
	xi, noomit: estpost tabstat ///
		 maleW1 ageW1 i.educcatW1 i.empstatRW1 /*durmig*/ ///
		 i.maritalRW1 i.partnerW1 /*i.partnerPW1*/ everdivorcW1 evercohabW1 singleparW1 ///
		 i.religrcW1 ///
		 hhsizeW1 i.nchildcatW1 ///
		 homeownW1 if missW1 == 0 & sample == `i' ///
		 , s(mean sd) c(s)

	eststo descstats`i'
}

xi, noomit: estpost tabstat ///
	 maleW1 ageW1 durmig i.educcatW1 i.empstatRW1 i.spksdutch i.langpref ///
	 i.maritalRW1 i.partnerW1 i.partnerPW1 everdivorcW1 evercohabW1 singleparW1 ///
	 i.religrcW1 ///
	 hhsizeW1 i.nchildcatW1 ///
	 homeownW1 if missW1 == 0 & sample == 2 ///
	 , s(mean sd) c(s)

eststo descstats2

//Table
esttab descstats1 descstats2 descstats3 descstatsTot using table2.tex, replace booktabs align(rrrrrrrr) ///
	   cells("mean(fmt(2) label(Mean)) sd(fmt(2) label(SD))") ///
	   title("Descriptive Statistics for Independent Variables: Polish, Polish Families in \\ the Netherlands, and Dutch Subsamples") ///
	   mtitle("Polish" "\shortstack{Polish \\ Migrants}" "Dutch" "Total") nonum ///
	   coefl(maleW1 "Male" ageW1 "Age (in Years)" ///
			 _IeduccatW1_1 "\quad Primary or Below" _IeduccatW1_2 "\quad Secondary" _IeduccatW1_3 "\quad Tertiary" ///
			 _IempstatRW_1 "\quad Employed" _IempstatRW_2 "\quad Unemployed" _IempstatRW_3 "\quad Student" _IempstatRW_4 "\quad Other" ///
			 durmig "Migration Duration" ///
			 _Ispksdutch_1 "\quad Not at all" _Ispksdutch_2 "\quad Not well"_Ispksdutch_3 "\quad Neither good nor bad"_Ispksdutch_4 "\quad Well"_Ispksdutch_5 "\quad Very Well" ///
			 _Ilangpref_1 "\quad Polish" _Ilangpref_2 "\quad Dutch" _Ilangpref_3 "\quad English" _Ilangpref_4 "\quad None" ///
			 _ImaritalRW_1 "\quad Never Married" _ImaritalRW_2 "\quad Married" _ImaritalRW_3 "\quad Divorced or Widowed" ///
			 _IpartnerW1_1 "\quad Co-Resident Partner" _IpartnerW1_2 "\quad Non-Resident Partner" _IpartnerW1_3 "\quad No Partner" ///
			 _IpartnerPW_1 "\quad Polish Partner" _IpartnerPW_2 "\quad Dutch Partner" _IpartnerPW_3 "\quad Partner Other Ethn." _IpartnerPW_4 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 _IreligrcW1_1 "\quad Catholic" _IreligrcW1_2 "\quad Protestant" _IreligrcW1_3 "\quad Other" _IreligrcW1_4 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 _Inchildcat_1 "\quad No Children" _Inchildcat_2 "\quad 1 Child" _Inchildcat_3 "\quad 2 Children" _Inchildcat_4 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner") ///
	   refcat(_IeduccatW1_1 "Highest Level of Education" ///
			  _IempstatRW_1 "Employment Status" ///
			  _Ispksdutch_1 "How Well Speaks Dutch" ///
			  _Ilangpref_1  "Language Used With \\ Boss, Friends, Neighbors" ///
			  _ImaritalRW_1 "Marital Status" ///
			  _IpartnerW1_1 "Partner Status" ///
			  _IpartnerPW_1 "Partner Status (Migrants)" ///
			  _IreligrcW1_1 "Religious Denomination" ///
			  _Inchildcat_1 "Number of Children", nolabel) ///
		order(maleW1 ageW1 durmig ///
			  _Ispksdutch_1 _Ispksdutch_2 _Ispksdutch_3 _Ispksdutch_4 _Ispksdutch_5 ///
			  _Ilangpref_1 _Ilangpref_2 _Ilangpref_3 _Ilangpref_4 ///
			  _IeduccatW1_1 _IeduccatW1_2 _IeduccatW1_3 ///
		      _IempstatRW_1 _IempstatRW_2 _IempstatRW_3 _IempstatRW_4 ///
			  _ImaritalRW_1 _ImaritalRW_2 _ImaritalRW_3 ///
			  _IpartnerW1_1 _IpartnerW1_2 _IpartnerW1_3 ///
			  _IpartnerPW_1 _IpartnerPW_2 _IpartnerPW_3 _IpartnerPW_4 ///
			  everdivorcW1 evercohabW1 singleparW1 ///
			  _IreligrcW1_1 _IreligrcW1_2 _IreligrcW1_3 _IreligrcW1_4 ///
			  _Inchildcat_1 _Inchildcat_2 _Inchildcat_3 _Inchildcat_4 ///
			  homeownW1)

***************************	   
*** Regression Analysis ***
***************************

*** Analysis Across Samples (Polish/Dutch Natives and Polish Migrants in NL) ***

clear matrix

//Define Macros
global depvars "cohabW1 divorceW1 singlemomW1" 

global indvars ib2.sample maleW1 c.ageW1##c.ageW1 i.educcatW1 i.empstatRW1 ///
			   ib2.maritalRW1 i.partnerW1 everdivorcW1 evercohabW1 singleparW1 ///
			   i.religrcW1 ///
			   hhsizeW1 i.nchildcatW1 ///
			   homeownW1 

global indvsens1 ib2.sample maleW1 c.ageW1##c.ageW1 i.educcatW1 i.empstatRW1 ///
			     ib2.maritalRW1 /*i.partnerW1*/ everdivorcW1 evercohabW1 singleparW1 ///
			     i.religrcW1 ///
			     hhsizeW1 i.nchildcatW1 ///
			     homeownW1 

global indvsens2 ib2.sample maleW1 c.ageW1##c.ageW1 i.educcatW1 i.empstatRW1 ///
			     ib2.maritalRW1 i.partnerW1 /*everdivorcW1 evercohabW1 singleparW1*/ ///
			     i.religrcW1 ///
			     hhsizeW1 i.nchildcatW1 ///
			     homeownW1 
				 
			   
capture gen age_sqrW1 = ageW1^2			   

//Check for Collinearity			   
global indvars2 i.sample maleW1 ageW1 age_sqrW1 i.educcatW1 i.empstatRW1 ///
			    i.maritalRW1 i.partnerW1 everdivorcW1 evercohabW1 singleparW1 ///
			    i.religrcW1 ///
			    hhsizeW1 i.nchildcatW1 ///
			    homeownW1 
			   		   
xi: collin $indvars2 if missW1 == 0	   

//Loop to Estimate Models
forvalues i = 1/3 {
	local depvar = word("$depvars", `i')
	
	*Ordered Logit Models
	
	//Estimate Ordered Logit Models
	ologit `depvar' $indvars if missW1 == 0 
	
	eststo olg_`depvar'

	//Brant Test
	oparallel, ic
	brant

	*Multinomial Logit
	
	//Recode Dep Variable [Collapse Traditional Categories]
	capture recode `depvar' (1 2 = 1 "Least/Less Accepting") ///
							(3 = 2 "Neutral") ///
							(4 = 3 "More \\ Accepting") ///
							(5 = 4 "Most \\ Accepting") ///
							, gen(`depvar'R) /* Collapse Traditional Cateogories */
	
	tab2 `depvar' `depvar'R
	
	//Estimate Multinomial Logit
	mlogit  `depvar'R $indvars if missW1 == 0, base(2) 
	
	mlogit, coefl
	
	eststo mlg_`depvar'
	
	*Binary Logit
	
	//Recode Dependent Variable to Binary
	capture recode `depvar' (5 4 = 1 "Non-Trad") (1 2 3 = 0 "Else"), gen(`depvar'B)
	
	//Estimate Binary Logit
	logit `depvar'B $indvars if missW1 == 0 
	
	eststo blg_`depvar'

	*Sensitivty Analysis
	
	//Estimate Binary Logit [No Partnership]
	logit `depvar'B $indvsens1 if missW1 == 0 
	
	eststo blgs1_`depvar'

	//Estimate Binary Logit [No Marriage/Partner History]
	logit `depvar'B $indvsens2 if missW1 == 0 
	
	eststo blgs2_`depvar'

	}

*** Tables ***

//Order Logit Table	(Supplemental Analysis)
esttab olg_cohabW1 olg_divorceW1 olg_singlemomW1 using Stable1.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Ordered Logit Regressions of Attitudes toward Alternatives to Marriage") ///
	   eqlabel("\textit{Variables}" "\textit{Cut Points}") ///
	   mtitle("Cohabitation" "Divorce" "\shortstack{Single \\ Motherhood}") nonum ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(1.sample "Sample \\ \quad Polish" 3.sample "\quad Dutch" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerW1 "\quad Non-Resident Partner" 3.partnerW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 /:cut1 "\quad cut1" /:cut2 "\quad cut2" /:cut3 "\quad cut3" /:cut4 "\quad cut4") ///
	   refcat(3.sample "\quad Polish Migrants" ///
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerW1 "Partner Status \\ \quad Co-Resident Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerW1 2.sample 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

*Multinomial Logit Model Tables -- Supplemental Analysis -- (Seperate for Each Dependent Variable)

//Cohabitation
esttab mlg_cohabW1 /*olg_divorceW1 olg_singlemomW1*/ using Stable2.tex, replace ///
	   unstack wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Multinomial Logit Regression of Attitudes toward Cohabitation") ///
	   eqlabel("\shortstack{Least/Less \\ Accepting}" "\shortstack{More \\ Accepting}" "\shortstack{Most \\ Accepting}") ///
	   mtitle("") nonum nodep ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(1.sample "Sample \\ \quad Polish" 3.sample "\quad Dutch" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerW1 "\quad Non-Resident Partner" 3.partnerW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(3.sample "\quad Polish Migrants" ///
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerW1 "Partner Status \\ \quad Co-Resident Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerW1 2.sample 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1 Neutral:*) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("Note: Base Catgery is 'Neutral'" ///
				"\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

//Divorce
esttab /*mlg_cohabW1*/ mlg_divorceW1 /*mlg_singlemomW1*/ using Stable3.tex, replace ///
	   unstack wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Multinomial Logit Regression of Attitudes toward Divorce") ///
	   eqlabel("\shortstack{Least/Less \\ Accepting}" "\shortstack{More \\ Accepting}" "\shortstack{Most \\ Accepting}") ///
	   mtitle("") nonum nodep ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(1.sample "Sample \\ \quad Polish" 3.sample "\quad Dutch" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerW1 "\quad Non-Resident Partner" 3.partnerW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(3.sample "\quad Polish Migrants" ///
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerW1 "Partner Status \\ \quad Co-Resident Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerW1 2.sample 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1 Neutral:*) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("Note: Base Catgery is 'Neutral'" ///
				"\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

//Single Motherhood
esttab /*mlg_cohabW1 mlg_divorceW1*/ mlg_singlemomW1 using Stable4.tex, replace ///
	   unstack wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Multinomial Logit Regression of Attitudes toward Single Motherhood") ///
	   eqlabel("\shortstack{Least/Less \\ Accepting}" "\shortstack{More \\ Accepting}" "\shortstack{Most \\ Accepting}") ///
	   mtitle("") nonum nodep ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(1.sample "Sample \\ \quad Polish" 3.sample "\quad Dutch" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerW1 "\quad Non-Resident Partner" 3.partnerW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(3.sample "\quad Polish Migrants" ///
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerW1 "Partner Status \\ \quad Co-Resident Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerW1 2.sample 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1 Neutral:*) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("Note: Base Catgery is 'Neutral'" ///
				"\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

*Binary Logit Tables

esttab blg_cohabW1 blg_divorceW1 blg_singlemomW1 using table3.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Logit Regressions of Attitudes toward Alternatives to Marriage") ///
	   eqlabel("\textit{Variables}") ///
	   mtitle("Cohabitation" "Divorce" "\shortstack{Single \\ Motherhood}") nonum ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(1.sample "Sample \\ \quad Polish" 3.sample "\quad Dutch" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerW1 "\quad Non-Resident Partner" 3.partnerW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(3.sample "\quad Polish Migrants" ///
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerW1 "Partner Status \\ \quad Co-Resident Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerW1 2.sample 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

*Binary Logit Tables -- Sensitivity Analysis, Model Specification 

//Cohabitation
esttab blg_cohabW1 blgs1_cohabW1 blgs2_cohabW1 using Stable5.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Logit Regressions of Attitudes toward Cohabitation (Sensitivity Analysis)") ///
	   eqlabel("\textit{Variables}") ///
	   mtitle("\shortstack{Main \\ Analysis}" "\shortstack{Excludes \\ Partner}" "\shortstack{Excludes \\ Marriage History}") nonum ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(1.sample "Sample \\ \quad Polish" 3.sample "\quad Dutch" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerW1 "\quad Non-Resident Partner" 3.partnerW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(3.sample "\quad Polish Migrants" ///
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerW1 "Partner Status \\ \quad Co-Resident Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerW1 2.sample 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

//Divorce
esttab blg_divorceW1 blgs1_divorceW1 blgs2_divorceW1 using Stable6.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Logit Regressions of Attitudes toward Divorce (Sensitivity Analysis)") ///
	   eqlabel("\textit{Variables}") ///
	   mtitle("\shortstack{Main \\ Analysis}" "\shortstack{Excludes \\ Partner}" "\shortstack{Excludes \\ Marriage History}") nonum ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(1.sample "Sample \\ \quad Polish" 3.sample "\quad Dutch" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerW1 "\quad Non-Resident Partner" 3.partnerW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(3.sample "\quad Polish Migrants" ///
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerW1 "Partner Status \\ \quad Co-Resident Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerW1 2.sample 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

//Single Motherhood
esttab blg_singlemomW1 blgs1_singlemomW1 blgs2_singlemomW1 using Stable7.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Logit Regressions of Attitudes toward Single Motherhood (Sensitivity Analysis)") ///
	   eqlabel("\textit{Variables}") ///
	   mtitle("\shortstack{Main \\ Analysis}" "\shortstack{Excludes \\ Partner}" "\shortstack{Excludes \\ Marriage History}") nonum ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(1.sample "Sample \\ \quad Polish" 3.sample "\quad Dutch" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerW1 "\quad Non-Resident Partner" 3.partnerW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(3.sample "\quad Polish Migrants" ///
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerW1 "Partner Status \\ \quad Co-Resident Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerW1 2.sample 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

*** Polish Migrants Only ***

global indmvars i.spksdutch i.langpref durmig maleW1 ageW1 /*c.ageW1##c.ageW1*/ i.educcatW1 i.empstatRW1 ///
			    ib2.maritalRW1 i.partnerPW1 everdivorcW1 evercohabW1 singleparW1 ///
			    i.religrcW1 ///
			    hhsizeW1 i.nchildcatW1 ///
			    homeownW1 

global indmvsens1 i.spksdutch i.langpref durmig maleW1 ageW1 /*c.ageW1##c.ageW1*/ i.educcatW1 i.empstatRW1 ///
			      ib2.maritalRW1 i.partnerPW1 /*everdivorcW1 evercohabW1 singleparW1*/ ///
			      i.religrcW1 ///
			      hhsizeW1 i.nchildcatW1 ///
			      homeownW1 
			   
//Check for Collinearity -- Note: Partner Variable No Collinearity Issues			   
global indmvars2 i.spksdutch i.langpref durmig maleW1 ageW1 /*c.ageW1##c.ageW1*/ i.educcatW1 i.empstatRW1 ///
			     i.maritalRW1 i.partnerPW1 everdivorcW1 evercohabW1 singleparW1 ///
			     i.religrcW1 ///
			     hhsizeW1 i.nchildcatW1 ///
			     homeownW1 
				 
xi: collin $indmvars2 if missW1 == 0 & sample == 2

//Loop to Estimate Models
forvalues i = 1/3 {
	local depvar = word("$depvars", `i')
	
	*Ordered Logit Models
	
	//Estimate Ordered Logit Models
	ologit `depvar' $indmvars if missW1 == 0 & sample == 2
	
	eststo olgm_`depvar'

	//Hypothesis Test for Language Variables
	testparm i.spksdutch 
	testparm i.langpref
	
	//Brant Test
	capture oparallel, ic
	capture brant

	*Multinomial Logit
	
	//Recode Dep Variable [Collapse Traditional Categories]
	capture recode `depvar' (1 2 = 1 "Least/Less Accepting") ///
							(3 = 2 "Neutral") ///
							(4 = 3 "More \\ Accepting") ///
							(5 = 4 "Most \\ Accepting") ///
							, gen(`depvar'R) /* Collapse Traditional Cateogories */
	
	tab2 `depvar' `depvar'R
	
	//Estimate Multinomial Logit
	mlogit  `depvar'R $indmvars if missW1 == 0 & sample == 2, base(2) 
	
	mlogit, coefl
	
	eststo mlgm_`depvar'
	
	*Binary Logit
	
	//Recode Dependent Variable to Binary
	capture recode `depvar' (5 4 = 1 "Non-Trad") (1 2 3 = 0 "Else"), gen(`depvar'B)
	
	//Estimate Binary Logit
	logit `depvar'B $indmvars if missW1 == 0 & sample == 2
	
	eststo blgm_`depvar'

	*Sensitivty Analysis
	
	//Estimate Binary Logit [No Marriage/Partner History]
	logit `depvar'B $indmvsens1 if missW1 == 0 & sample == 2
	
	eststo blgms1_`depvar'
	
}

//Order Logit Table	(Supplemental Analysis)
esttab olgm_cohabW1 olgm_divorceW1 olgm_singlemomW1 using Stable8.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Ordered Logit Regressions of Attitudes toward Alternatives to Marriage (Migrants Only)") ///
	   eqlabel("\textit{Variables}" "\textit{Cut Points}") ///
	   mtitle("Cohabitation" "Divorce" "\shortstack{Single \\ Motherhood}") nonum ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(2.spksdutch "\quad Not well" 3.spksdutch "\quad Neither good nor bad" 4.spksdutch "\quad Well" 5.spksdutch "\quad Very Well" ///
			 2.langpref "\quad Dutch" 3.langpref "\quad English" 4.langpref "\quad None" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" durmig "Migration Duration" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerPW1 "\quad Dutch Partner" 3.partnerPW1 "\quad Partner Other Ethn." 4.partnerPW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 /:cut1 "\quad cut1" /:cut2 "\quad cut2" /:cut3 "\quad cut3" /:cut4 "\quad cut4") ///
	   refcat(2.spksdutch "How Well Speaks Dutch \\ \quad Not at all"  ///
			  2.langpref "Language Used With \\ Boss, Friends, Neighbors \\ \quad Polish" /// 
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerPW1 "Partner Status \\ \quad Polish Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerPW1 1.spksdutch 1.langpref 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

*Multinomial Logit Model Tables -- Supplemental Analysis -- (Seperate for Each Dependent Variable)
//Cohabitation
esttab mlgm_cohabW1 /*mlgm_divorceW1 mlgm_singlemomW1*/ using Stable9.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) unstack ///
	   title("Multinomial Logit Regressions of Attitudes toward Cohabitation (Migrants Only)") ///
	   eqlabel("\shortstack{Least/Less \\ Accepting}" "\shortstack{More \\ Accepting}" "\shortstack{Most \\ Accepting}") ///
	   mtitle("") nonum nodep ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(2.spksdutch "\quad Not well" 3.spksdutch "\quad Neither good nor bad" 4.spksdutch "\quad Well" 5.spksdutch "\quad Very Well" ///
			 2.langpref "\quad Dutch" 3.langpref "\quad English" 4.langpref "\quad None" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" durmig "Migration Duration" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerPW1 "\quad Dutch Partner" 3.partnerPW1 "\quad Partner Other Ethn." 4.partnerPW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(2.spksdutch "How Well Speaks Dutch \\ \quad Not at all"  ///
			  2.langpref "Language Used With \\ Boss, Friends, Neighbors \\ \quad Polish" /// 
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerPW1 "Partner Status \\ \quad Polish Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerPW1 1.spksdutch 1.langpref 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1 Neutral:*) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("Note: Base Catgery is 'Neutral'" ///
			    "\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

//Divorce
esttab /*mlgm_cohabW1*/ mlgm_divorceW1 /*mlgm_singlemomW1*/ using Stable10.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) unstack ///
	   title("Multinomial Logit Regressions of Attitudes toward Divorce (Migrants Only)") ///
	   eqlabel("\shortstack{Least/Less \\ Accepting}" "\shortstack{More \\ Accepting}" "\shortstack{Most \\ Accepting}") ///
	   mtitle("") nonum nodep ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(2.spksdutch "\quad Not well" 3.spksdutch "\quad Neither good nor bad" 4.spksdutch "\quad Well" 5.spksdutch "\quad Very Well" ///
			 2.langpref "\quad Dutch" 3.langpref "\quad English" 4.langpref "\quad None" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" durmig "Migration Duration" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerPW1 "\quad Dutch Partner" 3.partnerPW1 "\quad Partner Other Ethn." 4.partnerPW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(2.spksdutch "How Well Speaks Dutch \\ \quad Not at all"  ///
			  2.langpref "Language Used With \\ Boss, Friends, Neighbors \\ \quad Polish" /// 
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerPW1 "Partner Status \\ \quad Polish Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerPW1 1.spksdutch 1.langpref 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1 Neutral:*) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("Note: Base Catgery is 'Neutral'" ///
			    "\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

//Single Motherhood
esttab /*mlgm_cohabW1 mlgm_divorceW1*/ mlgm_singlemomW1 using Stable11.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) unstack ///
	   title("Multinomial Logit Regressions of Attitudes toward Single Motherhood (Migrants Only)") ///
	   eqlabel("\shortstack{Least/Less \\ Accepting}" "\shortstack{More \\ Accepting}" "\shortstack{Most \\ Accepting}") ///
	   mtitle("") nonum nodep ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(2.spksdutch "\quad Not well" 3.spksdutch "\quad Neither good nor bad" 4.spksdutch "\quad Well" 5.spksdutch "\quad Very Well" ///
			 2.langpref "\quad Dutch" 3.langpref "\quad English" 4.langpref "\quad None" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" durmig "Migration Duration" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerPW1 "\quad Dutch Partner" 3.partnerPW1 "\quad Partner Other Ethn." 4.partnerPW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(2.spksdutch "How Well Speaks Dutch \\ \quad Not at all"  ///
			  2.langpref "Language Used With \\ Boss, Friends, Neighbors \\ \quad Polish" /// 
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerPW1 "Partner Status \\ \quad Polish Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerPW1 1.spksdutch 1.langpref 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1 Neutral:*) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("Note: Base Catgery is 'Neutral'" ///
			    "\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

*Binary Logit 

//Binary Table
esttab blgm_cohabW1 blgm_divorceW1 blgm_singlemomW1 using table4.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Logit Regressions of Attitudes toward Alternatives to Marriage (Migrants Only)") ///
	   eqlabel("\textit{Variables}") ///
	   mtitle("Cohabitation" "Divorce" "\shortstack{Single \\ Motherhood}") nonum ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(2.spksdutch "\quad Not well" 3.spksdutch "\quad Neither good nor bad" 4.spksdutch "\quad Well" 5.spksdutch "\quad Very Well" ///
			 2.langpref "\quad Dutch" 3.langpref "\quad English" 4.langpref "\quad None" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" durmig "Migration Duration" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerPW1 "\quad Dutch Partner" 3.partnerPW1 "\quad Partner Other Ethn." 4.partnerPW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(2.spksdutch "How Well Speaks Dutch \\ \quad Not at all"  ///
			  2.langpref "Language Used With \\ Boss, Friends, Neighbors \\ \quad Polish" /// 
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerPW1 "Partner Status \\ \quad Polish Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerPW1 1.spksdutch 1.langpref 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

*Binary Logit Tables -- Sensitivity Analysis, Model Specification 

//Cohabitation		
esttab blgm_cohabW1 blgms1_cohabW1 using Stable12.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Logit Regressions of Attitudes toward Cohabitation (Migrants Only) (Sensitivity Analysis)") ///
	   eqlabel("\textit{Variables}") ///
	   mtitle("\shortstack{Main \\ Analysis}" "\shortstack{Excludes \\ Marriage History}") nonum ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(2.spksdutch "\quad Not well" 3.spksdutch "\quad Neither good nor bad" 4.spksdutch "\quad Well" 5.spksdutch "\quad Very Well" ///
			 2.langpref "\quad Dutch" 3.langpref "\quad English" 4.langpref "\quad None" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" durmig "Migration Duration" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerPW1 "\quad Dutch Partner" 3.partnerPW1 "\quad Partner Other Ethn." 4.partnerPW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(2.spksdutch "How Well Speaks Dutch \\ \quad Not at all"  ///
			  2.langpref "Language Used With \\ Boss, Friends, Neighbors \\ \quad Polish" /// 
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerPW1 "Partner Status \\ \quad Polish Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerPW1 1.spksdutch 1.langpref 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

//Divorce
esttab blgm_divorceW1 blgms1_divorceW1 using Stable13.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Logit Regressions of Attitudes toward Divorce (Migrants Only) (Sensitivity Analysis)") ///
	   eqlabel("\textit{Variables}") ///
	   mtitle("\shortstack{Main \\ Analysis}" "\shortstack{Excludes \\ Marriage History}") nonum ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(2.spksdutch "\quad Not well" 3.spksdutch "\quad Neither good nor bad" 4.spksdutch "\quad Well" 5.spksdutch "\quad Very Well" ///
			 2.langpref "\quad Dutch" 3.langpref "\quad English" 4.langpref "\quad None" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" durmig "Migration Duration" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerPW1 "\quad Dutch Partner" 3.partnerPW1 "\quad Partner Other Ethn." 4.partnerPW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(2.spksdutch "How Well Speaks Dutch \\ \quad Not at all"  ///
			  2.langpref "Language Used With \\ Boss, Friends, Neighbors \\ \quad Polish" /// 
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerPW1 "Partner Status \\ \quad Polish Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerPW1 1.spksdutch 1.langpref 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")

//Single Motherhood
esttab blgm_singlemomW1 blgms1_singlemomW1 using Stable14.tex, replace ///
	   wide booktabs alignment(D{.}{.}{-1} D{.}{.}{-1}) ///
	   title("Logit Regressions of Attitudes toward Single Motherhood (Migrants Only) (Sensitivity Analysis)") ///
	   eqlabel("\textit{Variables}") ///
	   mtitle("\shortstack{Main \\ Analysis}" "\shortstack{Excludes \\ Marriage History}") nonum ///
	   cells("b(star label(\beta) fmt(3)) se(label(SE) fmt(2))") ///
	   coefl(2.spksdutch "\quad Not well" 3.spksdutch "\quad Neither good nor bad" 4.spksdutch "\quad Well" 5.spksdutch "\quad Very Well" ///
			 2.langpref "\quad Dutch" 3.langpref "\quad English" 4.langpref "\quad None" ///
			 maleW1 "Male" ageW1 "Age (in Years)" c.ageW1#c.ageW1 "Age Squared" durmig "Migration Duration" ///
			 2.educcatW1 "\quad Secondary" 3.educcatW1 "\quad Tertiary" ///
			 2.empstatRW1 "\quad Unemployed" 3.empstatRW1 "\quad Student" 4.empstatRW1 "\quad Other" 5.empstatRW1 "\quad Other" ///
			 1.maritalRW1 "Marital Status \\ \quad Never Married" 3.maritalRW1 "\quad Divorced or Widowed" ///
			 2.partnerPW1 "\quad Dutch Partner" 3.partnerPW1 "\quad Partner Other Ethn." 4.partnerPW1 "\quad No Partner" ///
			 everdivorcW1 "Ever Divorced" evercohabW1 "Ever Cohabited" singleparW1 "Single Parent" ///
			 2.religrcW1 "\quad Protestant" 3.religrcW1 "\quad Other" 4.religrcW1 "\quad None" ///
			 hhsizeW1 "Household Size" ///
			 2.nchildcatW1 "\quad 1 Child" 3.nchildcatW1 "\quad 2 Children" 4.nchildcatW1 "\quad 3 or More Children" ///
			 homeownW1 "Homeowner" ///
			 _cons "Intercept") ///
	   refcat(2.spksdutch "How Well Speaks Dutch \\ \quad Not at all"  ///
			  2.langpref "Language Used With \\ Boss, Friends, Neighbors \\ \quad Polish" /// 
			  2.educcatW1 "Highest Level of Education \\ \quad Primary or Below" ///
			  2.empstatRW1 "Employment Status \\ \quad Employed" ///
			  3.maritalRW1 "\quad Married" ///
			  2.partnerPW1 "Partner Status \\ \quad Polish Partner" ///
			  2.religrcW1 "Religious Denomination \\ \quad Catholic" ///
			  2.nchildcatW1 "Number of Children \\ \quad No Children", label(".ref")) ///
		drop(1.partnerPW1 1.spksdutch 1.langpref 1.educcatW1 1.empstatRW1 2.maritalRW1 1.religrcW1 1.nchildcatW1) ///
		stats(N ll aic bic, fmt(0 2 2 2) label("N" "Log Likelihood" "AIC" "BIC")) ///
		addnote("\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)")
