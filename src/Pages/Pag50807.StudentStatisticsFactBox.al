page 50807 "Student Statistics FactBox"
{
    PageType = CardPart;
    SourceTable = Student;
    Caption = 'Student Statistics';

    layout
    {
        area(Content)
        {
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