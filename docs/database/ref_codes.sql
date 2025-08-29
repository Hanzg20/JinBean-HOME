-- Docu/database_schema/ref_codes.sql

--
-- Table structure for table `ref_codes` (多语言友好版)
-- 分层编码表，用于存储服务类型、提供商类型等分类数据。
--

DROP TABLE IF EXISTS public.ref_codes CASCADE;

CREATE TABLE public.ref_codes (
    id bigint PRIMARY KEY,
    type_code text NOT NULL,           -- 分类类型（如 SERVICE_TYPE）
    code text NOT NULL,                -- 唯一编码
    name jsonb NOT NULL,               -- 多语言名称，如 {"zh": "家政到家", "en": "Home Help"}
    description jsonb,                 -- 多语言描述
    parent_id bigint REFERENCES public.ref_codes(id), -- 父级ID
    level smallint NOT NULL,           -- 层级（1/2/3）
    sort_order integer NOT NULL DEFAULT 0, -- 排序
    status smallint NOT NULL DEFAULT 1,    -- 状态：1=启用，0=禁用，2=待启用，9=失效/废弃
    extra_data jsonb DEFAULT '{}',     -- 额外信息（如icon等）
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 唯一约束
ALTER TABLE public.ref_codes ADD CONSTRAINT unique_type_code_code UNIQUE (type_code, code);

-- 索引
CREATE INDEX idx_ref_codes_type_code ON public.ref_codes (type_code);
CREATE INDEX idx_ref_codes_code ON public.ref_codes (code);
CREATE INDEX idx_ref_codes_parent_id ON public.ref_codes (parent_id);
CREATE INDEX idx_ref_codes_level ON public.ref_codes (level);
CREATE INDEX idx_ref_codes_status ON public.ref_codes (status);

-- RLS 策略
ALTER TABLE public.ref_codes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select on ref_codes" ON public.ref_codes FOR SELECT TO authenticated USING (true);

-- === JinBean 分类体系（2024新版，ID规则：10+3+2+2） ===
-- 一级分类
INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data)
VALUES
  (1010000, 'SERVICE_TYPE', 'FOOD_COURT', '{"zh": "美食天地", "en": "Food Court"}', '{}', NULL, 1, 1, 1, '{"icon":"restaurant"}'),
  (1020000, 'SERVICE_TYPE', 'HOME_TO_HOME', '{"zh": "家政到家", "en": "Home to Home"}', '{}', NULL, 1, 2, 1, '{"icon":"home"}'),
  (1030000, 'SERVICE_TYPE', 'TRAVEL_PLAZA', '{"zh": "出行广场", "en": "Travel Plaza"}', '{}', NULL, 1, 3, 1, '{"icon":"directions_car"}'),
  (1040000, 'SERVICE_TYPE', 'SHARE_PARK', '{"zh": "共享乐园", "en": "Share Park"}', '{}', NULL, 1, 4, 1, '{"icon":"share"}'),
  (1050000, 'SERVICE_TYPE', 'LEARNING_PARK', '{"zh": "学习课堂", "en": "Learning Park"}', '{}', NULL, 1, 5, 1, '{"icon":"school"}'),
  (1060000, 'SERVICE_TYPE', 'LIFE_HELP', '{"zh": "生活帮忙", "en": "Life Help"}', '{}', NULL, 1, 6, 1, '{"icon":"volunteer_activism"}');

-- 美食天地二级
INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1010100, 'SERVICE_TYPE', 'HOME_COOKED', '{"zh": "居家美食", "en": "Home-cooked"}', '{}', 1010000, 2, 1, 1, '{"icon":"home"}'),
  (1010200, 'SERVICE_TYPE', 'CUSTOM_CATERING', '{"zh": "定制美食", "en": "Custom Catering"}', '{}', 1010000, 2, 2, 1, '{"icon":"cake"}'),
  (1010300, 'SERVICE_TYPE', 'WORLD_CUISINE', '{"zh": "世界美食", "en": "World Cuisine"}', '{}', 1010000, 2, 3, 1, '{"icon":"public"}'),
  (1010400, 'SERVICE_TYPE', 'QUICK_EATS', '{"zh": "速食代购", "en": "Quick Eats & Delivery"}', '{}', 1010000, 2, 4, 1, '{"icon":"delivery_dining"}'),
  (1010500, 'SERVICE_TYPE', 'FOOD_COURT_OTHER', '{"zh": "其它", "en": "Other"}', '{}', 1010000, 2, 5, 1, '{"icon":"more_horiz"}');

