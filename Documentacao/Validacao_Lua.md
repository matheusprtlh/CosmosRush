# Validação das fases lunares

O percurso foi executado no Godot 4.6.3 em uma cópia limpa da branch
`level-design/fases-da-lua`, a partir do redesenho no commit `70508e1`.
As cenas, o TileSet e os scripts do jogo vieram desse commit.

O script [validar_lua.gd](testes/validar_lua.gd) abre a Lua 1 e registra no
`Gamedata` os cristais anteriores necessários para cada caso. Depois usa as
ações de movimento e salto do projeto (`ui_left`, `ui_right`, `ui_accept`)
para avançar. O Godot aplica a física, as colisões e o consumo de oxigênio.
As coletas disparam pelos nós das cenas e os portais e a nave fazem as
transições do jogo.

## Como executar

Na raiz do projeto, importe os recursos e rode os três modos.

```bash
godot --headless --editor --import
for modo in base early late; do
  godot --headless --fixed-fps 60 --script res://Documentacao/testes/validar_lua.gd -- "$modo" || exit
done
```

Com ambiente gráfico, o mesmo script pode salvar um PNG de cada fase.
Passe um diretório existente para `--shots`. A execução que gerou os
prints usou o modo `late` para mostrar o cristal azul nas duas fases.

```bash
mkdir -p capturas-lua
godot --rendering-method gl_compatibility --audio-driver Dummy \
  --resolution 1152x648 --fixed-fps 60 \
  --script res://Documentacao/testes/validar_lua.gd -- late --shots "$PWD/capturas-lua"
```

O modo `base` usa os pontos de salto de referência. `early` e `late` variam
esses pontos em 5 px em cada direção. Uma verificação que falha aparece como
`FAIL` e retorna código de saída diferente de zero.

## Resultados

Os modos `base`, `early` e `late` passaram tanto em modo headless
quanto em OpenGL Compatibility com janela. As seis execuções retornaram
código de saída 0.

| Fase | Validação em execução |
| --- | --- |
| Lua 1 | 142 células lunares com colisão, spawn seguro, 11 saltos, 2 cápsulas, inimigo evitado e portal para Lua 2. |
| Lua 2 | 160 células lunares com colisão, spawn seguro, 2 descidas, 3 saltos, 3 cápsulas, verde coletado, inimigo evitado e portal para Lua 3. |
| Lua 3 | 109 células lunares com colisão, spawn seguro, 6 saltos, 2 cápsulas e chegada à área da nave. |

O script também verifica o tamanho de 16 × 16 de cada célula, o zoom de 2×
e o uso das colunas 5–7 e linhas 0–2 da fonte 0 do atlas
`res://TileMaps/sTileset.png`. Cada percurso bem-sucedido coleta as sete
cápsulas e termina as três fases com oxigênio positivo e sem dano.

| Modo | Preparação e cristal azul | Nave |
| --- | --- | --- |
| `base` | Cristais de Terra e Marte registrados. Azul coletado na Lua 1 e ausente na Lua 3, com a contagem mantida. | Decolou com quatro cristais e carregou `final.tscn`. |
| `early` | Apenas o cristal da Terra registrado. Azul coletado na Lua 1 e ausente na Lua 3, com a contagem mantida. | Jogador entrou na área com três cristais. A nave ficou inativa e a cena permaneceu na Lua 3. |
| `late` | Cristais de Terra e Marte registrados. Azul ignorado na Lua 1 e coletado na Lua 3. | Decolou com quatro cristais e carregou `final.tscn`. |

A validação usa entrada automatizada e começa na Lua 1. Partida
manual, percurso desde a Terra, áudio audível e exportação do jogo
ficaram fora dessa execução. O Godot emitiu avisos de V-Sync no
modo gráfico e de recursos em uso ao encerrar. A importação do editor
também registrou a ausência da chave `runnable` no preset de exportação.
