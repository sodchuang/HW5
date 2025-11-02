-- Worker 名字管理資料庫初始化腳本
-- 此腳本在PostgreSQL容器第一次啟動時執行

-- 建立名字表
CREATE TABLE IF NOT EXISTS names (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_names_created_at ON names(created_at);
CREATE INDEX IF NOT EXISTS idx_names_name ON names(name);

-- 建立更新時間觸發器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE OR REPLACE TRIGGER update_names_updated_at 
    BEFORE UPDATE ON names 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 插入一些範例資料 (可選)
INSERT INTO names (name) VALUES 
    ('範例名字1'),
    ('範例名字2'),
    ('範例名字3')
ON CONFLICT DO NOTHING;

-- 建立資料庫統計檢視
CREATE OR REPLACE VIEW names_stats AS
SELECT 
    COUNT(*) as total_names,
    MIN(created_at) as first_created,
    MAX(created_at) as last_created,
    COUNT(DISTINCT DATE(created_at)) as days_with_data
FROM names;

-- 顯示初始化完成訊息
DO $$
BEGIN
    RAISE NOTICE 'Worker 名字管理資料庫初始化完成!';
    RAISE NOTICE '資料表: names';
    RAISE NOTICE '統計檢視: names_stats';
END $$;