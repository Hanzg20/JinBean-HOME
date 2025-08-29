#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
JinBean Platform - 数据插入脚本生成器
自动生成分类数据插入脚本
"""

import json
import os
from typing import Dict, List, Any

class DataScriptGenerator:
    def __init__(self, template_path: str = "data_insertion_template.sql"):
        self.template_path = template_path
        self.template_content = self._load_template()
    
    def _load_template(self) -> str:
        """加载模板文件"""
        try:
            with open(self.template_path, 'r', encoding='utf-8') as f:
                return f.read()
        except FileNotFoundError:
            print(f"模板文件 {self.template_path} 不存在")
            return ""
    
    def generate_script(self, category_config: Dict[str, Any]) -> str:
        """
        生成数据插入脚本
        
        Args:
            category_config: 分类配置字典
        """
        script = self.template_content
        
        # 替换基本变量
        script = script.replace('{CATEGORY_NAME_ZH}', category_config['name_zh'])
        script = script.replace('{CATEGORY_NAME_EN}', category_config['name_en'])
        script = script.replace('{PROVIDER_COUNT}', str(len(category_config['providers'])))
        script = script.replace('{SERVICE_COUNT_PER_CATEGORY}', str(category_config['services_per_category']))
        
        # 生成提供商数据
        provider_data = self._format_provider_data(category_config['providers'])
        script = script.replace('{PROVIDER_DATA}', provider_data)
        
        # 生成服务数据
        service_data = self._format_service_data(category_config['services'])
        script = script.replace('{SERVICE_DATA}', service_data)
        
        # 生成动态变量
        script = self._generate_dynamic_variables(script, category_config['subcategories'])
        
        return script
    
    def _format_provider_data(self, providers: List[Dict[str, Any]]) -> str:
        """格式化提供商数据"""
        provider_lines = []
        
        for i, provider in enumerate(providers):
            line = f"""(gen_random_uuid(), 
 '{{"zh": "{provider['name_zh']}", "en": "{provider['name_en']}"}}',
 '{{"zh": "{provider['bio_zh']}", "en": "{provider['bio_en']}"}}',
 'https://picsum.photos/id/{300 + i}/200/200',
 '{provider['phone']}', '{provider['email']}', 
 {provider['rating']}, {provider['review_count']}, 'active', '{provider['type']}', true,
 {provider['experience_years']}, ARRAY{provider['tags']}, 
 '{{"specialties": {provider['specialties']}, "certifications": {provider['certifications']}, "languages": {provider['languages']}}}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"""
            
            if i < len(providers) - 1:
                line += ","
            
            provider_lines.append(line)
        
        return "\n".join(provider_lines)
    
    def _format_service_data(self, services: List[Dict[str, Any]]) -> str:
        """格式化服务数据"""
        service_lines = []
        
        for service in services:
            line = f"""INSERT INTO services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, service_delivery_method, created_at, updated_at) VALUES 
(gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '{service['provider_name']}'), '{{"zh": "{service['name_zh']}", "en": "{service['name_en']}"}}', '{{"zh": "{service['description_zh']}", "en": "{service['description_en']}"}}', category_level1_id, {service['subcategory_id']}, 'active', {service['rating']}, {service['review_count']}, '{service['delivery_method']}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);"""
            
            service_lines.append(line)
        
        return "\n".join(service_lines)
    
    def _generate_dynamic_variables(self, script: str, subcategories: List[str]) -> str:
        """生成动态变量"""
        # 生成变量声明
        variables = []
        for i, subcategory in enumerate(subcategories):
            variables.append(f"subcategory{i+1}_id INTEGER")
        
        script = script.replace('{SUBCATEGORY_VARIABLES}', "; ".join(variables))
        
        # 生成ID查询
        queries = []
        for i, subcategory in enumerate(subcategories):
            query = f"SELECT id INTO subcategory{i+1}_id FROM ref_codes WHERE type_code = 'SERVICE_TYPE' AND level = 2 AND name->>'zh' = '{subcategory}';"
            queries.append(query)
        
        script = script.replace('{SUBCATEGORY_ID_QUERIES}', "\n    ".join(queries))
        
        # 生成名称列表
        names = ", ".join(subcategories)
        script = script.replace('{SUBCATEGORY_NAMES}', names)
        
        return script
    
    def save_script(self, script: str, output_path: str):
        """保存生成的脚本"""
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(script)
        print(f"脚本已保存到: {output_path}")

def create_food_category_config() -> Dict[str, Any]:
    """创建美食分类配置示例"""
    return {
        "name_zh": "美食天地",
        "name_en": "Food World",
        "services_per_category": 2,
        "subcategories": ["社区美食", "餐厅预订", "团体餐饮", "食材采购", "其它"],
        "providers": [
            {
                "name_zh": "张妈妈川菜工坊",
                "name_en": "Auntie Zhang's Sichuan Kitchen",
                "bio_zh": "20年川菜制作经验，社区认证美食服务商",
                "bio_en": "20 years of Sichuan cuisine experience, community-certified food service provider",
                "phone": "+1-416-555-0101",
                "email": "zhangmama@jinbean.ca",
                "rating": 4.8,
                "review_count": 156,
                "type": "individual",
                "experience_years": 20,
                "tags": "['川菜', '麻辣', '家常菜']",
                "specialties": "['川菜', '麻辣', '家常菜']",
                "certifications": "['社区认证', '食品安全']",
                "languages": "['中文', '英文']"
            },
            {
                "name_zh": "李师傅饺子屋",
                "name_en": "Master Li's Dumpling House",
                "bio_zh": "专业手工饺子制作，新鲜食材，多种馅料",
                "bio_en": "Professional handmade dumplings, fresh ingredients, various fillings",
                "phone": "+1-416-555-0102",
                "email": "masterli@jinbean.ca",
                "rating": 4.7,
                "review_count": 89,
                "type": "individual",
                "experience_years": 15,
                "tags": "['饺子', '手工制作', '新鲜食材']",
                "specialties": "['饺子', '手工制作', '新鲜食材']",
                "certifications": "['社区认证', '食品安全']",
                "languages": "['中文', '英文']"
            }
        ],
        "services": [
            {
                "provider_name": "张妈妈川菜工坊",
                "name_zh": "张妈妈川菜工坊",
                "name_en": "Auntie Zhang's Sichuan Kitchen",
                "description_zh": "社区认证的川菜制作，正宗麻辣味道，温馨家常",
                "description_en": "Community-certified Sichuan cuisine, authentic spicy flavors, warm home-style",
                "subcategory_id": "subcategory1_id",
                "rating": 4.8,
                "review_count": 156,
                "delivery_method": "delivery"
            },
            {
                "provider_name": "李师傅饺子屋",
                "name_zh": "李师傅饺子屋",
                "name_en": "Master Li's Dumpling House",
                "description_zh": "手工饺子制作，新鲜食材，多种馅料可选",
                "description_en": "Handmade dumplings, fresh ingredients, various fillings available",
                "subcategory_id": "subcategory1_id",
                "rating": 4.7,
                "review_count": 89,
                "delivery_method": "delivery"
            }
        ]
    }

def create_home_services_config() -> Dict[str, Any]:
    """创建家政服务分类配置示例"""
    return {
        "name_zh": "家政服务",
        "name_en": "Home Services",
        "services_per_category": 2,
        "subcategories": ["清洁服务", "维修服务", "搬家服务", "其他"],
        "providers": [
            {
                "name_zh": "专业清洁公司",
                "name_en": "Professional Cleaning Company",
                "bio_zh": "专业家庭清洁服务，10年经验",
                "bio_en": "Professional home cleaning service, 10 years experience",
                "phone": "+1-416-555-0201",
                "email": "cleaning@example.com",
                "rating": 4.9,
                "review_count": 234,
                "type": "corporate",
                "experience_years": 10,
                "tags": "['清洁', '消毒', '整理']",
                "specialties": "['清洁', '消毒']",
                "certifications": "['清洁认证']",
                "languages": "['中文', '英文']"
            }
        ],
        "services": [
            {
                "provider_name": "专业清洁公司",
                "name_zh": "家庭深度清洁",
                "name_en": "Deep Home Cleaning",
                "description_zh": "专业家庭深度清洁服务，包括厨房、卫生间、客厅等",
                "description_en": "Professional deep home cleaning service, including kitchen, bathroom, living room",
                "subcategory_id": "subcategory1_id",
                "rating": 4.9,
                "review_count": 234,
                "delivery_method": "on_site"
            }
        ]
    }

def main():
    """主函数"""
    generator = DataScriptGenerator()
    
    # 生成美食分类脚本
    food_config = create_food_category_config()
    food_script = generator.generate_script(food_config)
    generator.save_script(food_script, "generated_food_services_data.sql")
    
    # 生成家政服务脚本
    home_config = create_home_services_config()
    home_script = generator.generate_script(home_config)
    generator.save_script(home_script, "generated_home_services_data.sql")
    
    print("脚本生成完成！")

if __name__ == "__main__":
    main()
