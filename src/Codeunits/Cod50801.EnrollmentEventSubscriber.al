codeunit 50801 "Enrollment Event Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Enrollment Post", 'OnAfterPostEnrollmentEntry', '', false, false)]
    local procedure UpdateStudentLastEnrollmentDate(var PostedEntry: Record "Posted Enrollment Entry")
    var
        Student: Record Student;

    begin
        if not Student.Get(PostedEntry."Student No.") then
            exit;

        Student."Last Enrollment Date" := PostedEntry."Enrollment Date";
        Student.Modify();
    end;
}