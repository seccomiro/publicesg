# Docker Development Workflow

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd publicesg_platform
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```

3. **Build and start the containers**
   ```bash
   docker compose up --build
   ```

4. **Access the application**
   - Rails application: http://localhost:3000
   - PostgreSQL: localhost:5432
   - PostgreSQL Test DB: localhost:5433
   - Redis: localhost:6379

## Docker Commands

### Starting the application
```bash
# Start all services
docker compose up

# Start in background
docker compose up -d

# Rebuild containers
docker compose up --build
```

### Stopping the application
```bash
# Stop all services
docker compose down

# Stop and remove volumes (clean slate)
docker compose down -v
```

### Running commands in containers
```bash
# Rails console
docker compose exec web rails console

# Run migrations
docker compose exec web rails db:migrate

# Run tests
docker compose exec web rspec

# Access bash shell
docker compose exec web bash

# View logs
docker compose logs -f web
```

### Database commands
```bash
# Create databases
docker compose exec web rails db:create

# Run migrations
docker compose exec web rails db:migrate

# Drop databases
docker compose exec web rails db:drop

# Reset database
docker compose exec web rails db:reset
```

## Development Tips

1. **Volume Mounts**: The application code is mounted as a volume, so changes to your local files are immediately reflected in the container.

2. **Bundle Cache**: Gems are cached in a Docker volume to speed up builds. If you need to clean the cache:
   ```bash
   docker compose down -v
   docker compose up --build
   ```

3. **Database Persistence**: PostgreSQL data is stored in a Docker volume. To reset the database:
   ```bash
   docker compose down -v
   docker compose up
   ```

4. **Running Tests**: Tests use a separate PostgreSQL instance on port 5433:
   ```bash
   docker compose exec web rspec
   ```

5. **Debugging**: The containers are configured with `stdin_open: true` and `tty: true` for debugging support:
   ```bash
   docker compose exec web rails console
   ```

## Troubleshooting

### Port conflicts
If you get port conflict errors, check if services are already running:
```bash
# Check what's using port 3000
lsof -i :3000

# Check what's using port 5432
lsof -i :5432
```

### Database connection issues
Ensure the database service is healthy:
```bash
docker compose ps
docker compose logs postgres
```

### Permission issues
If you encounter permission issues with volumes:
```bash
# Fix ownership
docker compose exec web chown -R $(id -u):$(id -g) .
```

### Rebuilding from scratch
```bash
docker compose down -v
docker system prune -a
docker compose up --build
```

## Environment Variables

Key environment variables used in Docker:
- `DATABASE_URL`: PostgreSQL connection string
- `RAILS_ENV`: Rails environment (development/test/production)
- `RAILS_MAX_THREADS`: Number of threads for Puma
- `DATABASE_HOST`: Database host (postgres in Docker)
- `DATABASE_PORT`: Database port (5432)
- `DATABASE_USERNAME`: Database username (postgres)
- `DATABASE_PASSWORD`: Database password

## Docker Compose Services

- **postgres**: PostgreSQL database for development
- **postgres_test**: PostgreSQL database for testing
- **web**: Rails application
- **redis**: Redis for caching and background jobs

## Best Practices

1. Always use `docker compose` commands (not `docker-compose`)
2. Keep Docker images updated: `docker compose pull`
3. Regularly clean up unused images: `docker system prune`
4. Use `.dockerignore` to exclude unnecessary files from builds
5. Check container health before running commands: `docker compose ps`