{***********************************************************************************************************************
 *
 * TERRA Game Engine
 * ==========================================
 *
 * Copyright (C) 2003, 2014 by S�rgio Flores 
 *
 ***********************************************************************************************************************
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 **********************************************************************************************************************
 * TERRA_UI
 * Implements the UI class
 ***********************************************************************************************************************
}
Unit TERRA_UI;
{$I terra.inc}

Interface
Uses {$IFDEF USEDEBUGUNIT}TERRA_Debug,{$ENDIF}
  TERRA_String, TERRA_Font, TERRA_Collections, TERRA_Image, TERRA_Utils, TERRA_TextureAtlas, TERRA_Application,
  TERRA_Vector3D, TERRA_Vector2D, TERRA_Matrix3x3, TERRA_Color, TERRA_Texture, TERRA_Math, TERRA_Tween,
  TERRA_SpriteManager, TERRA_Vector4D, TERRA_GraphicsManager, TERRA_FontRenderer, TERRA_UITransition,
  TERRA_ClipRect, TERRA_Hashmap;

Const
  // widget tween
  wtPositionX   = 1;
  wtPositionY   = 2;
  wtColorRed    = 3;
  wtColorGreen  = 4;

  wtColorBlue   = 5;
  wtColorAlpha  = 6;
  wtRotation    = 7;
  wtScale       = 8;
  wtSaturation  = 9;

  // custom tweens
  wtValue       = 100;

  waTopLeft     = 0;
  waTopCenter   = 1;
  waTopRight    = 2;
  waLeftCenter  = 3;
  waCenter      = 4;
  waRightCenter = 5;
  waBottomLeft     = 6;
  waBottomCenter   = 7;
  waBottomRight    = 8;

  widgetAnimateAlpha  = 1;
  widgetAnimatePosX   = 2;
  widgetAnimatePosY   = 4;
  widgetAnimateRotation = 8;
  widgetAnimateScale    = 16;
  widgetAnimateSaturation  = 32;
  widgetAnimatePosX_Bottom = 64;
  widgetAnimatePosY_Bottom = 128;

  TextureAtlasWidth = 1024;
  TextureAtlasHeight = 512;

Type
  UI = Class;

  UISkinLayout = Class(TERRAObject)
    Protected
      _Target:TextureAtlasItem;
    Public
      X:Array[0..2] Of Single;
      Y:Array[0..2] Of Single;

      Constructor Create(Source:TextureAtlasItem);
      Procedure Release; Override;

      Function GCSX(I:Integer): Single;
      Function GCSY(J:Integer): Single;

      Function GetWidth(Width:Integer):Single;
      Function GetHeight(Height:Integer):Single;
  End;

  UICursor = Class(TERRAObject)
    Protected
      _UI:UI;
      _Name:TERRAString;
      _Item:TextureAtlasItem;
      _OfsX:Integer;
      _OfsY:Integer;

      Procedure Render;

    Public
      Constructor Create(Name:TERRAString; UI:UI; OfsX:Integer = 0; OfsY:Integer=0);
      Procedure Release; Override;

      Property UI:UI Read _UI;
  End;

  Widget = Class;
  WidgetClass = Class Of Widget;
  WidgetEventHandler = Function (Source:Widget):Boolean; CDecl;

	Widget = Class(HashMapObject)
    Private
      _UI:UI;
      _Next:Widget;
      _Tested:Boolean;
      _RenderFrameID:Cardinal;

		Protected
			_Parent:Widget;
			_Visible:Boolean;
			_Position:Vector2D;
      _Layer:Single;
      _Picked:Boolean;
      _ComponentList:Array Of TextureAtlasItem;
      _ComponentCount:Integer;
      _TweenList:Array Of Tween;
      _TweenCount:Integer;
      _Tooltip:TERRAString;
      _Align:Integer;
      _NeedsUpdate:Boolean;
      _NeedsHide:Boolean;

      _Enabled:Boolean;

      _TabIndex:Integer;
      _TabControl:Widget;

      _Dragging: Boolean;
      _DragX: Single;
      _DragY: Single;
      _DragStart:Vector2D;

      _ChildrenList:Array Of Widget;
      _ChildrenCount:Integer;

      _FontRenderer:FontRenderer;

      _Transform:Matrix3x3;
      _TransformChanged:Boolean;
      _Corners:Array[0..3] Of Vector2D;

      _UsingHighLightProperties:Boolean;
      _SelectedWithKeyboard:Boolean;
      _InheritColor:Boolean;

      _Hitting:Boolean;
      _HitTime:Cardinal;

      _Size:Vector2D;
      _Pivot:Vector2D;
      _Center:Vector2D;

      _OriginalColor:Color;
      _OriginalPosition:Vector2D;

      _Color:Color;
      _Rotation:Single;
      _Scale:Single;
      _Saturation:Single;
      _ColorTable:Texture;
      _Font:Font;

      _ClipRect:ClipRect;

      _Scroll:Widget;
      _ScrollValue:Single;

      _VisibleFrame:Cardinal;

      _DropShadowColor:Color;

      _HighlightGroup:Integer;

      Procedure CopyValue(Other:CollectionObject); Override;
      Function Sort(Other:CollectionObject):Integer; Override;

      Function GetUpControl():Widget;
      Function GetDownControl():Widget;
      Function GetLeftControl():Widget;
      Function GetRightControl():Widget;

      Procedure SetVisible(Value:Boolean);
      Procedure SetPosition(Pos:Vector2D);
      Procedure SetLayer(Z:Single);
      Procedure SetColor(MyColor:Color);
      Procedure SetRotation(const Value: Single);
      Procedure SetSaturation(const Value: Single);
      Procedure SetScale(const Value: Single);
      Procedure SetFont(const Value: TERRA_Font.Font);

      Function LoadComponent(Name:TERRAString):Integer;

      Function GetTabControl():Widget;

      Procedure PruneTweens;
      Function CreateCustomTween(TweenType:Integer; TargetValue:Single):Tween; Virtual;

      Procedure UpdateHighlight(); Overload;
      Procedure UpdateHighlight(Condition:Boolean); Overload;

      Function IsSelected: Boolean;

			Function OnKeyDown(Key:Word):Boolean;Virtual;
			Function OnKeyUp(Key:Word):Boolean;Virtual;
			Function OnKeyPress(Key:Word):Boolean;Virtual;

      Function HasMouseOver():Boolean; Virtual;

      Procedure OnHit(); Virtual;
      Procedure OnHighlight(Prev:Widget); Virtual;
      Procedure StartHighlight(); Virtual;
      Procedure StopHighlight(); Virtual;

      Function IsSelectable():Boolean; Virtual;
      Function CanHighlight(GroupID:Integer):Boolean;

      Function GetFontRenderer: FontRenderer;

      Function OutsideClipRect(X,Y:Integer):Boolean;

      Function CanRender():Boolean;

      Procedure RenderChildren();

      Procedure ResetClipRect();

      Procedure SetEnabled(Value:Boolean);

		Public
      Tag:Integer;
      DisableHighlights:Boolean;
      DisableUIColor:Boolean;
      UserData:TERRAString;
      Draggable:Boolean;

      OnMouseClick:WidgetEventHandler;
      OnExtendedClick:WidgetEventHandler;
      OnMouseRelease:WidgetEventHandler;
      OnMouseOver:WidgetEventHandler;
      OnMouseOut:WidgetEventHandler;
      OnBeginDrag:WidgetEventHandler;
      OnEndDrag:WidgetEventHandler;

      Constructor Create(Const Name:TERRAString; Owner:UI; Parent:Widget);
      Procedure Release; Override;

      Procedure Render; Virtual;

      Procedure UpdateRects; Virtual; Abstract;
      Function UpdateTransform():Boolean; Virtual;

			Function IsVisible:Boolean;
			Function GetAbsolutePosition:Vector2D;
			Function GetRelativePosition:Vector2D;
			Function GetLayer:Single;
      Function GetColor:Color;
			Function GetSaturation:Single;
      Function GetColorTable:Texture;
      Function GetHighlightGroup:Integer;

      Procedure SetPositionRelative(Other:Widget; OfsX, OfsY:Single);

      Procedure GetScrollOffset(Out OfsX, OfsY:Single);

      Function AddTween(TweenType:Integer; TargetValue:Single; Time:Integer; Delay:Integer=0):Tween;
      Function HasTweens:Boolean;

			Procedure OnLanguageChange();Virtual;

      Function OnRegion(X,Y:Integer): Boolean; Virtual;
      Function OnCustomRegion(X,Y:Integer; X1,Y1,X2,Y2:Single):Boolean;
      
      Procedure AddChild(W:Widget);
      Function GetChild(Index:Integer):Widget; Overload;
      Function GetChild(Const Name:TERRAString):Widget; Overload;
      Function GetChild(ChildClass:WidgetClass; Index:Integer = 0):Widget; Overload;

      Function OnSelectRight():Boolean; Virtual;
      Function OnSelectLeft():Boolean; Virtual;
      Function OnSelectUp():Boolean; Virtual;
      Function OnSelectDown():Boolean; Virtual;
      Function OnSelectAction():Boolean; Virtual;
      Function OnSelectAlternateAction():Boolean; Virtual;

      Function IsOutsideScreen():Boolean;

      Procedure SetChildrenVisibilityByTag(Tag:Integer; Visibility:Boolean);

      Procedure SetClipRect(Value:ClipRect);
      Procedure UpdateClipRect(Clip:ClipRect; LeftBorder:Single = 0.0; TopBorder:Single = 0.0; RightBorder:Single = 0.0; BottomBorder:Single = 0.0);

      Procedure SetName(Const Value:TERRAString);

      Procedure DrawComponent(Index:Integer; Const Offset:Vector3D; X1,Y1,X2,Y2:Single; Color:Color; ScaleColor:Boolean=True);
      Procedure DrawWindow(Index:Integer; Const Offset:Vector3D; Width, Height:Integer; Layout:UISkinLayout; Color:Color);
      Procedure DrawText(Const Text:TERRAString; Const Offset:Vector3D; C:Color; Scale:Single; UseFont:Font = Nil);

      Function IsHighlighted():Boolean;
      Function HasHighlightedChildren():Boolean;

			Function OnMouseDown(X,Y:Integer; Button:Word):Boolean;Virtual;
			Function OnMouseUp(X,Y:Integer; Button:Word):Boolean;Virtual;
			Function OnMouseMove(X,Y:Integer):Boolean;Virtual;
			Function OnMouseWheel(X,Y:Integer; Delta:Integer):Boolean;Virtual;

      Function GetIndex():Integer;

      Function IsSameFamily(Other:Widget):Boolean;

      Function GetSize:Vector2D; Virtual;

      Function GetFont:TERRA_Font.Font;

      Function GetClipRect():ClipRect;

      Procedure CancelDrag();

      Function Show(AnimationFlags:Integer; Delay:Integer=0; EaseType:Integer = -1; Duration:Integer=500):Tween;
      Function Hide(AnimationFlags:Integer; Delay:Integer=0; EaseType:Integer = -1; Duration:Integer=500):Tween;
      Function ToggleVisibility(AnimationFlags:Integer; Delay:Integer=0; EaseType:Integer = -1; Duration:Integer=500):Tween;

      //Procedure CenterOnScreen(CenterX:Boolean = True; CenterY:Boolean = True);
      //Procedure CenterOnParent(CenterX:Boolean = True; CenterY:Boolean = True);
      Procedure CenterOnPoint(X,Y:Single);

			Property Visible:Boolean Read IsVisible Write SetVisible;
			Property Position:Vector2D Read GetAbsolutePosition Write SetPosition;
      Property Pivot:Vector2D Read _Pivot Write _Pivot;
      Property Size:Vector2D Read GetSize;
			Property Layer:Single Read GetLayer Write SetLayer;
			Property Name:TERRAString Read _Key Write SetName;

      Property TabIndex:Integer Read _TabIndex Write _TabIndex;
      Property TabControl:Widget Read GetTabControl Write _TabControl;

      Property InheritColor:Boolean Read _InheritColor Write _InheritColor;

      Property Color:TERRA_Color.Color Read GetColor Write SetColor;
      Property ColorTable:Texture Read GetColorTable Write _ColorTable;
      Property Saturation:Single Read GetSaturation Write SetSaturation;
      Property Rotation:Single Read _Rotation Write SetRotation;
      Property Scale:Single Read _Scale Write SetScale;
      Property Font:TERRA_Font.Font Read GetFont Write SetFont;

      Property Scroll:Widget Read _Scroll Write _Scroll;

      Property Parent:Widget Read _Parent Write _Parent;
      Property Align:Integer Read _Align Write _Align;

      Property ChildrenCount:Integer Read _ChildrenCount;

      Property ClipRect:ClipRect Read GetClipRect Write SetClipRect;

      Property Center:Vector2D Read _Center Write _Center;

      Property Enabled:Boolean  Read _Enabled Write SetEnabled;

      Property Selected:Boolean Read IsSelected;

      Property DropShadowColor:Color Read _DropShadowColor Write _DropShadowColor;

      Property HighlightGroup:Integer Read GetHighlightGroup Write _HighlightGroup;

      Property UI:UI Read _UI;
      Property FontRenderer:FontRenderer Read GetFontRenderer Write _FontRenderer;
	End;

  UI = Class(TERRAObject)
    Protected
      _Visible:Boolean;

      _CursorList:Array Of UICursor;
      _CursorCount:Integer;
      _CurrentCursor:UICursor;
      _CursorPos:Vector2D;

      _VirtualKeyboard:Widget;

      _FontRenderer:FontRenderer;

		  _Focus:Widget;
      _Dragger:Widget;
      _Modal:Widget;
      _Highlight:Widget;
      _First:Widget;
      _Draw:Boolean;

      _ColorTable:Texture;
      _Color:Color;
      _Saturation:Single;

      _Transition:UITransition;
      _Widgets:HashMap;

      _DefaultFont:Font;
      _Language:TERRAString;

      _WndCallback1:WidgetEventHandler;
      _WndCallback2:WidgetEventHandler;
      _PrevHighlight:Widget;

      _LastWidget:Widget;

      _Transform:Matrix3x3;
      _InverseTransform:Matrix3x3;
      _ClipRect:ClipRect;

      Procedure UpdateLanguage();

      Procedure SetColorTable(const Value:Texture);
      Procedure SetDefaultFont(const Value: Font);
      Procedure SetHighlight(const Value: Widget);
      Procedure SetDragger(const Value: Widget);

      Function GetHighlight:Widget;

      Procedure CloseWnd();
      Procedure InitStuff();

      Procedure OnOrientationChange;

      Procedure SetVisible(const Value: Boolean);

      Function GetFontRenderer():FontRenderer;

    Public
      CloseButton:Widget;

      Key_Up:Integer;
      Key_Down:Integer;
      Key_Right:Integer;
      Key_Left:Integer;
      Key_Action:Integer;
      Key_Action2:Integer;
      Key_Cancel:Integer;

      System_Wnd:Widget;
      System_Text:Widget;
      System_Btn:Array[0..2] Of Widget;
      System_BG:Widget;

      DefaultEaseType:Integer;

      Constructor Create;
      Procedure Release; Override;

      Procedure AddWidget(MyWidget:Widget);
      Procedure DeleteWidget(MyWidget:Widget);
      Function GetWidget(Const Name:TERRAString):Widget;

      Function AllowsEvents(W:Widget):Boolean;

      Function AddQuad(Const StartPos, EndPos:Vector2D; Const TexCoord1, TexCoord2:Vector2D; MyColor:Color; Z:Single; PageID:Integer;
        Const Transform:Matrix3x3; Saturation:Single; ColorTable:Texture; Const Clip:ClipRect):QuadSprite;

      Procedure Clear;

      Function SelectNearestWidget(Target:Widget):Widget;
      Procedure GetFirstHighLight(GroupID:Integer);

      Procedure ConvertGlobalToLocal(Var X, Y:Integer);
      Procedure ConvertLocalToGlobal(Var X, Y:Integer);

		  Function OnKeyDown(Key:Word):Widget;
		  Function OnKeyUp(Key:Word):Widget;
		  Function OnKeyPress(Key:Word):Widget;

		  Function OnMouseDown(X,Y:Integer;Button:Word):Widget;
		  Function OnMouseUp(X,Y:Integer;Button:Word):Widget;
		  Function OnMouseWheel(X,Y:Integer; Delta:Integer):Widget;
		  Function OnMouseMove(X,Y:Integer):Widget;

      Procedure Render;

      Procedure AfterEffects;

      Procedure SetTransform(Const M:Matrix3x3);

      Procedure SetFocus(W:Widget);
      Procedure SetTransition(MyTransition:UITransition);

      Function GetVirtualKeyboard():Widget;

      Procedure SetFontRenderer(const Value: FontRenderer);

      Function LoadCursor(Const Name:TERRAString; OfsX:Integer = 0; OfsY:Integer = 0):UICursor;

      Procedure MessageBox(Msg:TERRAString; Callback: WidgetEventHandler = Nil);
      Procedure ChoiceBox(Msg, Option1, Option2:TERRAString; Callback1:WidgetEventHandler = Nil; Callback2: WidgetEventHandler = Nil);
      Procedure ClearChoiceBox();
      Procedure ShowModal(W:Widget);
      Procedure InitTempWidgets();

      Function OnRegion(X, Y:Integer):Boolean;

      Property Color:TERRA_Color.Color Read _Color Write _Color;
      Property ColorTable:Texture Read _ColorTable Write SetColorTable;
      Property Saturation:Single Read _Saturation Write _Saturation;

      Property Focus:Widget Read _Focus Write SetFocus;
      Property Dragger:Widget Read _Dragger Write SetDragger;

      Property Transition:UITransition Read _Transition Write SetTransition;

      Property VirtualKeyboard:Widget Read GetVirtualKeyboard;

      Property Widgets:HashMap Read _Widgets;

      Property LastWidget:Widget Read _LastWidget;

      Property DefaultFont:Font Read _DefaultFont Write SetDefaultFont;
      Property Modal:Widget Read _Modal Write _Modal;
      Property Highlight:Widget Read GetHighlight Write SetHighlight;

      Property Visible:Boolean Read _Visible Write SetVisible;

      Property Transform:Matrix3x3 Read _Transform Write SetTransform;

      Property FontRenderer:FontRenderer Read GetFontRenderer Write SetFontRenderer;

      Property ClipRect:ClipRect Read _ClipRect Write _ClipRect;
    End;

  UIManager = Class(ApplicationComponent)
    Protected
      _TextureAtlas:TextureAtlas;
      _UpdateTextureAtlas:Boolean;

      _UIList:Array Of UI;
      _UICount:Integer;

      _Ratio:Single;

      _FontRenderer:FontRenderer;

      Procedure OnLanguageChange; Override;
      Procedure OnOrientationChange; Override;

      Procedure UpdateRatio();

      Function GetWidth:Integer;
      Function GetHeight:Integer;

      Function GetTextureAtlas:TextureAtlas;

      Function GetFontRenderer: FontRenderer;

    Public
      Procedure Init; Override;

      Procedure Release; Override;

      Class Function Instance:UIManager;

      Procedure AddUI(UI:UI);
      Procedure RemoveUI(UI:UI);

      Procedure TextureAtlasClear();

      Procedure Render;
      Procedure AfterEffects;

      Procedure SetFontRenderer(const Value: FontRenderer);

      Function GetUI(Index:Integer):UI;

      Property Width:Integer Read GetWidth;
      Property Height:Integer Read GetHeight;

      Property TextureAtlas:TextureAtlas Read _TextureAtlas;

      Property Ratio:Single Read _Ratio;

      Property Count:Integer Read _UICount;

      Property FontRenderer:FontRenderer Read GetFontRenderer Write SetFontRenderer;
  End;

