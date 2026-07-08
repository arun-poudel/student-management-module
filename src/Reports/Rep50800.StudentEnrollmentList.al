report 50800 "Student Enrollment List"
{
    ApplicationArea = All;
    Caption = 'Student Enrollment List';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/StudentEnrollmentList.rdl';


    dataset
    {
        dataitem(Student; Student)
        {
            RequestFilterFields = "No.";

            column(StudentNo; "No.")
            {
            }

            column(StudentName; Name)
            {
            }

            column(TotalFeesPaid; "Total Fees Paid")
            {
            }



            dataitem(PostedEnrollmentEntry; "Posted Enrollment Entry")
            {
                DataItemLink = "Student No." = FIELD("No.");
                RequestFilterFields = "Posting Date";

                column(CourseCode; "Course Code")
                {
                }

                column(CourseDescription; "Course Description")
                {
                }

                column(EnrollmentDate; "Enrollment Date")
                {
                }

                column(FeeAmount; "Fee Amount")
                {
                }

                column(PostingDate; "Posting Date")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                CalcFields("Total Fees Paid");
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
            }
        }
    }
}