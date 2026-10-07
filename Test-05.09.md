# Relatório de Testes --- Cosmos Rush

**Projeto:** Cosmos Rush\
**Engine:** Godot 4.x\
**Data dos testes:** 06/10/2026\
**Versões analisadas:** V1, V2, V3 e correção pós-V3 do TP da Lua

------------------------------------------------------------------------

## 1. Objetivo

Este relatório registra a evolução do Cosmos Rush durante os testes
realizados entre as versões V1, V2 e V3. O objetivo foi identificar
bugs, registrar as correções realizadas, comparar as versões e manter
evidências visuais dos problemas encontrados.

O relatório separa:

-   alterações confirmadas pela comparação dos arquivos;
-   problemas observados durante os testes;
-   correções realizadas;
-   problemas que permaneceram pendentes ao final da aula.

------------------------------------------------------------------------

# 2. V1 --- Versão inicial de testes

## 2.1 Situação encontrada

A V1 foi utilizada como versão-base para os primeiros testes.

Durante os testes foram identificados principalmente:

-   **Pause na Lua com problema**, necessitando correção.
-   **Enemy com problema de interação/colisão com o Player**,
    necessitando revisão.

Além disso, a estrutura do projeto ainda possuía scripts separados para
os players dos planetas, incluindo:

-   `Scripts/playerMarte.gd`
-   `Scripts/playerLua.gd`
-   `Scripts/player.gd`

## 2.2 Objetivos definidos após o teste da V1

Para a versão seguinte, foram definidos como objetivos:

1.  corrigir o Pause nas fases da Lua;
2.  corrigir o comportamento do Enemy;
3.  melhorar a estrutura dos scripts do Player;
4.  revisar o fluxo das fases/portais.

## 2.3 Resultado do teste

**Status:** versão funcional como base, porém com bugs que exigiam
correção.

------------------------------------------------------------------------

# 3. V2 --- Refatoração e segundo ciclo de testes

## 3.1 Diferenças confirmadas entre V1 e V2

A comparação direta dos arquivos mostrou as seguintes alterações
relevantes:

### Arquivos adicionados

-   `Cenas/player.gd`
-   `Cenas/player.gd.uid`

### Arquivos removidos

-   `Scripts/playerMarte.gd`
-   `Scripts/playerMarte.gd.uid`
-   `Scripts/playerLua.gd`
-   `Scripts/playerLua.gd.uid`

### Arquivos modificados

-   `Scripts/player.gd`
-   `Cenas/marte.tscn`
-   `Cenas/marte_2.tscn`
-   `Cenas/marte_3.tscn`
-   `Cenas/lua.tscn`
-   `Cenas/lua_2.tscn`
-   `Cenas/lua_3.tscn`

Arquivos internos da pasta `.godot` foram desconsiderados da comparação
por serem arquivos de cache/editor.

## 3.2 Player universal

A principal alteração da V2 foi a transformação do Player em um sistema
configurável.

Na V1, valores importantes eram definidos diretamente no script, como
velocidade, força do pulo e gravidade.

Na V2, esses valores passaram a utilizar propriedades exportadas para o
Inspector:

-   `speed`
-   `jump_force`
-   `gravity`
-   `impulso_morte`
-   `tempo_ate_game_over`
-   `limite_queda`
-   `oxigenio_maximo`
-   `perda_por_segundo`
-   `recuperacao_capsula`

Isso permitiu utilizar uma mesma lógica de Player e configurar o
comportamento de cada planeta pelo Inspector.

### Evidência --- Player configurável

![Inspector mostrando parâmetros configuráveis do
Player](relatorio_testes_assets/v2_player_inspector.png)

**Resultado:** refatoração concluída e estrutura mais reutilizável.

### Evidência --- busca pelos scripts do Player

![Busca por Player no
projeto](relatorio_testes_assets/v2_busca_player.png)

A imagem foi registrada durante a verificação da nova estrutura do
Player.

## 3.3 Game Over

Durante a V2 também foi registrada a cena de Game Over contendo:

-   botão de Menu;
-   botão Retry;
-   áudio;
-   tela de Game Over.

![Cena Game Over durante os testes da
V2](relatorio_testes_assets/v2_game_over.png)

O print comprova a existência/configuração da tela. O funcionamento
individual dos botões deve ser considerado um teste funcional separado.

## 3.4 Correções verificadas durante o ciclo da V2

Durante esse ciclo:

-   o **Pause da Lua foi corrigido**;
-   o fluxo de **Marte 1 → Marte 2 → Marte 3** foi corrigido;
-   o Enemy recebeu alterações, porém os testes mostraram que ele
    **ainda não estava totalmente corrigido**.

## 3.5 Novos bugs encontrados na V2

Os testes da V2 revelaram novos problemas:

