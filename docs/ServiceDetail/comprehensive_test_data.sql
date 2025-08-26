-- =====================================================
-- JinBean Platform - Comprehensive Test Data Script
-- Service_Details 重构后完整测试数据
-- 包含：餐饮、家政、租赁、教育、交通、医疗、专业速帮
-- =====================================================

-- 清理现有测试数据（可选）
-- DELETE FROM service_details WHERE service_id LIKE 'test-%';
-- DELETE FROM services WHERE id LIKE 'test-%';
-- DELETE FROM providers WHERE id LIKE 'provider-%';

-- =====================================================
-- 1. 创建服务提供商数据
-- =====================================================

INSERT INTO provider_profiles (id, display_name, provider_type, email, phone, status, created_at, updated_at) VALUES
-- 餐饮服务提供商
(
    'provider-001',
    '{"en": "Bella Italia Restaurant", "zh": "贝拉意大利餐厅", "fr": "Restaurant Bella Italia"}',
    'business',
    'info@bellaitalia.com',
    '+1-416-555-0101',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'provider-002',
    '{"en": "Golden Dragon Chinese Restaurant", "zh": "金龙中餐厅", "fr": "Restaurant Chinois Golden Dragon"}',
    'business',
    'info@goldendragon.com',
    '+1-416-555-0102',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 家政服务提供商
(
    'provider-003',
    '{"en": "CleanPro Services", "zh": "清洁专家服务", "fr": "Services CleanPro"}',
    'business',
    'info@cleanpro.com',
    '+1-416-555-0103',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 租赁服务提供商
(
    'provider-004',
    '{"en": "ToolRent Pro", "zh": "专业工具租赁", "fr": "Location d''Outils Pro"}',
    'business',
    'info@toolrentpro.com',
    '+1-416-555-0104',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 教育服务提供商
(
    'provider-005',
    '{"en": "CodeAcademy Pro", "zh": "专业编程学院", "fr": "Académie de Code Pro"}',
    'business',
    'info@codeacademypro.com',
    '+1-416-555-0105',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 交通服务提供商
(
    'provider-006',
    '{"en": "Luxury Transport Services", "zh": "奢华运输服务", "fr": "Services de Transport de Luxe"}',
    'business',
    'info@luxurytransport.com',
    '+1-416-555-0106',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 医疗服务提供商
(
    'provider-007',
    '{"en": "Advanced Therapy Clinic", "zh": "高级治疗诊所", "fr": "Clinique de Thérapie Avancée"}',
    'business',
    'info@advancedtherapy.com',
    '+1-416-555-0107',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 专业速帮服务提供商
(
    'provider-008',
    '{"en": "TechPro Solutions", "zh": "科技专家解决方案", "fr": "Solutions TechPro"}',
    'business',
    'info@techprosolutions.com',
    '+1-416-555-0108',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'provider-009',
    '{"en": "QuickFix Appliance Repair", "zh": "快速修复家电维修", "fr": "Réparation Rapide d''Appareils"}',
    'business',
    'info@quickfixrepair.com',
    '+1-416-555-0109',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'provider-010',
    '{"en": "DesignStudio Pro", "zh": "专业设计工作室", "fr": "Studio de Design Pro"}',
    'business',
    'info@designstudiopro.com',
    '+1-416-555-0110',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'provider-011',
    '{"en": "LegalAdvice Pro", "zh": "专业法律咨询", "fr": "Conseil Juridique Pro"}',
    'business',
    'info@legaladvicepro.com',
    '+1-416-555-0111',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'provider-012',
    '{"en": "FinancialAdvisor Pro", "zh": "专业财务顾问", "fr": "Conseiller Financier Pro"}',
    'financial_consulting',
    'info@financialadvisorpro.com',
    '+1-416-555-0112',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. 创建services主表数据
-- =====================================================

INSERT INTO services (id, title, description, category_level1_id, category_level2_id, provider_id, status, average_rating, review_count, latitude, longitude, service_delivery_method, created_at, updated_at) VALUES
-- 餐饮服务
(
    'restaurant-001',
    '{"en": "Bella Italia Restaurant", "zh": "贝拉意大利餐厅", "fr": "Restaurant Bella Italia"}',
    'Authentic Italian cuisine with traditional recipes and modern presentation. Specializing in pasta, pizza, and regional specialties.',
    '1010000',  -- 餐饮服务
    '1010100',  -- 餐厅
    'provider-001',
    'active',
    4.8,
    156,
    43.6532,
    -79.3832,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'restaurant-002',
    '{"en": "Golden Dragon Chinese Restaurant", "zh": "金龙中餐厅", "fr": "Restaurant Chinois Golden Dragon"}',
    'Authentic Chinese cuisine featuring Cantonese and Sichuan specialties. Family-owned restaurant with over 20 years of experience.',
    '1010000',  -- 餐饮服务
    '1010100',  -- 餐厅
    'provider-002',
    'active',
    4.6,
    89,
    43.6545,
    -79.3801,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 家政服务
(
    'cleaning-001',
    '{"en": "Premium Home Cleaning Service", "zh": "优质家庭清洁服务", "fr": "Service de Nettoyage Premium"}',
    'Professional home cleaning with eco-friendly products and guaranteed satisfaction. Licensed, bonded, and insured cleaning professionals.',
    '1020000',  -- 家政服务
    '1020100',  -- 清洁服务
    'provider-003',
    'active',
    4.9,
    234,
    43.6520,
    -79.3845,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 共享租赁服务
(
    'rental-001',
    '{"en": "Professional Power Tools Rental", "zh": "专业电动工具租赁", "fr": "Location d''Outils Électriques Professionnels"}',
    'High-quality power tools for DIY projects and professional use. Well-maintained equipment with flexible rental terms.',
    '1040000',  -- 共享租赁
    '1040100',  -- 设备租赁
    'provider-004',
    'active',
    4.7,
    78,
    43.6538,
    -79.3810,
    'pickup',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 教育培训服务
(
    'education-001',
    '{"en": "Full-Stack Programming Bootcamp", "zh": "全栈编程训练营", "fr": "Bootcamp de Programmation Full-Stack"}',
    'Comprehensive programming course covering frontend, backend, and database development. Industry-experienced instructors with hands-on projects.',
    '1050000',  -- 教育培训
    '1050100',  -- 技能培训
    'provider-005',
    'active',
    4.8,
    145,
    43.6515,
    -79.3850,
    'online',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 交通出行服务
(
    'transport-001',
    '{"en": "Premium Airport Transfer Service", "zh": "优质机场接送服务", "fr": "Service de Transfert Aéroport Premium"}',
    'Reliable airport transportation with professional drivers and luxury vehicles. Flight monitoring and flexible scheduling available.',
    '1030000',  -- 交通出行
    '1030100',  -- 接送服务
    'provider-006',
    'active',
    4.9,
    203,
    43.6540,
    -79.3820,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 健康医疗服务
(
    'health-001',
    '{"en": "Advanced Physical Therapy Clinic", "zh": "高级物理治疗诊所", "fr": "Clinique de Physiothérapie Avancée"}',
    'Comprehensive physical therapy services with certified therapists. Modern equipment and personalized treatment plans.',
    '1060000',  -- 健康医疗
    '1060100',  -- 物理治疗
    'provider-007',
    'active',
    4.8,
    167,
    43.6525,
    -79.3835,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 专业速帮服务
(
    'tech-support-001',
    '{"en": "Professional IT Support & Consulting", "zh": "专业IT技术支持与咨询", "fr": "Support et Conseil IT Professionnel"}',
    'Expert IT support for businesses and individuals. Network setup, system maintenance, cybersecurity, and digital transformation consulting.',
    '1060000',  -- 技术服务
    '1060100',  -- IT支持
    'provider-008',
    'active',
    4.9,
    189,
    43.6535,
    -79.3815,
    'hybrid',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'appliance-repair-001',
    '{"en": "Expert Appliance Repair Service", "zh": "专业家电维修服务", "fr": "Service de Réparation d''Appareils Expert"}',
    'Professional repair service for all major appliances. Same-day service available for urgent repairs. Licensed and insured technicians.',
    '1020000',  -- 家政服务
    '1020200',  -- 维修服务
    'provider-009',
    'active',
    4.7,
    156,
    43.6528,
    -79.3842,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'interior-design-001',
    '{"en": "Creative Interior Design Studio", "zh": "创意室内设计工作室", "fr": "Studio de Design d''Intérieur Créatif"}',
    'Professional interior design services for residential and commercial spaces. 3D visualization, project management, and turnkey solutions.',
    '1060000',  -- 技术服务
    '1060200',  -- 设计服务
    'provider-010',
    'active',
    4.8,
    134,
    43.6542,
    -79.3825,
    'hybrid',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'legal-consulting-001',
    '{"en": "Professional Legal Consulting", "zh": "专业法律咨询", "fr": "Conseil Juridique Professionnel"}',
    'Expert legal advice for individuals and businesses. Specializing in business law, employment law, and contract review.',
    '1060000',  -- 技术服务
    '1060300',  -- 咨询服务
    'provider-011',
    'active',
    4.9,
    98,
    43.6530,
    -79.3838,
    'hybrid',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'financial-consulting-001',
    '{"en": "Expert Financial Advisory Services", "zh": "专业财务咨询服务", "fr": "Services de Conseil Financier Expert"}',
    'Comprehensive financial planning, tax preparation, and business consulting. Certified financial planners and tax professionals.',
    '1060000',  -- 技术服务
    '1060300',  -- 咨询服务
    'provider-012',
    'active',
    4.8,
    167,
    43.6548,
    -79.3818,
    'hybrid',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 3. 创建service_details详情数据
-- =====================================================

-- 餐饮服务详情
INSERT INTO service_details (id, service_id, category, name, description, pricing_type, price, currency, sub_category, is_available, sort_order, attributes, business_rules) VALUES
-- 意大利餐厅主服务
(
    gen_random_uuid(),
    'restaurant-001',
    'main',
    '{"en": "Bella Italia Restaurant", "zh": "贝拉意大利餐厅", "fr": "Restaurant Bella Italia"}',
    'Authentic Italian cuisine with traditional recipes and modern presentation',
    'fixed_price',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"cuisine_type": "italian", "dress_code": "smart_casual", "parking": true, "delivery": true, "takeout": true}',
    '{"reservation_required": false, "min_party_size": 1, "max_party_size": 20, "cancellation_policy": "2_hours"}'
),
-- 意大利餐厅菜单项目
(
    gen_random_uuid(),
    'restaurant-001',
    'menu_item',
    '{"en": "Bruschetta al Pomodoro", "zh": "番茄面包片", "fr": "Bruschetta aux Tomates"}',
    'Toasted bread topped with fresh tomatoes, basil, and olive oil',
    'fixed_price',
    8.99,
    'CAD',
    'appetizer',
    true,
    1,
    '{"vegetarian": true, "vegan": true, "gluten_free": false, "spicy": false, "calories": 120, "allergens": ["gluten"]}',
    '{"preparation_time": "10_min", "seasonal": false, "chef_special": false}'
),
(
    gen_random_uuid(),
    'restaurant-001',
    'menu_item',
    '{"en": "Spaghetti alla Carbonara", "zh": "奶油培根意面", "fr": "Spaghetti à la Carbonara"}',
    'Classic pasta with eggs, cheese, pancetta, and black pepper',
    'fixed_price',
    22.99,
    'CAD',
    'main_course',
    true,
    2,
    '{"vegetarian": false, "vegan": false, "gluten_free": false, "spicy": false, "calories": 650, "allergens": ["gluten", "dairy", "eggs"]}',
    '{"preparation_time": "15_min", "seasonal": false, "chef_special": false}'
),
-- 中餐厅主服务
(
    gen_random_uuid(),
    'restaurant-002',
    'main',
    '{"en": "Golden Dragon Chinese Restaurant", "zh": "金龙中餐厅", "fr": "Restaurant Chinois Golden Dragon"}',
    'Authentic Chinese cuisine featuring Cantonese and Sichuan specialties',
    'fixed_price',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"cuisine_type": "chinese", "dress_code": "casual", "parking": true, "delivery": true, "takeout": true}',
    '{"reservation_required": false, "min_party_size": 1, "max_party_size": 30, "cancellation_policy": "1_hour"}'
),
-- 中餐厅套餐
(
    gen_random_uuid(),
    'restaurant-002',
    'menu_item',
    '{"en": "Family Feast Package", "zh": "家庭盛宴套餐", "fr": "Pack Festin Familial"}',
    'Complete meal for 4-6 people including appetizers, main dishes, and dessert',
    'fixed_price',
    89.99,
    'CAD',
    'package',
    true,
    1,
    '{"vegetarian": false, "vegan": false, "gluten_free": false, "spicy": "medium", "calories": 2800, "serves": "4-6_people"}',
    '{"preparation_time": "30_min", "advance_order": "2_hours", "chef_special": true}'
),

-- 家政服务详情
-- 清洁服务主服务
(
    gen_random_uuid(),
    'cleaning-001',
    'main',
    '{"en": "Premium Home Cleaning Service", "zh": "优质家庭清洁服务", "fr": "Service de Nettoyage Premium"}',
    'Professional home cleaning with eco-friendly products and guaranteed satisfaction',
    'fixed_price',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"service_type": "cleaning", "eco_friendly": true, "insured": true, "bonded": true}',
    '{"advance_booking": "24_hours", "cancellation_policy": "4_hours", "satisfaction_guarantee": true}'
),
-- 清洁服务项目
(
    gen_random_uuid(),
    'cleaning-001',
    'service_item',
    '{"en": "Deep Cleaning", "zh": "深度清洁", "fr": "Nettoyage en Profondeur"}',
    'Comprehensive cleaning including all rooms, appliances, and hard-to-reach areas',
    'fixed_price',
    120.00,
    'CAD',
    'deep_cleaning',
    true,
    1,
    '{"duration": "3-4_hours", "team_size": "2_people", "includes": ["kitchen", "bathrooms", "bedrooms", "living_areas"]}',
    '{"min_notice": "24_hours", "max_house_size": "3000_sqft", "eco_products": true}'
),
(
    gen_random_uuid(),
    'cleaning-001',
    'service_item',
    '{"en": "Regular Maintenance", "zh": "定期维护", "fr": "Maintenance Régulière"}',
    'Weekly or bi-weekly cleaning to maintain home cleanliness',
    'subscription',
    80.00,
    'CAD',
    'maintenance',
    true,
    2,
    '{"duration": "2-3_hours", "team_size": "1_person", "frequency": "weekly_biweekly"}',
    '{"subscription_discount": "15_percent", "flexible_scheduling": true, "eco_products": true}'
),

-- 共享租赁详情
-- 工具租赁主服务
(
    gen_random_uuid(),
    'rental-001',
    'main',
    '{"en": "Professional Power Tools Rental", "zh": "专业电动工具租赁", "fr": "Location d''Outils Électriques Professionnels"}',
    'High-quality power tools for DIY projects and professional use',
    'rental',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"tool_category": "power_tools", "professional_grade": true, "maintenance": "weekly"}',
    '{"min_rental": "1_day", "max_rental": "30_days", "deposit_required": true, "insurance_required": true}'
),
-- 租赁物品
(
    gen_random_uuid(),
    'rental-001',
    'rental_item',
    '{"en": "Cordless Drill Set", "zh": "无线电钻套装", "fr": "Perceuse Visseuse Sans Fil"}',
    'Professional 20V cordless drill with battery and charger',
    'rental',
    25.00,
    'CAD',
    'drills',
    true,
    1,
    5,
    10,
    '{"power": "20V", "battery_included": true, "weight": "2.5_kg", "condition": "excellent"}',
    '{"rental_unit": "day", "min_rental": "1_day", "deposit": 50, "insurance": 10}'
),
(
    gen_random_uuid(),
    'rental-001',
    'rental_item',
    '{"en": "Circular Saw", "zh": "圆锯", "fr": "Scie Circulaire"}',
    'Heavy-duty circular saw for cutting wood and other materials',
    'rental',
    35.00,
    'CAD',
    'saws',
    true,
    2,
    3,
    8,
    '{"blade_size": "7.25_inch", "power": "15A", "weight": "4.2_kg", "condition": "good"}',
    '{"rental_unit": "day", "min_rental": "1_day", "deposit": 100, "insurance": 15}'
),

-- 教育培训详情
-- 编程训练营主服务
(
    gen_random_uuid(),
    'education-001',
    'main',
    '{"en": "Full-Stack Programming Bootcamp", "zh": "全栈编程训练营", "fr": "Bootcamp de Programmation Full-Stack"}',
    'Comprehensive programming course covering frontend, backend, and database development',
    'fixed_price',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"course_type": "programming", "delivery_method": "hybrid", "certification": true}',
    '{"min_students": "5", "max_students": "20", "refund_policy": "30_days", "prerequisites": "basic_computer_skills"}'
),
-- 课程模块
(
    gen_random_uuid(),
    'education-001',
    'course_module',
    '{"en": "HTML/CSS Fundamentals", "zh": "HTML/CSS基础", "fr": "Fondamentaux HTML/CSS"}',
    'Learn the basics of web development with HTML and CSS',
    'fixed_price',
    299.00,
    'CAD',
    'beginner',
    true,
    1,
    '{"difficulty": "beginner", "duration": "20_hours", "format": "video_lectures", "certificate": true}',
    '{"prerequisites": "none", "materials_included": true, "support": "24_7"}'
),
(
    gen_random_uuid(),
    'education-001',
    'course_module',
    '{"en": "JavaScript Programming", "zh": "JavaScript编程", "fr": "Programmation JavaScript"}',
    'Master JavaScript fundamentals and modern ES6+ features',
    'fixed_price',
    399.00,
    'CAD',
    'intermediate',
    true,
    2,
    '{"difficulty": "intermediate", "duration": "30_hours", "format": "hands_on", "certificate": true}',
    '{"prerequisites": ["HTML_CSS"], "materials_included": true, "support": "24_7"}'
),

-- 交通出行详情
-- 机场接送主服务
(
    gen_random_uuid(),
    'transport-001',
    'main',
    '{"en": "Premium Airport Transfer Service", "zh": "优质机场接送服务", "fr": "Service de Transfert Aéroport Premium"}',
    'Reliable airport transportation with professional drivers and luxury vehicles',
    'fixed_price',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"service_type": "airport_transfer", "vehicle_class": "luxury", "insured": true}',
    '{"advance_booking": "2_hours", "cancellation_policy": "1_hour", "flight_monitoring": true}'
),
-- 接送服务项目
(
    gen_random_uuid(),
    'transport-001',
    'service_item',
    '{"en": "Sedan Transfer", "zh": "轿车接送", "fr": "Transfert Berline"}',
    'Luxury sedan for up to 3 passengers with luggage',
    'fixed_price',
    89.00,
    'CAD',
    'sedan',
    true,
    1,
    '{"vehicle_type": "sedan", "passengers": "3", "luggage": "3_large_suitcases", "duration": "45_min"}',
    '{"wait_time": "15_min", "flight_delay_coverage": true, "meet_greet": true}'
),
(
    gen_random_uuid(),
    'transport-001',
    'service_item',
    '{"en": "SUV Transfer", "zh": "SUV接送", "fr": "Transfert SUV"}',
    'Spacious SUV for up to 6 passengers with luggage',
    'fixed_price',
    129.00,
    'CAD',
    'suv',
    true,
    2,
    '{"vehicle_type": "suv", "passengers": "6", "luggage": "6_large_suitcases", "duration": "45_min"}',
    '{"wait_time": "15_min", "flight_delay_coverage": true, "meet_greet": true}'
),

-- 健康医疗详情
-- 物理治疗主服务
(
    gen_random_uuid(),
    'health-001',
    'main',
    '{"en": "Advanced Physical Therapy Clinic", "zh": "高级物理治疗诊所", "fr": "Clinique de Physiothérapie Avancée"}',
    'Comprehensive physical therapy services with certified therapists',
    'fixed_price',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"service_type": "physical_therapy", "licensed": true, "insurance_accepted": true}',
    '{"advance_booking": "24_hours", "cancellation_policy": "4_hours", "consultation_required": true}'
),
-- 治疗项目
(
    gen_random_uuid(),
    'health-001',
    'service_item',
    '{"en": "Initial Consultation", "zh": "初次咨询", "fr": "Consultation Initiale"}',
    'Comprehensive assessment and treatment plan development',
    'fixed_price',
    80.00,
    'CAD',
    'consultation',
    true,
    1,
    '{"duration": "30_min", "includes": ["assessment", "treatment_plan"], "therapist_level": "senior"}',
    '{"insurance_billing": true, "referral_required": false, "follow_up": "1_week"}'
),
(
    gen_random_uuid(),
    'health-001',
    'service_item',
    '{"en": "Therapy Session", "zh": "治疗疗程", "fr": "Séance de Thérapie"}',
    'Individualized physical therapy treatment session',
    'fixed_price',
    120.00,
    'CAD',
    'treatment',
    true,
    2,
    '{"duration": "60_min", "includes": ["manual_therapy", "exercises", "education"], "therapist_level": "certified"}',
    '{"insurance_billing": true, "package_discount": true, "follow_up": "as_needed"}'
),

-- 专业速帮详情
-- IT技术支持主服务
(
    gen_random_uuid(),
    'tech-support-001',
    'main',
    '{"en": "Professional IT Support & Consulting", "zh": "专业IT技术支持与咨询", "fr": "Support et Conseil IT Professionnel"}',
    'Expert IT support for businesses and individuals. Network setup, system maintenance, cybersecurity, and digital transformation consulting.',
    'hourly',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"service_type": "it_support", "certification": ["CompTIA", "Cisco", "Microsoft"], "experience_years": 8, "response_time": "2_hours"}',
    '{"advance_booking": "24_hours", "cancellation_policy": "4_hours", "emergency_support": true}'
),
-- IT服务项目
(
    gen_random_uuid(),
    'tech-support-001',
    'service_item',
    '{"en": "Network Setup & Configuration", "zh": "网络设置与配置", "fr": "Configuration et Installation de Réseau"}',
    'Complete network setup for home and small business. Includes router configuration, WiFi optimization, and security setup.',
    'hourly',
    85.00,
    'CAD',
    'network_services',
    true,
    1,
    '{"duration": "2-4_hours", "includes": ["hardware", "configuration", "testing"], "skill_level": "expert"}',
    '{"min_booking": "2_hours", "travel_fee": "free_within_20km", "warranty": "90_days"}'
),
(
    gen_random_uuid(),
    'tech-support-001',
    'service_item',
    '{"en": "System Maintenance & Optimization", "zh": "系统维护与优化", "fr": "Maintenance et Optimisation de Système"}',
    'Regular system maintenance, performance optimization, and security updates for computers and servers.',
    'hourly',
    75.00,
    'CAD',
    'maintenance',
    true,
    2,
    '{"duration": "1-3_hours", "includes": ["cleanup", "optimization", "security"], "skill_level": "expert"}',
    '{"min_booking": "1_hour", "maintenance_plan": "available", "remote_support": true}'
),

-- 家电维修主服务
(
    gen_random_uuid(),
    'appliance-repair-001',
    'main',
    '{"en": "Expert Appliance Repair Service", "zh": "专业家电维修服务", "fr": "Service de Réparation d''Appareils Expert"}',
    'Professional repair service for all major appliances. Same-day service available for urgent repairs. Licensed and insured technicians.',
    'hourly',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"service_type": "appliance_repair", "certification": ["licensed", "insured"], "experience_years": 12, "response_time": "same_day"}',
    '{"advance_booking": "24_hours", "cancellation_policy": "2_hours", "emergency_service": true}'
),
-- 维修服务项目
(
    gen_random_uuid(),
    'appliance-repair-001',
    'service_item',
    '{"en": "Refrigerator Repair", "zh": "冰箱维修", "fr": "Réparation de Réfrigérateur"}',
    'Complete refrigerator repair service including diagnosis, parts replacement, and testing.',
    'hourly',
    65.00,
    'CAD',
    'refrigerator',
    true,
    1,
    '{"duration": "1-3_hours", "includes": ["diagnosis", "repair", "testing"], "parts_warranty": "1_year"}',
    '{"min_booking": "1_hour", "travel_fee": "free_within_25km", "same_day_service": true}'
),

-- 室内设计主服务
(
    gen_random_uuid(),
    'interior-design-001',
    'main',
    '{"en": "Creative Interior Design Studio", "zh": "创意室内设计工作室", "fr": "Studio de Design d''Intérieur Créatif"}',
    'Professional interior design services for residential and commercial spaces. 3D visualization, project management, and turnkey solutions.',
    'project_based',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"service_type": "interior_design", "certification": ["NCIDQ", "ASID"], "experience_years": 15, "software": ["AutoCAD", "3DS Max", "SketchUp"]}',
    '{"advance_booking": "2_weeks", "cancellation_policy": "1_week", "consultation_fee": "refundable"}'
),
-- 设计服务项目
(
    gen_random_uuid(),
    'interior-design-001',
    'service_item',
    '{"en": "Initial Consultation & Concept Design", "zh": "初次咨询与概念设计", "fr": "Consultation Initiale et Concept Design"}',
    'Initial meeting to understand your needs, followed by concept development and mood board creation.',
    'fixed_price',
    150.00,
    'CAD',
    'consultation',
    true,
    1,
    '{"duration": "2_hours", "includes": ["consultation", "concept", "mood_board"], "deliverables": "concept_presentation"}',
    '{"consultation_fee": "refundable", "follow_up": "1_week", "revision": "1_free"}'
),

-- 法律咨询主服务
(
    gen_random_uuid(),
    'legal-consulting-001',
    'main',
    '{"en": "Professional Legal Consulting", "zh": "专业法律咨询", "fr": "Conseil Juridique Professionnel"}',
    'Expert legal advice for individuals and businesses. Specializing in business law, employment law, and contract review.',
    'hourly',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"service_type": "legal_consulting", "certification": ["bar_licensed", "specialized"], "experience_years": 18, "practice_areas": ["business_law", "employment_law"]}',
    '{"advance_booking": "48_hours", "cancellation_policy": "24_hours", "confidentiality": "guaranteed"}'
),
-- 法律服务项目
(
    gen_random_uuid(),
    'legal-consulting-001',
    'service_item',
    '{"en": "Contract Review & Analysis", "zh": "合同审查与分析", "fr": "Révision et Analyse de Contrat"}',
    'Comprehensive contract review including legal analysis, risk assessment, and recommendations for improvement.',
    'hourly',
    200.00,
    'CAD',
    'contract_services',
    true,
    1,
    '{"duration": "2-4_hours", "includes": ["review", "analysis", "recommendations"], "document_length": "up_to_20_pages"}',
    '{"min_booking": "2_hours", "rush_service": "available", "follow_up": "included"}'
),

-- 财务咨询主服务
(
    gen_random_uuid(),
    'financial-consulting-001',
    'main',
    '{"en": "Expert Financial Advisory Services", "zh": "专业财务咨询服务", "fr": "Services de Conseil Financier Expert"}',
    'Comprehensive financial planning, tax preparation, and business consulting. Certified financial planners and tax professionals.',
    'hourly',
    0,
    'CAD',
    NULL,
    true,
    1,
    '{"service_type": "financial_consulting", "certification": ["CFP", "CPA"], "experience_years": 20, "specializations": ["tax_planning", "investment_advice"]}',
    '{"advance_booking": "1_week", "cancellation_policy": "48_hours", "confidentiality": "guaranteed"}'
),
-- 财务服务项目
(
    gen_random_uuid(),
    'financial-consulting-001',
    'service_item',
    '{"en": "Tax Preparation & Planning", "zh": "税务准备与规划", "fr": "Préparation et Planification Fiscale"}',
    'Complete tax preparation for individuals and businesses, including tax planning and optimization strategies.',
    'fixed_price',
    300.00,
    'CAD',
    'tax_services',
    true,
    1,
    '{"duration": "1_week", "includes": ["preparation", "filing", "planning"], "complexity": "standard"}',
    '{"deadline": "april_15", "e_filing": "included", "audit_support": "1_year"}'
);

-- =====================================================
-- 4. 数据验证查询
-- =====================================================

-- 验证数据完整性
SELECT 'Data Integrity Check' as check_type, COUNT(*) as total_records FROM service_details;

-- 检查各行业数据分布
SELECT 
    'Industry Distribution' as check_type,
    category,
    COUNT(*) as record_count,
    COUNT(DISTINCT service_id) as unique_services
FROM service_details 
GROUP BY category
ORDER BY record_count DESC;

-- 检查多语言支持完整性
SELECT 
    'Multi-language Support' as check_type,
    category,
    COUNT(*) as total_records,
    COUNT(CASE WHEN name->>'en' IS NOT NULL THEN 1 END) as has_english,
    COUNT(CASE WHEN name->>'zh' IS NOT NULL THEN 1 END) as has_chinese,
    COUNT(CASE WHEN name->>'fr' IS NOT NULL THEN 1 END) as has_french
FROM service_details 
GROUP BY category;

-- 验证主表和详情表的关联
SELECT 
    'Foreign Key Validation' as check_type,
    COUNT(*) as orphaned_records
FROM service_details sd
LEFT JOIN services s ON sd.service_id = s.id
WHERE s.id IS NULL;

-- 检查各服务的详情数量
SELECT 
    'Service Detail Count' as check_type,
    s.title->>'en' as service_name,
    s.category_level1_id,
    COUNT(sd.id) as detail_count,
    COUNT(CASE WHEN sd.category = 'main' THEN 1 END) as main_details,
    COUNT(CASE WHEN sd.category != 'main' THEN 1 END) as sub_details
FROM services s
LEFT JOIN service_details sd ON s.id = sd.service_id
GROUP BY s.id, s.title, s.category_level1_id
ORDER BY detail_count DESC;

-- 验证业务逻辑
SELECT 
    'Business Logic Validation' as check_type,
    COUNT(*) as validation_errors
FROM service_details 
WHERE (pricing_type = 'fixed_price' AND price < 0)
   OR (pricing_type = 'rental' AND price < 0)
   OR (current_stock IS NOT NULL AND current_stock < 0)
   OR (max_stock IS NOT NULL AND current_stock > max_stock);

-- =====================================================
-- 测试数据创建完成
-- =====================================================

COMMIT;

-- 显示创建结果摘要
SELECT 
    'Test Data Creation Summary' as summary,
    (SELECT COUNT(*) FROM provider_profiles WHERE id LIKE 'provider-%') as providers_created,
    (SELECT COUNT(*) FROM services WHERE id LIKE '%-001') as services_created,
    (SELECT COUNT(*) FROM service_details WHERE service_id LIKE '%-001') as details_created;
