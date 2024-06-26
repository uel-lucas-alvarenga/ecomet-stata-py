* Author: Lucas Alvarenga <lb.am.alvarenga@uel.br>
*   Date: 2024-05-06
*   Desc: Late night coding wonders

qui {
	clear all
	
	local BASE_PATH "\\wsl.localhost\Debian\home\lal\work\uel\ecomet\4b2"
	local BLOCK_PROMPT 1
  
	cd `BASE_PATH'
  do "utils\utils.do"
	
	sysuse auto
	import delimited "data\csv\output.csv", clear
	
  label var rest "Identificador do restaurante"
	label var wagelaw "1 se houver lei de salário mínimo"
	label var after "1 se a lei de salário mínimo está ativa"
	label var branch "Rede do restaurante"
	label var pmeal "Preço médio de uma refeição"
	label var wage_st "Salário médio no restaurante"
	label var emptot "Total de pessoas empregadas"
	label var co_owned "1 se o restaurante tivesse co-proprietário"
  
  gen after_wagelaw = wagelaw * after
  label var after_wagelaw "1 se o restaurante está sob lei de salário mínimo"
  
  // y = Salário ------------------------------------------------
  n _print "*** Salário ***"
  
  n _print "Diferença antes e depois do tratamento"
  n ttest wage_st if !after, by(wagelaw)
  n ttest wage_st if after, by(wagelaw)
  
  n _print "Regresão DiD"
  n didregress (wage_st) (after_wagelaw), group(rest) time(after)
  
  _print "Regressão"
  regress wage_st i.wagelaw##i.after
  
  // Verificar diferença no erro padrão
  _print "Regressão stde"
  regress wage_st i.wagelaw##i.after i.rest, vce(cluster rest) 

  
  // y = Empregados ---------------------------------------------
  n _print "*** Empregados ***"
  
  n _print "Diferença antes e depois do tratamento"
  n ttest emptot if !after, by(wagelaw)
  n ttest emptot if after, by(wagelaw)
  
  n _print "Regresão DiD"
  n didregress (emptot) (after_wagelaw), group(rest) time(after)
  
  // y = Preço da refeição --------------------------------------
  n _print "*** Preço da refeição ***"
  
  n _print "Regresão DiD"
  n didregress (pmeal) (after_wagelaw), group(rest) time(after)
  
  // Variáveis de controle
  n _print "Variáveis de controle"
  n didregress (pmeal wage_st emptot) (after_wagelaw), group(wagelaw) time(after)
  estat trendplots
}
