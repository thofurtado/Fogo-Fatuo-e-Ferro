# 📜 Matriz Modular de Criação de Personagem & Prólogos Dinâmicos (1645)

Este documento estabelece as regras de game design, a arquitetura de dados para programação e o guia narrativo para o sistema modular de personagens de **Fogo-Fátuo & Ferro**.

---

## 1. A Filosofia do Sistema: A Grande História com Prólogos Únicos

A grande trama do jogo é uma só: **a terra sangra sob o choque bélico de 1645 (Insurreição Pernambucana), despertando a ira primordial do Fogo-Fátuo e das entidades da mata perante o avanço da pólvora e do ferro.**

Porém, a jornada de cada jogador começa em um ponto de vista completamente diferente, determinado pelas suas 4 escolhas fundamentais:

```
    [ 1. ORIGEM ]          -> Quem são seus antepassados e sua relação espiritual com a terra
          ↓
  [ 2. CONDIÇÃO SOCIAL ]   -> Seu status perante a lei colonial (Livre, Fugitivo, Degredado...)
          ↓
  [ 3. REGIÃO NO MAPA ]    -> Seu berço geográfico, clima local e Totem de Respawn
          ↓
     [ 4. OFÍCIO ]         -> Suas ferramentas de sobrevivência, perícias e papel prático
```

---

## 2. A Arquitetura Modular (Para o Thomás Programar)

Para evitar que a equipe enlouqueça tentando balancear centenas de combinações manuais, o sistema funciona por **composição aditiva de dicionários (Tags & Modificadores)**.

### A Fórmula dos Atributos:
$$\text{Atributo Final} = \text{Base da Origem} + \text{Modificador de Condição} + \text{Bônus do Ofício}$$

### Atributos Base:
* **Força (FOR):** Vigor físico, combate corpo a corpo, carregar peso.
* **Destreza (DES):** Furtividade, pontaria com flechas/arcabuz, agilidade na mata.
* **Lábia (LAB):** Negociação comercial, persuasão, intimidação, diplomacia.
* **Misticismo (MIS):** Sintonia com entidades, rituais, sensibilidade ao sobrenatural.
* **Vida Máxima (HP):** Tolerância a dano físico.
* **Espírito / Mana (MP):** Energia mágica, resistência a maldições e bênçãos.

---

## 3. Os 4 Pilares da Ficha

### Pilar 1: Origem Étnico-Cultural (As Raízes)
Define a cosmovisão do herói e como o sobrenatural reage a ele:

1. **Povos Originários da Costa (Ex: Tupi/Tabajara):**
   * *Bônus:* +2 Misticismo, +1 Destreza.
   * *Passiva Cultural:* Entende os sinais das aves e a linguagem das águas.
2. **Povos do Sertão Bruto (Ex: Tapuias/Cariris):**
   * *Bônus:* +2 Força, +1 Misticismo.
   * *Passiva Cultural:* Resistência natural à sede e veneno de peçonha.
3. **Afro-Atlântico (Bantos e Iorubás):**
   * *Bônus:* +2 Força, +1 Lábia.
   * *Passiva Cultural:* Sabedoria dos ancestrais além-mar e forja sagrada.
4. **Luso-Brasileiro da Terra (Mestiço / Caboclo):**
   * *Bônus:* +1 Força, +1 Destreza, +1 Lábia.
   * *Passiva Cultural:* Transita entre as vilas dos brancos e as picadas da floresta.
5. **Europeu Desertor (Holandês, Flamengo ou Judeu Converso):**
   * *Bônus:* +2 Destreza, +1 Lábia, -1 Misticismo.
   * *Passiva Cultural:* Engenharia militar de campanha e línguas metropolitanas.

---

### Pilar 2: Condição Social & Status Legal
Define como a sociedade dos homens e a lei colonial tratam você:

1. **Cativo / Fugitivo da Senzala ou Engenho:**
   * *Status:* Marcado pela milícia (preço pela cabeça).
   * *Bônus:* +2 Vigor, Instinto de Fuga (anda mais rápido se estiver ferido).
   * *Item:* Grilhão de ferro quebrado (usado como porrete ou arrombador).
2. **Homem / Mulher Livre de Poucas Posses:**
   * *Status:* Neutro; transita nas feiras sem ser parado pelos guardas.
   * *Bônus:* +1 Lábia, +1 Destreza.
   * *Item:* Salitre, fumo comum e pataca de cobre.
3. **Degredado da Metrópole (Exilado Criminal):**
   * *Status:* Desprezado pela Igreja, mas temido pelo submundo.
   * *Bônus:* +1 Força, +1 Audácia.
   * *Item:* Adaga de lâmina oculta e carta de perdão rasgada.
