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

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";

            begin
                if "Email" <> '' then
                    MailManagement.CheckValidEmailAddresses("Email");
            end;
        }

        field(4; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }

        field(5; "Enrollment Date"; Date)
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
        field(8; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            Editable = false;
        }
    }




    keys
    {
        key(pk; "No.")
        {
            Clustered = true;
        }
    }

    var
        StudentNumberSeriesTok: Label 'STUDENT', Locked = true;

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";

    begin
        if "No." = '' then begin
            "No. Series" := StudentNumberSeriesTok;
            "No." := NoSeries.GetNextNo("No. Series");
        end;
    end;


}