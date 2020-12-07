/*============================================================================================================================  
Autora: Suelene Mascarini
Criacao:05.12.2020
Ultima alteracao: 07.12.2020 
objetivo: Responder teste da analise de dados da 4Intelligence
OBS: Por segurança o caminho para abrir e salvar os arquivos foi omitido deixando indicado a programaçao
============================================================================================================================ */


/*======================================================================================================================
                                                    CASE 1
====================================================================================================================== */
clear
set mem 100m
log using "caminho\Results.log", replace text
import delimited caminho\TFP.csv, encoding(UTF-8) 
egen cntry = group(isocode)
xtset cntry year

* Analise exporatoria
twoway line rtfpna year if isocode=="CAN" ||        ///
	   line rtfpna year if isocode=="MEX" ||       ///
	   line rtfpna year if isocode=="USA",         ///
	   legend(col(3) lab(1 "CAN") lab(2 "MEX") lab(3 "USA")) ///
	   title("Produtvidade Total do Fator a  preços constantes")
graph save Graph "caminho.gph"	   
graph export "caminho.tif", as(tif) replace
caplog using Q1_4i.txt, replace:bysort isocode: xtsum rtfpna

***Prevendo
clear
set mem 100m
import delimited caminho\TFP.csv, encoding(UTF-8) 
reshape wide rtfpna, i( year) j(isocode) string

