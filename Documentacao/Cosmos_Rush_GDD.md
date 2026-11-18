# GDD — Cosmos Rush


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
- A/D, setas esquerda/direita ou analógico esquerdo para mover.
- W, Espaço, Enter ou botão inferior do controle para pular.
- Esc para pausar ou continuar.

## Movimento e Gravidade
O personagem possui física diferente de acordo com o planeta. O controle horizontal ganha velocidade gradualmente, com aceleração de 900 px/s² e desaceleração de 1.200 px/s². As taxas são ajustáveis no Inspector. O impulso horizontal e vertical do dano tem prioridade sobre os controles por 0,14 s.

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
O jogador começa cada fase com 100 de oxigênio. O consumo padrão é de 1 unidade a cada 0,25 s de jogo (4 unidades por segundo). Isso dá cerca de 25 s sem cápsulas nem dano. A nave introdutória tem oxigênio sem consumo. O consumo também é suspenso na pausa e após entrar em um portal ou embarcar em um foguete.

O HUD indica a quantidade restante por uma barra em pixel art. O máximo, a perda por intervalo, o intervalo e a recuperação por cápsula são ajustáveis no Inspector.

### Cápsulas de Oxigênio
Existem cápsulas espalhadas pelas fases.

Ao coletar uma cápsula:
- o jogador recupera até 20 de oxigênio, limitado ao máximo;
- a cápsula é consumida uma única vez;
- um efeito sonoro é reproduzido.

## Cristais
Existem quatro cristais distintos. O amarelo está na Terra 2, o roxo em Marte 2, o azul na Lua 1 ou na Lua 3 e o verde na Lua 2. As duas instâncias azuis dão uma única unidade de progresso.

Ao coletar um cristal:
- o total global aumenta;
- o cristal desaparece;
- o HUD de cristais é atualizado.

O progresso é mantido ao avançar e ao reiniciar a fase pelo Pause. Um cristal já coletado desaparece ao recarregar a fase.

## Inimigo
O jogo possui um inimigo básico de patrulha.

Comportamento:
- anda horizontalmente;
- usa dois RayCast2D para detectar obstáculos e bordas. Inverte a direção quando o caminho oposto está livre e espera quando ambos os lados estão bloqueados;
- causa 15 de dano ao oxigênio por entrada na área de contato, com proteção de 0,25 s contra impactos duplicados;
- aplica knockback;
- deixa o personagem vermelho brevemente ao receber dano.

## Condições de Derrota
O jogador perde quando:
- o oxigênio chega a 0;
- cai para fora do limite do mapa.

Ao perder, o jogo abre a tela de Game Over.

## Pausa
O autoload GlobalPause é compartilhado pelas nove fases. A pausa congela o jogo e os temporizadores da fase. O comando fica bloqueado enquanto o PixelFade troca de cena.

- **Continuar** retoma a fase no mesmo ponto.
- **Reiniciar** recarrega a fase e restaura o oxigênio, mantendo os cristais coletados.
- **Menu** encerra a partida e zera os cristais.

Iniciar pelo menu ou usar Retry após o Game Over começa com zero cristais. Retry volta à Terra 1.

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
A tela final abre em preto com um impacto sonoro. Após 3 s, começa o áudio espacial. O texto “OBRIGADO POR JOGAR” aparece 8 s depois e permanece por 5 s. Aos 16 s, a partida é zerada e o menu principal volta. Os três tempos são ajustáveis no Inspector.


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
Terra 1 → Terra 2 → Terra 3 → Marte 1 → Marte 2 → Marte 3 → Lua 1 → Lua 2 → Lua 3 → Nave Final. Os portais e foguetes usam PixelFade.

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
→ Nave introdutória
→ Terra 1 → Terra 2 → Terra 3
→ Marte 1 → Marte 2 → Marte 3
→ Lua 1 → Lua 2 → Lua 3
→ Nave Final
→ Encerramento
→ Menu
```

## Observações de Projeto
O escopo mudou em relação ao protótipo inicial. O projeto deixou de ser uma demonstração de uma única fase e passou a ter três planetas, múltiplas cenas, coleta global de cristais, inimigo, transições com foguetes, áudio, tutorial, pausa e encerramento completo.

O sistema de inventário/hotbar não faz parte da versão atual.
A antiga ideia de Núcleo de Dados/portal foi substituída pelo objetivo de coletar 4 cristais e ativar a nave final.


## Créditos

O menu do jogo credita Matheus Portilho.