Function GetSpriteZOnTop(W:Widget; Ofs:Single = 1.0):Single;

Implementation
Uses TERRA_Error, TERRA_OS, TERRA_Widgets, TERRA_Stream, TERRA_Renderer,
  TERRA_Matrix4x4, TERRA_Log, TERRA_FileUtils, TERRA_FileManager, TERRA_InputManager, TERRA_UIVirtualKeyboard;

Var
  _UIManager_Instance:ApplicationObject = Nil;

Function GetSpriteZOnTop(W:Widget; Ofs:Single):Single;
Begin
  //Result := (100 - W.GetLayer()) - Ofs;
  Result := W.GetLayer() + Ofs;
End;

Procedure ShowWidget(Source:Widget); CDecl;
Begin
  Source.Visible := True;
End;

Procedure HideWidget(Source:Pointer); CDecl;
Var
  W:Widget;
Begin
  W := Widget(Source);
  W._Color := W._OriginalColor;
  W._Position := W._OriginalPosition;
  W.SetVisible(False);

  If (W.UI.Highlight = W) Or (W.HasHighlightedChildren()) Then
    W.UI.Highlight := Nil;
End;

Function Widget.HasHighlightedChildren():Boolean;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I] = UI.Highlight) Then
  Begin
    Result := True;
    Exit;
  End Else
  Begin
    Result := _ChildrenList[I].HasHighlightedChildren();
    If Result Then
      Exit;
  End;

  Result := False;
End;

Function Widget.IsHighlighted: Boolean;
Begin
  Result := (UI._Highlight = Self) Or (_Parent<>Nil) And (_Parent.IsHighlighted);
End;

{
Procedure Widget.CenterOnScreen(CenterX:Boolean = True; CenterY:Boolean = True);
Begin
  _Align := waTopLeft;
  Self.UpdateRects;

  If CenterX Then
    _Position.X := (UIManager.Instance.Width * 0.5) - (_Size.X * 0.5  * _Scale);
  If CenterY Then
    _Position.Y := (UIManager.Instance.Height * 0.5) - (_Size.Y * 0.5 *_Scale);
End;}

Procedure Widget.CenterOnPoint(X,Y:Single);
Begin
  _Align := waTopLeft;
  Self.UpdateRects;

  _Position.X := X - _Size.X * 0.5;
  _Position.Y := Y - _Size.Y * 0.5;
End;

{Procedure Widget.CenterOnParent(CenterX, CenterY: Boolean);
Begin
  If Not Assigned(_Parent) Then
    Exit;

  Self.UpdateRects;
  _Align := waTopLeft;

  If CenterX Then
    _Position.X := (_Parent._Size.X * 0.5) - (_Size.X * 0.5);
  If CenterY Then
    _Position.Y := (_Parent._Size.Y * 0.5) - (_Size.Y * 0.5);
End;}

Procedure Widget.StartHighlight;
Begin
  Self._Color := ColorBlack;
End;

Procedure Widget.StopHighlight;
Begin
  Self._Color := ColorWhite;
End;

Procedure Widget.OnHit();
Var
  N:Integer;
  A,B:Single;
Begin
  A := Self.Color.R/255;
  B := A * 0.5;
  N := 150;
  Self.AddTween(wtColorRed, B, N);
  Self.AddTween(wtColorGreen, B, N);
  Self.AddTween(wtColorBlue, B, N);

  Self.AddTween(wtColorRed, A, N, N);
  Self.AddTween(wtColorGreen, A, N, N);
  Self.AddTween(wtColorBlue, A, N, N);
End;

Function Widget.CreateCustomTween(TweenType: Integer; TargetValue: Single): Tween;
Begin
  RemoveHint(TweenType + Trunc(TargetValue));
  Result := Nil;
End;

Procedure Widget.OnLanguageChange;
Begin
  // do nothing
End;

Procedure Widget.Release();
Begin
  TweenManager.Instance.RemoveTween(Self);

  If (UI.Dragger = Self) Then
    UI.Dragger := Nil;

  If (UI.Focus = Self) Then
    UI.Focus := Nil;

  If (UI.LastWidget = Self) Then
    UI._LastWidget := Nil;
End;

Function Widget.GetSize: Vector2D;
Begin
  If (_Size.X<=0) Or (_Size.Y<=0) Then
    Self.UpdateRects();

  Result.X := _Size.X;
  Result.Y := _Size.Y;
End;


{ Widget }
Constructor Widget.Create(Const Name:TERRAString; Owner: UI; Parent:Widget);
Begin
  _Key := Name;
   
  _Visible := True;
  _Enabled := True;
  _UI := Owner;

  _Parent := Parent;

  _Pivot := VectorCreate2D(0.5, 0.5);
  _Scale := 1.0;
  _Rotation := 0.0;
  _Saturation := 1.0;
  _Color := ColorWhite;
  _ColorTable := Nil;
  _FontRenderer := Owner._FontRenderer;
  _UI := Owner;

  _ClipRect.Style := clipNothing;

  //_DropShadowColor := ColorNull;
  _DropShadowColor := ColorGrey(0, 255);

  _Font := Owner._DefaultFont;
  _FontRenderer := UI.FontRenderer;

  _InheritColor := True;
  _TransformChanged := True;

  UI.AddWidget(Self);
End;

Procedure Widget.CopyValue(Other: CollectionObject);
Begin
  RemoveHint(Cardinal(Other));
  RaiseError('Not implemented!');
End;

Function Widget.IsSameFamily(Other: Widget): Boolean;
Begin
  Result := (Self = Other);
  If (Not Result) And (Other<>Nil) And (Other._Parent<>Nil) Then
    Result := IsSameFamily(Other._Parent);
End;

Function Widget.IsSelectable():Boolean;
Begin
  Result := Assigned(Self.OnMouseClick);
End;

Function Widget.CanHighlight(GroupID:Integer): Boolean;
Begin
  Result := (Self.Visible) And (Self.Enabled) And (Self.IsSelectable()) And (Self.HighlightGroup = GroupID) And (Not Self.HasTweens());
End;

Function Widget.GetDownControl(): Widget;
Var
  W:Widget;
  It:Iterator;
  Base:Vector2D;
  GroupID:Integer;
  Min, Dist, Y:Single;
Begin
  Result := Nil;

  Min := 99999;
  Base := Self.Position;
  Base.Y := Base.Y + Self.Size.Y;
  GroupID := Self.HighlightGroup;

  It := Self.UI.Widgets.GetIterator();
  While It.HasNext() Do
  Begin
    W := Widget(It.Value);
    If (W = Self) Or (Not W.CanHighlight(GroupID)) Then
      Continue;

    Y := W.Position.Y;
    If (Y<Base.Y) Then
      Continue;

    Dist := W.Position.Distance(Base);
    If (Dist< Min) Then
    Begin
      Min := Dist;
      Result := W;
    End;
  End;
  ReleaseObject(It);
End;

Function Widget.GetUpControl(): Widget;
Var
  W:Widget;
  It:Iterator;
  P,Base:Vector2D;
  GroupID:Integer;
  Min, Dist, Y:Single;
Begin
  Result := Nil;

  Min := 99999;
  Base := Self.Position;
  GroupID := Self.HighlightGroup;

  It := Self.UI.Widgets.GetIterator();
  While It.HasNext() Do
  Begin
    W := Widget(It.Value);
    If (W = Self) Or (Not W.CanHighlight(GroupID)) Then
      Continue;

    P := W.Position;
    P.Y := P.Y + W.Size.Y;
    Dist := P.Distance(Base);
    If (Dist< Min) And (P.Y<Base.Y) Then
    Begin
      Min := Dist;
      Result := W;
    End;
  End;
  ReleaseObject(It);
End;

Function Widget.GetRightControl(): Widget;
Var
  W:Widget;
  It:Iterator;
  Base:Vector2D;
  Min, Dist, X:Single;
  GroupID:Integer;
