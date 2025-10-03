# 🔥 WAR POKEMON

> A modern Rails web application for exploring and battling with Pokémon using PokéAPI

![Pokemon](https://img.shields.io/badge/Pokémon-API-yellow?style=for-the-badge&logo=pokemon)
![Rails](https://img.shields.io/badge/Rails-7.2.2-red?style=for-the-badge&logo=ruby-on-rails)
![Ruby](https://img.shields.io/badge/Ruby-3.1.7-red?style=for-the-badge&logo=ruby)
![Docker](https://img.shields.io/badge/Docker-Compose-blue?style=for-the-badge&logo=docker)

## ✨ Features

- 🔍 **Search Pokémon** - Find any Pokémon by name or ID
- 📊 **Pokémon Stats** - View detailed stats, types, and abilities
- 🎨 **Beautiful UI** - Modern, responsive design with smooth animations
- ⚡ **Fast Performance** - Redis caching for optimal speed
- 🐳 **Docker Ready** - One-command setup with Docker Compose
- 📱 **Mobile Friendly** - Works perfectly on all devices

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Git

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/lam-vd/war-pokemon.git
   cd war-pokemon
   ```

2. **Start the application**

   ```bash
   docker compose up
   ```

3. **Access the app**
   - Open http://localhost:3000 in your browser
   - Start exploring Pokémon! 🎉

That's it! The app will automatically set up MySQL, Redis, and Rails.

## 🛠 Tech Stack

| Component       | Technology    | Version |
| --------------- | ------------- | ------- |
| **Backend**     | Ruby on Rails | 7.2.2   |
| **Language**    | Ruby          | 3.1.7   |
| **Database**    | MySQL         | 8.0     |
| **Cache**       | Redis         | Alpine  |
| **HTTP Client** | HTTParty      | Latest  |
| **Web Server**  | Puma          | 7.0+    |
| **Container**   | Docker        | Latest  |

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
