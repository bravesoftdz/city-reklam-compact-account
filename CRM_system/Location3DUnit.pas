unit Location3DUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpenGL, DB;

type

  TConstAxis = (
    caX,
    caY,
    caZ
   );

   TImagePosition = (
    ipLeft,
    ipRight
   );

  TLocation3DForm = class(TForm)
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure LoadArrayFromImage(ImCanvas: TCanvas;
      ConstAxis: TConstAxis; XOffset, YOffset, ZOffset: Double;
      ImagePosition: TImagePosition; BitmapWidth, BitmapHeight: Integer);
    procedure LoadCurrentLocation;
  private
    { Private declarations }
    DC : HDC;    //�������� ����������
    hrc: HGLRC;  //�������� ���������������
    ry : GLfloat;
    tx : GLfloat;
    quadObj : GLUquadricObj;

    img,img1,res:array[1..200,1..100,0..2]of glubyte;
  public
    { Public declarations }
    procedure SetDCPixelFormat(DC: Cardinal);
    procedure Morph;
  end;

  const m=15;

  var
    Location3DForm: TLocation3DForm;
    mode : (POINT, LINE, FILL, SILHOUETTE, LINE_STRIP) = LINE_STRIP;
    gluobj : (SPHERE, CONE, CYLINDER, DISK, COMPLEX_OBJ) = COMPLEX_OBJ;
    orientation : (OUTSIDE, INSIDE) = OUTSIDE;
    normals : (NONE, FLAT, SMOOTH) = SMOOTH;



implementation

{$R *.dfm}

uses MainUnit, DBConnectUnit;

procedure TLocation3DForm.Morph;
var i,k,j,c,t: Integer;
begin
      t:=t+1;
      for k:=1 to 50 do
      for i:=1 to 50 do
 for j:=0 to 2 do
{���������� ����������� ������ ��������������� ����������� � ������� res}
 res[i][k][j]:=img[i][k][j]+round((img1[i][k][j]-img[i][k][j])*t/m);
end;

procedure TLocation3DForm.LoadArrayFromImage(ImCanvas: TCanvas;
  ConstAxis: TConstAxis; XOffset, YOffset, ZOffset: Double;
  ImagePosition: TImagePosition; BitmapWidth, BitmapHeight: Integer);
var i,k,c: Integer;
    p_dist_coeff: Single;
    position_coeff: SmallInt;
    img_height, img_width: Integer;
begin
  {���������� �������� RGB-���������� ������ �������� �� ����������� Image1 � Image2}
  //glPointSize(1);
  //glclear(gl_color_buffer_bit or gl_depth_buffer_bit);
  position_coeff:=-1;
  if ImagePosition=ipLeft then
    position_coeff:=1;
  p_dist_coeff:=0.01;
  glPointSize(2);
  glEnable(GL_POINT_SMOOTH);
  glBegin(GL_POINTS);
  //ImCanvas.
  img_width:=BitmapWidth;
  img_height:=BitmapHeight;
  for k:=1 to img_height do
    for i:=1 to img_width do begin
    c:=ImCanvas.pixels[i,k];
    img[k][i][0]:=getRvalue(c);  {Red}
    img[k][i][1]:=getGvalue(c);  {Green}
    img[k][i][2]:=getBvalue(c);  {Blue}
    glColor3f(img[k][i][0]/255,img[k][i][1]/255,img[k][i][2]/255);
    //if img[51-k][i][0]<255 then
    //   ShowMessage(FloatToStr(img[51-k][i][0]));
    //glColor3f(1-0.1*i,1,0);

    if ConstAxis=caX then
      begin
        glVertex3f(XOffset,YOffset-k*p_dist_coeff,
          position_coeff*(ZOffset-i*p_dist_coeff));
      end
    else if ConstAxis=caY then
      begin
        //glVertex3f(position_coeff*(XOffset-i*p_dist_coeff),YOffset-k*p_dist_coeff,
        //  ZOffset*p_dist_coeff);
      end
    else if ConstAxis=caZ then
      begin
        glVertex3f(position_coeff*(XOffset-i*p_dist_coeff),YOffset-k*p_dist_coeff,
          ZOffset);
      end
    else
      begin

      end;

    //����� ������
    //glVertex3f(-48*p_dist_coeff,1.2-k*p_dist_coeff,0.5-i*p_dist_coeff);
    //glVertex3f(-52*p_dist_coeff, 1.2-k*p_dist_coeff,i*p_dist_coeff-0.5);
    //������
    //glVertex3f(252*p_dist_coeff,1.2-k*p_dist_coeff,0.5-i*p_dist_coeff);
    //glVertex3f(248*p_dist_coeff, 1.2-k*p_dist_coeff,i*p_dist_coeff-0.5);
  end;
  glEnd;
  //glpixelstorei(gl_unpack_alignment,1);
  //glrasterpos(0,0);
  //gldrawpixels(50,50,gl_rgb,gl_unsigned_byte,@img);
  //swapbuffers(dc);
  //invalidaterect(handle,nil,false);
