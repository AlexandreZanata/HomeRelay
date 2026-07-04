# Plano de Implementação

> PC doméstico como servidor remoto de automação — guia completo de instalação e operação.

**Open source:** todos os passos usam software livre. Este guia vale para **qualquer PC** — não está amarrado a um hardware específico. Para clonar o repositório e instalar em **outra máquina**, comece por [INSTALACAO-EM-OUTRO-PC.md](INSTALACAO-EM-OUTRO-PC.md).

---

## 1. Visão geral do problema

Provedores de internet residencial costumam usar **CGNAT** (IP compartilhado). Isso implica:

- Você **não tem** um IP público real em casa.
- Configurar "abertura de porta" no roteador **não funciona** para acesso externo.
- Não é possível acessar o PC diretamente pela internet, mesmo conhecendo o IP exibido no roteador.

A solução inverte a lógica: **o PC de casa se conecta à VPS**, mantendo um túnel aberto. Como o PC inicia a conexão (saída para fora), o CGNAT não bloqueia. A VPS, com IP público fixo, vira a porta de entrada para chegar ao PC.

---

## 2. Arquitetura da solução

```
 [Você — celular/notebook, de qualquer lugar]
              │  SSH
              ▼
 [VPS — IP público fixo]  ◄──── túnel WireGuard permanente ────►  [PC de casa — Wi-Fi]
   age como "hub" / porta de entrada                               sem IP público, roda os bots
```

### Componentes

| Componente | Papel |
|------------|-------|
| **WireGuard** | VPN privada entre PC e VPS; o PC recebe IP interno (ex.: `10.8.0.2`) acessível a partir da VPS |
| **SSH** | Acesso remoto para gerenciar o PC; ProxyJump via VPS para acesso de qualquer lugar |
| **PM2 / systemd** | Mantém bots rodando 24/7 e reinicia automaticamente após falhas ou reboot |

### Fluxo de acesso

1. Você executa `ssh meupc` no notebook/celular.
2. O SSH conecta na VPS (`ProxyJump`).
3. A VPS encaminha a sessão pelo túnel WireGuard até `10.8.0.2` (PC).
4. Você gerencia bots, logs e configurações no PC de casa.

---

## 3. Requisitos

| Item | Especificação |
|------|---------------|
| PC doméstico | Pode ser antigo/fraco — sem placa de vídeo dedicada |
| Rede | Wi-Fi em casa (sem necessidade de cabo) |
| VPS | 1 vCPU / 1–2 GB RAM (Contabo, Hetzner, Oracle Free Tier, DigitalOcean etc.) |
| Instalação | Pendrive para gravar imagem Linux |
| WhatsApp | Número **dedicado** para automações (não use o pessoal) |

---

## Etapa 1 — Sistema operacional do PC

**Recomendação:** Debian 12 (Bookworm) instalação mínima, sem interface gráfica.

**Alternativa:** Ubuntu Server 24.04 LTS (Wi-Fi mais simples durante a instalação).

**Por quê:** leve, estável, suporte longo, roda Node.js/Python/Chromium sem problemas.

### Passos de instalação

1. Baixe a imagem Debian com firmware incluso (`firmware-...-netinst`) para o instalador reconhecer a placa Wi-Fi.
2. Grave no pendrive (Rufus ou balenaEtcher).
3. Na seleção de pacotes, **desmarque** "Debian desktop environment" e "GNOME" — mantenha apenas "SSH server" e "standard system utilities".
4. Configure o Wi-Fi durante a instalação (ou depois, conforme abaixo).

### Wi-Fi persistente no boot

```bash
sudo apt install network-manager -y
sudo nmcli device wifi connect "NOME_DA_REDE" password "SUA_SENHA"
sudo nmcli connection modify "NOME_DA_REDE" connection.autoconnect yes
```

### Evitar suspensão do PC

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

### BIOS/UEFI

Ative **"Restore on AC Power Loss"** / **"Power On After Power Failure"** — se faltar luz, o PC liga sozinho quando a energia voltar.

---

## Etapa 2 — Preparar a VPS

```bash
sudo apt update && sudo apt upgrade -y
sudo adduser seu_usuario
sudo usermod -aG sudo seu_usuario
sudo apt install ufw wireguard -y
sudo ufw allow OpenSSH
sudo ufw allow 51820/udp
sudo ufw enable
```

> Verifique também o **security group / firewall do painel da VPS** — UDP 51820 deve estar liberado além do `ufw`.

---

## Etapa 3 — Túnel WireGuard (PC ↔ VPS)

### Na VPS (servidor)

```bash
wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key
```

Crie `/etc/wireguard/wg0.conf`:

```ini
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = <conteúdo de server_private.key>

[Peer]
# PC de casa
PublicKey = <chave pública do PC — gerada abaixo>
AllowedIPs = 10.8.0.2/32
```

### No PC (cliente)

```bash
sudo apt install wireguard -y
wg genkey | sudo tee /etc/wireguard/client_private.key | wg pubkey | sudo tee /etc/wireguard/client_public.key
```

Crie `/etc/wireguard/wg0.conf`:

```ini
[Interface]
Address = 10.8.0.2/24
PrivateKey = <conteúdo de client_private.key>

[Peer]
PublicKey = <chave pública da VPS>
Endpoint = IP_DA_VPS:51820
AllowedIPs = 10.8.0.0/24
PersistentKeepalive = 25
```

> **`PersistentKeepalive = 25`** é essencial: mantém o túnel vivo atrás de NAT/Wi-Fi doméstico, evitando queda silenciosa da conexão.

### Ativar e testar

