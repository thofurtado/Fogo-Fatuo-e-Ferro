# Combate na SubidaSerra: integração, feedback e logs

## O que está integrado

A cena `Scenes/SubidaSerra.tscn` agora reúne o combate dentro do mapa existente, sem substituir `MainMenu.tscn` nem a rota de exploração:

- a Mula sem Cabeça é instanciada em `YSortContainer/MulaSemCabeca`, perto da clareira do altar, em `(930, 900)`;
- o Tropeiro da cena continua usando `TropeiroPlayer.gd`, com `AttackArea` como filha direta e tecla **J** para atacar;
- `CombatSystem` conecta os sinais `attack_requested` do jogador e da criatura e encaminha dano;
- `CombatFeedback` escuta windup, janela de golpe, acerto, estados de preparação da Mula e derrota;
- `CombatHUD` mostra HP do inimigo, estado atual, último evento e instrução de controle;
- `CombatTestLogger` abre uma sessão CSV automaticamente ao entrar na cena.

A silhueta geométrica escura e a chama azul da inimiga são *placeholders* intencionais. Não são sprites finais; servem para conferir tamanho, origem, escala, leitura e colisões até a produção das folhas de animação.

## Camadas físicas na cena principal

Os números são máscaras de bits do Godot. O valor `2`, por exemplo, representa a camada 2.

| Elemento | Camada | Máscara | Uso |
|---|---:|---:|---|
| Mundo/obstáculos | 1 | conforme o corpo | Paredões, água bloqueada e obstáculos existentes |
| Tropeiro | 2 | 5 (`1 + 4`) | Colide com mundo e corpo da Mula |
| Corpo da Mula | 4 | 3 (`1 + 2`) | Colide com mundo e Tropeiro |
| `DetectionArea` da Mula | 0 | 2 | Reconhece apenas o Tropeiro |
| `ChargeHitbox` da Mula | 16 | 2 | Detecta o Tropeiro durante `CHARGE` |
| `AttackArea` do Tropeiro | 8 | 4 | Detecta o corpo da Mula durante a janela de golpe |

A máscara ajustável `player_collision_mask` da instância da Mula está em `2`, igual à camada do jogador. Se o projeto reatribuir camadas físicas, atualize em conjunto a instância na cena e o Inspector. Ative **Debug → Visible Collision Shapes** para observar corpo, percepção e hitboxes.

## Feedback visual e sonoro

`Scripts/CombatFeedback.gd` é um filho do nó raiz da cena e recebe caminhos exportados para jogador, inimiga, `CombatSystem` e camada ordenada do mundo. Os sinais são conectados em `_ready()`; assim, efeitos ficam fora da lógica de vida e dano.

- **Windup do Tropeiro:** toca `tropeiro_windup.wav` e emite partículas âmbar antes da abertura da hitbox.
- **Janela de ataque:** desenha um arco geométrico breve na direção travada do golpe.
- **Acerto:** `attack_applied` emite partículas no alvo e toca o som de impacto quando o ataque envolve o Tropeiro.
- **Windup/derrota da Mula:** emite faíscas azuladas para sinalizar a preparação e a derrota.

As partículas atuais são `CPUParticles2D` criadas por código, com uma textura branca de 3×3 px tingida por evento. São uma primeira camada de feedback, não um sistema de VFX final. Em seguida, substituir por sprites de impacto/chama desenhados para a paleta 16-bit e limitar emissão/quantidade para manter o efeito legível em resolução retrato.

## Controles e rotina de teste

1. Inicie o jogo pelo menu habitual ou rode `Scenes/SubidaSerra.tscn` com **F6 (Run Current Scene)**.
2. Mova-se com **WASD** ou setas; aproxime-se da Mula para iniciar perseguição e antecipação.
3. Pressione **J** para atacar. A preparação de 0,18 s e a janela de acerto vêm de `TropeiroPlayer.gd`.
4. Ajuste a dificuldade selecionando `YSortContainer/MulaSemCabeca` no Inspector. Os exports estão agrupados em **Vida**, **Perseguição**, **Investida — balanceamento** e **Reação a dano**.
5. Após a derrota do Tropeiro, pressione **R** para reiniciar a cena com vida restaurada. A fogueira de pouso também sincroniza a cura do `GameManager` com o HP exibido no HUD.
6. Pressione **F8** para interromper ou retomar a gravação do CSV. Ao sair da cena, o logger fecha a sessão automaticamente.

