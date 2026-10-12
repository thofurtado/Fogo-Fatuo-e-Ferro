# Implementação: movimento no TileMapLayer e estados da Mula sem Cabeça

## Escopo

Foram adicionados dois controladores novos, próprios para o protótipo. Eles não substituem `TropeiroPlayer.gd` nem reutilizam `MulaBonita.gd`; assim, as cenas existentes permanecem intactas. A colisão com o mapa é física: o controlador do jogador não consulta células a cada quadro. O `TileMapLayer` fornece os corpos estáticos das células sólidas, e `CharacterBody2D.move_and_slide()` resolve o contato.

## Nós esperados

```text
TilemapPrototype (Node2D)
├── GroundLayer (TileMapLayer)             # TileSet externo; colisão só em células sólidas
├── DetailLayer (TileMapLayer)             # decoração sem colisão
├── YSortWorld (Node2D, y_sort_enabled=true)
    ├── Tropeiro (CharacterBody2D)         # TropeiroTilemapController.gd; grupo player
    │   ├── AnimatedSprite2D
    │   ├── CollisionShape2D
    │   └── AttackArea (Area2D)             # camada 4; máscara 3; monitoramento ativo
    │       └── CollisionShape2D            # retângulo/cápsula; posição atualizada pela direção
    └── MulaSemCabeca (CharacterBody2D)    # instância de Scenes/MulaSemCabeca.tscn
        ├── AnimatedSprite2D
        ├── CollisionShape2D                # corpo/cascos; não inclui a chama
        ├── DetectionArea (Area2D)
        │   └── CollisionShape2D            # círculo de percepção
        └── ChargeHitbox (Area2D)
            └── CollisionShape2D            # retângulo/cápsula à frente
└── CombatSystem (Node)                    # CombatSystem.gd; conecta os sinais por grupos
```

Use a origem de ambos os `CharacterBody2D` no ponto de contato com o chão. Desloque o desenho para cima dentro do quadro; desloque a forma física para cobrir pés/cascos e tronco, não a arte inteira. Mantenha jogador e criatura sob o mesmo pai com Y-sort ativo. Copas de árvores continuam numa camada visual separada, sem colisão. A cena-base da Mula já cria corpo, percepção e hitbox; seu `AnimatedSprite2D` ainda aguarda os frames finais.

## Movimento do Tropeiro

`Scripts/TropeiroTilemapController.gd` usa `CharacterBody2D` em modo `MOTION_MODE_FLOATING`, apropriado para exploração top-down. [3] Lê as ações `ui_*` e também W/A/S/D como os controladores atuais. `move_speed` inicia em 160 px/s; aceleração e frenagem deixam a resposta menos abrupta e são ajustáveis no Inspector.

O `AnimatedSprite2D` é opcional para o teste físico. Quando houver um recurso `SpriteFrames`, o script procura os clipes `idle_down/up/left/right` e `walk_down/up/left/right`. Na diagonal, escolhe o eixo dominante e conserva a última orientação em caso de empate. A implementação limita a velocidade diagonal e permite travar o movimento por diálogo com `set_movement_enabled(false)`.

A colisão não depende de nome ou referência direta ao `TileMapLayer`: configure a máscara do jogador para incluir a camada de mundo. Isso também deixa o controlador utilizável em outras cenas top-down.

## Matriz de colisão sugerida

Os valores são máscaras de bits do Inspector Godot; a camada 1 corresponde ao valor `1`, a camada 2 ao valor `2`, etc. O contato é filtrado pelo `collision_layer` do corpo e pelo `collision_mask` que o outro objeto consulta. [4]

- **Mundo sólido / TileSet:** camada 1 (`1`). Em `TileSet`, crie Physics Layer 0; marque formas apenas em água profunda, paredões, rochas e bases de obstáculos. Grama, trilha, margem caminhável e detalhes ficam sem forma física.
- **Tropeiro:** camada 2 (`2`); máscara `1 | 4` (`5`) para mundo e corpo da criatura.
- **Corpo da Mula:** camada 3 (`4`); máscara `1 | 2` (`3`) para mundo e jogador.
- **DetectionArea da Mula:** camada `0`; máscara `2` para detectar corpos do jogador. Raio inicial sugerido: 160–220 px.
- **ChargeHitbox da Mula:** camada 5 (`16`); máscara `2`; `monitoring = false` fora do estado `CHARGE`. Forma inicial sugerida: retângulo de 36×28 px, deslocado cerca de 28 px na direção da investida.
- **AttackArea do Tropeiro:** camada 4 (`8`); máscara `4` para detectar o corpo da Mula. O script a ativa durante a janela do golpe e desloca sua forma na direção atual; comece com retângulo de 36×28 px e offset de 26 px.

O corpo da Mula colide com obstáculos e com o jogador; as hitboxes são `Area2D` separadas para que dano não dependa da resolução física do corpo. Use `set_deferred("monitoring", ...)` ao ligar/desligar a área durante a física. `Area2D` detecta corpos quando está monitorando e sua máscara inclui a camada do corpo detectado. [4] Confira as formas e máscaras com **Debug > Visible Collision Shapes** no Editor.

## Ataque e vida

