# VMS Backend

Spring Boot REST API for the VMS frontend.

## Render deployment

Create a Render Web Service for this repository.

Build command:

```sh
./mvnw clean package -DskipTests
```

Start command:

```sh
java -Dserver.port=$PORT -jar target/vms-backend-0.0.1-SNAPSHOT.jar
```

Configure these Render environment variables:

| Variable | Value |
| --- | --- |
| `DB_URL` | `jdbc:postgresql://HOST:5432/DATABASE` |
| `DB_USERNAME` | PostgreSQL username |
| `DB_PASSWORD` | PostgreSQL password |
| `JWT_SECRET` | Random secret with at least 32 characters |
| `ADMIN_USERNAME` | Initial administrator username |
| `ADMIN_PASSWORD` | Strong initial administrator password |
| `APP_CORS_ALLOWED_ORIGINS` | Exact deployed Netlify origin, e.g. `https://your-site.netlify.app` |

Do not commit database credentials or authentication secrets. The
`APP_CORS_ALLOWED_ORIGINS` value must not include a trailing slash.

After deployment, verify `https://YOUR-SERVICE.onrender.com/api/health`.