-- 美食天地三级
INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1010101, 'SERVICE_TYPE', 'HOME_KITCHEN', '{"zh": "家庭小灶", "en": "Home Kitchen"}', '{}', 1010100, 3, 1, 1, '{}'),
  (1010102, 'SERVICE_TYPE', 'COFFEE_TEA', '{"zh": "咖啡奶茶", "en": "Coffee & Tea"}', '{}', 1010100, 3, 2, 1, '{}'),
  (1010103, 'SERVICE_TYPE', 'PRIVATE_CHEF', '{"zh": "厨师上门", "en": "Private Chef"}', '{}', 1010100, 3, 3, 1, '{}'),
  (1010201, 'SERVICE_TYPE', 'PARTY_CATERING', '{"zh": "聚会大餐", "en": "Party Catering"}', '{}', 1010200, 3, 1, 1, '{}'),
  (1010202, 'SERVICE_TYPE', 'CAKE_CUSTOM', '{"zh": "蛋糕定制", "en": "Cake Custom"}', '{}', 1010200, 3, 2, 1, '{}'),
  (1010203, 'SERVICE_TYPE', 'BREAKFAST_BENTO', '{"zh": "早餐便当", "en": "Breakfast Bento"}', '{}', 1010200, 3, 3, 1, '{}'),
  (1010301, 'SERVICE_TYPE', 'CHINA_CUISINE', '{"zh": "地道中餐", "en": "China Cuisine"}', '{}', 1010300, 3, 1, 1, '{}'),
  (1010302, 'SERVICE_TYPE', 'KOREAN_CUISINE', '{"zh": "中韩料理", "en": "Korean Cuisine"}', '{}', 1010300, 3, 2, 1, '{}'),
  (1010303, 'SERVICE_TYPE', 'SEA_CUISINE', '{"zh": "东南亚菜", "en": "Asian Cuisine"}', '{}', 1010300, 3, 3, 1, '{}'),
  (1010304, 'SERVICE_TYPE', 'MIDDLE_EAST_CUISINE', '{"zh": "中东口味", "en": "Middle East Cuisine"}', '{}', 1010300, 3, 4, 1, '{}'),
  (1010305, 'SERVICE_TYPE', 'INDIAN_CUISINE', '{"zh": "印度菜系", "en": "Indian Cuisine"}', '{}', 1010300, 3, 5, 1, '{}'),
  (1010306, 'SERVICE_TYPE', 'TURKISH_CUISINE', '{"zh": "土耳其菜", "en": "Turkish Cuisine"}', '{}', 1010300, 3, 6, 1, '{}'),
  (1010307, 'SERVICE_TYPE', 'EXOTIC_FOOD', '{"zh": "其它异国风味", "en": "Exotic Food"}', '{}', 1010300, 3, 7, 1, '{}'),
  (1010401, 'SERVICE_TYPE', 'GROCERY_DELIVERY', '{"zh": "超市代买", "en": "Grocery Delivery"}', '{}', 1010400, 3, 1, 1, '{}'),
  (1010402, 'SERVICE_TYPE', 'FOOD_DELIVERY', '{"zh": "外卖跑腿", "en": "Food Delivery"}', '{}', 1010400, 3, 2, 1, '{}'),
  (1010403, 'SERVICE_TYPE', 'HOMESTYLE_DELIVERY', '{"zh": "食材快送", "en": "Homestyle Delivery"}', '{}', 1010400, 3, 3, 1, '{}');

