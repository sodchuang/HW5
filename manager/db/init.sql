-- Database initialization script for Names Management
-- This script will be executed when PostgreSQL container starts for the first time

-- Create database if not exists (PostgreSQL will use POSTGRES_DB env var)
-- No need to create database as it's handled by env vars

-- Create names table
CREATE TABLE IF NOT EXISTS names (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_names_created_at ON names(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_names_name ON names(name);

-- Insert some sample data
INSERT INTO names (name) VALUES 
    ('張小明'),
    ('李小華'),
    ('王大同'),
    ('陳美麗'),
    ('林志偉')
ON CONFLICT DO NOTHING;

-- Grant permissions (if needed)
-- GRANT ALL PRIVILEGES ON TABLE names TO postgres;
-- GRANT USAGE, SELECT ON SEQUENCE names_id_seq TO postgres;

-- Print confirmation
\echo 'Names table initialized successfully with sample data'