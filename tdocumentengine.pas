unit TDocumentEngine;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, ExtCtrls, SysUtils;

type


 nodeTypes     = (unknown, pageCommand, patternCommand, blockCommand, renderTargetDiv, renterTargetSpan, shapeDrawing, remoteResource, incomplete, erroneous );

 TPageCommandPtr = ^TPageCommand;
 TPageCommand    = Packed Record

   //------------------------      Basic COMMANDS       --------------------------// ASSUME PAGE IS RECTANGLE

   rectangleMargin      : Array of Integer; //------------------------------------// 4 side margins
   paragraphSpacing     : Integer; //---------------------------------------------// Space between paragraphs
   lineSpacing          : Integer; //---------------------------------------------// space between lines


   //------------------------      Font COMMANDS       ---------------------------// ASSUME FONT IS USED, and not pixel drawing

   isFontRenderable     : Boolean; //---------------------------------------------// Can be font or some other things
   fontBaseColor        : TColor;
   fontBaseSize         : Integer;
   fontBaseName         : String; //----------------------------------------------// Keep as string;
   fontZoomLevel        : Integer; //---------------------------------------------// Affects only fonts


   //------------------------      Page COMMANDS       ---------------------------// Colors etc

   pageBaseColor        : TColor; //----------------------------------------------// background color
   pagePencolor         : TColor; //----------------------------------------------// Default Drawing pen
   pageHighLightColor   : TColor; //----------------------------------------------// Default highlighting
   pageFillColor        : TColor; //----------------------------------------------// Default fill color of shapes



   //----------------------      Linked list items       -------------------------// Neighbors etc

   prev                 : TPageCommandPtr;
   next                 : TPageCommandPtr;

   id                   : Integer;


 end;



 stringSections         = Array of String; //-------------------------------------// A sentence can be made out of sections, each a string

 TPatternCommandPtr = ^TPatternCommand;
 TPatternCommand = Packed Record

   //----------------------     Match information        -------------------------// Colors etc

   pattern              : String;
   input                : String;
   matches              : Array of stringSections; //-----------------------------// Multiple matches. Each a sentence
                                                                                  // Sentence = stringSections



   //----------------------     Format information       -------------------------// Colors etc

   isFontRenderable     : Boolean; //---------------------------------------------// Can be font or some other things
   fontNewColor         : TColor;
   fontNewSize          : Integer;
   fontNewName          : String; //----------------------------------------------// Keep as string;
   fontNewFormat        : Integer; //---------------------------------------------// Such as bold or italics
                                                                                  // 0: None
                                                                                  // 1: Bold
                                                                                  // 2: Italics
                                                                                  // 3: Bold + Italics
                                                                                  // 4: Underline
                                                                                  // 4+1 = 5 : Underline + Bold
                                                                                  // 8: Strikethrough
                                                                                  // 16: Overline
                                                                                  // 32: Superscript
                                                                                  // 64: Subscript
                                                                                  //etc
   fontZoomLevel        : Integer; //---------------------------------------------// Affects only fonts
   


   //----------------------      Linked list items       -------------------------// Neighbors, ID etc

   prev                 : TPageCommandPtr;
   next                 : TPageCommandPtr;

   id                   : Integer;

 end;


 TBlockCommandPtr= ^TBlockCommand;

 TBlockCommand   = Packed Record

   //----------------------     Format information       -------------------------// Colors etc

   isFontRenderable     : Boolean; //---------------------------------------------// Can be font or some other things
   fontNewColor         : TColor;
   fontNewSize          : Integer;
   fontNewName          : String; //----------------------------------------------// Keep as string;
   fontNewFormat        : Integer; //---------------------------------------------// Such as bold or italics
                                                                                  // 0: None
                                                                                  // 1: Bold
                                                                                  // 2: Italics
                                                                                  // 3: Bold + Italics
                                                                                  // 4: Underline
                                                                                  // 4+1 = 5 : Underline + Bold
                                                                                  // 8: Strikethrough
                                                                                  // 16: Overline
                                                                                  // 32: Superscript
                                                                                  // 64: Subscript
                                                                                  //etc
   fontZoomLevel        : Integer; //---------------------------------------------// Affects only fonts



   //----------------------      Linked list items       -------------------------// Neighbors, ID etc

   prev                 : TPageCommandPtr;
   next                 : TPageCommandPtr;

   id                   : Integer;


 end;

 TDocumentNodePtr = ^TDocumentNode;
 TDocumentNode = Packed Record
   //----------------------------   BLOCK TYPE    --------------------------------//

   blockType            : nodeTypes;



   //----------------------------      DATA       --------------------------------//

   blockData            : String;  //---------------------------------------------// If Renderable text, then render the entire text
                                                                                  // otherwise, if remote resource, then decide
                                                                                  // based on file metadata

   blockFormatNode      : TBlockCommandPtr; //------------------------------------// this directly binds format commands to
                                                                                  // the node.
                                                                                  // This can be set to nil to save memory


   //----------------------      Linked list items       -------------------------// Neighbors, ID etc

   prev                 : TDocumentNodePtr;
   next                 : TDocumentNodePtr;

   parent               : TDocumentNodePtr;
   children             : Array of TDocumentNodePtr;

   id                   : Integer;
 end;


 TDocumentInputPtr = ^TDocumentInput;
 TDocumentInput = Packed Record
   inputVal              : String;
   prev                  : TDocumentInputPtr;
   next                  : TDocumentInputPtr;
 end;


 { TDocument }

 TDocument = Class
   public
     pageCommandSequence: TPageCommandPtr; //-------------------------------------// Page command is a set of global commands
                                                                                  // A doubly linked list where order of commands
                                                                                  // implies the precedence of application
     patternCommands    : Array of TPatternCommandPtr; //-------------------------// Array of separate pattern matching commands,
                                                                                  // EACH of which individually is a doubly linked list
                                                                                  // where the order again implies the precedence of
                                                                                  // application
     blockCommands      : Array of TBlockCommandPtr; //---------------------------// same thing.
                                                                                  // Each block command has an ID,
                                                                                  // so that the render Engine can look up the
                                                                                  // array and find the correct command
     documentTree_rootNode:TDocumentNodePtr; // -----------------------------------// A Doubly linked list, where
                                                                                  // each element can have children, where the
                                                                                  // chlidren are connected as a doubly linked list as well
                                                                                  // each element also has an pointer to a block command
                                                                                  // Each block takes the block command of its parent
                                                                                  // unless the parent is the page itself.
     rawInput           : TDocumentInputPtr; //-----------------------------------// linked list of document nodes,
                                                                                  // even command nodes are in the same list
     constructor  Create();

 end;

 { TDocumentEngine }

 { TDocumentParseEngine }

 TDocumentParseEngine = Class
   public
     currDocument       : TDocument;
     currInputBuffer    : String;

     constructor Create();

     function parseInput() : Boolean;

     function parse_pageCommand(strInput : String) : TPageCommandPtr;
     procedure insert_newPageCommand(pgCommand : TPageCommandPtr);

     function identifyBlock() : NodeTypes;

 end;

