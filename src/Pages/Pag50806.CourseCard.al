page 50806 CourseCard
{
    ApplicationArea = All;
    Caption = 'CourseCard';
    PageType = Card;
    SourceTable = Course;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
