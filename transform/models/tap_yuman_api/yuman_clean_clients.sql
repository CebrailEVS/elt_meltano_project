{{
  config(
    materialized='table'
  )
}}

with base as (
    select *
    from {{ source('tap_yuman_api', 'yuman_clients') }}
)
select 
    id,
    code,
    name,
    updated_at
from base