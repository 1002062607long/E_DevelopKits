unit Unit1;

interface
uses e;

procedure DefineConstsCommandsAndDatatype1();


implementation

const Command1_Args: array[0..1] of ARG_INFO = 
  (
    (m_szName:'num1'; m_szExplain:''; m_shtBitmapIndex:0; m_shtBitmapCount:0; m_dtDataType:SDT_INT; m_nDefault:0; m_dwState:0),
    (m_szName:'num2'; m_szExplain:''; m_shtBitmapIndex:0; m_shtBitmapCount:0; m_dtDataType:SDT_INT; m_nDefault:0; m_dwState:0)
  );
procedure Command1(pRetData: pMDATA_INF; nArgCount: Integer; pArgInf: pMDATA_INF); cdecl;
begin  pRetData.m_Value.m_int := ArgArray(pArgInf)[0].m_Value.m_int + ArgArray(pArgInf)[1].m_Value.m_int;end;

procedure Command2(pRetData: pMDATA_INF; nArgCount: Integer; pArgInf: pMDATA_INF); cdecl;
begin  pRetData.m_Value.m_bool := ETrue;end;


procedure DefineEnum1();
var datatypeIndex: Integer;
begin
  datatypeIndex := DefineEnumDatatype('ö��һ', 'Enum1', '����ö��һ��˵��', 0);

  DefineEnumElement(datatypeIndex, 'A', 'constA', '', 1001, 0);
  DefineEnumElement(datatypeIndex, 'B', 'constB', '', 1002, 0);
  DefineEnumElement(datatypeIndex, 'C', 'constC', '', 1003, 0);
end;

procedure Datatype1_m1 (pRetData: pMDATA_INF; nArgCount: Integer; pArgInf: pMDATA_INF); cdecl;
begin  pRetData.m_Value.m_int := 1999;end;
//normal datatype
procedure DefineDatatype1();
var datatypeIndex : integer;
begin
  datatypeIndex := DefineDatatype('��ͨ����һ', 'Datatype1', 'about Datatype1', 0);

  DefineMethod(datatypeIndex, Datatype1_m1, [], '����һ', 'method1', '', SDT_INT, 0, LVL_SIMPLE);
  DefineMethod(datatypeIndex, Datatype1_m1, [], '������', 'method2', '', SDT_INT, 0, LVL_SIMPLE);

  DefineElement(datatypeIndex, '������Ա', 'element1', '', SDT_INT, nil, 0, 0);
  DefineElement(datatypeIndex, '�ı���Ա', 'element2', '', SDT_TEXT, nil, 0, 0);
end;

procedure DefineConstsCommandsAndDatatype1();
begin

  DefineConst('����һ', 'const1', '�������һ��˵�����ı�����', CT_TEXT, 0, '����һ��ֵ(�ı�)');
  DefineConst('������', 'const2', '�����������˵������ֵ����', CT_NUM, 1999, nil);
  DefineConst('������', 'const3', '�����������˵�����߼�����', CT_BOOL, 1, nil);

  DefineCommand(Command1, Command1_Args, '����һ', 'command1', '����һ��˵�����������������ĺ�', SDT_INT, 0, LVL_SIMPLE, 1);
  DefineCommand(Command2, [], '�����', 'command2', '����һ��˵����ֱ�ӷ�����', SDT_BOOL, 0, LVL_SIMPLE, 1);

  DefineEnum1();
  DefineDatatype1();
end;

end.
