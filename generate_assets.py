import math
from PIL import Image, ImageDraw

def create_player():
    size = (128, 128)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Sombra no chão
    d.ellipse([34, 110, 94, 126], fill=(40, 30, 20, 90))
    
    # Pés / Botinas
    d.rounded_rectangle([42, 100, 58, 116], radius=6, fill=(100, 50, 20), outline=(20, 20, 20), width=3)
    d.rounded_rectangle([70, 100, 86, 116], radius=6, fill=(100, 50, 20), outline=(20, 20, 20), width=3)
    
    # Calça (marrom cáqui colonial com dobras)
    d.polygon([(46, 75), (82, 75), (88, 104), (68, 104), (64, 88), (60, 104), (40, 104)], fill=(180, 120, 60), outline=(20, 20, 20), width=3)
    d.line([(64, 88), (64, 76)], fill=(20, 20, 20), width=3)
    
    # Corpo / Camisa Azul Vibrante
    d.rounded_rectangle([40, 48, 88, 78], radius=10, fill=(35, 115, 215), outline=(20, 20, 20), width=4)
    # Gola da camisa
    d.polygon([(52, 48), (64, 62), (76, 48)], fill=(245, 245, 240), outline=(20, 20, 20), width=2)
    # Bolsinho
    d.rectangle([46, 56, 56, 68], fill=(25, 95, 185), outline=(20, 20, 20), width=2)
    
    # Braços
    d.rounded_rectangle([30, 50, 42, 76], radius=6, fill=(35, 115, 215), outline=(20, 20, 20), width=3)
    d.rounded_rectangle([86, 50, 98, 76], radius=6, fill=(35, 115, 215), outline=(20, 20, 20), width=3)
    # Mãos (pele quente)
    d.ellipse([28, 72, 40, 84], fill=(250, 195, 140), outline=(20, 20, 20), width=3)
    d.ellipse([88, 72, 100, 84], fill=(250, 195, 140), outline=(20, 20, 20), width=3)
    
    # Cabeça (formato arredondado expressivo de gibi)
    d.ellipse([42, 22, 86, 56], fill=(250, 195, 140), outline=(20, 20, 20), width=4)
    # Orelhas
    d.ellipse([36, 34, 46, 46], fill=(250, 195, 140), outline=(20, 20, 20), width=3)
    d.ellipse([82, 34, 92, 46], fill=(250, 195, 140), outline=(20, 20, 20), width=3)
    
    # Bochechas rosadas de cartum
    d.ellipse([46, 42, 54, 48], fill=(240, 140, 130, 180))
    d.ellipse([74, 42, 82, 48], fill=(240, 140, 130, 180))
    
    # Olhos (Estilo gibi clássico: ovais grandes, pupilas pretas com brilho branco)
    d.ellipse([50, 30, 60, 44], fill=(255, 255, 255), outline=(20, 20, 20), width=2)
    d.ellipse([68, 30, 78, 44], fill=(255, 255, 255), outline=(20, 20, 20), width=2)
    # Pupilas
    d.ellipse([54, 34, 60, 42], fill=(20, 20, 20))
    d.ellipse([72, 34, 78, 42], fill=(20, 20, 20))
    # Brilhos
    d.ellipse([57, 35, 59, 38], fill=(255, 255, 255))
    d.ellipse([75, 35, 77, 38], fill=(255, 255, 255))
    
    # Narizinho e Sorriso
    d.arc([60, 38, 68, 44], 0, 180, fill=(180, 110, 70), width=2)
    d.arc([56, 42, 72, 50], 10, 170, fill=(20, 20, 20), width=3)
    
    # Chapéu de Palha Clássico (Aba larga e topo cônico com textura de tranças)
    hat_crown = [(48, 24), (80, 24), (74, 6), (54, 6)]
    d.polygon(hat_crown, fill=(245, 210, 70), outline=(20, 20, 20), width=4)
    # Faixa vermelha do chapéu
    d.polygon([(47, 24), (81, 24), (80, 17), (48, 17)], fill=(225, 45, 40), outline=(20, 20, 20), width=2)
    # Aba recortada
    hat_brim = [(20, 30), (36, 22), (64, 20), (92, 22), (108, 30), (88, 34), (40, 34)]
    d.polygon(hat_brim, fill=(245, 210, 70), outline=(20, 20, 20), width=4)
    # Detalhes de palha
    d.line([(58, 8), (56, 17)], fill=(190, 150, 40), width=2)
    d.line([(70, 8), (72, 17)], fill=(190, 150, 40), width=2)
    
    img.save("Assets/Sprites/player.png")