Begin
  Result := Nil;

  Min := 99999;
  Base := Self.Position;
  GroupID := Self.HighlightGroup;

  It := Self.UI.Widgets.GetIterator();
  While It.HasNext() Do
  Begin
    W := Widget(It.Value);
    If (W = Self) Or (Not W.CanHighlight(GroupID)) Then
      Continue;

    X := W.Position.X;
    Dist := W.Position.Distance(Base);
    If (Dist< Min) And (X>Base.X + Self.Size.X) Then
    Begin
      Min := Dist;
      Result := W;
    End;
  End;
  ReleaseObject(It);
End;

Function Widget.GetLeftControl(): Widget;
Var
  W:Widget;
  It:Iterator;
  P, Base:Vector2D;
  Min, Dist:Single;
  GroupID:Integer;
Begin
  Result := Nil;

  Min := 99999;
  Base := Self.Position;
  GroupID := Self.HighlightGroup;

  It := Self.UI.Widgets.GetIterator();
  While It.HasNext() Do
  Begin
    W := Widget(It.Value);
    If (W = Self) Or (Not W.CanHighlight(GroupID)) Then
      Continue;

    P := W.Position;
    P.X := P.X + W.Size.X;
    Dist := P.Distance(Base);
    If (Dist< Min) And (P.X<Base.X) Then
    Begin
      Min := Dist;
      Result := W;
    End;
  End;
  ReleaseObject(It);
End;

Function Widget.Show(AnimationFlags:Integer; Delay, EaseType, Duration:Integer):Tween;
Var
  X, Y, TY:Single;
Begin
  Log(logDebug, 'UI', 'Showing '+Self.Name+' with animation '+IntToString(AnimationFlags));

  _Visible := True;
  Result := Nil;

  Self._NeedsHide := False;

  If EaseType<0 Then
    EaseType := UI.DefaultEaseType;

  If (AnimationFlags And widgetAnimatePosX<>0) Then
  Begin
    X := _Position.X;
    _Position.X := -(Self.Size.X);
    Result := AddTween(wtPositionX, X, Duration, Delay);
  End Else
  If (AnimationFlags And widgetAnimatePosX_Bottom<>0) Then
  Begin
    X := _Position.X;
    _Position.X := UIManager.Instance.Width + (Self.Size.X);
    Result := AddTween(wtPositionX, X, Duration, Delay);
  End;

  If (AnimationFlags And widgetAnimatePosY<>0) Then
  Begin
    Y := _Position.Y;

    TY := -Self.Size.Y;
    If (Self.Align = waCenter) Or (Self.Align = waLeftCenter) Or (Self.Align = waRightCenter) Then
      TY := TY - (UIManager.Instance.Height * 0.5);

    _Position.Y := TY;

    Result := AddTween(wtPositionY, Y, Duration, Delay);
  End Else
  If (AnimationFlags And widgetAnimatePosY_Bottom<>0) Then
  Begin
    Y := _Position.Y;

    TY := UIManager.Instance.Height + Self.Size.Y;
    If (Self.Align = waCenter) Or (Self.Align = waLeftCenter) Or (Self.Align = waRightCenter) Then
      TY := TY + (UIManager.Instance.Height * 0.5);

    _Position.Y := TY;
    Result := AddTween(wtPositionY, Y, Duration, Delay);
  End;

  If (AnimationFlags And widgetAnimateAlpha<>0) Then
  Begin
    _Color.A := 0;
    Result := AddTween(wtColorAlpha, 1.0, Duration, Delay);
  End;

  If (AnimationFlags And widgetAnimateRotation<>0) Then
  Begin
    _Rotation := 360.0 * RAD;
    Result := AddTween(wtRotation, 0.0, Duration, Delay);
  End;

  If (AnimationFlags And widgetAnimateScale<>0) Then
  Begin
    _Scale := 0.0;
    Result := AddTween(wtScale, 1.0, Duration, Delay);
  End;

  If (AnimationFlags And widgetAnimateSaturation<>0) Then
  Begin
    _Saturation := 0.0;
    Result := AddTween(wtSaturation, 1.0, Duration, Delay);
  End;

  If Assigned(Result) Then
    Result.EaseType := EaseType;
End;

Function Widget.Hide(AnimationFlags:Integer; Delay, EaseType, Duration:Integer):Tween;
Var
  Ofs:Single;
Begin
  _OriginalPosition := _Position;
  _OriginalColor := _Color;

  Result := Nil;

  If EaseType<0 Then
    EaseType := UI.DefaultEaseType;
  
  If (AnimationFlags And widgetAnimatePosX<>0) Then
  Begin
    Ofs := -Self.Size.X;

    If (Self.Align = waCenter) Or (Self.Align = waTopCenter) Or (Self.Align = waBottomCenter) Then
      Ofs := Ofs - Self.Position.X;

    Result := AddTween(wtPositionX, Ofs, Duration, Delay);
  End Else
  If (AnimationFlags And widgetAnimatePosX_Bottom<>0) Then
    Result := AddTween(wtPositionX, UIManager.Instance.Width +(Self.Size.X+15), Duration, Delay);

  If (AnimationFlags And widgetAnimatePosY<>0) Then
  Begin
    Ofs := -Self.Size.Y;

    If (Self.Align = waCenter) Or (Self.Align = waLeftCenter) Or (Self.Align = waRightCenter) Then
      Ofs := Ofs - Self.Position.Y;

    Result := AddTween(wtPositionY, Ofs, Duration, Delay)
  End Else
  If (AnimationFlags And widgetAnimatePosY_Bottom<>0) Then
    Result := AddTween(wtPositionY, UIManager.Instance.Height + Self.Size.Y, Duration, Delay);

  If (AnimationFlags And widgetAnimateAlpha<>0) Then
    Result := AddTween(wtColorAlpha, 0.0, Duration, Delay);

  If Assigned(Result) Then
  Begin
    Self._NeedsHide := True;
    Result.EaseType := EaseType;
  End;
End;

Function Widget.ToggleVisibility(AnimationFlags:Integer; Delay, EaseType, Duration:Integer):Tween;
Begin
  If _Visible Then
    Result := Hide(AnimationFlags, Delay, EaseType, Duration)
  Else
    Result := Show(AnimationFlags, Delay, EaseType, Duration);
End;

Function Widget.IsVisible:Boolean;
Begin
  If (Self = Nil) Then
  Begin
    Result := False;
    Exit;
  End;

	Result := _Visible;
  If (Result) And (Assigned(_Parent)) Then
  Begin
    Result := Result And (_Parent.IsVisible);

    If (Result) And (Self.TabIndex>=0) And (Parent.TabControl<>Nil) And (_Parent.TabControl Is UITabList) Then
    Begin
      If (UITabList(_Parent.TabControl).SelectedIndex<>Self.TabIndex) Then
        Result := False;
    End;
  End;
End;

Procedure Widget.SetVisible(Value:Boolean);
Begin
  {If (Self = Nil) Then
    Exit;}

  If (Value = _Visible) Then
    Exit;

  //Log(logDebug,'UI', Self._Name+' visibility is now '+BoolToString(Value));
    
  _Visible := Value;

  If Value Then
    _VisibleFrame := GraphicsManager.Instance.FrameID;

  If (Not Value) And (_UsingHighLightProperties) Then
    Self.StopHighlight();
End;

Procedure Widget.SetPosition(Pos:Vector2D);
Begin
  If (Pos.X = _Position.X) And (Pos.Y = _Position.Y) Then
    Exit;

  _Position := Pos;
  _TransformChanged := True;
End;

Procedure Widget.SetLayer(Z:Single);
Begin
  If (Z = _Layer) Then
    Exit;

  _Layer := Z;
End;

Procedure Widget.SetColor(MyColor:Color);
Begin
  If (Cardinal(MyColor) = Cardinal(_Color)) Then
    Exit;

  _Color := MyColor;
End;

Function Widget.GetColor:Color;  {$IFDEF FPC} Inline;{$ENDIF}
Begin
	Result := _Color;
  If (Not _InheritColor) Then
    Exit;
                          
	If (Assigned(_Parent)) Then
		Result := ColorMultiply(Result, _Parent.GetColor());
End;

Function Widget.GetRelativePosition:Vector2D;
Begin
  Result := _Position;
End;

Function Widget.GetAbsolutePosition:Vector2D;
Var
  Width, Height:Single;
  ParentSize, Center:Vector2D;
Begin
  Result := _Position;

  If (Align<>waTopLeft) Then
  Begin
    Width := _Size.X{ * _Scale};
    Height := _Size.Y{ * _Scale};

    {IF _Scale>1 Then
      IntToString(2);}

  	If (Assigned(_Parent)) Then
    Begin
      ParentSize := _Parent.Size;
{      ParentSize.X := ParentSize.X * _Parent._Scale;
      ParentSize.Y := ParentSize.Y * _Parent._Scale;}
    End Else
      ParentSize := VectorCreate2D(UIManager.Instance.Width, UIManager.Instance.Height);
      
    Center.X := ParentSize.X * 0.5;
    Center.Y := ParentSize.Y * 0.5;

    Case Align Of
      waCenter:
      Begin
        Result.X := Result.X + Center.X - Width * 0.5;
        Result.Y := Result.Y + Center.Y - Height * 0.5;
      End;

      waTopCenter:
      Begin
        Result.X := Result.X + Center.X - Width * 0.5;
      End;

      waTopRight:
      Begin
        Result.X := (ParentSize.X - Width) - Result.X;
      End;

      waLeftCenter:
      Begin
        Result.Y := Result.Y + Center.Y - Height * 0.5;
      End;

      waRightCenter:
      Begin
        Result.X := (ParentSize.X - Width) - Result.X;
        Result.Y := Result.Y + Center.Y - Height * 0.5;
      End;

      waBottomLeft:
      Begin
        Result.Y := (ParentSize.Y - Height) - Result.Y;
      End;

      waBottomCenter:
      Begin
        Result.X := Result.X + Center.X - Width * 0.5;
        Result.Y := (ParentSize.Y - Height) - Result.Y;
      End;

      waBottomRight:
      Begin
        Result.X := (ParentSize.X - Width) - Result.X;
        Result.Y := (ParentSize.Y - Height) - Result.Y;
      End;
    End;
  End;

	If (Assigned(_Parent)) Then
		Result.Add(_Parent.GetAbsolutePosition());
End;

Function Widget.GetLayer:Single;  {$IFDEF FPC} Inline;{$ENDIF}
Begin
	Result := _Layer;

	If (Assigned(_Parent)) Then
		Result := Result + _Parent.GetLayer();
End;

Function Widget.GetSaturation:Single;
Begin
	Result := _Saturation;
	If (Assigned(_Parent)) Then
		Result := Result * _Parent.GetSaturation();
End;

Function Widget.GetHighlightGroup:Integer;
Begin
	Result := _HighlightGroup;
	If (Assigned(_Parent)) And (_HighlightGroup<=0) Then
		Result := _Parent.GetHighlightGroup();
End;


Function Widget.GetColorTable:Texture;
Begin
	Result := _ColorTable;
	If (Result = Nil) And (Assigned(_Parent)) Then
		Result := _Parent.GetColorTable();
End;

Function Widget.HasTweens:Boolean;
Begin
  PruneTweens;
  Result := (_TweenCount>0);
End;

Procedure Widget.PruneTweens;
Var
  I:Integer;
Begin
  I:=0;
  While I<_TweenCount Do
  If (TweenManager.Instance.HasTween(_TweenList[I])) Then
      Inc(I)
  Else
  Begin
    _TweenList[I] := _TweenList[Pred(_TweenCount)];
    Dec(_TweenCount);
  End;
End;

Function Widget.AddTween(TweenType:Integer; TargetValue:Single; Time:Integer; Delay:Integer=0):Tween;
Begin
  PruneTweens();

  Case TweenType Of
  wtPositionX:  Result := Tween.Create(Self, tweenFloat, @Self._Position.X, TargetValue, Self);
  wtPositionY:  Result := Tween.Create(Self, tweenFloat, @Self._Position.Y, TargetValue, Self);
  wtColorRed:   Result := Tween.Create(Self, tweenByte, @Self._Color.R, TargetValue, Self);
  wtColorGreen: Result := Tween.Create(Self, tweenByte, @Self._Color.G, TargetValue, Self);
  wtColorBlue:  Result := Tween.Create(Self, tweenByte, @Self._Color.B, TargetValue, Self);
  wtColorAlpha: Result := Tween.Create(Self, tweenByte, @Self._Color.A, TargetValue, Self);
  wtRotation:   Result := Tween.Create(Self, tweenFloat, @Self._Rotation, TargetValue, Self);
  wtScale:      Result := Tween.Create(Self, tweenFloat, @Self._Scale, TargetValue, Self);
  wtSaturation: Result := Tween.Create(Self, tweenFloat, @Self._Saturation, TargetValue, Self);
  Else
//    RaiseError('Invalid tween type: '+IntToString(TweenType));
    Result := Self.CreateCustomTween(TweenType, TargetValue);
  End;

  If Not Assigned(Result) Then
    Exit;

  Inc(_TweenCount);
  SetLength(_TweenList, _TweenCount);
  _TweenList[Pred(_TweenCount)] := Result;

  Result.Time := Time;
  Result.Delay := Delay;
End;

Function Widget.LoadComponent(Name:TERRAString):Integer;
Var
  I:Integer;
  Source, Temp:Image;
  MyStream:Stream;
  S:TERRAString;
  Item:TextureAtlasItem;
  Ext:ImageClassInfo;
