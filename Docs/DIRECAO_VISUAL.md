# Direção Visual — Fogo-Fátuo & Ferro

**Status:** proposta de consolidação, v0.1
**Escopo:** identidade visual geral; não altera nem substitui os assets existentes.

## Princípio de direção

**Uma aventura brasileira de quadrinhos, colorida e legível à primeira vista, atravessada por uma narrativa de xilogravura áspera.** A natureza deve parecer viva e antiga; o ferro, pesado e invasivo; o sobrenatural, belo o bastante para atrair e estranho o bastante para inquietar.

A identidade se organiza em dois registros já descritos no [GDD de visão](GDD_VISAO_GERAL.md):

1. **Narrativa, diálogos e cutscenes — nanquim/xilogravura:** preto, branco e papel; contraste alto; sombras em hachura; enquadramentos de página de gibi; ritmo dramático. A referência a Flávio Colin orienta o contraste e a gravidade, não uma cópia literal do traço.
2. **Exploração, menus e leitura do mundo — gibi brasileiro colorido:** desenho de contorno limpo e expressivo, formas simplificadas e cores vivas sobre uma base terrosa. Manter a personalidade de HQ nacional sem transformar o elenco ou o folclore em caricatura infantil.

## Gramática visual compartilhada

- **Contorno:** nanquim escuro, espesso o bastante para sobreviver à escala de celular; variar o peso para separar silhueta, plano e detalhe.
- **Forma:** silhuetas reconhecíveis antes dos detalhes. Personagens principais seguem a proporção de cerca de **3,5 cabeças** registrada nas folhas de conceito; postura e expressão são firmes, calmas ou vigilantes, nunca cômicas por padrão.
- **Textura:** hachura, pontilhado, papel e marcas de impressão aparecem com intenção — sobretudo em cutscenes, mapas e superfícies — sem cobrir informação de jogo.
- **Materiais narrativos:** papel, madeira, couro, barro e ferro podem inspirar molduras, placas e painéis. A interface deve parecer parte do mundo, não um HUD genérico de fantasia.
- **Coerência entre modos:** conservar personagens, símbolos, proporções e códigos de cor nos dois registros; muda a técnica de representação, não a identidade do mundo.

## Paleta de trabalho

A paleta-base já aparece em [TILEMAP_RPG_GIBI.md](TILEMAP_RPG_GIBI.md). Tratar os códigos abaixo como tokens iniciais a validar contra os assets, não como uma nova obrigação de recolorir tudo.

| Uso | Cor de referência | Função |
|---|---|---|
| Tinta / contorno | `#171916` | Silhuetas, texto e contraste estrutural |
| Papel / luz quente | `#DEC085` | Pergaminho, trilha clara, áreas de leitura |
| Mata viva | `#4E9B3D` | Vegetação legível durante a exploração |
| Mata em sombra | `#2E6822` | Profundidade e bloqueio visual |
| Terra / rota | `#C28B52` | Caminhos, poeira e superfícies quentes |
| Barro e ferro oxidado | `#8C5329` / `#BA4829` | Construções, couro, perigo físico e desgaste |
| Água profunda | `#1A3B4D` | Brejo, noite e zonas de risco |
| Fogo-fátuo | `#2DD8C1` | Sinal sobrenatural e foco de navegação |
| Contraste místico | `#3F2263` | Sombra anômala, usado com parcimônia |

O fogo-fátuo pode combinar núcleo turquesa com pequenas bordas de brasa alaranjada, como sugerem os conceitos existentes. Não usar ciano como cor decorativa genérica: ele deve sinalizar fenômeno ou interação sobrenatural.

## Personagens, criaturas e cenários

