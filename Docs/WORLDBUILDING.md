---
name: fogo-fatuo-worldbuilding
description: Metodologia avançada de Worldbuilding, Design de Campanhas Sandbox e Arquitetura de RPG baseada no Worlds Without Number (Kevin Crawford) e na historiografia de religiosidade colonial (Laura de Mello e Souza / Câmara Cascudo), adaptada para Fogo-Fátuo & Ferro na Godot 4.
---

# Metodologia de Worldbuilding & Design de RPG: Fogo-Fátuo & Ferro

Este documento consolida o método oficial de criação de mundo, ecologia mágica, facções dinâmicas e design de exploração para o RPG **Fogo-Fátuo & Ferro**, integrando a teoria de sandbox do clássico contemporâneo **Worlds Without Number (WWN)** de Kevin Crawford com a historiografia antropológica do Brasil Colonial e do Folclore Nacional.

---

## 1. O Motor de Facções (The Faction Turn System - WWN)

No mundo de *Fogo-Fátuo & Ferro*, o cenário não é um pano de fundo estático esperando a passagem do jogador. O mundo se move organicamente através de um sistema de turnos de facções baseado no capítulo 8 do WWN (páginas 322–343).

As 4 grandes potências coloniais e espirituais disputam o destino da terra:

### Facção 1: As Bandeiras e Milícias da Coroa (O Monstro de Ferro)
* **Atributos:** Força 6 | Riqueza 5 | Astúcia 2
* **Objetivo:** Abrir estradas de ferro e pólvora, queimar aldeias refratárias, capturar braços para as minas e derrubar matas sagradas.
* **Ativos (Assets):** Capitães-do-mato com cães farejadores, canhões de bronze, arcabuzes e feitorias armadas.

### Facção 2: As Missões e o Tribunal Inquisitorial (O Dogma Metropolitano)
* **Atributos:** Força 3 | Riqueza 4 | Astúcia 6
* **Objetivo:** Erradicar o "signo do demo" e a feitiçaria popular (*O Diabo e a Terra de Santa Cruz*), impor a catequese jesuítica e confiscar relíquias sagradas da terra.
* **Ativos:** Reduções fortificadas, autos-de-fé, espiões confessionais e boticários de claustro.

### Facção 3: A Confederação dos Povos da Mata (O Sangue Ancestral)
* **Atributos:** Força 4 | Riqueza 1 | Astúcia 7
* **Objetivo:** Proteger os santuários das árvores-matrizes, repelir os invasores com emboscadas de flechas envenenadas e invocar a ira dos guardiões espirituais.
* **Ativos:** Trilhas invisíveis, pajés de transe xamânico, armadilhas de cipó e sinergia mágica com o Curupira e o Boitatá.

### Facção 4: A Rede dos Quilombos e Tropeiros Livres (A Resistência e o Contrabando)
* **Atributos:** Força 4 | Riqueza 4 | Astúcia 6
* **Objetivo:** Garantir a soberania das comunidades livres nas serras (Mocambos/Quilombos), manter rotas de fuga seguras e contrabandear ferro, sal e pólvora.
* **Ativos:** Picadas de descaminho, tropas de muares camufladas, ferreiros de guerrilha e rede de sussurros dos rios.

---

## 2. Sistema de Tags de Regiões e Ermos (Wilderness Tags - WWN)

Toda região explorável na Godot 4 deve ser projetada combinando **duas Wilderness Tags** adaptadas do WWN (páginas 206–220). Cada tag dita automaticamente:
1. **Inimigos e Encontros**
2. **Perigos Naturais da Mata**
3. **Pistas e Segredos Investigativos**
4. **Recursos de Sobrevivência (Ervas, Minérios, Água)**