tsset year
foreach country in CAN MEX USA{
arima rtfpna`country', arima (1,1,1)
tsappend, last(2021) tsfmt(float)
predict TFP_`country', y dynamic(float(2011))
tsline TFP_`country'
}

* graficando
twoway line TFP_CAN year || ///
	   line TFP_MEX year || ///
	   line TFP_USA year , legend(col(3) lab(1 "CAN") lab(2 "MEX") lab(3 "USA"))
graph export "caminho\FTP11_21.tif", as(tif) replace
log close


/*======================================================================================================================
                                                    CASE 2
====================================================================================================================== */
clear
set mem 100m
log using "caminho\nomedoarquivo.log", append text
import delimited caminho\data_comexstat.csv, encoding(UTF-8)

/*==========================================================================================*
Q1. Show the evolution of total monthly and total annual exports from Brazil 
(all states and to everywhere) of ‘soybeans’, ‘soybean oil’ and ‘soybean meal’
==========================================================================================*/
gen year= substr(date,1,4)
destring year, replace
gen month= substr(date,1,7)
generate mdate = date(month,"YM")
format %tdNN/CCYY mdate
drop month

*Evolução Mensal em Toneladas
egen tonsBR=total(tons), by(date product type)
gen  tonsBr_Milhoes=tonsBR/1000000
twoway line tonsBr_Milhoes mdate if (type=="Export" & product =="soybean_oil") || 		///
	   line tonsBr_Milhoes mdate if (type=="Export" & product =="soybean_meal") || 		///
	   line tonsBr_Milhoes mdate if (type=="Export" & product =="soybeans"), 			///
	   legend(col(3) lab(1 "Óleo de Soja") lab(2 "Farelo de Soja") lab(3 "Grão de Soja")) 		///
	   xtitle("Mês/Ano") ytitle("Toneladas (Milhões)") title("Evolução das Exportações Brasileira")
graph save Graph "caminho\nomegrafico.gph"
graph export "caminho\nomegrafico.tif" as(tif) replace

*Evolução Mensal em USD
egen USDBR=total(usd)  , by(date product type)
gen  USDBRBr_Bi=USDBR/1000000000
twoway line USDBRBr_Bi mdate if (type=="Export" & product =="soybean_oil") || 		///
	   line USDBRBr_Bi mdate if (type=="Export" & product =="soybean_meal") || 		///
	   line USDBRBr_Bi mdate if (type=="Export" & product =="soybeans"), 			///
	   legend(col(3) lab(1 "Óleo de Soja") lab(2 "Farelo de Soja") lab(3 "Grão de Soja")) 		///
	   xtitle("Mês/Ano") ytitle("US$ (Bilhões)") title("Evolução das Exportações Brasileira")
graph save Graph "caminho\nomegrafico.gph"
graph export "caminho\nomegrafico.tif" as(tif) replace
	   
*Evolução Anual em Toneladas
egen tonsBRy=total(tons), by(year product type)
gen  tonsBry_Milhoes=tonsBRy/1000000
twoway line tonsBry_Milhoes year if (type=="Export" & product =="soybean_oil")   || 	///
	   line tonsBry_Milhoes year if (type=="Export" & product =="soybean_meal")  || 	///
	   line tonsBry_Milhoes year if (type=="Export" & product =="soybeans")      , 	///
	   legend(col(3) lab(1 "Óleo de Soja") lab(2 "Farelo de Soja") lab(3 "Grão de Soja")) 		///
	   xtitle("Ano") ytitle("Toneladas (Milhões)") title("Evolução das Exportações Brasileira")
graph save Graph "caminho\nomegrafico.gph"
graph export "caminho\nomegrafico.tif" as(tif) replace

*Evolução Anual em USD
egen USDBRy=total(usd)  , by(year product type)
gen  USDBRy_Bi=USDBRy/1000000000
twoway line USDBRy_Bi year if (type=="Export" & product =="soybean_oil") || 		      ///
	   line USDBRy_Bi year if (type=="Export" & product =="soybean_meal") || 		      ///
	   line USDBRy_Bi year if (type=="Export" & product =="soybeans"), 			          ///
	   legend(col(3) lab(1 "Óleo de Soja") lab(2 "Farelo de Soja") lab(3 "Grão de Soja")) 	///
	   xtitle("Ano") ytitle("US$ (Bilhões)") title("Evolução das Exportações Brasileira")
graph save Graph "caminho\nomegrafico.gph"
graph export "caminho\nomegrafico.tif" as(tif) replace
	   
/*==========================================================================================
Q2.What are the 3 most important products exported by Brazil in the last 5 years? 
==========================================================================================*/
graph pie tons if (type=="Export" & year>2014), over(product)  sort descending   ///
	  plabel(_all percent, color(white) size(small) format(%2.1g)) intensity(inten80) ///
	  plotregion(lstyle(none)) legend(on col(3)) ///
	  title("Participação dos produtos brasileiros nas exportações, no acumulado entre 2014 e 2019 (Ton)")  ///
	  note("Elaboração própria com dados disponibilizados pela 4i")
graph save Graph "caminho.gph", replace
graph export "caminho.tif", as(tif) replace

graph pie usd if (type=="Export" & year>2014), over(product)  sort descending   ///
	  plabel(_all percent, color(white) size(small) format(%2.1g)) intensity(inten80) ///
	  plotregion(lstyle(none)) legend(on col(3)) ///
	  title("Participação dos produtos brasileiros nas exportações, no acumulado entre 2014 e 2019 (US$)")  ///
	  note("Elaboração própria com dados disponibilizados pela 4i )")	  
graph save Graph "caminho.gph", replace
graph export "caminho.tif", as(tif) replace

/*==========================================================================================
Q3. What are the main routes through which Brazil have been exporting ‘corn’ in the last few 
years? Are there differences in the relative importancem of routes depending on the product? 
==========================================================================================*/
**Milho
graph hbar (sum) usd if (type=="Export" & year>2014 & product=="corn"), over(route, sort(usd) descending) missing ///
	  intensity(inten80) blabel(bar) legend(off) ///
	  title("Rotas das Exportações de Milho")  ///
	  note("Elaboração própria com dados disponibilizados pela 4i")

**comparativo
egen S_usd_prod=sum(usd) if year>2014, by(product type)
gen  Part=usd*100/S_usd_prod
graph hbar (sum) Part if (type=="Export" & year>2014), over(route) missing ///
	  by(product) intensity(inten80) legend(off) 
graph export "caminho.tif", as(tif) replace


/*==========================================================================================
Q4. Which countries have been the most important trade partners for Brazil in terms of 
‘corn’ and ‘sugar’ in the last 3 years? 
==========================================================================================*/
clear
set mem 100m
import delimited C:\Users\smasc\Desktop\4Intelligence\Challenge_4i\data_comexstat.csv, encoding(UTF-8)
gen year= substr(date,1,4)
destring year, replace
gen month= substr(date,1,7)
generate mdate = date(month,"YM")
format %tdNN/CCYY mdate
drop month
	
foreach typ in Export Import {			
foreach prod in corn sugar { 
		caplog using Q4_4i.txt, append: table country year if (year>2016 & type=="`typ'" & product=="`prod'"), c(sum usd) format(%11.0f) center row col
		display _newline(5)
			}	
		}
	logout, use(Q4_4i.txt) save (Q4_4i) noauto excel replace		
			
/*==========================================================================================
Q5. For each of the products in the dataset, show the 5 most important states in terms of exports?  
==========================================================================================*/	  		
collapse (sum) usd, by( product state type)
drop if type=="Import"
reshape wide usd, i(state) j(product) string
egen  usdtotal=rowtotal( usdcorn usdsoybean_meal usdsoybean_oil usdsoybeans usdsugar usdwheat) , missin
export excel using "caminho.xls", sheetreplace firstrow(variables)

 
/*==========================================================================================
Q6. 	Now, we ask you to show your modelling skills. Feel free to use any type of modelling 
approach, but bear in mind that the modelling approach depends on the nature of your data, 
and so different models yield different estimates and forecasts. To help you out in this task 
we also provide you with a dataset of possible covariates (.xlsx). They all come from public 
sources (IMF, World Bank) and are presented in index number format. Question: What should be 
the total brazilian soybeans, soybean_meal, and corn export forecasts, in tons, for the next 
11 years (2020-2030)? We’re mostly interested in the annual forecast.
==========================================================================================*/	  
	
log close
