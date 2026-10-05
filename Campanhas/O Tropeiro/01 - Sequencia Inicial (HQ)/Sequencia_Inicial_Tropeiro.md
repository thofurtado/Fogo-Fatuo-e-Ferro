# 🎬 Campanha do Tropeiro: Sequência Inicial (HQ / Storyboard)

> **Protagonista:** O Tropeiro & Sua Mula de Carga  
> **Marco Histórico:** 1645 (Insurreição Pernambucana / Tensões Coloniais)  
> **Local de Partida:** Porto de Santos / Sopé da Serra do Mar (Capitania de São Vicente)  
> **Estilo Gráfico:** Nanquim & Xilogravura de Alto Contraste (estilo Flávio Colin) com legendas em caixas de rodapé clássicas de HQ.

---

## 📐 Guia Rápido para os Desenhos no CorelDRAW

Para manter a consistência e facilitar a importação direta para o Godot e Obsidian:
* **Proporção Recomendada:** 9:16 vertical (para tela mobile em pé) ou prancha de gibi com quadros verticais.
* **Formato de Exportação:** PNG ou JPG (alta resolução, RGB).
* **Pasta de Destino das Imagens:** `Campanhas/O Tropeiro/01 - Sequencia Inicial (HQ)/Imagens/`
* **Padrão de Nomenclatura Sugerido:**
  * `tropeiro_intro_p01.png`
  * `tropeiro_intro_p02.png`
  * `tropeiro_intro_p03.png` ...

---

---

## 🗺️ Etapa 0: A Tela de Seleção de Origem (Mapa-Múndi Cartográfico)

Esta é a primeira tela interativa que abre a construção de personagem e define a raiz da campanha. O visual utiliza a moldura cartográfica entalhada e mapa em pergaminho antigo de 1645.

![[mapamundi_selecao_origem.jpg]]

### 🧭 Os 3 Continentes Selecionáveis:

1. **🇧🇷 América do Sul (Brasil Colonial):**
   * **Ícone no Mapa:** Estandarte colonial com a **Cruz da Ordem de Cristo** e aura iluminada em dourado.
   * **Texto do Rodapé ao Clicar:**
     > *"Ano de 1645. Nas terras de Santa Cruz, o sangue dos povos originários e dos mestiços da terra desafia as picadas da serra e as entidades milenares da mata."*
   * **Próxima Tela:** Escolha entre **Tropeiro Paulista**, **Caboclo da Terra** ou **Nativo Batedor (Curumim)**.

2. **👑 Continente Europeu:**
   * **Ícone no Mapa:** Estandarte heráldico com brasão real de armas.
   * **Texto do Rodapé ao Clicar:**
     > *"Das cortes e frotas do Velho Mundo chegam os homens do ferro, da pólvora e da fé, buscando fortuna, redenção ou fuga no além-mar."*
   * **Próxima Tela:** Escolha entre **Explorador Português**, **Soldado Espanhol** ou **Mercenário/Desertor Flamengo (WIC)**.

3. **🛡️ Continente Africano:**
   * **Ícone no Mapa:** Estandarte entalhado com escudo e máscara tribal guerreira.
   * **Texto do Rodapé ao Clicar:**
     > *"Trazidos pelas correntes do Atlântico sob o jugo dos grilhões, guerreiros, ferreiros sagrados e líderes ancestrais constroem a liberdade nos quilombos."*
   * **Próxima Tela:** Escolha entre **Guerreiro Quilombola / Fugitivo**, **Ferreiro Ancestral** ou **Líder Comunitário**.

---

## 🎞️ Decupagem da Sequência Narrativa (HQ / Prólogo do Tropeiro)

Após a escolha da classe **Tropeiro**, a história engata na sequência em quadrinhos de introdução:

### 📄 Página 01: O Cenário & O Porto de Santos
* **Arquivo da Imagem:** `![[tropeiro_intro_p01.jpg]]`
* **Legenda no Rodapé (Estilo Flavio Colin):**
  > *"Ano do Senhor de 1645. Enquanto o Norte queima em pólvora holandesa, no sopé da serra paulista o peso do ferro e do sal move a vida dos homens sem terra."*
* **Áudio / Trilha Sugerida:** Som de ondas calmas no cais de Santos, gaivotas distantes e o sino tosco de uma capela ao longe.
* **Notas de Direção:** Visão panorâmica do ancoradouro, fardos de carga, marinheiros e o paredão imponente e escuro da Serra de Paranapiacaba coberto por mormaço ao fundo.

---

### 📄 Página 02: A Apresentação da Dupla (O Tropeiro & A Mula Bonita)
* **Arquivo da Imagem:** `![[tropeiro_intro_p02.jpg]]`
* **Legenda no Rodapé:**
  > *"Tião Caboclo mascava um talo de capim-santo encostado ao mourão de amarra. A algibeira trazia apenas vento e réis gastos de cobre, mas ao seu lado, as orelhas compridas da mulinha Bonita bufavam prontas para mais um paredão de serra."*
* **Áudio / Trilha Sugerida:** Relincho carinhoso da mula, estalo do basto de couro cru e o bufo do animal cheirando o braço do tropeiro.
* **Mecânica Central de Comitiva:** A mula **Bonita** acompanha Tião em 100% da exploração. Possui o medidor vivo de **Afinidade com a Mula** (que dita a tolerância à carga, aviso de emboscadas e resolução de quebra-cabeças).

---

