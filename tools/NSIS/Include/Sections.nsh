; Sections.nsh
;
; 区段控制的定义和宏
;
; 在您的脚本中使用以下语句包含此文件：
; !include "Sections.nsh"

;--------------------------------

!ifndef SECTIONS_INCLUDED

!define SECTIONS_INCLUDED

;--------------------------------

; 通用区段定义

;选择区段或区段组
!define SF_SELECTED 1

;区段组
!define SF_SECGRP 2
!define SF_SUBSEC 2 # 废弃

;区段组结束标记
!define SF_SECGRPEND 4
!define SF_SUBSECEND 4 # 废弃

;加粗文本 (Section !blah)
!define SF_BOLD 8

;只读 (SectionIn RO)
!define SF_RO 16

;扩展区段组 (SectionGroup /e blah)
!define SF_EXPAND 32

;区段组部分选择
!define SF_PSELECTED 64 # 内部

#内;部
!define SF_TOGGLED 128 # 内部
!define SF_NAMECHG 256 # 内部

;关闭已选择标记的掩码
!define SECTION_OFF 0xFFFFFFFE

;--------------------------------

; 选择 / 取消 / 保留 section

!macro SelectSection SECTION

  Push $0
  Push $1
    StrCpy $1 "${SECTION}"
    SectionGetFlags $1 $0
    IntOp $0 $0 | ${SF_SELECTED}
    SectionSetFlags $1 $0
  Pop $1
  Pop $0

!macroend

!macro UnselectSection SECTION

  Push $0
  Push $1
    StrCpy $1 "${SECTION}"
    SectionGetFlags $1 $0
    IntOp $0 $0 & ${SECTION_OFF}
    SectionSetFlags $1 $0
  Pop $1
  Pop $0

!macroend

; 如果区段已选择，则取消选择，如果未选择，则选择

!macro ReverseSection SECTION

  Push $0
  Push $1
    StrCpy $1 "${SECTION}"
    SectionGetFlags $1 $0
    IntOp $0 $0 ^ ${SF_SELECTED}
    SectionSetFlags $1 $0
  Pop $1
  Pop $0

!macroend

;--------------------------------
; 用于互斥区段选择的宏
; 作者：Tim Gallagher
;
; 参见 one-section.nsi 以了解使用示例

; 开始单选按钮块
; 应将保存选定区段的变量作为此宏的第一个参数传递。
; 此变量应初始化为默认区段的索引。
;
; 由于此宏使用 $R0 和 $R1，因此不能将这两个作为保存选定区段的变量。

!macro StartRadioButtons var

  !define StartRadioButtons_Var "${var}"

  Push $R0
  
   SectionGetFlags "${StartRadioButtons_Var}" $R0
   IntOp $R0 $R0 & ${SECTION_OFF}
   SectionSetFlags "${StartRadioButtons_Var}" $R0
   
  Push $R1
  
    StrCpy $R1 "${StartRadioButtons_Var}"
   
!macroend

; 单选按钮

!macro RadioButton SECTION_NAME

  SectionGetFlags ${SECTION_NAME} $R0
  IntOp $R0 $R0 & ${SF_SELECTED}
  IntCmp $R0 ${SF_SELECTED} 0 +2 +2
  StrCpy "${StartRadioButtons_Var}" ${SECTION_NAME}

!macroend

; 结束单选按钮块

!macro EndRadioButtons
  
  StrCmp $R1 "${StartRadioButtons_Var}" 0 +4 ; selection hasn't changed
    SectionGetFlags "${StartRadioButtons_Var}" $R0
    IntOp $R0 $R0 | ${SF_SELECTED}
    SectionSetFlags "${StartRadioButtons_Var}" $R0

  Pop $R1
  Pop $R0
  
  !undef StartRadioButtons_Var

!macroend

;--------------------------------

; 这是两个宏，您可以使用它们来在 InstType 中设置一个 Section，
; 或从 InstType 中清除它。
;
; 作者：Robert Kehl
;
; 有关详情，请参见 https://nsis.sourceforge.io/wiki/SetSectionInInstType%2C_ClearSectionInInstType
;
; 对于 WANTED_INSTTYPE 参数，请使用以下定义。

