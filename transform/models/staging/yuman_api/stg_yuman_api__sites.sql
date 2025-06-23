{{
  config(
    materialized='table',
    description='Sites nettoyés avec référence client validée'
  )
}}

with source_data as (
    select * from {{ source('yuman_api', 'yuman_sites') }}
),

cleaned as (
    select
        id as site_id,
        client_id,
        upper(trim(name)) as site_name,
        updated_at::timestamp as last_updated
    from source_data
    where id is not null 
      and client_id is not null  -- S'assurer que la FK existe
)

select * from cleaned