-- 家政到家 Home to Home
INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1020100, 'SERVICE_TYPE', 'CLEANING_MAINTENANCE', '{"zh": "清洁保养", "en": "Cleaning & Maintenance"}', '{}', 1020000, 2, 1, 1, '{"icon":"cleaning_services"}'),
  (1020200, 'SERVICE_TYPE', 'FURNITURE_APPLIANCES', '{"zh": "家具家电", "en": "Furniture & Appliances"}', '{}', 1020000, 2, 2, 1, '{"icon":"weekend"}'),
  (1020300, 'SERVICE_TYPE', 'GARDENING_OUTDOOR', '{"zh": "园艺户外", "en": "Gardening & Outdoor"}', '{}', 1020000, 2, 3, 1, '{"icon":"yard"}'),
  (1020400, 'SERVICE_TYPE', 'PET_CARE', '{"zh": "宠物照护", "en": "Pet Care"}', '{}', 1020000, 2, 4, 1, '{"icon":"pets"}'),
  (1020500, 'SERVICE_TYPE', 'REAL_ESTATE', '{"zh": "房产相关", "en": "Real Estate"}', '{}', 1020000, 2, 5, 1, '{"icon":"home_work"}'),
  (1020600, 'SERVICE_TYPE', 'HOME_TO_HOME_OTHER', '{"zh": "其它", "en": "Other"}', '{}', 1020000, 2, 6, 1, '{"icon":"more_horiz"}');

INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1020101, 'SERVICE_TYPE', 'HOME_CLEANING', '{"zh": "家里大扫除", "en": "Home Cleaning"}', '{}', 1020100, 3, 1, 1, '{}'),
  (1020102, 'SERVICE_TYPE', 'DAILY_CLEANING', '{"zh": "日常保洁", "en": "Daily Cleaning"}', '{}', 1020100, 3, 2, 1, '{}'),
  (1020103, 'SERVICE_TYPE', 'CARPET_CLEANING', '{"zh": "地毯清洗", "en": "Carpet Cleaning"}', '{}', 1020100, 3, 3, 1, '{}'),
  (1020104, 'SERVICE_TYPE', 'POST_RENO_CLEANING', '{"zh": "装修后清理", "en": "Post-reno Cleaning"}', '{}', 1020100, 3, 4, 1, '{}'),
  (1020105, 'SERVICE_TYPE', 'DEEP_CLEANING', '{"zh": "深度保洁", "en": "Deep Cleaning"}', '{}', 1020100, 3, 5, 1, '{}'),
  (1020106, 'SERVICE_TYPE', 'PLUMBING', '{"zh": "水管维护", "en": "Plumbing"}', '{}', 1020100, 3, 6, 1, '{}'),
  (1020107, 'SERVICE_TYPE', 'ELECTRICAL_REPAIR', '{"zh": "电路维修", "en": "Electrical Repair"}', '{}', 1020100, 3, 7, 1, '{}'),
  (1020201, 'SERVICE_TYPE', 'FURNITURE_ASSEMBLY', '{"zh": "家具组装", "en": "Furniture Assembly"}', '{}', 1020200, 3, 1, 1, '{}'),
  (1020202, 'SERVICE_TYPE', 'WALL_REPAIR_PAINT', '{"zh": "墙面维护", "en": "Wall Repair/Paint"}', '{}', 1020200, 3, 2, 1, '{}'),
  (1020203, 'SERVICE_TYPE', 'APPLIANCE_INSTALL_REPAIR', '{"zh": "家电安维", "en": "Appliance Install/Repair"}', '{}', 1020200, 3, 3, 1, '{}'),
  (1020301, 'SERVICE_TYPE', 'LAWN_MOWING', '{"zh": "割草修树", "en": "Lawn Mowing"}', '{}', 1020300, 3, 1, 1, '{}'),
  (1020302, 'SERVICE_TYPE', 'GARDEN_CARE', '{"zh": "花园养护", "en": "Garden Care"}', '{}', 1020300, 3, 2, 1, '{}'),
  (1020303, 'SERVICE_TYPE', 'SNOW_REMOVAL', '{"zh": "铲雪除冰", "en": "Snow Removal"}', '{}', 1020300, 3, 3, 1, '{}'),
  (1020401, 'SERVICE_TYPE', 'PET_SITTING', '{"zh": "宠物托管", "en": "Pet Sitting"}', '{}', 1020400, 3, 1, 1, '{}'),
  (1020402, 'SERVICE_TYPE', 'DOG_WALKING', '{"zh": "遛狗服务", "en": "Dog Walking"}', '{}', 1020400, 3, 2, 1, '{}'),
  (1020501, 'SERVICE_TYPE', 'AGENT', '{"zh": "房屋中介", "en": "Agent"}', '{}', 1020500, 3, 1, 1, '{}'),
  (1020502, 'SERVICE_TYPE', 'HOME_ENTERTAINMENT', '{"zh": "家庭娱乐", "en": "Home Entertainment"}', '{}', 1020500, 3, 2, 1, '{}');

