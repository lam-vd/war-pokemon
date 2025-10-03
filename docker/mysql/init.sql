-- Initial database setup for War Pokemon application
CREATE DATABASE IF NOT EXISTS war_pokemon_development CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS war_pokemon_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS war_pokemon_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges to pokemon_user
GRANT ALL PRIVILEGES ON war_pokemon_development.* TO 'pokemon_user'@'%';
GRANT ALL PRIVILEGES ON war_pokemon_test.* TO 'pokemon_user'@'%';
GRANT ALL PRIVILEGES ON war_pokemon_production.* TO 'pokemon_user'@'%';

FLUSH PRIVILEGES;
