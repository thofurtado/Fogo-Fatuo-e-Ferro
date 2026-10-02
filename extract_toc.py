from pypdf import PdfReader

reader = PdfReader("Docs/Referencias/Worlds_Without_Number_Deluxe.pdf")
print("Total de Paginas:", len(reader.pages))

outline = reader.outline
def print_outline(outline, depth=0):
    for item in outline:
        if isinstance(item, list):
            print_outline(item, depth + 1)
        else:
            try:
                title = item.title if hasattr(item, "title") else str(item)
                print("  " * depth + f"- {title}")
            except Exception:
                pass

if outline:
    print_outline(outline[:25])
else:
    print("Sem outline nos metadados, buscando nas primeiras paginas...")
    for i in range(1, 8):
        text = reader.pages[i].extract_text()
        if "Table of Contents" in text or "Contents" in text:
            print(f"--- Pagina {i} ---")
            print(text[:1200])