-- 出行广场 Travel Plaza
INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1030100, 'SERVICE_TYPE', 'DAILY_SHUTTLE', '{"zh": "日常接送", "en": "Daily Shuttle"}', '{}', 1030000, 2, 1, 1, '{"icon":"airport_shuttle"}'),
  (1030200, 'SERVICE_TYPE', 'COURIER_SHOPPING', '{"zh": "快递代购", "en": "Courier & Shopping"}', '{}', 1030000, 2, 2, 1, '{"icon":"local_shipping"}'),
  (1030300, 'SERVICE_TYPE', 'MOVING', '{"zh": "搬家搬运", "en": "Moving"}', '{}', 1030000, 2, 3, 1, '{"icon":"move_to_inbox"}'),
  (1030400, 'SERVICE_TYPE', 'ERRANDS', '{"zh": "跑腿帮办", "en": "Errands"}', '{}', 1030000, 2, 4, 1, '{"icon":"directions_run"}'),
  (1030500, 'SERVICE_TYPE', 'TRAVEL_PLAZA_OTHER', '{"zh": "其它", "en": "Other"}', '{}', 1030000, 2, 5, 1, '{"icon":"more_horiz"}');

INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1030101, 'SERVICE_TYPE', 'AIRPORT_TRANSFER', '{"zh": "机场接送", "en": "Airport Transfer"}', '{}', 1030100, 3, 1, 1, '{}'),
  (1030102, 'SERVICE_TYPE', 'SCHOOL_SHUTTLE', '{"zh": "学校接送", "en": "School Shuttle"}', '{}', 1030100, 3, 2, 1, '{}'),
  (1030103, 'SERVICE_TYPE', 'CARPOOLING', '{"zh": "拼车顺风", "en": "Carpooling"}', '{}', 1030100, 3, 3, 1, '{}'),
  (1030201, 'SERVICE_TYPE', 'LOCAL_COURIER', '{"zh": "同城快递", "en": "Local Courier"}', '{}', 1030200, 3, 1, 1, '{}'),
  (1030202, 'SERVICE_TYPE', 'PACKAGE_PICKUP', '{"zh": "包裹代收", "en": "Package Pickup"}', '{}', 1030200, 3, 2, 1, '{}'),
  (1030203, 'SERVICE_TYPE', 'SHOPPING_AGENT', '{"zh": "代购服务", "en": "Shopping Agent"}', '{}', 1030200, 3, 3, 1, '{}'),
  (1030301, 'SERVICE_TYPE', 'MOVING_SERVICE', '{"zh": "搬家服务", "en": "Moving Service"}', '{}', 1030300, 3, 1, 1, '{}'),
  (1030302, 'SERVICE_TYPE', 'CHAUFFEUR', '{"zh": "代驾服务", "en": "Chauffeur"}', '{}', 1030300, 3, 2, 1, '{}'),
  (1030401, 'SERVICE_TYPE', 'QUEUE_PICKUP', '{"zh": "排队/取物", "en": "Queue/Pickup"}', '{}', 1030400, 3, 1, 1, '{}');

