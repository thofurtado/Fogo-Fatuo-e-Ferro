# ⚔️ FOGO FÁTUO & FERRO — Documento de Visão e Escopo (GDD)

### 1. Visão Geral do Jogo

* **Título:** *Fogo Fátuo & Ferro*
* **Gênero:** RPG mobile-first, tático e de sobrevivência com foco em narrativa histórica e elementos de dark fantasy/folclore.
* **Premissa:** Ambientado no Brasil colonial em **1645 (Insurreição Pernambucana)**, o jogo explora o choque brutal entre a colonização, o ferro, a pólvora e as forças místicas/folclóricas da terra.
* **Abordagem de Jogabilidade:** Focado em experiências para uma mão (*one-handed*), navegação estratégica e alta penalidade por morte, fugindo de facilitadores modernos.

---

### 2. Identidade Visual (Sistema Dual)

O jogo utiliza dois estilos visuais bem marcados para separar momentos narrativos de momentos de exploração:

* **Modo Quadrinhos / Cutscenes (Decisões e Diálogos):** Estilo de xilogravura e nanquim em preto e branco de alto contraste (pesadamente inspirado no traço clássico de *Flavio Colin*), focado em hachuras, sombras profundas e atmosfera dramática de revista de época.
* **Modo Exploração (Mundo Aberto e Telas de Menu):** Estilo de arte vibrante, limpo e expressivo inspirado na estética de HQs clássicas brasileiras (como *Ziraldo / Turma do Pererê* e *Mauricio de Sousa*), trazendo cores vivas e identidade para a interface e caminhada no mapa.

---

### 3. Escopo Técnico e Interface (Mobile-First)

* **Proporção:** Foco estrito na vertical (**9:16**). Versões de PC/Navegador utilizam as barras laterais vazias para fichas de personagem e inventário.
* **Câmera e Mapa:** Visão isométrica/ortográfica top-down (*zoomed-out*), exibindo uma matriz ampla de cerca de 15 a 20 blocos de largura no modo exploração. Isso garante visão panorâmica, liberdade tática e menor detalhamento micro dos sprites.
* **Escala de Unidades (Grid Métrico / m³):**
  - **Humanoides (Personagens / Inimigos):** 1m x 1m base | 2m de altura (2 blocos verticais).
  - **Vegetação Padrão:** 1m x 1m base | 3m de altura.
  - **Vegetação Monumental (Árvores Centenárias):** 3m x 3m (9m²) base | 5m a 7m de altura.
* **Fluxo de Criação (Modular):** Menus divididos por telas sequenciais e intuitivas para o polegar:
  1. *Origem Étnico-Cultural* (A raiz ancestral e a relação mística com a terra).
  2. *Condição Social & Status Legal* (O status perante a lei colonial de 1645: Livre, Fugitivo, Degredado, etc.).
  3. *Região de Partida (As 6 Macro-Regiões)*:
     - **Nordeste Açucareiro:** Alta densidade urbana/militar, engenhos e guerra.
     - **Sertão Nordestino:** Bioma árido, distâncias médias, pecuária extensiva.
     - **Planalto de Piratininga:** O coração vicentino, ponto de partida de expedições.
     - **Litoral e Rotas de Serra:** Trilhas costeiras, encostas, escoamento mercante e portos.
     - **Pantanal e Rios Centrais:** Terreno híbrido (água/terra), isolamento fluvial.
     - **Sul e Bacia do Prata:** Grandes planícies, missões jesuíticas e fronteiras.
  4. *Ofício e Sobrevivência* (A profissão prática, ferramentas e habilidades ativas).
  5. *Traços, Bênçãos e Fobias* (Modificadores pessoais e sobrenaturais).

---

### 4. Regras de Sobrevivência e Progressão

* **Sem Checkpoints Mágicos:** O jogo não possui salvamento instantâneo nas missões. Morreu? O personagem retorna obrigatoriamente para a sua região de nascimento ou para o último **Totem de Salvamento** ativado, exigindo que o jogador refaça a jornada física pelo mapa.
* **O Papel do Folclore:** As entidades místicas (Curupira, Caipora, etc.) **não** são personagens jogáveis nem aceitam modificação de atributos; elas funcionam como forças da natureza, patronos, ameaças ou aliados misteriosos que reagem às escolhas dos mortais.
* **Arquétipos e Variedade de Personagens:** O jogador escolhe sua trajetória combinando sua história de berço (como povos originários, afro-descendentes, colonizadores portugueses ou desertores europeus) com ofícios dinâmicos (como o **Tropeiro**, que garante trânsito livre por rotas comerciais e o mapa expandido).
