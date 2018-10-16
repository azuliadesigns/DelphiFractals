unit fractal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Menus, ComCtrls, Gauges;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    btnDraw: TButton;
    grpParameters: TGroupBox;
    txtXmax: TEdit;
    txtXmin: TEdit;
    txtYmax: TEdit;
    txtYmin: TEdit;
    txtRC: TEdit;
    txtIC: TEdit;
    lblIC: TLabel;
    lblRC: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    grpType: TGroupBox;
    rbMS: TRadioButton;
    rbJS: TRadioButton;
    grpZoom: TGroupBox;
    zoomx2: TRadioButton;
    zoomx4: TRadioButton;
    zoomx8: TRadioButton;
    zoomcust: TRadioButton;
    rbCosTim: TRadioButton;
    lambda: TTrackBar;
    lambdav: TLabel;
    lambdalabel: TLabel;
    Progress: TGauge;
    IterSelect: TUpDown;
    txtIter: TEdit;
    lblMaxIterlbl: TLabel;
    grpColors: TGroupBox;
    lblColorslbl: TLabel;
    cboColors: TComboBox;
    cboNumColors: TComboBox;
    Label5: TLabel;
    cboPal: TComboBox;
    lblPallbl: TLabel;
    btnSaveImageDisc: TButton;
    btnSaveLoc: TButton;
    btnLoadLoc: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Memo1: TMemo;
    lblProgress: TLabel;
    grpImageSize: TGroupBox;
    rb128: TRadioButton;
    rb256: TRadioButton;
    rb512: TRadioButton;
    FractalImage: TImage;
    procedure btnDrawClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpdateTextBoxes(Mode: integer);
    procedure UpdateVars;
    procedure DrawJulia;
    procedure DrawCosTim;
    procedure DrawMandel;
    function CalcColorMandel(cx,cy: double; maxiter: integer): TColor;
    function CalcColorJulia(cx,cy,X,Y: double; maxiter: integer): TColor;
    function CalcColorCosTim(k,X,Y: double; maxiter: integer): TColor;
    procedure rbMSClick(Sender: TObject);
    procedure rbJSClick(Sender: TObject);
    procedure FractalImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FractalImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FractalImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure zoomx2Click(Sender: TObject);
    procedure zoomx4Click(Sender: TObject);
    procedure zoomx8Click(Sender: TObject);
    procedure zoomcustClick(Sender: TObject);
    procedure GetPalette;
    procedure rbCosTimClick(Sender: TObject);
    procedure lambdaChange(Sender: TObject);
    procedure IterSelectClick(Sender: TObject; Button: TUDBtnType);
    procedure cboColorsChange(Sender: TObject);
    procedure cboNumColorsChange(Sender: TObject);
    procedure cboPalChange(Sender: TObject);
    procedure btnSaveImageDiscClick(Sender: TObject);
    procedure btnSaveLocClick(Sender: TObject);
    procedure btnLoadLocClick(Sender: TObject);
    procedure rb128Click(Sender: TObject);
    procedure rb256Click(Sender: TObject);
    procedure rb512Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  xmin,xmax,ymin,ymax,cy,cx: extended;
  txmin,txmax,tymin,tymax: extended;
  MOUSEDOWNE, DRAWINGF: boolean;
  XOld, YOld, ZoomFactor : integer;
  maxiter, colorFactor,PaletteType,TimeTakenM, TimeTakenS : integer;
  eHour,eMin,eSec,eMSec,sHour,sMin,sSec,SMSec: Word;
  p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16: integer;
  sTime, eTime : TDateTime;
implementation

{$R *.DFM}

function TfrmMain.CalcColorMandel(cx,cy: double; maxiter: integer): TColor;
var
   x2,y2,temp,x,y : double;
   iter: integer;
begin
     x := 0;
     y := 0;
     x2 := 0;
     y2 := 0;
     iter := 0;
     while ((iter < maxiter) and ((abs(x2) + abs(y2)) < 100000)) do
     begin
          temp := x2 - y2 + cx;
          y := (2 * x * y) + cy;
          x := temp;
          x2 := x * x;
          y2 := y * y;
          inc(iter);
     end;
     if PaletteType = 2 then result := trunc((iter+80)*colorFactor);
     if PaletteType = 1 then
     begin
          if ((iter > 60) AND (iter < maxiter)) then result :=     p14
          else if ((iter < 56) AND (iter > 53)) then result :=     p13
          else if ((iter < 52) AND (iter > 47)) then result :=     p12
          else if ((iter < 48) AND (iter > 45)) then result :=     p11
          else if ((iter < 44) AND (iter > 41)) then result :=     p10
          else if ((iter < 40) AND (iter > 37)) then result :=     p9
          else if ((iter < 36) AND (iter > 33)) then result :=     p8
          else if ((iter < 32) AND (iter > 29)) then result :=     p7
          else if ((iter < 28) AND (iter > 25)) then result :=     p6
          else if ((iter < 24) AND (iter > 21)) then result :=     p5
          else if ((iter < 20) AND (iter > 17)) then result :=     p4
          else if ((iter < 16) AND (iter > 13)) then result :=     p3
          else if ((iter < 12) AND (iter > 9)) then result  :=     p2
          else if ((iter < 8) AND (iter > 5)) then result   :=     p1
          else if (iter < 4) then result                    :=     p0
          else result := 0;
     end;
