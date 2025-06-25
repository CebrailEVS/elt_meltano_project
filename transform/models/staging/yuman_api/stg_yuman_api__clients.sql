{{ 
  config(
    materialized='table',
    description='Clients nettoyés et enrichis depuis yuman_clients'
  ) 
}}

with source_data as (
    select * 
    from {{ source('yuman_api', 'yuman_clients') }}
),

base_clients as (
    select
        id as client_id,
        partner_id, 
        code as client_code,
        name as client_name,
        address as client_address,       
        active as is_active,
        _embed_fields::jsonb as embed_fields,
        created_at::timestamp as created_at,
        updated_at::timestamp as last_updated,
        _sdc_extracted_at::timestamp as extracted_at,
        _sdc_deleted_at::timestamp as deleted_at
    from source_data
    where id is not null
),

json_parsed as (
    select
        client_id,
        client_code,
        client_name,
        last_updated,
        jsonb_array_elements(coalesce(embed_fields, '[]'::jsonb)) as field
    from base_clients
),

extracted_fields as (
    select
        client_id,
        client_code,
        client_name,
        last_updated,
        field->>'name' as field_name,
        field->>'value' as field_value
    from json_parsed
),

pivoted as (
    select
        bc.client_id,
        bc.partner_id,
        bc.client_code,
        bc.client_name,
        max(case when ef.field_name = 'CATEGORIE CLIENT EVS' then ef.field_value end) as client_category,
        bc.client_address,
        bc.is_active,
        bc.created_at,
        bc.last_updated,
        bc.extracted_at,
        bc.deleted_at
    from base_clients bc
    left join extracted_fields ef on ef.client_id = bc.client_id
    group by 
        bc.client_id, bc.client_code, bc.client_name, bc.client_address,
        bc.partner_id, bc.is_active,
        bc.created_at, bc.last_updated, bc.extracted_at, bc.deleted_at
)

select * from pivoted