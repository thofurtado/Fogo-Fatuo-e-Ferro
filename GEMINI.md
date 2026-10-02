# Diretrizes de Desenvolvimento e Versionamento

Sempre que finalizar qualquer alteração, correção, refatoração ou adição de código neste projeto:

1. **Validar / Build**:
   - Verificar a integridade e sintaxe das modificações realizadas (validar arquivos GDScript/Godot garantindo que não há erros de execução ou referências nulas).
2. **Versionar (Git)**:
   - Adicionar os arquivos alterados ao Git (`git add <arquivos>`), respeitando o `.gitignore`.
3. **Commit Semântico**:
   - Executar o commit com uma mensagem clara, objetiva e contextualizada em português (ex.: `feat: ...`, `fix: ...`, `refactor: ...`, `docs: ...`).
4. **Relatório ao Usuário**:
   - Explicar exatamente o que foi implementado/modificado;
   - Listar os arquivos afetados com links clicáveis;
   - Informar o commit realizado.