-- 共享乐园 Share Park
INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1040100, 'SERVICE_TYPE', 'TOOL_RENTAL', '{"zh": "工具租赁", "en": "Tool Rental"}', '{}', 1040000, 2, 1, 1, '{"icon":"handyman"}'),
  (1040200, 'SERVICE_TYPE', 'SPACE_RENTAL', '{"zh": "空间租赁", "en": "Space Rental"}', '{}', 1040000, 2, 2, 1, '{"icon":"meeting_room"}'),
  (1040300, 'SERVICE_TYPE', 'KIDS_FAMILY', '{"zh": "儿童家庭", "en": "Kids & Family"}', '{}', 1040000, 2, 3, 1, '{"icon":"family_restroom"}'),
  (1040400, 'SERVICE_TYPE', 'ITEM_SHARE', '{"zh": "闲置共享", "en": "Item Share"}', '{}', 1040000, 2, 4, 1, '{"icon":"recycling"}'),
  (1040500, 'SERVICE_TYPE', 'SKILL_SWAP', '{"zh": "技能交换", "en": "Skill Swap"}', '{}', 1040000, 2, 5, 1, '{"icon":"swap_horiz"}'),
  (1040600, 'SERVICE_TYPE', 'FAMILY_TRAVEL_MANAGEMENT', '{"zh": "家庭旅管", "en": "Family Travel & Management"}', '{}', 1040000, 2, 6, 1, '{"icon":"travel_explore"}'),
  (1040700, 'SERVICE_TYPE', 'SHARE_PARK_OTHER', '{"zh": "其它", "en": "Other"}', '{}', 1040000, 2, 7, 1, '{"icon":"more_horiz"}');

INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1040101, 'SERVICE_TYPE', 'TOOL_RENTAL_TOOL', '{"zh": "工具租赁", "en": "Tool Rental"}', '{}', 1040100, 3, 1, 1, '{}'),
  (1040102, 'SERVICE_TYPE', 'TOOL_RENTAL_FURNITURE', '{"zh": "家具租赁", "en": "Furniture Rental"}', '{}', 1040100, 3, 2, 1, '{}'),
  (1040103, 'SERVICE_TYPE', 'TOOL_RENTAL_APPLIANCE', '{"zh": "家电租赁", "en": "Appliance Rental"}', '{}', 1040100, 3, 3, 1, '{}'),
  (1040104, 'SERVICE_TYPE', 'TOOL_RENTAL_PHOTO_3D', '{"zh": "摄影设备", "en": "Photo/3D Equip"}', '{}', 1040100, 3, 4, 1, '{}'),
  (1040201, 'SERVICE_TYPE', 'TEMP_OFFICE', '{"zh": "临时办公", "en": "Temp Office"}', '{}', 1040200, 3, 1, 1, '{}'),
  (1040202, 'SERVICE_TYPE', 'HOME_VENUE', '{"zh": "场地租赁", "en": "Home Venue"}', '{}', 1040200, 3, 2, 1, '{}'),
  (1040203, 'SERVICE_TYPE', 'STORAGE_RENTAL', '{"zh": "储物空间", "en": "Storage Rental"}', '{}', 1040200, 3, 3, 1, '{}'),
  (1040204, 'SERVICE_TYPE', 'HOUSE_RENTAL', '{"zh": "房屋租赁", "en": "House Rental"}', '{}', 1040200, 3, 4, 1, '{}'),
  (1040301, 'SERVICE_TYPE', 'KIDS_PLAY', '{"zh": "儿童游乐", "en": "Kids'' Play"}', '{}', 1040300, 3, 1, 1, '{}'),
  (1040302, 'SERVICE_TYPE', 'BABY_GEAR', '{"zh": "婴幼用品", "en": "Baby Gear"}', '{}', 1040300, 3, 2, 1, '{}'),
  (1040401, 'SERVICE_TYPE', 'ITEM_SHARE_SECOND_HAND_RENTAL', '{"zh": "闲置出租", "en": "Second-hand Rental"}', '{}', 1040400, 3, 1, 1, '{}'),
  (1040402, 'SERVICE_TYPE', 'ITEM_SHARE_SKILL_SWAP', '{"zh": "技能交换", "en": "Skill Swap"}', '{}', 1040400, 3, 2, 1, '{}'),
  (1040601, 'SERVICE_TYPE', 'FAMILY_TRIP_PLANNING', '{"zh": "家庭出游策划", "en": "Family Trip Planning"}', '{}', 1040600, 3, 1, 1, '{}'),
  (1040602, 'SERVICE_TYPE', 'FAMILY_GROUP_OUTING', '{"zh": "亲子游/团建", "en": "Family/Group Outing"}', '{}', 1040600, 3, 2, 1, '{}'),
  (1040603, 'SERVICE_TYPE', 'HOMESTAY_RENTAL', '{"zh": "旅居短租", "en": "Homestay/Short-term Rental"}', '{}', 1040600, 3, 3, 1, '{}');

