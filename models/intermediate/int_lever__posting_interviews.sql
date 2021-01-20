with posting_interview as (

    select *
    from {{ var('posting_interview') }}
),
-- grabbing inteview to get hiring manager of posting into the interiew enhanced model
posting_metrics as (

    select 
        posting.*,
        count(posting_interview.interview_id) as count_interviews
    
    from posting_interview 