- **Personagens jogáveis:** leitura imediata por silhueta, roupa, ferramenta e postura. Distinguir os arquétipos por materiais e acessórios — arco e fibras, corrente rompida, metal e pólvora, objetos de devoção, bruacas e carga — sem depender de texto para reconhecê-los.
- **Folclore:** tratar entidades como forças da mata, não mascotes. O Curupira, a Caipora e a Mula sem Cabeça podem ter contornos atraentes e expressivos, mas devem preservar presença, escala e tensão. O fogo azul/verde e o ferro em brasa são sinais visuais raros e fortes.
- **Mundo:** cada região precisa de uma assinatura ambiental própria (vegetação, relevo, água, arquitetura e clima), mantendo a mesma espessura de linha e o mesmo sistema de leitura. Evitar que toda mata vire o mesmo bloco de verde.
- **Exploração modular:** a especificação de 32×32 px, base dos objetos, copas separadas e ordenação por profundidade de [TILEMAP_RPG_GIBI.md](TILEMAP_RPG_GIBI.md) serve como regra de produção para o mundo caminhável. Reservar hachura e microdetalhe para elementos grandes; em tiles pequenos, priorizar massa, contraste e borda legível.

## Interface e composição mobile

- **Formato principal:** retrato 9:16; o projeto já trabalha próximo dessa proporção em `project.godot`. Projetar primeiro para toque com uma mão e textos curtos.
- **Hierarquia:** personagem e rota antes dos adornos; diálogos e escolhas com contraste alto; controles próximos das zonas alcançáveis pelo polegar; informações secundárias podem ocupar áreas laterais em telas largas.
- **Acabamento:** painéis com cantos e bordas mais firmes, aparência de papel, madeira ou chapa, e poucos ornamentos repetidos. Substituir emojis usados como placeholders por pictogramas desenhados quando os ícones entrarem em produção.
- **Tipografia:** priorizar legibilidade e hierarquia de pesos/tamanhos; não trocar a família de fonte principal sem decisão explícita do projeto. Evitar fontes decorativas em parágrafos, diálogos longos e dados de combate.
- **Acessibilidade:** não codificar vida, perigo ou seleção apenas pela cor; somar forma, ícone, posição ou rótulo. Conferir textos e alvos de toque no tamanho real de tela.

## Combate: compatibilizar as referências

O quadro [Estilos Visuais.canvas](../Estilos%20Visuais.canvas) menciona *Super Mario World* para o combate e uma rolagem de dados sobreposta; o guia de tilemap cita RPGs de 16 bits. Para não criar um terceiro estilo incompatível com o sistema dual do GDD, esta proposta usa essas referências pela **clareza de leitura, escala de tile e ritmo da ação**, mantendo contorno e paleta do mundo de exploração. Dados e resultados podem surgir como uma camada de papel/tinta ou ferro gravado, sem cobrir a ação nem converter toda a batalha em pixel art.

Se a intenção for que o combate seja realmente pixel art separado, isso deve ser decidido antes de produzir sprites e animações — não inferido apenas da referência no canvas.

## Transição entre registros

A passagem da cutscene monocromática para a exploração colorida pode acontecer por um detalhe recorrente — uma brasa, um traço turquesa ou uma marca no papel — que ganha cor e se torna elemento do mundo. O restante da cena permanece em preto e branco até a transição, preservando o contraste dramático do GDD.

## Critérios de consistência

Antes de aprovar uma nova peça visual, conferir: **(1)** lê bem em 9:16 e em miniatura; **(2)** sua silhueta funciona sem textura; **(3)** pertence claramente ao registro narrativo ou ao de exploração; **(4)** usa cor sobrenatural só quando há motivo diegético; **(5)** mantém expressão séria e respeitosa; **(6)** combina com os assets já existentes em linha, escala e contraste.

## Base consultada

- [GDD de visão geral](GDD_VISAO_GERAL.md)
- [Guia de tilemap e gibi](TILEMAP_RPG_GIBI.md)
- [Quadro de referências visuais](../Estilos%20Visuais.canvas)
- `Assets/Backgrounds/poster_capa.jpg`, `hq_prologo.jpg`, `mata_dia.jpg` e `mata_noite.jpg`
- `Assets/Sprites/tropeiro_mula_concept_sheet.jpg`, `mula_sem_cabeca_estilo_gibi.jpg` e `mapa_brasil_regioes.jpg`
