table 50805 "Student Mgt. Setup"
{
    Caption = 'Student Mgt. Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Student Nos."; Code[20])
        {
            Caption = 'Student Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Course Nos."; Code[20])
        {
            Caption = 'Course Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Posted Enrollment Nos."; Code[20])
        {
            TableRelation = "No. Series";
            Caption = 'Posted Enrollment Nos.';}
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
