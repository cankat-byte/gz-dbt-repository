with 

source as (

    select * from {{ source('raw_data_circle', 'raw_cc_parcel') }}

),

renamed as (

    select
        parcel_id,
        parcel_tracking,
        transporter,
        priority,
        date_purchase,
        date_shipping,
        date_delivery,
        datecancelled

    from source

)

select * from renamed