# UC04 — Reconexão automática após queda de rede

## Ator

Watchdog (`/usr/local/bin/watchdog.sh`), executado via cron a cada 5 minutos.

## Pré-condições

- WireGuard configurado e habilitado no boot
- NetworkManager gerenciando Wi-Fi com `autoconnect yes`
- Script watchdog instalado e agendado no cron

## Fluxo principal — túnel saudável

1. Cron executa watchdog a cada 5 minutos.
2. Watchdog faz `ping -c 2 10.8.0.1` (VPS via túnel).
3. Ping responde — watchdog encerra sem ação.

## Fluxo principal — túnel ou Wi-Fi down

1. Cron executa watchdog.
2. Ping para `10.8.0.1` falha.
3. Watchdog reinicia WireGuard: `systemctl restart wg-quick@wg0`.
4. Watchdog reinicia rádio Wi-Fi: `nmcli radio wifi off` → sleep 3s → `on`.
5. NetworkManager reconecta à rede doméstica.
6. WireGuard restabelece túnel com `PersistentKeepalive`.
7. Próximo ping (até 5 min) confirma recuperação.

## Fluxo alternativo — falha persistente

1. Watchdog falha por 3+ ciclos consecutivos (15+ minutos).
2. PM2 continua tentando manter bots locais, mas sem conectividade externa.
3. Administrador recebe alerta (monitoramento futuro) ou detecta via `ssh meupc` indisponível.
4. Se necessário, intervenção física no PC (verificar roteador, sinal Wi-Fi, energia).

## Pós-condições

- Túnel WireGuard restaurado.
- Bots retomam operação normal (WhatsApp reconecta sessão, agendador retoma).

## Regras de negócio

- Intervalo de verificação: 5 minutos (balanceia detecção vs. carga).
- Reiniciar Wi-Fi apenas após falha de ping no túnel (não a cada ciclo).
- PC configurado para ligar automaticamente após queda de energia (BIOS).

## Referências

- [Plano — Etapa 8](../PLANO-IMPLEMENTACAO.md#etapa-8--estabilidade-wi-fi-sem-cabo)
- [Glossário — Watchdog](../GLOSSARY.md#watchdog)
- [Checklist — Fase 8](../CHECKLIST-IMPLANTACAO.md#fase-8--estabilidade-wi-fi)
