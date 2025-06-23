CREATE TABLE public.ref_codes (
    id BIGINT PRIMARY KEY,
    type_code VARCHAR(30) NOT NULL, -- 实体类型编码（如 SERVICE_TYPE、PROVIDER_TYPE）
    code VARCHAR(50) NOT NULL, -- 分类编码（同一类型下唯一）
    chinese_name VARCHAR(100) NOT NULL, -- 中文名称
    english_name VARCHAR(100) DEFAULT NULL, -- 英文名称
    parent_id BIGINT REFERENCES public.ref_codes(id) ON DELETE RESTRICT, -- 父节点ID（NULL 表示一级分类）
    level SMALLINT NOT NULL, -- 层级（1=一级，2=二级，3=三级）
    description VARCHAR(255) DEFAULT NULL, -- 分类描述
    sort_order INTEGER DEFAULT 0 NOT NULL, -- 排序序号
    status SMALLINT DEFAULT 1 NOT NULL, -- 状态（1=启用，0=禁用）
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL, -- 创建时间
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL, -- 更新时间
    extra_data JSONB DEFAULT '{}' NOT NULL, -- 额外数据（如图标、特定属性等）

    -- 确保在同一实体类型下，代码是唯一的
    CONSTRAINT uk_type_code_code UNIQUE (type_code, code)
);

-- 添加列注释 (PostgreSQL 方式)
COMMENT ON COLUMN public.ref_codes.id IS '主键ID';
COMMENT ON COLUMN public.ref_codes.type_code IS '实体类型编码（如 SERVICE_TYPE、PROVIDER_TYPE）';
COMMENT ON COLUMN public.ref_codes.code IS '分类编码（同一类型下唯一）';
COMMENT ON COLUMN public.ref_codes.chinese_name IS '中文名称';
COMMENT ON COLUMN public.ref_codes.english_name IS '英文名称';
COMMENT ON COLUMN public.ref_codes.parent_id IS '父节点ID（NULL 表示一级分类）';
COMMENT ON COLUMN public.ref_codes.level IS '层级（1=一级，2=二级，3=三级）';
COMMENT ON COLUMN public.ref_codes.description IS '分类描述';
COMMENT ON COLUMN public.ref_codes.sort_order IS '排序序号';
COMMENT ON COLUMN public.ref_codes.status IS '状态（1=启用，0=禁用）';
COMMENT ON COLUMN public.ref_codes.created_at IS '创建时间';
COMMENT ON COLUMN public.ref_codes.updated_at IS '更新时间';
COMMENT ON COLUMN public.ref_codes.extra_data IS '额外数据（如图标、特定属性等）';


-- 为常用查询字段创建索引，以优化查询性能
CREATE INDEX idx_ref_codes_type_parent ON public.ref_codes (type_code, parent_id);
CREATE INDEX idx_ref_codes_type_level ON public.ref_codes (type_code, level);
CREATE INDEX idx_ref_codes_status ON public.ref_codes (status);

-- 创建一个函数，用于在行更新时自动更新 updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为 ref_codes 表创建触发器
CREATE TRIGGER update_ref_codes_updated_at
BEFORE UPDATE ON public.ref_codes
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- 数据插入脚本

-- 顶级分类
INSERT INTO public.ref_codes (id, type_code, code, chinese_name, english_name, parent_id, level, sort_order, description, status, extra_data) VALUES
(1, 'SERVICE_TYPE', 'DINING', '餐饮美食', 'Dining', NULL, 1, 1, NULL, 1, '{"icon": "restaurant"}'),
(20, 'SERVICE_TYPE', 'HOME_SERVICES', '家居服务', 'Home Services', NULL, 1, 2, NULL, 1, '{"icon": "home"}'),
(40, 'SERVICE_TYPE', 'TRANSPORTATION', '出行交通', 'Transportation', NULL, 1, 3, NULL, 1, '{"icon": "directions_car"}'),
(55, 'SERVICE_TYPE', 'RENTAL_SHARE', '租赁共享', 'Rental & Share', NULL, 1, 4, NULL, 1, '{"icon": "share"}'),
(70, 'SERVICE_TYPE', 'LEARNING', '学习成长', 'Learning', NULL, 1, 5, NULL, 1, '{"icon": "school"}'),
(90, 'SERVICE_TYPE', 'PRO_GIGS', '专业速帮', 'Pro & Gigs', NULL, 1, 6, NULL, 1, '{"icon": "work"}');

