# GDD — Cosmos Rush


---

# Cosmos Rush

## Elevator Pitch
Cosmos Rush é um jogo de plataforma 2D espacial em que o jogador controla um astronauta e atravessa Terra, Marte e Lua. Cada planeta possui movimentação e gravidade próprias, enquanto o jogador precisa administrar o oxigênio, superar plataformas e inimigos e coletar quatro cristais espalhados pela jornada.

## Objetivo Principal
Atravessar todas as fases, manter o oxigênio acima de zero, coletar os 4 cristais e chegar à nave final. A nave só pode ser ativada depois que todos os cristais forem encontrados.

## Estrutura Atual
O jogo possui:
- menu principal;
- tutorial inicial;
- Terra, Marte e Lua;
- três trechos/fases em cada planeta;
- sistema de oxigênio;
- cápsulas de recuperação;
- inimigo de patrulha;
- quatro cristais coletáveis;
- indicador visual de cristais;
- foguetes de transição entre planetas;
- menu de pausa;
- tela de Game Over;
- músicas ambientes diferentes por planeta;
- sequência de encerramento e tela final.

## Estilo
Jogo 2D com visual em pixel art e temática espacial. A progressão combina plataforma, exploração e gerenciamento de oxigênio.


---

# Mecânicas e Controles

## Controles
- A = mover para a esquerda
- D = mover para a direita
- W ou Espaço = pular
- ESC = pausar o jogo

## Movimento e Gravidade
O personagem possui física diferente de acordo com o planeta.

### Terra
- Velocidade: 110
- Força do pulo: -290
- Gravidade: 800

### Marte
- Velocidade: 100
- Força do pulo: -200
- Gravidade: 300
- A gravidade menor deixa a queda e os saltos diferentes da Terra.

### Lua
- Velocidade: 100
- Força do pulo: -150
- Gravidade: 200
- É o ambiente de menor gravidade do jogo.

## Sistema de Oxigênio
O jogador começa cada fase com 100 de oxigênio.

O oxigênio diminui continuamente durante a partida. O HUD mostra:
- valor atual;
- valor máximo;
- indicador visual da quantidade restante.

### Cápsulas de Oxigênio
Existem cápsulas espalhadas pelas fases.

Ao coletar uma cápsula:
- o jogador recupera 20 de oxigênio;
- a cápsula desaparece;
- um efeito sonoro é reproduzido.

## Cristais
Existem 4 cristais coletáveis espalhados pelo jogo.

Ao coletar um cristal:
- o total global aumenta;
- o cristal desaparece;
- o HUD de cristais é atualizado.

O progresso dos cristais é mantido durante a troca de cenas.

## Inimigo
O jogo possui um inimigo básico de patrulha.

Comportamento:
- anda horizontalmente;
- muda de direção ao detectar uma parede;
- causa 15 de dano ao oxigênio ao encostar no jogador;
- aplica knockback;
- deixa o personagem vermelho brevemente ao receber dano.

## Condições de Derrota
O jogador perde quando:
- o oxigênio chega a 0;
- cai para fora do limite do mapa.

Ao perder, o jogo abre a tela de Game Over.

## Pausa
Ao pressionar ESC, o jogo abre o menu de pausa.

Opções:
- continuar;
- reiniciar a fase;
- voltar ao menu principal.

## Tutorial
Antes da primeira fase, o jogo apresenta instruções com fade in e fade out explicando:
- controles;
- objetivo;
- oxigênio;
- perigos;
- gravidade;
- cristais.


---

# Fases e Planetas

## Estrutura Geral
Cosmos Rush possui uma progressão por três corpos celestes:

1. Terra
2. Marte
3. Lua

Cada planeta é dividido em diferentes trechos de plataforma.

## Terra
A Terra funciona como o início da jornada e apresenta a movimentação com maior gravidade.

Elementos:
- plataformas;
- oxigênio;
- cápsulas;
- cristais;
- perigos;
- transição entre trechos.

Ao terminar a Terra, o jogador utiliza um foguete para viajar até Marte.

### Foguete Terra → Marte
Ao entrar no foguete:
- o jogador desaparece;
- o foguete toca um som;
- treme por alguns segundos;
- decola;
- a cena de Marte é carregada.

