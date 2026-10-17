# Plano de TileSet e animações — protótipo da mata

## Objetivo

Converter o conceito de exploração em um protótipo jogável de pixel art 16-bit, sem substituir o mapa atual até que terreno, colisões, escala e leitura estejam validados. Definir também os primeiros ciclos de animação do Tropeiro e da Mula sem Cabeça.

## Estado atual do projeto

- O projeto está configurado para Godot **4.7**, com viewport retrato de **572×1024**.
- `Assets/Sprites/tileset_gibi_32x32.png` mede **256×32 px**: oito células de 32×32. `Assets/Tilesets/tileset_gibi.tres` usa essa grade, tem colisão em duas células e uma coleção de cenas para a árvore tropical, o jequitibá e o bloco de granito.
- As cenas pesquisadas ainda não usam `TileMapLayer` nem `AnimatedSprite2D`. `WorldRPG.tscn` monta o chão com textura repetida, trilhas com `ColorRect` e objetos sob uma árvore Y-sort; `ForestGame.tscn` usa um fundo de tela inteira e colisões grandes colocadas à mão.
- `curumim_spritesheet.png` mede **192×256 px**, organizado em 3 colunas e 4 linhas de quadros de 64×64. `CurumimPlayer.gd` já percorre as quatro direções e usa o ciclo de caminhada `0 → 1 → 2 → 1`.
- `TropeiroPlayer.gd` já implementa movimento, mas ainda não escolhe quadros de animação. `MulaBonita.gd` é a mula de carga que segue o jogador; não é a Mula sem Cabeça inimiga.

## TileSet proposto

### Arquivos e atlas

Criar recursos novos, preservando o atlas existente:

- `Assets/Tilesets/mata_16bit_32.png`: atlas de produção, **512×512 px** — grade de 16×16 células de 32×32.
- `Assets/Tilesets/mata_16bit.tres`: recurso `TileSet` externo com célula de 32×32, camadas de física e terrenos configurados.
- `Scenes/TilemapPrototype.tscn`: cena de teste independente, sem trocar a cena principal.

O conceito vertical gerado serve de referência de paleta, vegetação, caminho e composição. Não deve ser recortado como se já fosse um atlas: não tem células alinhadas, transições repetíveis nem bordas projetadas para encaixe.

Agrupar células contíguas por função e reservar espaço para variantes. O primeiro recorte deve incluir grama, terra batida, margem e água, ponte simples, pequenas pedras, folhas e tufos. As árvores grandes, altares e props que ultrapassam uma célula devem continuar como cenas próprias ou tiles de coleção de cenas.

### Terrenos, camadas e colisões

Configurar um conjunto de terrenos para conectar automaticamente grama, trilha e margem/água. Escolher o modo de conexão no `TileSet` antes de pintar o mapa e preencher os *terrain peering bits* de cada variação; o modo define quais vizinhos o Godot considera ao conectar terrenos. Para props grandes, aproveitar a coleção de cenas já presente em `tileset_gibi.tres` ou instanciar as cenas existentes no plano de ordenação correto. O Godot recomenda camadas `TileMapLayer` separadas quando há funções de desenho distintas e permite reutilizar um `TileSet` externo entre elas. [1] [2]

Estrutura inicial sugerida:

```text
TilemapPrototype (Node2D)
├── GroundLayer (TileMapLayer)          # grama base e áreas caminháveis
├── SurfaceLayer (TileMapLayer)         # terra, margens, água e ponte
├── DetailLayer (TileMapLayer)           # folhas, flores e marcas; sem colisão
├── YSortWorld (Node2D, Y-sort ativo)   # jogador, criaturas e props que se cruzam
├── CanopyLayer (TileMapLayer)          # copas em primeiro plano; sem colisão
└── UILayer (CanvasLayer)               # opcional, somente após validar o mapa
```

A grama e as trilhas não precisam de colisão. Bloquear somente água profunda, precipícios e paredes. Árvores e rochas devem bloquear pela base ou pelo tronco, não pela copa inteira. Manter o ponto de ordenação de árvores, jogador e entidades na linha de contato com o chão. A cena atual do jequitibá já aproxima essa regra: a arte fica deslocada para cima e a colisão permanece junto às raízes.

### Cena de teste e critérios

Montar primeiro um pedaço de **24×36 células**, com uma clareira inicial, trilha, um cruzamento de água com ponte, três árvores de portes diferentes, uma rocha bloqueadora e um ponto de interação. Usar a viewport atual de 572×1024; começar com zoom de câmera **1.0** para comparar a leitura da grade e depois conferir o zoom 1.25 usado em `WorldRPG.tscn`.

Aprovar o protótipo quando:

1. grama, terra e margem conectarem sem lacunas ou cantos errados;
2. a caminhada passar corretamente atrás e à frente das árvores, com o personagem ordenado pelos pés;
3. troncos e água bloquearem, mas copas e detalhes não;
4. a câmera revelar rota suficiente no retrato sem esconder marcos de navegação;
5. o pixel art permanecer nítido, sem filtragem borrada nem tremor de posição subpixel.

Testar primeiro em `TilemapPrototype.tscn`; só depois migrar a clareira aprovada para `WorldRPG.tscn`.