-- 二级及三级分类 - 餐饮美食 Dining
INSERT INTO public.ref_codes (id, type_code, code, chinese_name, english_name, parent_id, level, sort_order, description, status, extra_data) VALUES
(2, 'SERVICE_TYPE', 'HOME_MEALS', '家庭餐', 'Home Meals', 1, 2, 1, NULL, 1, '{"icon": "home"}'),
(3, 'SERVICE_TYPE', 'HOME_KITCHEN', '家庭厨房', 'Home Kitchen', 2, 3, 1, NULL, 1, '{"icon": "kitchen"}'),
(4, 'SERVICE_TYPE', 'PRIVATE_CHEF', '私厨服务', 'Private Chef', 2, 3, 2, NULL, 1, '{"icon": "person"}'),
(5, 'SERVICE_TYPE', 'HOMESTYLE_DELIVERY', '家常菜配送', 'Homestyle Delivery', 2, 3, 3, NULL, 1, '{"icon": "delivery_dining"}'),
(6, 'SERVICE_TYPE', 'CUSTOM_CATERING', '美食定制', 'Custom Catering', 1, 2, 2, NULL, 1, '{"icon": "cake"}'),
(7, 'SERVICE_TYPE', 'GATHERING_MEALS', '聚会宴席', 'Gathering Meals', 6, 3, 1, NULL, 1, '{"icon": "groups"}'),
(8, 'SERVICE_TYPE', 'CAKE_CUSTOM', '蛋糕定制', 'Cake Custom', 6, 3, 2, NULL, 1, '{"icon": "cake"}'),
(9, 'SERVICE_TYPE', 'BREAKFAST_BENTO', '早餐便当', 'Breakfast Bento', 6, 3, 3, NULL, 1, '{"icon": "breakfast_dining"}'),
(10, 'SERVICE_TYPE', 'DIVERSE_DINING', '餐饮多样', 'Diverse Dining', 1, 2, 3, NULL, 1, '{"icon": "diversity_3"}'),
(11, 'SERVICE_TYPE', 'ASIAN_CUISINE', '中餐/韩餐/东南亚餐', 'Chinese/Korean/SEA Cuisine', 10, 3, 1, NULL, 1, '{"icon": "ramen_dining"}'),
(12, 'SERVICE_TYPE', 'COFFEE_TEA', '咖啡茶饮', 'Coffee & Tea', 10, 3, 2, NULL, 1, '{"icon": "local_cafe"}'),
(13, 'SERVICE_TYPE', 'EXOTIC_FOOD', '异国料理', 'Exotic Food', 10, 3, 3, NULL, 1, '{"icon": "restaurant_menu"}'),
(15, 'SERVICE_TYPE', 'GROCERY_DELIVERY', '食材代购配送', 'Grocery Shop&Delivery', 1, 2, 4, NULL, 1, '{"icon": "shopping_cart"}'),
(16, 'SERVICE_TYPE', 'FOOD_DELIVERY', '餐饮配送', 'Food Delivery', 1, 2, 5, NULL, 1, '{"icon": "delivery_dining"}');

