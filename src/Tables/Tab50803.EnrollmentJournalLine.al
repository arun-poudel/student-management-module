table 50803 "Enrollment Journal Line"
{
    Caption = 'Enrollment Journal Line';
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
            TableRelation = Student."No.";

            trigger OnValidate()
            var
                Student: Record Student;
            begin
                if "Student No." = '' then begin
                    Validate("Student Name", '');
                    exit;
                end;
                Student.Get("Student No.");
                Student.TestField(Blocked, false);
                Validate("Student Name", Student.Name);
            end;
        }
        field(3; "Student Name"; Text[100])
        {
            Caption = 'Student Name';
        }
        field(4; "Course Code"; Code[20])
        {
            Caption = 'Course Code';
            TableRelation = Course."Code";


            trigger OnValidate()
            var
                Course: Record Course;
            begin
                if "Course Code" = '' then begin
                    Validate("Course Description", '');
                    Validate("Fee Amount", 0);
                    exit;
                end;

                Course.Get("Course Code");
                Validate("Course Description", Course.Description);
                Validate("Fee Amount", Course."Fee Amount");
            end;
        }
        field(5; "Course Description"; Text[100])
        {
            Caption = 'Course Description';
        }
        field(6; "Enrollment Date"; Date)
        {
            Caption = 'Enrollment Date';
        }
        field(7; "Fee Amount"; Decimal)
        {
            Caption = 'Fee Amount';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        EnrollmentJournal: Record "Enrollment Journal Line";
    begin
        if EnrollmentJournal.FindLast() then
            "Entry No." := EnrollmentJournal."Entry No." + 1
        else
            "Entry No." := 1;
        "Enrollment Date" := WorkDate();
    end;
}
