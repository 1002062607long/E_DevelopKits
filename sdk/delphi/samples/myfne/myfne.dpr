library myfne;

uses
  e,
  SysUtils,
  Classes,
  Unit1 in 'Unit1.pas',
  mypanel in 'mypanel.pas';

{$R *.res}
{$E fne} //ָ����������ļ�����׺Ϊ"fne"


//������֧�ֿ�Ҫ��ĵ������� GetNewInf()
function GetNewInf() : pLIB_INFO; stdcall; export;
begin
  result := GetLibInfo();
end;

//����������(exports)
exports
  GetNewInf;


begin

  DefineLib
  (
      'myfne', '{5CAFDDB6-22E7-4B27-823A-A80A3919189F}', //szName, szGuid
      'Delphi������һ���򵥵�������֧�ֿ⣬��Ҫ������ʾ��', //szExplain
      1, 0, 1, __GBK_LANG_VER, //nMajorVersion, nMinorVersion, nBuildNumber, nLanguage
      0, //dwState
      '����������������������������޹�˾', 'www.dywt.com.cn', '', //szAuthor,szHomePage,szOther
      2, '0000����1'#0'0000����2'#0, //nCategoryCount, szzCategory
      nil, nil, //pfnRunAddInFn, szzAddInFnInfo
      nil, //pfnNotifyLib (can be nil, default to DefaultProcessNotifyLib)
      nil, //szzDependFiles
      nil  //pfnFreeLibData
  );

  DefineConstsCommandsAndDatatype1;

  DefineMyPanel;

end.

