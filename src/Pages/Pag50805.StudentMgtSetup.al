page 50805 "Student Mgt. Setup"
{
    ApplicationArea = All;
    Caption = 'Student Mgt. Setup';
    PageType = Card;
    SourceTable = "Student Mgt. Setup";
    UsageCategory = Administration;


    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Student Nos."; Rec."Student Nos.")
                {
                    ToolTip = 'Specifies the value of the Student Nos. field.', Comment = '%';
                }
                field("Course Nos."; Rec."Course Nos.")
                {
                    ToolTip = 'Specifies the value of the Course Nos. field.', Comment = '%';
                }
                field("Posted Enrollment Nos."; Rec."Posted Enrollment Nos.")
                {
                    ToolTip = 'Specifies the value of the Posted Enrollment Nos. field.', Comment = '%';
                }
            }
        }
    }
}