### 📄 Página 03: A Taverna do Pescador Torto & A Bandeja de Rolagem de Dados
* **Arquivo da Imagem:** `![[tropeiro_intro_p03.jpg]]`
* **Cena no Godot:** `res://Scenes/PrologoTropeiro.tscn` (com componente `res://Scenes/DiceTray.tscn`)
* **Legenda no Rodapé / Janela do Mestre:**
  > *"O salão está esfumaçado e cheio de sussurros. Role teus dados na bandeja de couro para ver o que teus olhos de tropeiro conseguem discernir entre as sombras da taverna."*
* **🎲 Teste no HUD (Sistema B.A.N.D.E.I.R.A. / Storyteller):**
  > 🎯 **`[TESTE DE PERCEPÇÃO: INSTINTO (3) + NAVEGAÇÃO (5) = 8 D10s — DIFICULDADE 6]`**  
  > *Os 8 dados de osso quicam dinamicamente pelas bordas da bandeja de couro com física 2D, colisões elásticas e rotações até assentarem nos resultados finais.*

* **🏆 As 3 Revelações Dinâmicas de Acordo com o Resultado dos Dados:**
  1. **💀 Resultado Ruim / Falha (0 Sucessos Finais ou Falha Crítica):**
     * **Narrativa:** A fumaça arde nos olhos de Tião e o burburinho o atordoa. Ele esbarra na mesa dos fundos e chama a atenção de **Baltazar 'Perna de Pau'** — notório contrabandista do descaminho ligado a revoltosos holandeses.
     * **Carga Revelada:** `Caixotes de Ferro & Pólvora Holandesa` (A que traz mais complicações: 65 arrobas, risco 5/5 com patrulhas da Coroa, hostilidade de espíritos da mata pelo cheiro de pólvora e ferro).
  2. **⚖️ Bom Resultado (1 a 2 Sucessos Finais):**
     * **Narrativa:** O olhar experiente de tropeiro ignora as distrações e localiza o **Feitor Gaspar** da Fazenda Real no balcão, conferindo listas com o selo real da Capitania de São Vicente.
     * **Carga Revelada:** `Sacas de Sal & Charque` (A mais segura: pagamento limpo e garantido pela Câmara, salvo-conduto oficial da guarda, risco 1/5).
  3. **✨ Sucesso Absoluto (3+ Sucessos Finais):**
     * **Narrativa:** O instinto afiado lê o salão inteiro num relance! Tião identifica **Frei Lourenço** da Companhia de Jesus no reservado dos fundos, escoltando caixas com relíquias e fumo aromático de oferenda — a opção mais rentável e abençoada!
     * **Carga Revelada:** `Fumo de Rolo & Relíquias Sagradas` (Carga leve de 15 arrobas, pagamento em patacas de prata e oferenda automática para as entidades da floresta).
     * **📜 BOATO SECRETO OUVIDO NA MESA AO LADO (EXCLUSIVO!):**
       > *« Tião ouve dois marinheiros bêbados no balcão sussurrarem: "— ...juro pela Virgem! Na subida de Paranapiacaba, antes da Garganta das Águas, há uma fenda escondida atrás do salto d'água da Cachoeira do Véu... Um capitão bandeirante escondeu um baú de ferro enterrado cheio de patacas ali antes de morrer!" »*
       > *(Ativa no `GameManager.boato_cachoeira_descoberto = true`, permitindo abrir o baú secreto atrás da cascata na cena jogável `SubidaSerra.tscn`!)*

---

### 📄 Página 04: A Grande Decisão da Partida
Após fechar o frete, a interface apresenta 3 caminhos de partida ao jogador:

1. **🌅 Descansar no estábulo e partir logo ao raiar do dia:**
   * Tião alimenta a Bonita com milho e palha fresca e descansa ao som do mar.
   * **Inicia no Modo Exploração de Dia:** Cores vibrantes estilo gibi/Maurício, visão límpida sem neblina.
   * **Bônus:** +Vigor temporário (HP extra) e **+1 Ponto de Afinidade com a Mula** (a Bonita anda rápida e disposta!).
2. **🌙 Carregar a mula e subir a serra agora mesmo, na calada da noite:**
   * *"Quem tem pressa não espera o sol."* Tião amarra as bruacas e acende um tição de resina.
   * **Inicia no Modo Exploração à Noite:** Neblina espessa da serra (*mormaço*), campo de visão reduzido ao círculo da tocha, penalidade de percepção.
   * **Vantagem Tática:** Passa direto pelo posto fiscal da Coroa sem pagar pedágio colonial!
3. **🕯️ Esperar mais um gole e ouvir o causo do Mestre Bento (A Caipora):**
   * O taverneiro revela que a **Caipora** ronda os bambuzais da encosta punindo quem desrespeita a mata, e ensina o segredo de deixar oferenda de **Fumo de Rolo** na forquilha das árvores.
   * Libera a compra de fumo de oferenda antes da partida e o segredo de sobrevivência folclórica!

---

### 📄 Página 05: O Pé na Estrada & O Mistério da Serra
* **Arquivo da Imagem:** `![[tropeiro_intro_p04.png]]`
* **Áudio / Trilha Sugerida:** Trovoada abafada no cume da serra, vento nas folhagens e o primeiro brilho azul de fogo-fátuo entre os galhos.
* **Transição:** Corte seco para o **Rancho do Pé da Serra**, onde se inicia o modo jogável de exploração e quebra-cabeças com a mula (estilo *Goofy Troop*).

