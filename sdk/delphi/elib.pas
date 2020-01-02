unit elib;

////////////////////////////////////////////////////////////////////////////////
//
//   ������֧�ֿ⿪����(EDK) for Delphi, 1.0
// ---------------------------------------------
// (2008/5, ����������������������������޹�˾)
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  e, Classes, Types, Messages, Controls, Graphics, Forms, ExtCtrls, Windows, CommCtrl;

type

  TVclFormContainer = class(TForm)
  end;

  TVclPanelContainer = class(TPanel)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  ELib_TPropReader = class
  public
    constructor Create(DataAddress: Pointer; DataLength: Cardinal);
    function Read(Buffer: Pointer; Count: Cardinal): Boolean;
    function ReadInt(): Integer;
    function ReadBool(): EBool;
    function ReadDouble(): Double;
    function ReadString(): String;
    function ReadDWord(): DWORD;
    function ReadByte(): Byte;
    function ReadCardinal(): Cardinal;
    function ReadFont(): TLogFont; overload;
    function ReadFont(out fontVar: TLogFont): Boolean; overload;
    function ReadStrings(stringsVar: TStrings): Boolean;
    function ReadMemoryStream(memoryVar: TMemoryStream): Boolean;
  private
    FDataAddress: Pointer;
    FDataLength: Cardinal;
    FPosition: Cardinal;
  end;

  ELib_TPropWriter = class
  public
    constructor Create();
    function Write(DataAddress: Pointer; Count: Cardinal): Boolean;
    function WriteInt(intValue: Integer): Boolean;
    function WriteBool(boolValue: EBool): Boolean;
    function WriteDouble(doubleValue: Double): Boolean;
    function WriteString(stringValue: String): Boolean;
    function WriteFont(fontValue: LOGFONT): Boolean;
    function WriteDWord(dwordValue: DWORD): Boolean;
    function WriteByte(byteValue: Byte): Boolean;
    function WriteCardinal(cardinalValue: Cardinal): Boolean;
    function WriteStrings(stringsValue: TStrings): Boolean;
    function WriteMemoryStream(memoryValue: TMemoryStream): Boolean;
    function AllocHGlobal(): HGLOBAL;
    function GetDataAddress(): Pointer;
    function GetDataLength(): Cardinal;
    destructor Destroy; override;
  private
    FMemoryStream: TMemoryStream;
  end;

  // һ������ Attach ��һ���Ѿ����ڵ��ڴ�� MemoryStream
  // �� MemoryStream ���ɸı��С
  TAttachedMemoryStream = class(TCustomMemoryStream)
  public
    constructor Create(Ptr: Pointer; Size: LongInt);
    function Write(const Buffer; Count: LongInt): Longint; override;
  end;

  TContainer = TWinControl;
  TContainerClass = class of TContainer;

{
  ����һ���ؼ���ע�ᵽ������ϵͳ.

  * �Ƿ�ʹ��Containerȡ���� ContainerClass ����

  * ���� NeedClick �ļ�˵��:
  ����������,һ��VCL�ؼ�����Ƿ���Panel��ʱ,���������Ϣ(����WM_LBUTTONDOWN)����ת����Panel,���ܱ������Ե�"�ÿؼ�_������������"���յ�<ԭ���Ǽ���Panel֮��,ע��������Ե�ʵ���������Panel,������ʵ�ʵĿؼ�,����������ֻ�ܽ��յ�Panel����Ϣ������ʵ�ʿؼ�����Ϣ>

  ����,�������ؼ���WM_LBUTTONDOWNת�����˸�����(Panel)�ֻᵼ������Click�¼����ƻ�(�޷��յ�).����,��������Click,�ͱ��벻ת��WM_LBUTTONDOWN.

  ����.Ҫô����Click,Ҫô����WM_LBUTTONDOWN.
}
function ELib_CreateControl(out UnitHandle: HUNIT; ControlClass: TWinControlClass;
  dwStyle, hParentWnd: Cardinal; x,y,cx,cy: Integer; ContainerClass: TContainerClass = nil; AUnitID: Cardinal = 0; AFormID: Cardinal = 0): TWinControl;
//��TWinControl����ע�ᵽ��ϵͳ, ������HUNIT. ʧ�ܷ���0.
// ��� ContainerClass ��Ϊ nil ����Զ�����һ�������͵� Form ��Ϊ�ÿؼ��ĸ��ؼ�
// ͬʱ�ÿؼ�֮ǰ�ĸ����ڳ�Ϊ Form �ĸ�����
function ELib_RegControl(Control: TWinControl; AContainer: TContainer = nil; AFormID: Cardinal = 0; AUnitID: Cardinal = 0): HUNIT;

//����HUNIT��ȡ��Ӧ��TWinControl����. ʧ�ܷ���nil.
function ELib_GetControl(UnitHandle: HUNIT): TWinControl; overload;
//�����׶����ȡ��Ӧ��TWinControl����. ʧ�ܷ���nil.
function ELib_GetControl(SelfMData: PMDATA_INF): TWinControl; overload;

//Ϊ�����Էǿ��ӿؼ������������: ���߱߿�, ��С�ߴ�Ϊ26*26, ������ʾͼƬ
procedure ELib_SettingForFunctionalControl(control: TPanel; imageResourceID: Integer;
                                           fixMinSize: Boolean = true; fixMaxSize: Boolean = true);

//��һ���Ѿ�ע�����TWinControl������ȡ����HUNIT. ʧ�ܷ���0.
function ELib_GetHUNIT(Control: TWinControl): HUNIT; overload;
//��ȡ�׶����HUNIT
function ELib_GetHUNIT(SelfMData: PMDATA_INF): HUNIT; overload;

// ��һ�� TStream ����������һ�� HGLOBAL
// �ú�������;�ο� ITF_GET_ALL_PROPERTY_DATA
function ELib_AllocHGlobal(Stream: TStream): HGLOBAL;

// Boolean <--> EBool
function ELib_BooleanToEBool(Value: Boolean): EBool;
function ELib_EBoolToBoolean(value: EBool): Boolean;

// ��ͼƬ���ݴ�����һ�� TBitmap
// ʧ�ܷ���nil; ��ע�ⷵ��ֵ���ͷ�����
function ELib_CreateBitmap(Data: Pointer; Size: Cardinal): Graphics.TBitmap;
// �������Ը�ʽ��ͼƬ�����ݴ���ΪHImageList
function ELib_CreateImageList(Data: Pointer; AOwner: TComponent; out TransparentColor: TColor): TImageList; overload;
function ELib_CreateImageList(Data: Pointer; AOwner: TComponent): TImageList; overload;