end;

function TfrmMain.CalcColorJulia(cx,cy,X,Y: double; maxiter: integer): TColor;
var
   x2,y2,xtemp,ytemp : double;
   iter: integer;
begin
     iter := 0;
     x2 := X + cx;
     y2 := Y + cy;
     while ((iter < maxiter) and ((abs(x2) + abs(y2)) < 100000)) do
     begin
           xtemp := (x2 * x2) - (y2 * y2) + cx;
           ytemp := 2 * (x2 * y2) + cy;
           x2 := xtemp;
           y2 := ytemp;
           inc(iter);
     end;

     result := trunc((iter+80)*colorFactor)

end;

function TfrmMain.CalcColorCosTim(k,X,Y: double; maxiter: integer): TColor;
var
   xx,yy,coshx,coshy,sinhx,sinhy : double;
   iter: integer;
begin


     xx := X;
     yy := Y;
     iter := 1;

     While iter < maxiter do
     begin
          if (Abs(yy) > 50) or (Abs(xx) > 50) then
          begin
               result := iter;
               break;
          end;

          coshx := 0.5 * (Exp(xx) + Exp(-xx));
          sinhx := 0.5 * (Exp(xx) - Exp(-xx));
          coshy := 0.5 * (Exp(yy) + Exp(-yy));
          sinhy := 0.5 * (Exp(yy) - Exp(-yy));
          x := k * Cos(xx) * coshy;
          y := -k * Sin(xx) * sinhy;
          xx := x;
          yy := y;
          inc(iter);
     end;
     result := trunc((iter+80)*colorFactor);
end;

procedure TfrmMain.DrawMandel;
var
   x,y: extended;
   ix,iy,nx,ny: integer;
   aColor: TColor;
begin
     nx := frmMain.FractalImage.Width;
     ny := frmMain.FractalImage.Height;
     DRAWINGF := TRUE;
     for iy := 0 to ny-1 do
     begin
          Y := (ymin +iy * (ymax -ymin) / (ny - 1));
          for ix := 0 to nx-1 do
          begin
               X := (xmin + ix * (xmax - xmin) / (nx - 1));
               aColor := CalcColorMandel(X,Y,maxiter);
               frmMain.FractalImage.Canvas.MoveTo(ix,iy);
               frmMain.FractalImage.Canvas.Pen.Color := aColor;
               frmMain.FractalImage.Canvas.LineTo(ix,iy+16);
               frmMain.Progress.Progress := trunc(((iy/FractalImage.Width)*100)+1);
          end;
          Application.ProcessMessages;
     end;
     DRAWINGF := FALSE;
end;

procedure TfrmMain.DrawJulia;
var
   x,y: extended;
   ix,iy,nx,ny: integer;
   aColor: TColor;
begin
     nx := FractalImage.Width;
     ny := FractalImage.Height;
     DRAWINGF := TRUE;
     for iy := 0 to ny-1 do
     begin
          Y := (ymin + iy * (ymax - ymin) / (ny - 1));
          for ix := 1 to nx-1 do
          begin
               X := (xmin + ix * (xmax - xmin) / (nx - 1));
               aColor := CalcColorJulia(cx, cy, X,Y,maxiter);
               FractalImage.Canvas.Pixels[ix,iy] := aColor;
               frmMain.Progress.Progress := trunc((iy/FractalImage.Width)*100)+1;
          end;
          Application.ProcessMessages;
     end;
     DRAWINGF := FALSE;
end;

procedure TfrmMain.DrawCosTim;
var
   x,y,k: extended;
   ix,iy,nx,ny: integer;
   aColor: TColor;
