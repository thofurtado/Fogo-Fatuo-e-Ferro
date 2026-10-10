# 📐 Guia Rápido de Componentes, Construções & Grid (1645)
### Dicionário Oficial de Sprites e Plantas-Baixas para CorelDRAW & Godot 4

> **Como usar este guia:**  
> Ao desenhar suas plantas-baixas no CorelDRAW sobre o quadriculado (Grid), use as siglas abaixo dentro dos quadrados. Cada código indica o tipo de objeto, suas dimensões em blocos (1x1, 2x2, 3x3...) e seu comportamento físico no jogo (colisão, colheita, abrigo ou passagem).

---

## 🏛️ 1. Categoria B — Construções & Edificações (Buildings)

### ⛪ B.1 — Edifícios Religiosos & Cívicos
| Código | Nome do Componente | Tamanho (Grid) | Função & Detalhes Coloniais |
| :---: | :--- | :---: | :--- |
| **`B10`** | **Capelinha de Povoado / Ermida** | 2x2 | Pequena capela de pau-a-pique com sino único. Ponto de oração e bênção rápida. |
| **`B11`** | **Igreja Matriz Colonial** | 4x4 | Edifício imponente de taipa de pilão e pedra. Centro do Largo da Matriz de Santos. |
| **`B12`** | **Convento Franciscano / Jesuíta** | 5x5 | Convento de Santo Antônio do Valongo. Claustro de pedra, horta interna e portal da serra. |
| **`B13`** | **Casa da Câmara e Cadeia** | 3x3 | Sobrado de 2 andares: prisão no térreo com grades de ferro; câmara dos nobres no 2º andar. |
| **`B14`** | **Capela de Santa Catarina (Outeiro)** | 2x2 | Marco zero sobre o morro rochoso na beira d'água. |

---

### 🏪 B.2 — Comércio, Porto & Apoio Logístico
| Código | Nome do Componente | Tamanho (Grid) | Função & Detalhes Coloniais |
| :---: | :--- | :---: | :--- |
| **`B01`** | **Rancho de Pouso / Tapera** | 2x2 | Abrigo rústico de palha e esteios de madeira para tropeiros dormirem ao abrigo da chuva. |
| **`B02`** | **Venda de Secos & Molhados** | 2x2 | Armazém comercial: fumo de rolo, rapadura, sal, cordas e farinha de mandioca. |
| **`B03`** | **Taverna do Pescador Torto** | 3x3 | Estalagem com balcão de fórmica/madeira, mesas, quartos no sótão e fumaça de cachimbo. |
| **`B04`** | **Grande Armazém da Coroa / Alfândega** | 4x3 | Galpão fortificado de pedra colado ao cais para fiscalização de açúcar, sal e pólvora. |
| **`B05`** | **Trapiche do Porto (Píer de Madeira)** | 2x4 (ou linha) | Plataforma de pranchas sobre estacas no canal para atracar caravelas e barcaças. |
| **`B06`** | **Ferraria de Vila / Ferrador de Mulas** | 2x2 | Forja aberta, bigorna e carvão para trocar ferraduras e consertar arreios. |

---

### 🏡 B.3 — Habitações, Oficinas & Defesa
| Código | Nome do Componente | Tamanho (Grid) | Função & Detalhes Coloniais |
| :---: | :--- | :---: | :--- |
| **`B20`** | **Casa Térrea Simples** | 2x2 | Habitação de colonos e artesãos: taipa de pilão, telhado de barro colonial e porta única. |
| **`B21`** | **Sobrado de Comerciante / Feitor** | 2x3 (2 andares) | Sacadas de madeira escura no piso superior e loja comercial no piso térreo. |
| **`B22`** | **Olaria Colonial** | 3x3 | Tanques de barro e forno rústico para queima de telhas canal e tijolos crus. |
| **`B23`** | **Forno de Cal de Sambaqui** | 2x2 | Forno fumegante que queima conchas milenares para fazer argamassa de alvenaria. |
| **`B30`** | **Forte de São Felipe / Reduto de Artilharia** | 4x4 | Muralha de pedra chanfrada na beira d'água com canhões de bronze virados para o canal. |
| **`B31`** | **Guarita / Vigia de Madeira** | 1x1 | Posto elevado de vigia para sentinela com bacamarte ou arqueiro nativo. |

---

## 🌉 2. Categoria R — Vias, Trilhas & Pontes (Roads)