def create_tiao():
    size = (128, 128)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Sombra
    d.ellipse([34, 110, 94, 126], fill=(40, 30, 20, 90))
    
    # Botas de couro escuro
    d.rounded_rectangle([40, 102, 58, 118], radius=6, fill=(60, 40, 25), outline=(20, 20, 20), width=3)
    d.rounded_rectangle([70, 102, 88, 118], radius=6, fill=(60, 40, 25), outline=(20, 20, 20), width=3)
    
    # Calça de vaqueiro
    d.polygon([(44, 76), (84, 76), (88, 106), (68, 106), (64, 90), (60, 106), (40, 106)], fill=(70, 85, 110), outline=(20, 20, 20), width=3)
    
    # Colete de Couro Marrom sobre camisa branca
    d.rounded_rectangle([38, 48, 90, 80], radius=10, fill=(240, 235, 225), outline=(20, 20, 20), width=4)
    # Painéis do colete de couro
    d.polygon([(38, 48), (56, 48), (52, 78), (38, 78)], fill=(145, 75, 30), outline=(20, 20, 20), width=3)
    d.polygon([(90, 48), (72, 48), (76, 78), (90, 78)], fill=(145, 75, 30), outline=(20, 20, 20), width=3)
    # Lenço vermelho no pescoço
    d.polygon([(54, 48), (64, 60), (74, 48), (64, 44)], fill=(210, 35, 30), outline=(20, 20, 20), width=2)
    
    # Braços
    d.rounded_rectangle([28, 50, 40, 76], radius=6, fill=(240, 235, 225), outline=(20, 20, 20), width=3)
    d.rounded_rectangle([88, 50, 100, 76], radius=6, fill=(240, 235, 225), outline=(20, 20, 20), width=3)
    # Mãos
    d.ellipse([26, 72, 38, 84], fill=(235, 180, 130), outline=(20, 20, 20), width=3)
    d.ellipse([90, 72, 102, 84], fill=(235, 180, 130), outline=(20, 20, 20), width=3)
    
    # Cabeça
    d.ellipse([42, 20, 86, 54], fill=(235, 180, 130), outline=(20, 20, 20), width=4)
    
    # Olhos expressivos
    d.ellipse([50, 28, 58, 38], fill=(255, 255, 255), outline=(20, 20, 20), width=2)
    d.ellipse([70, 28, 78, 38], fill=(255, 255, 255), outline=(20, 20, 20), width=2)
    d.ellipse([53, 31, 57, 37], fill=(20, 20, 20))
    d.ellipse([73, 31, 77, 37], fill=(20, 20, 20))
    
    # Sobrancelhas grossas
    d.line([(48, 26), (60, 25)], fill=(30, 25, 20), width=3)
    d.line([(68, 25), (80, 26)], fill=(30, 25, 20), width=3)
    
    # BIGODÃO CLÁSSICO DE SERTANEJO
    d.polygon([(44, 44), (54, 38), (64, 42), (74, 38), (84, 44), (74, 48), (64, 45), (54, 48)], fill=(35, 30, 25), outline=(15, 15, 15), width=3)
    
    # Chapéu de Feltro Sertanejo (estilo Lampião / Vaqueiro do Sertão com aba dobrada)
    hat_pts = [(24, 28), (40, 18), (64, 16), (88, 18), (104, 28), (84, 26), (44, 26)]
    d.polygon(hat_pts, fill=(115, 65, 35), outline=(20, 20, 20), width=4)
    # Copa
    d.polygon([(46, 20), (82, 20), (76, 4), (52, 4)], fill=(115, 65, 35), outline=(20, 20, 20), width=4)
    # Fita com estrela/fivela de ferro
    d.line([(47, 20), (81, 20)], fill=(210, 180, 80), width=4)
    
    img.save("Assets/Sprites/tiao_caboclo.png")

def create_tree():
    size = (192, 240)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Sombra da árvore
    d.ellipse([30, 195, 162, 235], fill=(30, 45, 20, 95))
    
    # Tronco de madeira brasileira (curvilíneo, robusto e com raízes)
    trunk = [(82, 100), (110, 100), (116, 170), (135, 215), (105, 210), (96, 175), (85, 212), (65, 210), (74, 170)]
    d.polygon(trunk, fill=(135, 75, 35), outline=(25, 20, 15), width=5)
    # Texturas e nós da madeira
    d.line([(90, 120), (88, 160)], fill=(95, 45, 20), width=3)
    d.line([(102, 130), (106, 180)], fill=(95, 45, 20), width=3)
    d.ellipse([92, 140, 100, 152], fill=(95, 45, 20), outline=(25, 20, 15), width=2)
    
    # Copa em Massas de Folhas (Nuvens Verdes com contorno nanquim e volume)
    foliage_layers = [
        # Sombra profunda da folhagem
        (96, 75, 65, (35, 110, 45)),
        (55, 95, 45, (30, 95, 40)),
        (137, 95, 45, (30, 95, 40)),
        (70, 50, 45, (45, 130, 55)),
        (122, 50, 45, (45, 130, 55)),
        (96, 40, 50, (55, 155, 65)),
        # Luz nas copas superiores
        (85, 30, 32, (85, 195, 80)),
        (115, 35, 30, (85, 195, 80))
    ]
    for x, y, r, col in foliage_layers:
        d.ellipse([x - r, y - r, x + r, y + r], fill=col, outline=(20, 25, 20), width=5)
        
    img.save("Assets/Sprites/arvore_tropical.png")

