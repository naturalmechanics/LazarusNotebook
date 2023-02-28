unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Menus, StdCtrls, BCLabel, BCPanel, RichMemo, kmemo, TAdvancedMenu, Themes,
  TDocumentEngine, TRenderEngine,
  ColorBox, ActnList, LCLProc, Spin, EditBtn, BCTypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    ActionList1: TActionList;
    ColorButton1: TColorButton;
    ColorButton3: TColorButton;
    pageColorSourceSwitchButton: TButton;
    pageColorLabel: TBCLabel;
    BCLabel2: TBCLabel;
    BCLabel3: TBCLabel;
    BCLabel4: TBCLabel;
    BCLabel5: TBCLabel;
    BCLabel6: TBCLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    fontSelectionLabel: TBCLabel;
    ColorBox2: TColorBox;
    ColorButton2: TColorButton;
    fontSelectionLabel1: TBCLabel;
    fontColorSourceSwitchButton: TButton;
    scaleFontButton: TButton;
    fontGenLabel: TBCLabel;
    FontDialog1: TFontDialog;
    renderPanel: TBCPanel;
    Button1: TButton;
    Button2: TButton;
    applyMarginsButton: TButton;
    pageColorSelector: TColorBox;
    pageColorButton: TColorButton;
    ComboBox1: TComboBox;
    FileNameEdit1: TFileNameEdit;
    FileNameEdit2: TFileNameEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    codeInput: TRichMemo;
    setBaseFontSiteButton: TButton;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    SpinEdit7: TSpinEdit;
    SpinEdit8: TSpinEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    StatusBar1: TStatusBar;
    procedure codeInputClick(Sender: TObject);
    procedure codeInputKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure ColorButton1Click(Sender: TObject);
    procedure pageColorSelectorChange(Sender: TObject);
    procedure pageColorLabelClick(Sender: TObject);
    procedure pageColorButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pageColorButtonColorChanged(Sender: TObject);
    procedure pageColorSourceSwitchButtonClick(Sender: TObject);
    procedure pageColorSourceSwitchButtonMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Panel5Click(Sender: TObject);
    procedure Splitter1CanOffset(Sender: TObject; var NewOffset: Integer;
      var Accept: Boolean);
    procedure RenderMargin(Sender : TObject);
  private

  public

  end;

var
  Form1: TForm1;
  MainMenu      : TAdvancedMenu.TAdvancedMainMenu;

  mainEngine    : TDocumentEngine.TDocumentParseEngine;
  mainRenderer  : TRenderEngine.RenderEngine;

  isNewFile     : Boolean;
  lastParsedLine: Integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Splitter1CanOffset(Sender: TObject; var NewOffset: Integer;
  var Accept: Boolean);
begin



end;



procedure TForm1.FormCreate(Sender: TObject);
var
  MainMenuItems : Array of String;
  MainMenuNames : Array of String;

  FileMenuItems : Array of String;
  FileMenuItemNames:Array of String;

  saveMenuItems : Array of String;
  saveMenuItemNames: Array of String;

  ViewMenuItems : Array of String;
  ViewMenuItemNames: Array of String;

  mForm         : TForm;
  mPanel        : TPanel;

  qa            : TAdvancedMenu.TProc;
  pa            : TAdvancedMenu.TProc;
  sa            : TAdvancedMenu.TProc;

  ids           : Integer;

begin
  MainMenuItems := ['File', 'Edit', 'View', 'Engine', 'Tools', 'Help'];
  MainMenuNames := ['fileMenu', 'editMenu', 'viewMenu', 'engineMenu', 'toolMenu', 'helpMenu'];

  FileMenuItems := ['New', 'Open', 'Save', 'Import', 'Export', 'Print', 'Send', 'Close', 'Quit'];
  FileMenuItemNames:=['newMenu', 'openMenu', 'saveMenu', 'importMenu', 'exportMenu', 'printMenu', 'sendMenu', 'closeMenu', 'quitMenu' ];

  saveMenuItems := ['Save', 'Save as', 'Save a copy'];
  saveMenuItemNames := ['saveDirectMenu', 'saveAsMenu', 'saveCopyMenu'];

  ViewMenuItems := ['Render Automatically', 'Render Manually', '-', 'Zoom In', 'Zoom Out', 'Zoom to Fit', 'Zoom to Match Width', '-', 'Show Margins', 'Show Element Borders'];
  ViewMenuItemNames := ['autoRenderMenu', 'manualRenderMenu', 'divider1', 'zoomInMenu', 'zoomOutMenu', 'zoomFitMenu', 'zoomMatchWidthMenu', 'divider2', 'showMarginMenu', 'showBorderMenu'];



  MainMenu      := TAdvancedMenu.TAdvancedMainMenu.Create();
  MainMenu.create_mainMenu(MainMenuItems, MainMenuNames);

  MainMenu.add_mainMenuSubMenu_byName('fileMenu', FileMenuItems, FileMenuItemNames);  // SUBMENU ADDED BUT WILL NOT RENDER
  MainMenu.add_subMenuSubMenu_byName('saveMenu', saveMenuItems, saveMenuItemNames);

  MainMenu.add_mainMenuSubMenu_byName('viewMenu', ViewMenuItems, ViewMenuItemNames);  // SUBMENU ADDED BUT WILL NOT RENDER


  mPanel        := Panel1;
  MainMenu.render(mPanel);

  applyMarginsButton.Caption:= 'APPLY' + Chr(10) + 'MARGINS' ;

  codeInput.Clear;

  isNewFile     := True;
  Form1.Caption := '[Untitled File]';

  MainEngine    := TDocumentEngine.TDocumentParseEngine.Create();

  MainRenderer  := TRenderEngine.RenderEngine.Create();

  lastParsedLine:= -1;