```bash
# Nos dois lados
sudo systemctl enable --now wg-quick@wg0

# Teste a partir da VPS
ping 10.8.0.2
```

---

## Etapa 4 — Acesso remoto via SSH

### No PC

```bash
sudo systemctl enable --now ssh
```

### Da VPS (acesso direto pelo túnel)

```bash
ssh seu_usuario@10.8.0.2
```

### De qualquer lugar (ProxyJump)

Adicione ao `~/.ssh/config` da sua máquina de administração:

```
Host meupc
    HostName 10.8.0.2
    User seu_usuario
    ProxyJump seu_usuario@IP_DA_VPS
```

Depois: `ssh meupc` de qualquer máquina com chave configurada.

### Reforço de segurança

```bash
ssh-keygen -t ed25519
ssh-copy-id seu_usuario@IP_DA_VPS
ssh-copy-id meupc
```

Desative login por senha em `/etc/ssh/sshd_config` nas **duas** máquinas:

```
PasswordAuthentication no
```

Reinicie o SSH após alterar: `sudo systemctl restart sshd`.

> **Nunca** exponha o SSH do PC diretamente à internet — apenas via túnel WireGuard.

---

## Etapa 5 — Automações (WhatsApp + agendamento de posts)

### Base Node.js

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install --lts
```

### WhatsApp

| Biblioteca | Prós | Contras |
|------------|------|---------|
| **Baileys** (recomendado) | Leve, sem Chromium, ideal para PC fraco | Menos exemplos na comunidade |
| **whatsapp-web.js** | Muito popular | Puppeteer/Chromium — alto consumo de RAM |

### Agendamento de posts

| Abordagem | Quando usar |
|-----------|-------------|
| Script Node.js/Python + `cron` | Poucas redes, rotinas simples |
| **n8n** (Docker self-hosted) | Interface visual, nós prontos para redes sociais e WhatsApp |

---

## Etapa 6 — Manter tudo rodando (PM2)

```bash
npm install -g pm2
pm2 start bot-whatsapp.js --name whatsapp-bot
pm2 start agendador-posts.js --name agendador
pm2 save
pm2 startup   # execute o comando que o PM2 imprimir
```

Garante restart automático após crash ou reboot do PC.

### Comandos úteis

```bash
pm2 status          # estado dos processos
pm2 logs whatsapp-bot
pm2 restart all
```

---

## Etapa 7 — Segurança

| Medida | Onde | Detalhe |
|--------|------|---------|
| `ufw` | PC e VPS | Liberar só o necessário (51820/udp WireGuard; 22/tcp restrito) |
| `fail2ban` | VPS | Protege SSH exposto publicamente |
| `unattended-upgrades` | PC e VPS | `sudo apt install unattended-upgrades -y` |
| SSH do PC | PC | **Nunca** exposto à internet — só via WireGuard |
| Chaves SSH | Todas | Ed25519; desabilitar senha |

---

## Etapa 8 — Estabilidade (Wi-Fi sem cabo)

### Watchdog de reconexão

Crie `/usr/local/bin/watchdog.sh` no PC:

```bash
#!/bin/bash
if ! ping -c 2 10.8.0.1 &> /dev/null; then
    systemctl restart wg-quick@wg0
    nmcli radio wifi off
    sleep 3
    nmcli radio wifi on
fi
```

```bash
sudo chmod +x /usr/local/bin/watchdog.sh
sudo crontab -e
# Adicione:
*/5 * * * * /usr/local/bin/watchdog.sh
```

### Recomendações físicas

- **Nobreak (UPS)** simples — evita corrupção por queda abrupta de energia.
- Posicione o PC com **bom sinal Wi-Fi** (longe de paredes grossas).

---

## Checklist final de testes

- [ ] `ping 10.8.0.2` funciona da VPS
- [ ] `ssh meupc` funciona de fora de casa
- [ ] Reiniciar o PC → Wi-Fi, WireGuard e PM2 voltam sozinhos
- [ ] Desligar e religar o Wi-Fi → watchdog reconecta em até 5 min
- [ ] Simular queda de energia → PC liga sozinho (BIOS configurada)

---

## Troubleshooting

| Problema | Causa provável | Solução |
|----------|----------------|---------|
| WireGuard não conecta | Firewall da VPS bloqueando UDP 51820 | Checar `ufw status` e security group do provedor |
| Wi-Fi não reconecta no boot | `autoconnect` não configurado | `nmcli connection modify "NOME_DA_REDE" connection.autoconnect yes` |
| Chromium/Puppeteer não abre | Dependências faltando | Instalar libs do Chromium ou migrar para Baileys |
| Bot WhatsApp desconecta | Sessão expirada ou banimento | Reduzir volume de envio; reescanear QR code |
| SSH via ProxyJump falha | Chave não copiada ou túnel down | Testar `ping 10.8.0.2` da VPS; verificar chaves |
| PM2 não inicia no boot | `pm2 startup` não executado | Rodar `pm2 startup` e aplicar comando gerado |

---

## Observações importantes

- **WhatsApp:** envio em massa sem opt-in viola os Termos de Uso e pode banir o número. Use número dedicado e respeite limites de envio.
- **Custos:** apenas a VPS — WireGuard, PM2 e n8n são open-source.
- **Jurídico:** este documento é orientação técnica, não assessoria jurídica sobre dados ou mensagens de marketing.

---

## Próximos passos (desenvolvimento)

1. Implementar scripts de automação em `src/` (WhatsApp, agendador).
2. Versionar configs WireGuard de forma segura (sem chaves privadas no git).
3. Adicionar monitoramento básico (health check do túnel + alertas).
4. Documentar cada bot em `docs/use-cases/`.