!define INSTTYPE_1 1
!define INSTTYPE_2 2
!define INSTTYPE_3 4
!define INSTTYPE_4 8
!define INSTTYPE_5 16
!define INSTTYPE_6 32
!define INSTTYPE_7 64
!define INSTTYPE_8 128
!define INSTTYPE_9 256
!define INSTTYPE_10 512
!define INSTTYPE_11 1024
!define INSTTYPE_12 2048
!define INSTTYPE_13 4096
!define INSTTYPE_14 8192
!define INSTTYPE_15 16384
!define INSTTYPE_16 32768
!define INSTTYPE_17 65536
!define INSTTYPE_18 131072
!define INSTTYPE_19 262144
!define INSTTYPE_20 524288
!define INSTTYPE_21 1048576
!define INSTTYPE_22 2097152
!define INSTTYPE_23 4194304
!define INSTTYPE_24 8388608
!define INSTTYPE_25 16777216
!define INSTTYPE_26 33554432
!define INSTTYPE_27 67108864
!define INSTTYPE_28 134217728
!define INSTTYPE_29 268435456
!define INSTTYPE_30 536870912
!define INSTTYPE_31 1073741824
!define INSTTYPE_32 2147483648

!macro SetSectionInInstType SECTION_NAME WANTED_INSTTYPE

  Push $0
  Push $1
    StrCpy $1 "${SECTION_NAME}"
    SectionGetInstTypes $1 $0
    IntOp $0 $0 | ${WANTED_INSTTYPE}
    SectionSetInstTypes $1 $0
  Pop $1
  Pop $0

!macroend

!macro ClearSectionInInstType SECTION_NAME WANTED_INSTTYPE

  Push $0
  Push $1
  Push $2
    StrCpy $2 "${SECTION_NAME}"
    SectionGetInstTypes $2 $0
    StrCpy $1 ${WANTED_INSTTYPE}
    IntOp $1 $1 ~
    IntOp $0 $0 & $1
    SectionSetInstTypes $2 $0
  Pop $2
  Pop $1
  Pop $0

!macroend

;--------------------------------

; 设置/清除/检查区段标志位
; 作者：derekrprice

; 在一个区段的标志位中设置一个或多个bits
!macro SetSectionFlag SECTION BITS

  Push $R0
  Push $R1
    StrCpy $R1 "${SECTION}"
    SectionGetFlags $R1 $R0
    IntOp $R0 $R0 | "${BITS}"
    SectionSetFlags $R1 $R0
  Pop $R1
  Pop $R0
 
!macroend

; 从一个区段的标志位中清除一个或多个比特

!macro ClearSectionFlag SECTION BITS

  Push $R0
  Push $R1
  Push $R2
    StrCpy $R2 "${SECTION}"
    SectionGetFlags $R2 $R0
    IntOp $R1 "${BITS}" ~
    IntOp $R0 $R0 & $R1
    SectionSetFlags $R2 $R0
  Pop $R2
  Pop $R1
  Pop $R0

!macroend

; 检查一个或多个位是否已设置在区段标志中
; 如果设置了，跳转到 JUMPIFSET
; 如果没有设置，跳转到 JUMPIFNOTSET

!macro SectionFlagIsSet SECTION BITS JUMPIFSET JUMPIFNOTSET
	Push $R0
	SectionGetFlags "${SECTION}" $R0
	IntOp $R0 $R0 & "${BITS}"
	IntCmp $R0 "${BITS}" +3
	Pop $R0
	StrCmp "" "${JUMPIFNOTSET}" +3 "${JUMPIFNOTSET}"
	Pop $R0
	Goto "${JUMPIFSET}"
!macroend

;--------------------------------

; 通过取消选择并隐藏一个区段来删除它

!macro RemoveSection SECTION

  Push $R0
  Push $R1
    StrCpy $R1 `${SECTION}`
    SectionGetFlags $R1 $R0
    IntOp $R0 $R0 & ${SECTION_OFF}
    SectionSetFlags $R1 $R0
    SectionSetText $R1 ``
  Pop $R1
  Pop $R0

!macroend

; 撤销 RemoveSection 操作

!macro UnremoveSection SECTION SECTION_TEXT

  Push $R0
  Push $R1
  Push $R2
    StrCpy $R1 `${SECTION}`
    StrCpy $R2 `${SECTION_TEXT}`
    SectionGetFlags $R1 $R0
    IntOp $R0 $R0 | ${SF_SELECTED}
    SectionSetFlags $R1 $R0
    SectionSetText $R1 $R2
  Pop $R2
  Pop $R1
  Pop $R0

!macroend

;--------------------------------

!endif
