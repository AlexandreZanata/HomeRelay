# Instalação em outro computador

> Este projeto é **100% open source**. Qualquer pessoa pode clonar, instalar e operar em **qualquer PC** — inclusive substituir o hardware original ou rodar em paralelo em outra máquina.

---

## Princípios

| Princípio | O que significa na prática |
|-----------|----------------------------|
| **Open source** | Código, documentação e scripts sob licença MIT — sem custo de licença |
| **Sem vendor lock-in** | WireGuard, PM2, Node.js, Baileys/n8n — tudo software livre |
| **Reproduzível** | Mesmo repositório + mesma documentação = mesma instalação em outro PC |
| **Segredos locais** | Chaves WireGuard, tokens e senhas ficam **no computador**, nunca no git |
| **Independente por máquina** | Cada PC é uma instalação separada (IP VPN `10.8.0.x`, chaves próprias) |

---

## Cenários comuns

### A — Trocar de PC (migrar automações)

Você comprou/outro PC antigo e quer mover as automações para lá.

1. Clone o repositório no **novo** PC (ou copie via pendrive — ver abaixo).
2. Siga o [Plano de implementação](PLANO-IMPLEMENTACAO.md) do zero no hardware novo.
3. Na VPS, adicione um **novo peer** WireGuard (ou substitua o peer antigo).
4. Reconfigure `.env`, escaneie QR do WhatsApp no número dedicado.
5. Desligue o PC antigo quando o novo estiver validado no [Checklist](CHECKLIST-IMPLANTACAO.md).

### B — Segundo PC em paralelo (outra casa ou backup)

1. Clone o repositório no segundo PC.
2. Use **outro IP** na VPN (ex.: `10.8.0.3` em vez de `10.8.0.2`).
3. Adicione segundo `[Peer]` no `wg0.conf` da VPS.
4. Cada PC tem suas próprias chaves WireGuard e sessão WhatsApp (se aplicável).

### C — Outra pessoa instala a partir do GitHub

Qualquer contribuidor ou usuário:

1. Clona o repositório público.
2. Lê a documentação em `docs/`.
3. Provisiona **sua própria** VPS e **seu próprio** PC.
4. Não precisa de conta, API key ou serviço pago além da VPS escolhida.

---

## Passo a passo — clonar e preparar

### 1. Obter o repositório

**Com internet (recomendado):**

```bash
git clone --recurse-submodules https://github.com/SEU_USUARIO/PC-ANTIGO-SERVIDOR.git
cd PC-ANTIGO-SERVIDOR
```

> `--recurse-submodules` baixa o Agent Harness (`.agent-harness/`). Sem isso, rode depois: `git submodule update --init --recursive`.

**Sem internet no PC alvo (pendrive):**

```bash
# Na máquina com internet
git clone --recurse-submodules https://github.com/SEU_USUARIO/PC-ANTIGO-SERVIDOR.git
tar czf pc-antigo-servidor.tar.gz PC-ANTIGO-SERVIDOR/

# Copie pc-antigo-servidor.tar.gz para o pendrive
# No PC de destino:
tar xzf pc-antigo-servidor.tar.gz
cd PC-ANTIGO-SERVIDOR
```

### 2. Instalar dependências do harness (opcional — só para dev com agentes de IA)

```bash
pip install -r .agent-harness/harness/requirements.txt
./agent-harness/install.sh . --symlink   # se ainda não instalado
```

Para **só operar** o servidor (WireGuard, bots, PM2), a documentação em `docs/` basta — não é obrigatório rodar o harness.

### 3. Configurar segredos (nunca commitar)

```bash
cp .env.example .env    # quando existir — preencha localmente
chmod 600 .env
```

O que **nunca** entra no git:

- Chaves privadas WireGuard (`*.key`)
- Senhas Wi-Fi, SSH, VPS
- Tokens de API (WhatsApp, redes sociais)
- Arquivos de sessão WhatsApp