-- 学习课堂 Learning Park
INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1050100, 'SERVICE_TYPE', 'TUTORING', '{"zh": "学科辅导", "en": "Tutoring"}', '{}', 1050000, 2, 1, 1, '{"icon":"menu_book"}'),
  (1050200, 'SERVICE_TYPE', 'ARTS_HOBBIES', '{"zh": "艺术兴趣", "en": "Arts & Hobbies"}', '{}', 1050000, 2, 2, 1, '{"icon":"palette"}'),
  (1050300, 'SERVICE_TYPE', 'SKILL_GROWTH', '{"zh": "技能提升", "en": "Skill Growth"}', '{}', 1050000, 2, 3, 1, '{"icon":"psychology"}'),
  (1050400, 'SERVICE_TYPE', 'EDU_SERVICES', '{"zh": "教育服务", "en": "Edu Services"}', '{}', 1050000, 2, 4, 1, '{"icon":"school"}'),
  (1050500, 'SERVICE_TYPE', 'LEARNING_PARK_OTHER', '{"zh": "其它", "en": "Other"}', '{}', 1050000, 2, 5, 1, '{"icon":"more_horiz"}');

INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1050101, 'SERVICE_TYPE', 'K12_COURSES', '{"zh": "K12课程", "en": "K-12 Courses"}', '{}', 1050100, 3, 1, 1, '{}'),
  (1050102, 'SERVICE_TYPE', 'ENGLISH_FRENCH', '{"zh": "英语/法语", "en": "English/French"}', '{}', 1050100, 3, 2, 1, '{}'),
  (1050103, 'SERVICE_TYPE', 'ONLINE_ONE_ON_ONE', '{"zh": "在线1对1", "en": "Online 1-on-1"}', '{}', 1050100, 3, 3, 1, '{}'),
  (1050201, 'SERVICE_TYPE', 'ARTS_CRAFTS', '{"zh": "美术手工", "en": "Arts & Crafts"}', '{}', 1050200, 3, 1, 1, '{}'),
  (1050202, 'SERVICE_TYPE', 'INSTRUMENT_VOCAL', '{"zh": "乐器声乐", "en": "Instrument/Vocal"}', '{}', 1050200, 3, 2, 1, '{}'),
  (1050203, 'SERVICE_TYPE', 'DANCE_THEATRE', '{"zh": "舞蹈戏剧", "en": "Dance/Theatre"}', '{}', 1050200, 3, 3, 1, '{}'),
  (1050301, 'SERVICE_TYPE', 'CODING_AI_DESIGN', '{"zh": "编程/AI/设计", "en": "Coding/AI/Design"}', '{}', 1050300, 3, 1, 1, '{}'),
  (1050302, 'SERVICE_TYPE', 'ADULT_HOBBY', '{"zh": "成人兴趣", "en": "Adult Hobby"}', '{}', 1050300, 3, 2, 1, '{}'),
  (1050303, 'SERVICE_TYPE', 'SKILL_TRAINING', '{"zh": "技能培训", "en": "Skill Training"}', '{}', 1050300, 3, 3, 1, '{}'),
  (1050401, 'SERVICE_TYPE', 'STUDY_ABROAD', '{"zh": "留学申请", "en": "Study Abroad"}', '{}', 1050400, 3, 1, 1, '{}'),
  (1050402, 'SERVICE_TYPE', 'IMMIGRATION_CONSULT', '{"zh": "移民咨询", "en": "Immigration Consult"}', '{}', 1050400, 3, 2, 1, '{}'),
  (1050403, 'SERVICE_TYPE', 'MENTAL_HEALTH', '{"zh": "心理教育", "en": "Mental Health"}', '{}', 1050400, 3, 3, 1, '{}');

