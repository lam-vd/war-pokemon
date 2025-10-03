# ⚔️ WAR POKEMON - Pokémon Battle Arena

> Một ứng dụng web Rails hiện đại để khám phá, tìm kiếm và chiến đấu với Pokémon sử dụng PokéAPI

![Pokemon](https://img.shields.io/badge/Pokémon-API-yellow?style=for-the-badge&logo=pokemon)
![Rails](https://img.shields.io/badge/Rails-7.2.2-red?style=for-the-badge&logo=ruby-on-rails)
![Ruby](https://img.shields.io/badge/Ruby-3.1.7-red?style=for-the-badge&logo=ruby)
![Docker](https://img.shields.io/badge/Docker-Compose-blue?style=for-the-badge&logo=docker)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=for-the-badge&logo=mysql)
![Redis](https://img.shields.io/badge/Redis-7.0-red?style=for-the-badge&logo=redis)

## ✨ Tính Năng Chính

- 🔍 **Tìm kiếm Pokémon** - Tìm Pokémon theo tên hoặc ID với gợi ý thông minh
- 📊 **Chi tiết Pokémon** - Xem stats, types, abilities và sprite gallery
- ⚔️ **Battle System** - Hệ thống chiến đấu turn-based với animation real-time
- 🎲 **Random Pokémon** - Khám phá Pokémon ngẫu nhiên
- 📋 **Danh sách tổng hợp** - Browse 1000+ Pokémon với pagination
- 🆚 **So sánh Pokémon** - So sánh stats giữa các Pokémon
- 🎨 **Giao diện đẹp** - Vietnamese UI với responsive design
- ⚡ **Hiệu năng cao** - Fallback system và error handling
- 🐳 **Docker Ready** - Setup một lệnh với Docker Compose
- 📱 **Mobile Friendly** - Hoạt động hoàn hảo trên mọi thiết bị

## 🚀 Hướng Dẫn Chạy Ứng Dụng

### Yêu Cầu Hệ Thống

- **Docker** & **Docker Compose** (phiên bản mới nhất)
- **Git**
- **Kết nối internet** (để fetch data từ PokéAPI)

### Cài Đặt & Chạy

1. **Clone repository**

   ```bash
   git clone https://github.com/lam-vd/war-pokemon.git
   cd war-pokemon
   ```

2. **Khởi động ứng dụng**

   ```bash
   # Build và start tất cả services
   docker compose up --build

   # Hoặc chạy ngầm
   docker compose up -d
   ```

3. **Truy cập ứng dụng**

   - Mở http://localhost:3000 trong trình duyệt
   - Bắt đầu khám phá thế giới Pokémon! 🎉

4. **Dừng ứng dụng**
   ```bash
   docker compose down
   ```

### Các Lệnh Hữu Ích

```bash
# Xem logs
docker compose logs -f web

# Restart service
docker compose restart web

# Vào Rails console
docker compose exec web rails console

# Chạy tests (nếu có)
docker compose exec web bundle exec rspec
```

## 🛠 Tech Stack & Architecture

| Component       | Technology     | Version  | Mục đích            |
| --------------- | -------------- | -------- | ------------------- |
| **Backend**     | Ruby on Rails  | 7.2.2    | Web framework chính |
| **Language**    | Ruby           | 3.1.7    | Ngôn ngữ lập trình  |
| **Database**    | MySQL          | 8.0      | Lưu trữ dữ liệu     |
| **Cache**       | Redis          | Alpine   | Caching & sessions  |
| **HTTP Client** | Net::HTTP      | Built-in | API calls           |
| **Pokemon Gem** | poke-api-v2    | Latest   | PokéAPI integration |
| **Frontend**    | Bootstrap 5    | Latest   | Responsive UI       |
| **Icons**       | Font Awesome   | Latest   | Icons & animations  |
| **Container**   | Docker Compose | Latest   | Orchestration       |

## 🔄 Cách Sử Dụng AI trong Dự Án

Dự án này được phát triển với sự hỗ trợ đáng kể từ **GitHub Copilot AI**, đây là cách AI đã được tận dụng:

### 🤖 AI-Assisted Development Process

#### **1. Code Generation & Architecture Design**

```ruby
# AI giúp thiết kế service layer pattern
class PokemonServiceV2 < BaseService
  # AI suggest error handling và fallback mechanisms
  def find_pokemon(identifier)
    # AI generated comprehensive error handling
    begin
      pokemon = PokeApi.get(pokemon: identifier)
      format_pokemon_data(pokemon)
    rescue => e
      # AI suggested fallback strategy
      get_offline_pokemon_data(identifier) if network_error?(e)
    end
  end
end
```

#### **2. Battle System Logic**

- **AI đã thiết kế**: Turn-based battle algorithm
- **Damage calculation**: Dựa trên Pokemon stats thật
- **HP system**: Convert base stats thành battle HP
- **Animation logic**: Real-time battle log updates

#### **3. Frontend Development**

```javascript
// AI generated battle animation system
async function animateBattle(battleData) {
	// AI suggested smooth animation với proper timing
	for (const [index, logEntry] of battleData.log.entries()) {
		await new Promise((resolve) => {
			setTimeout(() => {
				// AI generated DOM manipulation
				updateBattleUI(logEntry);
				resolve();
			}, index * battleAnimationSpeed);
		});
	}
}
```

#### **4. Error Handling & Resilience**

AI đã giúp thiết kế comprehensive error handling:

- **Network timeouts**: Fallback to cached data
- **API rate limits**: Intelligent retry mechanisms
- **Missing data**: Graceful degradation
- **User experience**: Meaningful error messages

### 🎯 AI Decision Making Process

1. **Problem Analysis**: AI phân tích requirements và suggest architecture
2. **Code Generation**: AI viết boilerplate và complex logic
3. **Debugging**: AI giúp identify và fix bugs
4. **Optimization**: AI suggest performance improvements
5. **Documentation**: AI assist trong việc viết README và comments

## 📚 API Integration & Data Flow

### PokéAPI Integration Strategy

```ruby
# Multi-layer fallback system thiết kế bởi AI
def get_pokemon_data(id)
  # Layer 1: poke-api-v2 gem
  PokeApi.get(pokemon: id)
rescue NetworkError
  # Layer 2: Direct HTTP calls
  fetch_via_http(id)
rescue HTTPError
  # Layer 3: Cached/offline data
  get_fallback_data(id)
end
```

### Data Sources

1. **Primary**: [PokéAPI](https://pokeapi.co/) - Real-time data
2. **Secondary**: Direct HTTP calls với timeout handling
3. **Fallback**: Hardcoded popular Pokémon data

## 🎨 Quyết Định Thiết Kế & Rationale

### **1. Architecture Decisions**

#### **MVC + Service Layer Pattern**

```
Controllers → Services → External APIs
     ↓            ↓
   Views    →  Data Processing
```

**Lý do**:

- **Separation of concerns**: Controller chỉ handle HTTP, Service handle business logic
- **Testability**: Service layer dễ test hơn
- **Reusability**: Service có thể dùng ở nhiều controller

#### **Docker Compose Setup**

```yaml
services:
  web: # Rails app
  db: # MySQL database
  redis: # Caching layer
```

**Lý do**:

- **Development consistency**: Mọi người dev trong môi trường giống nhau
- **Production parity**: Dev environment giống production
- **Easy setup**: One command để start tất cả

### **2. Frontend Design Decisions**

#### **Bootstrap 5 + Custom CSS**

- **Bootstrap**: Rapid prototyping, responsive grid
- **Custom CSS**: Pokemon-specific styling, animations
- **Vietnamese Interface**: Accessibility cho người Việt

#### **Inline JavaScript cho Rails 7**

```erb
<script>
// Inline JS thay vì external files
// Lý do: Rails 7 asset pipeline changes
</script>
```

**Lý do**: Rails 7 thay đổi cách handle assets, inline JS đảm bảo compatibility

### **3. Performance Decisions**

#### **Caching Strategy**

- **Redis**: Session storage và API response caching
- **HTTP timeouts**: 10s để balance performance vs reliability
- **Fallback data**: Ensure app luôn functional

#### **Pagination Implementation**

```ruby
# Smart pagination với real API calls
def get_pokemon_list(limit: 20, offset: 0)
  # AI suggested efficient pagination
  fetch_pokemon_list_from_api(limit, offset)
rescue APIError
  generate_fallback_list(limit, offset)
end
```

### **4. Battle System Design**

#### **Turn-based Logic**

```ruby
# AI designed battle calculation
def calculate_damage(attacker, defender)
  base_damage = ((2 * 50 + 10) / 250.0) * (attack / defense.to_f) * 50 + 2
  critical_multiplier = rand(1..16) == 1 ? 1.5 : 1.0
  randomness = rand(85..100) / 100.0

  (base_damage * critical_multiplier * randomness).round
end
```

**Thiết kế dựa trên**:

- **Pokemon game formula**: Authentic damage calculation
- **Speed determines turn order**: Realistic battle mechanics
- **HP conversion**: Base stats → Battle HP
- **Random elements**: Critical hits, damage variance

## 🔧 Development & Deployment

### Local Development

```bash
# Setup development environment
docker compose up --build

# Check logs khi debug
docker compose logs -f web

# Access Rails console
docker compose exec web rails console
```

### Production Considerations

- **Environment variables**: Database credentials, API keys
- **SSL termination**: Nginx hoặc load balancer
- **Health checks**: `/up` endpoint for monitoring
- **Scaling**: Horizontal scaling với multiple web containers

## 📚 API Integration

This app integrates with [PokéAPI](https://pokeapi.co/) to fetch:

- Pokémon basic info (name, ID, sprites)
- Detailed stats (HP, Attack, Defense, etc.)
- Type information and effectiveness
- Abilities and move sets
- Evolution chains

## 🔧 Development

### Manual Setup (without Docker)

1. **Install dependencies**

   ```bash
   bundle install
   ```

2. **Setup database**

   ```bash
   rails db:create db:migrate
   ```

3. **Start services**
   ```bash
   # Start MySQL and Redis
   # Then start Rails
   rails server
   ```

### Project Structure

```
war-pokemon/
├── app/
│   ├── controllers/     # Rails controllers
│   ├── models/          # Data models
│   ├── views/           # HTML templates
│   └── services/        # PokéAPI integration
├── config/
│   ├── database.yml     # Database configuration
│   └── routes.rb        # Application routes
├── docker-compose.yml   # Docker setup
├── Dockerfile          # Container definition
└── Gemfile             # Ruby dependencies
```

## 🌟 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/pokemon-feature`)
3. Commit your changes (`git commit -m 'Add pokemon feature'`)
4. Push to the branch (`git push origin feature/pokemon-feature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🔗 Links

- [PokéAPI Documentation](https://pokeapi.co/docs/v2)
- [Rails Guides](https://guides.rubyonrails.org/)
- [Docker Documentation](https://docs.docker.com/)

---

Made with ❤️ by [lam-vd](https://github.com/lam-vd)

## 🎮 Tính Năng Chi Tiết

### **1. Pokemon Search & Discovery**

- **Intelligent search**: Tìm theo tên (tiếng Anh), ID, hoặc partial matches
- **Auto-suggestions**: Gợi ý khi gõ sai chính tả
- **Random discovery**: Khám phá Pokemon ngẫu nhiên với một click

### **2. Battle System** ⚔️

```
Player Pokemon  VS  Random Opponent
     ↓               ↓
Turn-based combat dựa trên Speed stat
     ↓
Real-time HP bars + animated battle log
     ↓
Victory/Defeat screen với statistics
```

**Features**:

- **Realistic damage calculation** dựa trên Attack/Defense
- **Critical hits** (1/16 chance, 50% extra damage)
- **Speed-based turn order** (fast Pokemon attacks first)
- **Animated battle log** với timing effects
- **HP visualization** với color-coded bars

### **3. Pokemon Information Display**

- **Complete stats**: HP, Attack, Defense, Sp.Atk, Sp.Def, Speed
- **Type system**: Color-coded types với proper colors
- **Sprite gallery**: Multiple views (front, back, shiny, official artwork)
- **Abilities & descriptions**: Comprehensive Pokemon data
- **Generation info**: Pokemon generation và habitat

### **4. Advanced Features**

- **Pagination system**: Browse 1000+ Pokemon efficiently
- **Compare functionality**: Side-by-side Pokemon comparison
- **Responsive design**: Mobile-first approach
- **Error resilience**: Graceful fallbacks khi API fails

## 🚨 Troubleshooting

### Common Issues & Solutions

#### **1. Container startup fails**

```bash
# Check if ports are available
sudo netstat -tulpn | grep :3000
sudo netstat -tulpn | grep :3306

# Kill processes using ports if needed
sudo kill -9 $(sudo lsof -t -i:3000)

# Restart with fresh build
docker compose down
docker compose up --build
```

#### **2. API connection errors**

```bash
# Check DNS resolution
docker compose exec web nslookup pokeapi.co

# Test direct API call
docker compose exec web curl -I https://pokeapi.co/api/v2/pokemon/1/

# If fails, app will use fallback data automatically
```

#### **3. Database connection issues**

```bash
# Reset database
docker compose down
docker volume rm war-pokemon_mysql_data
docker compose up

# Check database status
docker compose exec db mysql -u root -p -e "SHOW DATABASES;"
```

#### **4. Performance issues**

```bash
# Check container resources
docker stats

# Restart Redis if caching fails
docker compose restart redis

# Clear Docker cache
docker system prune -f
```

## 🌟 Demo & Screenshots

### **Home Page**

- Clean, modern interface với search functionality
- Featured Pokemon carousel
- Quick access buttons

### **Pokemon Detail Page**

- Comprehensive stats display với animated bars
- Sprite gallery với modal views
- Battle button integration
- Type effectiveness visualization

### **Battle Arena**

- Pre-battle setup với player Pokemon vs mystery opponent
- Real-time battle simulation với HP tracking
- Animated battle log với turn-by-turn updates
- Victory/defeat screens với battle statistics

### **Pokemon List**

- Paginated grid layout (20 Pokemon per page)
- Jump-to-page functionality
- Search integration
- Data source indicators (API vs fallback)

## 🔮 Future Enhancements

### **Planned Features**

- [ ] **Type effectiveness system** (Fire > Grass, Water > Fire)
- [ ] **Pokemon team builder** (6-Pokemon teams)
- [ ] **Move selection** thay vì auto-battle
- [ ] **Multiplayer battles** với WebSocket
- [ ] **Battle history & statistics**
- [ ] **Pokemon favorites** với user accounts
- [ ] **Shiny Pokemon showcase**
- [ ] **Evolution chain viewer**
- [ ] **Pokemon comparison charts** với Chart.js
- [ ] **Advanced search filters** (generation, type, stats range)

### **Technical Improvements**

- [ ] **WebSocket integration** for real-time battles
- [ ] **Progressive Web App** (PWA) support
- [ ] **GraphQL API** for more efficient data fetching
- [ ] **Background job processing** với Sidekiq
- [ ] **Full test coverage** với RSpec
- [ ] **CI/CD pipeline** với GitHub Actions
- [ ] **Kubernetes deployment** files

## 👥 Contributing

### **Development Workflow**

1. **Fork** repository
2. **Create feature branch**: `git checkout -b feature/new-feature`
3. **Make changes** với proper commit messages
4. **Test thoroughly**: Local testing + Docker testing
5. **Submit PR** với detailed description

### **Code Style**

- **Ruby**: Follow Rails conventions
- **JavaScript**: ES6+ features preferred
- **CSS**: BEM naming convention
- **Comments**: Vietnamese cho business logic, English cho technical

## 📄 License & Credits

### **Open Source Libraries Used**

- **Ruby on Rails** (7.2.2) - Web framework
- **poke-api-v2** gem - PokéAPI Ruby wrapper
- **Bootstrap 5** - CSS framework
- **Font Awesome** - Icons
- **MySQL** - Database
- **Redis** - Caching

### **Data Sources**

- **PokéAPI** (https://pokeapi.co/) - Comprehensive Pokémon data
- **Official Pokémon sprites** - Game artwork và sprites

### **AI Acknowledgment**

Dự án này được phát triển với sự hỗ trợ của **GitHub Copilot AI**:

- **Architecture design**: AI suggested MVC + Service pattern
- **Error handling**: AI designed comprehensive fallback systems
- **Battle system**: AI created damage calculation và animation logic
- **Code generation**: AI assisted trong việc viết boilerplate và complex features
- **Debugging**: AI helped identify và resolve technical issues

### **Author**

**Lam VD** - Full-stack developer với passion cho Pokémon và modern web development

---

## 🚀 Quick Commands

```bash
# Start application
docker compose up -d

# View logs
docker compose logs -f web

# Stop application
docker compose down

# Rebuild từ scratch
docker compose down && docker compose up --build

# Access Rails console
docker compose exec web rails console

# Database console
docker compose exec db mysql -u root -p

# Redis console
docker compose exec redis redis-cli
```

---

**⚡ Happy Pokemon Training! Gotta Code 'Em All! ⚡**
