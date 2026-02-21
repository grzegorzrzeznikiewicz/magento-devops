# magento-devops

Repozytorium infrastruktury i deploymentu Magento 2 na VM.

## Zakres
- `docker-compose.yml` i obrazy kontenerów,
- workflowy GitHub Actions (deploy/rollback/CI),
- skrypty operacyjne (instalacja, backup, bootstrap),
- dokumentacja wymagań sekretów i kroków wdrożeniowych.

## Relacja z repo aplikacji
- kod Magento jest w osobnym repo: `magento-demo`,
- ten projekt montuje kod aplikacji w `./app`,
- deployment synchronizuje `app` z `origin/main` repo `magento-demo`.

## Kluczowa zmienna repo
- `MAGENTO_APP_REPO` (GitHub Variable, opcjonalnie): URL SSH repo aplikacji,
- domyślnie: `git@github.com:grzegorzrzeznikiewicz/magento-demo.git`.
