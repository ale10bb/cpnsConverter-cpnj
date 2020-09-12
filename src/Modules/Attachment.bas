Public Function Main()
    ' C.3����Ҫ����ʵ��ɨ����������������ڱ���ԭʼ����ʱ����Ҫ��¼��
    ' �÷ݱ����Ƿ��漰����ϵͳ�����ݿ⡢Ӧ��
    ' �����д洢��Ӧ���½ڱ�ţ�vb��Ĭ��ֵΪ0����Ч��Ŵ�1��ʼ
    Dim vulKind(3) As Integer
    ' ����Ӧ������ʱ(Testing)
    copyDelay = 0
    
    Call CommonWindow.WriteStatus("����", "����", "��ʼ��", "���")
    Set oldAttachment = ActiveDocument
    Set newAttachment = Documents.Add(Visible:=True)
    ' ===== ��dotm�и���2-3�½ڣ�ģ���ʽ�� =====
    Call ThisDocument.Range(ThisDocument.Sections(2).Range.Start, ThisDocument.Sections(3).Range.End).Copy
    Call Delay(copyDelay)
    ' Issue��ĳЩ������������������4605���²���copy��������paste֮ǰ��ϵͳ��������
    ' �����ڸ��ƺ�ճ��֮�����ʱ�����Դ�󽵵͸�����ĳ���Ƶ��
    ' �������������ԣ�ճ������ʱ��������ʱ������ճ����ֱ���ɹ�
    ' (����������ԭ���µģ���ֱ����ѭ���ˣ��Ұ��������)
    On Error GoTo CopyFailureHandler
    Call newAttachment.Content.PasteAndFormat(wdUseDestinationStylesRecovery)
    On Error GoTo 0

    ' ===== ��ȡ��Ŀ��Ų�д�� =====
    Dim tempStr() As String
    tempStr() = Split(oldAttachment.Sections(2).Headers(wdHeaderFooterPrimary).Range.Text, "��")
    ' ���ڶ���ҳü����ð�ŷָ���ȥ���հ׷�
    codeStr = Trim(Replace(tempStr(UBound(tempStr)), Chr(13), ""))
    newAttachment.Bookmarks("C0��Ŀ���1").Range.Text = codeStr
    newAttachment.Bookmarks("C0��Ŀ���2").Range.Text = codeStr
    
    ' ===== ����©��-�ʲ��ֵ� =====
    Call CommonWindow.WriteStatus("����", "����", "��ʼ��", "�����ֵ�")
    vulListStr = ""
    Set vulDict = New Scripting.Dictionary
    For i = 2 To 4
        For j = 2 To oldAttachment.Content.Tables(i).Rows.Count
            ' ע��Word����Chr(13) & Chr(7)��ʶ��Ԫ�����
            vulName = Replace(oldAttachment.Tables(i).Cell(j, 3).Range.Text, Chr(13) & Chr(7), "")
            vulAsset = Replace(oldAttachment.Tables(i).Cell(j, 5).Range.Text, Chr(13) & Chr(7), "")
            Call vulDict.Add(vulName, vulAsset)
            vulListStr = vulListStr + vulName + "��"
        Next j
    Next i
    
    ' ===== ����©������ =====
    vulKindPos = 1
    ' ��λ��B.3��ʼ��
    Set tempRange = oldAttachment.Content
    Call tempRange.Find.Execute(FindText:="B.3 ©����ϸ", Forward:=True)
    startPos = tempRange.GoTo(wdGoToHeading, wdGoToNext).Start
    Do While True
        Call CommonWindow.WriteStatus("B.3 ©����ϸ", "B.4 ���Խ���", "��������", oldAttachment.Range(startPos, startPos + 10).Text)
        ' workRange����Ϊ��������֮�������
        endPos = oldAttachment.Range(startPos, startPos).GoTo(wdGoToHeading, wdGoToNext).Start - 1
        If oldAttachment.Range(startPos, startPos + 3).Text = "B.4" Then Exit Do
        ' �������⣨���棩�����
        If Left(oldAttachment.Range(startPos, startPos).ParagraphStyle, 4) = "���� 3" Then
            ' ��ģ���и��������˵�
            Call ThisDocument.Sections(4).Range.Paragraphs(1).Range.Copy
            Call Delay(copyDelay)
            On Error GoTo CopyFailureHandler
            ' C3_Startλ��C.3�ĵ�һ�ַ�λ�ã����ڶ�λ���Ƶ�
            Call newAttachment.Range( _
                newAttachment.Bookmarks("C3_Start").Range.Start - 1, _
                newAttachment.Bookmarks("C3_Start").Range.Start - 1 _
                ).PasteAndFormat(wdUseDestinationStylesRecovery)
            On Error GoTo 0
            ' �ݴ�ò���λ�ڸ����е�ʵ��λ��
            Select Case oldAttachment.Range(startPos + 6, endPos).Text
                Case "����ϵͳ"
                    newAttachment.Bookmarks("C2����").Range.Text = "����ϵͳ"
                    vulKind(0) = vulKindPos
                Case "���ݿ�"
                    newAttachment.Bookmarks("C2����").Range.Text = "���ݿ�"
                    vulKind(1) = vulKindPos
                Case "Ӧ��"
                    newAttachment.Bookmarks("C2����").Range.Text = "Ӧ��ϵͳ"
                    vulKind(2) = vulKindPos
            End Select
            vulKindPos = vulKindPos + 1
        End If
        ' �ļ����⣨©���������
        If Mid(oldAttachment.Range(startPos, startPos).ParagraphStyle, 1, 4) = "���� 4" Then
            ' ��ģ���и����ļ��˵�
            Call ThisDocument.Range( _
                ThisDocument.Sections(4).Range.Paragraphs(2).Range.Start, _
                ThisDocument.Sections(4).Range.Paragraphs(12).Range.End _
                ).Copy
            Call Delay(copyDelay)
            On Error GoTo CopyFailureHandler
            Call newAttachment.Range( _
                newAttachment.Bookmarks("C3_Start").Range.Start - 1, _
                newAttachment.Bookmarks("C3_Start").Range.Start - 1 _
                ).PasteAndFormat(wdUseDestinationStylesRecovery)
            On Error GoTo 0
            ' ����©������
            Set headingRange = oldAttachment.Range(startPos, endPos).Paragraphs(1).Range
            ' ���������
            Call headingRange.MoveStart(wdWord, 7)
            ' ȥ�����ܴ��ڵ������������
            tempText = Replace(headingRange.Text, "�������ģ�", "")
            ' ȥ�����з��Ϳո�
            tempText = Trim(Replace(tempText, Chr(13), ""))
            ' headingȥ�����յȼ�����ʱΪ©������
            headingText = Trim(Left(tempText, Len(tempText) - 4))
            ' severity������ȡ���յȼ���ȥ������
            severityText = Replace(Right(tempText, 3), "��", "")
            newAttachment.Bookmarks("C2©������").Range.Text = headingText
            ' ���ֵ���������ʲ�
            If Not vulDict.Exists(headingText) Then
                newAttachment.Bookmarks("C2©���ʲ�").Range.Text = "����"
            Else
                newAttachment.Bookmarks("C2©���ʲ�").Range.Text = vulDict.Item(headingText)
            End If
            ' Issue����������ʱ��ĳЩ©�����ܰ���wdInlineShapeScriptAnchor��Ԫ��(ͼΪwdInlineShapePicture)�������쳣����if
            ' BugFix�����InlineShape�����ͣ�����flag���ڿ�������
            flag = False
            i_saved = -1
            If oldAttachment.Range(startPos, endPos).InlineShapes.Count > 0 Then
                For i = 1 To oldAttachment.Range(startPos, endPos).InlineShapes.Count
                    If oldAttachment.Range(startPos, endPos).InlineShapes(i).Type = wdInlineShapePicture Then
                        flag = True
                        i_saved = i
                        Exit For
                    End If
                Next i
            End If
            ' �����ͼ������⸴��©�����Ƶ�ͼע�ϣ�������ͼ
            If flag Then
                newAttachment.Bookmarks("C2©������2").Range.Text = headingText
                Call oldAttachment.Range(startPos, endPos).InlineShapes(i_saved).Select
                Call Selection.Copy
                Call Delay(copyDelay)
                On Error GoTo CopyFailureHandler
                Call newAttachment.Bookmarks("C2ͼ").Range.Paste
                On Error GoTo 0
            ' ����ɾ��ͼ��ص�����
            Else
                newAttachment.Range( _
                    newAttachment.Bookmarks("C2ͼ").Range.Start, _
                    newAttachment.Bookmarks("C2©������2").Range.End + 1 _
                    ).Delete
            End If
            ' ת�����յȼ�
            Select Case severityText
                Case "Σ��", "��Σ"
                    newAttachment.Bookmarks("C2©������").Range.Text = "����"
                Case "��Σ", "��Σ", "��Ϣ"
                    newAttachment.Bookmarks("C2©������").Range.Text = "һ��"
            End Select
            ' �����������
            If InStrRev(headingRange.Text, "������") Then
                newAttachment.Bookmarks("C2©������").Range.Text = "���©����ȫ�����ġ�" + Chr(13)
                Call newAttachment.Bookmarks("C2�Ƿ�����").Delete
            Else
                newAttachment.Bookmarks("C2©������").Range.Text = "���©����δ���ġ�" + Chr(13)
                newAttachment.Bookmarks("C2�Ƿ�����").Range.Text = ""
            End If
            ' ɨһ��ԭ�ģ�ȷ��©���������޸������λ��
            For i = 1 To oldAttachment.Range(startPos, endPos).Paragraphs.Count - 1
                Select Case Mid(oldAttachment.Range(startPos, endPos).Paragraphs(i).Range.Text, 1, 4)
                    Case "©������"
                        discriptionStart = oldAttachment.Range(startPos, endPos).Paragraphs(i + 1).Range.Start
                    Case "��ƽ��"
                        discriptionEnd = oldAttachment.Range(startPos, endPos).Paragraphs(i).Range.Start - 1
                    Case "�޸�����"
                        adviceStart = oldAttachment.Range(startPos, endPos).Paragraphs(i + 1).Range.Start
                End Select
            Next i
            adviceEnd = endPos - 1
            newAttachment.Bookmarks("C2©������").Range.Text = oldAttachment.Range(discriptionStart, discriptionEnd).Text
            newAttachment.Bookmarks("C2©������").Range.Text = oldAttachment.Range(adviceStart, adviceEnd).Text
        End If
        startPos = oldAttachment.Range(startPos, startPos).GoTo(wdGoToHeading, wdGoToNext).Start
    Loop
    
    Call CommonWindow.WriteStatus("����", "����", "�޸�ռλ���ֶ�", "C.1")
    'ɾ��ԭ�����е�ʮ�������ո�
    Call newAttachment.Content.Find.Execute(FindText:="          ", ReplaceWith:="", Replace:=wdReplaceAll)
    '����©��������ֶ�
    C1Str = ""
    C3Str1 = ""
    C3Str2 = ""
    If vulKind(0) > 0 Then
        C1Str = C1Str + "����ϵͳ��"
        C3Str2 = C3Str2 + "�μ�C.2." + Str(vulKind(0)) + "�½ڡ�"
    End If
    If vulKind(1) > 0 Then
        C1Str = C1Str + "���ݿ⡢"
        C3Str2 = C3Str2 + "�μ�C.2." + Str(vulKind(1)) + "�½ڡ�"
    End If
    If vulKind(2) > 0 Then
        C1Str = C1Str + "Ӧ��ϵͳ��"
        C3Str1 = C3Str1 + "�μ�C.2." + Str(vulKind(2)) + "�½ڡ�"
        C3Str2 = C3Str2 + "�μ�C.2." + Str(vulKind(2)) + "�½ڡ�"
    End If
    '����C1
    newAttachment.Bookmarks("C1����").Range.Text = Mid(C1Str, 1, Len(C1Str) - 1)
    Call CommonWindow.WriteStatus("����", "����", "�޸�ռλ���ֶ�", "C.3")
    '����C3
    If Len(C3Str2) > 0 Then
        newAttachment.Content.Tables(1).Cell(3, 4).Range.Text = Mid(C3Str2, 1, Len(C3Str2) - 1)
    Else
        Call newAttachment.Content.Tables(1).Cell(3, 4).Range.Cells.Delete(shiftcells:=wdDeleteCellsEntireRow)
    End If
    If Len(C3Str1) > 0 Then
        newAttachment.Content.Tables(1).Cell(2, 4).Range.Text = Mid(C3Str2, 1, Len(C3Str1) - 1)
    Else
        Call newAttachment.Content.Tables(1).Cell(2, 4).Range.Cells.Delete(shiftcells:=wdDeleteCellsEntireRow)
        newAttachment.Content.Tables(1).Cell(2, 2).Range.Text = "��ȫ���㻷��"
    End If
    For i = 2 To newAttachment.Content.Tables(1).Rows.Count
        newAttachment.Content.Tables(1).Cell(i, 1).Range.Text = Str(i - 1)
    Next i
    Call CommonWindow.WriteStatus("����", "����", "�޸�ռλ���ֶ�", "C.4")
    '����C4ʣ��©���б�
    If Len(vulListStr) > 0 Then
        newAttachment.Bookmarks("C4©������").Range.Text = Mid(vulListStr, 1, Len(vulListStr) - 1)
    Else
        newAttachment.Bookmarks("C4©������").Range.Text = "����"
    End If
    
    '�޸İ�ȫ©������ͳ�Ʊ��ı����м�����ɫ
    Call oldAttachment.Content.Tables(1).Range.Copy
    Call Delay(copyDelay)
    On Error GoTo CopyFailureHandler
    Call newAttachment.Bookmarks("C4©����").Range.Paste
    On Error GoTo 0
    newAttachment.Content.Tables(2).Cell(1, 2).Range.Text = "����"
    newAttachment.Content.Tables(2).Cell(1, 4).Range.Text = "һ��"
    newAttachment.Content.Tables(2).Rows(1).Shading.BackgroundPatternColor = wdColorGray35
    'ɾ���ͳ����
    Call newAttachment.Content.Tables(2).Cell(newAttachment.Content.Tables(2).Rows.Count, 1).Delete(wdDeleteCellsEntireRow)
    '�ۼ�����
    For i = 2 To newAttachment.Content.Tables(2).Rows.Count
        newAttachment.Content.Tables(2).Cell(i, 2).Range.Text = Str( _
            CInt(Replace(newAttachment.Content.Tables(2).Cell(i, 2).Range.Text, Chr(13) & Chr(7), "")) + _
            CInt(Replace(newAttachment.Content.Tables(2).Cell(i, 3).Range.Text, Chr(13) & Chr(7), "")) _
            )
        newAttachment.Content.Tables(2).Cell(i, 4).Range.Text = Str( _
            CInt(Replace(newAttachment.Content.Tables(2).Cell(i, 4).Range.Text, Chr(13) & Chr(7), "")) + _
            CInt(Replace(newAttachment.Content.Tables(2).Cell(i, 5).Range.Text, Chr(13) & Chr(7), "")) + _
            CInt(Replace(newAttachment.Content.Tables(2).Cell(i, 6).Range.Text, Chr(13) & Chr(7), "")) _
            )
    Next i
    ' ɾ�������У����޸��������ɫ
    Call newAttachment.Content.Tables(2).Cell(1, 6).Delete(wdDeleteCellsEntireColumn)
    Call newAttachment.Content.Tables(2).Cell(1, 5).Delete(wdDeleteCellsEntireColumn)
    Call newAttachment.Content.Tables(2).Cell(1, 3).Delete(wdDeleteCellsEntireColumn)
    newAttachment.Content.Tables(2).Range.Font.Name = "���ķ���"
    newAttachment.Content.Tables(2).Range.Font.Name = "Times New Romans"
    newAttachment.Content.Tables(2).Range.Font.Color = wdColorAutomatic
    ' ˢ��ͼ�����
    Call newAttachment.Content.Fields.Update
    ' ɾ��c3_start��ǩ
    Call newAttachment.Bookmarks("C3_Start").Delete
    Call oldAttachment.Close(SaveChanges:=wdDoNotSaveChanges)
    Call newAttachment.Activate
    Exit Function
    ' ���ƹ����쳣ʱ�Ĵ�������
CopyFailureHandler:
    copyDelay = copyDelay + 0.2
    Call Delay(copyDelay)
    Resume
End Function