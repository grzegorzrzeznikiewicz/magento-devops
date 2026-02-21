# Required GitHub Secrets and Variables

## Repository Secrets
- `VM1_HOST`
- `VM1_USER`
- `VM1_PASSWORD`
- `VM1_PORT`
- `GHCR_PAT` (token z uprawnieniami read:packages)
- `COMPOSER_PUBLIC_KEY`
- `COMPOSER_PRIVATE_KEY`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_ROOT_PASSWORD`
- `REDIS_PASSWORD`
- `OPENSEARCH_INITIAL_ADMIN_PASSWORD`
- `MAGENTO_ADMIN_USER`
- `MAGENTO_ADMIN_PASSWORD`
- `MAGENTO_ADMIN_EMAIL`

## Repository Variables
- `MAGENTO_VERSION` (aktualnie rekomendowane `2.4.8-p3`, potwierdzić przed deployem)
- `MAGENTO_BASE_URL` (np. `https://magento.gama-software.com/`)
- `MAGENTO_BACKEND_FRONTNAME` (np. `admin`)
- `MAGENTO_ADMIN_FIRSTNAME` (np. `Admin`)
- `MAGENTO_ADMIN_LASTNAME` (np. `User`)
- `MAGENTO_APP_REPO` (opcjonalnie, domyślnie `git@github.com:grzegorzrzeznikiewicz/magento-demo.git`)