// ��һ�� TBitmap ƽ��,������ָ���Ĵ�С
// ��� DisplaySize �Ŀ��,�߶Ƚ�С�ڻ����λͼ����,�򱣳�ԭλͼ����,������ False
function ELib_TileBitmap(var Bitmap: Graphics.TBitmap; var DisplaySize: TSize): Boolean;

// ��һ�� TBitmap ƽ�̲������µ� TBitmap ����
// ��� DisplaySize �Ŀ��,�߶Ƚ�С�ڻ����λͼ����,�򷵻�nil
function ELib_CreateTitledBitmap(const Bitmap: Graphics.TBitmap; var DisplaySize: TSize): Graphics.TBitmap;

// ������Ĭ�ϱ���ɫ
function ELib_ToEBackColor(color: TColor): Cardinal;
function ELib_FromEBackColor(color: Cardinal): TColor;

// '����'(Align) ����
procedure ELib_DefineAlignProperty(datatypeIndex: Integer);
function ELib_GetAlignFromIndex(index: Integer): TAlign;
function ELib_GetAlignIndex(align: TAlign): Integer;
procedure ELib_SetAlignByIndex(control: TWinControl; ePropIndex: Integer);

//'�߿�'����
procedure ELib_DefineBorderProperty(datatypeIndex: Integer);
procedure ELib_SetBorderByIndex(panel: TPanel; ePropIndex: Integer);
function  ELib_GetBorderIndex(panel: TPanel): Integer;

//'����'����
procedure ELib_SetFont(font: TFont; const LogFont: TLogFont);
procedure ELib_SetDefaultFont(font: TFont);
function ELib_GetLogFont(const font: TFont): TLogFont;
procedure ELib_SetFont_Songti9(font: TFont);


type TCallWndProc = procedure(var Msg: TMessage) of object;
procedure ELib_WinControlWndProc(Control: TWinControl; var msg: TMessage; CallBaseWndProc: TCallWndProc; RealignOnMoveSize: Boolean = false);

// ����TStrings�����ݴ���һ������������
function ELib_TStringsToEArray(const Strings: TStrings): Pointer;

implementation

{$R VclFromContainer.dfm}

uses
  Math, SysUtils;

type
  ContainerPropData = record
    CWndPtr: HUNIT;
    Child: TWinControl;
    OldProc: Pointer;
    Painting: Boolean;
  end;

  ControlPropData = record
    Recreating: Boolean;
    OldProc: Pointer;
    MouseTracking: Boolean;
    MouseEntered: Boolean;
    case HasContainer: Boolean of
      True: (Container: TContainer; FormID, UnitID: Cardinal;);
      False: (CWndPtr: HUNIT);
  end;

  WndPropData = record
    Control: TWinControl;
    case IsContainer: Boolean of
      True: (ContainerData: ContainerPropData);
      False: (ControlData: ControlPropData);
  end;
  PWndPropData = ^WndPropData;

const
  ELIB_WND_PROP_NAME: PChar = 'dywt.com.cn/elib/vcl/wnd_prop_name';

function _GetPropData(arg: HWND): PWndPropData; overload;
begin
  Result := PWndPropData(GetProp(arg,ELIB_WND_PROP_NAME));
end;

function _GetPropData(arg: TWinControl): PWndPropData; overload;
begin
  Result := _GetPropData(arg.Handle);
end;

function _RemovePropData(arg: TWinControl): Boolean;
var
  pData: PWndPropData;
begin
  Result := False;
  pData := _GetPropData(arg);
  if not Assigned(pData) then exit;
  Result := RemoveProp(arg.Handle, ELIB_WND_PROP_NAME) <> 0;
  Dispose(pData);
end;

function _SetPropData(Control: TWinControl; Data: PWndPropData): Boolean;
begin
  _RemovePropData(Control);
  Result := SetProp(Control.Handle, ELIB_WND_PROP_NAME, Cardinal(Data));
end;


function ELib_ContainerNewProc(Handle: HWND; Msg: Cardinal; wParam, lParam: Integer): Cardinal; stdcall;
var
  Data: PWndPropData;
  AContainer: TWinControl;
begin
  Result := 0;
  AContainer := FindControl(Handle);
  if not Assigned(AContainer) then
    exit;
  Data := _GetPropData(FindControl(Handle));
  Assert(Data.IsContainer);
  with Data.ContainerData do
  begin
    case Msg of
      WM_ENABLE:
      begin
        Child.Enabled := wParam <> 0;
        AContainer.Enabled := wParam <> 0;
      end;
      WM_SETFOCUS:
      begin
        if not Child.Focused and Child.Visible and Child.Enabled then
          SetFocus(Child.Handle);
      end;
      WM_SHOWWINDOW:
      begin
        AContainer.Visible := (wParam <> 0);
      end;
      {WM_PAINT, WM_NCPAINT, WM_ERASEBKGND:
      begin
        if not Painting then
        begin
          Painting := true;
          Child.Perform(Msg, wParam, lParam);
          Child.Invalidate;
          Painting := false;
        end;
      end;}
    end;
    Result := CallWindowProc(OldProc, Handle, Msg, wParam, lParam);
  end;
end;

function ELib_ChildNewProc(Handle: HWND; Msg: Cardinal; wParam, lParam: Integer): Cardinal; stdcall;
var
  Data: PWndPropData;
  AControl: TWinControl;
  EventData: EVENT_NOTIFY2;
function GetEShiftState: Integer;
var
  ShiftState: TShiftState;
begin
  Result:= 0;
  ShiftState := KeyboardStateToShiftState;
  if ssCtrl in ShiftState then
    Result:= Result or 1; // ���ƣ�Ctrl��״̬ ���ͣ���ֵ��    ֵ��1��
  if ssShift in ShiftState then
    Result:= Result or 2; //  ���ƣ�Shift��״̬ ���ͣ���ֵ��    ֵ��2��
  if ssAlt in ShiftState then
    Result:= Result or 4; //  ���ƣ�Alt��״̬ ���ͣ���ֵ��    ֵ��4��
end;
procedure SendMouseEventData(Index:Integer; FormID, UnitID: Cardinal);
begin
  Init_EVENT_NOTIFY2(EventData, FormID, UnitID, Index);
  EventData.m_nArgCount := 3;
  EventData.m_nArgValue[0].m_inf.m_Value.m_int := LOWORD(lParam);
  EventData.m_nArgValue[1].m_inf.m_Value.m_int := HIWORD(lParam);
  EventData.m_nArgValue[2].m_inf.m_Value.m_int := GetEShiftState;
  NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