-- 二级及三级分类 - 家居服务 Home Services
INSERT INTO public.ref_codes (id, type_code, code, chinese_name, english_name, parent_id, level, sort_order, description, status, extra_data) VALUES
(21, 'SERVICE_TYPE', 'CLEANING', '清洁维护', 'Cleaning', 20, 2, 1, NULL, 1, '{"icon": "cleaning_services"}'),
(22, 'SERVICE_TYPE', 'HOME_CLEAN', '居家清洁', 'Home Clean', 21, 3, 1, NULL, 1, '{"icon": "cleaning_services"}'),
(23, 'SERVICE_TYPE', 'POST_RENO_CLEAN', '装修清洁', 'Post-Reno Clean', 21, 3, 2, NULL, 1, '{"icon": "construction"}'),
(24, 'SERVICE_TYPE', 'DEEP_CLEAN', '深度清洁', 'Deep Clean', 21, 3, 3, NULL, 1, '{"icon": "cleaning_services"}'),
(25, 'SERVICE_TYPE', 'PLUMBING', '管道疏通', 'Plumbing', 21, 3, 4, NULL, 1, '{"icon": "plumbing"}'),
(26, 'SERVICE_TYPE', 'FURNITURE', '家具安装', 'Furniture', 20, 2, 2, NULL, 1, '{"icon": "chair"}'),
(27, 'SERVICE_TYPE', 'FURNITURE_ASSM', '家具安装', 'Furniture Assm', 26, 3, 1, NULL, 1, '{"icon": "build"}'),
(28, 'SERVICE_TYPE', 'WALL_REPAIR', '墙修/涂刷', 'Wall Repair/Paint', 26, 3, 2, NULL, 1, '{"icon": "format_paint"}'),
(29, 'SERVICE_TYPE', 'APPLIANCE_INSTALL', '家电装/修', 'Appliance Install/Repair', 26, 3, 3, NULL, 1, '{"icon": "electrical_services"}'),
(30, 'SERVICE_TYPE', 'GARDENING', '园艺户外', 'Gardening', 20, 2, 3, NULL, 1, '{"icon": "landscape"}'),
(31, 'SERVICE_TYPE', 'LAWN_MOWING', '割草修剪', 'Lawn Mowing', 30, 3, 1, NULL, 1, '{"icon": "grass"}'),
(32, 'SERVICE_TYPE', 'GARDEN_MAIN', '园艺维护', 'Garden Main', 30, 3, 2, NULL, 1, '{"icon": "park"}'),
(33, 'SERVICE_TYPE', 'SNOW_REMOVAL', '铲雪服务', 'Snow Removal', 30, 3, 3, NULL, 1, '{"icon": "ac_unit"}'),
(34, 'SERVICE_TYPE', 'PET_CARE', '宠物服务', 'Pet Care', 20, 2, 4, NULL, 1, '{"icon": "pets"}'),
(35, 'SERVICE_TYPE', 'PET_SIT', '宠物照料', 'Pet Sit', 34, 3, 1, NULL, 1, '{"icon": "pets"}'),
(36, 'SERVICE_TYPE', 'DOG_WALK', '遛宠', 'Dog Walk', 34, 3, 2, NULL, 1, '{"icon": "directions_walk"}'),
(37, 'SERVICE_TYPE', 'REAL_ESTATE', '房产空间', 'Real Estate', 20, 2, 5, NULL, 1, '{"icon": "home_work"}'),
(38, 'SERVICE_TYPE', 'REAL_ESTATE_AGENT', '房屋经纪', 'Real Estate', 37, 3, 1, NULL, 1, '{"icon": "real_estate_agent"}'),
(39, 'SERVICE_TYPE', 'HOME_ENTERTAINMENT', '家庭娱乐', 'Home Entertainment', 37, 3, 2, NULL, 1, '{"icon": "sports_esports"}');

