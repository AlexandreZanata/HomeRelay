# Glossário de Domínio

> Linguagem ubíqua deste projeto. Documentação, scripts e conversas devem usar estes termos de forma consistente.

---

## PC Doméstico (Home PC)

**Definição:** Computador físico em casa que executa as automações (bots WhatsApp, agendador de posts).
**Não é o mesmo que:** VPS — o PC não possui IP público e inicia conexões de saída.
**Endereço na VPN:** `10.8.0.2` (padrão deste projeto).

---

## VPS (Hub)

**Definição:** Servidor na nuvem com IP público fixo que funciona como ponto de entrada e relay para o PC doméstico.
**Não é o mesmo que:** PC Doméstico — a VPS não rooda os bots; apenas mantém o túnel e recebe SSH externo.
**Endereço na VPN:** `10.8.0.1` (padrão deste projeto).

---

## CGNAT

**Definição:** Carrier-Grade NAT — técnica do provedor de internet que compartilha um único IP público entre vários assinantes residenciais.
**Impacto:** Impossibilita port forwarding tradicional; exige túnel reverso (WireGuard com conexão iniciada pelo PC).

---

## Túnel WireGuard

**Definição:** Conexão VPN criptografada e persistente entre PC doméstico e VPS, criando rede privada `10.8.0.0/24`.
**Configuração crítica:** `PersistentKeepalive = 25` no cliente (PC) para manter NAT aberto.

---

## ProxyJump

**Definição:** Mecanismo SSH que encadeia conexões — sua máquina → VPS → PC doméstico, sem expor o PC à internet.
**Alias padrão:** `meupc` no `~/.ssh/config`.

---

## Bot de Automação

**Definição:** Processo Node.js (ou Python) que executa tarefas agendadas — envio WhatsApp, publicação em redes sociais etc.
**Gerenciamento:** PM2 com auto-restart e persistência no boot.

---

## Watchdog

**Definição:** Script (`/usr/local/bin/watchdog.sh`) executado a cada 5 minutos via cron que verifica conectividade com a VPS e reinicia WireGuard/Wi-Fi se necessário.
**Motivação:** Conexão Wi-Fi doméstica é menos estável que cabo; reconexão automática é obrigatória.

---

## Baileys

**Definição:** Biblioteca Node.js que conecta ao WhatsApp via protocolo nativo, sem navegador/Chromium.
**Preferência:** Recomendada para PCs com pouca RAM.

---

## whatsapp-web.js

**Definição:** Biblioteca Node.js popular para WhatsApp via Puppeteer/Chromium em headless.
**Trade-off:** Maior consumo de memória; usar apenas se Baileys não atender.

---

## n8n

**Definição:** Plataforma de automação visual self-hosted (Docker) com nós para redes sociais, WhatsApp e agendamento.
**Quando usar:** Rotinas complexas ou equipe sem perfil para manter scripts customizados.

---

## PM2

**Definição:** Process manager para Node.js — mantém bots ativos, reinicia após crash e persiste lista de processos no boot.
**Comandos-chave:** `pm2 start`, `pm2 save`, `pm2 startup`.

---

## Número Dedicado (WhatsApp)

**Definição:** Linha telefônica separada usada exclusivamente para automações de mensagens.
**Regra:** Nunca usar número pessoal — risco de banimento por volume ou violação de ToS.

---

## Agent Harness

**Definição:** Conjunto de regras e scripts (`agent-rules/`, `.cursor/rules/`) que orientam agentes de IA durante o desenvolvimento deste repositório.
**Fonte:** [GoodPraticesForLLMSandAgents](https://github.com/AlexandreZanata/GoodPraticesForLLMSandAgents) (open source, MIT).

---

## Open Source

**Definição:** Projeto publicado sob licença MIT — código, documentação e stack de infraestrutura são software livre, sem vendor lock-in.
**Implicação:** Qualquer pessoa pode clonar e instalar em outro PC seguindo [INSTALACAO-EM-OUTRO-PC.md](INSTALACAO-EM-OUTRO-PC.md).
**Segredos:** Chaves e tokens permanecem locais (`.env`, arquivos no disco) — nunca versionados no git.
