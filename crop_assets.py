from PIL import Image

# Recorta o Curumim caminhando da imagem da noite (está em pé, perfeito para caminhar!)
noite = Image.open("Assets/Backgrounds/mata_noite.jpg").convert("RGBA")
# Coordenadas aproximadas do curumim em mata_noite:
# largura: 572, altura: 1024. O curumim está em (250, 260) até (330, 400)
curumim_crop = noite.crop((245, 260, 335, 405))
curumim_crop.save("Assets/Sprites/curumim_caminhando.png")

# Recorta o amuleto esmeralda de mata_dia:
dia = Image.open("Assets/Backgrounds/mata_dia.jpg").convert("RGBA")
# O amuleto verde está ao lado do garoto: x cerca de 295 a 335, y cerca de 485 a 525
amuleto_crop = dia.crop((295, 485, 335, 525))
amuleto_crop.save("Assets/Sprites/amuleto_verde.png")

# Recorta o Curupira espiando de mata_noite:
# Curupira está no canto superior direito do tronco: x cerca de 360 a 430, y cerca de 130 a 250
curupira_crop = noite.crop((360, 130, 430, 250))
curupira_crop.save("Assets/Sprites/curupira_espiando.png")

print("Recortes de alta resolução gerados com sucesso!")