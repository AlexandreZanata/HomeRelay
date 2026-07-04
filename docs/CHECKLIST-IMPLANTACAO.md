# Checklist de Implantação

> Marque cada item conforme concluir. Não avance para a próxima fase sem validar a anterior.

**Instalação em outro PC?** Cada máquina é uma implantação independente — gere **novas chaves WireGuard** no hardware de destino. Ver [INSTALACAO-EM-OUTRO-PC.md](INSTALACAO-EM-OUTRO-PC.md).

---

## Fase 0 — Preparação

- [ ] Repositório clonado (`git clone --recurse-submodules ...`) ou copiado via pendrive
- [ ] PC disponível (pode ser antigo/fraco) — **qualquer hardware compatível com Linux**
- [ ] Pendrive preparado com imagem Linux (Debian 12 firmware-netinst ou Ubuntu Server 24.04)
- [ ] VPS contratada (1 vCPU, 1–2 GB RAM)
- [ ] Número WhatsApp dedicado para automações
- [ ] Credenciais Wi-Fi anotadas (`NOME_DA_REDE`, senha)
- [ ] IP público da VPS anotado

---

## Fase 1 — PC doméstico (SO)

- [ ] Linux instalado **sem** ambiente gráfico
- [ ] SSH server habilitado
- [ ] Wi-Fi conecta automaticamente no boot (`autoconnect yes`)
- [ ] Suspensão/hibernação desabilitada (`systemctl mask sleep.target ...`)
- [ ] BIOS: "Power On After Power Failure" ativado
- [ ] Nobreak (UPS) instalado (recomendado)

---

## Fase 2 — VPS

- [ ] Sistema atualizado (`apt update && apt upgrade`)
- [ ] Usuário não-root criado com sudo
- [ ] `ufw` ativo: OpenSSH + UDP 51820
- [ ] Security group do provedor: UDP 51820 liberado
- [ ] WireGuard instalado

---

## Fase 3 — WireGuard

- [ ] Chaves geradas na VPS (`server_private.key`, `server_public.key`)
- [ ] Chaves geradas no PC (`client_private.key`, `client_public.key`)
- [ ] `/etc/wireguard/wg0.conf` configurado na VPS
- [ ] `/etc/wireguard/wg0.conf` configurado no PC (com `PersistentKeepalive = 25`)
- [ ] `systemctl enable --now wg-quick@wg0` nos dois lados
- [ ] **Teste:** `ping 10.8.0.2` funciona da VPS

---

## Fase 4 — SSH remoto

- [ ] Chave Ed25519 gerada na máquina de administração
- [ ] `ssh-copy-id` para VPS
- [ ] `ssh-copy-id` para PC (via VPS ou túnel)
- [ ] `~/.ssh/config` com Host `meupc` + ProxyJump
- [ ] **Teste:** `ssh meupc` funciona de fora de casa
- [ ] `PasswordAuthentication no` na VPS e no PC

---

## Fase 5 — Automações

- [ ] nvm + Node.js LTS instalados no PC
- [ ] Biblioteca WhatsApp escolhida (Baileys recomendado)
- [ ] Bot WhatsApp funcional (QR code escaneado, sessão persistida)
- [ ] Agendador de posts implementado (script + cron ou n8n)
- [ ] **Teste:** envio de mensagem de teste com sucesso
- [ ] **Teste:** post agendado executado no horário correto

---

## Fase 6 — PM2 e persistência

- [ ] PM2 instalado globalmente
- [ ] Bots registrados (`pm2 start ... --name ...`)
- [ ] `pm2 save` executado
- [ ] `pm2 startup` configurado (comando systemd aplicado)
- [ ] **Teste:** reboot do PC → bots voltam automaticamente

---

## Fase 7 — Segurança

- [ ] `ufw` configurado no PC (regras mínimas)
- [ ] `fail2ban` ativo na VPS
- [ ] `unattended-upgrades` instalado (PC e VPS)
- [ ] Chaves privadas WireGuard **não** commitadas no git
- [ ] SSH do PC **não** exposto à internet pública

---

## Fase 8 — Estabilidade Wi-Fi

- [ ] `/usr/local/bin/watchdog.sh` criado e executável
- [ ] Cron configurado (`*/5 * * * *`)
- [ ] **Teste:** desligar Wi-Fi → reconecta em até 5 min
- [ ] **Teste:** queda simulada de energia → PC liga sozinho

---

## Fase 9 — Validação final

- [ ] Todos os testes da [Etapa 8 do plano](PLANO-IMPLEMENTACAO.md#checklist-final-de-testes) passaram
- [ ] Documentação de credenciais em local seguro (gerenciador de senhas)
- [ ] Procedimento de recovery documentado (reescanear QR WhatsApp, restaurar sessão)

---

## Sign-off

| Fase | Responsável | Data | OK |
|------|-------------|------|----|
| SO + Wi-Fi | | | |
| VPS + WireGuard | | | |
| SSH remoto | | | |
| Automações + PM2 | | | |
| Segurança + Watchdog | | | |
