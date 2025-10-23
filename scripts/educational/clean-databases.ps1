# Clean Databases for Liquibase Migration Test
Write-Host "=== Cleaning Databases for Liquibase Testing ===" -ForegroundColor Cyan

# Drop and recreate databases
Write-Host "`nDropping and recreating databases..." -ForegroundColor Yellow

docker exec customer-db psql -U postgres -c "DROP DATABASE IF EXISTS customerdb;"
docker exec customer-db psql -U postgres -c "CREATE DATABASE customerdb;"
Write-Host "Customer database cleaned" -ForegroundColor Green

docker exec document-db psql -U postgres -c "DROP DATABASE IF EXISTS documentdb;"
docker exec document-db psql -U postgres -c "CREATE DATABASE documentdb;"
Write-Host "Document database cleaned" -ForegroundColor Green

docker exec account-db psql -U postgres -c "DROP DATABASE IF EXISTS accountdb;"
docker exec account-db psql -U postgres -c "CREATE DATABASE accountdb;"
Write-Host "Account database cleaned" -ForegroundColor Green

docker exec notification-db psql -U postgres -c "DROP DATABASE IF EXISTS notificationdb;"
docker exec notification-db psql -U postgres -c "CREATE DATABASE notificationdb;"
Write-Host "Notification database cleaned" -ForegroundColor Green

Write-Host "`n=== Databases Ready for Liquibase Migrations ===" -ForegroundColor Cyan
Write-Host "You can now start the services to test Liquibase migrations" -ForegroundColor White
