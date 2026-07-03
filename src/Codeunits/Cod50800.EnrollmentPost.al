codeunit 50800 "Enrollment Post"

{
    TableNo = "Enrollment Journal Line";

    trigger OnRun()
    var
        EnrollmentJournalLine: Record "Enrollment Journal Line";
        PostedEnrollmentEntry: Record "Posted Enrollment Entry";
        NextEntryNo: Integer;
        LinesPosted: Integer;

    begin

        EnrollmentJournalLine.Reset();
        EnrollmentJournalLine.SetFilter("Student No.", '<>%1', '');

        if not EnrollmentJournalLine.FindSet() then
            Error('There is noting to post.');

        if PostedEnrollmentEntry.FindLast() then
            NextEntryNo := PostedEnrollmentEntry."Entry No." + 1

        else
            NextEntryNo := 1;

        repeat
            PostedEnrollmentEntry.Init();
            PostedEnrollmentEntry."Entry No." := NextEntryNo;
            PostedEnrollmentEntry."Student No." := EnrollmentJournalLine."Student No.";
            PostedEnrollmentEntry."Student Name" := EnrollmentJournalLine."Student Name";
            PostedEnrollmentEntry."Course Code" := EnrollmentJournalLine."Course Code";
            PostedEnrollmentEntry."Course Description" := EnrollmentJournalLine."Course Description";
            PostedEnrollmentEntry."Enrollment Date" := EnrollmentJournalLine."Enrollment Date";
            PostedEnrollmentEntry."Fee Amount" := EnrollmentJournalLine."Fee Amount";
            PostedEnrollmentEntry."Posting Date" := WorkDate();
            PostedEnrollmentEntry."User ID" := UserId();
            PostedEnrollmentEntry.Insert();
            NextEntryNo += 1;
            LinesPosted += 1;

        until EnrollmentJournalLine.Next() = 0;
        EnrollmentJournalLine.DeleteAll();
        Message('%1 enrollment line(s) were posted.', LinesPosted);




    end;
}