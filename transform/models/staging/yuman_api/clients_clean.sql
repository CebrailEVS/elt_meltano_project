{{
  config(
    materialized='table',
    description='Clients nettoyés et standardisés'
  )
}}

with source_data as (
    select * from {{ source('yuman_api', 'yuman_clients') }}
),

cleaned as (
    select
        id,
        upper(trim(name)) as client_name,
        lower(trim(email)) as email,
        updated_at::timestamp as last_updated
    from source_data
    where id is not null  -- Filtrer les données invalides
)

select * from cleaned