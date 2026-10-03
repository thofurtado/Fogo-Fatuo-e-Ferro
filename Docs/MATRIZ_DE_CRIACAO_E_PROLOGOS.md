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
  [ 3. REGIÃO NO MAPA ]    -> Uma das 6 macro-regiões (Berço, Clima e Totem de Respawn)
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

1. **Povos Originários da Costa (Ex: Tupi / Tabajara):**
   * *Bônus:* +2 Misticismo, +1 Destreza.
   * *Passiva Cultural:* Entende os sinais das aves e a linguagem das águas.
2. **Povos do Sertão Bruto (Ex: Tapuias / Cariris):**
   * *Bônus:* +2 Força, +1 Misticismo.
   * *Passiva Cultural:* Resistência natural à sede e veneno de peçonha.
3. **Afro-Atlântico (Bantos e Iorubás / Comunidades Livres):**
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
   * *Item Inicial:* Grilhão de ferro quebrado (usado como porrete ou alavanca).
2. **Homem / Mulher Livre de Poucas Posses:**
   * *Status:* Neutro; transita nas feiras sem ser parado pelos guardas.
   * *Bônus:* +1 Lábia, +1 Destreza.
   * *Item Inicial:* Salitre, fumo de rolo comum e pataca de cobre.
3. **Degredado da Metrópole (Exilado Criminal):**
   * *Status:* Desprezado pela Igreja, mas temido no submundo colonial.
   * *Bônus:* +1 Força, +1 Audácia.
   * *Item Inicial:* Adaga de lâmina oculta e carta de perdão rasgada.
4. **Família Tradicional Decadente (Nobre da Terra Empobrecido):**
   * *Status:* Respeito aristocrático formal, mas sem ouro no bolso.
   * *Bônus:* +2 Lábia, +1 Reputação inicial.
   * *Item Inicial:* Anel de sinete e casaca puída de veludo.

---

### Pilar 3: Região de Partida (Divisão Macro-Regional do Mapa - 1645)
O mapa global é dividido em **6 porções equivalentes de exploração**. A escolha define seu berço geográfico, perigos do bioma e o seu **Totem de Respawn**:

1. **Nordeste Açucareiro:**
   * *Características:* Alta densidade urbana/militar, engenhos e guerra aberta (Insurreição Pernambucana).
   * *Ambiente:* Canaviais queimados, fumaça de fornalhas, feitorias fortificadas e patrulhas da Companhia Holandesa (WIC) e milícias luso-brasileiras.
   * *Riscos:* Fogo cruzado de mosquetes e canhões, capitães-do-mato e autos-de-fé.
   * *Totem de Respawn:* Capela abandonada de taipa ou oco de jaqueira centenária no litoral.
2. **Sertão Nordestino:**
   * *Características:* Bioma árido, distâncias médias, pecuária extensiva dos currais.
   * *Ambiente:* Caatinga cinzenta, espinheiros impenetráveis, leitos de rios secos e lajedos sagrados.
   * *Riscos:* Insolação rápida, escassez severa de água potável, emboscadas em desfiladeiros de pedra e cascavéis.
   * *Totem de Respawn:* Olho-d'água místico nas fendas do lajedo ou cruzeiro de pedra sertanejo.
3. **Planalto de Piratininga:**
   * *Características:* O coração vicentino, ponto de partida das expedições e bandeiras.
   * *Ambiente:* Campos altos de altitude, colégio dos jesuítas, oficinas rústicas de ferreiros e armações de sertanistas.
   * *Riscos:* Recrutamento forçado para bandeiras de apresamento, mamelucos violentos e choque bélico com nações nativas indomadas.
   * *Totem de Respawn:* Pouso tropeiro fortificado ou tronco de jequitibá no cume da serra.
4. **Litoral e Rotas de Serra:**
   * *Características:* Trilhas costeiras escarpadas, escoamento mercante, contrabando e portos.
   * *Ambiente:* Mata Atlântica de encosta, lamaçal contínuo, barrotes escorregadios e enseadas com ancoradouros clandestinos.
   * *Riscos:* Quedas em precipícios, emboscadas de contrabandistas armados, neblina espessa (*mormaço*) e corsários na enseada.
   * *Totem de Respawn:* Rancho tropeiro de cumeeira ou farol rústico de restinga.