Implementation

{ TDocumentEngine }

constructor TDocumentParseEngine.Create;
begin
  currDocument  := TDocument.Create(); //-----------------------------------------// a NEW DOCUMENT IS CREATED

end;

function TDocumentParseEngine.parseInput: Boolean;
var
  i             : nodeTypes;
  outStr        : String;
  r             : Boolean;
  possibleBlock : TDocumentNodePtr;

  new_pageCommand: TPageCommandPtr;
begin
  i             := identifyBlock();
  r             := False;
  if i <> unknown then
  begin
     r          := True;
  end;

  writeStr(outStr, i);
  writeln(outStr);

  case i of
       pageCommand:
         begin
           new_pageCommand := parse_pageCommand(currInputBuffer);
           insert_newPageCommand(new_pageCommand);
           currInputBuffer := '';
         end;
  //     patternCommand:
  //       begin
  //          insert_newPatternCommand(currInputBuffer);
  //          currInputBuffer := '';
  //       end;
  //     blockCommand:
  //       begin
  //          possibleBlock := Nil;
  //          possibleBlock := parseBlock(currInputBuffer);
  //          insert_newDocumentBlock(possibleBlock);
  //          assing_relevantBlockFormatCommands();
  //       end;
       else
         begin
            currInputBuffer := '';
         end;
  end;

  writeLn('returning : '+ boolToStr(r));
  Result        := r;
