page 50803 "Enrollment Journal"
{
    ApplicationArea = All;
    Caption = 'Enrollment Journal';
    PageType = List;
    SourceTable = "Enrollment Journal Line";
    UsageCategory = Lists;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Student No."; Rec."Student No.")
                {
                    ToolTip = 'Specifies the value of the Student No. field.', Comment = '%';
                }
                field("Student Name"; Rec."Student Name")
                {
                    ToolTip = 'Specifies the value of the Student Name field.', Comment = '%';
                }
                field("Course Code"; Rec."Course Code")
                {
                    ToolTip = 'Specifies the value of the Course Code field.', Comment = '%';
                }
                field("Course Description"; Rec."Course Description")
                {
                    ToolTip = 'Specifies the value of the Course Description field.', Comment = '%';
                }
                field("Enrollment Date"; Rec."Enrollment Date")
                {
                    ToolTip = 'Specifies the value of the Enrollment Date field.', Comment = '%';
                }
                field("Fee Amount"; Rec."Fee Amount")
                {
                    ToolTip = 'Specifies the value of the Fee Amount field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                Caption = 'Post';
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;


                trigger OnAction()
                var
                    EnrollmentPost: Codeunit "Enrollment Post";

                begin
                    if not Confirm('Do you want to post all enrollment lines?') then
                        exit;

                    EnrollmentPost.Run(Rec)
                end;
            }
            action("Show Posted Entries")
            {
                caption = 'Show Posted Entries';
                applicationArea = All;
                Image = History;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PostedEnrollmentEntry: Record "Posted Enrollment Entry";
                begin
                    PostedEnrollmentEntry.SetRange("Student No.", Rec."Student No.");
                    Page.Run(Page::"Posted Enrollment Entries", PostedEnrollmentEntry);
                end;
            }
        }
    }
}
