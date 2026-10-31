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
```

O teste de percurso constrói uma malha a partir das colisões reais, move o personagem usando a mesma entrada virtual do jogo, alcança as áreas de interação e termina a missão. Os testes usam armazenamento isolado ou desativam a gravação. A exportação Web também executa os quatro testes. Teste físico de controle, celular e navegação no Preview continuam necessários para avaliar conforto e compatibilidade no dispositivo final.


## Revisao artistica manual pendente

Em `Scenes/SubidaSerra.tscn`, o grupo `EscarpmentsContainer` contem as bordas de queda. As faixas marrons sao desenhos provisorios de `Scripts/EscarpmentLedge.gd`, nao erros de exportacao. Os paredoes nas laterais usam `Scripts/CliffFace.gd`. A composicao atual coloca muitas dessas bordas atravessando visualmente a trilha: ajustar apenas cor ou shader nao resolve a leitura de altura. E necessario recompor os patamares, substituir esses desenhos por arte coerente e conferir as colisoes e gatilhos de queda junto com o novo visual.

Em `YSortContainer`, revisar o espacamento, escala e sobreposicao das arvores e construcoes, evitando repeticao excessiva. Usar o tropeiro (aproximadamente 66 pixels de altura no mundo) como referencia. Mover um objeto pelo no pai preserva a relacao entre sprite e colisao; mover apenas o `Sprite2D` pode separar a imagem de sua area solida. A posicao dos objetivos tambem deve continuar acessivel.

A caminhada do tropeiro usa poses de contato e passagem distintas, com ancoragem dos pes e espelhamento consistente do ciclo lateral. O ritmo acompanha a distancia real percorrida. O teste `walk_cycle.gd` verifica a diferenca de silhueta e o avanco dos quadros em todas as direcoes; isso nao substitui a revisao artistica do movimento.
