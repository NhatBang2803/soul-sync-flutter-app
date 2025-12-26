#!/bin/bash

# =====================================================
# Soul Sync Database - Auto Setup Script
# Mục đích: Tự động chạy tất cả setup scripts và kết nối Supabase
# Sử dụng: ./setup_database.sh (tự động đọc từ .env)
# Yêu cầu: File .env phải có SUPABASE_URL và SUPABASE_PASSWORD
# Ngày tạo: 2025-12-27
# =====================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to load .env file
load_env() {
    if [ -f "../.env" ]; then
        echo -e "${GREEN}🔧 Loading environment variables from .env...${NC}"
        export $(grep -v '^#' ../.env | xargs)
    elif [ -f ".env" ]; then
        echo -e "${GREEN}🔧 Loading environment variables from .env...${NC}"
        export $(grep -v '^#' .env | xargs)
    else
        echo -e "${RED}❌ Error: .env file not found!${NC}"
        echo -e "${YELLOW}💡 Make sure .env file exists in project root or database folder${NC}"
        exit 1
    fi
}

# Load environment variables
load_env

# Extract database info from Supabase URL
if [ -z "$SUPABASE_URL" ]; then
    echo -e "${RED}❌ Error: SUPABASE_URL not found in .env file${NC}"
    exit 1
fi

# Parse Supabase URL to get connection info
SUPABASE_HOST=$(echo $SUPABASE_URL | sed -E 's|https://([^.]+)\.supabase\.co|\1.supabase.co|')
DB_NAME="postgres"
DB_USER="postgres"
DB_PASSWORD="$SUPABASE_PASSWORD"
DB_PORT="5432"

# Build connection string
export PGPASSWORD="$DB_PASSWORD"
PSQL_CONN="-h $SUPABASE_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME"

echo -e "${BLUE}🚀 Soul Sync Database Setup${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e "Supabase Host: ${YELLOW}$SUPABASE_HOST${NC}"
echo -e "Database: ${YELLOW}$DB_NAME${NC}"
echo -e "User: ${YELLOW}$DB_USER${NC}"
echo ""

# Array of SQL files to execute in order
SQL_FILES=(
    "p01_initialize_database.sql"
    "p02_create_schema.sql"  
    "p03_create_views.sql"
    "p04_create_functions.sql"
    "p05_configure_security.sql"
    "p06_seed_default_data.sql"
    "p07_import_sample_data.sql"
    "p08_finalize_setup.sql"
)

# Function to execute SQL file
execute_sql_file() {
    local file=$1
    local step=$2
    
    echo -e "${YELLOW}[$step/8]${NC} Executing ${BLUE}$file${NC}..."
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Error: File $file not found!${NC}"
        exit 1
    fi
    
    if psql $PSQL_CONN -f "$file" -q; then
        echo -e "${GREEN}✅ $file completed successfully${NC}"
    else
        echo -e "${RED}❌ Error executing $file${NC}"
        exit 1
    fi
    echo ""
}

# Check if psql is available
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ Error: psql command not found. Please install PostgreSQL client.${NC}"
    exit 1
fi

# Test database connection
echo -e "${YELLOW}🔍 Testing Supabase database connection...${NC}"
if ! psql $PSQL_CONN -c "SELECT version();" > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Cannot connect to Supabase database${NC}"
    echo -e "${YELLOW}💡 Please check:${NC}"
    echo -e "   - SUPABASE_URL in .env file is correct"
    echo -e "   - SUPABASE_PASSWORD in .env file is correct"
    echo -e "   - Your internet connection"
    echo -e "   - Supabase database is accessible"
    exit 1
fi
echo -e "${GREEN}✅ Supabase database connection successful${NC}"
echo ""

# Confirm before proceeding
echo -e "${YELLOW}⚠️  WARNING: This will reset the entire Supabase database schema!${NC}"
echo -e "${YELLOW}⚠️  All existing data will be LOST!${NC}"
echo -e "${YELLOW}⚠️  Database: $SUPABASE_HOST${NC}"
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Setup cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Starting database setup...${NC}"
echo ""

# Execute all SQL files in order
for i in "${!SQL_FILES[@]}"; do
    execute_sql_file "${SQL_FILES[$i]}" $((i+1))
done

# Final validation
echo -e "${BLUE}🔍 Final validation...${NC}"
HEALTH_CHECK=$(psql $PSQL_CONN -t -c "SELECT COUNT(*) FROM view_database_health;" 2>/dev/null || echo "0")

if [ "$HEALTH_CHECK" -ge 8 ]; then
    echo -e "${GREEN}🎉 SUPABASE DATABASE SETUP COMPLETED SUCCESSFULLY!${NC}"
    echo ""
    echo -e "${BLUE}📊 Database Health Summary:${NC}"
    psql $PSQL_CONN -c "SELECT * FROM view_database_health;"
    echo ""
    echo -e "${GREEN}✅ Your Soul Sync Supabase database is ready to use!${NC}"
    echo -e "${YELLOW}💡 Next steps:${NC}"
    echo -e "   1. Your Flutter app should now connect automatically using .env"
    echo -e "   2. Test your API endpoints"  
    echo -e "   3. Check the README.md for maintenance commands"
else
    echo -e "${RED}❌ Setup completed but validation failed${NC}"
    echo -e "${YELLOW}💡 Please check the logs above for any errors${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Happy coding! 🎵${NC}"