Begin
  Name := GetFileName(Name, True);

  Log(logDebug, 'UI', 'Getting '+Name);
  Item := UIManager.Instance.GetTextureAtlas.Get(Name);
  If Assigned(Item) Then
  Begin
    Result := _ComponentCount;
    Inc(_ComponentCount);
    SetLength(_ComponentList, _ComponentCount);
    _ComponentList[Result] := Item;
    Exit;
  End;

  Log(logDebug, 'UI', 'Searching icons');
  S := '';
  I := 0;
  While (S='') And (I<GetImageExtensionCount()) Do
  Begin
    Ext := GetImageExtension(I);
    S := FileManager.Instance.SearchResourceFile(Name+'.'+Ext.Name);
    Inc(I);
  End;

  Log(logDebug, 'Game', 'Got '+S);
  If S<>'' Then
  Begin
    Log(logDebug, 'Game', 'Opening stream');
    MyStream := FileManager.Instance.OpenStream(S);
    Log(logDebug, 'Game', 'Creating image: '+S);

    Source := Image.Create(MyStream);
    Log(logDebug, 'Game', 'Image created: '+IntToString(Source.Width)+'x'+IntToString(Source.Height));

    Log(logDebug, 'Game', 'Adding compnent');

    Result := _ComponentCount;
    Inc(_ComponentCount);
    SetLength(_ComponentList, _ComponentCount);

    Log(logDebug, 'Game', 'Adding to TextureAtlas');

    _ComponentList[Pred(_ComponentCount)] := UIManager.Instance.GetTextureAtlas.Add(Source, Name);
    UIManager.Instance.TextureAtlasClear();

    Log(logDebug, 'Game', 'TextureAtlas added');

    ReleaseObject(Source);
    ReleaseObject(MyStream);
  End Else
  Begin
    Log(logWarning,'UI', 'UI component not found. ['+Name+']');
    Result := -1;
  End;
End;

Procedure Widget.DrawComponent(Index:Integer; Const Offset:Vector3D; X1,Y1,X2,Y2:Single; Color:Color; ScaleColor:Boolean);
Var
  P:Vector2D;
  Z:Single;
  StartPos, EndPos:Vector2D;
  ShadowOffset:Vector2D;
  TC1, TC2:Vector2D;
  Source:Image;
  MyTextureAtlas:TextureAtlas;
  Saturation:Single;
  ColorTable:Texture;
  OfsX,OfsY:Single;
Begin
  If (Index<0) Or (Index>=_ComponentCount) Then
    Exit;

  If (Self.HasTweens) Then
    _TransformChanged := True;

  MyTextureAtlas := UIManager.Instance.GetTextureAtlas();
  Source := _ComponentList[Index].Buffer;
  P := Self.GetAbsolutePosition();
  Z := Self.GetLayer + Offset.Z;
  P.X := P.X + Offset.X;
  P.Y := P.Y + Offset.Y;

  Self.GetScrollOffset(OfsX, OfsY);

  P.X := P.X + OfsX;
  P.Y := P.Y + OfsY;

  StartPos := VectorCreate2D(Trunc(P.X + Trunc(X1 * Source.Width)), Trunc(P.Y + Trunc(Y1 * Source.Height)));
  EndPos := VectorCreate2D(Round(P.X + Trunc(X2 * Source.Width)), Round(P.Y + Trunc(Y2 * Source.Height)));
  TC1.X := (_ComponentList[Index].U1 + ( (X1*Pred(Source.Width)) / MyTextureAtlas.Width));
  TC1.Y := (_ComponentList[Index].V1 + ( (Y1*Pred(Source.Height)) / MyTextureAtlas.Height));
  TC2.X := (_ComponentList[Index].U1 + ( ((X2*Pred(Source.Width))) / MyTextureAtlas.Width));
  TC2.Y := (_ComponentList[Index].V1 + ( ((Y2*Pred(Source.Height))) / MyTextureAtlas.Height));

  Saturation := Self.GetSaturation();
  ColorTable := Self.GetColorTable();

  If (ScaleColor) And (Not DisableUIColor) Then
  Begin
    Color := ColorMultiply(Color, UI._Color);
    Saturation := Saturation * Self._Saturation;

    If (ColorTable = Nil) Then
      ColorTable := UI._ColorTable;
  End;

  If Not Enabled Then
    Saturation := 0.0;

  UI.AddQuad(StartPos, EndPos, TC1, TC2, Color, Z, _ComponentList[Index].PageID, _Transform, Saturation, ColorTable, GetClipRect());
End;

Procedure Widget.DrawWindow(Index:Integer; Const Offset:Vector3D; Width, Height:Integer; Layout:UISkinLayout; Color:Color);
Var
  IX,IY:Integer;
  I,J:Integer;
  LX,LY:Single;
Begin
  If (Index<0) Or (Index>=Self._ComponentCount) Then
    Exit;

  IX := _ComponentList[Index].Buffer.Width;
  IY := _ComponentList[Index].Buffer.Height;

  LX := Layout.GCSX(0) + Width * Layout.GCSX(1);
  LX := LX - Layout.X[2] * IX;

  LY := Layout.GCSY(0) + Height * Layout.GCSY(1);
  LY := LY - Layout.Y[2] * IY;

  Self.DrawComponent(0, Offset, 0.0, 0.0, Layout.X[1], Layout.Y[1], Color);
  Self.DrawComponent(0, VectorCreate(Offset.X + LX, Offset.Y, Offset.Z), Layout.X[2], 0.0, 1.0, Layout.Y[1], Color);

  Self.DrawComponent(0, VectorCreate(Offset.X, Offset.Y + LY, Offset.Z), 0.0, Layout.Y[2], Layout.X[1], 1.0, Color);
  Self.DrawComponent(0, VectorCreate(Offset.X + LX, Offset.Y + LY, Offset.Z), Layout.X[2], Layout.Y[2], 1.0, 1.0, Color);

  For I:=1 To Width Do
  Begin
    Self.DrawComponent(0, VectorCreate(Offset.X + Layout.GCSX(1) * Pred(I), Offset.Y, Offset.Z), Layout.X[1], Layout.Y[0], Layout.X[2], Layout.Y[1], Color);
    Self.DrawComponent(0, VectorCreate(Offset.X + Layout.GCSX(1) * Pred(I), Offset.Y + LY, Offset.Z), Layout.X[1], Layout.Y[2], Layout.X[2], 1.0, Color);
  End;

  For I:=1 To Height Do
  Begin
    Self.DrawComponent(0, VectorCreate(Offset.X, Offset.Y + Layout.GCSY(1) * Pred(I), Offset.Z), 0.0, Layout.Y[1], Layout.X[1],  Layout.Y[2], Color);
    Self.DrawComponent(0, VectorCreate(Offset.X + LX, Offset.Y + Layout.GCSY(1) * Pred(I), Offset.Z), Layout.X[2], Layout.Y[1], 1.0, Layout.Y[2], Color);
  End;

  For J:=1 To Height Do
  For I:=1 To Width Do
  Begin
    Self.DrawComponent(0, VectorCreate(Offset.X + Layout.GCSX(1)*Pred(I), Offset.Y + Layout.GCSY(1)*Pred(J), Offset.Z), Layout.X[1], Layout.Y[1], Layout.X[2], Layout.Y[2], Color);
  End;
End;

Procedure Widget.DrawText(Const Text:TERRAString; Const Offset:Vector3D; C:Color; Scale:Single; UseFont:Font);
Var
  P:Vector2D;
  Z:Single;
  OfsX,OfsY:Single;
  Fnt:TERRA_Font.Font;
Begin
  //Color.A := Trunc(Color.A * UI.Instance._Alpha);

  P := Self.GetAbsolutePosition();
  Z := Self.GetLayer + Offset.Z;

  Self.GetScrollOffset(OfsX, OfsY);

  P.X := P.X + Offset.X + OfsX;
  P.Y := P.Y + Offset.Y + OfsY;

  If Assigned(UseFont) Then
    Fnt := UseFont
  Else
    Fnt := Self.GetFont();

  _FontRenderer.SetFont(Fnt);
  _FontRenderer.SetClipRect(GetClipRect());
  _FontRenderer.SetTransform(_Transform);
  _FontRenderer.SetDropShadow(_DropShadowColor);
  _FontRenderer.SetColor(C);

  _FontRenderer.DrawText(P.X, P.Y, Z, Text);
End;

Function Widget.OnKeyDown(Key:Word):Boolean;
Begin
  RemoveHint(Key);
	Result := False;
End;

Function Widget.OnKeyUp(Key:Word):Boolean;
Var
  I:Integer;
Begin
  If Not Self.Visible Then
  Begin
    Result := False;
    Exit;
  End;

  If (Key = UI.Key_Action) Then
  Begin
    Result := Self.OnSelectAction();
  End Else
  If (Key = UI.Key_Action2) Then
  Begin
    Result := Self.OnSelectAlternateAction();
  End Else
  If (Key = UI.key_Up) Then
  Begin
    Result := Self.OnSelectUp();
  End Else
  If (Key = UI.Key_Down) Then
  Begin
    Result := Self.OnSelectDown();
  End Else
  If (Key = UI.key_Left) Then
  Begin
    Result := Self.OnSelectLeft();
  End Else
  If (Key = UI.key_Right) Then
  Begin
    Result := Self.OnSelectRight();
  End Else
  	Result := False;

  If Result Then
    Exit;

  For I:=0 To Pred(_ChildrenCount) Do
  Begin
    Result := _ChildrenList[I].OnKeyUp(Key);
    If Result Then
      Exit;
  End;
End;

Function Widget.OnKeyPress(Key:Word):Boolean;
Begin
  RemoveHint(Key);
	Result := False;
End;

Function Widget.OnRegion(X,Y:Integer): Boolean;
Begin
  {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', 'X:'+IntToString(X)+' Y:'+IntToString(Y));{$ENDIF}
  {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', _Name+ '.OnRegion called');{$ENDIF}
  {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', 'X1:'+IntToString(Trunc(_Corners[0].X))+' Y1:'+IntToString(Trunc(_Corners[0].Y)));{$ENDIF}
  {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', 'X2:'+IntToString(Trunc(_Corners[2].X))+' Y2:'+IntToString(Trunc(_Corners[2].Y)));{$ENDIF}

  If (GraphicsManager.Instance.FrameID = Self._VisibleFrame) Or (OutsideClipRect(X,Y)) Or (Not _Enabled) Then
  Begin
    Result := False;
    {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', 'Cliprect clipped!');{$ENDIF}
    Exit;
  End;

  Result := (X>= _Corners[0].X) And (X <= _Corners[2].X) And (Y >= _Corners[0].Y) And (Y <= _Corners[2].Y);
  {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', 'Region result for '+_Name+' was '+BoolToString(Result));{$ENDIF}
End;

Function Widget.OnMouseDown(X,Y:Integer;Button:Word):Boolean;
Var
  I:Integer;
Begin
  Result := False;

  {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', _Name+ '.OnMouseDown called');{$ENDIF}

  If (Not Self.Visible) Or (Not Self.Enabled) Then
    Exit;

  If (Self.HasTweens) Then
  Begin
    {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', _Name+ ' has tweens!');{$ENDIF}
    Exit;
  End;

  For I:=0 To Pred(_ChildrenCount) Do
    _ChildrenList[I]._Tested := False;

  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I].Visible) And (_ChildrenList[I] Is UIComboBox) Then
  Begin
    _ChildrenList[I]._Tested := True;
    Result := _ChildrenList[I].OnMouseDown(X,Y, Button);
    If Result Then
      Exit;
  End;

  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I].Visible) And (_ChildrenList[I] Is UIWindow) Then
  Begin
    _ChildrenList[I]._Tested := True;
    Result := _ChildrenList[I].OnMouseDown(X,Y, Button);
    If Result Then
      Exit;
  End;

  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I].Visible) And (Not _ChildrenList[I]._Tested)  Then
  Begin
    Result := _ChildrenList[I].OnMouseDown(X,Y, Button);
    If Result Then
      Exit;
  End;

  If (OnRegion(X,Y)) Then
  Begin
    If (Draggable) Then
    Begin
      If (Not _Dragging) Then
      Begin
        If (Assigned(OnBeginDrag)) Then
          Self.OnBeginDrag(Self);

        _UI._Dragger := Self;
        _DragStart := _Position;
        _Dragging := True;
        _DragX := (X-_Position.X);
        _DragY := (Y-_Position.Y);
      End;
      
      Result := True;
      Exit;
    End;

    {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', 'Found, and has handler: '+BoolToString(Assigned(OnMouseClick)));{$ENDIF}
    If (Assigned(OnMouseClick)) And (Pos('KEY_', Self.Name)<>1) Then
    Begin
      Result := True;
      OnMouseClick(Self);
    End;
  End;
End;

Function Widget.OnMouseUp(X,Y:Integer;Button:Word):Boolean;
Var
  I:Integer;
Begin
  Result := False;

  If (_Dragging) Then
  Begin
    If (_UI._Dragger = Self) And (Assigned(OnEndDrag)) Then
      Self.OnEndDrag(Self);

    _Dragging := False;
    _UI._Dragger := Nil;
    Result := True;
    Exit;
  End;

  {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', _Name+ '.OnMouseUp called');{$ENDIF}

  If (Not Self.Visible) Or (Self.HasTweens) Then
    Exit;

  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I]._Visible) Then
  Begin
    Result := _ChildrenList[I].OnMouseUp(X,Y, Button);
    If Result Then
      Exit;
  End;

  If (OnRegion(X,Y)) And (Assigned(OnMouseRelease)) Then
  Begin
    Result := True;
    OnMouseRelease(Self);
  End;
End;

Function IsEditText(W:Widget):Boolean;
Begin
  If W = Nil Then
    Result := False
  Else
    Result := (W Is UIEditText);
End;

Function Widget.OnMouseMove(X,Y:Integer):Boolean;
Var
  B:Boolean;
  I:Integer;
Begin
  Result := False;

  If (_Dragging) Then
  Begin
    _Position.X := X - _DragX;
    _Position.Y := Y - _DragY;
    _TransformChanged := True;
    Exit;
  End;
  
  If (Not Self.Visible) Or (Self.HasTweens) Or (OnRegion(X,Y)) Then
    Exit;

  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I]._Visible) Then
  Begin
    Result := _ChildrenList[I].OnMouseMove(X,Y);
    If Result Then
      Exit;
  End;

  {$IFDEF PC}
  If (Self.HasMouseOver) Then
  Begin
    B := OnRegion(X,Y);
    If (B=True) And (UI.Highlight <> Self) And (Not IsEditText(UI.Highlight)) Then
    Begin
    	Result := True;
      UI.Highlight := Self;

      If (Assigned(OnMouseOver)) Then
        OnMouseOver(Self);
    End Else
    If (B=False) And (UI.Highlight = Self) And (Not UI.Highlight._SelectedWithKeyboard) Then
    Begin
    	Result := True;

      (*{$IFDEF MOBILE}
      If (Assigned(OnMouseClick)) And (Pos('KEY_', Self.Name)<>1) Then
      Begin
        OnMouseClick(Self);
      End;
      {$ENDIF}*)

      If (Assigned(OnMouseOut)) Then
        OnMouseOut(Self);
    End Else
    	Result := False;
  End Else
	  Result := False;
  {$ENDIF}
