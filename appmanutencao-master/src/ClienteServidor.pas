unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB,
  UGerenciadorExcecoes, System.Threading;

type
  TServidor = class
  private
    FPath: String;
  public
    constructor Create;
    //Tipo do par?metro n?o pode ser alterado
    procedure SalvarArquivos(AData: OleVariant; NumeroArquivo: Integer);
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: String;
    FServidor: TServidor;

    function InitDataset: TClientDataset;
    procedure ExecutarParalelamente(ValorInicial, QtdEnvios: Integer);
  public
  end;

var
  fClienteServidor: TfClienteServidor;
  DiretorioLogErros: string;
  ValorProgressoParalelo: String;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  ProgressBar.Position := 0;
  cds := InitDataset;
  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin

      cds.Append;
      TBlobField(cds.FieldByName('Arquivo')).LoadFromFile((FPath));
      cds.Post;
      FServidor.SalvarArquivos(cds.Data, i);
      cds.EmptyDataSet;
      ProgressBar.Position := i;

      {$REGION Simula??o de erro, n?o alterar}
      if i = (QTD_ARQUIVOS_ENVIAR/2) then
        FServidor.SalvarArquivos(NULL, i);
      {$ENDREGION}
  end;

  cds.Free; //Liberar mem?ria

end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
var
  Task, Task2: ITask;
begin
  ProgressBar.Position := 0;
  Task := TTask.Create(procedure
                      begin
                        Sleep(1000);
                        ExecutarParalelamente(0, Round(QTD_ARQUIVOS_ENVIAR/2));
                      end);
  Task2 := TTask.Create(procedure
                      begin
                        Sleep(1000);
                        ExecutarParalelamente(50, QTD_ARQUIVOS_ENVIAR);
                      end);
  Task.Start;
  Task2.Start;
end;

procedure TfClienteServidor.ExecutarParalelamente(ValorInicial, QtdEnvios: Integer);
var
  cds: TClientDataset;
  i: Integer;
begin

  cds := InitDataset;
  for i := ValorInicial to QtdEnvios do
  begin
    cds.Append;
    TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
    cds.Post;
    FServidor.SalvarArquivos(cds.Data, i);
    cds.EmptyDataSet;
    ProgressBar.Position := QtdEnvios;
  end;

  ProgressBar.Position := QTD_ARQUIVOS_ENVIAR;
  cds.Free; //Liberar mem?ria
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  ProgressBar.Position := 0;
  cds := InitDataset;
  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin
    cds.Append;
    TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
    cds.Post;
    FServidor.SalvarArquivos(cds.Data, i);
    cds.EmptyDataSet;
    ProgressBar.Position := i;
  end;

  cds.Free; //Liberar mem?ria
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FServidor := TServidor.Create;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
end;

procedure TServidor.SalvarArquivos(AData: OleVariant; NumeroArquivo: Integer);
var
  cds: TClientDataSet;
  FileName: string;
begin

    cds := TClientDataset.Create(nil);
    cds.Data := AData;

    {$REGION Simula??o de erro, n?o alterar}
    if cds.RecordCount = 0 then
      Exit;
    {$ENDREGION}

    cds.First;

    while not cds.Eof do
    begin
      FileName := FPath + NumeroArquivo.ToString + '.pdf';
      if TFile.Exists(FileName) then
        TFile.Delete(FileName);
      TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
      cds.Next;
    end;

    cds.Free; //Liberar mem?ria

end;

end.
