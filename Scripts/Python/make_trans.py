from PIL import Image

img = Image.open("Assets/Sprites/curumim_caminhando.png").convert("RGBA")
width, height = img.size

# Amostra as cores dos cantos (que são a areia da trilha)
bg_samples = [
    img.getpixel((0, 0)),
    img.getpixel((width - 1, 0)),
    img.getpixel((0, height - 1)),
    img.getpixel((width - 1, height - 1))
]
avg_bg = [sum(x[i] for x in bg_samples) / len(bg_samples) for i in range(3)]

# Faz uma limpeza suave das bordas
datas = img.getdata()
new_data = []
for item in datas:
    # Distância euclidiana da cor média da areia
    dist = ((item[0]-avg_bg[0])**2 + (item[1]-avg_bg[1])**2 + (item[2]-avg_bg[2])**2)**0.5
    if dist < 42:
        new_data.append((255, 255, 255, 0)) # Transparente
    elif dist < 58:
        alpha = int((dist - 42) / 16.0 * 255)
        new_data.append((item[0], item[1], item[2], alpha))
    else:
        new_data.append(item)

img.putdata(new_data)
img.save("Assets/Sprites/curumim_transparente.png")
print("Curumim com transparência gerado com sucesso!")