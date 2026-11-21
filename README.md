# vms-frontend

# VMS Frontend

Flutter web application for the VMS project.

## Local development

The backend API URL is supplied at build or run time:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

The default when no value is supplied is `http://localhost:8080`.

## Netlify deployment

Import this private GitHub repository from Netlify. No database credentials or
backend secrets belong in this Flutter application.

Configure these Netlify settings:

- Branch: `main`
- Build command: `bash scripts/netlify-build.sh`
- Publish directory: `build/web`
- Environment variable: `API_BASE_URL=<the public HTTPS URL of the backend>`

The repository build script installs the Flutter stable SDK on Netlify and
builds `build/web`.
