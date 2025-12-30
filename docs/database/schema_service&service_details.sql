create table public.services (
  id uuid not null default extensions.uuid_generate_v4 (),
  provider_id uuid not null,
  title jsonb not null,
  description jsonb null,
  category_level1_id bigint not null,
  category_level2_id bigint null,
  status text not null default 'draft'::text,
  average_rating numeric null default 0.0,
  review_count integer null default 0,
  latitude numeric null,
  longitude numeric null,
  service_delivery_method text not null default 'on_site'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  images_url jsonb null,
  supports_cart boolean null default true,
  booking_type text null default 'direct'::text,
  industry_type text not null default 'food'::text,
  industry_metadata jsonb null default '{}'::jsonb,
  is_available boolean null default true,
  availability_schedule jsonb null default '{}'::jsonb,
  service_area_geometry jsonb null,
  max_distance_km numeric null,
  base_price numeric null,
  pricing_model text null default 'fixed'::text,
  constraint services_pkey primary key (id),
  constraint services_category_level2_id_fkey foreign KEY (category_level2_id) references ref_codes (id),
  constraint services_provider_id_fkey foreign KEY (provider_id) references provider_profiles (id),
  constraint services_category_level1_id_fkey foreign KEY (category_level1_id) references ref_codes (id),
  constraint services_industry_type_check check (
    (
      industry_type = any (
        array[
          'food'::text,
          'home_services'::text,
          'transport'::text,
          'rental'::text,
          'learning'::text,
          'professional'::text
        ]
      )
    )
  ),
  constraint services_booking_type_check check (
    (
      booking_type = any (array['direct'::text, 'cart'::text, 'both'::text])
    )
  ),
  constraint services_pricing_model_check check (
    (
      pricing_model = any (
        array[
          'fixed'::text,
          'hourly'::text,
          'distance_based'::text,
          'quote_only'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_services_category_level1_id on public.services using btree (category_level1_id) TABLESPACE pg_default;

create index IF not exists idx_services_category_level2_id on public.services using btree (category_level2_id) TABLESPACE pg_default;

create index IF not exists idx_services_delivery_method on public.services using btree (service_delivery_method) TABLESPACE pg_default;

create index IF not exists idx_services_location on public.services using btree (latitude, longitude) TABLESPACE pg_default;

create index IF not exists idx_services_provider_id on public.services using btree (provider_id) TABLESPACE pg_default;

create index IF not exists idx_services_status on public.services using btree (status) TABLESPACE pg_default;

create index IF not exists idx_services_industry_type on public.services using btree (industry_type) TABLESPACE pg_default;

create index IF not exists idx_services_available on public.services using btree (is_available) TABLESPACE pg_default;

create index IF not exists idx_services_pricing_model on public.services using btree (pricing_model) TABLESPACE pg_default;




create table public.service_details (
  service_id uuid not null,
  pricing_type text not null default 'fixed_price'::text,
  price numeric null,
  currency text null,
  negotiation_details text null,
  duration_type text not null default 'hours'::text,
  duration interval null,
  images_url text[] null default '{}'::text[],
  videos_url text[] null default '{}'::text[],
  tags text[] null default '{}'::text[],
  service_area_codes text[] null default '{}'::text[],
  platform_service_fee_rate numeric null,
  min_platform_service_fee numeric null,
  service_details_json jsonb null,
  extra_data jsonb null,
  promotion_start timestamp with time zone null,
  promotion_end timestamp with time zone null,
  view_count integer null default 0,
  favorite_count integer null default 0,
  order_count integer null default 0,
  verification_status text not null default 'pending'::text,
  verification_documents text[] null default '{}'::text[],
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  id uuid not null default gen_random_uuid (),
  category text null default 'main'::text,
  name jsonb null,
  sub_category text null,
  is_available boolean null default true,
  sort_order integer null default 0,
  current_stock integer null,
  max_stock integer null,
  attributes jsonb null default '{}'::jsonb,
  business_rules jsonb null default '{}'::jsonb,
  constraint service_details_pkey primary key (id),
  constraint unique_service_category_name unique (service_id, category, name),
  constraint service_details_service_id_fkey foreign KEY (service_id) references services (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_service_details_duration_type on public.service_details using btree (duration_type) TABLESPACE pg_default;

create index IF not exists idx_service_details_pricing_type on public.service_details using btree (pricing_type) TABLESPACE pg_default;

create index IF not exists idx_service_details_service_area_codes on public.service_details using gin (service_area_codes) TABLESPACE pg_default;

create index IF not exists idx_service_details_tags on public.service_details using gin (tags) TABLESPACE pg_default;