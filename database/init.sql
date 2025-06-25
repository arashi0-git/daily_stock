-- データベース初期化スクリプト

-- ユーザーテーブル
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 日用品カテゴリテーブル
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 通知テーブル
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES daily_items(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    scheduled_date TIMESTAMP,
    sent_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- デフォルトカテゴリを挿入
INSERT INTO categories (name, description) VALUES
('食品', '食料品・調味料・飲料など'),
('日用品', 'トイレットペーパー・洗剤・歯磨き粉など'),
('衛生用品', 'シャンプー・石鹸・化粧品など'),
('文房具', 'ペン・ノート・事務用品など'),
('医薬品', '薬・絆創膏・マスクなど'),
('その他', 'その他の日用品');

-- インデックスを作成（パフォーマンス向上のため）
CREATE INDEX idx_daily_items_user_id ON daily_items(user_id);
CREATE INDEX idx_consumption_records_user_id ON consumption_records(user_id);
CREATE INDEX idx_consumption_records_item_id ON consumption_records(item_id);
CREATE INDEX idx_replenishment_records_user_id ON replenishment_records(user_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_sent_at ON notifications(sent_at);

-- トリガー関数：updated_atを自動更新
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- トリガー：users, daily_itemsテーブルのupdated_atを自動更新
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_daily_items_updated_at BEFORE UPDATE ON daily_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 