end;

procedure TForm1.pageColorButtonColorChanged(Sender: TObject);
begin

  if pageColorSourceSwitchButton.Caption = '<' then //----------------------------// Allowed to Set the background color from the left selector
  begin
    renderPanel.Background.Color:= pageColorButton.ButtonColor ; //---------------// DO Set the background color from the left selector
    renderPanel.Background.Style:= bbsColor ; //----------------------------------// Without style, the color will not apply.
                                                                                  // It is only needed for first time tho
                                                                                  // but we dont know what will be used for the first time.
                                                                                  // So we set the style always

    pageColorLabel.Caption:=Format (' R : %d; G : %d; B : %d ', [Red(pageColorButton.ButtonColor), Green(pageColorButton.ButtonColor), Blue(pageColorButton.ButtonColor)]);
  end;                                                                     //-----// Show the color being Used

end;

procedure TForm1.pageColorSourceSwitchButtonClick(Sender: TObject); //------------// Pick the color the button is pointing to, and change the direction
                                                                                  // This is a quick switch method
var
  c             : TColor ;
begin

  if pageColorSourceSwitchButton.Caption = '>' then //----------------------------// If button is pointing to left
  begin
    renderPanel.Background.Color:= pageColorSelector.Selected; //-----------------// Pick the color, using ".Selected" method and apply it
    renderPanel.Background.Style:= bbsColor ; //----------------------------------// same logic as above

    c             := pageColorSelector.Selected; //-------------------------------// Originally, this was wrapped in ColorToRgb()
                                                                                  // The output of ColorToRgb() applied on .Selected
                                                                                  // was used as the color.
                                                                                  // I do not know why that is necessary.

    pageColorLabel.Caption:=Format (' R : %d; G : %d; B : %d ', [Red(c), Green(c), Blue(c)]); // Show the color
    pageColorSourceSwitchButton.Caption := '<'; //--------------------------------// flip the direction of the arrow so that
                                                                                  // Next time, the other color is picked

  end
  else
  begin   
    renderPanel.Background.Color:= pageColorButton.ButtonColor ; //---------------// same deal
    renderPanel.Background.Style:= bbsColor ;

    pageColorLabel.Caption:=Format (' R : %d; G : %d; B : %d ', [Red(pageColorButton.ButtonColor), Green(pageColorButton.ButtonColor), Blue(pageColorButton.ButtonColor)]);
    pageColorSourceSwitchButton.Caption := '>'; //--------------------------------// Flip again

  end;

end;

procedure TForm1.pageColorSourceSwitchButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TForm1.pageColorButtonClick(Sender: TObject);
begin
end;

procedure TForm1.pageColorLabelClick(Sender: TObject);
begin

end;

procedure TForm1.pageColorSelectorChange(Sender: TObject);
var
  c             : TColor;
begin

  if pageColorSourceSwitchButton.Caption = '>' then //----------------------------// If allowed to use the right hand color
  begin
    renderPanel.Background.Color:= pageColorSelector.Selected; //-----------------// Pick the color and apply
    renderPanel.Background.Style:= bbsColor ;

    c             := pageColorSelector.Selected; //-------------------------------// Again, thsi was wrapped in ColorToRgb()

    pageColorLabel.Caption:=Format (' R : %d; G : %d; B : %d ', [Red(c), Green(c), Blue(c)]); // Show.
  end;


end;

procedure TForm1.ColorButton1Click(Sender: TObject);
begin

end;

procedure TForm1.codeInputClick(Sender: TObject);
begin

end;

procedure TForm1.codeInputKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  blocks        : Array of String;
  i             : Integer;

  newBlock      : String;
  parseSuccLim  : Integer;
  Proc          : TAdvancedMenu.TProc;

begin
  if RightStr(Form1.Caption,1) <> '*' then
  begin
    Form1.Caption := Form1.Caption + '*';
  end;

  if Ord(Key) = 13 then
  begin
    //--------------------   FIND WHERE the Last change occured ------------------//

    lastParsedLine:= lastParsedLine ; //------------------------------------------// MAY NEED TO CHANGE in future


    //--------------------     EXTRACT the unparsed part   -----------------------//

    newBlock      := '';

    for i := lastParsedLine + 1 to codeInput.Lines.Count - 1 do
    begin
      newBlock    := newBlock + codeInput.Lines[i];
    end;

    //--------------------------  and feed it to the engine  ---------------------//

    MainEngine.currInputBuffer:=newBlock;



    //-----------------------     IF SUCCESSFUL, then update ---------------------//

    if (MainEngine.parseInput()) then
    begin
      lastParsedLine  := codeInput.CaretPos.Y -1;

      // MainRenderer.RenderPage (MainEngine.currDocument.pageCommandSequence, renderPanel);

      MainRenderer.margins := [10,50,20,90];
      Proc            := @MainRenderer.RenderMargin;
      renderPanel.OnPaint:=  Proc;
      renderPanel.Repaint;
    end;
  end;



end;


procedure TForm1.Panel5Click(Sender: TObject);
begin

end;


procedure TForm1.RenderMargin(Sender: TObject);
var
  targetPanel : TBCPanel;
  s1          : Integer;
  s2          : Integer;
  e1          : Integer;
  e2          : Integer;

begin

  targetPanel := (Sender as TBCPanel);
  targetPanel.Canvas.Pen.Color := clGrayText;

  s1          := 0;
  s2          := targetPanel.Height div 2;
  e1          := targetPanel.Width;
  e2          := targetPanel.Height div 2;
  targetPanel.Canvas.Line(s1,s2,e1,e2);
  // targetPanel.Canvas.Line(0, , , targetPanel.Height div 2);

end;

end.