-- 生活帮忙 Life Help
INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1060100, 'SERVICE_TYPE', 'SIMPLE_LABOR', '{"zh": "简单劳务", "en": "Simple Labor"}', '{}', 1060000, 2, 1, 1, '{"icon":"handyman"}'),
  (1060200, 'SERVICE_TYPE', 'PROFESSIONAL_SERVICES', '{"zh": "专业服务", "en": "Professional Services"}', '{}', 1060000, 2, 2, 1, '{"icon":"engineering"}'),
  (1060300, 'SERVICE_TYPE', 'CONSULTING', '{"zh": "咨询顾问", "en": "Consulting"}', '{}', 1060000, 2, 3, 1, '{"icon":"business"}'),
  (1060400, 'SERVICE_TYPE', 'HEALTH_SUPPORT', '{"zh": "健康支持", "en": "Health Support"}', '{}', 1060000, 2, 4, 1, '{"icon":"health_and_safety"}'),
  (1060500, 'SERVICE_TYPE', 'LIFE_HELP_OTHER', '{"zh": "其它", "en": "Other"}', '{}', 1060000, 2, 5, 1, '{"icon":"more_horiz"}');

INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data) VALUES
  (1060101, 'SERVICE_TYPE', 'MOVING_ASSEMBLY', '{"zh": "搬运安装", "en": "Moving/Assembly"}', '{}', 1060100, 3, 1, 1, '{}'),
  (1060102, 'SERVICE_TYPE', 'CAREGIVER', '{"zh": "护工陪护", "en": "Caregiver"}', '{}', 1060100, 3, 2, 1, '{}'),
  (1060103, 'SERVICE_TYPE', 'NANNY_HOUSEKEEPING', '{"zh": "保姆家政", "en": "Nanny/Housekeeping"}', '{}', 1060100, 3, 3, 1, '{}'),
  (1060201, 'SERVICE_TYPE', 'IT_SUPPORT', '{"zh": "IT支持", "en": "IT Support"}', '{}', 1060200, 3, 1, 1, '{}'),
  (1060202, 'SERVICE_TYPE', 'DESIGN', '{"zh": "设计服务", "en": "Design"}', '{}', 1060200, 3, 2, 1, '{}'),
  (1060203, 'SERVICE_TYPE', 'PHOTO_VIDEO', '{"zh": "摄影摄像", "en": "Photo/Video"}', '{}', 1060200, 3, 3, 1, '{}'),
  (1060204, 'SERVICE_TYPE', 'TRANSLATION_TYPESET', '{"zh": "翻译排版", "en": "Translation/Typeset"}', '{}', 1060200, 3, 4, 1, '{}'),
  (1060301, 'SERVICE_TYPE', 'REAL_ESTATE_AGENT', '{"zh": "房产中介", "en": "Real Estate Agent"}', '{}', 1060300, 3, 1, 1, '{}'),
  (1060302, 'SERVICE_TYPE', 'LOAN_INSURANCE', '{"zh": "贷款保险", "en": "Loan/Insurance"}', '{}', 1060300, 3, 2, 1, '{}'),
  (1060303, 'SERVICE_TYPE', 'TAX_ACCOUNTING', '{"zh": "税务会计", "en": "Tax/Accounting"}', '{}', 1060300, 3, 3, 1, '{}'),
  (1060304, 'SERVICE_TYPE', 'LEGAL', '{"zh": "法律咨询", "en": "Legal"}', '{}', 1060300, 3, 4, 1, '{}'),
  (1060401, 'SERVICE_TYPE', 'PHYSIO', '{"zh": "理疗服务", "en": "Physio"}', '{}', 1060400, 3, 1, 1, '{}'),
  (1060402, 'SERVICE_TYPE', 'CLINIC_ACCOMPANY', '{"zh": "陪诊服务", "en": "Clinic Accompany"}', '{}', 1060400, 3, 2, 1, '{}'),
  (1060403, 'SERVICE_TYPE', 'DAILY_CARE', '{"zh": "生活照护", "en": "Daily Care"}', '{}', 1060400, 3, 3, 1, '{}');