## Marte
Marte possui gravidade menor que a Terra, alterando a sensação dos saltos e da queda.

Elementos:
- plataformas;
- cápsulas de oxigênio;
- cristais;
- inimigo;
- HUD de progresso;
- música ambiente própria.

Ao concluir Marte, outro foguete leva o jogador para a Lua.

### Foguete Marte → Lua
O foguete:
- esconde o jogador;
- reproduz som;
- vibra;
- sobe;
- carrega a fase da Lua.

## Lua
A Lua possui a menor gravidade entre os três ambientes.

Elementos:
- plataformas;
- sistema normal de oxigênio;
- cápsulas;
- cristais;
- HUD;
- música ambiente própria;
- trechos de progressão até a nave final.

## Nave Final
A nave final exige os 4 cristais.

Se o jogador ainda não tiver todos os cristais, a nave não é ativada.

Com 4 cristais:
- o jogador desaparece;
- o som do foguete e a música final começam;
- a nave vibra por 10 segundos;
- a nave decola;
- a cena final é carregada.

## Encerramento
A cena final utiliza tela preta e efeitos sonoros.

A sequência inclui:
- impacto sonoro;
- som espacial;
- mensagem “Obrigado por jogar!”;
- retorno ao menu principal;
- reset do progresso dos cristais.


---

# Core Loop

```text
1. Entrar em uma fase
2. Andar e pular pelas plataformas
3. Administrar o oxigênio
4. Coletar cápsulas quando necessário
5. Evitar quedas e inimigos
6. Procurar os cristais espalhados pela jornada
7. Avançar pelos trechos do planeta
8. Viajar para o próximo planeta
9. Repetir o ciclo com uma gravidade diferente
10. Conseguir os 4 cristais
11. Ativar a nave final
12. Concluir o jogo
```

## Ações Principais do Jogador
Durante a maior parte do jogo, o jogador:
- corre;
- pula;
- atravessa plataformas;
- adapta os saltos à gravidade de cada planeta;
- observa o nível de oxigênio;
- procura cápsulas;
- evita inimigos;
- coleta cristais;
- procura o caminho para a próxima fase.

## Progressão
A progressão ocorre em duas escalas:

### Progressão local
O jogador atravessa diferentes trechos dentro do mesmo planeta.

### Progressão geral
O jogador viaja na ordem:
Terra → Marte → Lua → Nave Final.

Os 4 cristais funcionam como objetivo global da jornada.


---

# Checklist de Entrega — Cosmos Rush

## Sistemas implementados
- [x] Movimento horizontal
- [x] Sistema de pulo
- [x] Gravidade diferente por planeta
- [x] Terra
- [x] Marte
- [x] Lua
- [x] Múltiplos trechos/fases
- [x] Barra e HUD de oxigênio
- [x] Perda contínua de oxigênio
- [x] Cápsulas coletáveis
- [x] Recuperação de oxigênio
- [x] Game Over por falta de oxigênio
- [x] Game Over por queda
- [x] Inimigo de patrulha
- [x] Dano por contato
- [x] Knockback
- [x] Feedback visual vermelho ao receber dano
- [x] 4 cristais coletáveis
- [x] Progresso global dos cristais
- [x] HUD dos cristais
- [x] Foguete Terra → Marte
- [x] Foguete Marte → Lua
- [x] Nave final condicionada aos 4 cristais
- [x] Animação/vibração de decolagem
- [x] Menu principal
- [x] Tutorial inicial
- [x] Menu de pausa
- [x] Tela de Game Over
- [x] Músicas ambientes por planeta
- [x] Efeitos sonoros
- [x] Tela/sequência final
- [x] Retorno ao menu após o encerramento

## Fluxo Final
```text
Menu
→ Tutorial
→ Terra
→ Marte
→ Lua
→ Nave Final
→ Encerramento
→ Menu
```

## Observações de Projeto
O escopo mudou em relação ao protótipo inicial. O projeto deixou de ser uma demonstração de uma única fase e passou a ter três planetas, múltiplas cenas, coleta global de cristais, inimigo, transições com foguetes, áudio, tutorial, pausa e encerramento completo.

O sistema de inventário/hotbar não faz parte da versão atual.
A antiga ideia de Núcleo de Dados/portal foi substituída pelo objetivo de coletar 4 cristais e ativar a nave final.