end;

procedure TLocation3DForm.FormCreate(Sender: TObject);
begin
  DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 glClearColor (0.5, 0.5, 0.75, 1.0); // ���� ����
 glLineWidth (1.5);
 glEnable (GL_LIGHTING);
 glEnable (GL_LIGHT0);
 glEnable (GL_DEPTH_TEST);
 glEnable (GL_COLOR_MATERIAL); // �������. ��� ���. ��������� ����� ��� ����� ����� ����������
 glColor3f (1.0, 0.0, 0.0);
 quadObj := gluNewQuadric; //������� ������ quadric-������, ������������ �������
 ry := 0.0;
 tx := 0.0;
end;

procedure TLocation3DForm.FormDestroy(Sender: TObject);
begin
 gluDeleteQuadric (quadObj); //�������� �������, ����������� �� ������������ ����. ���������������
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);  // �������� ��������� ���������������
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TLocation3DForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
 If Key = VK_LEFT then begin
    ry := ry + 2.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_RIGHT then begin
    ry := ry - 2.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_UP then begin
    tx := tx - 0.1;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_DOWN then begin
    tx := tx + 0.1;
    InvalidateRect(Handle, nil, False);
 end;

 If Key = 49 then begin
    Inc (mode);
    If mode > High (mode) then mode := Low (mode);
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 50 then begin
    Inc (gluobj);
    If gluobj > High (gluobj) then gluobj := Low (gluobj);
    InvalidateRect(Handle, nil, False);
 end;

 If Key = 51 then begin
    If orientation = INSIDE
       then orientation := OUTSIDE
       else orientation := INSIDE;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = 52 then begin
    Inc (normals);
    If normals > High (normals) then normals := Low (normals);
    InvalidateRect(Handle, nil, False);
 end;
end;