End;

Function Widget.OnMouseWheel(X,Y:Integer; Delta:Integer):Boolean;
Var
  I:Integer;
Begin
  Result := False;

  If (Not Self.Visible) Or (Self.HasTweens) Or (OnRegion(X,Y)) Then
    Exit;

  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I]._Visible) Then
  Begin
    Result := _ChildrenList[I].OnMouseWheel(X, Y, Delta);
    If Result Then
      Exit;
  End;

	Result := False;
End;

Function Widget.Sort(Other:CollectionObject):Integer;
Begin
  If (Self.Name<Widget(Other).Name) Then
    Result := 1
  Else
  If (Self.Name>Widget(Other).Name) Then
    Result := -1
  Else
    Result := 0;
End;

Procedure Widget.UpdateHighlight();
Begin
  UpdateHighlight(IsHighlighted());
End;

Procedure Widget.UpdateHighlight(Condition:Boolean);
Begin
  If (_UsingHighLightProperties = Condition) Then
    Exit;

  _UsingHighLightProperties := Condition;
  If (Condition) Then
    Self.StartHighlight()
  Else
    Self.StopHighlight();
End;

Function Widget.HasMouseOver: Boolean;
Begin
  Result := (Assigned(OnMouseOver)) Or (Assigned(OnMouseOut)) Or (Assigned(OnMouseClick));
End;

Procedure Widget.SetSaturation(const Value: Single);
Begin
  _Saturation := Value;
  _NeedsUpdate := True;
End;

Procedure Widget.SetScale(const Value: Single);
Begin
  _Scale := Value;
  _NeedsUpdate := True;
  _TransformChanged := True;
End;


Procedure Widget.SetRotation(const Value: Single);
Begin
  _Rotation := Value;
  _NeedsUpdate := True;
  _TransformChanged := True;
End;

Function Widget.UpdateTransform():Boolean;
Var
  I:Integer;
  Center:Vector2D;
  Pos:Vector2D;
  W,H, Ratio:Single;
  OfsX,OfsY:Single;
Begin
  Result := False;

  If (_NeedsHide) And (Not Self.HasTweens()) Then
  Begin
    _NeedsHide := False;
    HideWidget(Self);
  End;

  If (Not _TransformChanged) Then
    Exit;

  _TransformChanged := False;

  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I]._Visible) Then
    _ChildrenList[I]._TransformChanged := True;

  If Assigned(_Parent) Then
    Ratio := 1.0
  Else
    Ratio := UIManager.Instance.Ratio;

  Center := Self.GetSize();
  Center.X := Center.X * _Pivot.X;
  Center.Y := Center.Y * _Pivot.Y;
  Center.Add(Self.GetAbsolutePosition());

  If (_Rotation <> 0.0) Then
    _Transform := MatrixRotationAndScale2D(_Rotation, _Scale, _Scale * Ratio)
  Else
    _Transform := MatrixScale2D(_Scale, _Scale * Ratio);

  _Transform := MatrixTransformAroundPoint2D(Center, _Transform);

  If Assigned(_Parent) Then
    _Transform := MatrixMultiply3x3(_Transform, Parent._Transform)
  Else
    _Transform := MatrixMultiply3x3(_Transform, _UI._Transform);

  Pos := Self.GetAbsolutePosition();
  W := Pos.X + Size.X;
  H := Pos.Y + Size.Y;

  Self.GetScrollOffset(OfsX, OfsY);

  _Corners[0] := VectorCreate2D(Pos.X, Pos.Y);
  _Corners[1] := VectorCreate2D(W, Pos.Y);
  _Corners[2] := VectorCreate2D(W, H);
  _Corners[3] := VectorCreate2D(Pos.X, H);

  For I:=0 To 3 Do
  Begin
    _Corners[I].Add(VectorCreate2D(OfsX, OfsY));
    _Corners[I] := _Transform.Transform(_Corners[I]);
  End;

  Result := True;
End;

Function Widget.GetChild(Index:Integer): Widget;
Begin
  If (Index>=0) And (Index<=Self.ChildrenCount) Then
    Result := _ChildrenList[Index]
  Else
    Result := Nil;
End;

Function Widget.GetChild(Const Name:TERRAString): Widget;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_ChildrenCount) Do
  If (StringEquals(_ChildrenList[I].Name, Name)) Then
  Begin
    Result := _ChildrenList[I];
    Exit;
  End;

  Result := Nil;
End;

Procedure Widget.AddChild(W: Widget);
Begin
  If (W=Nil) Then
    Exit;

  W._Parent := Self;
  Inc(_ChildrenCount);
  SetLength(_ChildrenList, _ChildrenCount);
  _ChildrenList[Pred(_ChildrenCount)] := W;
End;

Function Widget.GetChild(ChildClass: WidgetClass; Index:Integer): Widget;
Var
  I, Count:Integer;
Begin
  Count := -1;
  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I].ClassType = ChildClass) Then
  Begin
    Inc(Count);
    If (Count = Index) Then
    Begin
      Result := _ChildrenList[I];
      Exit;
    End;
  End;

  Result := Nil;
End;

Procedure Widget.Render;
Begin
  If (Not Self.Visible) Then
    Exit;


  RenderChildren();
End;

Procedure Widget.RenderChildren();
Var
  I:Integer;
Begin
  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I].Visible) And (_ChildrenList[I].CanRender()) Then
    _ChildrenList[I].Render();
End;

Procedure Widget.OnHighlight(Prev: Widget);
Begin
  // do nothing
End;

Function Widget.IsSelected: Boolean;
Begin
  Result := (Self = UI.Highlight) Or (Self = UI.Focus);
End;

Function Widget.OnSelectAction: Boolean;
Begin
  If (Self.Selected) And (Assigned(OnMouseClick)) And (Not Self.HasTweens()) Then
  Begin
    Result := OnMouseClick(Self);
  End Else
    Result := False;
End;

Function Widget.OnSelectAlternateAction: Boolean;
Begin
  If (Self.Selected) And (Assigned(OnExtendedClick)) And (Not Self.HasTweens()) Then
  Begin
    Result := OnExtendedClick(Self);
  End Else
    Result := False;
End;

Function Widget.OnSelectDown():Boolean;
Var
  W:Widget;
Begin
  Result := False;

  If (Self.Selected) Then
  Begin
    W := Self.GetDownControl();
    If (Assigned(W)) And (Not Self.HasTweens()) Then
    Begin
      Result := True;
      UI.Highlight := W;
    End;
  End;
End;

Function Widget.OnSelectLeft():Boolean;
Var
  W:Widget;
Begin
  Result := False;

  If (Self.Selected) Then
  Begin
    W := Self.GetLeftControl();
    If (Assigned(W)) And (Not Self.HasTweens()) Then
    Begin
      Result := True;
      UI.Highlight := W;
    End;
  End;
End;

Function Widget.OnSelectRight():Boolean;
Var
  W:Widget;
Begin
  Result := False;

  If (Self.Selected) Then
  Begin
    W := Self.GetRightControl();
    If (Assigned(W)) And (Not Self.HasTweens()) Then
    Begin
      Result := True;
      UI.Highlight := W;
    End;
  End;
End;

Function Widget.OnSelectUp():Boolean;
Var
  W:Widget;
Begin
  Result := False;

  If (Self.Selected) Then
  Begin
    W := Self.GetUpControl();
    If (Assigned(W)) And (Not Self.HasTweens()) Then
    Begin
      Result := True;
      UI.Highlight := W;
    End;
  End;
End;

Function Widget.GetClipRect:ClipRect;
Begin
  Result := Self._ClipRect;

  If (Assigned(_Parent)) Then
    Result.Merge(_Parent.GetClipRect())
  Else
    Result.Merge(_UI._ClipRect);
End;

Function Widget.GetFont:TERRA_Font.Font;
Begin
  Result := _Font;

  If Result = Nil Then
    Result := _UI.DefaultFont;

  If Result = Nil Then
    Result := FontManager.Instance.DefaultFont;
End;

Procedure Widget.SetClipRect(Value:ClipRect);
Begin
  Self._ClipRect := Value;
End;

Procedure Widget.GetScrollOffset(Out OfsX, OfsY: Single);
Var
  TX, TY:Single;
  Bar:UIScrollBar;
Begin
  OfsX := 0;
  OfsY := 0;

  If (Assigned(Scroll)) And (Scroll Is UIScrollBar) Then
  Begin
    Bar := UIScrollBar(Scroll);

    If (_ScrollValue<>Bar.Value) Then
    Begin
      Self._TransformChanged := True;
      _ScrollValue := Bar.Value;
    End;

    If (Bar.Horizontal) Then
      OfsX := -Bar.Value
    Else
      OfsY := -Bar.Value;
  End;

  If Assigned(Parent) Then
  Begin
    Parent.GetScrollOffset(TX, TY);
    OfsX := OfsX + TX;
    OfsY := OfsY + TY;
  End;
End;

Procedure Widget.SetPositionRelative(Other: Widget; OfsX, OfsY: Single);
Begin
  If (Other.Parent<>Nil) Then
    _Position := VectorCreate2D(Other.Position.X - Other.Parent.Position.X, Other.Position.Y - Other.Parent.Position.Y)
  Else
    _Position := Other.Position;

  _Position.Add(VectorCreate2D(OfsX, OfsY));
  _TransformChanged := True;
End;

Procedure Widget.SetName(const Value:TERRAString);
Begin
  _Key := Value;
  Self._UI._Widgets.Reindex(Self);
End;

Function Widget.OutsideClipRect(X, Y: Integer): Boolean;
Var
  X1, Y1, X2, Y2:Single;
Begin
  If (_ClipRect.Style = clipNothing) Then
  Begin
    Result := False;
    Exit;
  End;

  If (_ClipRect.Style = clipEverything) Then
  Begin
    Result := True;
    Exit;
  End;

  _ClipRect.GetRealRect(X1, Y1, X2, Y2{, IsLandscapeOrientation(Application.Instance.Orientation)});

  Result := (X<X1) Or (Y<Y1) Or (X>=X2) Or (Y>=Y2);
End;

Procedure Widget.SetEnabled(Value: Boolean);
Begin
  Self._Enabled := Value;
End;

Procedure Widget.UpdateClipRect(Clip: ClipRect; LeftBorder,TopBorder, RightBorder, BottomBorder:Single);
Var
  Pos, Size:Vector2D;
Begin
  Pos := Self.Position;
  Size := Self.Size;
  Clip.X := Pos.X + LeftBorder;
  Clip.Y := Pos.Y + TopBorder;
  Clip.Width := Size.X - (RightBorder + LeftBorder);
  Clip.Height := Size.Y - (TopBorder + BottomBorder);
End;

Procedure Widget.SetFont(const Value: TERRA_Font.Font);
Begin
  If (Self._Font = Value) Then
    Exit;

  If Assigned(Value) Then
    Value.Prefetch();

  Self._Font := Value;
End;

Procedure Widget.CancelDrag;
Begin
  If _Dragging Then
  Begin
    _Position := _DragStart;
    _Dragging := False;
    If _UI._Dragger = Self Then
      _UI._Dragger := Nil;

    Self._TransformChanged := True;
  End;
End;

Function Widget.GetIndex: Integer;
Var
  S:TERRAString;
Begin
  S := Self.Name;
  StringGetNextSplit(S, Ord('_'));
  Result := StringToInt(S); 
End;

Function Widget.GetTabControl():Widget;
Begin
  If Assigned(_TabControl) Then
    Result := _TabControl
  Else
  If (Assigned(_Parent)) Then
    Result := _Parent.GetTabControl()
  Else
    Result := Nil;
End;

Procedure Widget.SetChildrenVisibilityByTag(Tag: Integer; Visibility: Boolean);
Var
  I:Integer;
Begin
  For I:=0 To Pred(_ChildrenCount) Do
  If (Assigned(_ChildrenList[I])) And (_ChildrenList[I].Tag = Tag) Then
    _ChildrenList[I].Visible := Visibility;
End;

Function Widget.CanRender: Boolean;
Var
  CurrentFrameID:Cardinal;
Begin
  CurrentFrameID := GraphicsManager.Instance.FrameID;
  If (_RenderFrameID = CurrentFrameID) Then
  Begin
    Result := False;
    Exit;
  End;

  _RenderFrameID := CurrentFrameID;
  Result := True;
End;

Procedure Widget.ResetClipRect;
Begin
  _ClipRect.Style := clipSomething;
  _ClipRect.X := Self.Position.X;
  _ClipRect.Y := Self.Position.Y;
  _ClipRect.Width := Self.Size.X;
  _ClipRect.Height := Self.Size.Y;
  _ClipRect.Transform(_UI.Transform);
End;

Function Widget.OnCustomRegion(X, Y:Integer; X1, Y1, X2, Y2:Single): Boolean;
Var
  I:Integer;
  Pos:Vector2D;
  P:Array[0..3] Of Vector2D;
Begin
  Pos := Self.GetAbsolutePosition();
  P[0] := VectorCreate2D(X1, Y1);
  P[1] := VectorCreate2D(X2, Y1);
  P[2] := VectorCreate2D(X2, Y2);
  P[3] := VectorCreate2D(X1, Y2);

  For I:=0 To 3 Do
  Begin
    P[I].Add(Pos);
    P[I] := _Transform.Transform(P[I]);
  End;

  Result := (X>= P[0].X) And (X <= P[2].X) And (Y >= P[0].Y) And (Y <= P[2].Y);
