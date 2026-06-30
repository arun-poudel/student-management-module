table 50802 "Course"
{
    Caption = 'Course';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; CreditHour; Decimal)
        {
            Caption = 'CreditHour';
            DataClassification = CustomerContent;
        }
        field(4; "Fee Amount"; Decimal)
        {
            Caption = 'Fee Amount';
            DataClassification = CustomerContent;
        }
        field(5; "Instructor Name"; Text[100])
        {
            Caption = 'Instructor Name';
            DataClassification = CustomerContent;
        }

    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
