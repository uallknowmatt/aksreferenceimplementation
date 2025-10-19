-- Customer Service Database Initialization Script
-- This script runs automatically when the container starts for the first time

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- The tables will be created by Hibernate/JPA automatically
-- This script is for any custom initialization

-- Create indexes for better performance
-- (Will be created after tables exist, so this is a placeholder)

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE customerdb TO postgres;

-- Log initialization
DO $$
BEGIN
  RAISE NOTICE 'Customer database initialized successfully';
END $$;
