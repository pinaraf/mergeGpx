unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  XMLRead, XMLWrite, DOM, lcltype;

type

  { TForm1 }

  TForm1 = class(TForm)
    addFileBtn: TButton;
    mergeBtn: TButton;
    singleTrack: TCheckBox;
    Label1: TLabel;
    fileList: TListBox;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure addFileBtnClick(Sender: TObject);
    procedure fileListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mergeBtnClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.addFileBtnClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    fileList.Items.AddStrings(OpenDialog1.Files);
  end;
end;

procedure TForm1.fileListKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  NewList: TStrings;
  i: integer;
begin
  if Key = VK_DELETE then
  begin
    NewList := TStringList.Create;
    for i := 0 to fileList.Items.Count - 1 do
    begin
      if not(fileList.Selected[i]) then
         NewList.Add(fileList.Items[i]);
    end;
    fileList.Items := NewList;
  end;
end;

procedure renameTrack(TrackNode: TDOMNode; TrackIdx: integer);
var
  Children: TDOMNodeList;
  i: integer;
begin
  Children := TrackNode.GetChildNodes;
  for i := 0 to Children.Count - 1 do
  begin
    if Children.Item[i].NodeName = 'name' then
      Children.Item[i].TextContent := format('%d - %s', [TrackIdx, Children.Item[i].TextContent]);
  end;
end;

procedure TForm1.mergeBtnClick(Sender: TObject);
var
  Doc: TXMLDocument;
  TargetDoc: TXMLDocument;
  RootNode: TDOMElement;
  SourceNodes: TDOMNodeList;
  ImportedNode: TDOMNode;
  TargetNode: TDOMNode;
  SegmentNode: TDOMNode;
  TrackNode: TDOMNode;
  i, j: integer;
  trackIdx: integer;
begin
  if not(SaveDialog1.Execute) then Exit;

  trackIdx := 1;
  try
    TargetDoc := TXMLDocument.Create;
    RootNode := TargetDoc.CreateElementNS('http://www.topografix.com/GPX/1/1', 'gpx');   
    RootNode.SetAttribute('creator', 'GPX Merger');
    TargetDoc.AppendChild(RootNode);
    for i := 0 to fileList.Items.Count - 1 do
    begin
      try
        ReadXMLFile(Doc, fileList.Items[i]);
        SourceNodes := Doc.GetElementsByTagName('trk');
        for j := 0 to SourceNodes.Count - 1 do
        begin
          ImportedNode := TargetDoc.ImportNode(SourceNodes.Item[j], true);
          renameTrack(ImportedNode, trackIdx);
          trackIdx := trackIdx + 1;
          RootNode.AppendChild(ImportedNode);
        end;
      finally
        Doc.Free
      end;
    end;
    if singleTrack.Checked then
    begin
      SourceNodes := TargetDoc.GetElementsByTagName('trkseg');
      TargetNode := SourceNodes.Item[0].ParentNode;
      for i := 1 to SourceNodes.Count - 1 do
      begin
        SegmentNode := SourceNodes.Item[i];
        TrackNode := SegmentNode.ParentNode;
        TargetNode.AppendChild(TrackNode.DetachChild(SegmentNode));
        TrackNode.ParentNode.RemoveChild(TrackNode);
      end;
    end;
    WriteXMLFile(TargetDoc, SaveDialog1.FileName);
    ShowMessage('Fichier généré');
    fileList.Clear;
  finally
    TargetDoc.Free;
  end;
end;


end.

