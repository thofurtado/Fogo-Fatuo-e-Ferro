from pypdf import PdfReader

reader = PdfReader("Docs/Referencias/Worlds_Without_Number_Deluxe.pdf")

# Procura as páginas de Wilderness Tags e Factions
tags_page = None
faction_page = None

for idx, page in enumerate(reader.pages):
    text = page.extract_text()
    if "Wilderness Tags" in text and tags_page is None:
        tags_page = idx
    if "Factions and Major Projects" in text and faction_page is None:
        faction_page = idx

print(f"Wilderness Tags encontrada na pagina: {tags_page}")
print(f"Factions encontrada na pagina: {faction_page}")

if tags_page:
    print("\n--- TRECHO DE WILDERNESS TAGS ---")
    print(reader.pages[tags_page].extract_text()[:1500])

if faction_page:
    print("\n--- TRECHO DE FACTIONS ---")
    print(reader.pages[faction_page].extract_text()[:1500])