#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ETL 脚本：从 CSV 加载数据到 Data Lake 和 Data Warehouse
用途：自动化数据摄取、清洗、转换和加载流程
"""

import pandas as pd
import numpy as np
from datetime import datetime
import logging

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class ChronicDiseaseETL:
    """慢性病数据 ETL 处理类"""
    
    def __init__(self, csv_path):
        """初始化 ETL 类"""
        self.csv_path = csv_path
        self.df_raw = None
        self.df_cleaned = None
        logger.info(f"初始化 ETL 处理器，数据源: {csv_path}")
    
    def load_raw_data(self):
        """第一步：从 CSV 加载原始数据到 Data Lake"""
        logger.info("=" * 80)
        logger.info("STEP 1: 加载原始数据到 Data Lake")
        logger.info("=" * 80)
        
        try:
            self.df_raw = pd.read_csv(self.csv_path, low_memory=False)
            logger.info(f"✅ 成功加载数据: {self.df_raw.shape[0]:,} 行 × {self.df_raw.shape[1]} 列")
            
            # 显示数据摘要
            logger.info(f"   - 列名数: {len(self.df_raw.columns)}")
            logger.info(f"   - 缺失值比例: {self.df_raw.isnull().mean().mean()*100:.2f}%")
            logger.info(f"   - 重复行数: {self.df_raw.duplicated().sum()}")
            
            return self.df_raw
        except FileNotFoundError:
            logger.error(f"❌ 文件不存在: {self.csv_path}")
            raise
        except Exception as e:
            logger.error(f"❌ 加载数据失败: {e}")
            raise
    
    def validate_data(self):
        """第二步：数据质量检查"""
        logger.info("=" * 80)
        logger.info("STEP 2: 数据质量验证")
        logger.info("=" * 80)
        
        if self.df_raw is None:
            logger.error("❌ 原始数据未加载")
            return False
        
        validation_passed = True
        
        # 检查必需列
        required_cols = ['Topic', 'Question', 'LocationDesc', 'YearStart', 'YearEnd', 'DataValue']
        for col in required_cols:
            if col not in self.df_raw.columns:
                logger.warning(f"⚠️  缺少列: {col}")
                validation_passed = False
            else:
                non_null_pct = (self.df_raw[col].notna().sum() / len(self.df_raw)) * 100
                logger.info(f"   ✓ {col}: {non_null_pct:.1f}% 非空")
        
        # 检查数据值
        if 'DataValue' in self.df_raw.columns:
            numeric_count = pd.to_numeric(self.df_raw['DataValue'], errors='coerce').notna().sum()
            logger.info(f"   ✓ DataValue: {numeric_count:,} 行有有效数值")
        
        # 检查年份范围
        if 'YearStart' in self.df_raw.columns:
            year_min = self.df_raw['YearStart'].min()
            year_max = self.df_raw['YearStart'].max()
            logger.info(f"   ✓ 年份范围: {year_min} - {year_max}")
        
        logger.info(f"   验证结果: {'✅ 通过' if validation_passed else '⚠️  有警告'}")
        return validation_passed
    
    def clean_and_transform(self):
        """第三步：数据清洗和转换"""
        logger.info("=" * 80)
        logger.info("STEP 3: 数据清洗和转换")
        logger.info("=" * 80)
        
        self.df_cleaned = self.df_raw.copy()
        initial_rows = len(self.df_cleaned)
        
        # 1. 删除完全重复行
        before = len(self.df_cleaned)
        self.df_cleaned = self.df_cleaned.drop_duplicates()
        after = len(self.df_cleaned)
        logger.info(f"   ✓ 删除重复行: {before - after} 行")
        
        # 2. 清洗文本字段（去除首尾空格）
        text_cols = self.df_cleaned.select_dtypes(include=['object']).columns
        for col in text_cols:
            self.df_cleaned[col] = self.df_cleaned[col].str.strip()
        logger.info(f"   ✓ 清洗 {len(text_cols)} 个文本列")
        
        # 3. 转换数值字段
        if 'DataValue' in self.df_cleaned.columns:
            self.df_cleaned['DataValue_numeric'] = pd.to_numeric(
                self.df_cleaned['DataValue'], 
                errors='coerce'
            )
            logger.info(f"   ✓ 转换 DataValue 为数值")
        
        # 4. 转换年份为整数
        if 'YearStart' in self.df_cleaned.columns:
            self.df_cleaned['YearStart'] = pd.to_numeric(
                self.df_cleaned['YearStart'], 
                errors='coerce'
            ).astype('Int64')
        if 'YearEnd' in self.df_cleaned.columns:
            self.df_cleaned['YearEnd'] = pd.to_numeric(
                self.df_cleaned['YearEnd'], 
                errors='coerce'
            ).astype('Int64')
        logger.info(f"   ✓ 转换年份字段")
        
        # 5. 添加处理时间戳
        self.df_cleaned['load_timestamp'] = datetime.now()
        logger.info(f"   ✓ 添加加载时间戳")
        
        removed_rows = initial_rows - len(self.df_cleaned)
        logger.info(f"   清洗后数据: {len(self.df_cleaned):,} 行（删除 {removed_rows} 行）")
        
        return self.df_cleaned
    
    def generate_dimensions(self):
        """第四步：生成维度表数据"""
        logger.info("=" * 80)
        logger.info("STEP 4: 生成维度数据")
        logger.info("=" * 80)
        
        if self.df_cleaned is None:
            logger.error("❌ 清洗数据未准备")
            return {}
        
        dimensions = {}
        
        # 维度 1: Topics
        if 'Topic' in self.df_cleaned.columns:
            topics = self.df_cleaned[['Topic', 'TopicID']].drop_duplicates()
            topics = topics[topics['Topic'].notna()]
            dimensions['dim_topics'] = topics.rename(columns={
                'Topic': 'topic_name',
                'TopicID': 'topic_code'
            })
            logger.info(f"   ✓ Topics 维度: {len(dimensions['dim_topics'])} 个不同的主题")
        
        # 维度 2: Questions
        if 'Question' in self.df_cleaned.columns:
            questions = self.df_cleaned[['Question', 'QuestionID', 'Topic']].drop_duplicates()
            questions = questions[questions['Question'].notna()]
            dimensions['dim_questions'] = questions.rename(columns={
                'Question': 'question_text',
                'QuestionID': 'question_code',
                'Topic': 'topic_name'
            })
            logger.info(f"   ✓ Questions 维度: {len(dimensions['dim_questions'])} 个不同的问题")
        
        # 维度 3: Locations
        if 'LocationDesc' in self.df_cleaned.columns:
            locations = self.df_cleaned[[
                'LocationAbbr', 'LocationDesc', 'Geolocation'
            ]].drop_duplicates()
            locations = locations[locations['LocationDesc'].notna()]
            dimensions['dim_locations'] = locations.rename(columns={
                'LocationAbbr': 'location_abbr',
                'LocationDesc': 'location_desc',
                'Geolocation': 'geolocation'
            })
            logger.info(f"   ✓ Locations 维度: {len(dimensions['dim_locations'])} 个不同的地区")
        
        # 维度 4: Data Value Types
        if 'DataValueType' in self.df_cleaned.columns:
            types = self.df_cleaned[[
                'DataValueType', 'DataValueUnit'
            ]].drop_duplicates()
            types = types[types['DataValueType'].notna()]
            dimensions['dim_data_value_types'] = types.rename(columns={
                'DataValueType': 'type_name',
                'DataValueUnit': 'unit_of_measure'
            })
            logger.info(f"   ✓ Data Value Types 维度: {len(dimensions['dim_data_value_types'])} 个类型")
        
        return dimensions
    
    def summary_report(self):
        """生成处理报告"""
        logger.info("=" * 80)
        logger.info("FINAL REPORT - ETL 处理总结")
        logger.info("=" * 80)
        
        logger.info(f"✅ 处理时间: {datetime.now()}")
        logger.info(f"✅ 原始数据行数: {len(self.df_raw):,}")
        logger.info(f"✅ 清洗后行数: {len(self.df_cleaned):,}")
        logger.info(f"✅ 列数: {self.df_cleaned.shape[1]}")
        logger.info(f"✅ 缺失值比例: {self.df_cleaned.isnull().mean().mean()*100:.2f}%")
        logger.info("=" * 80)


def main():
    """主函数"""
    csv_path = 'data/U.S._Chronic_Disease_Indicators_20251102.csv'
    
    # 创建 ETL 处理器
    etl = ChronicDiseaseETL(csv_path)
    
    # 执行 ETL 流程
    etl.load_raw_data()
    etl.validate_data()
    etl.clean_and_transform()
    dimensions = etl.generate_dimensions()
    etl.summary_report()
    
    logger.info("\n✅ ETL 处理完成！")
    logger.info("\n下一步:")
    logger.info("1. 使用生成的清洗数据加载到 Data Lake")
    logger.info("2. 执行维度表加载 SQL")
    logger.info("3. 执行事实表加载 SQL")
    logger.info("4. 进行数据验证和性能优化")


if __name__ == '__main__':
    main()
