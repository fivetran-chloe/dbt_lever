with opportunity_application as (

    select *
    from {{ ref('int_lever__opportunity_application') }}
),

opportunity_sources as (

    select 
        opportunity_id,
        {{ fivetran_utils.string_agg('source', "', '") }} as sources

    from {{ var('opportunity_source') }}

    group by 1
),

contact_info as (

    select *
    from {{ ref('int_lever__contact_info') }}
),

order_resumes as (

    select 
        *,
        row_number() over(partition by opportunity_id order by created_at desc) as row_num
    
    from {{ var('resume') }}
),

latest_resume as (

    select *
    from order_resumes 

    where row_num = 1
),

final as (

    select
        opportunity_application.*,
        opportunity_sources.sources,
        latest_resume.file_download_url as resume_download_url,
        contact_info.phones,
        contact_info.emails,
        contact_info.linkedin_link,
        contact_info.github_link

    from opportunity_application

    left join opportunity_sources
        on opportunity_application.opportunity_id = opportunity_sources.opportunity_id

    left join latest_resume 
        on latest_resume.opportunity_id = opportunity_application.opportunity_id

    left join contact_info
        on contact_info.contact_id = opportunity_application.contact_id
)

select *
from final