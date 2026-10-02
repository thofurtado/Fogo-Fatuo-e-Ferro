from PIL import Image

def clean_ground(image_path, out_path, box_coords):
    img = Image.open(image_path).convert("RGB")
    # A área onde o garoto estava desenhado:
    # Em mata_dia (572x1024): o garoto sentado está entre x: 260 a 305, y: 475 a 525
    # Amostramos a textura da grama/terra logo acima (x: 260 a 305, y: 410 a 460)
    sample = img.crop((box_coords[0], box_coords[1] - 65, box_coords[2], box_coords[3] - 65))
    # Cola a textura da clareira sobre o garoto fixo
    img.paste(sample, (box_coords[0], box_coords[1]))
    img.save(out_path, quality=95)
    print(f"Fundo limpo e salvo em: {out_path}")

clean_ground("Assets/Backgrounds/mata_dia.jpg", "Assets/Backgrounds/mata_dia_limpa.jpg", (260, 475, 305, 525))
clean_ground("Assets/Backgrounds/mata_noite.jpg", "Assets/Backgrounds/mata_noite_limpa.jpg", (245, 260, 335, 405))