end;
begin
  Result := 0;
  Data := _GetPropData(Handle);
  if not Assigned(Data) then exit;
  AControl := Data.Control;
  if not Assigned(AControl) then exit;

  Assert(Data.IsContainer = false);
  with Data.ControlData do
  begin
    Result := CallWindowProc(OldProc, Handle, Msg, wParam, lParam);

    if Msg = WM_NCDESTROY then Exit;
    if HasContainer then
    begin
      case Msg of
        WM_SHOWWINDOW:
        begin
          Container.Visible := wParam <> 0;
        end;
        WM_LBUTTONDOWN: begin
          SendMouseEventData(-1, FormID, UnitID);
        end;
        WM_LBUTTONUP: begin
          SendMouseEventData(-2, FormID, UnitID);
        end;
        WM_LBUTTONDBLCLK: begin
          SendMouseEventData(-3, FormID, UnitID);
        end;
        WM_RBUTTONDOWN: begin
          SendMouseEventData(-4, FormID, UnitID);
        end;
        WM_RBUTTONUP: begin
          SendMouseEventData(-5, FormID, UnitID);
        end;
        WM_MOUSEMOVE: begin
          SendMouseEventData(-6, FormID, UnitID);
        end;
        WM_SETFOCUS: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -7);
          EventData.m_nArgCount := 0;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
        WM_KILLFOCUS: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -8);
          EventData.m_nArgCount := 0;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
        WM_KEYDOWN: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -9);
          EventData.m_nArgCount := 2;
          EventData.m_nArgValue[0].m_inf.m_Value.m_int := wParam;
          EventData.m_nArgValue[1].m_inf.m_Value.m_int := GetEShiftState;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
        WM_KEYUP: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -10);
          EventData.m_nArgCount := 2;
          EventData.m_nArgValue[0].m_inf.m_Value.m_int := wParam;
          EventData.m_nArgValue[1].m_inf.m_Value.m_int := GetEShiftState;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
        WM_CHAR: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -11);
          EventData.m_nArgCount := 1;
          EventData.m_nArgValue[0].m_inf.m_Value.m_int := wParam;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
        WM_MOUSEWHEEL: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -12);
          EventData.m_nArgCount := 2;
          EventData.m_nArgValue[0].m_inf.m_Value.m_int := wParam;
          EventData.m_nArgValue[1].m_inf.m_Value.m_int := GetEShiftState;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
      end;
    end;
  end;
end;

function ELib_GetControl(UnitHandle: HUNIT): TWinControl; overload;
var
  Handle: HWND;
  Data: PWndPropData;
begin
  Result := nil;
  if UnitHandle = 0 then exit;
  Handle := HWND(NotifySys(NAS_GET_HWND_OF_CWND_OBJECT, Cardinal(UnitHandle), 0));
  Data := PWndPropData(GetProp(Handle, ELIB_WND_PROP_NAME));
  if not Assigned(Data) then exit;
  if Data.IsContainer then
    Result := Data.ContainerData.Child
  else
    Result := FindControl(Handle);
end;

function ELib_GetControl(selfMData: PMDATA_INF): TWinControl; overload;
begin
  result := ELib_GetControl(ELib_GetHUNIT(selfMData));
end;

function ELib_GetHUNIT(control: TWinControl): HUNIT; overload;
var
  Data: PWndPropData;
begin
  Result := 0;
  Data := _GetPropData(Control);
  if not Assigned(Data) then exit;
  if Data.IsContainer then
    Result := Data.ContainerData.CWndPtr
  else
  with Data.ControlData do
    if HasContainer then
      Result := _GetPropData(Container).ContainerData.CWndPtr
    else
      Result := Data.ControlData.CWndPtr;
end;

function ELib_GetHUNIT(selfMData: PMDATA_INF): HUNIT; overload;
begin
  Result := HUNIT(NotifySys (NRS_GET_AND_CHECK_UNIT_PTR,
            selfMData.m_Value.m_unit.m_dwFormID, selfMData.m_Value.m_unit.m_dwUnitID));
end;

type
  TChildStuff = record
    Instance: TWinControl;
    Handle: HWND;
    ParentCtrl:TWinControl;
    ParentHandle: HWND;
    PropData: PWndPropData;
  end;
  TChildrenStuf = array of TChildStuff;

// ȡ��AControl��������Ҫ��AControl�ؽ�ʱ���⴦����ӿؼ�(�ݹ�)
// ����ֵ�������ӿؼ��Լ�������д���ʱ�������һЩ����
function _GetChildren(AControl: TWinControl): TChildrenStuf;
var
  ChildHandle: HWND;
  Children: TChildrenStuf;
  I, H: Integer;
begin
  ChildHandle := 0;
  // ѭ���������е�ֱ���Ӵ���
  repeat
    ChildHandle := FindWindowEx(AControl.Handle, ChildHandle, nil, nil);
    if (ChildHandle = 0)  or (NotifySys(NAS_IS_EWIN, ChildHandle) = 0) then break;
    // �����Ӵ��ڼ�¼����
    SetLength(Result, Length(Result) + 1);
    with Result[Length(Result) - 1] do
    begin
      Handle := ChildHandle;
      Instance := FindControl(Handle);
      // �Ƿ��ж�Ӧ��Delphi TWinControlʵ��??
      if Assigned(Instance) then
      begin
        // ��ӦTWinControlʵ��, ˵������AControl��VCL���и��ӹ�ϵ
        // ����AControl�ؽ�ʱ���Զ��ؽ�
        PropData := _GetPropData(Handle);
        if PropData <> nil then
        begin
          if not PropData.IsContainer then
            PropData.ControlData.Recreating := True; //��ֹ�ӿؼ���������
          // �ݹ鴦�����Ӵ���
          Children := _GetChildren(Instance);
          if Length(Children) > 0 then
          begin
            H := High(Result);
            SetLength(Result, Length(Result) + Length(Children));
            for I := Low(Children) to High(Children)do
              Result[H + I + 1] := Children[I];
          end;
        end;
      end;
      ParentHandle := GetParent(Handle);
      ParentCtrl := FindControl(ParentHandle);
    end;
  until False;

  // ����������ı���ѭ���н���SetParent,����ᵼ��"������"�ж�,ѭ����ֹ
  for I := Low(Result) to High(Result) do
  begin
    with Result[I] do
      if Instance = nil then
        SetParent(Handle, 0);
  end;
end;

procedure _SetChildren(AControl: TWinControl; const Children: TChildrenStuf);
var
  I: Integer;
begin
  for I := Low(Children) to High(Children) do
    with Children[I] do
    begin
      if Instance = nil then
      begin
        if Assigned(ParentCtrl) then
          SetParent(Handle, ParentCtrl.Handle)
        else
          SetParent(Handle, ParentHandle)
      end
      else
      begin
        if Assigned(PropData) then
        begin
          Assert(not PropData.IsContainer);
          with PropData.ControlData do
          begin
            OldProc := Pointer(SetWindowLong(Handle, GWL_WNDPROC, Integer(@ELib_ChildNewProc)));
            Recreating := False;
            _SetPropData(Instance, PropData);
            // ���� Attach CWnd ����
            NotifySys(NAS_DETACH_CWND_OBJECT, Cardinal(CWndPtr), 0);
            NotifySys(NAS_ATTACH_CWND_OBJECT, Instance.Handle, Cardinal(CWndPtr));
          end;
        end;
      end;
    end;
