-- Account Service Database Initialization Script
-- This script runs automatically when the container starts for the first time

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- The tables will be created by Hibernate/JPA automatically
-- This script is for any custom initialization

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE accountdb TO postgres;

-- Log initialization
DO $$
BEGIN
  RAISE NOTICE 'Account database initialized successfully';
END $$;