| Código | Nome do Componente | Tamanho | Comportamento no Jogo |
| :---: | :--- | :---: | :--- |
| **`R01`** | **Picada de Terra Batida / Areia** | 1x1 | Caminho rústico. Velocidade padrão de caminhada da tropa. |
| **`R02`** | **Calçada de Pedra do Peabiru** | 1x1 | Lajes de granito entalhadas ancestrais. **+25% de velocidade de marcha** e preserva ferraduras. |
| **`R03`** | **Ponte de Troncos Rústica** | 1x2 ou 1x3 | Dois troncos descascados lado a lado cruzando rios de mangue. Passagem estreita. |
| **`R04`** | **Ponte de Pranchas com Corrimão** | 2x3 | Ponte reforçada para cargueiros sobre rios mais largos (Rio Cubatão). |
| **`R05`** | **Pinguela Única** | 1x2 | Tronco fino e escorregadio. Animais grandes (mulas) recusam passar; exige desvio. |
| **`R06`** | **Balsa Fluvial de Tração** | 2x2 | Balsa de pranchas puxada por cabos de cipó/corda para cruzar estuários fundos. |
| **`R10`** | **Curva em Zigue-Zague (Switchback)** | Curva 2x2 | Curva fechada cavada na rocha para subir o paredão escarpado de Paranapiacaba. |

---

## 🌊 3. Categoria W — Hidrografia & Terreno Alagado (Water)