end;


{type
  TChildStuff = record
    Instance: TWinControl;
    Handle: HWND;
    PropData: PWndPropData;
  end;
  TChildrenStuf = array of TChildStuff;

// ȡ��AControl��������Ҫ��AControl�ؽ�ʱ���⴦����ӿؼ�(�ݹ�)
// ����ֵ�������ӿؼ��Լ�������д���ʱ�������һЩ����
function _GetChildren(AControl: TWinControl): TChildrenStuf;
var
  ChildHandle: HWND;
  I: Integer;
begin
  ChildHandle := 0;
  // ѭ���������е�ֱ���Ӵ���
  repeat
    ChildHandle := FindWindowEx(AControl.Handle, ChildHandle, nil, nil);
    if ChildHandle = 0 then break;
    // �����Ӵ��ڼ�¼����
    SetLength(Result, Length(Result) + 1);
    with Result[Length(Result) - 1] do
    begin
      Handle := ChildHandle;
      Instance := FindControl(Handle);
      // �Ƿ��ж�Ӧ��Delphi TWinControlʵ��??
      if Assigned(Instance) then
      begin
        PropData := _GetPropData(Instance);
        Assert(not PropData.IsContainer);
        PropData.ControlData.Recreating := False; //�����Ӵ��������������
        Instance.Parent := nil;
      end
    end;
  until False;

  // ����������ı���ѭ���н���,����ᵼ��"������"�ж�,ѭ����ֹ
  for I := Low(Result) to High(Result) do
  begin
    with Result[I] do
      if Instance = nil then
        SetParent(Handle, 0);
  end;
end;

procedure _SetChildren(AControl: TWinControl; const Children: TChildrenStuf);
var
  I: Integer;
begin
  for I := Low(Children) to High(Children) do
    with Children[I] do
    begin
      if Assigned(Instance) then
      begin
        Assert(not PropData.IsContainer);
        with PropData.ControlData do
        begin
          OldProc := Pointer(SetWindowLong(Handle, GWL_WNDPROC, Integer(@ELib_ChildNewProc)));
          Recreating := False;
          _SetPropData(Instance, PropData);
          // ���� Attach CWnd ����
          NotifySys(NAS_DETACH_CWND_OBJECT, Cardinal(CWndPtr), 0);
          NotifySys(NAS_ATTACH_CWND_OBJECT, Instance.Handle, Cardinal(CWndPtr));
        end
      end
      else
      begin
        SetParent(Handle, AControl.Handle);
      end;
    end;
end;}

type
  TTrackMouseEventTimer = class(TTimer)
  public
    FControl: TControl;
    procedure OnTimerHandler(Sender: TObject);
  end;

procedure TTrackMouseEventTimer.OnTimerHandler(Sender: TObject);
begin
  if not PtInRect(Bounds(FControl.LRDockWidth, FControl.Top, FControl.Width, FControl.Height), Mouse.CursorPos) then
  begin
    FControl.Perform(CM_MOUSELEAVE, 0, 0);
    Self.Free;
  end;
end;

procedure MyTrackMouseEvent(AControl: TControl);
var
  Timer: TTrackMouseEventTimer;
begin
  Timer := TTrackMouseEventTimer.Create(AControl);
  Timer.FControl := AControl;
  Timer.OnTimer := Timer.OnTimerHandler;
  Timer.OnTimerHandler(Timer);
  Timer.Interval := 100;
end;

procedure ELib_WinControlWndProc(control: TWinControl; var msg: TMessage; CallBaseWndProc: TCallWndProc; RealignOnMoveSize: Boolean);
var
  pData, pContainerData: PWndPropData;
  ParentWnd: HWND;
  ParentWndCtrl: TWinControl;
  Children: TChildrenStuf;
  Tme: Windows.TTrackMouseEvent;
  TrackOK: LongBool;
  Visible: boolean;
