# CI Roadmap (kolejny etap)

## Cel
Dodać walidację jakości kodu Magento do workflow CI.

## Narzędzia do wdrożenia
- `phpstan`
- `phpcs` + `magento-coding-standard`
- `phpunit`
- `composer audit` (zależności)
- opcjonalnie: skan SAST (np. CodeQL)

## Proponowana kolejność
1. `composer validate`
2. `phpstan`
3. `phpcs`
4. `phpunit`
5. `composer audit`

## Kryterium przejścia
- brak błędów krytycznych
- brak nowych naruszeń standardu
- testy przechodzą