End;

Function Widget.GetFontRenderer: FontRenderer;
Begin
  Result := _FontRenderer;

  If Assigned(Result) Then
    Result.SetFont(Self.Font);
End;


Function Widget.IsOutsideScreen: Boolean;
Begin
  Result := (Self.Position.X + Self.Size.X<0) Or (Self.Position.Y + Self.Size.Y<0)
    Or (Self.Position.X> UIManager.Instance.Width) Or (Self.Position.Y > UIManager.Instance.Height);
End;

{ UICursor }
Constructor UICursor.Create(Name:TERRAString; UI:UI; OfsX, OfsY:Integer);
Var
  Source:Image;
  MyStream:Stream;
Begin
  _UI := UI;
  _Item := UIManager.Instance.GetTextureAtlas.Get(Name);

  If Not Assigned(_Item) Then
  Begin
    Name := FileManager.Instance.SearchResourceFile(Name);
    If Name<>'' Then
    Begin
      MyStream := FileManager.Instance.OpenStream(Name);
      Source := Image.Create(MyStream);
      _Item := UIManager.Instance.GetTextureAtlas.Add(Source, Name);
      UIManager.Instance.TextureAtlasClear();
      ReleaseObject(Source);
      ReleaseObject(MyStream);
    End;
  End;

  _Name := Name;
  _OfsX := OfsY;
  _OfsY := OfsY;
End;

Procedure UICursor.Release;
Begin
  // do nothing
End;

Procedure UICursor.Render;
Var
  StartPos, EndPos:Vector2D;
  T1, T2:Vector2D;
  MyTextureAtlas:TextureAtlas;
  MyColor:Color;
  CR:ClipRect;
Begin
  If (Not Assigned(_Item)) Then
    Exit;

  CR.Style := clipNothing;

  StartPos := VectorCreate2D(UI._CursorPos.X - _OfsX, UI._CursorPos.Y - _OfsY);
  EndPos.X := StartPos.X + _Item.Buffer.Width;
  EndPos.Y := StartPos.Y + _Item.Buffer.Height;
  T1 := VectorCreate2D(_Item.U1, _Item.V1);
  MyTextureAtlas := UIManager.Instance.GetTextureAtlas;
  T2.X := T1.X + (_Item.Buffer.Width / MyTextureAtlas.Width);
  T2.Y := T1.Y + (_Item.Buffer.Height / MyTextureAtlas.Height);
  MyColor := ColorGrey(255, UI._Color.A);
  UI.AddQuad(StartPos, EndPos, T1, T2, MyColor, 99, _Item.PageID, MatrixIdentity3x3, 1, Nil, CR);
End;

{ UI }
Constructor UI.Create;
Begin
  _Widgets := HashMap.Create(1024);
  _Visible := True;

  _CurrentCursor := Nil;
  _CursorCount := 0;
  _Transition := Nil;

  _Color := ColorCreateFromFloat(1.0, 1.0, 1.0, 1.0);
  _Saturation := 1.0;
  _ColorTable := Nil;

  _FontRenderer := Nil;

  SetTransform(MatrixIdentity3x3);

  DefaultEaseType := easeInSine;

  Key_Up := TERRA_OS.keyUp;
  Key_Down := TERRA_OS.keyDown;
  Key_Right := TERRA_OS.keyRight;
  Key_Left := TERRA_OS.keyLeft;
  Key_Action := TERRA_OS.keyEnter;
  Key_Action2 := TERRA_OS.keyBackspace;
  Key_Cancel := TERRA_OS.keyEscape;

  UIManager.Instance.AddUI(Self);
End;

Procedure UI.Release;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_CursorCount) Do
    ReleaseObject(_CursorList[I]);

  ReleaseObject(_Transition);
	ReleaseObject(_Widgets);
End;

Procedure UI.Clear;
Begin
  Log(logError, 'UI', 'Clearing UI');
  _First := Nil;
  _Widgets.Clear;

  SetTransition(Nil);
  Log(logError, 'UI', 'UI is now clear.');
End;

(*Procedure UI.DrawCutsceneBars;
Var
  V:Array[0..11] Of Vector2D;
  X,H, Y:Single;
  PositionHandle:Integer;
  MyShader:Shader;
Begin
  X := UIManager.Instance.Width;
  H := UIManager.Instance.Height;

  _CutsceneAlpha:=1;
  Y := H * 0.1 * _CutsceneAlpha;

  V[0].X := 0.0;
  V[0].Y := 0.0;
  V[1].X := 0.0;
  V[1].Y := Y;
  V[2].X := X;
  V[2].Y := Y;
  V[3] := V[2];
  V[4].X := X;
  V[4].Y := 0;
  V[5] := V[0];

  V[6].X := 0.0;
  V[6].Y := H-Y;
  V[7].X := 0.0;
  V[7].Y := H;
  V[8].X := X;
  V[8].Y := H;
  V[9] := V[8];
  V[10].X := X;
  V[10].Y := H-Y;
  V[11] := V[6];

  MyShader := UIManager.Instance.GetCutsceneShader();
  If MyShader = Nil Then
    Exit;

  ShaderManager.Instance.Bind(MyShader);
  MyShader.SetUniform('projectionMatrix', GraphicsManager.Instance.ProjectionMatrix);

  PositionHandle := MyShader.GetAttribute('terra_position');

  GraphicsManager.Instance.Renderer.SetBlendMode(blendNone);

End;
End;*)

Procedure UI.SetFocus(W: Widget);
Begin
  If (W = _Focus) Then
    Exit;

  If (Assigned(_Focus)) Then
  Begin
    _Focus.StopHighlight();
    Self.SetHighlight(W);
  End;

  _Focus := W;
End;

Procedure UI.SetDefaultFont(const Value: Font);
Begin
  FontManager.Instance.PreFetch(Value);
  Self._DefaultFont := Value;
End;

Function UI.AllowsEvents(W: Widget): Boolean;
Begin
  If (W = Nil) Or (Not W.Visible) Then
  Begin
    Result := False;
    Exit;
  End;

  If (_Modal = Nil) Or  (W = _Modal) Then
  Begin
    Result := True;
    Exit;
  End;

  If (Not _Modal.Visible) Then
  Begin
    _Modal := Nil;
    Result := True;
    Exit;
  End;


  Result := Self.AllowsEvents(W.Parent);
End;

Procedure UI.SetColorTable(Const Value:Texture);
Begin
  Self._ColorTable := Value;
End;

Function UI.LoadCursor(Const Name:TERRAString; OfsX, OfsY:Integer):UICursor;
Begin
  Inc(_CursorCount);
  SetLength(_CursorList, _CursorCount);
  Result := UICursor.Create(Name, Self, OfsX, OfsY);
  _CursorList[Pred(_CursorCount)] := Result;
  If (Not Assigned(_CurrentCursor)) Then
    _CurrentCursor := Result;
End;

Procedure UI.AddWidget(MyWidget:Widget);
Var
  Temp, Last:Widget;
  Found:Boolean;
  It:Iterator;
Begin
  If Assigned(GetWidget(MyWidget.Name)) Then
  Begin
    Log(logWarning, 'UI', 'A widget with that name already exists! ['+ MyWidget.Name +']');
  End;

  If (Assigned(MyWidget._Parent)) Then
  Begin
    It := _Widgets.GetIterator();
    Found := False;
    While (It.HasNext) Do
    Begin
      Temp := Widget(It.Value);
      If (Temp = MyWidget._Parent) Then
      Begin
        Widget(Temp).AddChild(MyWidget);
        Found := True;
        Break;
      End;
    End;
    ReleaseObject(It);

    If Not Found Then
      Log(logWarning, 'UI', 'Error finding parent for '+ MyWidget.Name +'!');
  End Else
  If (Assigned(_First)) Then
  Begin
    If (_First.Layer > MyWidget.Layer) Then
    Begin
      MyWidget._Next := _First;
      _First := MyWidget;
    End Else
    Begin
      Last := _First;
      Temp := _First._Next;
      Found := False;
      While (Assigned(Temp)) Do
      Begin
        If (Temp.Layer > MyWidget.Layer) Then
        Begin
          MyWidget._Next := Temp;
          Last._Next := MyWidget;
          Found := True;
          Break;
        End;
        Last := Temp;
        Temp := Temp._Next;
      End;

      If (Not Found) Then
      Begin
        Last._Next := MyWidget;
        MyWidget._Next := Nil;
      End;
    End;

  End Else
  Begin
    _First := MyWidget;
    MyWidget._Next := Nil;
  End;

  _Widgets.Add(MyWidget);
End;

Procedure UI.DeleteWidget(MyWidget:Widget);
Var
  It:Iterator;
  Temp:Widget;
Begin
  If (MyWidget = Nil) Then
    Exit;

  If (MyWidget = _Focus) Then
    _Focus := Nil;

  If (MyWidget = _Highlight) Then
    _Highlight := Nil;

  TweenManager.Instance.RemoveTween(MyWidget);

  If (_First = MyWidget) Then
  Begin
    _First := MyWidget._Next;
  End Else
  Begin
    It := _Widgets.GetIterator();
    While (It.HasNext) Do
    Begin
      Temp := Widget(It.Value);
      If (Temp._Next = MyWidget) Then
      Begin
        Temp._Next := MyWidget._Next;
        Break;
      End;
    End;
    ReleaseObject(It);
  End;
  _Widgets.Delete(MyWidget);
End;

Function SearchWidgetByName(P:CollectionObject; UserData:Pointer):Boolean; CDecl;
Begin
  Result := (Widget(P).Name = PString(Userdata)^);
End;

Function UI.GetWidget(Const Name:TERRAString):Widget;
Var
  WidgetName:TERRAString;
Begin
  WidgetName := GetFileName(Name, True);
  Result := Widget(_Widgets.Search(SearchWidgetByName, @WidgetName));
End;


Function UI.AddQuad(Const StartPos, EndPos:Vector2D; Const TexCoord1, TexCoord2:Vector2D; MyColor:Color; Z:Single; PageID:Integer;
                    Const Transform:Matrix3x3; Saturation:Single; ColorTable:Texture; Const Clip:ClipRect):QuadSprite;
Var
  Tex:Texture;
Begin
  Tex := UIManager.Instance.TextureAtlas.GetTexture(PageID);
  Result := SpriteManager.Instance.DrawSprite(StartPos.X, StartPos.Y, Z, Tex, ColorTable, blendBlend, Saturation);
  If (Result = Nil) Then
    Exit;

  Result.Rect.Width := Trunc(EndPos.X - StartPos.X);
  Result.Rect.Height := Trunc(EndPos.Y - StartPos.Y);

  //Clip.Merge(Self._ClipRect);
  Result.ClipRect := Clip;

  Result.SetTransform(Transform);

  Result.SetColor(MyColor);
  Result.Rect.UVRemap(TexCoord1.X, TexCoord1.Y, TexCoord2.X, TexCoord2.Y);
End;

Procedure UI.UpdateLanguage();
Var
  MyWidget:Widget;
  It:Iterator;
Begin
  _Language := Application.Instance.Language;
  It := _Widgets.GetIterator();
  While (It.HasNext) Do
  Begin
    MyWidget := Widget(It.Value);
    MyWidget.OnLanguageChange();
  End;
  ReleaseObject(It);
End;

Procedure UI.Render;
Var
  MyWidget:Widget;
  I, J:Integer;
  Temp:Image;
  W,H:Integer;
  S:TERRAString;
  X,Y:Single;
  PositionHandle, UVHandle, ColorHandle:Integer;
  Transform:Matrix4x4;
  Q:Vector4D;
Begin
  _Draw := False;
  _CursorPos.X := InputManager.Instance.Mouse.X;
  _CursorPos.Y := InputManager.Instance.Mouse.Y;

  If (Assigned(_Highlight)) And ((Not _Highlight.Visible) Or (Not _Highlight.Enabled)) Then
  Begin
    _Highlight := SelectNearestWidget(_Highlight);
  End;

  If (Assigned(_Focus)) And (Not _Focus.Visible) Then
    _Focus := Nil;

  If (Assigned(_Modal)) And (Not _Modal.Visible) Then
    _Modal := Nil;

  If (_Language <> Application.Instance.Language) Then
    UpdateLanguage();

  //glEnable(glCoverage);

  (*ShaderManager.Instance.Bind(Self.GetShader);
  _Shader.SetUniform('texture', 0);
  _Shader.SetUniform('projectionMatrix', GraphicsManager.Instance.ProjectionMatrix);
  Q.X := GraphicsManager.Instance.Ratio2D.X;
  Q.Y := GraphicsManager.Instance.Ratio2D.Y;
  Q.Z := 1;
  Q.W := 1;
  _Shader.SetUniform('screen_ratio', Q);

  PositionHandle := _Shader.GetAttribute('terra_position');
  UVHandle := _Shader.GetAttribute('terra_UV0');
  ColorHandle := _Shader.GetAttribute('terra_color');
  *)

  If (UIManager.Instance._UpdateTextureAtlas) Then
    Exit;

  GraphicsManager.Instance.Renderer.SetBlendMode(blendBlend);

  If (Assigned(_CurrentCursor)) Then
    _CurrentCursor.Render;

  MyWidget := _First;
  While (Assigned(MyWidget)) Do
  Begin
    If (Not Assigned(MyWidget._Parent)) And (MyWidget.IsVisible) And (MyWidget.CanRender()) Then
      MyWidget.Render();

    MyWidget := MyWidget._Next;
  End;

  //glDisable(glCoverage);
End;

Procedure UI.AfterEffects;
Var
  CurrentTransitionID:Cardinal;
