-- Docu/database_schema/provider_schedules.sql

-- 启用 UUID 扩展 (如果尚未启用)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- Table structure for table `provider_schedules`
-- 服务商日程表
--

CREATE TABLE public.provider_schedules (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE, -- 关联到服务商资料表
    service_id uuid REFERENCES public.services(id) ON DELETE SET NULL,                  -- 关联的服务ID（如果日程针对特定服务）
    schedule_type text NOT NULL,                                                      -- 日程类型：daily/weekly/one_time/block
    start_time timestamptz NOT NULL,
    end_time timestamptz NOT NULL,
    is_available boolean NOT NULL DEFAULT TRUE,
    capacity integer DEFAULT 1,
    booked_capacity integer DEFAULT 0,
    recurrence_rule text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX idx_provider_schedules_provider_id ON public.provider_schedules (provider_id);
CREATE INDEX idx_provider_schedules_service_id ON public.provider_schedules (service_id);
CREATE INDEX idx_provider_schedules_time_available ON public.provider_schedules (start_time, end_time, is_available);
CREATE INDEX idx_provider_schedules_schedule_type ON public.provider_schedules (schedule_type);

--
-- Sample data for `provider_schedules`
-- Note: provider_id and service_id must exist in their respective tables.
-- Replace with actual UUIDs.
--

INSERT INTO public.provider_schedules (id, provider_id, service_id, schedule_type, start_time, end_time, is_available, capacity, booked_capacity, recurrence_rule, created_at, updated_at) VALUES
('j0eebc99-9c0b-4ef8-bb6d-6bb9bd380f01', '00000000-0000-0000-0000-000000000001', NULL, 'weekly', '2024-07-29 09:00:00+00', '2024-07-29 17:00:00+00', TRUE, 5, 0, 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR', now(), now()),
('j0eebc99-9c0b-4ef8-bb6d-6bb9bd380f02', '00000000-0000-0000-0000-000000000001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'one_time', '2024-08-01 10:00:00+00', '2024-08-01 14:00:00+00', FALSE, 1, 1, NULL, now(), now()), -- Booked for cleaning service
('j0eebc99-9c0b-4ef8-bb6d-6bb9bd380f03', '00000000-0000-0000-0000-000000000002', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'daily', '2024-07-29 10:00:00+00', '2024-07-29 18:00:00+00', TRUE, 3, 0, 'FREQ=DAILY', now(), now()); 