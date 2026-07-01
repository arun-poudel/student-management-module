table 50804 "Posted Enrollment Entry"
{
    Caption = 'Posted Enrollment Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';

        }
        field(2; "Student No."; Code[20])
        {
            Caption = 'Student No.';
        }
        field(3; "Student Name"; Text[100])
        {
            Caption = 'Student Name';
        }
        field(4; "Course Code"; Code[20])
        {
            Caption = 'Course Code';
        }
        field(5; "Enrollment Date"; Date)
        {
            Caption = 'Enrollment Date';
        }
        field(6; "Course Description"; Text[100])
        {
            Caption = 'Course Description';
        }
        field(7; "Fee Amount"; Decimal)
        {
            Caption = 'Fee Amount';
        }
        field(8; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(9; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
