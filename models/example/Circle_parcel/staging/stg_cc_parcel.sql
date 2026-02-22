{{ config(
  materialized='table'
) }}

SELECT
  parcel_id,
  -- Sütun isimlerini ham verideki (raw) isimlerle birebir aynı yazdığından emin ol
  SAFE.PARSE_DATE('%B %e, %Y', Date_purCHase) AS date_purchase,
  SAFE.PARSE_DATE('%B %e, %Y', Date_sHIpping) AS date_shipping,
  SAFE.PARSE_DATE('%B %e, %Y', DATE_delivery) AS date_delivery,
  
  -- Diğer önemli sütunları da eklemeyi unutma
  Parcel_tracking,
  Transporter,
  Priority
FROM {{ source('raw_data_circle', 'raw_cc_parcel') }}