report 50800 "Student Enrollment List"
{
    Caption = 'Student Enrollment list';
    UsageCategory = Administration;
    ApplicationArea = All;
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
            column(StudentName; "Name")
            {

            }
            column(TotalFeesPaid; "Total Fees Paid")
            {

            }
            dataitem(PostedEnrollmentEntry; "Posted Enrollment Entry")
            {
                DataItemLink = "Student No." = field("No.");
                RequestFilterFields = "Posting Date";
                column(CourseCode; "Course Code")
                {

                }
                column(CourseDesc; "Course Description")
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