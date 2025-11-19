# Multithreading em Delphi

Diferença entre TThread, TTask e TTask.Future

## Introdução

Delphi oferece duas principais abordagens para execução paralela:

1. TThread: controle manual da thread.
2. TTask: execução paralela baseada no ThreadPool.
3. TTask.Future: execução paralela com retorno de valor.

Este documento explica as diferenças práticas entre cada abordagem e mostra um exemplo real de paralelismo com Future e WaitForAll.

---

# 1. TThread

## O que é

TThread é a API tradicional de threads do Delphi. O desenvolvedor controla a criação, execução, sincronização e finalização da thread.

## Características

* Controle total sobre o ciclo de vida.
* Permite loops contínuos e longas execuções.
* Exige Synchronize ou Queue para atualizar a interface.
* Mais verboso.
* Ideal para processos complexos ou de longa duração.

## Exemplo simples

```delphi
TMinhaThread = class(TThread)
protected
  procedure Execute; override;
end;

procedure TMinhaThread.Execute;
begin
  while not Terminated do
  begin
    Sleep(500);
    TThread.Queue(nil,
      procedure
      begin
        ProgressBar.Position := ProgressBar.Position + 10;
      end);
  end;
end;
```

---

# 2. TTask

## O que é

TTask utiliza o ThreadPool do Delphi. Não há criação manual de threads; o sistema gerencia automaticamente.

## Características

* Código mais simples.
* Sem necessidade de manipular ciclo de vida.
* Melhor desempenho para tarefas pequenas.
* Bom para paralelismo rápido.
* Não retorna valores diretamente.

## Exemplo

```delphi
TTask.Run(
  procedure
  begin
    UpdateProgressBar(ProgressBar1, 10);
  end);
```

---

# 3. TTask.Future

## O que é

TTask.Future<T> executa um cálculo em background e retorna um valor. Funciona como Future ou Promise em outras linguagens.

## Características

* Executa código paralelo que retorna resultado.
* Ideal para consultas independentes, cálculos e requisições.
* Permite paralelismo com retorno de dados.
* Leitura do Value bloqueia se a tarefa ainda não terminou.

## Exemplo do projeto

```delphi
LItensFut := TTask.Future<TPedItenArray>(
  function: TPedItenArray
  var
    LConexao: TFDConnection;
  begin
    LConexao := Connected(g_Conexao);
    try
      Exit(GetItens(sNumero, not pFiltros.itens));
    finally
      Disconnected(LConexao);
    end;
  end);
```

---

# 4. Executando Futuros em Paralelo

O código abaixo executa duas consultas simultaneamente:

```delphi
LItensFut := TTask.Future<TPedItenArray>(...);
LNotasFut := TTask.Future<TPedNotaArray>(...);

SetLength(LTasks, 2);
LTasks[0] := ITask(LItensFut);
LTasks[1] := ITask(LNotasFut);

TTask.WaitForAll(LTasks);
```

Após todas terminarem:

```delphi
LItens := LItensFut.Value;
LNotas := LNotasFut.Value;
```

---

# 5. Comparação Direta

| Característica             | TThread                      | TTask                    | TTask.Future                  |
| -------------------------- | ---------------------------- | ------------------------ | ----------------------------- |
| Controle total da execução | Sim                          | Não                      | Não                           |
| Simplicidade               | Baixa                        | Alta                     | Alta                          |
| Retorno de valor           | Não                          | Não                      | Sim                           |
| Paralelismo simples        | Médio                        | Alto                     | Alto                          |
| Ideal para loops contínuos | Sim                          | Não                      | Não                           |
| Uso do ThreadPool          | Não                          | Sim                      | Sim                           |
| Uso recomendado            | Processos longos e complexos | Execução paralela rápida | Execução paralela com retorno |

---

# 6. Resumo

TThread é ideal quando é preciso controle total sobre o ciclo de vida da thread.
TTask é a forma mais prática e rápida para paralelismo simples.
TTask.Future é a melhor opção para tarefas paralelas que retornam valores, como consultas em banco de dados ou cálculos independentes.

---

Se quiser, posso gerar também:

* Um arquivo separado com exemplos completos.
* Diagramas explicando o fluxo de TThread vs TTask.
* Uma versão avançada com cancelamento e timeout.
