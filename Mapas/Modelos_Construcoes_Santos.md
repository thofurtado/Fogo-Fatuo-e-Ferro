# 🏛️ Modelos e Guia de Desenho: Construções da Vila de Santos (1645)

> **Contexto de Produção:** Referência visual oficial para o traçado de construções no CorelDRAW e montagem de sprites/tilesets no Godot 4 para *Fogo-Fátuo & Ferro*.

---

## 🎨 Prancha de Conceito Visual Oficial

![Conceito de Construções Coloniais 1645 - Igreja, Taverna e Casa](modelos_construcoes_santos.jpg)

*(Arquivo disponível em `Assets/Sprites/modelos_construcoes_santos.jpg` e `Anexos/modelos_construcoes_santos.jpg`)*

---

## 📐 1. Diretrizes Técnicas de Desenho

### A. Perspectiva (Top-Down 3/4)
* **Ângulo:** Projeção axonométrica / isométrica suave estilo RPG 16-bit (*Goofy Troop / Zelda*).
* **Fachada Frontal:** Paredes, portas e janelas vistas de frente (sem distorção de fuga complexa).
* **Telhado:** Visto com inclinação superior de 45° a 60°, permitindo ver as fileiras de telha canal de barro colonial.
* **Proporção:** 1 bloco do Grid = **1 metro** (32 × 32 px no Godot).

### B. Linguagem Visual (HQ Clássica Brasileira / Gibi Sério)
* **Traço:** Linha de contorno preta sólida e uniforme (nanquim digital), mantendo a clareza para telas móveis verticais (9:16).
* **Paleta de Cores:**
  * **Paredes:** Branco caiado / ocre claro envelhecido (`#F5EFEB`, `#EAE0D0`).
  * **Telhados:** Terracota / cerâmica queimada alaranjada (`#C85A32`, `#A04020`).
  * **Madeiramento:** Vigas, portas e esteios em castanho escuro colonial (`#4A2E1B`, `#6B4423`).
  * **Base / Alicerce:** Pedra de cantaria e conchas de sambaqui cinza-terroso (`#7D786F`, `#9C968B`).

### C. Camadas no Godot (Y-Sort e Colisão)
* **Colisão Física (StaticBody2D):** Deve cobrir **apenas a base no solo** (a linha de contato da parede com o chão, cerca de 1 bloco de altura).
* **Telhado e Fachada Alta:** Devem ficar acima do ponto de origem da cena (Offset `Y < 0`), permitindo que o jogador e a mula caminhem por trás ou pela frente da casa usando o **Y-Sort** sem engasgar na colisão.

---

## 🏘️ 2. Os Três Modelos Prontos de Construção

### ⛪ Modelo 1: Igreja Matriz / Capela Colonial (Código `B11` / `B10`)
* **Tamanho Sugerido no Grid:** **4×4 blocos** (Matriz) ou **2×2 blocos** (Capelinha).
* **Elementos Arquitetônicos de 1645:**
  1. **Torre Sineira:** Torre quadrada em taipa de pilão com sino de bronze exposto e cruzeiro no topo.
  2. **Portal em Arco Pleno:** Porta dupla de madeira pesada com dobradiças de ferro forjado e degraus de pedra de cantaria na entrada.
  3. **Óculo Superior:** Pequena abertura circular acima do portal para entrada de luz no coro.
  4. **Cruzeiro no Frontão:** Cruz de madeira ou pedra entalhada arrematando o topo do telhado.
* **Função no Jogo:** Ponto seguro da vila, cura de enfermidades/maldições, bênção para subir a serra e reuniões cívicas.

---

### 🍻 Modelo 2: Taverna do Porto & Secos e Molhados (Código `B03` / `B02`)
* **Tamanho Sugerido no Grid:** **3×3 blocos** (ou **3×2**).
* **Elementos Arquitetônicos de 1645:**
  1. **Balcão Externo Aberto:** Meia-parede com tábua larga servindo de balcão voltado para o cais (atendimento rápido de marujos e tropeiros).
  2. **Placa Suspensa:** Tábua de madeira entalhada presa por tiras ou suportes de ferro com o nome ("Taverna do Porto", âncora ou barril).
  3. **Props / Decoração de Calçada:**
     * Pilhas de barris de aguardente e tonéis de pólvora/sal.
     * Caixotes de feijão, fumo e ferramentas encostados na parede lateral.
  4. **Postigos de Madeira:** Janelas com folhas de madeira duplas que se abrem para fora.
* **Função no Jogo:** Recrutamento de batedores, jogos de dados valendo patacas de prata, compra de mantimentos de marcha e rumores sobre a serra.

---

### 🏡 Modelo 3: Casa Colonial Térrea (Habitação Simples) (Código `B20`)
* **Tamanho Sugerido no Grid:** **2×2 blocos** (ou **2×3** para sobrado simples).
* **Elementos Arquitetônicos de 1645:**
  1. **Taipa com Vigamento Aparente:** Estrutura mista de esteios verticais de tronco de lei com reboco de barro e cal de conchas.
  2. **Base com Desgaste de Umidade:** Faixa inferior de pedras e argamassa de sambaqui desgastada pela maresia e lamaçal da maré de Santos.
  3. **Porta Rústica de Pranchas:** Feita de tábuas verticais unidas por cravos de ferro e trinco de madeira.
  4. **Telhado Duas Águas com Beiral Saliente:** Beiral projetado para frente para escoar as chuvas torrenciais do litoral e proteger as paredes de taipa.
* **Função no Jogo:** Residência de pescadores, colonos e artesãos; quintais com bananeiras, galinheiros e cacimbas d'água.

---

## 🛠️ 3. Como Montar Usando os Sprites Existentes

No projeto, a textura base já modularizada está em:
👉 `Assets/Sprites/cabana_tropeira.png`

Ela contém:
* Peças de cumeeira e telhado capa-e-canal modular em fatias.
* Paredes de taipa caiada clara e paredes de tábuas de madeira.
* Portas com ferragens coloniais e janelas com caixilho.
* Alicerce de pedra de cantaria.

Ao desenhar no **CorelDRAW** ou pintar no **Godot TileMap**:
1. Defina a pegada no grid (ex: `[B20]` para Casa 2×2, `[B03]` para Taverna 3×3, `[B11]` para Igreja 4×4).
2. Posicione a parede frontal na altura dos olhos do jogador.
3. Adicione o telhado inclinado ocupando 1 a 2 blocos para cima.
4. Finalize com adereços de chão (barris, caixotes, degraus de pedra) que deem vida à cena portuária.