5. **Pantanal e Rios Centrais:**
   * *Características:* Terreno híbrido (água e terra), isolamento fluvial profundo e expedições de monções.
   * *Ambiente:* Corixos alagadiços, canais de igapó, capões de mata firme e rios caudalosos navegados em canoas monóxilas.
   * *Riscos:* Piranhas, jacarés pantaneiros, febres da várzea e criaturas das águas profundas (Caboclo d'Água, Iara e Minhocão).
   * *Totem de Respawn:* Canoa monóxila encalhada em capão de terra seca ou raiz de umbuzeiro d'água.
6. **Sul e Bacia do Prata:**
   * *Características:* Grandes planícies, missões jesuíticas e fronteiras ibéricas disputadas.
   * *Ambiente:* Coxilhas verdes sem fim, vento minuano cortante, reduções de pedra dos Sete Povos e tropas de gado chimarrão.
   * *Riscos:* Patrulhas montadas espanholas e portuguesas, caçadores de couro sem lei e tempestades repentinas (*pampeiros*).
   * *Totem de Respawn:* Pórtico de pedra da missão jesuítica ou marco de fronteira colonial.

---

### Pilar 4: Ofício e Sobrevivência (A Profissão Prática)
Define as habilidades ativas em combate/exploração e os equipamentos no inventário:

1. **Tropeiro / Mercador de Picada:**
   * *Habilidade:* Mula de Carga (inventário dobrado) e Conhecimento de Rotas Seguras.
   * *Equipamento:* Bruaca de couro reforçada, pederneira e feijão tropeiro desidratado (+HP).
2. **Mateiro / Rastreador:**
   * *Habilidade:* Passo Leve (ignora penalidade de terreno difícil) e Olho Clínico de Pegadas.
   * *Equipamento:* Facão de mato e arco curto com flechas de ponta de osso.
3. **Ferreiro de Campanha / Armeiro:**
   * *Habilidade:* Forja Rápida de Lâminas e Manuseio Seguro de Pólvora/Chumbo.
   * *Equipamento:* Martelo de forja, pinças de ferro e pederneira de chispa.
4. **Boticário do Claustro / Rezadeira da Terra:**
   * *Habilidade:* Preparo de Cataplasmas Medicinais e Identificação de Peçonhas/Ervas Místicas.
   * *Equipamento:* Morteiro de pedra, frascos de cerâmica e óleo de copaíba.
5. **Guerrilheiro / Soldado de Emboscada:**
   * *Habilidade:* Tiro Furtivo de Pederneira e Fuga Tática por Trincheiras de Raízes.
   * *Equipamento:* Garrucha de pederneira, polvorinho de chifre e adaga estreita.

---

## 4. O Sistema de Prólogos Dinâmicos (Como Começa a História)

O prólogo em quadrinhos (estilo *Flavio Colin*) adapta seus quadros automaticamente conforme a ficha:

$$\text{Quadro 1 (A Região e Clima)} \rightarrow \text{Quadro 2 (O Conflito da Condição Social)} \rightarrow \text{Quadro 3 (A Reação pelo Ofício)} \rightarrow \text{O Encontro com o Fogo-Fátuo}$$

### Exemplo 1:
* **Ficha:** *Nativo + Fugitivo + Nordeste Açucareiro + Mateiro*
  * *Quadro 1:* O clarão avermelhado das fornalhas do engenho corta a noite em Pernambuco.
  * *Quadro 2:* Capitães-do-mato com cães farejadores e arcabuzes cercam a mata próxima.
  * *Quadro 3:* O mateiro apaga seus rastros andando para trás nas poças d'água e se embrenha no brejo.
  * *Desfecho:* No coração do pântano, as chamas azuis do Boitatá/Fogo-Fátuo surgem das águas.

### Exemplo 2:
* **Ficha:** *Europeu Desertor + Degredado + Planalto de Piratininga + Ferreiro*
  * *Quadro 1:* A névoa fria da serra cobre os galpões de armas e taipa de Piratininga.
  * *Quadro 2:* Oficiais da Coroa dão voz de prisão por contrabando de pólvora e ferro.
  * *Quadro 3:* O ferreiro derruba a bigorna contra a porta, cega os guardas com brasas e foge pela picada do sul.
  * *Desfecho:* Na mata escura, o silêncio cai e olhos flamejantes de espíritos espiam entre os jequitibás.

---

## 5. Estrutura de Dados em GDScript (Para o Thomás)

```gdscript
# GameManager.gd - Dicionário canônico de regiões
const REGIOES = {
    "nordeste_acucareiro": {
        "nome": "Nordeste Açucareiro",
        "densidade": "alta",
        "clima": "tropical_humido",
        "respawn_totem": "Capela Litorânea",
        "perigo_primario": "milicia_holandesa"
    },
    "sertao_nordestino": {
        "nome": "Sertão Nordestino",
        "densidade": "media",
        "clima": "semiarido",
        "respawn_totem": "Lajedo Sagrado",
        "perigo_primario": "sede_e_peconha"
    },
    "planalto_piratininga": {
        "nome": "Planalto de Piratininga",
        "densidade": "media_alta",
        "clima": "subtropical_altitude",
        "respawn_totem": "Pouso Tropeiro da Serra",
        "perigo_primario": "bandeiras_apresamento"
    },
    "litoral_rotas_serra": {
        "nome": "Litoral e Rotas de Serra",
        "densidade": "media",
        "clima": "mata_atlantica_escarpa",
        "respawn_totem": "Rancho de Cumeeira",
        "perigo_primario": "precipicios_e_contrabando"
    },
    "pantanal_rios_centrais": {
        "nome": "Pantanal e Rios Centrais",
        "densidade": "baixa",
        "clima": "inundavel_fluvial",
        "respawn_totem": "Canoa do Capão",
        "perigo_primario": "pantano_e_entidades_aquaticas"
    },
    "sul_bacia_prata": {
        "nome": "Sul e Bacia do Prata",
        "densidade": "baixa_media",
        "clima": "pampas_coxilhas",
        "respawn_totem": "Redução Jesuítica de Pedra",
        "perigo_primario": "cavalaria_e_pampeiro"
    }
}
```
