page 50802 "Course List"
{
    ApplicationArea = All;
    Caption = 'Course List';
    PageType = List;
    SourceTable = Course;
    UsageCategory = Lists;
    DelayedInsert = true;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(CreditHour; Rec.CreditHour)
                {
                    ToolTip = 'Specifies the value of the CreditHour field.', Comment = '%';
                }
                field("Fee Amount"; Rec."Fee Amount")
                {
                    ToolTip = 'Specifies the value of the Fee Amount field.', Comment = '%';
                }
                field("Instructor Name"; Rec."Instructor Name")
                {
                    ToolTip = 'Specifies the value of the Instructor Name field.', Comment = '%';
                }
            }
        }
    }
}