-- 二级及三级分类 - 出行交通 Transportation
INSERT INTO public.ref_codes (id, type_code, code, chinese_name, english_name, parent_id, level, sort_order, description, status, extra_data) VALUES
(41, 'SERVICE_TYPE', 'DAILY_SHUTTLE', '日常接送', 'Daily Shuttle', 40, 2, 1, NULL, 1, '{"icon": "airport_shuttle"}'),
(42, 'SERVICE_TYPE', 'AIRPORT_TRANSFER', '机场接送', 'Airport Transfer', 41, 3, 1, NULL, 1, '{"icon": "flight"}'),
(43, 'SERVICE_TYPE', 'SCHOOL_SHUTTLE', '学校接送', 'School Shuttle', 41, 3, 2, NULL, 1, '{"icon": "school"}'),
(44, 'SERVICE_TYPE', 'CARPOOLING', '拼车', 'Carpooling', 41, 3, 3, NULL, 1, '{"icon": "group"}'),
(45, 'SERVICE_TYPE', 'COURIER_SHOP', '快递代购', 'Courier & Shop', 40, 2, 2, NULL, 1, '{"icon": "local_shipping"}'),
(46, 'SERVICE_TYPE', 'SAME_CITY_COURIER', '同城快递', 'Same-City Courier', 45, 3, 1, NULL, 1, '{"icon": "local_shipping"}'),
(47, 'SERVICE_TYPE', 'PACKAGE_SERVICE', '包裹代收寄', 'Package Service', 45, 3, 2, NULL, 1, '{"icon": "inventory_2"}'),
(48, 'SERVICE_TYPE', 'SHOPPING_SERVICE', '代购', 'Local/IntShop', 45, 3, 3, NULL, 1, '{"icon": "shopping_bag"}'),
(49, 'SERVICE_TYPE', 'MOVING', '移动搬运', 'Moving', 40, 2, 3, NULL, 1, '{"icon": "move_to_inbox"}'),
(50, 'SERVICE_TYPE', 'MOVING_SERVICE', '搬家', 'Moving', 49, 3, 1, NULL, 1, '{"icon": "home"}'),
(51, 'SERVICE_TYPE', 'CHAUFFEUR', '代驾', 'Chauffeur', 49, 3, 2, NULL, 1, '{"icon": "drive_eta"}'),
(52, 'SERVICE_TYPE', 'ERRANDS', '跑腿', 'Errands', 40, 2, 4, NULL, 1, '{"icon": "directions_run"}'),
(53, 'SERVICE_TYPE', 'QUEUE_PICKUP', '代办(排队/领物)', 'Errands (Queue/Pickup)', 52, 3, 1, NULL, 1, '{"icon": "queue"}');

-- 二级及三级分类 - 租赁共享 Rental & Share
INSERT INTO public.ref_codes (id, type_code, code, chinese_name, english_name, parent_id, level, sort_order, description, status, extra_data) VALUES
(56, 'SERVICE_TYPE', 'TOOLS_EQUIP', '工具设备', 'Tools & Equip', 55, 2, 1, NULL, 1, '{"icon": "build"}'),
(57, 'SERVICE_TYPE', 'TOOL_RENTAL', '工具租赁', 'Tool Rental', 56, 3, 1, NULL, 1, '{"icon": "handyman"}'),
(58, 'SERVICE_TYPE', 'APPLIANCE_RENTAL', '家电租赁', 'Appliance Rental', 56, 3, 2, NULL, 1, '{"icon": "electrical_services"}'),
(59, 'SERVICE_TYPE', 'PHOTO_3D_EQUIP', '摄影/3D设备', 'Photo/3D Equip', 56, 3, 3, NULL, 1, '{"icon": "camera_alt"}'),
(60, 'SERVICE_TYPE', 'SPACE_SHARE', '空间共享', 'Space Share', 55, 2, 2, NULL, 1, '{"icon": "space_dashboard"}'),
(61, 'SERVICE_TYPE', 'TEMP_OFFICE', '临时办公', 'Temp Office', 60, 3, 1, NULL, 1, '{"icon": "work"}'),
(62, 'SERVICE_TYPE', 'HOME_VENUE', '家庭场地', 'Home Venue', 60, 3, 2, NULL, 1, '{"icon": "home"}'),
(63, 'SERVICE_TYPE', 'STORAGE_RENTAL', '储物租赁', 'Storage Rental', 60, 3, 3, NULL, 1, '{"icon": "storage"}'),
(64, 'SERVICE_TYPE', 'KIDS_FAMILY', '儿童家庭', 'Kids & Family', 55, 2, 3, NULL, 1, '{"icon": "family_restroom"}'),
(65, 'SERVICE_TYPE', 'KIDS_PLAY', '儿童游乐', 'Kids\Play', 64, 3, 1, NULL, 1, '{"icon": "child_care"}'),
(66, 'SERVICE_TYPE', 'BABY_GEAR', '婴幼用品', 'Baby Gear', 64, 3, 2, NULL, 1, '{"icon": "baby_changing_station"}'),
(67, 'SERVICE_TYPE', 'ITEM_SHARE', '物品共享', 'Item Share', 55, 2, 4, NULL, 1, '{"icon": "share"}'),
(68, 'SERVICE_TYPE', 'SECOND_HAND_RENTAL', '闲置租借', 'Second-hand Rental', 67, 3, 1, NULL, 1, '{"icon": "recycling"}');