begin
     nx := FractalImage.Width;
     ny := FractalImage.Height;
     DRAWINGF := TRUE;
     k := (lambda.position /10) * (3.5 - 1.5) / 32767 + 1.5;
     for iy := 0 to trunc(ny/2) do
     begin
          Y := (ymin + iy * (ymax - ymin) / (ny - 1));
          for ix := 1 to nx-1 do
          begin
               X := (xmin + ix * (xmax - xmin) / (nx - 1));
               aColor := CalcColorCosTim(k, X,Y,maxiter);
               FractalImage.Canvas.Pixels[ix,iy] := aColor;
               FractalImage.Canvas.Pixels[ix,FractalImage.Width-iy] := aColor;
               frmMain.Progress.Progress := trunc((2*iy/FractalImage.Width)*100)+1;
          end;
          Application.ProcessMessages;
     end;
     DRAWINGF := FALSE;
end;


procedure TfrmMain.UpdateVars;
begin
       xmax := StrToFloat(frmMain.txtXmax.Text);
       xmin := StrToFloat(frmMain.txtXmin.Text);
       ymax := StrToFloat(frmMain.txtYmax.Text);
       ymin := StrToFloat(frmMain.txtYmin.Text);
       cx   := StrToFloat(frmMain.txtRC.Text);
       cy   := StrToFloat(frmMain.txtIC.Text);
       maxiter := StrToInt(frmMain.txtIter.Text);
end;

procedure TfrmMain.UpdateTextBoxes(Mode: integer);
begin
     if mode = 0 then
     begin
          frmMain.txtXmax.Text := FloatToStr(xmax);
          frmMain.txtXmin.Text := FloatToStr(xmin);
          frmMain.txtYmax.Text := FloatToStr(ymax);
          frmMain.txtYmin.Text := FloatToStr(ymin);
          frmMain.txtRC.Text   := FloatToStr(cx);
          frmMain.txtIC.Text   := FloatToStr(cy);
          frmMain.IterSelect.Position := maxiter;
     end;

     if mode = 1 then
     begin
          frmMain.txtXmax.Text := FloatToStr(txmax);
          frmMain.txtXmin.Text := FloatToStr(txmin);
          frmMain.txtYmax.Text := FloatToStr(tymax);
          frmMain.txtYmin.Text := FloatToStr(tymin);
          frmMain.txtRC.Text   := FloatToStr(cx);
          frmMain.txtIC.Text   := FloatToStr(cy);
          frmMain.IterSelect.Position := maxiter;
     end;
end;


procedure TfrmMain.btnDrawClick(Sender: TObject);
begin
  if (DRAWINGF = FALSE) then begin
     UpdateVars;
     if frmMain.rbMS.checked = TRUE then DrawMandel;
     if frmMain.rbJS.checked = TRUE then DrawJulia;
     if frmMain.rbCosTim.Checked = TRUE then DrawCosTim;
     sTime := Time;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
     xmax       := 0.5;
     xmin       := -1.5;
     ymax       := 1;
     ymin       := -1;
     cx         := -0.74543;
     cy         := 0.11301;
     ZoomFactor := 2;
     PaletteType := 2;
     UpdateTextBoxes(0);
     frmMain.IterSelect.Position := 176;
     frmMain.cboColors.ItemIndex := 0;
     frmMain.cboNumColors.ItemIndex := 1;
     frmMain.cboPal.ItemIndex := 0;
     GetPalette;
     Colorfactor := 1;
     frmMain.ClientHeight := 512;
     frmMain.ClientWidth := 512 + Panel1.Width;
end;

procedure TfrmMain.rbMSClick(Sender: TObject);
begin
     xmax       := 0.5;
     xmin       := -1.5;
     ymax       := 1;
     ymin       := -1;
     lambdalabel.visible := FALSE;
     lambdav.visible := FALSE;
     lambda.visible := FALSE;
     lblrC.visible := FALSE;
     lbliC.visible := FALSE;
     txtRc.visible := FALSE;
     txtic.visible := FALSE;
     UpdateTextBoxes(0);
end;

procedure TfrmMain.rbJSClick(Sender: TObject);
begin
     xmax       := 2.5;
     xmin       := -1.0;
     ymax       := 2.5;
     ymin       := -2;
     cx         := -0.74543;
     cy         := 0.11301;
     UpdateTextBoxes(0);
     lambdalabel.visible := FALSE;
     lambdav.visible := FALSE;
     lambda.visible := FALSE;
     lblrC.visible := TRUE;
     lbliC.visible := TRUE;
     txtRc.visible := TRUE;
     txtic.visible := TRUE;
end;