def create_fogo_fatuo():
    size = (96, 96)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Pedras de fogueira
    stones = [(24, 70, 14), (40, 76, 16), (60, 75, 15), (74, 68, 13), (32, 64, 12), (66, 62, 12)]
    for sx, sy, sr in stones:
        d.ellipse([sx - sr, sy - sr, sx + sr, sy + sr], fill=(130, 130, 135), outline=(20, 20, 20), width=3)
        
    # Lenha cruzada
    d.line([(28, 68), (68, 62)], fill=(90, 50, 20), width=8)
    d.line([(28, 68), (68, 62)], fill=(20, 20, 20), width=2)
    d.line([(68, 68), (28, 62)], fill=(90, 50, 20), width=8)
    d.line([(68, 68), (28, 62)], fill=(20, 20, 20), width=2)
    
    # Chama Mágica do Fogo-Fátuo (Azul esmeralda místico)
    # Brilho externo
    d.ellipse([20, 15, 76, 65], fill=(40, 220, 200, 70))
    # Chama principal
    flame_pts = [(48, 8), (68, 30), (62, 54), (48, 60), (34, 54), (28, 30)]
    d.polygon(flame_pts, fill=(30, 190, 225), outline=(15, 40, 60), width=4)
    # Núcleo quente esmeralda
    core_pts = [(48, 20), (58, 36), (54, 52), (48, 56), (42, 52), (38, 36)]
    d.polygon(core_pts, fill=(160, 255, 230), outline=(15, 40, 60), width=3)
    
    # Olhinhos travessos da criatura
    d.ellipse([42, 34, 46, 42], fill=(20, 30, 40))
    d.ellipse([50, 34, 54, 42], fill=(20, 30, 40))
    d.ellipse([44, 35, 46, 38], fill=(255, 255, 255))
    d.ellipse([52, 35, 54, 38], fill=(255, 255, 255))
    
    img.save("Assets/Sprites/fogo_fatuo.png")

def create_porteira():
    size = (160, 96)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Mourões principais (postes grossos)
    d.rounded_rectangle([12, 10, 32, 90], radius=4, fill=(120, 70, 35), outline=(20, 20, 20), width=4)
    d.rounded_rectangle([128, 10, 148, 90], radius=4, fill=(120, 70, 35), outline=(20, 20, 20), width=4)
    
    # Tábuas horizontais
    d.rounded_rectangle([28, 24, 132, 38], radius=3, fill=(150, 90, 45), outline=(20, 20, 20), width=3)
    d.rounded_rectangle([28, 46, 132, 60], radius=3, fill=(150, 90, 45), outline=(20, 20, 20), width=3)
    d.rounded_rectangle([28, 68, 132, 82], radius=3, fill=(150, 90, 45), outline=(20, 20, 20), width=3)
    
    # Trave diagonal
    d.polygon([(36, 80), (46, 82), (124, 26), (114, 24)], fill=(135, 80, 40), outline=(20, 20, 20), width=3)
    
    # Ferragens (pregos e ferrolho de ferro forjado)
    nails = [(22, 28), (22, 52), (22, 74), (138, 28), (138, 52), (138, 74), (80, 52)]
    for nx, ny in nails:
        d.ellipse([nx - 3, ny - 3, nx + 3, ny + 3], fill=(30, 30, 35), outline=(10, 10, 10), width=1)
        
    img.save("Assets/Sprites/porteira.png")

def create_tiles():
    # Tile de Terra Batida Acolhedora
    terra = Image.new("RGBA", (128, 128), (225, 195, 145))
    dt = ImageDraw.Draw(terra)
    # Detalhes suaves de pedrinhas de gibi
    pebbles = [(20, 30, 4), (85, 45, 5), (40, 90, 3), (110, 105, 4), (70, 15, 3)]
    for px, py, pr in pebbles:
        dt.ellipse([px-pr, py-pr, px+pr, py+pr], fill=(195, 160, 115), outline=(60, 45, 30), width=1)
    terra.save("Assets/Sprites/tile_terra.png")
    
    # Tile de Grama Tropical de Gibi
    grama = Image.new("RGBA", (128, 128), (95, 185, 80))
    dg = ImageDraw.Draw(grama)
    # Tufos de grama estilizados
    tufts = [(30, 40), (95, 25), (60, 85), (110, 95)]
    for tx, ty in tufts:
        dg.line([(tx, ty), (tx - 4, ty - 8)], fill=(45, 120, 40), width=2)
        dg.line([(tx, ty), (tx, ty - 11)], fill=(45, 120, 40), width=2)
        dg.line([(tx, ty), (tx + 4, ty - 8)], fill=(45, 120, 40), width=2)
    # Florzinha do campo
    dg.ellipse([48, 48, 54, 54], fill=(255, 230, 50), outline=(30, 30, 30), width=1)
    grama.save("Assets/Sprites/tile_grama.png")

create_player()
create_tiao()
create_tree()
create_fogo_fatuo()
create_porteira()
create_tiles()
print("TODOS OS SPRITES GERADOS COM SUCESSO!")