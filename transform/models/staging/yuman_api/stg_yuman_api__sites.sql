{{
  config(
    materialized='table',
    description='Sites nettoyés avec référence client validée'
  )
}}

with source_data as (
    select * from {{ source('yuman_api', 'yuman_sites') }}
),

extracted_postal_code as (
    select
        *,
        (
            select value::jsonb->>'value'
            from jsonb_array_elements(_embed_fields::jsonb)
            where value::jsonb->>'name' = 'CODE POSTAL'
            limit 1
        ) as raw_code_postal
    from source_data
),

cleaned as (
    select
        id as site_id,
        client_id,
        agency_id,
        code as site_code,
        name as site_name,
        address as site_address,
        -- Nettoyage du code postal : suppression du ".0", puis cast en texte
        regexp_replace(raw_code_postal, '\.0$', '') as code_postal,
        created_at::timestamp as created_at,
        updated_at::timestamp as last_updated,
        _sdc_extracted_at::timestamp as extracted_at,
        _sdc_deleted_at::timestamp as deleted_at
    from extracted_postal_code
    where id is not null 
      and client_id is not null
)

select * from cleaned