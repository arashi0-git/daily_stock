-- Add consumption_recommendations table
CREATE TABLE IF NOT EXISTS consumption_recommendations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES daily_items(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50) NOT NULL,
    urgency_level VARCHAR(20) NOT NULL,
    user_consumption_pace FLOAT NOT NULL,
    market_consumption_pace FLOAT,
    estimated_days_remaining INTEGER NOT NULL,
    recommendation_message TEXT NOT NULL,
    confidence_score FLOAT NOT NULL,
    additional_info JSON,
    is_active BOOLEAN DEFAULT TRUE,
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_consumption_recommendations_user_id ON consumption_recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_consumption_recommendations_item_id ON consumption_recommendations(item_id);
CREATE INDEX IF NOT EXISTS idx_consumption_recommendations_urgency ON consumption_recommendations(urgency_level);
CREATE INDEX IF NOT EXISTS idx_consumption_recommendations_active ON consumption_recommendations(is_active);
CREATE INDEX IF NOT EXISTS idx_consumption_recommendations_created_at ON consumption_recommendations(created_at);

-- Add trigger to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_consumption_recommendations_updated_at 
    BEFORE UPDATE ON consumption_recommendations 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();