1. Instancie `Scenes/MulaSemCabeca.tscn` sob `YSortWorld`. Os nomes `DetectionArea` e `ChargeHitbox` são usados pelo controlador; não os renomeie. Em `_ready()`, a Mula conecta `body_entered`/`body_exited` da área de percepção e `body_entered` da hitbox da investida.
2. No Tropeiro, crie `AttackArea` como filho direto do `CharacterBody2D`, com `CollisionShape2D`, `collision_layer = 8`, `collision_mask = 4` e `monitoring = true`. O controlador procura exatamente o caminho `AttackArea`; sem esse nó não haverá golpes.
3. Adicione um `Node` chamado `CombatSystem` ao nó raiz da cena e anexe `Scripts/CombatSystem.gd`. Não é necessário conectar sinais manualmente: o sistema encontra os nós dos grupos `player` e `enemy` e conecta `attack_requested`, inclusive em atores adicionados depois.
4. O Tropeiro entra automaticamente no grupo `player`; a Mula entra em `enemy`. A tecla **J** pede um ataque do Tropeiro (o método público `request_attack()` também pode ser chamado por um botão de toque). Cada alvo só recebe um acerto por golpe.

```text
Tropeiro.request_attack() ── AttackArea ── attack_requested(alvo, dano) ─┐
Mula: ChargeHitbox ─────────────── attack_requested(alvo, dano) ─────────┤
                                                                        v
                          CombatSystem → alvo.take_damage(dano, origem)
```

O `CombatSystem` só roteia dano e bloqueia fogo amigo; a vida pertence aos atores. `TropeiroTilemapController.take_damage()` altera `current_health`, sincroniza `GameManager.current_archetype["vida_atual"]` e emite `health_changed`/`died`. A Mula mantém `health` e `max_health`, emite `health_changed` e, ao chegar a zero, `defeated`. Conecte esses sinais ao HUD/efeitos da cena; `attack_applied` do sistema também pode disparar som, partículas ou números de dano.

## Máquina de estados da Mula

`Scripts/MulaSemCabecaController.gd` define estas transições:

```text
IDLE → CHASE → WINDUP → CHARGE → RECOVER → CHASE ou IDLE
                         qualquer estado vivo → STAGGER → CHASE ou IDLE
                         vida zero → DEFEATED
```

- `IDLE`: aguarda um corpo no grupo `player` entrar em `DetectionArea`.
- `CHASE`: aproxima-se diretamente do alvo. Ao entrar em `charge_trigger_distance`, para e entra em `WINDUP`.
- `WINDUP`: fixa a direção do alvo por 0,55 s para que o jogador possa ler e reagir à intenção.
- `CHARGE`: avança nessa direção por até 0,45 s. A hitbox fica ativa apenas aqui e cada investida emite no máximo um `attack_requested(target, damage)`.
- `RECOVER`: desacelera por 0,8 s; depois volta à perseguição se o alvo continuar na área.
- `STAGGER`: reação a `take_damage()`, com impulso opcional de repulsão.
- `DEFEATED`: desliga colisões/áreas e emite `defeated`, para que a cena de combate escolha como tocar `vanish` e remover a criatura.

`CombatSystem.gd` recebe o `attack_requested` da investida e aplica dano pelo método `take_damage()` do Tropeiro. Conecte `defeated` à lógica que reproduz a animação de dissolução e chama `queue_free()` depois que ela terminar.

A perseguição inicial é direta. `move_and_slide()` evita atravessar árvores e margens sólidas, mas não calcula caminho ao redor delas; se os testes mostrarem que a Mula fica presa, a próxima etapa é acrescentar `NavigationAgent2D` ou uma busca em grade, não ignorar colisões.

## Como testar

1. Anexe `TropeiroTilemapController.gd` a um `CharacterBody2D`, inclua `CollisionShape2D` e `AttackArea/CollisionShape2D`; o script adiciona o grupo `player`.
2. Configure a camada 1 do `TileSet` para as células sólidas e confirme que `GroundLayer` compartilha o TileSet externo. Não aplique colisão à grama ou à trilha.
3. Instancie `Scenes/MulaSemCabeca.tscn`, adicione `CombatSystem` à raiz e mantenha os nomes de áreas previstos.
4. Crie ou importe os clipes nomeados no recurso `SpriteFrames`. A ausência de animações não impede o movimento; clipes ausentes simplesmente não são tocados.
5. Rode a cena, visualize formas físicas, teste WASD/setas, **J** para atacar, percepção, aviso da investida, um único dano por golpe, recuperação e derrota; conecte `health_changed` ao HUD.

O ambiente desta tarefa não tem o executável Godot de linha de comando disponível. Portanto, os scripts foram preparados e revisados estaticamente, mas precisam ser abertos e executados no Editor Godot 4.7 para validação de sintaxe/runtime e ajuste visual dos shapes.

## Referências oficiais

[1]: https://docs.godotengine.org/en/4.7/tutorials/2d/using_tilemaps.html "Using TileMaps — Godot Engine 4.7"
[2]: https://docs.godotengine.org/en/4.7/tutorials/2d/using_tilesets.html "Using TileSets — Godot Engine 4.7"
[3]: https://docs.godotengine.org/en/4.7/classes/class_characterbody2d.html "CharacterBody2D — Godot Engine 4.7"
[4]: https://docs.godotengine.org/en/4.7/classes/class_area2d.html "Area2D — Godot Engine 4.7"
