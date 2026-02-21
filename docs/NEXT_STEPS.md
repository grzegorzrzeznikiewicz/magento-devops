# Next Steps

1. Utworzyć repo `magento-devops` na GitHub.
2. Potwierdzić dostęp SSH z VM do repo aplikacyjnego `magento-demo`.
2. Wypchnąć kod lokalny do `main`.
3. Ustawić Secrets/Variables wg `REQUIRED_SECRETS.md` lub skryptem `scripts/sync-github-config.sh`.
4. Na VM1 zainstalować Docker + Compose plugin.
5. Włączyć workflow deploy po pierwszym push.
6. Skonfigurować cron backupu:
   - codziennie dump DB
   - retencja 3 dni
