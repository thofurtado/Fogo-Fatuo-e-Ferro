# 🎨 Guia de Trabalho no Godot: Pintura do Mapa da Subida da Serra

## 📍 Ponto de Parada (07/10/2026)
* **Cena Ativa:** `Scenes/PinturaMapaSubida.tscn`
* **Gabarito de Fundo Calibrado:** `Mapas/mapa_subida_santos_gabarito.png` (1920 × 2048 px)
* **Área Total:** **6 Telas de Jogo** (3 telas de largura × 2 telas de altura)
* **Grid do Jogo:** **60 colunas × 64 linhas** (blocos de 32 × 32 px)
* **Tileset Ativo:** `Assets/Tilesets/tileset_gibi.tres`

---

## 🖌️ Passo a Passo para Trabalhar Amanhã no Godot

### 1. Abrir a Cena
* Abra o **Godot 4.3**.
* No painel do sistema de arquivos (*FileSystem*), abra a cena:
  `res://Scenes/PinturaMapaSubida.tscn`

### 2. Preencher a Base Verde (Opcional)
* Selecione o nó raiz `PinturaMapaSubida` na árvore da cena (*Scene Tree*).
* No painel **Inspector** (à direita), marque a caixinha:
  `Preencher Fundo Com Grama: [x]`
* A tela preencherá automaticamente os 60 × 64 blocos com o gramado verde da serra, servindo de base limpa.

### 3. Selecionar a Camada de Pintura
A cena está organizada em 3 camadas (*TileMapLayers*):
1. **`ChaoTileMap`**: Camada de chão comum. Use para:
   * **Estrada de Barro / Trilha** (Laranja / Marrom)
   * **Água do Rio / Mangue** (Azul Ciano / Lama)
   * **Pranchas de Madeira** (Pontes sobre o rio)
2. **`EscarpasTileMap`**: Camada de relevo e paredões. Use para:
   * **Rocha de Granito** (Paredões e escarpas)
   * **Escarpa / Rampa** (Degraus unidirecionais da subida)
3. **`ObjetosTileMap`**: Camada superior para decorações, cruzeiro, arbustos e marcos.

### 4. Usar o Pincel do TileMap
* Clique no nó da camada desejada (ex: `ChaoTileMap`).
* No painel inferior do Godot, clique na aba **TileMap** / **TileSet**:
  * Você verá a paleta de texturas estilizadas (Gibi 32×32).
  * Clique no bloco que deseja usar (ex: Barro ou Água).
* Na barra de ferramentas do viewport superior:
  * Selecione a ferramenta **Pincel / Lápis** (ou tecla `D`).
  * Para preencher áreas maiores, use o **Balde de Tinta** (ou tecla `F`).
  * Para desenhar retas, use a ferramenta de **Linha** (ou tecla `L`).
* Pinte diretamente sobre a tela acompanhando o traçado do gabarito semitransparente ao fundo!

### 5. Controlar a Transparência do Gabarito
* Se quiser enxergar o desenho de fundo mais forte ou mais fraco:
  * Clique no nó raiz `PinturaMapaSubida`.
  * No **Inspector**, ajuste o controle deslizante:
    `Opacidade Gabarito` (de 0.0 até 1.0; padrão: 0.45).
* *(Nota: Quando o jogo for executado no runtime, o gabarito fica invisível automaticamente).*

### 6. Salvar o Progresso
* Pressione `Ctrl + S` para salvar a cena.

---

## 📦 Paleta de Blocos Cadastrados no Tileset

### 1. Atlas Básico (Chão & Paredões) — `Fonte 0`
| Bloco | Coordenada no Atlas | Função no Jogo | Colisão Física? |
| :--- | :--- | :--- | :---: |
| **Grama Verde** | `(0, 0)` | Chão base da serra e clareiras | Não (Livre) |
| **Trilha de Barro** | `(1, 0)` | Caminho do Peabiru / estrada dos tropeiros | Não (Livre) |
| **Água de Rio** | `(2, 0)` | Rios Cubatão, Troncos e canais de Santos | Não (Vadeável/Livre) |
| **Rocha de Granito** | `(3, 0)` | **Paredões intransponíveis e abismos** | 🧱 **SIM (Bloqueia 100%)** |
| **Prancha de Madeira**| `(4, 0)` | Pontes de troncos e trapiches do cais | Não (Livre) |
| **Escarpa / Rampa** | `(5, 0)` | Degraus da serra com colisão unidirecional | Rampa |
| **Lama de Mangue** | `(6, 0)` | Área de desaceleração e manguezal | Não (Desacelera) |
| **Grama de Bloqueio (Mata Intransponível)** | `(7, 0)` | **Verde idêntico ao gramado, mas fecha passagens** | 🧱 **SIM (Bloqueia 100%)** |

> 💡 **Como pintar barreiras verdes de mata fechada:**  
> O bloco `(7, 0)` tem exatamente o mesmo verde da grama comum `(0, 0)`, mas possui **colisão física sólida total**. Use-o para fechar bordas de morros, mata fechada ou áreas onde você não quer que o jogador vá, sem quebrar o visual verde do mapa!


---

### 2. Coleção de Objetos Sólidos & Árvores — `Fonte 1 (Scenes Collection)`
No painel inferior do Godot, na aba **TileSet**, na coluna esquerda onde ficam as fontes de imagem, você verá o ícone de **Cenas / Objetos**:
1. 🌴 **Árvore Tropical:** Árvore média com copa ampla. Tem colisão redonda na base do tronco e Y-Sort (o herói passa por trás das folhas e na frente das raízes).
2. 🌳 **Árvore Jequitibá:** Árvore monumental para marcos da mata fechada, com raiz sólida de 9m² de bloqueio.
3. 🪨 **Bloco de Granito (64×32):** Matacão de pedra duplo para estreitar desfiladeiros e fechar passagens.

> 🖌️ **Como carimbar árvores no mapa:**  
> 1. Selecione a camada **`ObjetosTileMap`**.  
> 2. No painel inferior **TileSet**, clique na fonte **1 (Scenes Collection)**.  
> 3. Clique na árvore e carimbe diretamente com o botão esquerdo do mouse sobre a tela!

