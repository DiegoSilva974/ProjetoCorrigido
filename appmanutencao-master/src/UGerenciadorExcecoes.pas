unit UGerenciadorExcecoes;

interface

uses
  System.SysUtils, Forms, System.Classes, Vcl.Dialogs;

type
  TGerenciadorExcecoes = class
  private
    ArquivoLog: String;
    PastaServidor: String;
  public
    constructor Create;
    procedure TratarExcecao(Sender: TObject; E: Exception);
    procedure SalvarLog(Value: String);
    procedure LimparDiretorio;
  end;


implementation


{ TGerenciadorExcecoes }

constructor TGerenciadorExcecoes.Create;
begin
  ArquivoLog := ExtractFilePath(ParamStr(0)) + 'LogErros\ArquivoLogErros.log';
  PastaServidor :=  ExtractFilePath(ParamStr(0)) + 'Servidor\';
  Application.onException := TratarExcecao;
end;

procedure TGerenciadorExcecoes.SalvarLog(Value: String);
var
  LogTxt: TextFile;
begin
  AssignFile(LogTxt, ArquivoLog);
  if FileExists(ArquivoLog) then
    Append(LogTxt)
  else
    Rewrite(LogTxt);

  Writeln(LogTxt, Value);
  CloseFile(LogTxt);
end;

procedure TGerenciadorExcecoes.TratarExcecao(Sender: TObject; E: Exception);
begin

  SalvarLog(StringofChar('=', 120));
  SalvarLog('Inclusão: ' + FormatDateTime('dd-mm-yyy hh:mm:ss', Now));
  if TComponent(Sender) is TForm then
    begin
      SalvarLog('Formulário: ' + TForm(Sender).Name);
      SalvarLog('Caption do Formulário: ' + TForm(Sender).Caption);
      SalvarLog('Nome da Classe: ' + E.ClassName);
      SalvarLog('Erro: ' + E.Message);
      SalvarLog('Arquivos Removidos da Pasta: ' + PastaServidor);
    end
  else
    begin
      SalvarLog('Formulário: ' + TForm(TComponent(Sender).Owner).Name);
      SalvarLog('Caption do Formulário:: ' + TForm(TComponent(Sender).Owner).Caption);
      SalvarLog('Nome da Classe: ' + E.ClassName);
      SalvarLog('Erro: ' + E.Message);
      SalvarLog('Arquivos Removidos da Pasta: ' + PastaServidor);
    end;

  LimparDiretorio;
  SalvarLog(StringofChar('=', 120));
  ShowMessage('1 - Ocorreu um problema ao realizar o procedimento: ' + E.Message + #13 + #13 + #13
    + '2 - Arquivos removidos da pasta: ' + PastaServidor + #13 + #13 + #13
    + '3 - Log salvo em: ' + ArquivoLog);
end;

procedure TGerenciadorExcecoes.LimparDiretorio;
var
  SR: TSearchRec;
  I: integer;
  Diretorio: String;
begin
  Diretorio := PastaServidor;
  I := FindFirst(Diretorio + '*.*', faAnyFile, SR);
  while I = 0 do
  begin
    if (SR.Attr and faDirectory) <> faDirectory then
    begin
      if not DeleteFile(PChar(Diretorio + SR.Name)) then
      begin
        Exit;
      end;
    end;
    I := FindNext(SR);
  end;

end;

var
  ExecoesProjeto: TGerenciadorExcecoes;

initialization
  ExecoesProjeto := TGerenciadorExcecoes.Create;

finalization
  ExecoesProjeto.Free;

end.