1.  **Chão de Marte:** foi percebido um problema no chão/colisão de
    Marte.
2.  **Portais:** alguns portais não estavam ativando/realizando a
    transição corretamente.
3.  **Tela "Obrigado por jogar":** o tempo de espera precisava ser
    ajustado.
4.  **Enemy --- dano frontal:** o inimigo não causava dano corretamente
    ao chegar de frente no Player.
5.  **Enemy --- borda da plataforma:** o inimigo caía da plataforma em
    vez de detectar a borda e retornar.

## 3.6 Resultado da V2

**Corrigido:**

-   Pause da Lua;
-   fluxo de Marte;
-   refatoração do Player.

**Ainda pendente após os testes:**

-   Enemy;
-   chão de Marte;
-   portais;
-   tempo do "Obrigado por jogar".

------------------------------------------------------------------------

# 4. V3 --- Terceiro ciclo de testes

## 4.1 Diferenças confirmadas entre V2 e V3

Desconsiderando arquivos internos da Godot, a comparação mostrou apenas
dois arquivos modificados:

-   `Cenas/game_over.tscn`
-   `Cenas/lua.tscn`

### `game_over.tscn`

Foi adicionado um `ColorRect` preto à cena de Game Over.

### `lua.tscn`

Na V3, o antigo `tplua` foi removido da cena `lua.tscn`, incluindo:

-   referência ao script `tplua.gd`;
-   nó `Area2D` do portal;
-   `CollisionShape2D`;
-   conexão do sinal `body_entered`.

Essa alteração se relacionou diretamente ao problema encontrado no TP da
Lua.

------------------------------------------------------------------------

# 5. Teste do TP da Lua --- V3

## 5.1 Problema encontrado

Durante o teste da V3, o TP da Lua não funcionava.

Ao abrir `tplua.gd`, foi constatado que o arquivo estava praticamente
vazio e possuía apenas:

``` gdscript
extends Area2D
```

Não havia lógica para:

-   detectar o Player;
-   definir a cena de destino;
-   iniciar a transição;
-   chamar o PixelFade;
-   trocar de fase.

### Evidência --- `tplua.gd` vazio

![Script tplua.gd contendo apenas extends
Area2D](relatorio_testes_assets/v3_tplua_vazio.png)

## 5.2 Portal ausente na fase

Também foi registrado visualmente que a fase estava sem o TP esperado.

![Fase da Lua sem o TP
funcional](relatorio_testes_assets/v3_lua_sem_tp.png)

## 5.3 Diagnóstico

O problema do TP da Lua foi associado a dois fatores:

-   ausência da lógica necessária no script `tplua.gd`;
-   portal/conexões ausentes ou incorretas na cena.

------------------------------------------------------------------------

# 6. Correção pós-V3 --- TP da Lua

Após identificar o problema, foi preparada uma correção específica para
o TP da Lua seguindo o padrão de transição do restante do jogo.

O novo `tplua.gd` passou a:

-   receber uma `cena_destino`;
-   detectar `body_entered`;
-   validar se o objeto é um `CharacterBody2D`;
-   impedir múltiplas ativações simultâneas;
-   localizar o `PixelFade`;
-   chamar `trocar_fase(cena_destino)`;
-   possuir fallback para troca direta de cena caso o PixelFade não seja
    encontrado.

As cenas também passaram a conectar o sinal `body_entered` ao próprio
portal.

O fluxo configurado ficou:

**Lua 1 → Lua 2 → Lua 3**

O shader/PixelFade foi integrado à lógica de transição.

**Observação:** a correção foi implementada, mas o teste final em
gameplay deve ser registrado separadamente para confirmar que toda a
sequência funciona no jogo executado.

------------------------------------------------------------------------

# 7. Teste da tela "Obrigado por jogar"

## 7.1 Problema identificado

O tempo da sequência final estava inconsistente com os próprios
comentários do código.

### Evidência

![Código mostrando tempos da sequência Obrigado por
jogar](relatorio_testes_assets/v3_tempo_obrigado.png)

No trecho registrado:

-   o comentário informa **"Tela preta por 3 segundos"** e o código
    utiliza `3.0`;
-   o comentário informa **"Música toca por 10 segundos"**, mas o código
    utiliza `8.0`;
-   o comentário informa **"Mensagem permanece por 5 segundos"**, mas o
    código utiliza `3.0`.

## 7.2 Diagnóstico

Existe diferença entre o tempo planejado nos comentários e o tempo
realmente executado pelo código.

## 7.3 Status

**PENDENTE ao final da aula.**

É necessário definir os tempos desejados e ajustar os valores de
`create_timer()`.

------------------------------------------------------------------------

# 8. Situação do Enemy ao final da aula

O Enemy recebeu tentativas de correção durante as versões, porém
continuou apresentando dois problemas principais:

