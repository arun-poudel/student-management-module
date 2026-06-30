table 50801 "Student"
{
    Caption = 'Student';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; code[20])
        {
            caption = 'No.';
            DataClassification = CustomerContent;
        }

        field(2; "Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Email"; Text[80])
        {
            Caption = 'Email';
            DataClassification = EndUserIdentifiableInformation;
        }

        field(4; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }

        field(5; "EnrollmentDate"; Date)
        {
            Caption = 'Enrollment Date';
            DataClassification = CustomerContent;
        }

        field(6; "Status"; Enum "student status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(7; "Blocked"; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(pk; "No.")
        {
            Clustered = true;
        }
    }
}