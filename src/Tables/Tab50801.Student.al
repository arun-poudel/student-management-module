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

        field(9; "Total Courses Enrolled"; Integer)
        {
            Caption = 'Total Courses Enrolled';
            FieldClass = FlowField;
            CalcFormula = count("Posted Enrollment Entry" where("Student No." = field("No.")));
            Editable = false;
        }
        field(10; "Total Fees Paid"; Decimal)
        {
            Caption = 'Total Fees Paid';
            FieldClass = FlowField;
            CalcFormula = sum("Posted Enrollment Entry"."Fee Amount" where("Student No." = field("No.")));
            Editable = false;
            AutoFormatType = 1;
        }
        field(11; "Last Enrollment Date"; Date)
        {
            Caption = 'Last Enrollment Date';
            DataClassification = CustomerContent;
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



    trigger OnInsert()
    var
        StudentMgtSetup: Record "Student Mgt. Setup";
        NoSeries: Codeunit "No. Series";

    begin
        if "No." = '' then begin
            StudentMgtSetup.GetSetup();
            StudentMgtSetup.TestField("Student Nos.");
            "No." := NoSeries.GetNextNo(StudentMgtSetup."Student Nos.");
        end;
    end;


}