begin
  case msg.Msg of
    WM_MOUSEMOVE:
    begin
      CallBaseWndProc(msg);
      pData := _GetPropData(control);
      Assert(pData.IsContainer = False);
      with pData.ControlData do
      begin
        if not MouseEntered then
        begin
          MouseEntered := True;
          control.Perform(CM_MOUSEENTER, 0, 0);
        end;
        if not MouseTracking then
        begin
          MouseTracking := True;
          Tme.cbSize := sizeof(Tme);
          Tme.hwndTrack := control.Handle;
          Tme.dwFlags := TME_LEAVE;
          TrackOK := Windows.TrackMouseEvent(Tme);
          Assert(TrackOK);
        end;
      end;
    end;
    WM_MOUSELEAVE:
    begin
      CallBaseWndProc(msg);
      control.Perform(CM_MOUSELEAVE, 0, 0);
      pData := _GetPropData(control);
      Assert(pData.IsContainer = False);
      with pData.ControlData do
      begin
        MouseEntered := False;
        MouseTracking := False;
      end;
    end;
    WM_MOVE, WM_SIZE:
    begin
      CallBaseWndProc(msg);
      if RealignOnMoveSize then
      begin
        {TempAlign := Control.Align;
        Control.Align := alNone;
        Control.Align := TempAlign;}
      end;
    end;
    WU_INIT: begin
      CallBaseWndProc(msg);
      ParentWnd := GetParent(control.Handle);
      ParentWndCtrl := FindControl(ParentWnd);
      if not (control is TForm) then
      begin
        if ParentWndCtrl <> nil then
          control.Parent := ParentWndCtrl
        else
          control.ParentWindow := ParentWnd;
      end
    end;
    CM_RECREATEWND: begin
      pData := _GetPropData(control);
      Assert(pData.IsContainer = False);
      with pData.ControlData do
      begin
        if HasContainer then
          Visible := IsWindowVisible(Container.Handle)
        else
          Visible := IsWindowVisible(control.Handle);

        Recreating := True;
        Children := _GetChildren(control);
        CallBaseWndProc(msg);
        _SetChildren(control, Children);
        // �Ѿ����´������
        Recreating := False;
        // Ϊ�´����Ĵ������� PropData
        _SetPropData(control, pData);
        // ����и�����
        if HasContainer then
        begin
          pContainerData := _GetPropData(Container);
          // ���ø����ڵ� Child
          pContainerData.ContainerData.Child := control; // ??
          OldProc := Pointer(SetWindowLong(Control.Handle, GWL_WNDPROC, Integer(@ELib_ChildNewProc)));
        end
        else
        begin
          // ���� Attach CWnd ����
          NotifySys(NAS_DETACH_CWND_OBJECT, Cardinal(CWndPtr), 0);
          NotifySys(NAS_ATTACH_CWND_OBJECT, control.Handle, Cardinal(CWndPtr));
        end;

        if HasContainer then
        begin
          ShowWindow(Container.Handle, IfThen(Visible, SW_SHOW, SW_HIDE));
          Container.Visible := Visible
        end
        else
        begin
          ShowWindow(Control.Handle, IfThen(Visible, SW_SHOW, SW_HIDE));
          Control.Visible := Visible;
        end
      end;
    end;
    WM_NCDESTROY: begin
      pData := _GetPropData(control);
      { �ͷ�����ʱ�ݹ���� }
      if not Assigned(pData)then
      begin
        CallBaseWndProc(msg);
        exit;
      end;
      Assert(Assigned(pData), 'û�е��� ELib_RegControl ??');
      Assert(pData.IsContainer = False);
      with pData.ControlData do
      begin
        { ���´���ʱ������ }
        if Recreating then
        begin
          CallBaseWndProc(msg);
          exit;
        end;
        { �������� }
        CallBaseWndProc(msg);
        if HasContainer then
        begin
          pData := _GetPropData(Container);
          // ɾ�� CWnd ����
          NotifySys(NAS_DETACH_CWND_OBJECT, Cardinal(pData.ContainerData.CWndPtr), 0);
          NotifySys(NAS_DELETE_CWND_OBJECT, Cardinal(pData.ContainerData.CWndPtr), 0);
          // �Ƴ� PropData
          _RemovePropData(Container);
          _RemovePropData(control);
          // �ͷ�����
          control.Free();
        end
        else
        begin
          // ɾ�� CWnd ����
          NotifySys(NAS_DETACH_CWND_OBJECT, Cardinal(CWndPtr), 0);
          NotifySys(NAS_DELETE_CWND_OBJECT, Cardinal(CWndPtr), 0);
          // �Ƴ� PropData
          _RemovePropData(control);
          // �ͷ�����
          control.Free();
        end;
      end;
    end;
    else begin
      try
        CallBaseWndProc(msg);
      except
        on EAbstractError do
          assert(false, '"���¼������ٴ��ڻ�ؼ�"������¿��ܵ��·Ƿ����ʻ�EAbstractError����');
      end;
    end;
  end;

end;

function ELib_RegControl(Control: TWinControl; AContainer: TContainer = nil; AFormID: Cardinal = 0; AUnitID: Cardinal = 0): HUNIT;
var
  Data: PWndPropData;
begin
  New(Data);
  Data.Control := control;
  if not Assigned(AContainer) then
  begin
    Data.IsContainer := False;
    with Data.ControlData do
    begin
      Recreating := False;
      MouseTracking := False;
      MouseEntered := False;
      HasContainer := False;
      CWndPtr := HUNIT(NotifySys(NAS_CREATE_CWND_OBJECT_FROM_HWND, Control.Handle, 0));
      OldProc := Pointer(SetWindowLong(Control.Handle, GWL_WNDPROC, Integer(@ELib_ChildNewProc)));
      _SetPropData(control, Data);
      Result := CWndPtr;
    end;
  end
  else
  begin
    Assert(AFormID <> 0);
    Assert(AUnitID <> 0); // ���ָ����ʹ������,��ô�������������븳ֵ
    control.Parent := AContainer;
    control.Align := alClient;
    //
    Data.IsContainer := True;
    with Data.ContainerData do
    begin
      Child := control;
      CWndPtr := HUNIT(NotifySys(NAS_CREATE_CWND_OBJECT_FROM_HWND, AContainer.Handle, 0));
      OldProc := Pointer(SetWindowLong(AContainer.Handle, GWL_WNDPROC, Integer(@ELib_ContainerNewProc)));
      _SetPropData(AContainer, Data);
      Painting := false;
      Result := CWndPtr;
    end;
    //
    New(Data);
    Data.Control := control;
    Data.IsContainer := False;
    with Data.ControlData do
    begin
      Recreating := False;
      MouseTracking := False;
      MouseEntered := False;
      HasContainer := True;
      Container := AContainer;
      FormID := AFormID;
      UnitID := AUnitID;
      OldProc := Pointer( SetWindowLong(Control.Handle, GWL_WNDPROC, Integer(@ELib_ChildNewProc)));
      _SetPropData(control, Data);
    end;
  end;
end;

function ELib_CreateControl(out UnitHandle: HUNIT; ControlClass: TWinControlClass;
  dwStyle, hParentWnd: Cardinal; x,y,cx,cy: Integer; ContainerClass: TContainerClass = nil; AUnitID: Cardinal = 0; AFormID: Cardinal = 0): TWinControl;
var
  T: TWinControl;
  C: TContainer;
begin
  if Assigned(ContainerClass) then
  begin
    C := ContainerClass.CreateParented(hParentWnd);
    Result := ControlClass.Create(C);
    Result.Visible := True;
    T := C;
  end
  else
  begin
    C := nil;
    Result := ControlClass.CreateParented(hParentWnd);
    T := Result;
  end;

  UnitHandle := ELib_RegControl(Result, C, AUnitID, AFormID);

  dwStyle := dwStyle or WS_CHILD or WS_CLIPSIBLINGS or Cardinal(GetWindowLong(Result.Handle, GWL_STYLE));
  SetWindowLong(Result.Handle, GWL_STYLE, dwStyle);
  with T do begin
    Left := x;
    Top := y;
    Width := cx;
    Height := cy;
    Visible := False;
    Enabled := (dwStyle and WS_DISABLED ) = 0;
  end;
end;

procedure ELib_SettingForFunctionalControl(control: TPanel; imageResourceID: Integer; fixMinSize: Boolean = true; fixMaxSize: Boolean = true);
var image: TImage;
begin
  //���߱߿�
  with control do begin
    BorderStyle := bsSingle;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Ctl3D := false;
    //���������С�ߴ�Ϊ26*26
    with Constraints do begin
      if fixMinSize then begin
        MinWidth  := 26;
        MinHeight := 26;
      end;
      if fixMaxSize then begin
        MaxWidth  := 26;
        MaxHeight := 26;
      end;
    end;
  end;

  //���з�ͼƬ��
  image := TImage.Create(control);
  with image do begin
    Picture.Bitmap.LoadFromResourceID(HInstance, imageResourceID);
    Align := alClient;
    Center := true;
  end;
  control.InsertControl(image);
end;

function ELib_AllocHGlobal(Stream: TStream):HGLOBAL;
var
  ptr: Pointer;
  OldPos: Int64;
