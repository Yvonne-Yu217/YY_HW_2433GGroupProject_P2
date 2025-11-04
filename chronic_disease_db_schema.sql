-- ============================================
-- Chronic Disease Database Schema
-- Based on U.S. Chronic Disease Indicators
-- ============================================

-- Dimension Table: Topics
CREATE TABLE dim_topics (
    topic_id SERIAL PRIMARY KEY,
    topic VARCHAR(200) NOT NULL UNIQUE,
    topic_description TEXT
);

-- Dimension Table: Questions (Health Indicators)
CREATE TABLE dim_questions (
    question_id SERIAL PRIMARY KEY,
    question TEXT NOT NULL UNIQUE,
    indicator VARCHAR(500),
    question_short_name VARCHAR(200)
);

-- Dimension Table: Locations (States/Territories)
CREATE TABLE dim_locations (
    location_id SERIAL PRIMARY KEY,
    location_abbr VARCHAR(10) NOT NULL UNIQUE,
    location_desc VARCHAR(200) NOT NULL,
    location_type VARCHAR(50)  -- e.g., 'State', 'Territory', 'National'
);

-- Dimension Table: Stratification Categories
CREATE TABLE dim_stratification_categories (
    stratification_category_id SERIAL PRIMARY KEY,
    stratification_category VARCHAR(100) NOT NULL UNIQUE,
    category_description TEXT
);

-- Dimension Table: Stratifications
CREATE TABLE dim_stratifications (
    stratification_id SERIAL PRIMARY KEY,
    stratification_category_id INT NOT NULL REFERENCES dim_stratification_categories(stratification_category_id),
    stratification VARCHAR(200) NOT NULL,
    UNIQUE(stratification_category_id, stratification)
);

-- Dimension Table: Data Value Types
CREATE TABLE dim_data_value_types (
    data_value_type_id SERIAL PRIMARY KEY,
    data_value_type VARCHAR(100) NOT NULL UNIQUE,
    data_value_unit VARCHAR(100)
);

-- Fact Table: Health Observations
CREATE TABLE fact_observations (
    observation_id SERIAL PRIMARY KEY,
    
    -- Foreign Keys to Dimensions
    topic_id INT NOT NULL REFERENCES dim_topics(topic_id),
    question_id INT NOT NULL REFERENCES dim_questions(question_id),
    location_id INT NOT NULL REFERENCES dim_locations(location_id),
    stratification_id INT REFERENCES dim_stratifications(stratification_id),
    data_value_type_id INT REFERENCES dim_data_value_types(data_value_type_id),
    
    -- Time Dimensions
    year_start INT,
    year_end INT,
    
    -- Measurements
    data_value DECIMAL(18, 4),
    low_confidence_limit DECIMAL(18, 4),
    high_confidence_limit DECIMAL(18, 4),
    
    -- Metadata
    response VARCHAR(200),
    data_value_footnote_symbol VARCHAR(10),
    data_value_footnote TEXT,
    
    -- Source Tracking
    datasource VARCHAR(100),
    
    -- Original IDs for reference
    yearstart VARCHAR(10),
    yearend VARCHAR(10),
    locationabbr VARCHAR(10),
    topicid VARCHAR(50),
    questionid VARCHAR(50),
    datavaluetypeid VARCHAR(50),
    stratificationcategoryid1 VARCHAR(50),
    stratificationid1 VARCHAR(50),
    
    -- Audit fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX idx_fact_observations_topic ON fact_observations(topic_id);
CREATE INDEX idx_fact_observations_question ON fact_observations(question_id);
CREATE INDEX idx_fact_observations_location ON fact_observations(location_id);
CREATE INDEX idx_fact_observations_year ON fact_observations(year_start, year_end);
CREATE INDEX idx_fact_observations_stratification ON fact_observations(stratification_id);