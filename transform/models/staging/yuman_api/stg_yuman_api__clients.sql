{{
  config(
    materialized='table',
    description='Clients nettoyés et standardisés'
  )
}}

with source_data as (
    select * from {{ source('yuman_api', 'yuman_clients') }}
),

base_clients as (
    select
        id,
        code,
        upper(trim(name)) as client_name,
        lower(trim(email)) as email,
        updated_at::timestamp as last_updated,
        _embed_fields::jsonb as embed_fields
    from source_data
    where id is not null
),

json_parsed as (
    select
        id,
        code,
        client_name,
        email,
        last_updated,
        jsonb_array_elements(coalesce(embed_fields, '[]'::jsonb)) as field
    from base_clients
),

extracted_fields as (
    select
        id,
        code,
        client_name,
        email,
        last_updated,
        field->>'name' as field_name,
        field->>'value' as field_value
    from json_parsed
),

pivoted as (
    select
        bc.id,
        bc.code,
        bc.client_name,
        bc.email,
        bc.last_updated,
        max(case when ef.field_name = 'CATEGORIE CLIENT EVS' then ef.field_value end) as client_category
    from base_clients bc
    left join extracted_fields ef on ef.id = bc.id
    group by bc.id, bc.code, bc.client_name, bc.email, bc.last_updated
)

select * from pivoted
