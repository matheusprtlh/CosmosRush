# Organização do projeto Cosmos Rush

Arquivos de cena, scripts e shaders realocados, com caminhos `res://` atualizados. Foram preservados os arquivos `.uid` associados. A pasta `.godot` é um cache que será recriado ao abrir o projeto.

## Arquivos movidos

- `nave.tscn` → `Cenas/nave.tscn`
- `nave.gd` → `Scripts/nave.gd`
- `alarme_visual.gd` → `Scripts/alarme_visual.gd`
- `fadeout.gd` → `Scripts/fadeout.gd`
- `nave.gdshader` → `Shaders/nave.gdshader`
- `meteoro.gdshader` → `Shaders/meteoro.gdshader`
- `Cenas/acordar.gd` → `Scripts/acordar.gd`
- `Cenas/player.gd` → `Scripts/player_cenas.gd`
- `Cenas/terra.gdshader` → `Shaders/terra.gdshader`
- `Cenas/marte.gdshader` → `Shaders/marte.gdshader`
- `Cenas/terrablur.gdshader` → `Shaders/terrablur.gdshader`
- `Cosmos_Rush_GDD.md` → `Documentacao/Cosmos_Rush_GDD.md`
- `Test-05.09.md` → `Documentacao/Test-05.09.md`
- `Test-20.10.md` → `Documentacao/Test-20.10.md`
- `CORRECAO_PORCOS.txt` → `Documentacao/CORRECAO_PORCOS.txt`

## Verificações estáticas

- Referências não resolvidas antes: 42
- Referências não resolvidas depois: 43
- Referências antigas remanescentes: 0
- UIDs de cenas duplicados: 0

**Observação:** Verificação estática não substitui abrir o projeto no Godot e testar as transições, o menu, a nave e o gameplay.