procedure TLocation3DForm.FormPaint(Sender: TObject);
begin
   glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);      // ������� ������ �����

 glPushMatrix;

 glRotatef (ry, 0.0, 1.0, 0.0);
 glTranslatef (tx, 0.0, 0.0);

 case mode of    //����� ���������������
   POINT : gluQuadricDrawStyle (quadObj, GLU_POINT); // ����� ��������������� ������� "quadObj",
   LINE  : gluQuadricDrawStyle (quadObj, GLU_LINE);    // ��� ������ glPolygonMode
   FILL  : gluQuadricDrawStyle (quadObj, GLU_FILL);
   SILHOUETTE : gluQuadricDrawStyle (quadObj, GLU_SILHOUETTE {������ ��������� ������} );
   LINE_STRIP  : gluQuadricDrawStyle (quadObj, GLU_LINE);
 end;

 case orientation of
   INSIDE : gluQuadricOrientation (quadObj, GLU_INSIDE); // ������
   OUTSIDE : gluQuadricOrientation (quadObj, GLU_OUTSIDE); // ������
 end;

 case normals of
   NONE : gluQuadricNormals (quadObj, GLU_NONE); // �� �������
   FLAT : gluQuadricNormals (quadObj, GLU_FLAT);   // ��� ��������
   SMOOTH : gluQuadricNormals (quadObj, GLU_SMOOTH);  // ��� ������ �������
 end;

 case gluobj of
   SPHERE : gluSphere (quadObj, 1.5, 10, 10);                       // �����
   CONE : gluCylinder(quadObj, 0.0, 1.0, 1.5, 10, 10);           // �����
   CYLINDER : gluCylinder (quadObj, 1.0, 1.0, 1.5, 10, 10);   // �������
   DISK : gluDisk (quadObj, 0.0, 1.5, 10, 5);//������ ���� 2,3-��������� ���������� � ������� �������
   COMPLEX_OBJ:
     begin
       glBegin(GL_LINE_LOOP);//������ ��������� �����
                glVertex3f(2.5,-0.95,-0.5); //������ ������� ������� � ����� ���������� �������
                glVertex3f(2.5,-0.95,0.5);//����� ������� �������, � ������ ������� �������
                glVertex3f(2.5,1.3,0.5);//����� ������� ������� � ������ �������� �������
                glVertex3f(2.5,1.3,-0.5);//����� �������� ������� � ������ ���������� �������
       glEnd;
       glBegin(GL_LINE_LOOP);//������ ��������� �����
                glVertex3f(-0.5,-0.95,-0.5); //������ ������� ������� � ����� ���������� �������
                glVertex3f(-0.5,-0.95,0.5);//����� ������� �������, � ������ ������� �������
                glVertex3f(-0.5,1.3,0.5);//����� ������� ������� � ������ �������� �������
                glVertex3f(-0.5,1.3,-0.5);//����� �������� ������� � ������ ���������� �������
       glEnd;
       glBegin(GL_LINE_LOOP);//������ ��������� �����
                glVertex3f(2.5,1.3,0.5); //������ ������� ������� � ����� ���������� �������
                glVertex3f(2.5,1.3,-0.5);//����� ������� �������, � ������ ������� �������
                glVertex3f(-0.5,1.3,-0.5);//����� ������� ������� � ������ �������� �������
                glVertex3f(-0.5,1.3,0.5);//����� �������� ������� � ������ ���������� �������
       glEnd;
       glBegin(GL_LINE_LOOP);//������ ��������� �����
                glVertex3f(2.5,-0.95,-0.5); //������ ������� ������� � ����� ���������� �������
                glVertex3f(-0.5,-0.95,-0.5);//����� ������� �������, � ������ ������� �������
       glEnd;
     end;
 end;

 LoadCurrentLocation;

 glPopMatrix;
 SwapBuffers(DC);
end;

