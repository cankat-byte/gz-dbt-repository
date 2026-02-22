SELECT
  -- Sayısal (INTEGER) olduğu için direkt alıyoruz
  ParCEL_id AS parcel_id, 
  -- Metin olduğu için TRIM kullanmaya devam edebiliriz
  TRIM(Model_mAME) AS model_name,
  -- Miktarı tam sayıya çeviriyoruz
  CAST(QUANTITY AS INT64) AS qty
FROM {{ source('raw_data_circle', 'raw_cc_parcel_product') }}
WHERE ParCEL_id IS NOT NULL