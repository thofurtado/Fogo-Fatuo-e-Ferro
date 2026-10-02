class_name DiceRoller

# Sistema Base: Storyteller (Vampiro: A Mascara)
# Rola D10s. Resultados >= Dificuldade = Sucesso. Resultados '1' subtraem sucessos.

static func rolar_teste(parada_de_dados: int, dificuldade: int = 6) -> Dictionary:
	var sucessos = 0
	var falhas_um = 0
	var resultados = []
	
	for i in range(parada_de_dados):
		var rolagem = (randi() % 10) + 1 # Gera numero de 1 a 10
		resultados.append(rolagem)
		
		if rolagem >= dificuldade:
			sucessos += 1
		elif rolagem == 1:
			falhas_um += 1
			
	var sucessos_finais = sucessos - falhas_um
	
	var tipo_resultado = "Falha"
	if sucessos_finais > 0:
		tipo_resultado = "Sucesso"
	elif sucessos == 0 and falhas_um > 0:
		tipo_resultado = "Falha Critica"
		
	return {
		"dados_rolados": resultados,
		"sucessos_brutos": sucessos,
		"uns_rolados": falhas_um,
		"sucessos_finais": sucessos_finais,
		"resultado_narrativo": tipo_resultado
	}
