# VMS Frontend

Flutter Web frontend for the Vehicle Management System (VMS). It uses GoRouter
for navigation and calls the separate Spring Boot backend through the REST API.

## Repositories

This project requires both repositories:

- `vms-frontend`: Flutter Web application
- `vms-backend`: Spring Boot REST API

The frontend does not contain database credentials or backend secrets.

## Prerequisites

Install and configure:

- Git
- Flutter stable SDK
- Chrome or another supported browser
- Access to the private GitHub repositories
- Java and Maven/JDK for running `vms-backend` locally

Verify Flutter:

```powershell
flutter doctor
flutter --version
```

## Run locally on a Windows, macOS, or Linux computer

### 1. Clone the repositories

```powershell
git clone https://github.com/0jayer/vms-frontend.git
git clone https://github.com/0jayer/vms-backend.git
```

Clone the repositories into separate folders. Authentication may be required
because both repositories are private.

### 2. Start the backend

Open the `vms-backend` folder and configure its required environment variables
and PostgreSQL connection. Then start Spring Boot.

For a Maven wrapper on Windows:

```powershell
.\mvnw.cmd spring-boot:run
```

For macOS or Linux:

```sh
./mvnw spring-boot:run
```

The local API normally runs at `http://localhost:8080`.
Confirm it using:

```text
http://localhost:8080/api/health
```

For the backend's environment variables and database setup, use the
`vms-backend` README.

### 3. Install frontend dependencies

```powershell
cd vms-frontend
flutter pub get
```

### 4. Start Flutter Web

With the backend running locally:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

On macOS or Linux, the command is the same.

To use the deployed backend instead:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=https://YOUR-BACKEND.onrender.com
```

Do not include `/api` or a trailing slash in `API_BASE_URL`. API paths such as
`/api/auth/login` and `/api/vehicles` are added by the application.

The backend URL defaults to `http://localhost:8080` when no
`API_BASE_URL` value is supplied.

## Run checks locally

```powershell
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=http://localhost:8080
```

The production web files are generated in `build/web`.

## Netlify deployment

The repository contains:

- `netlify.toml`: build and publish settings
- `scripts/netlify-build.sh`: installs Flutter stable and creates the web build
- `web/_redirects`: routes all SPA requests to `index.html`

### Import the private repository

1. Sign in to Netlify with GitHub.
2. Select **Add new site → Import an existing project**.
3. Select `vms-frontend`.
4. Select the `main` branch.
5. Netlify should detect the settings in `netlify.toml`.

Use these settings if they are entered manually:

| Setting | Value |
| --- | --- |
| Branch | `main` |
| Build command | `bash scripts/netlify-build.sh` |
| Publish directory | `build/web` |

### Configure the production API URL

Under **Site configuration → Environment variables**, add:

| Name | Value |
| --- | --- |
| `API_BASE_URL` | Public HTTPS URL of the deployed backend |

Example:

```text
https://YOUR-BACKEND.onrender.com
```

Do not use `localhost`, an HTTP backend URL, a database URL, or a secret.
Frontend environment values are compiled into the browser application.

Netlify builds the frontend with:

```sh
flutter build web --release --dart-define="API_BASE_URL=${API_BASE_URL:-http://localhost:8080}"
```

Trigger a deployment after setting or changing `API_BASE_URL`.

The production frontend is currently:

```text
https://vmsfrontend.netlify.app
```

The hash in `/#/login` is GoRouter's client-side route. The site origin used
for CORS is `https://vmsfrontend.netlify.app`, without `/#/login` or a trailing
slash.

## Render backend deployment

The backend repository must also be deployed to Render.

Configure these Render environment variables:

| Name | Purpose |
| --- | --- |
| `DB_URL` | PostgreSQL JDBC URL |
| `DB_USERNAME` | PostgreSQL username |
| `DB_PASSWORD` | PostgreSQL password |
| `JWT_SECRET` | Random secret containing at least 32 characters |
| `ADMIN_USERNAME` | Initial administrator username |
| `ADMIN_PASSWORD` | Strong initial administrator password |
| `APP_CORS_ALLOWED_ORIGINS` | Exact Netlify origin |

Set `APP_CORS_ALLOWED_ORIGINS` to:

```text
https://vmsfrontend.netlify.app
```

Do not put database credentials, JWT secrets, or administrator passwords in
GitHub or the Flutter application. Store them as Render environment variables.

Verify the backend deployment at:

```text
https://YOUR-BACKEND.onrender.com/api/health
```

## Deployment verification checklist

- [ ] Backend health endpoint reports both `status: UP` and `database: UP`.
- [ ] Netlify build finishes successfully.
- [ ] `https://vmsfrontend.netlify.app` opens.
- [ ] Direct routes such as `/dashboard` and `/vehicles` open correctly.
- [ ] `API_BASE_URL` in Netlify is the public HTTPS backend URL.
- [ ] `APP_CORS_ALLOWED_ORIGINS` in Render is `https://vmsfrontend.netlify.app`.
- [ ] Login works over the deployed frontend.
- [ ] No database credentials or secrets appear in GitHub or browser assets.

## Security note

Any value compiled into Flutter Web can be viewed by users in the browser.
Only public API URLs should be configured in the frontend. Database credentials,
JWT signing secrets, and administrator passwords must remain on the backend
or in Render environment variables.