-- 二级及三级分类 - 学习成长 Learning
INSERT INTO public.ref_codes (id, type_code, code, chinese_name, english_name, parent_id, level, sort_order, description, status, extra_data) VALUES
(71, 'SERVICE_TYPE', 'ACADEMIC_TUTORING', '学科辅导', 'Academic Tutoring', 70, 2, 1, NULL, 1, '{"icon": "menu_book"}'),
(72, 'SERVICE_TYPE', 'K12_COURSES', '小初高课程', 'K-12 Courses', 71, 3, 1, NULL, 1, '{"icon": "school"}'),
(73, 'SERVICE_TYPE', 'LANGUAGE_COURSES', '英语/法语', 'English/French', 71, 3, 2, NULL, 1, '{"icon": "language"}'),
(74, 'SERVICE_TYPE', 'ONLINE_TUTORING', '在线1对1', 'Online 1-on-1', 71, 3, 3, NULL, 1, '{"icon": "video_camera_front"}'),
(75, 'SERVICE_TYPE', 'ART_HOBBY', '艺术兴趣', 'Art & Hobby', 70, 2, 2, NULL, 1, '{"icon": "palette"}'),
(76, 'SERVICE_TYPE', 'ART_CRAFTS', '美术手工', 'Art & Crafts', 75, 3, 1, NULL, 1, '{"icon": "brush"}'),
(77, 'SERVICE_TYPE', 'MUSIC_VOCAL', '乐器/声乐', 'Instrument/Vocal', 75, 3, 2, NULL, 1, '{"icon": "music_note"}'),
(78, 'SERVICE_TYPE', 'DANCE_THEATRE', '舞蹈/戏剧', 'Dance/Theatre', 75, 3, 3, NULL, 1, '{"icon": "theater_comedy"}'),
(79, 'SERVICE_TYPE', 'SKILL_GROWTH', '技能成长', 'Skill Growth', 70, 2, 3, NULL, 1, '{"icon": "psychology"}'),
(80, 'SERVICE_TYPE', 'TECH_SKILLS', '编程/AI/设计', 'Coding/AI/Design', 79, 3, 1, NULL, 1, '{"icon": "code"}'),
(81, 'SERVICE_TYPE', 'ADULT_HOBBY', '成人兴趣班', 'Adult Hobby', 79, 3, 2, NULL, 1, '{"icon": "emoji_events"}'),
(82, 'SERVICE_TYPE', 'SKILL_TRAINING', '技能培训', 'Skill Training', 79, 3, 3, NULL, 1, '{"icon": "workspace_premium"}'),
(83, 'SERVICE_TYPE', 'EDU_SERVICES', '教育服务', 'Edu Services', 70, 2, 4, NULL, 1, '{"icon": "school"}'),
(84, 'SERVICE_TYPE', 'STUDY_ABROAD', '留学申请', 'Study Abroad Apps', 83, 3, 1, NULL, 1, '{"icon": "flight_takeoff"}'),
(85, 'SERVICE_TYPE', 'IMMIGRATION', '移民咨询', 'Immigration Consult', 83, 3, 2, NULL, 1, '{"icon": "people"}'),
(86, 'SERVICE_TYPE', 'MENTAL_HEALTH', '心理教育', 'Mental Health Edu', 83, 3, 3, NULL, 1, '{"icon": "psychology"}');