## Logs de balanceamento e desempenho

O logger usa `user://combat_logs/` e cria um nome único, por exemplo:

```text
combat_subida_serra_<data-hora>_<ticks>.csv
```

O caminho absoluto aparece no painel **Output** do Godot. A pasta `user://` fica no diretório de dados de usuário da aplicação Godot, não dentro dos assets versionados do projeto. Cada CSV começa com a configuração de balanceamento da Mula e registra:

- início/fim da sessão e motivo do encerramento;
- windup e abertura da janela de ataque do Tropeiro;
- acertos, dano, alvo, HP atual dos dois atores e estado da Mula;
- amostras a cada segundo de FPS, tempo de processamento e tempo de física;
- resumo ao encerrar com médias de FPS/tempo e FPS mínimo observado.

As métricas de processamento são amostras do monitor do Godot, úteis para comparar sessões na mesma máquina/configuração; não substituem um perfil de GPU nem devem ser comparadas entre computadores diferentes sem contexto. Para comparar dificuldade, mantenha o intervalo de log, os mesmos valores do Inspector e sessões de duração parecida.

## Próximos passos para arte final

O plano de sprites existente em `Docs/PLANO_TILESET_E_ANIMACOES.md` continua sendo a referência de dimensões e ciclos.

### Tropeiro

1. Fechar a folha de **192×256 px**, com 3 colunas × 4 linhas de quadros 64×64: baixo, cima, direita e esquerda.
2. Produzir primeiro idle e caminhada (ciclo `0 → 1 → 2 → 1`, 8–10 FPS); depois interação, ataque de facão (4–5 quadros) e reação de dano.
3. Montar `SpriteFrames` com nomes compatíveis com as quatro direções e substituir o `Sprite2D` estático da cena por `AnimatedSprite2D`.
4. Adaptar `TropeiroPlayer.gd` para escolher clipes por direção/estado. Não somar o bob contínuo atual à animação de caminhada até confirmar que os pés não parecem deslizar; preservar a origem lógica no chão.
5. Usar o sinal `attack_window_started` para casar o quadro de impacto da animação com o início da hitbox; o feedback visual não deve aplicar dano por conta própria.

### Mula sem Cabeça

1. Desenhar o corpo em quadros-base de **96×96 px**, com origem nos cascos; manter a colisão próxima a 64×32 px e independente da chama.
2. Separar o fogo-fátuo em um `AnimatedSprite2D` filho: quatro quadros em loop a 4–6 FPS.
3. Criar primeiro parada e trote (quatro quadros por vista, 8–10 FPS); depois desenhar investida, atingida e dissolução.
4. Ligar `IDLE/CHASE/WINDUP/CHARGE/RECOVER/STAGGER/DEFEATED` aos clipes correspondentes. Não renomear os nós `DetectionArea` e `ChargeHitbox`, pois o controlador os procura por esses nomes.
5. Conferir cada vista e posição de hitbox com **Visible Collision Shapes**; a chama, partículas e fumaça devem continuar sem colisão física.

### Partículas e acabamento

- Primeiro finalizar o timing e a leitura em silhueta com os efeitos procedurais atuais.
- Substituir a textura quadrada por folhas pequenas de faísca, poeira de casco e chama com transparência nítida, sem blur.
- Se houver muitas entidades simultâneas, medir custo antes de trocar `CPUParticles2D` por outra técnica; em uma única investida, prefira o efeito mais simples que mantenha o pixel art limpo.
- Fazer uma rodada de ajuste no Editor: zoom e alinhamento inteiro, volume dos dois sons, duração das partículas, janela de ataque, e faixa de reação visual ao acerto.

## Validação desta integração

O projeto foi importado e `SubidaSerra.tscn` foi executada em Godot 4.7.2 headless sem erros de parsing ou inicialização. O smoke test integrado verificou: detecção da Mula, dano nos dois sentidos, atualização do HUD e gravação dos eventos/configuração no CSV. A validação headless confirma estrutura e lógica; a revisão visual de animação, áudio e colisões ainda deve ser feita no Editor, em execução normal.
