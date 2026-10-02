from PIL import Image, ImageDraw

# Gera um Spritesheet real de RPG 4x3 (3 frames de caminhada por direção, 4 direções)
# Largura total: 64 * 3 = 192px. Altura total: 64 * 4 = 256px.
# Linha 0: Baixo (Down / Frente)
# Linha 1: Cima (Up / Costas)
# Linha 2: Direita (Right / Perfil)
# Linha 3: Esquerda (Left / Perfil)

fw, fh = 64, 64
sheet = Image.new("RGBA", (fw * 3, fh * 4), (0, 0, 0, 0))

def draw_curumim(d, x_off, y_off, direction, step_frame):
    # Sombra nos pés
    d.ellipse([x_off + 20, y_off + 54, x_off + 44, y_off + 62], fill=(20, 30, 20, 80))
    
    # Pele indígena dourada/quente
    pele = (215, 140, 85)
    cabelo = (25, 20, 20)
    tanga = (195, 70, 45)
    
    # Variação de passos
    bob = 1 if step_frame != 1 else 0
    leg_l = -3 if step_frame == 0 else (3 if step_frame == 2 else 0)
    leg_r = 3 if step_frame == 0 else (-3 if step_frame == 2 else 0)
    
    if direction == "down": # Frente
        # Pernas
        d.rectangle([x_off + 24, y_off + 42, x_off + 28, y_off + 56 + leg_l], fill=pele, outline=(15, 15, 15), width=2)
        d.rectangle([x_off + 36, y_off + 42, x_off + 40, y_off + 56 + leg_r], fill=pele, outline=(15, 15, 15), width=2)
        # Tanga
        d.polygon([(x_off + 22, y_off + 40), (x_off + 42, y_off + 40), (x_off + 38, y_off + 49), (x_off + 26, y_off + 49)], fill=tanga, outline=(15, 15, 15), width=2)
        # Tronco
        d.rounded_rectangle([x_off + 24, y_off + 26 - bob, x_off + 40, y_off + 42 - bob], radius=4, fill=pele, outline=(15, 15, 15), width=2)
        # Pintura corporal vermelha (urucum)
        d.line([(x_off + 28, y_off + 32 - bob), (x_off + 36, y_off + 32 - bob)], fill=(210, 35, 30), width=2)
        # Braços
        arm_l = 2 if step_frame == 2 else -2
        arm_r = 2 if step_frame == 0 else -2
        d.line([(x_off + 23, y_off + 28 - bob), (x_off + 20, y_off + 40 - bob + arm_l)], fill=pele, width=3)
        d.line([(x_off + 41, y_off + 28 - bob), (x_off + 44, y_off + 40 - bob + arm_r)], fill=pele, width=3)
        # Cabeça
        d.ellipse([x_off + 22, y_off + 10 - bob, x_off + 42, y_off + 28 - bob], fill=pele, outline=(15, 15, 15), width=2)
        # Olhos
        d.ellipse([x_off + 26, y_off + 16 - bob, x_off + 30, y_off + 21 - bob], fill=(15, 15, 15))
        d.ellipse([x_off + 34, y_off + 16 - bob, x_off + 38, y_off + 21 - bob], fill=(15, 15, 15))
        # Pintura facial de urucum
        d.line([(x_off + 25, y_off + 22 - bob), (x_off + 39, y_off + 22 - bob)], fill=(210, 35, 30), width=2)
        # Cabelo corte indígena tradicional liso com franja
        d.polygon([(x_off + 20, y_off + 14 - bob), (x_off + 44, y_off + 14 - bob), (x_off + 42, y_off + 8 - bob), (x_off + 22, y_off + 8 - bob)], fill=cabelo)
        d.arc([x_off + 20, y_off + 6 - bob, x_off + 44, y_off + 22 - bob], 180, 360, fill=cabelo, width=5)

    elif direction == "up": # Costas
        # Pernas
        d.rectangle([x_off + 24, y_off + 42, x_off + 28, y_off + 56 + leg_l], fill=pele, outline=(15, 15, 15), width=2)
        d.rectangle([x_off + 36, y_off + 42, x_off + 40, y_off + 56 + leg_r], fill=pele, outline=(15, 15, 15), width=2)
        # Tanga
        d.polygon([(x_off + 22, y_off + 40), (x_off + 42, y_off + 40), (x_off + 37, y_off + 48), (x_off + 27, y_off + 48)], fill=tanga, outline=(15, 15, 15), width=2)
        # Tronco
        d.rounded_rectangle([x_off + 24, y_off + 26 - bob, x_off + 40, y_off + 42 - bob], radius=4, fill=pele, outline=(15, 15, 15), width=2)
        # Braços
        d.line([(x_off + 23, y_off + 28 - bob), (x_off + 20, y_off + 40 - bob)], fill=pele, width=3)
        d.line([(x_off + 41, y_off + 28 - bob), (x_off + 44, y_off + 40 - bob)], fill=pele, width=3)
        # Cabeça e cabelo cobrindo a nuca
        d.ellipse([x_off + 22, y_off + 10 - bob, x_off + 42, y_off + 28 - bob], fill=cabelo, outline=(15, 15, 15), width=2)

    elif direction == "right": # Perfil Direita
        # Pernas com passada de lado
        d.rectangle([x_off + 28, y_off + 42, x_off + 34, y_off + 56 + leg_l], fill=pele, outline=(15, 15, 15), width=2)
        d.rectangle([x_off + 34, y_off + 42, x_off + 39, y_off + 56 + leg_r], fill=pele, outline=(15, 15, 15), width=2)
        # Tanga
        d.polygon([(x_off + 26, y_off + 40), (x_off + 40, y_off + 40), (x_off + 36, y_off + 48), (x_off + 28, y_off + 48)], fill=tanga, outline=(15, 15, 15), width=2)
        # Tronco
        d.rounded_rectangle([x_off + 27, y_off + 26 - bob, x_off + 39, y_off + 42 - bob], radius=4, fill=pele, outline=(15, 15, 15), width=2)
        # Braço balançando
        d.line([(x_off + 33, y_off + 28 - bob), (x_off + 36 + leg_r, y_off + 38 - bob)], fill=pele, width=3)
        # Cabeça
        d.ellipse([x_off + 24, y_off + 10 - bob, x_off + 42, y_off + 28 - bob], fill=pele, outline=(15, 15, 15), width=2)
        # Olho de perfil
        d.ellipse([x_off + 35, y_off + 16 - bob, x_off + 38, y_off + 21 - bob], fill=(15, 15, 15))
        # Cabelo
        d.arc([x_off + 22, y_off + 8 - bob, x_off + 42, y_off + 24 - bob], 140, 340, fill=cabelo, width=5)

    elif direction == "left": # Perfil Esquerda
        # Pernas
        d.rectangle([x_off + 25, y_off + 42, x_off + 30, y_off + 56 + leg_r], fill=pele, outline=(15, 15, 15), width=2)
        d.rectangle([x_off + 30, y_off + 42, x_off + 36, y_off + 56 + leg_l], fill=pele, outline=(15, 15, 15), width=2)
        # Tanga
        d.polygon([(x_off + 24, y_off + 40), (x_off + 38, y_off + 40), (x_off + 36, y_off + 48), (x_off + 28, y_off + 48)], fill=tanga, outline=(15, 15, 15), width=2)
        # Tronco
        d.rounded_rectangle([x_off + 25, y_off + 26 - bob, x_off + 37, y_off + 42 - bob], radius=4, fill=pele, outline=(15, 15, 15), width=2)
        # Braço
        d.line([(x_off + 31, y_off + 28 - bob), (x_off + 28 + leg_l, y_off + 38 - bob)], fill=pele, width=3)
        # Cabeça
        d.ellipse([x_off + 22, y_off + 10 - bob, x_off + 40, y_off + 28 - bob], fill=pele, outline=(15, 15, 15), width=2)
        # Olho
        d.ellipse([x_off + 26, y_off + 16 - bob, x_off + 29, y_off + 21 - bob], fill=(15, 15, 15))
        # Cabelo
        d.arc([x_off + 22, y_off + 8 - bob, x_off + 42, y_off + 24 - bob], 200, 400, fill=cabelo, width=5)

d = ImageDraw.Draw(sheet)
dirs = [("down", 0), ("up", 1), ("right", 2), ("left", 3)]
for dir_name, row in dirs:
    for col in range(3):
        draw_curumim(d, col * fw, row * fh, dir_name, col)

sheet.save("Assets/Sprites/curumim_spritesheet.png")
print("Spritesheet 4x3 do Curumim gerado com perfeição!")