begin
  Result := GlobalAlloc(GMEM_MOVEABLE, Stream.Size);
  if Result = 0 then exit;
  ptr := GlobalLock(Result);
  if ptr = nil then
  begin
    GlobalFree(Result);
    Result := 0;
    exit;
  end;
  OldPos := Stream.Position;
  Stream.Position := 0;
  Stream.ReadBuffer(ptr^, Stream.Size);
  Stream.Position := OldPos;
end;

function ELib_BooleanToEBool(value: Boolean): EBool;
begin
  if value then
    Result := ETrue
  else
    Result := EFalse;
end;

function ELib_EBoolToBoolean(value: EBool): Boolean;
begin
  if value = ETrue then
    Result := true
  else
    Result := false;
end;

{ TAttachedROMemoryStream }

constructor TAttachedMemoryStream.Create(Ptr: Pointer; Size: Integer);
begin
  inherited Create();
  Self.SetPointer(Ptr, Size);
end;

function TAttachedMemoryStream.Write(const Buffer; Count: Integer): Longint;
var
  Ptr: Pointer;
begin
  Result := 0;
  if Count < 0 then exit;
  if Position + Count > Size then
    Count := Size - Position;
  Ptr := Memory;
  Move(Buffer, Ptr, Count);
  Result := Count;
end;

function ELib_CreateBitmap(data: Pointer; size: Cardinal): Graphics.TBitmap;
var
  Handle: HBITMAP;
begin
  Result := nil;
  Handle := NotifySys(NAS_GET_HBITMAP, Cardinal(Data), Size);
  if Handle = 0 then exit;
  Result := Graphics.TBitmap.Create();
  Result.Handle := Handle;
end;

function ELib_TileBitmap(var bitmap: Graphics.TBitmap; var DisplaySize: TSize): Boolean;
var
  NewBitmap: Graphics.TBitmap;
begin
  NewBitmap := ELib_CreateTitledBitmap(Bitmap, DisplaySize);
  Result := True;
  if Assigned(NewBitmap) then
    Bitmap.Assign(NewBitmap)
  else
    Result := False;
end;

function ELib_CreateTitledBitmap(const bitmap: Graphics.TBitmap; var DisplaySize: TSize): Graphics.TBitmap;
var
  X,Y: Integer;
begin
  Result := nil;
  if not Assigned(Bitmap) then exit;
  if (Bitmap.Width = 0) or (Bitmap.Height = 0) then exit;
  if (DisplaySize.cx <= Bitmap.Width) and (DisplaySize.cy <= Bitmap.Height) then exit;
  X :=0; Y := 0;
  Result := Graphics.TBitmap.Create();
  Result.Width := Bitmap.Width * Ceil(DisplaySize.cx / Bitmap.Width);
  Result.Height := Bitmap.Height * Ceil(DisplaySize.cy / Bitmap.Height);
  try
    while X < DisplaySize.cx  do
    begin
      while Y < DisplaySize.cy do
      begin
        Result.Canvas.Draw(X, Y, Bitmap);
        Inc(Y, Bitmap.Height);
      end;
      Y := 0;
      Inc(X, Bitmap.Width);
    end
  except
    FreeAndNil(Result);
    raise
  end;
end;

function ELib_ToEBackColor(color: TColor): Cardinal;
begin
  Result := Cardinal(color);
  if (Result <> clSystemColor) and (Result and clSystemColor <> 0) then
    Result := GetSysColor(Result and not clSystemColor);
  if Result = GetSysColor(COLOR_BTNFACE) then
    Result := CLR_DEFAULT;
end;

function ELib_FromEBackColor(color: Cardinal): TColor;
begin
  if Cardinal(color) = clSystemColor then
    result := TColor(GetSysColor(COLOR_BTNFACE))
  else
    result := TColor(color);
end;


function ELib_StreamReadInteger(Stream: TStream): Integer;
begin
  Stream.Read(Result, sizeof(Result));
end;

function ELib_StreamReadSmallInt(Stream: TStream): Smallint;
begin
  Stream.Read(Result, sizeof(Result));
end;

function ELib_StreamReadCardinal(Stream: TStream): Cardinal;
begin
  Stream.Read(Result, sizeof(Result));
end;

function ELib_StreamReadDouble(Stream: TStream): Double;
begin
  Stream.Read(Result, sizeof(Result));
end;

function ELib_StreamReadString(Stream: TStream): String;
var
  LenWithZero: Integer;
  Ptr: PChar;
begin
  Result := '';
  LenWithZero := ELib_StreamReadInteger(Stream);
  if LenWithZero = 0 then exit;
  Ptr := GetMemory(LenWithZero);
  try
    Stream.Read(Ptr^, LenWithZero);
    Result := Ptr;
  finally
    FreeMemory(Ptr);
  end;
end;

function ELib_StreamReadStrings(Stream: TStream; var Strings: TStringList): Integer;
var
  StringsCount, I: Integer;
begin
  StringsCount := ELib_StreamReadInteger(Stream);
  for I:= 0 to StringsCount - 1 do
  begin
    Strings.Append(ELib_StreamReadString(Stream));
  end;
  Result := StringsCount;
end;

function ELib_StreamReadLogFont(Stream: TStream; var Font: LOGFONT): Boolean;
begin
  Result := Stream.Read(Font, sizeof(Font)) = sizeof(LOGFONT);
end;

function ELib_StreamWriteInteger(Stream: TStream; Value: Integer): Boolean;
begin
  Result := Stream.Write(Value, sizeof(Value)) = sizeof(Value);
end;

function ELib_StreamWriteSmallInt(Stream: TStream; Value: SmallInt): Boolean;
begin
  Result := Stream.Write(Value, sizeof(Value)) = sizeof(Value);
end;

function ELib_StreamWriteCardinal(Stream: TStream; Value: Cardinal): Boolean;
begin
  Result := Stream.Write(Value, sizeof(Value)) = sizeof(Value);
end;

function ELib_StreamWriteDouble(Stream: TStream; Value: Double): Boolean;
begin
  Result := Stream.Write(Value, sizeof(Value)) = sizeof(Value);
end;

function ELib_StreamWriteString(Stream: TStream; const Value: String): Boolean;
begin
  Result := False;
  if not ELib_StreamWriteInteger(Stream, Length(Value) + 1) then
    exit;
  if Stream.Write(PChar(Value)^, Length(Value) + 1) <> Length(Value) + 1 then
    exit;
  Result := True;
end;

function ELib_StreamWriteStrings(Stream: TStream; const Value: TStrings): Boolean;
var
  I: Integer;