## 8.1 Dano pela frente

**Problema:** quando o Enemy chegava de frente no Player, o dano não
ocorria corretamente.

**Status:** PENDENTE.

## 8.2 Queda nas bordas

**Problema:** o Enemy continuava andando ao chegar ao fim de uma
plataforma e caía, em vez de detectar a ausência de chão e inverter a
direção.

**Correção necessária:** adicionar/ajustar uma verificação de chão/borda
à frente do Enemy e inverter sua direção quando não houver plataforma.

**Status:** PENDENTE.

------------------------------------------------------------------------

# 9. Situação do chão de Marte

Durante os testes da V2 foi percebido um problema relacionado ao chão de
Marte.

O problema permaneceu citado como pendente até o encerramento deste
ciclo de testes.

**Status:** PENDENTE.

**Observação:** não foi fornecida neste ciclo uma evidência visual
específica que permita documentar tecnicamente a causa exata do
problema. Portanto, o relatório registra apenas o problema observado,
sem atribuir uma causa não comprovada.

------------------------------------------------------------------------

# 10. Comparação resumida das versões

  --------------------------------------------------------------------------------------
  Item              V1                V2                       V3 / pós-V3
  ----------------- ----------------- ------------------------ -------------------------
  Pause na Lua      Bug identificado  Corrigido                Mantido

  Player            Scripts separados Player                   Mantido
                                      universal/configurável   

  Fluxo de Marte    Precisava         Marte 1 → 2 → 3          Mantido
                    correção          corrigido                

  Enemy             Bug identificado  Ainda apresentou dano    Pendente
                                      frontal e queda em borda 

  Chão de Marte     ---               Bug identificado         Pendente

  Portais           ---               Problemas identificados  TP da Lua
                                                               diagnosticado/corrigido
                                                               em versão pós-V3

  TP da Lua         ---               ---                      Script vazio/portal
                                                               ausente detectado;
                                                               correção implementada

  Game Over         Existente         Registrado em teste      Fundo preto (`ColorRect`)
                                                               adicionado

  "Obrigado por     ---               Tempo apontado como      Inconsistência de timers
  jogar"                              problema                 registrada; pendente
  --------------------------------------------------------------------------------------

------------------------------------------------------------------------

# 11. Evolução dos testes

## Ciclo 1 --- V1

**Teste → problemas encontrados**

-   Pause da Lua.
-   Enemy.

**Ação seguinte:** corrigir os dois sistemas e revisar a estrutura do
Player.

## Ciclo 2 --- V2

**Correções/alterações**

-   Pause da Lua corrigido.
-   Player refatorado.
-   Fluxo de Marte corrigido.

**Novos problemas encontrados**

-   chão de Marte;
-   portais;
-   tempo da tela final;
-   dano frontal do Enemy;
-   Enemy caindo da plataforma.

## Ciclo 3 --- V3

**Problema principal encontrado**

-   TP da Lua sem funcionamento.

**Diagnóstico**

-   `tplua.gd` praticamente vazio;
-   TP removido/ausente em `lua.tscn`.

**Correção posterior**

-   portal restaurado/configurado;
-   sinal conectado;
-   destino configurável;
-   PixelFade integrado;
-   fluxo Lua 1 → Lua 2 → Lua 3 preparado.

------------------------------------------------------------------------

# 12. Pendências após este relatório

1.  **Corrigir o chão de Marte.**
2.  **Finalizar a correção do Enemy para dano frontal.**
3.  **Fazer o Enemy detectar bordas e retornar sem cair.**
4.  **Ajustar os tempos da sequência "Obrigado por jogar".**
5.  **Executar teste final do TP da Lua após a correção.**
6.  **Testar novamente todos os portais do jogo em sequência.**
7.  **Executar uma partida completa para verificar se as correções não
    introduziram novos bugs.**

------------------------------------------------------------------------

# 13. Conclusão

Os testes entre V1, V2 e V3 permitiram identificar e corrigir problemas
importantes do Cosmos Rush, além de melhorar a estrutura interna do
projeto.

A V2 representou a maior mudança estrutural, principalmente pela
implementação de um Player configurável e pela remoção dos scripts
separados de Marte e Lua. Os testes dessa versão também revelaram novos
problemas de gameplay.

Na V3, o teste dos portais revelou que o TP da Lua estava sem a lógica
necessária e ausente da configuração esperada da fase. O problema foi
diagnosticado e uma correção pós-V3 foi preparada utilizando o mesmo
conceito de transição com PixelFade.

Ao final do ciclo, os principais itens ainda pendentes são o chão de
Marte, o comportamento do Enemy e o tempo da sequência "Obrigado por
jogar".

Este documento deve continuar sendo atualizado nas próximas versões para
registrar as correções e os testes finais do projeto.
