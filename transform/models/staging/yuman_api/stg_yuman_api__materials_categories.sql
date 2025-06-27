{{ 
  config(
    materialized='table',
    description='Catégories (Machines) nettoyé depuis yuman_material_categories'
  ) 
}}

with source_data as (
    select * 
    from {{ source('yuman_api', 'yuman_material_categories') }}
),

cleaned_material_categories as (
    select
        id as category_id,
        name as category_name,   
        created_at::timestamp as created_at,
        updated_at::timestamp as last_updated,
        _sdc_extracted_at::timestamp as extracted_at,
        _sdc_deleted_at::timestamp as deleted_at
    from source_data
    where id is not null
)

select * from cleaned_material_categories