begin
  Result := False;
  ELib_StreamWriteInteger(Stream,Value.Count);
  for I := 0 to Value.Count - 1 do
  begin
    if not ELib_StreamWriteString(Stream, Value[I]) then exit;
  end;
  Result := True;
end;

function ELib_StreamWriteFont(Stream: TStream; const Value: LogFont): Boolean;
begin
  Result := Stream.Write(Value, sizeof(Value)) = sizeof(Value);
end;


{ ELib_PropReader }


{ ELib_TPropReader }

constructor ELib_TPropReader.Create(DataAddress: Pointer; DataLength: Cardinal);
begin
  FDataAddress := DataAddress;
  FDataLength := DataLength;
  FPosition := 0;
end;

function ELib_TPropReader.Read(Buffer: Pointer; Count: Cardinal): Boolean;
var Source: Pointer;
begin
  Result := false;
  if (FDataLength - FPosition < Count) or
     (FDataAddress = nil) or (FDataLength = 0)
    then exit;

  Source := Pointer(Cardinal(FDataAddress) + FPosition);
  CopyMemory(Buffer, Source, Count);

  FPosition := FPosition + Count;
  Result := true;
end;

function ELib_TPropReader.ReadBool(): EBool;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadByte(): Byte;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadCardinal(): Cardinal;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadDouble(): Double;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadDWord(): DWORD;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadFont(): TLogFont;
begin
  Read(@result, sizeof(TLogFont));
end;

function ELib_TPropReader.ReadFont(out fontVar: TLogFont): Boolean;
begin
  Result := Read(@fontVar, sizeof(fontVar));
end;

function ELib_TPropReader.ReadInt(): Integer;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadString(): String;
var
  strlen: DWORD;
  strbuffer: array of Char;
begin
  Result := '';
  strlen := ReadDWord();
  if strlen <= 0 then exit;

  SetLength(strbuffer, strlen + 1); //the last is #0
  if Read(@strbuffer[0], strlen) = false then exit;

  Result := PChar(@strbuffer[0]);
end;

function ELib_TPropReader.ReadStrings(stringsVar: TStrings): Boolean;
var
  count,i: Integer;
begin
  Assert(stringsVar <> nil);
  Result := false;
  stringsVar.Clear;
  count := ReadInt();
  if count <= 0 then exit;
  for i := 1 to count do begin
    stringsVar.Add(ReadString());
  end;
  Result := true;
end;

function ELib_TPropReader.ReadMemoryStream(memoryVar: TMemoryStream): Boolean;
var size: Cardinal;
begin
  Assert(memoryVar <> nil);
  memoryVar.Clear;
  size := ReadCardinal();
  memoryVar.SetSize(size);
  Read(memoryVar.Memory, size);
  Result := true;
end;

{ ELib_TPropWriter }

constructor ELib_TPropWriter.Create;
begin
  inherited;
  FMemoryStream := TMemoryStream.Create;
end;

destructor ELib_TPropWriter.Destroy;
begin
  FMemoryStream.Free();
  inherited;
end;

function ELib_TPropWriter.Write(DataAddress: Pointer; Count: Cardinal): Boolean;
begin
  Result := true;
  if FMemoryStream.Write(DataAddress^, Count) <> Integer(Count) then
    Result := false;
end;

function ELib_TPropWriter.WriteBool(boolValue: EBool): Boolean;
begin
  Result := Write(@boolValue, sizeof(boolValue));
end;

function ELib_TPropWriter.WriteByte(byteValue: Byte): Boolean;
begin
  Result := Write(@byteValue, sizeof(byteValue));
end;

function ELib_TPropWriter.WriteDouble(doubleValue: Double): Boolean;
begin
  Result := Write(@doubleValue, sizeof(doubleValue));
end;

function ELib_TPropWriter.WriteDWord(dwordValue: DWORD): Boolean;
begin
  Result := Write(@dwordValue, sizeof(dwordValue));
end;

function ELib_TPropWriter.WriteFont(fontValue: LOGFONT): Boolean;
begin
  Result := Write(@fontValue, sizeof(fontValue));
end;

function ELib_TPropWriter.WriteInt(intValue: Integer): Boolean;
begin
  Result := Write(@intValue, sizeof(intValue));
end;

function ELib_TPropWriter.WriteCardinal(cardinalValue: Cardinal): Boolean;
begin
  Result := Write(@cardinalValue, sizeof(cardinalValue));
end;

function ELib_TPropWriter.WriteString(stringValue: String): Boolean;
var
  strlen: Cardinal;
begin
  Result := false;
  strlen := Length(stringValue);
  if WriteDWord(strlen) = false then exit;
  if strlen = 0 then exit;

  Result := Write(PChar(stringValue), strlen);
end;

function ELib_TPropWriter.WriteStrings(stringsValue: TStrings): Boolean;
var i: Integer;
begin
  if stringsValue = nil then begin
    WriteInt(0); Result := true; exit;
  end;

  WriteInt(stringsValue.Count);
  for i:= 0 to stringsValue.Count - 1 do begin
    WriteString(stringsValue.Strings[i]);
  end;
  Result := true;
end;

function ELib_TPropWriter.WriteMemoryStream(memoryValue: TMemoryStream): Boolean;
begin
  if memoryValue = nil then begin
    WriteCardinal(0); Result := true; exit;
  end;

  WriteCardinal(memoryValue.Size);
  Write(memoryValue.Memory, memoryValue.Size);
  Result := true;
end;


function ELib_TPropWriter.AllocHGlobal: HGLOBAL;
begin
  Result := ELib_AllocHGlobal(FMemoryStream);
end;

function ELib_TPropWriter.GetDataAddress: Pointer;
begin
  Result := FMemoryStream.Memory;
end;

function ELib_TPropWriter.GetDataLength: Cardinal;
begin
  Result := Cardinal(FMemoryStream.Size);
end;

function ELib_CreateImageList(Data: Pointer; AOwner: TComponent; out TransparentColor: TColor): TImageList; overload;
var
  Stream: TAttachedMemoryStream;
  ComStream: TStreamAdapter;
const
  Sig: Cardinal = $4C54494D;//MakeLong(MakeWord(Ord('M'), Ord('I')), MakeWord(Ord('T'), Ord('L')));
begin
  Result := nil;
  Stream := TAttachedMemoryStream.Create(Data, MaxInt);
  ComStream := TStreamAdapter.Create(Stream, soOwned);
  try
    if ELib_StreamReadCardinal(Stream) <> Sig then
      raise EExternalException.Create('��Ч��������ͼƬ������');
    TransparentColor := ELib_StreamReadInteger(Stream);
    Result := TImageList.Create(AOwner);
    Result.Handle := ImageList_Read(ComStream);
  finally
    ComStream.Free;
  end;
end;

