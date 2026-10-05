# ⛰️ Ato I: A Subida da Serra de Paranapiacaba (1645)

> **Cenário Jogável no Godot:** `res://Scenes/SubidaSerra.tscn`  
> **Protagonista:** Tião Caboclo & A Mula Bonita (Companheira de Comitiva)  
> **Extensão do Mapa:** 700px largura × 2.600px altura (Desnível vertical de 4 patamares)  
> **Estilo de Câmera:** Câmera Seguidora Suave (Câmera Híbrida centralizada no herói)

---

## 🗺️ Arquitetura dos 4 Platôs & Falésias de Relevo (Estilo *Age of Empires*)

O mapa reproduz a escarpa traiçoeira da Serra do Mar no século XVII, forçando o jogador a contornar falésias íngremes e desfiladeiros:

```
[ TOPO: Y = 200 ]   ──► PLATÔ 4: A GRANDE ENCRUZILHADA DA SERRA (Cruzeiro, Fogo-Fátuo, Vista de Piratininga)
                              ▲
                       [ FALÉSIA 3: Paredão das Cristas rochosas ]
                              ▲
[ MEIO: Y = 1050 ]  ──► PLATÔ 3: O BAMBUZAL DA CAIPORA (Mata densa, Altar de oferenda de Fumo de Rolo)
                              ▲
                       [ FALÉSIA 2: Garganta estreita de desfiladeiro ]
                              ▲
[ INTERM: Y = 1600] ──► PLATÔ 2: A GARGANTA DAS ÁGUAS (Rio, cachoeira, ponte e barris empurráveis)
                              ▲
                       [ FALÉSIA 1: Paredão rochoso com rampa natural à direita ]
                              ▲
[ BASE: Y = 2350 ]  ──► PLATÔ 1: O RANCHO DO PÉ DA SERRA (Cabana, Fogueira de pouso, Baú de carga)
```

---

## 🧭 Elementos Interativos & Level Design

### 1. Platô 1 — O Rancho do Pé da Serra (Y: 2.100 a 2.500)
* **Ponto de Partida:** Tião e a Bonita iniciam com a carga atrelada.
* **Fogueira de Pouso:** Interagir com `[E]` restaura a Vida ao máximo e faz carinho na mula (**+15% de Afinidade**).
* **Baú de Madeira e Ferro:** Contém rações de *Feijão Tropeiro* (+6 HP), *Facão de Três Listras* e *Fumo de Rolo de Oferenda*.

### 2. Platô 2 — A Garganta das Águas (Y: 1.400 a 1.800)
* **Paredão 1:** Bloqueia a subida direta pela esquerda, canalizando a tropa para a rampa pedregosa da direita.
* **Mecânica de Puzzles (*Goofy Troop*):**
  * Dois barris pesados de cascalho/pólvora bloqueiam o caminho na entrada do pontilhão.
  * O jogador anda contra os barris para **empurrá-los com física e atrito**, desobstruindo a passagem da mula!
* **Rio & Pontilhão:** Passagem estreita de madeira de aroeira sobre as corredeiras do Rio Cubatão.

### 3. Platô 3 — O Bambuzal da Caipora (Y: 800 a 1.300)
* **A Floresta Densa:** Touceiras de taquara e jequitibás centenários criam uma atmosfera de neblina e sombras.
* **O Altar da Caipora:**
  * Altar rústico de pedras de rio.
  * Interagir com `[E]` permite depositar a oferenda de fumo conquistada no Rancho.
  * **Efeito:** A floresta se acalma, ouve-se um assobio amigo e a mula ganha **+25% de Afinidade** (*Irmã de Alma*).

### 4. Platô 4 — A Grande Encruzilhada da Serra (Y: 150 a 500)
* **O Cume:** O paredão se abre para os campos altos de altitude.
* **Cruzeiro de Pedra & Fogo-Fátuo:** Ponto de confluência onde a subida do Tropeiro se encontra com os destinos do Batedor Nativo e do Desertor da Coroa.

---

## 🐴 Mecânica Viva da Comitiva (Mula Bonita)

* **Script Dedicado:** `res://Scripts/MulaBonita.gd`
* **Rédea Dinâmica:** Linha de couro renderizada dinamicamente entre as mãos do Tropeiro e o cabresto da mula.
* **Movimentação:** Mantém distância orgânica (55px), virando o sprite e balançando os cascos suavemente ao caminhar.
* **Escala de Afinidade:**
  * `< 50%:` Arredia (passo lento e empaca fácil);
  * `50% a 119%:` Dócil (marcha firme e atenta);
  * `≥ 120%:` Irmã de Alma (alerta perigos antes do jogador e bônus de velocidade).