### Catálogo de Tags Nacionais:
* **`[Ninho de Encantados]`**: A presença de Curupiras, Caiporas ou Boitatás é densa. A bússola fica desorientada; pegadas mudam de direção no chão; fogueiras comuns apagam sozinhas; exige oferenda de fumo de rolo ou cantiga para transitar em segurança.
* **`[Terra Devastada pelo Ferro]`**: Tocos de árvores centenárias queimadas, fumaça residual de pólvora, armadilhas de ferro abandonadas e carcaças de animais. Os espíritos do local estão furiosos e atacam qualquer humano à vista.
* **`[Pouso de Tropeiros e Contrabando]`**: Restos de fogueiras de pedra, marcas entalhadas nos troncos com códigos de rotas, abrigo de chuva e possibilidade de encontrar comerciantes neutros ou salteadores.
* **`[Águas Profundas da Iara]`**: Riachos límpidos com flora deslumbrante e orquídeas raras. À noite, o canto hipnótico exige teste de Força de Vontade (Misticismo) para não se atirar nas correntezas.
* **`[Quilombo Oculto]`**: Zona fortificada por armadilhas naturais de bambu e espinhos. Amigável para o *Fugitivo* e o *Tropeiro*; extremamente hostil para o *Desertor* que ainda use fardamento da Coroa.

---

## 3. Desafios Sociais e Encontros Não-Violentos (WWN Reaction System)

No folclore brasileiro autêntico, criaturas como o Curupira e o Saci não são monstros para matar e pilhar XP. São **forças da natureza com inteligência, astúcia e valores morais**.

### Tabela de Reação Inicial do Encontro (Rolagem de D10):
* **Resultado 1–2 (Ira / Punição):** A entidade sente o desrespeito ou o cheiro de ferro. Lança maldição imediata (desorientação, ilusão labiríntica ou ataque de vespas da floresta).
* **Resultado 3–5 (Cautela / Desconfiança):** A entidade exige um pedágio ou teste de respeito. O jogador deve oferecer um item (fumo, cachaça, frutos colhidos) ou passar em teste de perícia.
* **Resultado 6–8 (Curiosidade Neutra):** A entidade aceita dialogar, propondo um enigma folclórico ou pedindo para punir um caçador invasor que desrespeitou a mata.
* **Resultado 9–10 (Bênção Ancestral):** O jogador é reconhecido como irmão da floresta. Recebe atalhos pelo mapa, amuleto de proteção ou visão de pegadas secretas.

---

## 4. Engenharia Técnica de RPG 2D na Godot 4 (Diretrizes de Construção)

Para garantir que o jogo nunca mais pareça uma imagem plana com adesivo, todo cenário e personagem deve obedecer a esta hierarquia arquitetural:

```
[LevelRoot (Node2D)]
  ├── WorldEnvironment (Iluminação e tonalidade)
  ├── CanvasModulate (Ciclo Dia/Noite: #FFFFFF -> #1C2338 azul noturno)
  │
  ├── TerrenoBase (TileMapLayer: Chão de terra, areia, gramado)
  │
  ├── EntidadesYsort (Node2D com y_sort_enabled = true)
  │     ├── ArvoreGrande (Sprite2D com Y-Sort e colisão na raiz)
  │     ├── PedrasComColisao (StaticBody2D)
  │     ├── Player (CharacterBody2D com State Machine e Y-Sort)
  │     ├── Curupira (Area2D / AnimatedSprite2D)
  │     └── ItensColetaveis (Area2D com brilho)
  │
  ├── CopasElevadas (TileMapLayer sem colisão, acima do Y-Sort)
  │
  └── UILayer (CanvasLayer de interface de RPG e diálogos)
```

1. **Y-Sorting Obrigatório:** O pé do personagem define sua coordenada Y. Se `Player.position.y < Arvore.position.y`, o personagem fica atrás da árvore. Se for maior, ele fica na frente. Isso cria tridimensionalidade visual orgânica.
2. **Spritesheets em 4 Direções:** O jogador deve possuir animações reais de 4 direções (`walk_down`, `walk_up`, `walk_left`, `walk_right`) com taxa de quadros fluida.
3. **Colisão Base-Only:** Troncos e obstáculos só bloqueiam a passagem na raiz (retângulo fino onde a base encosta no chão), permitindo que a copa passe por cima da cabeça do herói.