4. **Família Tradicional Decadente (Nobre da Terra Empobrecido):**
   * *Status:* Respeito aristocrático formal, mas sem ouro no bolso.
   * *Bônus:* +2 Lábia, +1 Reputação inicial.
   * *Item:* Anel de sinete e casaca puída.

---

### Pilar 3: Região de Partida (O Berço e Respawn)
Define onde o jogo começa, o clima e onde você renasce se sucumbir:

1. **Noroeste Açucareiro (Litoral da Capitania de Pernambuco):**
   * *Ambiente:* Canaviais queimados, fumaça de engenhos, patrulhas holandesas e bandeirantes.
   * *Risco:* Alta densidade de soldados e milícias armadas de arcabuz.
   * *Totem de Respawn:* Capela abandonada à beira-mar ou oco de jaqueira centenária.
2. **Sertão dos Cariris e Caatinga da Borborema:**
   * *Ambiente:* Terra rachada, espinheiros impenetráveis, lajedos sagrados.
   * *Risco:* Insolação, escassez de água potável e bandos de guerrilha.
   * *Totem de Respawn:* Altar de pedras empilhadas ou fonte de olho-d'água mística.
3. **Serra dos Palmares e Matas de Refúgio:**
   * *Ambiente:* Floresta tropical densa, cachoeiras, mocambos fortificados.
   * *Risco:* Caçadores de escravizados, armadilhas de estacas e feras da mata.
   * *Totem de Respawn:* Tronco da Gameleira Sagrada.
4. **Rotas Fluviais do Rio São Francisco:**
   * *Ambiente:* Barrancas barrentas, vapores noturnos e ilhas fluviais.
   * *Risco:* Emboscadas de canoas e criaturas das águas (Iara, Caboclo d'Água).
   * *Totem de Respawn:* Canoa encalhada sob o umbuzeiro.

---

### Pilar 4: Ofício e Sobrevivência (A Profissão Prática)
Define as habilidades ativas em combate/exploração e os equipamentos no inventário:

1. **Tropeiro / Mercador de Picada:**
   * *Habilidade:* Mula de Carga (inventário expandido) e Trânsito de Rotas.
   * *Equipamento:* Bruaca de couro, pederneira e feijão tropeiro seco.
2. **Mateiro / Rastreador de Rastro:**
   * *Habilidade:* Passo Silencioso (ignora penalidade de movimento em terreno difícil) e Olho de Águia.
   * *Equipamento:* Facão de mato e arco curto com flechas entalhadas.
3. **Ferreiro de Campanha / Armeiro:**
   * *Habilidade:* Conserto de Peças de Ferro e Manuseio de Pólvora sem risco de explosão acidental.
   * *Equipamento:* Martelo de forja e pinças de ferro fundido.
4. **Boticário do Claustro / Rezadeira da Terra:**
   * *Habilidade:* Preparo de Emplastros e Identificação de Ervas Medicinais / Venenos.
   * *Equipamento:* Morteiro de pedra, frascos de barro e tintura de arnica.
5. **Guerrilheiro / Soldado de Emboscada:**
   * *Habilidade:* Golpe de Emboscada (dano crítico ao atacar sem ser visto) e Tiro de Pederneira.
   * *Equipamento:* Pistola rústica de fecho de roda ou garrucha e balaço de chumbo.

---

## 4. O Sistema de Prólogos Dinâmicos (Como Começa a História)

O prólogo em quadrinhos (estilo *Flavio Colin*) adapta seus quadros automaticamente:

* **O Incidente Inicial é gerado pela fórmula:**
  $$\text{Quadro 1 (Cenário)} + \text{Quadro 2 (O Perigo da Condição)} + \text{Quadro 3 (A Reação pelo Ofício)}$$

### Exemplo Prático de Combinação:
* **Ficha:** *Nativo dos Cariris + Homem Livre + Sertão da Borborema + Mateiro.*
  * *Quadro 1:* O sol inclemente seca o leito do riacho nas pedras dos Cariris.
  * *Quadro 2:* Uma tropa de bandeirantes desce a serra caçando guias à força para encontrar ouro.
  * *Quadro 3:* O jogador usa suas pegadas invertidas e conhecimento da caatinga para escapar da primeira emboscada e encontrar o rastro do Fogo-Fátuo no lajedo sagrado.

---

## 5. Estrutura de Dados em GDScript (Para o Thomás)

```gdscript
# Exemplo de Modelo de Dados para o GameManager.gd
var character_builder = {
    "origem": "tupi",        # Modifica atributos base e diálogo com Curupira
    "condicao": "fugitivo",   # Modifica procurado pela milícia e item inicial
    "regiao": "sertao",       # Modifica spawn point e perigos ambientais
    "oficio": "tropeiro"      # Modifica inventário, habilidades e rotas
}
```