end;

function TDocumentParseEngine.parse_pageCommand(strInput: String   ): TPageCommandPtr;
var
  new_pageCommand: TPageCommandPtr;
  dtls          : Array of String;
  command       : String;
  args          : Array of String;
  breakPos      : Integer;

  ii            : Integer;

  i_arr         : Array of Integer;
begin

  strInput      := Trim(strInput);
  strInput      := Copy(strInput, 3);
  Delete(strInput, Length(strInput), 1);
  strInput      := Trim(strInput);


  breakPos      := Pos(' ', strInput,1); //----------------------------------------// Offset explicitely zero. returns first match
  command       := Copy(strInput,1,breakPos);
  args          := (Copy(strInput, breakPos +1)).Split(',');

  new_pageCommand:= Nil;

  case command of
       'margin' :

         begin
           if Length(args) <> 0 then
           begin

              new_pageCommand := new(TPageCommandPtr);

              SetLength(i_arr, 0);

              for ii := 0 to length(args) - 1 do
              begin
                SetLength(i_arr, Length(i_arr) + 1);
                i_arr[Length(i_arr) -1] := StrToInt(args[ii]);
              end;

              new_pageCommand^.rectangleMargin := i_arr;

           end;
         end;

       // 'nextcommand' :

  end;

  Result        := new_pageCommand;

end;

procedure TDocumentParseEngine.insert_newPageCommand(pgCommand: TPageCommandPtr   );
begin

end;

function TDocumentParseEngine.identifyBlock : NodeTypes;
var
  classificationResult             : nodeTypes;
  testLine      : String;
  firstTwo      : String;
  lastTwo       : String;
  firstOne      : String;
  lastOne       : String;
begin
  classificationResult := unknown; //---------------------------------------------// NOT KNOWN YET

  testLine      := currInputBuffer; //--------------------------------------------// Set to current Input Buffer
  testLine      :=  Trim(testLine) ; //--------------------------------------------// remove the whitespaces

  if (length(testLine) = 0) then
  begin
     classificationResult := unknown;//-------------------------------------------// FAILED to classify, line length 0
  end
  else
  begin
    firstOne    :=  LeftStr(testLine, 1);
    firstTwo    :=  LeftStr(testLine, 2);

    lastOne     :=  RightStr(testLine, 1);
    lastTwo     :=  RightStr(testLine, 2);

    if (firstTwo = '..') and (lastTwo <> '\;') and (lastOne = ';') then
    begin
       classificationResult := pageCommand;
    end;

    if (firstTwo = '..') and (lastTwo <> '\;') and (lastOne <> ';') then
    begin
       classificationResult := incomplete;
    end;

    if (firstTwo = '.#') and (lastTwo <> '\;') and (lastOne = ';') then
    begin
       classificationResult := patternCommand;
    end;

    if (firstTwo = '.#') and (lastTwo <> '\;') and (lastOne <> ';') then
    begin
       classificationResult := incomplete;
    end;

    if (firstone = '.') and (firstTwo <> '..') and (firstTwo <> '.#') and (lastTwo <> '\;') and (lastOne = ';') then
    begin
       classificationResult := blockCommand;
    end;

    if (firstone = '.') and (firstTwo <> '..') and (firstTwo <> '.#') and (lastTwo <> '\;') and (lastOne <> ';') then
    begin
       classificationResult := incomplete;
    end;

    if (firstone <> '.') then
    begin
       classificationResult := renderTargetDiv;
    end;

  end;


  Result :=    classificationResult; //-------------------------------------------// RETURN
end;

{ TDocument }

constructor TDocument.Create;
begin
  pageCommandSequence := Nil;
  patternCommands := Nil;
  blockCommands := Nil;

  documentTree_rootNode := Nil;
  rawInput      := Nil;
end;

end.

