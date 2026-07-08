page 50800 "Student card"
{
    ApplicationArea = All;
    Caption = 'Student';
    PageType = Card;
    SourceTable = Student;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field.', Comment = '%';
                }
                field(Email; Rec.Email)
                {
                    ToolTip = 'Specifies the value of the Email field.', Comment = '%';
                }
                field("Enrollment Date"; Rec."Enrollment Date")
                {
                    ToolTip = 'Specifies the value of the Enrollment Date field.', Comment = '%';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field("Total Courses Enrolled"; Rec."Total Courses Enrolled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many courses this student has enrolled in.';
                }
                field("Total Fees Paid"; Rec."Total Fees Paid")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total fees paid by this student.';
                }

            }
        }
    }
}