| Código | Nome do Componente | Tamanho | Comportamento no Jogo |
| :---: | :--- | :---: | :--- |
| **`W01`** | **Água Rasa / Vadeável** | 1x1 | Riacho límpido com pedras no fundo. Reduz marcha em 30%, mas é transponível a pé e a cavalo. |
| **`W02`** | **Canal Profundo / Correnteza** | 1x1 | Canal do porto ou poço de rio. Intransponível a pé; afoga quem cair sem barco. |
| **`W03`** | **Lamaçal de Mangue / Atolador** | 1x1 | Barro negro fedorento de maré. **Risco de atolar muares**. Exige empurrar barris ou usar pranchas. |
| **`W04`** | **Banco de Areia / Restingas** | 1x1 | Solo firme de areia branca perto da praia. Caminhada limpa. |
| **`W10`** | **Cachoeira do Véu (Queda d'Água)** | 2x3 | Cascata estrondosa despencando na escarpa. Esconde cavernas e baús secretos atrás da cortina! |
| **`W11`** | **Bica de Pedra / Olho d'Água** | 1x1 | Água doce potável cristalina. Enche cantis e recupera sede da tropa. |

---

## 🌳 4. Categoria T — Flora, Bosques & Agricultura (Trees)

| Código | Nome do Componente | Tamanho | Comportamento no Jogo |
| :---: | :--- | :---: | :--- |
| **`T01`** | **Samambaiaçu / Capim Navalha** | 1x1 | Vegetação rasteira. **Sem colisão** (o personagem caminha por cima sem travar). |
| **`T02`** | **Árvore Pequena (Figueira / Canela)** | 1x1 (base) | Bloqueia colisão no tronco (1m²); copa de 2 metros passa por cima do herói via Y-Sort. |
| **`T03`** | **Árvore Frutífera / Pomar Doméstico** | 1x1 | Jabuticabeira, maracujá ou goiaba. **Interativa:** pressione [E] para colher frutos nutritivos. |
| **`T04`** | **Bambuzal Fechado** | 1x1 | Bambus grossos entrelaçados. Bloqueia passagem; exige corte com o *Facão de Três Listras*. |
| **`T05`** | **Raízes de Mangue-Vermelho** | 1x1 | Raízes aéreas em arcos entrelaçados sobre a lama. |
| **`T06`** | **Bananeiras de Quintal** | 1x1 | Touceira de folhas largas comuns nos fundos das casas de Santos. |
| **`T10`** | **Jequitibá-Rei / Sumaúma Monumental** | 3x3 (base) | Árvore sagrada milenar. Raiz tabular monumental (9m² de colisão) e copa colossal de 7 metros. |
| **`T11`** | **Araucária de Serra** | 2x2 (base) | Pinheiro-do-paraná marcando a transição do topo da serra para o clima frio de Piratininga. |

---

## 🪨 5. Categoria S — Relevo, Rochas & Arqueologia (Stone)

| Código | Nome do Componente | Tamanho | Comportamento no Jogo |
| :---: | :--- | :---: | :--- |
| **`S01`** | **Seixo / Pedra Solta de Trilha** | 1x1 | Obstáculo cosmético ou projétil para atirar com funda/estilingue. |
| **`S02`** | **Matacão de Granito de Encosta** | 2x2 | Rocha colossal rolada da serra. Excelente para cobertura tática contra tiros de arcabuz. |
| **`S03`** | **Paredão Escarpado de Paranapiacaba** | Faixa sólida | Abismo ou paredão de granito intransponível. Delimita as bordas do mapa. |
| **`S04`** | **Boqueirão / Precipício Mortal** | 1x1 borda | Queda no abismo. Falha na rolagem de agilidade causa perda de carga ou morte da mula. |
| **`S10`** | **Sambaqui Ancestral de Conchas** | 3x3 a 5x5 | Colina cerimonial milenar de conchas e cerâmicas. Local sagrado; queimações atraem espíritos. |
| **`S11`** | **Canteiro de Terra Preta de Índio** | 2x2 | Solo fértil negro arqueológico. Descanso sobre ela recupera vigor e cura enfermidades. |

---

## ✨ 6. Categoria E — Eventos, Adereços & Misticismo (Events)

| Código | Nome do Componente | Tamanho | Interação de Gameplay |
| :---: | :--- | :---: | :--- |
| **`E01`** | **Fogueira de Rancho / Brasas de Pouso** | 1x1 | **Interativo:** Pressione [E] para descansar, cozinhar feijão tropeiro e restaurar 100% de vida. |
| **`E02`** | **Baú de Ferro Trancado / Bruaca Caída** | 1x1 | **Interativo:** Pressione [E] para abrir e saquear mantimentos, munição ou patacas de prata. |
| **`E03`** | **Altar do Bambuzal da Caipora** | 1x1 | **Interativo:** Deixar oferenda de *Fumo de Rolo*. Concede bênção da mata e +25% de afinidade da mula. |
| **`E04`** | **Pelourinho de Pedra da Vila** | 1x1 | Marco no centro da praça de Santos. Lugar de avisos de capitães-do-mato e ordens da Coroa. |
| **`E05`** | **Cruzeiro de Pedra da Serra (1645)** | 1x1 | Cruz colossal no cume de Paranapiacaba. Salva o jogo e contempla a vista panorâmica do Planalto. |
| **`E06`** | **Cacimba / Poço d'Água de Pedra** | 1x1 | Fonte de água nos quintais e praças. |
| **`E07`** | **Curral de Muares com Porteira** | 3x3 | Cercado de madeira rústica para descanso e pasto dos animais de tropa. |
| **`E10`** | **Ponto de Emboscada de Salteadores** | Gatilho | Área invisível: pisou, aciona emboscada de capangas armados com facões e pederneiras. |
| **`E11`** | **Ninho de Fogo-Fátuo / Assombro** | Gatilho | Área mística: luz azulada que persegue a tropa na escuridão. Exige teste de Misticismo. |

---

## 🎨 Exemplo Visual de Aplicação no Grid do Corel:

Quando você montar o vilarejo e a estrada no Corel, a folha de desenho vai ficar com essa clareza visual:

```text
[S03][S03][S03][R02][S03][S03]  ➔ Subida da serra (Calçada do Peabiru entre paredões)
[   ][T04][E03][R02][   ][   ]  ➔ Bambuzal com Altar da Caipora na beira da estrada
[W01][W01][R03][R03][W01][W01]  ➔ Travessia do rio com ponte de troncos rústica
[   ][   ][R01][   ][   ][   ]  ➔ Picada contornando o mangue
[   ][B12][B12][R01][B01][   ]  ➔ Convento do Valongo e rancho de mulas na saída
[B20][B20][   ][R01][B02][B02]  ➔ Casas térreas e venda de secos & molhados
[B20][   ][E04][   ][B11][B11]  ➔ Largo da Matriz com o Pelourinho e a Igreja
[B03][B03][   ][B04][B04][B04]  ➔ Taverna do Pescador Torto e Armazém da Alfândega
[B05][B05][W01][W01][W01][W01]  ➔ Trapiche do porto sobre as águas do canal
```

> 📌 **Dica de Ouro:** Com este arquivo salvo no seu Obsidian, basta deixar essa nota aberta no painel lateral enquanto trabalha no CorelDRAW!
