page 50803 "Enrollment Journal"
{
    ApplicationArea = All;
    Caption = 'Enrollment Journal';
    PageType = List;
    SourceTable = "Enrollment Journal Line";
    UsageCategory = Lists;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Student No."; Rec."Student No.")
                {
                    ToolTip = 'Specifies the value of the Student No. field.', Comment = '%';
                }
                field("Student Name"; Rec."Student Name")
                {
                    ToolTip = 'Specifies the value of the Student Name field.', Comment = '%';
                }
                field("Course Code"; Rec."Course Code")
                {
                    ToolTip = 'Specifies the value of the Course Code field.', Comment = '%';
                }
                field("Course Description"; Rec."Course Description")
                {
                    ToolTip = 'Specifies the value of the Course Description field.', Comment = '%';
                }
                field("Enrollment Date"; Rec."Enrollment Date")
                {
                    ToolTip = 'Specifies the value of the Enrollment Date field.', Comment = '%';
                }
                field("Fee Amount"; Rec."Fee Amount")
                {
                    ToolTip = 'Specifies the value of the Fee Amount field.', Comment = '%';
                }
            }
        }
    }
}
