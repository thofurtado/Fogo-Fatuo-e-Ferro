# Direção Visual — Fogo-Fátuo & Ferro

**Status:** direção confirmada pelo usuário
**Decisão central:** quadrinhos/xilogravura nas cutscenes; pixel art 16-bit nas partes jogáveis.

## Princípio de direção

**Um RPG brasileiro de sobrevivência cuja narrativa parece uma página impressa de gibi e cujo mundo jogável ganha vida como um RPG 16-bit.** A mata é viva e antiga; o ferro é pesado e invasivo; o sobrenatural atrai e inquieta.

A mudança de técnica visual acompanha a função da cena. Personagens, símbolos, materiais e identidade permanecem reconhecíveis ao passar de uma linguagem para a outra.

## Dois registros visuais

### Cutscenes e diálogos — quadrinhos/xilogravura

- Preto, branco e papel; contraste alto, nanquim, hachuras e sombras profundas.
- Enquadramento de página de gibi, ritmo de painéis e expressões claras, com gravidade dramática.
- Referências brasileiras de quadrinhos guiam a energia e a expressividade; a xilogravura dá peso histórico e tensão ao prólogo.
- A cor pode aparecer apenas como acento de transição quando a cena passa ao jogo — por exemplo, uma chama de fogo-fátuo que ganha cor. A cena narrativa permanece majoritariamente monocromática.

### Partes jogáveis — pixel art 16-bit

- A exploração, mapas navegáveis e combate usam a mesma linguagem pixelada top-down; o combate não vira um terceiro estilo.
- Compor o mundo com tiles legíveis, silhuetas claras, clusters de pixels e animações econômicas. O guia de tilemap registra 32×32 px como base de produção.
- Priorizar leitura à escala de celular: personagem, obstáculos, rota e perigos devem ser distinguíveis sem depender de microdetalhes.
- As referências de RPGs 16-bit orientam escala, ritmo e clareza, sem copiar personagens, tiles ou telas de jogos existentes.
- Menus navegáveis, HUD, inventário e seleção de regiões acompanham o pixel art. Papel, madeira, couro e ferro podem aparecer nas molduras e ícones, sem inserir quadros ilustrados de gibi dentro do campo de jogo.

## Gramática compartilhada

- **Silhueta:** cada personagem ou criatura precisa continuar reconhecível nas versões de cutscene e de gameplay. As folhas existentes usam cerca de **3,5 cabeças** como proporção de referência para personagens principais.
- **Materiais:** distinguir fibra, madeira, tecido, couro, barro e ferro pela forma e por pequenas áreas de cor; não depender de textura minúscula.
- **Motivo recorrente:** o contraste entre Fogo-Fátuo e Ferro organiza a cor, a iluminação, os efeitos e os símbolos de interface.
- **Expressão:** protagonistas firmes, calmos ou vigilantes; entidades folclóricas misteriosas e ameaçadoras, não mascotes cômicos.
- **Continuidade:** manter figurino, acessórios, proporções e cores-chave entre sprites e ilustrações de cutscene; muda o meio, não a identidade do personagem.

## Paleta de trabalho

Os códigos abaixo vêm do [guia de tilemap](TILEMAP_RPG_GIBI.md) e são referências iniciais para o gameplay pixelado, a validar contra os assets existentes.

| Uso | Cor de referência | Função |
|---|---|---|
| Tinta / sombra profunda | `#171916` | Contorno em pixels, silhueta e contraste |
| Papel / luz quente | `#DEC085` | Interfaces, trilha clara e áreas de leitura |
| Mata viva | `#4E9B3D` | Vegetação durante a exploração |
| Mata em sombra | `#2E6822` | Profundidade e bloqueio visual |
| Terra / rota | `#C28B52` | Caminhos, poeira e superfícies quentes |
| Barro / ferro oxidado | `#8C5329` / `#BA4829` | Construções, couro, metal gasto e perigo físico |
| Água profunda | `#1A3B4D` | Brejo, noite e zonas de risco |
| Fogo-fátuo | `#2DD8C1` | Sinal sobrenatural e foco de navegação |
| Contraste místico | `#3F2263` | Sombra anômala, usado com parcimônia |

O fogo-fátuo pode combinar núcleo turquesa com pequenas bordas de brasa alaranjada, como sugerem os conceitos existentes. Ciano não deve ser uma cor decorativa genérica: indica fenômeno ou interação sobrenatural.

## Mapas, telas e leitura mobile

- **Mapa de exploração:** pixel art top-down com trilhas e marcos ambientais claros. A especificação técnica de 32×32 px, base dos objetos, copas separadas e ordenação por profundidade continua como referência de implementação.
- **Mapa regional navegável:** tratado como tela de jogo pixelada, com regiões, rotas e seleção legíveis. Um mapa ilustrado em papel/xilogravura pertence a uma cutscene ou peça narrativa, não à tela interativa.
- **Combate:** cenário, atores e efeitos em pixel art 16-bit. Dados e resultados podem aparecer em moldura de papel/tinta ou ferro gravado, com contraste suficiente e sem esconder o campo de ação.
- **Menus e HUD:** priorizar personagem, rota, estado e escolha antes dos ornamentos; botões e alvos de toque adequados a uma mão em 9:16.
- **Tipografia e acessibilidade:** preservar a família de fonte principal do projeto salvo decisão explícita; usar tamanhos e contrastes legíveis. Vida, perigo e seleção não devem depender apenas da cor.

## Personagens em dois meios

Cada personagem principal tem uma representação de gameplay em pixel art 16-bit e uma versão ilustrada para cutscenes quando a narrativa precisar de close, gesto ou expressão. Manter nos dois meios as mesmas âncoras visuais — chapéu, poncho, facão e bruacas para o Tropeiro; forma equina, correntes, fogo-fátuo e cascos em brasa para a Mula sem Cabeça — ajustando o detalhe à escala de cada meio.

As entidades folclóricas são forças da mata e devem preservar presença e tensão. Representações de povos e grupos históricos devem evitar caricaturas e manter dignidade, contexto e distinção entre arquétipos.

## Critérios de consistência

Antes de aprovar uma peça visual, conferir: **(1)** está no registro correto — quadrinhos para cutscene ou pixel art para gameplay; **(2)** lê bem em 9:16 e em miniatura; **(3)** a silhueta funciona sem textura; **(4)** o código de cor do sobrenatural tem motivo diegético; **(5)** personagem e criatura mantêm identidade entre meios; **(6)** a interface não cobre rota, personagem ou ação.

## Base consultada

- [GDD de visão geral](GDD_VISAO_GERAL.md)
- [Guia de tilemap](TILEMAP_RPG_GIBI.md), com adendo de linguagem visual 16-bit
- [Quadro de referências visuais](../Estilos%20Visuais.canvas)
- `Assets/Backgrounds/poster_capa.jpg`, `hq_prologo.jpg`, `mata_dia.jpg` e `mata_noite.jpg`
- `Assets/Sprites/tropeiro_mula_concept_sheet.jpg`, `mula_sem_cabeca_estilo_gibi.jpg` e `mapa_brasil_regioes.jpg`
