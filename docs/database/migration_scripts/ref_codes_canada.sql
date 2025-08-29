-- 加拿大国家
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('200020000', 'AREA_CODE', NULL, 'CA', '{"en":"Canada","zh":"加拿大"}', 1, 1, 1, '{"type":"country"}');

-- 加拿大省份
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('200020100', 'AREA_CODE', '200020000', 'CA-ON', '{"en":"Ontario","zh":"安大略省"}', 2, 1, 1, '{"type":"province"}'),
('200020200', 'AREA_CODE', '200020000', 'CA-BC', '{"en":"British Columbia","zh":"不列颠哥伦比亚省"}', 2, 1, 2, '{"type":"province"}'),
('200020300', 'AREA_CODE', '200020000', 'CA-QC', '{"en":"Quebec","zh":"魁北克省"}', 2, 1, 3, '{"type":"province"}'),
('200020400', 'AREA_CODE', '200020000', 'CA-AB', '{"en":"Alberta","zh":"阿尔伯塔省"}', 2, 1, 4, '{"type":"province"}');

-- 安大略省-渥太华地区
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('200020110', 'AREA_CODE', '200020100', 'CA-ON-OTT-REGION', '{"en":"Ottawa Region","zh":"渥太华地区"}', 3, 1, 3, '{"type":"district"}');

-- 渥太华城市
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('200020102', 'AREA_CODE', '200020110', 'CA-ON-OTT', '{"en":"Ottawa","zh":"渥太华"}', 4, 1, 2, '{"type":"city"}');

-- 渥太华主要区域
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('20002010201', 'AREA_CODE', '200020102', 'CA-ON-OTT-DOWNTOWN', '{"en":"Downtown","zh":"市中心"}', 5, 1, 1, '{"type":"area"}'),
('20002010202', 'AREA_CODE', '200020102', 'CA-ON-OTT-KANATA', '{"en":"Kanata","zh":"卡纳塔"}', 5, 1, 2, '{"type":"area"}'),
('20002010203', 'AREA_CODE', '200020102', 'CA-ON-OTT-NEPEAN', '{"en":"Nepean","zh":"尼皮恩"}', 5, 1, 3, '{"type":"area"}'),
('20002010204', 'AREA_CODE', '200020102', 'CA-ON-OTT-ORLEANS', '{"en":"Orleans","zh":"奥尔良"}', 5, 1, 4, '{"type":"area"}'),
('20002010205', 'AREA_CODE', '200020102', 'CA-ON-OTT-BARRHAVEN', '{"en":"Barrhaven","zh":"巴尔黑文"}', 5, 1, 5, '{"type":"area"}'),
('20002010206', 'AREA_CODE', '200020102', 'CA-ON-OTT-GLOUCESTER', '{"en":"Gloucester","zh":"格洛斯特"}', 5, 1, 6, '{"type":"area"}'),
('20002010207', 'AREA_CODE', '200020102', 'CA-ON-OTT-VANIER', '{"en":"Vanier","zh":"瓦尼耶"}', 5, 1, 7, '{"type":"area"}');

-- 魁北克省-加蒂诺地区
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('200020310', 'AREA_CODE', '200020300', 'CA-QC-GAT-REGION', '{"en":"Gatineau Region","zh":"加蒂诺地区"}', 3, 1, 4, '{"type":"district"}');

-- 加蒂诺城市
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('200020311', 'AREA_CODE', '200020310', 'CA-QC-GAT', '{"en":"Gatineau","zh":"加蒂诺"}', 4, 1, 1, '{"type":"city"}');

-- 加蒂诺主要区域
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('20002031101', 'AREA_CODE', '200020311', 'CA-QC-GAT-HULL', '{"en":"Hull","zh":"赫尔"}', 5, 1, 1, '{"type":"area"}'),
('20002031102', 'AREA_CODE', '200020311', 'CA-QC-GAT-AYLMER', '{"en":"Aylmer","zh":"艾尔默"}', 5, 1, 2, '{"type":"area"}'),
('20002031103', 'AREA_CODE', '200020311', 'CA-QC-GAT-GATINEAU', '{"en":"Gatineau Sector","zh":"加蒂诺区"}', 5, 1, 3, '{"type":"area"}'),
('20002031104', 'AREA_CODE', '200020311', 'CA-QC-GAT-MASS', '{"en":"Masson-Angers","zh":"马松-安热"}', 5, 1, 4, '{"type":"area"}');

-- 其它主要城市（保持原有结构）
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('200020101', 'AREA_CODE', '200020100', 'CA-ON-TOR', '{"en":"Toronto","zh":"多伦多"}', 3, 1, 1, '{"type":"city"}'),
('200020201', 'AREA_CODE', '200020200', 'CA-BC-VAN', '{"en":"Vancouver","zh":"温哥华"}', 3, 1, 1, '{"type":"city"}'),
('200020202', 'AREA_CODE', '200020200', 'CA-BC-VIC', '{"en":"Victoria","zh":"维多利亚"}', 3, 1, 2, '{"type":"city"}'),
('200020301', 'AREA_CODE', '200020300', 'CA-QC-MTL', '{"en":"Montreal","zh":"蒙特利尔"}', 3, 1, 1, '{"type":"city"}'),
('200020302', 'AREA_CODE', '200020300', 'CA-QC-QC', '{"en":"Quebec City","zh":"魁北克市"}', 3, 1, 2, '{"type":"city"}'),
('200020401', 'AREA_CODE', '200020400', 'CA-AB-CGY', '{"en":"Calgary","zh":"卡尔加里"}', 3, 1, 1, '{"type":"city"}'),
('200020402', 'AREA_CODE', '200020400', 'CA-AB-EDM', '{"en":"Edmonton","zh":"埃德蒙顿"}', 3, 1, 2, '{"type":"city"}'); 