procedure TfrmMain.FractalImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   XSide, YSide : integer;
begin
     if DRAWINGF = FALSE then
     begin
          MOUSEDOWNE := TRUE;
          FractalImage.Canvas.Pen.Mode := pmXor;
          XSide := trunc(FractalImage.Width / ZoomFactor);
          YSide := trunc(FractalImage.Height / ZoomFactor);
          FractalImage.Canvas.Rectangle( (X - trunc(0.5 * XSide)), (Y - trunc(0.5 * YSide)), (X + trunc(0.5 * XSide)), (Y + trunc(0.5 * YSide)));
          XOld := X;
          YOld := Y;
     end;
end;

procedure TfrmMain.FractalImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   XSide, YSide: integer;
begin
     if MOUSEDOWNE then begin
     FractalImage.Canvas.Pen.Mode := pmXor;
     XSide := trunc(FractalImage.Width / ZoomFactor);
     YSide := trunc(FractalImage.Height / ZoomFactor);
     FractalImage.Canvas.Rectangle( (XOld - trunc(0.5 * XSide)), (YOld - trunc(0.5 * YSide)), (XOld + trunc(0.5 * XSide)), (YOld + trunc(0.5 * YSide)));
     FractalImage.Canvas.Rectangle( (X - trunc(0.5 * XSide)), (Y - trunc(0.5 * YSide)), (X + trunc(0.5 * XSide)), (Y + trunc(0.5 * YSide)));
     XOld := X;
     YOld := Y;
     end;
end;

procedure TfrmMain.FractalImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
   XSide, YSide: integer;
   temp: real;
  begin
     if DRAWINGF = FALSE then
     begin
          MOUSEDOWNE := FALSE;
          FractalImage.Canvas.Pen.Mode := pmXor;
          XSide := trunc(FractalImage.Width / ZoomFactor);
          YSide := trunc(FractalImage.Height / ZoomFactor);
          FractalImage.Canvas.Rectangle( (XOld - trunc(0.5 * XSide)), (YOld - trunc(0.5 * YSide)), (XOld + trunc(0.5 * XSide)), (YOld + trunc(0.5 * YSide)));
          FractalImage.Canvas.Pen.Mode := pmCopy;

          temp := xmin+(XOld - trunc(0.5 * XSide))*(xmax-xmin) / (FractalImage.Width);
          txmax := xmin+(XOld + trunc(0.5 * XSide))*(xmax-xmin) / (FractalImage.Width);
          txmin := temp;
          temp := ymin+(YOld - trunc(0.5 * YSide))*(ymax-ymin) / (FractalImage.Height);
          tymax := ymin+(YOld + trunc(0.5 * YSide))*(ymax-ymin) / (FractalImage.Height);
          tymin := temp;
          UpdateTextBoxes(1);
     end;
end;

procedure TfrmMain.zoomx2Click(Sender: TObject);
begin
     ZoomFactor := 2;
end;

procedure TfrmMain.zoomx4Click(Sender: TObject);
begin
     ZoomFactor := 4;
end;

procedure TfrmMain.zoomx8Click(Sender: TObject);
begin
     ZoomFactor := 8;
end;

procedure TfrmMain.zoomcustClick(Sender: TObject);
begin
     ZoomFactor := StrToInt(InputBox('Custom Zoom Factor', 'Enter Number Between 1 and 30', IntToStr(ZoomFactor)));
end;

procedure TfrmMain.rbCosTimClick(Sender: TObject);
begin
     xmax       := 5;
     xmin       := -5;
     ymax       := 5;
     ymin       := -5;
     cx         := -0.74543;
     cy         := 0.11301;
     lambdalabel.visible := TRUE;
     lambdav.visible := TRUE;
     lambda.visible := TRUE;
     lblrC.visible := FALSE;
     lbliC.visible := FALSE;
     txtRc.visible := FALSE;
     txtic.visible := FALSE;
     UpdateTextBoxes(0);
end;

procedure TfrmMain.lambdaChange(Sender: TObject);
begin
     lambdav.caption := FloatToStr(Lambda.position / 10) ;
     UpdateVars;
end;

procedure TfrmMain.IterSelectClick(Sender: TObject; Button: TUDBtnType);
begin
     UpdateVars;
end;

procedure TfrmMain.cboColorsChange(Sender: TObject);
begin
   if cboColors.ItemIndex = 0 then colorFactor := 1;
   if cboColors.ItemIndex = 1 then colorFactor := 256;
   if cboColors.ItemIndex = 2 then colorFactor := 256*256;

end;

procedure TfrmMain.cboNumColorsChange(Sender: TObject);
begin
     if cboNumColors.ItemIndex = 0 then begin  // 16 colors
        cboPal.Enabled := TRUE;
        cboColors.Enabled := FALSE;
        maxiter := 64;
        UpdateTextBoxes(0);
        PaletteType := 1;
     end;
     if cboNumColors.ItemIndex = 1 then begin  // 256 colors
        cboPal.Enabled := FALSE;
        cboColors.Enabled := TRUE;
        maxiter := 176;
        UpdateTextBoxes(0);
        PaletteType := 2;
     end;