Begin
  {If Self._CutsceneAlpha>0 Then
    DrawCutsceneBars;}

  If (Assigned(_Transition)) Then
  Begin
    CurrentTransitionID := _Transition.ID;
    // note, this is tricky, since transition update can call a callback that remove or setup a new transition
    If (Not _Transition.Update) Then
    Begin
      If (Assigned(_Transition)) And (_Transition.ID = CurrentTransitionID) Then
        SetTransition(Nil);
    End;
  End;
End;

Procedure UI.SetTransition(MyTransition:UITransition);
Begin
  ReleaseObject(_Transition);

  _Transition := MyTransition;

  If Assigned(_Transition) Then
  Begin
    _Transition.EaseType := Self.DefaultEaseType;
    _Transition.Transform := Self.Transform;
  End;
End;

Function UI.OnKeyDown(Key:Word):Widget;
Begin
  Result := Nil;

	If Assigned(_Highlight) Then
  Begin
		If _Highlight.OnKeyDown(Key) Then
      Result := _Highlight;
  End;
End;

Function UI.OnKeyUp(Key:Word):Widget;
Var
  MyWidget:Widget;
Begin
  Result := Nil;

	If Assigned(_Highlight) Then
  Begin
		If _Highlight.OnKeyUp(Key) Then
    Begin
      Result := _Highlight;
      Exit;
    End;
  End;
  
	If Assigned(_Focus) Then
  Begin
		If _Focus.OnKeyUp(Key) Then
    Begin
      Result := _Focus;
      Exit;
    End;
  End;

  MyWidget := _First;
  While (Assigned(MyWidget)) Do
  Begin
    If (Not Assigned(MyWidget._Parent)) And (MyWidget.IsVisible) Then
    Begin
      If MyWidget.OnKeyUp(Key) Then
      Begin
        Result := MyWidget;
        Exit;
      End;
    End;

    MyWidget := MyWidget._Next;
  End;
End;

Function UI.OnKeyPress(Key:Word):Widget;
Begin
  Result := Nil;
  Log(logDebug, 'UI', 'keypress: '+IntToString(Integer(Key)));

	If Assigned(_Focus) Then
  Begin
    Log(logDebug, 'UI', 'focus is '+_Focus.Name);
		_Focus.OnKeyPress(Key);
    Result := _Focus;
  End;

  Log(logDebug, 'UI', 'keypress done!');
End;

Function UI.OnMouseDown(X,Y:Integer;Button:Word):Widget;
Var
  I, Count:Integer;
	MyWidget, Pick:Widget;
  Z:Single;
Begin
  _LastWidget := Nil;

//  ConvertGlobalToLocal(X, Y);

  If (Assigned(_VirtualKeyboard)) And (_VirtualKeyboard.Visible) And (_VirtualKeyboard.OnRegion(X,Y)) Then
  Begin
    If _VirtualKeyboard.OnMouseDown(X,Y, Button) Then
      Result := _VirtualKeyboard
    Else
      Result := Nil;

    _LastWidget := Result;
    Exit;
  End;

  Count := 0;
	MyWidget := _First;
	While (Assigned(MyWidget)) Do
	Begin
    MyWidget._Picked := False;
    If (MyWidget.Visible) Then
      Inc(Count);
    MyWidget := MyWidget._Next;
	End;

  {$IFDEF DEBUG_GUI}Log(logDebug, 'Game', IntToString(Count)+' widgets visible');{$ENDIF}

  While (Count>0) Do
  Begin
    Pick := Nil;
    Z := -9999;
  	MyWidget := _First;
  	While (Assigned(MyWidget)) Do
  	Begin
      {If (MyWidget.Visible) And (MyWidget.Position.X>UIManager.Instance.Width) Or (MyWidget.Position.Y>UIManager.Instance.Height) Then
      Begin
        MyWidget.Visible := False;
      End;}

      If (Not MyWidget.Visible) Then
      Begin
        MyWidget := MyWidget._Next;
        Continue;
      End;

      If (Assigned(MyWidget.Parent)) Then
      Begin
        MyWidget := MyWidget._Next;
        Continue;
      End;

      If (MyWidget._Picked) Then
      Begin
        MyWidget := MyWidget._Next;
        Continue;
      End;

      If (MyWidget.GetLayer>Z) And (AllowsEvents(MyWidget)) Then
      Begin
        Z := MyWidget.GetLayer;
        Pick := MyWidget;
      End;

      MyWidget := MyWidget._Next;
  	End;

    If (Assigned(Pick)) Then
    Begin
      {$IFDEF DEBUG_GUI}Log(logDebug, 'Game', 'Found a Widget for MouseDown: '+Pick.Name);{$ENDIF}

      Pick._Picked := True;
      Dec(Count);

      If (Self.Modal<>Nil) And (Not Pick.IsSameFamily(Modal)) Then
      Begin
        Pick := Nil;
        {$IFDEF DEBUG_GUI}Log(logDebug, 'Game', 'Cancelled because of modal...');{$ENDIF}
      End;

      If (Pick=Nil) Then
        Break
      Else
       If (Pick.OnMouseDown(X,Y, Button)) Then
      Begin
        //Log(logDebug, 'Game', 'Found a Widget for MouseDown: '+Pick.Name);
        Result := Pick;
        _LastWidget := Result;
        {$IFDEF DEBUG_GUI}Log(logDebug, 'Game', 'MouseDown event accepted!');{$ENDIF}
  		  Exit;
      End;
    End Else
      Break;
  End;

  Result := Nil;
End;

Function UI.OnMouseUp(X,Y:Integer;Button:Word):Widget;
Var
  I, Count:Integer;
	MyWidget, Pick:Widget;
  Z:Single;
Begin
  _LastWidget := Nil;

//  ConvertGlobalToLocal(X, Y);

  If (Assigned(_VirtualKeyboard)) And (_VirtualKeyboard.Visible) And (_VirtualKeyboard.OnRegion(X,Y)) Then
  Begin
    If _VirtualKeyboard.OnMouseUp(X,Y, Button) Then
      Result := _VirtualKeyboard
    Else
      Result := Nil;

    _LastWidget := Result;
    
    Exit;
  End;


  Count := 0;
	MyWidget := _First;
	While (Assigned(MyWidget)) Do
	Begin
    MyWidget._Picked := False;
    If (MyWidget.Visible) Then
      Inc(Count);
    MyWidget := MyWidget._Next;
	End;

  Repeat
    Pick := Nil;
    Z := -9999;
  	MyWidget := _First;
  	While (Assigned(MyWidget)) Do
  	Begin
      If (Not MyWidget.Visible) Then
      Begin
        MyWidget := MyWidget._Next;
        Continue;
      End;

      If (MyWidget._Picked) Then
      Begin
        MyWidget := MyWidget._Next;
        Continue;
      End;

      If (MyWidget.GetLayer>Z) And (AllowsEvents(MyWidget)) Then
      Begin
        Z := MyWidget.GetLayer;
        Pick := MyWidget;
      End;

      MyWidget := MyWidget._Next;
  	End;

    If (Assigned(Pick)) Then
    Begin
      Pick._Picked := True;
      Dec(Count);

      If (Self.Modal<>Nil) And (Not Pick.IsSameFamily(Modal)) Then
        Pick := Nil;

      If (Assigned(Pick)) And (Pick.OnMouseUp(X,Y, Button)) Then
      Begin
        //Log(logDebug, 'Game', 'Found a Widget for MouseDown: '+Pick.Name);
        Result := Pick;
        _LastWidget := Result;
        //Log(logDebug, 'Game', 'MouseDown event processed');
  		  Exit;
      End;
    End Else
      Break;

  Until (Count<=0);

  Result := Nil;
End;

Function UI.OnMouseMove(X,Y:Integer):Widget;
Var
  I, Count:Integer;
	MyWidget, Pick:Widget;
  Z:Single;
Begin
  _LastWidget := Nil;

//  ConvertGlobalToLocal(X, Y);

  If Assigned(_Dragger) Then
  Begin
    If _Dragger.OnMouseMove(X, Y) Then
    Begin
      Result := _Dragger;
      _LastWidget := Result;
      Exit;
    End;
  End;

  Count := 0;
	MyWidget := _First;
	While (Assigned(MyWidget)) Do
	Begin
    MyWidget._Picked := False;
    If (MyWidget.Visible) Then
      Inc(Count);
    MyWidget := MyWidget._Next;
	End;

  Repeat
    Pick := Nil;
    Z := -9999;
  	MyWidget := _First;
  	While (Assigned(MyWidget)) Do
  	Begin
      If (Not MyWidget.Visible) Then
      Begin
        MyWidget := MyWidget._Next;
        Continue;
      End;

      If (MyWidget._Picked) Then
      Begin
        MyWidget := MyWidget._Next;
        Continue;
      End;

      If (MyWidget.GetLayer>Z) Then
      Begin
        Z := MyWidget.GetLayer;
        Pick := MyWidget;
      End;

      MyWidget := MyWidget._Next;
  	End;

    If (Assigned(Pick)) Then
    Begin
      If (Not AllowsEvents(Pick)) Then
      Begin
        Result := Nil;
        Exit;
      End;

      Pick._Picked := True;
      Dec(Count);

      If (Self.Modal<>Nil) And (Not Pick.IsSameFamily(Modal)) Then
        Pick := Nil;

      If (Assigned(_Virtualkeyboard)) And (_VirtualKeyboard.Visible) And (Pick<>_VirtualKeyboard) And (Pick.Parent<>_VirtualKeyboard) Then
        Pick := Nil;

      If (Pick<>Nil) And (Pick.OnMouseMove(X,Y)) Then
      Begin
        //Log(logDebug, 'Game', 'Found a Widget for MouseDown: '+Pick.Name);
        Result := Pick;
        _LastWidget := Result;
        //Log(logDebug, 'Game', 'MouseDown event processed');
  		  Exit;
      End;
    End Else
      Break;

  Until (Count<=0);

  Result := Nil;
End;

Function UI.OnMouseWheel(X,Y:Integer; Delta:Integer):Widget;
Var
  I, Count:Integer;
	MyWidget, Pick:Widget;
  Z:Single;
Begin
  _LastWidget := Nil;
  Result := Nil;
  
  ConvertGlobalToLocal(X, Y);

	If Assigned(_Focus) Then
  Begin
		If _Focus.OnMouseWheel(X, Y, Delta) Then
    Begin
      Result := _Focus;
      _LastWidget := Result;
      Exit;
    End;
  End;

  Count := 0;
	MyWidget := _First;
	While (Assigned(MyWidget)) Do
	Begin
    MyWidget._Picked := False;
    If (MyWidget.Visible) Then
      Inc(Count);
    MyWidget := MyWidget._Next;
	End;

  Repeat
    Pick := Nil;
    Z := -9999;
  	MyWidget := _First;
  	While (Assigned(MyWidget)) Do
  	Begin
      If (Not MyWidget.Visible) Then
      Begin
        MyWidget := MyWidget._Next;
        Continue;
      End;

      If (MyWidget._Picked) Then
      Begin
        MyWidget := MyWidget._Next;
        Continue;
      End;

      If (MyWidget.GetLayer>Z) Then
      Begin
        Z := MyWidget.GetLayer;
        Pick := MyWidget;
      End;

      MyWidget := MyWidget._Next;
  	End;

    If (Assigned(Pick)) Then
    Begin
      If (Not AllowsEvents(Pick)) Then
      Begin
        Result := Nil;
        Exit;
      End;

      Pick._Picked := True;
      Dec(Count);

      If (Self.Modal<>Nil) And (Not Pick.IsSameFamily(Modal)) Then
        Pick := Nil;

      If (Assigned(_Virtualkeyboard)) And (_VirtualKeyboard.Visible) And (Pick<>_VirtualKeyboard) And (Pick.Parent<>_VirtualKeyboard) Then
        Pick := Nil;

      If (Pick<>Nil) And (Pick.OnMouseWheel(X,Y, Delta)) Then
      Begin
        Result := Pick;
        _LastWidget := Result;
  		  Exit;
      End;
    End Else
      Break;

  Until (Count<=0);

  Result := Nil;
End;

Procedure UI.SetHighlight(const Value: Widget);
Var
  Prev, Temp:Widget;
Begin
  Prev := Self._Highlight;

  Self._Highlight := Value;

  If Assigned(Value) Then
  Begin
    Temp := Value;
    Value.OnHighlight(Prev);
    If (Temp = Self._Highlight) Then
      Self._Highlight._SelectedWithKeyboard := False;
  End;
End;

Procedure UI.SetDragger(const Value: Widget);
Begin
  Self._Dragger := Value;
End;

Procedure UI.CloseWnd();
Begin
  System_BG.Visible := False;
  System_Wnd.Visible := False;
  //MsgWnd.Hide(widgetAnimateAlpha);

  Modal := Nil;
  Highlight := _PrevHighlight;
End;

Function CloseMsgBox(Src:Widget):Boolean; Cdecl;
Var
  UI:TERRA_UI.UI;
Begin
  Result := True;

  If (Src = Nil) Then
    Exit;

  UI := Src._UI;
  If (UI = Nil) Then
    Exit;

  If (UI.System_Wnd = Nil) Or (UI.System_Wnd.HasTweens) Then
    Exit;

  UI.CloseWnd();

  If Assigned(UI._WndCallback1) Then
    UI._WndCallback1(Src);

  UI._WndCallback1 := Nil;
  UI._WndCallback2 := Nil;
End;

Function CloseMsgBox2(Src:Widget):Boolean; Cdecl;
Var
  UI:TERRA_UI.UI;
Begin
  Result := True;

  If (Src = Nil) Then
    Exit;

  UI := Src._UI;
  If (UI = Nil) Then
    Exit;

  If (UI.System_Wnd = Nil) Or (UI.System_Wnd.HasTweens) Then
    Exit;

  UI.CloseWnd();

  If Assigned(UI._WndCallback2) Then
    UI._WndCallback2(Src);

  UI._WndCallback1 := Nil;
  UI._WndCallback2 := Nil;
End;

Procedure UI.InitTempWidgets();
Var
  N,I:Integer;
  S:UISprite;