### 4. Seguir a instalação de infraestrutura

Ordem fixa — detalhes em [PLANO-IMPLEMENTACAO.md](PLANO-IMPLEMENTACAO.md):

1. Linux no PC (Etapa 1)
2. VPS preparada (Etapa 2)
3. WireGuard PC ↔ VPS (Etapa 3) — **gere chaves novas neste PC**
4. SSH remoto (Etapa 4)
5. Automações + PM2 (Etapas 5–6)
6. Segurança + watchdog (Etapas 7–8)

Marque progresso em [CHECKLIST-IMPLANTACAO.md](CHECKLIST-IMPLANTACAO.md).

---

## WireGuard — novo PC na mesma VPS

Ao instalar em **outro** computador usando a **mesma** VPS, edite `/etc/wireguard/wg0.conf` na VPS:

**Opção 1 — Substituir PC antigo** (mesmo IP `10.8.0.2`):

```ini
[Peer]
# PC de casa (novo hardware)
PublicKey = <NOVA_chave_publica_do_PC>
AllowedIPs = 10.8.0.2/32
```

**Opção 2 — PC adicional** (novo IP):

```ini
[Peer]
# PC secundário
PublicKey = <chave_publica_do_segundo_PC>
AllowedIPs = 10.8.0.3/32
```

No **novo PC**, use o IP correspondente em `[Interface] Address`.

Reinicie WireGuard nos dois lados:

```bash
sudo systemctl restart wg-quick@wg0
```

---

## Validar instalação no novo PC

Execute os mesmos testes do checklist final:

- [ ] `ping 10.8.0.2` (ou `.3`) funciona **da VPS**
- [ ] `ssh meupc` funciona **de fora de casa**
- [ ] Reboot → Wi-Fi, WireGuard e PM2 sobem sozinhos
- [ ] Watchdog reconecta após queda de Wi-Fi (até 5 min)

---

## Atualizar instalação existente

Quando houver novas versões no GitHub:

```bash
cd PC-ANTIGO-SERVIDOR
git pull
git submodule update --remote .agent-harness   # se usar harness
# Reinicie bots se necessário:
pm2 restart all
```

Configs locais (`.env`, WireGuard, sessão WhatsApp) **não são sobrescritas** pelo `git pull`.

---

## Ferramentas 100% open source usadas

| Ferramenta | Licença | Função |
|------------|---------|--------|
| WireGuard | GPL v2 | VPN PC ↔ VPS |
| OpenSSH | BSD | Acesso remoto |
| PM2 | AGPL-3.0 | Gerenciador de processos Node |
| Node.js | MIT | Runtime dos bots |
| Baileys | MIT | WhatsApp (protocolo nativo) |
| n8n | Sustainable Use License | Automação visual (opcional) |
| Debian / Ubuntu | GPL / diversas | Sistema operacional |

Nenhum componente proprietário ou fechado é **obrigatório** para o funcionamento básico.

---

## Perguntas frequentes

**Preciso pagar algo além da VPS?**
Não. Software é gratuito; o único custo recorrente típico é a VPS (~€3–5/mês ou tier free em alguns provedores).

**Posso forkar e modificar?**
Sim. Licença MIT permite uso, modificação e redistribuição com atribuição.

**Meus segredos vão para o GitHub?**
Não, se você seguir `.gitignore`. Apenas código e documentação são públicos.

**Funciona em outro SO que não Debian/Ubuntu?**
A arquitetura (WireGuard + SSH + PM2) funciona em qualquer Linux. Os comandos do plano foram testados/documentados para Debian 12 e Ubuntu Server 24.04.

---

## Referências

- [README.md](../README.md) — visão geral open source
- [PLANO-IMPLEMENTACAO.md](PLANO-IMPLEMENTACAO.md) — guia técnico completo
- [CHECKLIST-IMPLANTACAO.md](CHECKLIST-IMPLANTACAO.md) — validação fase a fase
- [LICENSE](../LICENSE) — MIT