## Animação do Tropeiro

### Primeiro spritesheet

Manter a convenção que já funciona com `CurumimPlayer.gd`: **3 colunas × 4 linhas**, cada quadro de **64×64 px**, total **192×256 px**. Usar as linhas na ordem `baixo`, `cima`, `direita`, `esquerda`. Em cada linha, desenhar três poses de caminhada: contato de um pé, passagem neutra e contato do outro pé. Reproduzir o ciclo `0 → 1 → 2 → 1`, aproximadamente **8–10 FPS** como ponto de partida.

A animação parada pode manter a pose central de cada direção. Isso entrega quatro poses de espera e doze quadros únicos de caminhada, sem exigir um segundo atlas. Reservar ciclos respiratórios para uma revisão posterior. Fixar os pés na base do quadro e deixar o pivô de ordenação no chão; para arte de 64×64, ajustar o deslocamento do desenho sem mover a origem lógica do personagem.

### Estados em ordem de produção

1. `idle_down`, `idle_up`, `idle_right`, `idle_left` — pose central, sem loop obrigatório.
2. `walk_down`, `walk_up`, `walk_right`, `walk_left` — três poses por direção, ciclo `0 → 1 → 2 → 1`.
3. `interact`/`pickup` — três quadros, uma vez, para testar amuleto, placa e baú.
4. `attack_machete` — quatro ou cinco quadros, uma vez, quando o combate estiver conectado.
5. `hurt` — dois quadros; deixar para a rodada seguinte.

No primeiro teste, não combinar quadros de caminhada com o balanço e a rotação contínuos de `TropeiroPlayer.gd`: esses tweens podem duplicar o movimento desenhado e produzir posições subpixel borradas. O movimento do corpo deve continuar pela física; os pés precisam ficar presos ao chão.

## Animação da Mula sem Cabeça

Criar uma entidade e cena próprias, por exemplo `MulaSemCabeca.tscn`, com recurso `SpriteFrames` separado. Não reutilizar `MulaBonita.gd`, cuja função atual é seguir o Tropeiro como animal de carga.

Usar um quadro inicial de **96×96 px** (três células de 32×32), com o corpo visivelmente maior que o humano e o ponto de apoio nos cascos. A forma de colisão cobre somente corpo/cascos, cerca de **64×32 px** como ponto de partida; fogo, fumaça e faíscas não colidem.

Para reduzir o custo inicial sem perder quatro direções, desenhar vistas `baixo`, `cima` e `lado`; espelhar a vista lateral para esquerda/direita se correntes, arreios e chama continuarem corretos quando invertidos.

### Primeiro conjunto de frames

- **Parada:** uma pose neutra por vista; manter o corpo quase estável.
- **Chama:** loop separado de **quatro quadros** na criança visual da chama, a **4–6 FPS**. Assim, o fogo-fátuo varia sem redesenhar o cavalo inteiro.
- **Trote:** **quatro quadros por vista** (`baixo`, `cima`, `lado`), total de doze quadros de corpo; começar em **8–10 FPS**. A repetição lateral pode ser espelhada para o outro lado.
- **Investida:** na segunda etapa, cinco ou seis quadros sem loop: antecipação, impulso, passada forte, contato e recuperação.
- **Atingida/desmaterialização:** depois da investida, dois ou três quadros de reação e seis de dissolução, caso a mecânica de combate peça isso.

Validar primeiro `parada + chama + trote` em exploração. A investida deve entrar apenas depois que tamanho, direção e colisão estiverem corretos; isso evita gastar quadros de ataque num inimigo ainda sem comportamento final.

## Configuração das animações no Godot

Para novos sprites, usar `AnimatedSprite2D` com um recurso `SpriteFrames` nomeado por estado e direção; ele permite guardar os clipes e definir velocidade de reprodução sem espalhar índices de quadros pelo controlador. A documentação do Godot 4.7 descreve tanto a importação de folhas de sprites quanto o uso de `play()`/`stop()` e FPS em `SpriteFrames`. [3] [4]

Manter a filtragem em vizinho mais próximo e testar alinhamento inteiro de posição. A referência de `AnimatedSprite2D` alerta que centralização em coordenadas fracionárias pode distorcer pixel art; usar o pivô/offset do quadro e o ajuste de pixel do projeto quando necessário. [4]

O protótipo não foi executado nesta sessão: o arquivo `project.godot` declara Godot 4.7, mas o executável de linha de comando não foi encontrado no `PATH` do ambiente. A validação indicada acima deve ser feita no Editor Godot do projeto, com as colisões visíveis durante a inspeção.

## Referências oficiais

[1]: https://docs.godotengine.org/en/4.7/tutorials/2d/using_tilemaps.html "Using TileMaps — Godot Engine 4.7"
[2]: https://docs.godotengine.org/en/4.7/tutorials/2d/using_tilesets.html "Using TileSets — Godot Engine 4.7"
[3]: https://docs.godotengine.org/en/4.7/tutorials/2d/2d_sprite_animation.html "2D sprite animation — Godot Engine 4.7"
[4]: https://docs.godotengine.org/en/4.7/classes/class_animatedsprite2d.html "AnimatedSprite2D — Godot Engine 4.7"
