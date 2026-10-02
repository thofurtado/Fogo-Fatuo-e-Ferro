---
name: fogo-fatuo-tilemap-gibi
description: Engenharia de mundos em blocos modulares (TileMapLayer, TileSet 32x32) com est?tica de Gibi Brasileiro Cl?ssico (1960-1980) e arquitetura de RPG Top-Down (Zelda: A Link to the Past, Super Mario RPG, Chrono Trigger) para Godot 4.3.
---

# Engenharia de Mundos em Blocos: TileMap & Gibi Brasileiro (Godot 4.3)

Este documento estabelece as diretrizes definitivas de engenharia e dire??o de arte para a constru??o do mundo de **Fogo-F?tuo & Ferro** bloco a bloco, abandonando ilustra??es est?ticas de fundo e adotando a arquitetura cl?ssica dos grandes RPGs de 16-bits (**Zelda: A Link to the Past**, **Super Mario RPG**, **Chrono Trigger** e **Final Fantasy VI**) fundida ? identidade visual dos quadrinhos nacionais (Renato Canini e Mauricio de Sousa).

---

## 1. Por Que Construir o Mundo Bloco a Bloco?

### 1.1. O Erro da "Foto Est?tica com Personagem em Cima"
* **Falha T?cnica:** Imagens est?ticas em tela cheia dependem de cache do compilador de texturas (`.godot/imported`). Se o projeto for movido ou compartilhado sem o cache, a tela fica em branco.
* **Falha de Design:** Imagem fixa n?o ? videogame. O personagem fica deslizando sobre um desenho plano sem profundidade, sem relevo e sem colis?o org?nica.

### 1.2. A Solu??o Cl?ssica dos Mestres (TileMap + Y-Sort)
* **Mundo Modular e Infinito:** O cen?rio ? montado com pe?as modulares de 32x32 pixels (grama, trilhas, cercas, paredes, ?rvores, ?guas).
* **Profundidade Real 2.5D (Y-Sort):** O jogador passa na frente e atr?s dos troncos e paredes.
* **C?mera Seguidora Din?mica:** A `Camera2D` desliza suavemente revelando clareiras, pontes, ranchos e perigos ? medida que o her?i caminha.
* **Leveza Absoluta e Portabilidade:** O mundo inteiro roda a partir de um atlas de menos de 100 KB, carregando instantaneamente em qualquer computador, Mac, Linux ou celular.

---

## 2. A Est?tica do Gibi Brasileiro nos Tiles (Dire??o de Arte)

Para manter o visual de quadrinho cl?ssico dos anos 1960?1980, cada bloco do TileSet deve seguir regras rigorosas de arte manual:

### 2.1. O Contorno de Nanquim Preto (Ink Outline)
* **Linhas de Tinta S?lidas:** Todos os elementos estruturais (?rvores, cercas, paredes de pau-a-pique, rochas e margens) possuem contornos pretos expressivos (1 a 2 pixels de espessura no grid 32x32).
* **Modula??o de Peso:** A base das ?rvores e das constru??es possui contornos mais grossos, dando sensa??o de ancoragem gravitacional no solo (estilo Canini).

### 2.2. Hachuras Manuais para Sombra (Cross-Hatching)
* Nada de degrad?s modernos ou sombras borradas por Photoshop.
* As ?reas sombreadas s?o constru?das com **tramas de hachura** (pequenas linhas diagonais pretas paralelas ou cruzadas), recriando a textura da pena de bico de mosquito sobre papel jornal.

### 2.3. Paleta Ecoline / Papel Imprensa (64 Cores da Editora Abril)
* **Grama Nativa da Mantiqueira:** Verde folha vivo (`#4E9B3D`), verde sombra com nanquim (`#2E6822`) e verde broto (`#7AC74F`).
* **Trilhas de Tropeiros e Poeira:** Marrom ocre (`#C28B52`), terra vermelha de caf? (`#8C5329`) e poeira clara (`#DEC085`).
* **?guas do Brejo e Fogo-F?tuo:** ?gua escura pantanosa (`#1A3B4D`) com reflexos turquesa m?stico (`#2DD8C1`) e ret?culas roxas (`#3F2263`).
* **Arquitetura Colonial:** Barro cru de taipa (`#B88B4A`), madeira de cerne escurecida (`#5C3A21`) e telhas de barro cozido (`#BA4829`).