Begin
  System_Wnd := UIWindow(GetWidget(System_Name_Wnd));
  System_Text := UILabel(GetWidget(System_Name_Text));
  For I:=0 To 2 Do
    System_Btn[I] := UIButton(GetWidget(System_Name_Btn+IntToString(I)));

  If Not Assigned(System_Wnd) Then
  Begin
    System_Wnd := UIWindow.Create(System_Name_Wnd, Self, Nil, 0, 0, 97, 8, 5);
    System_Wnd.Visible := False;
    System_Text := UILabel.Create(System_Name_Text, Self, System_Wnd, 20, 20, 0.5, '??');
    For I:=0 To 2 Do
    Begin
      Case I Of
      0:  N := 0;
      1:  N := -100;
      2:  N := 100;
      Else
      	N := 0;
      End;

      System_Btn[I] := UIButton.Create(System_Name_Btn+IntToString(I), Self, System_Wnd, N, 20, 0.5, 'Ok');
      System_Btn[I].Align := waBottomCenter;
    End;
  End;

  System_BG := UISprite(GetWidget(System_Name_BG));
  If Not Assigned(System_BG) Then
  Begin
    S := UISprite.Create(System_Name_BG, Self, Nil, 0, 0, 96.5);
    S.Texture := TextureManager.Instance.WhiteTexture;
    S.Rect.Width := UIManager.Instance.Width;
    S.Rect.Height := UIManager.Instance.Height;
    S.Color := ColorGrey(0, 100);
    S.Visible := False;
    System_BG := S;
  End;
End;

Procedure UI.InitStuff();
Var
  I:Integer;
Begin
  InitTempWidgets();
  System_Wnd.Align := waCenter;
  Modal := System_Wnd;

  System_BG.Visible := True;
  System_Wnd.Visible := True;

  For I:=0 To 2 Do
    System_Btn[I].OnMouseClick := CloseMsgBox;

  System_Btn[2].OnMouseClick := CloseMsgBox2;
End;

Procedure UI.MessageBox(Msg:TERRAString; Callback: WidgetEventHandler);
Var
  I:Integer;
Begin
  _WndCallback1 := Callback;
  InitStuff();

  UILabel(System_Text).Caption := Msg;
  For I:=0 To 2 Do
    System_Btn[I].Visible := (I=0);

  _PrevHighlight := Highlight;
  If (Highlight<>Nil) Then
    Highlight := System_Btn[0];
End;


Procedure UI.ChoiceBox(Msg, Option1, Option2:TERRAString; Callback1:WidgetEventHandler = Nil; Callback2: WidgetEventHandler = Nil);
Var
  I:Integer;
Begin
  _WndCallback1 := Callback1;
  _WndCallback2 := Callback2;
  InitStuff();

  UILabel(System_Text).Caption := System_Text._FontRenderer.AutoWrapText(Msg, System_Wnd.Size.X - 30);
  For I:=0 To 2 Do
    System_Btn[I].Visible := (I>0);

  UIButton(System_Btn[1]).Caption := Option1;
  UIButton(System_Btn[2]).Caption := Option2;

  _PrevHighlight := Highlight;
    Highlight := System_Btn[1];
End;

Procedure UI.ShowModal(W:Widget);
Begin
  If W = Nil Then
    Exit;

  InitTempWidgets();
  System_BG.Visible := True;

  If Not W.Visible Then
    W.Visible := True;

  Modal := W;

  If (Highlight<>Nil) Then
    Highlight := W;
End;

Procedure UI.ClearChoiceBox();
Begin
  Modal := Nil;

  If Assigned(System_BG) Then
    System_BG.Visible := False;

  If Assigned(System_Wnd) Then
    System_Wnd.Visible := False;
End;

Function UI.GetVirtualKeyboard: Widget;
Begin
  If (_VirtualKeyboard = Nil) Then
    _VirtualKeyboard := TERRA_UIVirtualKeyboard.VirtualKeyboard.Create('vkb', Self, 97);

  Result := _VirtualKeyboard;
End;

Procedure UI.OnOrientationChange;
Var
  MyWidget:Widget;
  It:Iterator;
Begin
  _Language := Application.Instance.Language;
  It := _Widgets.GetIterator();
  While (It.HasNext) Do
  Begin
    MyWidget := Widget(It.Value);
    If (MyWidget.Parent =  Nil) Then
      MyWidget._TransformChanged := True;
  End;
  ReleaseObject(It);
End;

Procedure UI.SetVisible(Const Value:Boolean);
Begin
  _Visible := Value;
End;

Function UI.GetHighlight: Widget;
Begin
  If (Assigned(_Highlight)) And (Not _Highlight.Visible) Then
    _Highlight := Nil;

  Result := _Highlight;
End;

Procedure UI.ConvertGlobalToLocal(Var X, Y: Integer);
Var
  P:Vector2D;
Begin
  P.X := X;
  P.Y := Y;

  P := _InverseTransform.Transform(P);

  X := Trunc(P.X);
  Y := Trunc(P.Y);
End;

Procedure UI.ConvertLocalToGlobal(Var X, Y: Integer);
Var
  P:Vector2D;
Begin
  P.X := X;
  P.Y := Y;

  P := _Transform.Transform(P);

  X := Trunc(P.X);
  Y := Trunc(P.Y);
End;

Procedure UI.SetTransform(const M: Matrix3x3);
Var
  It:Iterator;
  W:Widget;
Begin
  _Transform := M;
  _InverseTransform := MatrixInverse2D(M);
                         
  _ClipRect.Style := clipSomething;
  _ClipRect.X := 0;
  _ClipRect.Y := 0;
  _ClipRect.Width := UIManager.Instance.Width;
  _ClipRect.Height := UIManager.Instance.Height;
  _ClipRect.Transform(M);

  It := Self.Widgets.GetIterator();
  While It.HasNext() Do
  Begin
    W := Widget(It.Value);

    W._TransformChanged := True;
  End;
  ReleaseObject(It);
End;

Function UI.GetFontRenderer():FontRenderer;
Begin
  If Self._FontRenderer = Nil Then
    Self._FontRenderer := UIManager.Instance.FontRenderer;

  Result := Self._FontRenderer;
  Result.SetFont(Self._DefaultFont);
  Result.SetTransform(Self.Transform);
  Result.SetColor(ColorWhite);
  Result.SetClipRect(_ClipRect);
  Result.SetDropShadow(ColorGrey(0, 64));
End;

Function UI.OnRegion(X, Y: Integer): Boolean;
Begin
  Result := (X>=0) And (Y>=0) And (X<=UIManager.Instance.Width) And (Y<=UIManager.Instance.Height);
End;

Procedure UI.SetFontRenderer(const Value: FontRenderer);
Begin
  _FontRenderer := Value;
End;

Function UI.SelectNearestWidget(Target:Widget):Widget;
Var
  It:Iterator;
  Base:Vector2D;
  GroupID:Integer;
  Min, Dist:Single;
  W:Widget;
Begin
  Result := Nil;
  If Target = Nil Then
    Exit;

  Min := 99999;
  Base := Target.Position;
  GroupID := Target.HighlightGroup;

  It := Self.Widgets.GetIterator();
  While It.HasNext() Do
  Begin
    W := Widget(It.Value);
    If (W = Target) Or (Not W.CanHighlight(GroupID)) Then
      Continue;

    Dist := W.Position.Distance(Base);
    If (Dist< Min) Then
    Begin
      Min := Dist;
      Result := W;
    End;
  End;
  ReleaseObject(It);
End;

Procedure UI.GetFirstHighLight(GroupID:Integer);
Var
  W:Widget;
  It:Iterator;
Begin
  It := Self.Widgets.GetIterator();
  While It.HasNext() Do
  Begin
    W := Widget(It.Value);
    If (Not W.CanHighlight(GroupID)) Then
      Continue;

    Self.Highlight := W;
    Break;
  End;
  ReleaseObject(It);
End;

{ UISkinLayout }
Constructor UISkinLayout.Create(Source: TextureAtlasItem);
Var
  I:Integer;
Begin
  _Target := Source;

  For I:=0 To 2 Do
  Begin
    X[I] := I * (1/3);
    Y[I] := I * (1/3);
  End;
End;

Function UISkinLayout.GCSX(I: Integer): Single;
Begin
  If (I<2) Then
    Result := (X[Succ(I)] - X[I])
  Else
    Result := (1.0 - X[I]);

  If Assigned(_Target) Then
    Result := Result * _Target.Buffer.Width;
End;

Function UISkinLayout.GCSY(J: Integer): Single;
Begin
  If (J<2) Then
    Result := (Y[Succ(J)] - Y[J])
  Else
    Result := (1.0 - Y[J]);

  If Assigned(_Target) Then
    Result := Result * _Target.Buffer.Height;
End;

Function UISkinLayout.GetWidth(Width: Integer): Single;
Begin
  Result := Self.GCSX(0) + Self.GCSX(1) * Width + Self.GCSX(2);
End;

Function UISkinLayout.GetHeight(Height: Integer): Single;
Begin
  Result := Self.GCSY(0) + Self.GCSY(1) * Height + Self.GCSY(2);
End;

Procedure UISkinLayout.Release;
Begin
  // do nothing
End;

{ UIManager }
Procedure UIManager.Init;
Begin
  _TextureAtlas := Nil;
  _Ratio := 1.0;
  _UpdateTextureAtlas := False;
End;

Procedure UIManager.Release;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_UICount) Do
    ReleaseObject(_UIList[I]);

  _UICount := 0;

  ReleaseObject(_FontRenderer);

  ReleaseObject(_TextureAtlas);

  _UIManager_Instance := Nil;
End;

Procedure UIManager.AddUI(UI: UI);
Var
  I:Integer;
Begin
  If (UI = Nil) Then
    Exit;

  For I:=0 To Pred(_UICount) Do
  If (_UIList[I] = UI) Then
    Exit;

  Inc(_UICount);
  SetLength(_UIList, _UICount);
  _UIList[Pred(_UICount)] := UI;
End;

Procedure UIManager.RemoveUI(UI: UI);
Var
  I:Integer;
Begin
  I := 0;
  While (I<_UICount) Do
  If (_UIList[I] = UI) Then
  Begin
    _UIList[I] := _UIList[Pred(_UICount)];
    Dec(_UICount);
  End Else
    Inc(I);
End;

Function UIManager.GetTextureAtlas: TextureAtlas;
Begin
  If (Not Assigned(_TextureAtlas)) Then
    _TextureAtlas := TERRA_TextureAtlas.TextureAtlas.Create('UI', TextureAtlasWidth, TextureAtlasHeight);

  Result := _TextureAtlas;
End;

Function UIManager.GetWidth: Integer;
Begin
  {If GraphicsManager.Instance.LandscapeOrientation Then
  Begin
    Result := GraphicsManager.Instance.Height;
  End Else
  Begin
    Result := GraphicsManager.Instance.Width;
  End;}
  Result := GraphicsManager.Instance.UIViewport.Width;
End;

Function UIManager.GetHeight: Integer;
Begin
  {If GraphicsManager.Instance.LandscapeOrientation Then
  Begin
    Result := GraphicsManager.Instance.Width;
  End Else
  Begin
    Result := GraphicsManager.Instance.Height;
  End;}
  Result := GraphicsManager.Instance.UIViewport.Height;
End;

{Procedure UIManager.Adjust(Width, Height: Integer);
Var
  A,B:Integer;
Begin
  A := IntMin(Self.Width, Self.Height);
  B := IntMax(Width, Height);
  If (A<=B) Then
    Self._DefaultFont.BilinearFilter := True;
  GraphicsManager.Instance.AdjustRatio(Width, Height);
End;}


Procedure UIManager.TextureAtlasClear();
Begin
  _UpdateTextureAtlas := True;
End;

Class Function UIManager.Instance: UIManager;
Begin
  If (_UIManager_Instance = Nil) Then
    _UIManager_Instance := InitializeApplicationComponent(UIManager, TweenManager);

  Result := UIManager(_UIManager_Instance.Instance);
End;

Procedure UIManager.OnLanguageChange;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_UICount) Do
    _UIList[I].UpdateLanguage();
End;

Procedure UIManager.Render;
Var
  I:Integer;
Begin
  If (_UpdateTextureAtlas) Then
  Begin
    Log(logDebug, 'UI', 'Updating UI TextureAtlas');

    Self.GetTextureAtlas.Update();
    _UpdateTextureAtlas := False;

    For I:=0 To Pred(_TextureAtlas.PageCount) Do
      _TextureAtlas.GetTexture(I).Filter := filterBilinear;
  End;

  For I:=0 To Pred(_UICount) Do
  If (_UIList[I].Visible) Then
    _UIList[I].Render();
End;

Procedure UIManager.AfterEffects;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_UICount) Do
  If _UIList[I].Visible Then
    _UIList[I].AfterEffects();
End;

Procedure UIManager.OnOrientationChange;
Var
  I:Integer;
Begin
  If (GraphicsManager.Instance.UIViewport = Nil) Then
    Exit;

  UpdateRatio();
  For I:=0 To Pred(_UICount) Do
    _UIList[I].OnOrientationChange;
End;

Procedure UIManager.UpdateRatio;
Begin
 (* If (IsLandscapeOrientation(Application.Instance.Orientation)) Then
    _Ratio := (Height/Width)
  Else*)
    _Ratio := 1.0;
End;

Function UIManager.GetUI(Index: Integer): UI;
Begin
  If (Index<0) Or (Index>=Count) Then
    Result := Nil
  Else
    Result := Self._UIList[Index];
End;

Procedure UIManager.SetFontRenderer(const Value: FontRenderer);
Begin
  If _FontRenderer = FontRenderer Then
    Exit;

  _FontRenderer := FontRenderer;
End;

Function UIManager.GetFontRenderer: FontRenderer;
Begin
  If _FontRenderer = Nil Then
    _FontRenderer := TERRA_FontRenderer.FontRenderer.Create();

  Result := _FontRenderer;
End;

End.
