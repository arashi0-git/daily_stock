-- 🗄️ Supabase手動セットアップSQL
-- このSQLをSupabase SQL Editorで実行してください

-- 既存テーブルがあれば削除（注意：データも削除されます）
DROP TABLE IF EXISTS consumption_recommendations CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS replenishment_records CASCADE;
DROP TABLE IF EXISTS consumption_records CASCADE;
DROP TABLE IF EXISTS daily_items CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ユーザーテーブル
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- カテゴリテーブル
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 日用品テーブル
CREATE TABLE daily_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    current_quantity INTEGER DEFAULT 0,
    unit VARCHAR(20) DEFAULT '個',
    minimum_threshold INTEGER DEFAULT 1,
    estimated_consumption_days INTEGER DEFAULT 30,
    purchase_url TEXT,
    price DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 消費記録テーブル
CREATE TABLE consumption_records (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES daily_items(id) ON DELETE CASCADE,
    consumed_quantity INTEGER NOT NULL,
    consumption_date DATE DEFAULT CURRENT_DATE,
    remaining_quantity INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 補充記録テーブル
CREATE TABLE replenishment_records (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES daily_items(id) ON DELETE CASCADE,
    replenished_quantity INTEGER NOT NULL,
    replenishment_date DATE DEFAULT CURRENT_DATE,
    cost DECIMAL(10, 2),
    supplier VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 通知テーブル
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES daily_items(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    scheduled_date TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 消費推奨テーブル
CREATE TABLE consumption_recommendations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES daily_items(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50) NOT NULL,
    urgency_level VARCHAR(20) NOT NULL,
    user_consumption_pace FLOAT NOT NULL,
    market_consumption_pace FLOAT,
    estimated_days_remaining INTEGER NOT NULL,
    recommendation_message TEXT NOT NULL,
    confidence_score FLOAT NOT NULL,
    additional_info JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- デフォルトカテゴリを挿入
INSERT INTO categories (name, description) VALUES
('食品', '食料品・調味料・飲料など'),
('日用品', 'トイレットペーパー・洗剤・歯磨き粉など'),
('衛生用品', 'シャンプー・石鹸・化粧品など'),
('文房具', 'ペン・ノート・事務用品など'),
('医薬品', '薬・絆創膏・マスクなど'),
('その他', 'その他の日用品');

-- インデックスを作成
CREATE INDEX idx_daily_items_user_id ON daily_items(user_id);
CREATE INDEX idx_consumption_records_user_id ON consumption_records(user_id);
CREATE INDEX idx_consumption_records_item_id ON consumption_records(item_id);
CREATE INDEX idx_replenishment_records_user_id ON replenishment_records(user_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_consumption_recommendations_user_id ON consumption_recommendations(user_id);

-- トリガー関数：updated_atを自動更新
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- トリガーを作成
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_items_updated_at 
    BEFORE UPDATE ON daily_items 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_consumption_recommendations_updated_at 
    BEFORE UPDATE ON consumption_recommendations 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ✅ 手動セットアップ完了！ 