---

## 3. Arquitetura T?cnica no Godot 4.3 (TileMapLayer)

No Godot 4.3, o antigo n? monol?tico `TileMap` foi substitu?do pelo moderno **`TileMapLayer`**, permitindo controle cir?rgico de camadas, colis?es e profundidade:

```
World (Node2D, y_sort_enabled = true)
??? ChaoLayer (TileMapLayer, Z-index = 0)
?   ??? Grama, terra batida, pontilh?es de madeira
?   ??? Colis?o apenas em ?gua profunda ou precip?cios
??? DetalhesLayer (TileMapLayer, Z-index = 0)
?   ??? Flores silvestres, folhas ca?das, tufos de capim, cascalho
??? ObjetosYSortLayer (TileMapLayer, Z-index = 0, y_sort_enabled = true)
?   ??? Troncos de arauc?ria e jequitib? (Y Sort Origin na base da raiz)
?   ??? Paredes de pau-a-pique da cabana tropeira
?   ??? Cercas de mour?o, mour?es de porteira e fogueiras
?   ??? [Aqui tamb?m fica o Player e os NPCs no mesmo contexto de Y-Sort!]
??? Player (CharacterBody2D, Y-Sort ativo, piv? nos p?s)
??? Entidades (Curupira, Boitat?, Tropeiro, Ba? de Carga)
??? CopasLayer (TileMapLayer, Z-index = 1)
?   ??? Copas frondosas de ?rvores (o her?i anda por baixo das folhas)
?   ??? Telhados de sap? e alpendres
??? Camera2D (position_smoothing_enabled = true, limites definidos)
```

### 3.1. Calibra??o Cr?tica do Y-Sort
1. **Z-Index Unificado:** O `Player`, o `ObjetosYSortLayer` e os NPCs devem ter **Z-Index = 0**.
2. **Y-Sort Origin no TileSet:** Em objetos altos (?rvores de 64px ou 96px de altura), o ponto de ordena??o Y deve ser ajustado para a **linha de contato com o ch?o** (onde o tronco toca a grama).
3. **Piv? do Her?i:** O ponto central de colis?o do her?i fica nos seus **p?s**, garantindo que ao subir ele passe atr?s do tronco e ao descer ele passe na frente.

---

## 4. O Cat?logo de Blocos Modulares (Tileset 32x32)

O atlas modular b?sico de *Fogo-F?tuo & Ferro* divide-se nos seguintes conjuntos de pe?as:

1. **Terrenos da Mantiqueira (16 Tiles de Autotile / Terrains):**
   * Centro de grama, bordas retas (norte, sul, leste, oeste), cantos convexos e cantos c?ncavos.
   * Transi??o org?nica entre grama e estrada de terra com dentes e hachuras.
2. **Vegeta??o Nativa Modular:**
   * ?rvores de 2x2 ou 2x3 blocos (tronco no ch?o com colis?o + copa superior sem colis?o na camada `CopasLayer`).
   * Arbustos espessos intranspon?veis (que bloqueiam passagens secretas).
3. **Constru??es Tropeiras & Quilombolas:**
   * Paredes de pau-a-pique com amarra??o de cip? aparente.
   * Portas de t?buas largas com ferrolhos de ferro forjado.
   * Alpendres de pouso sustentados por esteios de aroeira.
4. **Adere?os e Props de Explora??o:**
   * Ba? de carga tropeiro com cantoneiras de ferro (anim?vel: fechado / aberto).
   * Fogueira com pedras de rio e caldeir?o de feij?o tropeiro fumegando.
   * Altares de pedra ind?gena e totens ancestrais de prote??o.
   * Labaredas de Fogo-F?tuo (azuis e esverdeadas).
