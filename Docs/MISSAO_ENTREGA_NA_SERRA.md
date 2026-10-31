# Primeira missão jogável: Entrega na Serra

Recorte de jogo: transportar a carga de Santos até o planalto, preparar a comitiva no rancho e fazer a oferenda à Caipora. A opção **Jogar · Entrega na Serra** começa de dia e entra diretamente nesta missão. O prólogo e a criação continuam disponíveis separadamente.

## Ciclo

1. Seguir o objetivo até o baú do rancho e pegar comida e fumo.
2. Descansar na fogueira: cura completa, recompensa de afinidade uma única vez.
3. Consumir o fumo no altar. Sem o item, a etapa não pode ser concluída.
4. Chegar ao marco do planalto e interagir para concluir a entrega.

Há uma pista opcional na placa da cachoeira. Comida é consumível pela algibeira e cura seis pontos de vida. Quedas custam vida e afinidade; chegar a zero abre a retomada do checkpoint. Ganhar apresenta tempo, quedas e afinidade e permite começar novamente ou voltar ao menu.

## Controles e leitura

WASD/setas ou analógico/direcional movem. E/Enter/Espaço ou A interagem. I/Y abrem a algibeira. Escape/B voltam e Start abre a pausa. Mouse e touch dispõem de direcional e ações visíveis. No desktop em orientação horizontal, a exploração usa a largura disponível; ao sair, menus e páginas narrativas voltam ao formato original. O objetivo e o marcador dourado apontam o próximo destino; as interações só executam quando o jogador solicita, sem abrir diálogos automaticamente por proximidade.

## Persistência e limites

O progresso é guardado em `user://serra_checkpoint.json` nas mudanças de etapa e uso da comida. **Continuar viagem** restaura o checkpoint no mesmo perfil local/navegador. A derrota permite retomar com vida restaurada. A vitória encerra o checkpoint. A costa e o perímetro têm colisões; a água do rio reduz a marcha, com exceção da ponte. O peso da carga altera a velocidade. O corpo da mula não bloqueia o jogador.

Esta é uma missão curta de exploração, não o RPG completo. O combate do PR #2 continua fora desta branch; progressão longa, economia e outras regiões ainda não estão implementadas nesta missão.

## Apresentação

Os atores têm quatro direções e quatro quadros de caminhada por direção. O terreno recebe variação procedural, água animada, detalhes de vegetação e sombras. Passos emitem poeira discreta; há passos sonoros, vento e aves ao fundo. A fogueira ilumina o pouso e oscila suavemente. A pausa ajusta o volume geral.

## Verificação

No Godot 4.7.2, após importar os recursos:

```text
godot --headless --path . --script res://Tests/controls_smoke.gd
godot --headless --path . --script res://Tests/walk_cycle.gd
godot --headless --path . --script res://Tests/mission_rules.gd
godot --headless --path . --script res://Tests/mission_route.gd
godot --headless --path . --script res://Tests/trail_corridor.gd
godot --headless --path . --script res://Tests/wildlife_reactions.gd
godot --headless --path . --script res://Tests/wildlife_routines_reins.gd
godot --headless --path . --script res://Tests/weather_sound.gd
godot --headless --path . --script res://Tests/snake_strike.gd
```

O teste de percurso constrói uma malha a partir das colisões reais, move o personagem usando a mesma entrada virtual do jogo, alcança as áreas de interação e termina a missão. Os testes usam armazenamento isolado ou desativam a gravação. O workflow de exportação Web executa os nove testes. Teste físico de controle, celular e navegação no Preview continuam necessários para avaliar conforto e compatibilidade no dispositivo final.


## Trecho de referencia: rancho e curvas da serra

As 49 bordas pequenas e os quatro paredoes provisorios foram substituidos por cinco barrancos ilustrados em `EscarpmentsContainer`. Cada barranco fica entre as curvas, com arte, area solida e gatilho de queda no mesmo no. O Inspector expoe `lip_texture`, `ledge_width` e `ledge_height`; a arte aparece no editor. A queda calcula o pouso alem da face inteira para nao prender o ator dentro da colisao.

O rancho tem uma clareira, fogueira ao lado da estrada e vegetacao rasteira reutilizavel (`Scenes/SerraFern.tscn`). O riacho foi afastado da trilha antes da ponte. Algumas arvores receberam variacoes de tamanho e espelhamento. O marco do cume fica ao lado da estrada, preservando a passagem de ida e volta.

`Tests/trail_corridor.gd` segue a estrada pintada ate o alto e retorna pelo mesmo caminho, exigindo zero quedas. Depois verifica uma queda proposital e o pouso fora do barranco. `mission_route.gd` continua verificando a entrega completa com as colisoes reais. Isso complementa a revisao visual, sem substituir teste de conforto em celular e controle fisico.

Este e o primeiro trecho de referencia, nao o acabamento final de todas as regioes. Revisar a repeticao das copas, a transicao do porto, o encaixe dos barrancos no terreno e a consistencia das poses dos personagens. Em `YSortContainer`, mover o no pai preserva sprite e colisao juntos. Usar o tropeiro (aproximadamente 66 pixels de altura no mundo) como referencia de escala.

## Fauna reativa

Doze animais ocupam pontos definidos de margem de rio, mata e trilha: tres cobras, tres aves, tres pererecas e tres saguis. `SerraWildlifeRoutes.tscn` define os habitats e percursos; `ForestWildlife.gd` instancia os animais; `WildlifeCritter.gd` controla observacao, fuga, ocultacao e retorno. O retorno so ocorre quando a comitiva esta longe do ponto original. Aves batem asas e ganham altura; pererecas saltam; saguis recuam em altura junto a vegetacao; cobras rastejam e podem assustar a mula. Sao representacoes estilizadas, nao simulacoes biologicas.

