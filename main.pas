unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  XMLRead, XMLWrite, DOM;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    ListBox1: TListBox;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    ListBox1.Items.AddStrings(OpenDialog1.Files);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Doc: TXMLDocument;
  TargetDoc: TXMLDocument;
  RootNode: TDOMElement;
  SourceNodes: TDOMNodeList;
  ImportedNode: TDOMNode;
  i, j: integer;
begin
  if not(SaveDialog1.Execute) then Exit;

  try
    TargetDoc := TXMLDocument.Create;
    RootNode := TargetDoc.CreateElementNS('http://www.topografix.com/GPX/1/1', 'gpx');   
    RootNode.SetAttribute('creator', 'GPX Merger');
    TargetDoc.AppendChild(RootNode);
    for i := 0 to ListBox1.Items.Count - 1 do
    begin
      try
        ReadXMLFile(Doc, ListBox1.Items[i]);
        SourceNodes := Doc.GetElementsByTagName('trk');
        for j := 0 to SourceNodes.Count - 1 do
        begin
          ImportedNode := TargetDoc.ImportNode(SourceNodes.Item[j], true);
          RootNode.AppendChild(ImportedNode);
        end;
      finally
        Doc.Free
      end;
    end;
    WriteXMLFile(TargetDoc, SaveDialog1.FileName);
  finally
    TargetDoc.Free;
  end;
end;


end.

