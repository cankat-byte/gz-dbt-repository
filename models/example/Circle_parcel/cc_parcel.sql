{{ config(
  materialized='table'
) }}

-- Önce ürün miktarlarını kargo bazında özetliyoruz
WITH nb_products_parcel AS (
  SELECT
    parcel_id,
    SUM(qty) AS qty,
    COUNT(DISTINCT model_name) AS nb_products
  FROM {{ ref('stg_cc_parcel_product') }}
  GROUP BY 1
)

SELECT
  -- Anahtar ve Paket Bilgileri
  p.parcel_id,
  p.parcel_tracking,
  p.priority,

  -- Tarihler (Staging'de düzelttiğimiz temiz tarihleri alıyoruz)
  p.date_purchase,
  p.date_shipping,
  p.date_delivery,

  -- Ay Bilgisi
  EXTRACT(MONTH FROM p.date_purchase) AS month_purchase,

  -- Durum (Status) KPI
  CASE
    WHEN p.date_shipping IS NULL THEN 'Devam Ediyor'
    WHEN p.date_delivery IS NULL THEN 'Taşınıyor'
    WHEN p.date_delivery IS NOT NULL THEN 'Teslim Edildi'
    ELSE 'Diğer'
  END AS status,

  -- Zaman Farkları KPI (Gün bazında)
  DATE_DIFF(p.date_shipping, p.date_purchase, DAY) AS expedition_time,
  DATE_DIFF(p.date_delivery, p.date_shipping, DAY) AS transport_time,
  DATE_DIFF(p.date_delivery, p.date_purchase, DAY) AS delivery_time,

  -- Gecikme KPI (5 günden fazla sürenler için 1, değilse 0)
  CASE 
    WHEN p.date_delivery IS NOT NULL AND DATE_DIFF(p.date_delivery, p.date_purchase, DAY) > 5 THEN 1 
    ELSE 0 
  END AS is_delayed,

  -- Ürün Metrikleri (CTE'den geliyor)
  n.qty,
  n.nb_products

FROM {{ ref('stg_cc_parcel') }} AS p
LEFT JOIN nb_products_parcel AS n ON p.parcel_id = n.parcel_id