procedure TLocation3DForm.LoadCurrentLocation;
begin
  try
  Caption:='��������� �������������� � 3D - ['+
    DBConnectDM.GetLocationNameByID(
    DBConnectDM.OrderItemByLocationIBQuery.ParamByName('loc_id').
    AsInteger)+']';
  if DBConnectDM.OrderItemByLocationIBQuery.RecordCount>0 then
    begin
      DBConnectDM.OrderItemByLocationIBQuery.First;
      //DBConnectDM.OrderItemByLocationIBQuery.
      while True do
        begin
        (DBConnectDM.OrderItemByLocationIBQuery.
        FieldByName('IMAGE_FILE') as TBlobField).SaveToFile(TempImgFilePath);
        MainForm.OrderItemImage.Picture.LoadFromFile(TempImgFilePath);
        if (MainForm.OrderItemImage.Picture.Bitmap.Width>=10) and
           (MainForm.OrderItemImage.Picture.Bitmap.Height>=10) then
          begin
          if DBConnectDM.OrderItemByLocationIBQuery.
            FindField('REKLAM_PLACE_NAME').AsString='������ ����� ������' then
          begin
            LoadArrayFromImage(MainForm.OrderItemImage.Picture.Bitmap.Canvas,
              caX,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_X_COORD').AsFloat,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_Y_COORD').AsFloat,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_Z_COORD').AsFloat,
              ipLeft,
              MainForm.OrderItemImage.Picture.Bitmap.Width,
              MainForm.OrderItemImage.Picture.Bitmap.Height);
          end
          else if DBConnectDM.OrderItemByLocationIBQuery.
            FindField('REKLAM_PLACE_NAME').AsString='������ ����� �������' then
          begin
            LoadArrayFromImage(MainForm.OrderItemImage.Picture.Bitmap.Canvas,
              caX,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_X_COORD').AsFloat,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_Y_COORD').AsFloat,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_Z_COORD').AsFloat,
              ipRight,
              MainForm.OrderItemImage.Picture.Bitmap.Width,
              MainForm.OrderItemImage.Picture.Bitmap.Height);
          end
          else if DBConnectDM.OrderItemByLocationIBQuery.
            FindField('REKLAM_PLACE_NAME').AsString='������ ������ ������' then
          begin
            LoadArrayFromImage(MainForm.OrderItemImage.Picture.Bitmap.Canvas,
              caX,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_X_COORD').AsFloat,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_Y_COORD').AsFloat,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_Z_COORD').AsFloat,
              ipRight,
              MainForm.OrderItemImage.Picture.Bitmap.Width,
              MainForm.OrderItemImage.Picture.Bitmap.Height);
          end
          else if DBConnectDM.OrderItemByLocationIBQuery.
            FindField('REKLAM_PLACE_NAME').AsString='������ ������ �������' then
          begin
            LoadArrayFromImage(MainForm.OrderItemImage.Picture.Bitmap.Canvas,
              caX,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_X_COORD').AsFloat,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_Y_COORD').AsFloat,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_Z_COORD').AsFloat,
              ipLeft,
              MainForm.OrderItemImage.Picture.Bitmap.Width,
              MainForm.OrderItemImage.Picture.Bitmap.Height);
          end
          else if (DBConnectDM.OrderItemByLocationIBQuery.
            FindField('REKLAM_PLACE_NAME').AsString='������ �������� ������ ����� ����') or
            (DBConnectDM.OrderItemByLocationIBQuery.
            FindField('REKLAM_PLACE_NAME').AsString='������ �������� ������ ������ ����') or
            (DBConnectDM.OrderItemByLocationIBQuery.
            FindField('REKLAM_PLACE_NAME').AsString='������ �������� ������ ����� �����') or
            (DBConnectDM.OrderItemByLocationIBQuery.
            FindField('REKLAM_PLACE_NAME').AsString='������ �������� ������ ������ �����') then
          begin
            LoadArrayFromImage(MainForm.OrderItemImage.Picture.Bitmap.Canvas,
              caZ,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_X_COORD').AsFloat,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_Y_COORD').AsFloat,
              DBConnectDM.OrderItemByLocationIBQuery.FieldByName('START_Z_COORD').AsFloat,
              ipRight,
              MainForm.OrderItemImage.Picture.Bitmap.Width,
              MainForm.OrderItemImage.Picture.Bitmap.Height);
          end
          else
          begin

          end;
          end
          else
            begin
              //ShowMessage();
            end;
          if DBConnectDM.OrderItemByLocationIBQuery.RecNo>=
             DBConnectDM.OrderItemByLocationIBQuery.RecordCount then
               Break
          else
             DBConnectDM.OrderItemByLocationIBQuery.Next;
        end;
    end;
  except on E: Exception do
    ShowMessage('��� �������� ���������� �� ��������� ��������������!');
  end;
end;

procedure TLocation3DForm.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode (GL_PROJECTION); // ������� ������������� ������� �������
 glLoadIdentity;
 glFrustum (-1, 1, -1, 1, 2, 9);
 glMatrixMode (GL_MODELVIEW);
 glLoadIdentity;

 // ���� �������� ����� ��� �������� �����������
 glTranslatef(0.0, 0.0, -5.0);   // ������� ������� - ��� Z
 glRotatef(30.0, 1.0, 0.0, 0.0); // ������� ������� - ��� X
 glRotatef(70.0, 0.0, 1.0, 0.0); // ������� ������� - ��� Y

 InvalidateRect(Handle, nil, False);
end;

procedure TLocation3DForm.SetDCPixelFormat(DC: Cardinal);
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;


end.