end;

procedure TfrmMain.cboPalChange(Sender: TObject);
begin
GetPalette;
end;

procedure TfrmMain.GetPalette;
begin
     if cboPal.ItemIndex = 0 then begin
        p14 :=    255 * 255 * 255;
        p13 :=    240 * 255 * 255;
        p12 :=    244 * 255 * 255;
        p11 :=    192 * 255 * 255;
        p10 :=    176 * 255 * 255;
        p9  :=   160 * 255 * 255;
        p8  :=   144 * 255 * 255;
        p7  :=   128 * 255 * 255;
        p6  :=   112 * 255 * 255;
        p5  :=   96 * 255 * 255;
        p4  :=   80 * 255 * 255;
        p3  :=   64 * 255 * 255;
        p2  :=   32 * 255 * 255;
        p1  :=   16 * 255 * 255;
        p0  :=   0;
     end;
end;

procedure TfrmMain.btnSaveImageDiscClick(Sender: TObject);
begin
     SaveDialog1.Title := 'Save Fractal to Disk';
     SaveDialog1.DefaultExt := 'bmp';
     SaveDialog1.Filename := '*.bmp';
     SaveDialog1.Filter := '*.bmp';
     SaveDialog1.Execute;
     FractalImage.Picture.SaveToFile(SaveDialog1.Filename);
end;

procedure TfrmMain.btnSaveLocClick(Sender: TObject);
var
   FType: integer;
begin
  Memo1.Lines.Clear;
  Memo1.Lines.Add(FloatToStr(xmin));
  Memo1.Lines.Add(FloatToStr(ymin));
  Memo1.Lines.Add(FloatToStr(xmax));
  Memo1.Lines.Add(FloatToStr(ymax));
  Memo1.Lines.Add(FloatToStr(maxiter));
  if rbMS.Checked = TRUE then FType := 0;
  if rbJS.Checked = TRUE then FType := 1;
  if rbCosTim.checked = TRUE then FType := 2;
  Memo1.Lines.Add(IntToStr(FType));
  SaveDialog1.Title := 'Save Fractal Location to Disk';
  SaveDialog1.DefaultExt := 'fra';
  SaveDialog1.Filename := '';
  SaveDialog1.Filter := '*.fra';
  SaveDialog1.Execute;
  Memo1.Lines.SaveToFile(SaveDialog1.Filename);
end;

procedure TfrmMain.btnLoadLocClick(Sender: TObject);
var
   FType: integer;
begin
  OpenDialog1.Title := 'Open Fractal Location';
  OpenDialog1.DefaultExt := 'fra';
  OpenDialog1.Filename := '';
  OpenDialog1.Filter := '*.fra';
  OpenDialog1.Execute;
  Memo1.Lines.LoadFromFile(OpenDialog1.Filename);
  xmin := StrToFloat(Memo1.Lines[0]);
  ymin := StrToFloat(Memo1.Lines[1]);
  xmax := StrToFloat(Memo1.Lines[2]);
  ymax := StrToFloat(Memo1.Lines[3]);
  maxiter := StrToInt(Memo1.Lines[4]);
  FType := StrToInt(Memo1.Lines[5]);
  if FType = 0 then rbMS.Checked := TRUE;
  if FType = 1 then rbJS.Checked := TRUE;
  if FType = 2 then rbCosTim.Checked := TRUE;
  UpdateTextBoxes(0);
end;

procedure TfrmMain.rb128Click(Sender: TObject);
begin
FractalImage.Align := alNone;
FractalImage.Width := 128;
FractalImage.Height := 128;
FractalImage.Top := trunc(frmMain.Height / 2) - trunc(FractalImage.Height / 2);
frmMain.Width := FractalImage.Width + Panel1.Width;
frmMain.Position := poScreenCenter;
end;

procedure TfrmMain.rb256Click(Sender: TObject);
begin
FractalImage.Align := alNone;
FractalImage.Width := 256;
FractalImage.Height := 256;
FractalImage.Top := trunc(frmMain.Height / 2) - trunc(FractalImage.Height / 2);
frmMain.Width := FractalImage.Width + Panel1.Width;
frmMain.Position := poScreenCenter;
end;

procedure TfrmMain.rb512Click(Sender: TObject);
begin
FractalImage.Align := alClient;
frmMain.ClientHeight := 512;
frmMain.ClientWidth := 512 + Panel1.Width;
frmMain.Position := poScreenCenter;
end;

end.
