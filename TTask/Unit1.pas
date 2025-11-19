unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Math, Threading;

type
  TForm1 = class(TForm)
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    ProgressBar3: TProgressBar;
    ProgressBar4: TProgressBar;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    FactiveThreads: Integer; // contador global de threads
    procedure UpdateActiveThreadsLabel; // atualiza o label na UI
    procedure UpdateProgressBar(Progressbar: TProgressBar; pIncrement: integer); // faz a progress bar subir dentro da thread
    procedure EnableButton(Button: TButton); // reabilita botão quando thread termina
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  ProgressBar1.Position := 0; // reinicia a barra
  Button1.Enabled := False; // evita clique duplo

  // Inicia tarefa assíncrona — roda fora da main thread
  TTask.Run(
    procedure
    begin
      // ++ threads ativas. Interlocked garante operação atômica
      InterlockedIncrement(FActiveThreads);
      UpdateActiveThreadsLabel;

      // anima o progressbar até 100
      UpdateProgressBar(ProgressBar1, 10);

      // -- threads ativas
      InterlockedDecrement(FActiveThreads);
      UpdateActiveThreadsLabel;

      // reabilita botão na UI
      EnableButton(Button1);
    end);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ProgressBar2.Position := 0;
  Button2.Enabled := False;

  TTask.Run(
    procedure
    begin
      InterlockedIncrement(FActiveThreads);
      UpdateActiveThreadsLabel;

      UpdateProgressBar(ProgressBar2, 10);

      InterlockedDecrement(FActiveThreads);
      UpdateActiveThreadsLabel;

      EnableButton(Button2);
    end);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ProgressBar3.Position := 0;
  Button3.Enabled := False;

  TTask.Run(
    procedure
    begin
      InterlockedIncrement(FActiveThreads);
      UpdateActiveThreadsLabel;

      UpdateProgressBar(ProgressBar3, 10);

      InterlockedDecrement(FActiveThreads);
      UpdateActiveThreadsLabel;

      EnableButton(Button3);
    end);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ProgressBar4.Position := 0;
  Button4.Enabled := False;

  TTask.Run(
    procedure
    begin
      InterlockedIncrement(FActiveThreads);
      UpdateActiveThreadsLabel;

      UpdateProgressBar(ProgressBar4, 10);

      InterlockedDecrement(FActiveThreads);
      UpdateActiveThreadsLabel;

      EnableButton(Button4);
    end);
end;

procedure TForm1.EnableButton(Button: TButton);
begin
  // toca na UI => precisa rodar na main thread
  TThread.Queue(nil,
    procedure
    begin
      Button.Enabled := True;
    end);
end;

procedure TForm1.UpdateProgressBar(Progressbar: TProgressBar; pIncrement: integer);
begin
  // roda em background dentro da TTask
  while Progressbar.Position < 100 do
  begin
    Sleep(500); // ritmo da animação

    // TThread.Queue coloca o update na fila da thread principal
    // evitando travar a UI e mantendo segurança
    TThread.Queue(nil,
      procedure
      begin
        Progressbar.Position := Min(Progressbar.Position + pIncrement, 100);

        // quando chegar a 100, desabilita visualmente
        if Progressbar.Position = 100 then
          Progressbar.Enabled := False;
      end);
  end;
end;

procedure TForm1.UpdateActiveThreadsLabel;
begin
  // UI => precisa rodar na main thread
  TThread.Queue(nil,
    procedure
    begin
      Label1.Caption := 'Active Threads: ' + IntToStr(FactiveThreads);
    end);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FactiveThreads := 0; // inicia zerado
end;

end.