O susto da Bonita dura menos de um segundo a um segundo, com recuperacao de dez segundos entre ativacoes. Maior afinidade encurta a reacao. Quando a redea estica, o tropeiro recebe um puxao limitado por velocidade e pelas colisoes; nao ha teleporte nem perda automatica de vida ou afinidade pelo susto. Pausa, inventario e dialogo impedem novos encontros de susto. As cobras agora podem dar um bote defensivo; os demais animais nao causam dano direto.

`wildlife_reactions.gd` verifica fuga real das aves, pererecas e saguis, susto unico da mula, deslocamento limitado do tropeiro, recuperacao, bloqueio durante pausa/inventario e impossibilidade de atravessar uma parede com o puxao. Os sons de bater de asas, coaxo e resfolego sao efeitos sintetizados discretos; nao sao gravacoes identificadas de especies.

Referencias regionais: [fauna da Serra da Bocaina, ICMBio](https://www.gov.br/icmbio/pt-br/assuntos/biodiversidade/unidade-de-conservacao/unidades-de-biomas/mata-atlantica/lista-de-ucs/parna-da-serra-da-bocaina/atributos-naturais/fauna), [jararaca, Instituto Butantan](https://butantan.gov.br/bubutantan/uma-jararaca-nada-comum-conheca-a-maior-causadora-de-acidentes-com-cobras-do-brasil).

## Rotinas, pousos e redea

`Scenes/SerraWildlifeRoutes.tscn` contem doze `Path2D`, editaveis com a ferramenta de curvas do Godot. O script `WildlifeRoute.gd` expoe a especie, velocidade, altura, tempo de pausa por ponto e indices dos abrigos. Os tempos correspondem aos pontos de controle, nao aos pontos intermediarios gerados pelo Godot. Os percursos terrestres e de galhos terminam no ponto inicial para fechar o circuito; os voos terminam fora do mapa e recomecam somente fora do enquadramento da camera. As tangentes da curva tambem sao respeitadas no jogo.

Aves usam `FaunaSky`, acima das copas e construcoes, com sombra no chao. Elas percorrem o cenario, param em arvores, recolhem as asas e retomam o voo. Os saguis ficam nos galhos de tres arvores definidas e alternam poses de alimentacao ao parar. Pererecas saltam entre pontos de margem e respiram durante o repouso. Cobras saem do mato, rastejam pela rota e voltam a abrigos com vegetacao na frente do corpo. A Bonita reage quando a cobra esta exposta. A aproximacao da comitiva continua interrompendo essas rotinas para a fuga.

`ReinRope.gd` atualiza a redea entre a mao do tropeiro e o cabresto da mula. Os pontos acompanham a direcao e a altura do quadro atual dos personagens. A curva perde folga quando a distancia aumenta, com uma oscilacao pequena e acabamento de sombra e fibra. O puxao fisico do susto continua limitado e respeitando as paredes; a nova curva e apresentacao visual, nao uma simulacao completa de corda com colisoes em cada ponto.

`wildlife_routines_reins.gd` acompanha quarenta segundos simulados de todas as rotas, verifica paradas e poses, camada do ceu, altura dos saguis, pontos de ligacao da redea e sua mudanca de folga para tensao.

## Clima, abrigo e som

`SerraWeather.gd` alterna tempo aberto, garoa, chuva forte e dissipacao com transicoes graduais. Vento movimenta as copas e samambaias, o terreno escurece com a chuva e a poeira deixa de aparecer quando molhado. A marcha ao ar livre perde no maximo 6% de velocidade; chuva nao retira HP. O rancho permite entrada pela frente, mostra o personagem sob a cobertura por transparencia e elimina essa penalidade enquanto abrigado. O ciclo para na pausa.

Aves procuram o pouso durante chuva forte e saguis prolongam o repouso nos galhos. Pererecas ficam mais ativas e coaxam. As reacoes de fuga continuam prioritarias quando a comitiva se aproxima.

`SerraSoundscape.gd` mistura sete camadas: mata, vento, chuva, telhado, rio, cachoeira e fogueira. Agua e fogo variam de volume com a distancia; sob o rancho entra o som de gotas na cobertura. Passos diferenciam terra, agua, madeira e cascos. Inventario, bau, descanso, oferenda, entrega, dano e tensao da redea recebem sinais sonoros. Sao efeitos sintetizados de prototipo, nao gravacoes de campo de especies nativas. A regulagem de volume existente continua disponivel na pausa.

A jararaca exposta arma o bote somente muito perto: aviso visual e chiado por 0,7 segundo, avanco curto na direcao marcada e 3 HP de dano em contato. E possivel desviar. Ha seis segundos entre ataques e imunidade breve apos o dano. Paredes bloqueiam o acerto; dialogos, inventario e pausa impedem novos ataques. Chegar a zero HP abre a mesma retomada de checkpoint usada nas quedas. Nao ha veneno persistente nem novos predadores nesta entrega.

`weather_sound.gd` verifica abrigo acessivel, mudanca da mistura sonora, pausa do clima e retomada das aves depois da chuva. `snake_strike.gd` verifica aviso, acerto, esquiva, intervalo, bloqueio por parede/inventario e derrota. A exportacao Web e a renderizacao nativa complementam esses testes; escuta em diferentes dispositivos e teste no navegador/celular continuam necessarios.
