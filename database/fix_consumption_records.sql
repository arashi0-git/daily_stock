-- Fix consumption_records table by adding missing user_id column
-- This migration fixes the missing user_id column in the consumption_records table

-- Check if user_id column exists, if not add it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'consumption_records' 
        AND column_name = 'user_id'
    ) THEN
        -- Add user_id column
        ALTER TABLE consumption_records 
        ADD COLUMN user_id INTEGER REFERENCES users(id) ON DELETE CASCADE;
        
        -- Create index for better performance
        CREATE INDEX IF NOT EXISTS idx_consumption_records_user_id ON consumption_records(user_id);
        
        -- Update existing records to set user_id based on the item's user_id
        UPDATE consumption_records 
        SET user_id = (
            SELECT user_id 
            FROM daily_items 
            WHERE daily_items.id = consumption_records.item_id
        );
        
        -- Make user_id NOT NULL after updating all records
        ALTER TABLE consumption_records 
        ALTER COLUMN user_id SET NOT NULL;
        
        RAISE NOTICE 'user_id column added to consumption_records table successfully';
    ELSE
        RAISE NOTICE 'user_id column already exists in consumption_records table';
    END IF;
END $$; 