function ELib_CreateImageList(Data: Pointer; AOwner: TComponent): TImageList; overload;
var
  Clr: TColor;
begin
  Result := ELib_CreateImageList(Data, AOwner, Clr);
end;

procedure ELib_DefineAlignProperty(datatypeIndex: Integer);
begin
  DefineProperty(datatypeIndex, '����', 'Align', '�� VCL �� TWinControl.Align ����һ��', UD_PICK_INT, 0,
      '��'#0'��'#0'��'#0'��'#0'��'#0'ƽ��'#0'�Զ���'#0);
end;


const _EAlignsIndexMap: array[0..6] of TAlign = (alNone, alTop, alBottom, alLeft, alRight, alClient, alCustom);

//see ELib_DefineAlignProperty()
function ELib_GetAlignFromIndex(index: Integer): TAlign;
begin
  if (index < 0) or (index > 6) then begin
    Result := alNone;
    exit;
  end;
  Result := _EAlignsIndexMap[index];
end;

procedure ELib_SetAlignByIndex(control: TWinControl; ePropIndex: Integer);
begin
  control.Align := alNone;
  control.Align := ELib_GetAlignFromIndex(ePropIndex);
end;

function ELib_GetAlignIndex(align: TAlign): Integer;
begin
  case align of
    alNone: Result := 0;
    alTop:  Result := 1;
    alBottom: Result := 2;
    alLeft: Result := 3;
    alRight: Result := 4;
    alClient: Result := 5;
    alCustom: Result := 6;
    else Result := 0;
  end;
end;

procedure ELib_DefineBorderProperty(datatypeIndex: Integer);
begin
  DefineProperty(datatypeIndex, '�߿�', 'Border', nil, UD_PICK_INT, 0,
      '�ޱ߿�'#0'����ʽ'#0'͹��ʽ'#0'ǳ����ʽ'#0'����ʽ'#0'���߱߿�ʽ'#0'�Զ���ʽ'#0);
end;

procedure ELib_SetBorderByIndex(panel: TPanel; ePropIndex: Integer);
begin
  with panel do begin
    case ePropIndex of
      0: begin //�ޱ߿�
        BorderStyle := bsNone;
        BevelInner := bvNone;
        BevelOuter := bvNone;
        BevelWidth := 1;
      end;
      1: begin //����ʽ
        BorderStyle := bsNone;
        BevelInner := bvLowered;
        BevelOuter := bvLowered;
        BevelWidth := 1;
      end;
      2: begin //͹��ʽ
        BorderStyle := bsNone;
        BevelInner := bvNone;
        BevelOuter := bvRaised;
        BevelWidth := 1;
      end;
      3: begin //ǳ����ʽ
        BorderStyle := bsNone;
        BevelInner := bvLowered;
        BevelOuter := bvNone;
        BevelWidth := 1;
      end;
      4: begin //����ʽ
        BorderStyle := bsNone;
        BevelInner := bvLowered;
        BevelOuter := bvRaised;
        BevelWidth := 2;
      end;
      5: begin //���߱߿�ʽ
        BorderStyle := bsSingle;
        BevelInner := bvNone;
        BevelOuter := bvNone;
        BevelWidth := 1;
      end;
      6: begin //�Զ���ʽ
      end;
    end; //case
  end; //with
end;

function  ELib_GetBorderIndex(panel: TPanel): Integer;
begin
  with panel do begin
    if
      (BorderStyle = bsNone) and
      (BevelInner = bvNone) and
      (BevelOuter = bvNone) and
      (BevelWidth = 1) then
        Result := 0 //�ޱ߿�
    else if
      (BorderStyle = bsNone) and
      (BevelInner = bvLowered) and
      (BevelOuter = bvLowered) and
      (BevelWidth = 1) then
        Result := 1 //����ʽ
    else if
      (BorderStyle = bsNone) and
      (BevelInner = bvNone) and
      (BevelOuter = bvRaised) and
      (BevelWidth = 1) then
        Result := 2 //͹��ʽ
    else if
      (BorderStyle = bsNone) and
      (BevelInner = bvLowered) and
      (BevelOuter = bvNone) and
      (BevelWidth = 1) then
        Result := 3 //ǳ����ʽ
    else if
      (BorderStyle = bsNone) and
      (BevelInner = bvLowered) and
      (BevelOuter = bvRaised) and
      (BevelWidth = 2) then
        Result := 4 //����ʽ
    else if
      (BorderStyle = bsSingle) and
      (BevelInner = bvNone) and
      (BevelOuter = bvNone) and
      (BevelWidth = 1) then
        Result := 5 //���߱߿�ʽ
    else
      Result := 6; //�Զ���ʽ
  end;
end;

//set TLogFont to TFont
procedure ELib_SetFont(font: TFont; const LogFont: TLogFont);
var
	Style: TFontStyles;
begin
	with LogFont do
	begin
		font.Name := lfFaceName;
		font.Height := lfHeight;
		Style := [];
		if lfWeight > FW_REGULAR then Include(Style, fsBold);
		if lfItalic <> 0 then Include(Style, fsItalic);
		if lfUnderline <> 0 then Include(Style, fsUnderline);
		if lfStrikeOut <> 0 then Include(Style, fsStrikeOut);
		font.Style := Style;
	end;
end;

procedure ELib_SetDefaultFont(font: TFont);
begin
		font.Name := '����';
		font.Height := -12;
    font.Style := [];
end;

function ELib_GetLogFont(const font: TFont): TLogFont;
var logfont: TLogFont;
begin
  GetObject(font.Handle, sizeof(logfont), @logfont);
  result := logfont;
end;

//����С���
procedure ELib_SetFont_Songti9(font: TFont);
begin
  with font do begin
    Name := '����';
    Height := -12;
    Style := [];
  end;
end;

function ELib_TStringsToEArray(const Strings: TStrings): Pointer;
var
  Memory: ELib_TPropWriter;
  I: Integer;
begin
  Memory := ELib_TPropWriter.Create;
  try
    Memory.WriteInt(1);
    Memory.WriteInt(0);
    if Strings.Count > 0 then
    begin
      for I := 0 to Strings.Count - 1 do
      begin
        Memory.WriteInt(Integer(CloneTextData(PChar(Strings[I]))));
        PInteger(Integer(Memory.GetDataAddress) + sizeof(Integer))^ := I + 1;
      end;
    end;
    result := MMalloc(Memory.GetDataLength);
    Move(Memory.GetDataAddress^, result^, Memory.GetDataLength);
  finally
    Memory.Free;
  end;
end;

{ TVclPanelContainer }

constructor TVclPanelContainer.Create(AOwner: TComponent);
begin
  inherited;
  // ���� Container �ޱ߿�
  BorderStyle := bsNone;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Ctl3D := False;
end;

end.

