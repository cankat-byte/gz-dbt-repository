{{ config(materialized="table") }}

-- Önce ürün miktarlarını kargo bazında özetliyoruz
with
    nb_products_parcel as (
        select parcel_id, sum(qty) as qty, count(distinct model_name) as nb_products
        from {{ ref("stg_cc_parcel_product") }}
        group by 1
    )

select
    -- Anahtar ve Paket Bilgileri
    p.parcel_id,
    p.parcel_tracking,
    p.priority,

    -- Tarihler (Staging'de düzelttiğimiz temiz tarihleri alıyoruz)
    p.date_purchase,
    p.date_shipping,
    p.date_delivery,

    -- Ay Bilgisi
    extract(month from p.date_purchase) as month_purchase,

    -- Durum (Status) KPI 
    case
        when p.date_shipping is null
        then 'Devam Ediyor'
        when p.date_delivery is null
        then 'Taşınıyor'
        when p.date_delivery is not null
        then 'Teslim Edildi'
        else 'Diğer'
    end as status,

    -- Zaman Farkları KPI (Gün bazında)
    date_diff(p.date_shipping, p.date_purchase, day) as expedition_time,
    date_diff(p.date_delivery, p.date_shipping, day) as transport_time,
    date_diff(p.date_delivery, p.date_purchase, day) as delivery_time,

    -- Gecikme KPI (5 günden fazla sürenler için 1, değilse 0)
    case
        when
            p.date_delivery is not null
            and date_diff(p.date_delivery, p.date_purchase, day) > 5
        then 1
        else 0
    end as is_delayed,

    -- Ürün Metrikleri (CTE'den geliyor)
    n.qty,
    n.nb_products

from {{ ref("stg_cc_parcel") }} as p
left join nb_products_parcel as n on p.parcel_id = n.parcel_id