-- 二级及三级分类 - 专业速帮 Pro & Gigs
INSERT INTO public.ref_codes (id, type_code, code, chinese_name, english_name, parent_id, level, sort_order, description, status, extra_data) VALUES
(91, 'SERVICE_TYPE', 'SIMPLE_LABOR', '简单劳务', 'Simple Labor', 90, 2, 1, NULL, 1, '{"icon": "handyman"}'),
(92, 'SERVICE_TYPE', 'HELP_MOVING', '搬物/安装', 'Help Moving/Assm', 91, 3, 1, NULL, 1, '{"icon": "move_to_inbox"}'),
(93, 'SERVICE_TYPE', 'CAREGIVER', '护工/陪护', 'Caregiver', 91, 3, 2, NULL, 1, '{"icon": "health_and_safety"}'),
(94, 'SERVICE_TYPE', 'NANNY', '保姆/家政', 'Nanny/Housekeeping', 91, 3, 3, NULL, 1, '{"icon": "cleaning_services"}'),
(95, 'SERVICE_TYPE', 'PRO_SERVICES', '专业服务', 'Pro Services', 90, 2, 2, NULL, 1, '{"icon": "computer"}'),
(96, 'SERVICE_TYPE', 'IT_SUPPORT', 'IT支持', 'IT Support', 95, 3, 1, NULL, 1, '{"icon": "support_agent"}'),
(97, 'SERVICE_TYPE', 'DESIGN_SERVICES', '平面/视频设计', 'Graphic/Video Design', 95, 3, 2, NULL, 1, '{"icon": "design_services"}'),
(98, 'SERVICE_TYPE', 'PHOTO_VIDEO', '摄影摄像', 'Photo&Video', 95, 3, 3, NULL, 1, '{"icon": "camera_alt"}'),
(99, 'SERVICE_TYPE', 'TRANSLATION', '翻译/排版', 'Trans/Typeset', 95, 3, 4, NULL, 1, '{"icon": "translate"}'),
(100, 'SERVICE_TYPE', 'CONSULTING', '咨询顾问', 'Consulting', 90, 2, 3, NULL, 1, '{"icon": "business"}'),
(101, 'SERVICE_TYPE', 'REAL_ESTATE_CONSULT', '房产中介', 'Real Estate', 100, 3, 1, NULL, 1, '{"icon": "home_work"}'),
(102, 'SERVICE_TYPE', 'FINANCIAL_CONSULT', '贷款/保险', 'Loan/Insurance', 100, 3, 2, NULL, 1, '{"icon": "account_balance"}'),
(103, 'SERVICE_TYPE', 'TAX_ACCOUNTING', '税务/会计', 'Tax/Accounting', 100, 3, 3, NULL, 1, '{"icon": "calculate"}'),
(104, 'SERVICE_TYPE', 'LEGAL_CONSULT', '法律咨询', 'Legal', 100, 3, 4, NULL, 1, '{"icon": "gavel"}'),
(105, 'SERVICE_TYPE', 'HEALTH_SUPPORT', '健康支持', 'Health Support', 90, 2, 4, NULL, 1, '{"icon": "health_and_safety"}'),
(106, 'SERVICE_TYPE', 'PHYSIO', '理疗', 'Physio', 105, 3, 1, NULL, 1, '{"icon": "healing"}'),
(107, 'SERVICE_TYPE', 'CLINIC_ACCOMPANY', '陪诊', 'Clinic Accompany', 105, 3, 2, NULL, 1, '{"icon": "medical_services"}'),
(108, 'SERVICE_TYPE', 'DAILY_CARE', '生活照护', 'Daily Care', 105, 3, 3, NULL, 1, '{"icon": "health_and_safety"}');

-- 二级 '其它' 分类 (新添加)
INSERT INTO public.ref_codes (id, type_code, code, chinese_name, english_name, parent_id, level, sort_order, description, status, extra_data) VALUES
(121, 'SERVICE_TYPE', 'OTHER_DINING', '其它餐饮美食', 'Other Dining', 1, 2, 6, NULL, 1, '{"icon": "more_horiz"}'),
(122, 'SERVICE_TYPE', 'OTHER_HOME_SERVICES', '其它家居服务', 'Other Home Services', 20, 2, 6, NULL, 1, '{"icon": "more_horiz"}'),
(123, 'SERVICE_TYPE', 'OTHER_TRANSPORTATION', '其它出行交通', 'Other Transportation', 40, 2, 5, NULL, 1, '{"icon": "more_horiz"}'),
(124, 'SERVICE_TYPE', 'OTHER_RENTAL_SHARE', '其它租赁共享', 'Other Rental & Share', 55, 2, 5, NULL, 1, '{"icon": "more_horiz"}'),
(125, 'SERVICE_TYPE', 'OTHER_LEARNING', '其它学习成长', 'Other Learning', 70, 2, 5, NULL, 1, '{"icon": "more_horiz"}'),
(126, 'SERVICE_TYPE', 'OTHER_PRO_GIGS', '其它专业速帮', 'Other Pro & Gigs', 90, 2, 5, NULL, 1, '{"icon": "more_horiz"}'); 