# AGENTS.md — PC Antigo Servidor de Automação

> Ponto de entrada para agentes de IA (Cursor, Claude Code, Codex etc.) neste repositório.

**Idioma da documentação do projeto:** Português (docs/, README, casos de uso).
**Idioma do código:** Inglês — nomes de variáveis, funções, commits e comentários.

---

## O que é este repositório

| É | Não é |
|---|-------|
| Projeto **100% open source** (MIT) — clone e instale em qualquer PC | SaaS, serviço fechado ou vendor lock-in |
| Documentação + código de automação para PC doméstico remoto | Template genérico de Agent Harness |
| Infraestrutura WireGuard + SSH + PM2 + bots | App pronto para deploy sem configuração |
| Reproduzível em **outro computador** a qualquer momento | Amarrado a um hardware ou VPS específicos |

**Objetivo:** transformar um PC de casa (sem IP público, Wi-Fi) em servidor de automação 24/7 acessível via VPS.

**Instalar em outra máquina:** [docs/INSTALACAO-EM-OUTRO-PC.md](docs/INSTALACAO-EM-OUTRO-PC.md)

---

## Leia antes de implementar

1. [README.md](README.md) — visão geral
2. [docs/PLANO-IMPLEMENTACAO.md](docs/PLANO-IMPLEMENTACAO.md) — arquitetura e etapas
3. [docs/GLOSSARY.md](docs/GLOSSARY.md) — termos de domínio (use exatamente como definido)
4. [docs/use-cases/](docs/use-cases/) — fluxos operacionais

Quando regras do harness conflitarem com código existente, **as regras prevalecem** — salvo override explícito do usuário.

---

## Agent Harness (regras de desenvolvimento)

```bash
pip install -r .agent-harness/harness/requirements.txt   # uma vez por máquina
./agent-harness/rules-path.sh
```

| Contexto | `rules_dir` |
|----------|-------------|
| Este projeto | `agent-rules/` |

### Sempre carregar (base)

1. `agent-rules/AGENT-CORE-PRINCIPLES.md`
2. `agent-rules/00-core/size-and-complexity-limits.md`
3. `agent-rules/04-testing/contract-first-tests.md`
4. `agent-rules/09-ai-agent-specific/token-economy.md`
5. `agent-rules/09-ai-agent-specific/anti-hallucination.md`

Cursor aplica automaticamente `.cursor/rules/*.mdc`.

### Carregar por tarefa (2–6 arquivos)

```bash
./agent-harness/resolve-rules.sh <palavras-chave da tarefa>
```

| Tarefa | Exemplo |
|--------|---------|
| Script WhatsApp | `./agent-harness/resolve-rules.sh whatsapp bot node pm2` |
| Infra WireGuard/SSH | `./agent-harness/resolve-rules.sh security ssh network` |
| Agendador / cron | `./agent-harness/resolve-rules.sh api schedule cron` |
| Testes | `./agent-harness/resolve-rules.sh test contract unit` |

---

## Protocolo do agente

1. Ler documentação do projeto (`docs/`) antes de codificar.
2. Manter o projeto **reproduzível em qualquer PC** — nunca hardcodar IPs, chaves ou paths de máquina específica.
3. Usar termos do [Glossário](docs/GLOSSARY.md) — não inventar nomenclatura.
3. **Perguntar** se requisitos de negócio estiverem em branco — nunca assumir.
4. Menor diff possível; uma mudança lógica por commit.
5. **Nunca** commitar chaves privadas, tokens ou `.env`.
6. Verificar após cada edição — não afirmar que testes passaram sem executá-los.
7. Seguir [Checklist de implantação](docs/CHECKLIST-IMPLANTACAO.md) ao implementar infra.

---

## Estrutura prevista do repositório

```
docs/                  # Documentação (este é o foco atual)
src/                   # Scripts de automação (futuro)
  bots/                # WhatsApp, agendador
  infra/               # Watchdog, helpers
.env.example           # Variáveis sem segredos (futuro)
agent-rules/           # Regras do harness (symlink)
agent-harness/         # Scripts resolve-rules (symlink)
.cursor/rules/         # Regras Cursor always-on
```

---

## Segurança — regras invioláveis

- SSH do PC **nunca** exposto à internet — só via WireGuard.
- Credenciais WhatsApp e APIs em `.env` (gitignored).
- Número WhatsApp dedicado; respeitar ToS e opt-in.
- `ufw` + `fail2ban` conforme [Plano Etapa 7](docs/PLANO-IMPLEMENTACAO.md#etapa-7--segurança).

---

## Referências

| Documento | Propósito |
|-----------|-----------|
| [docs/PLANO-IMPLEMENTACAO.md](docs/PLANO-IMPLEMENTACAO.md) | Guia técnico completo |
| [docs/CHECKLIST-IMPLANTACAO.md](docs/CHECKLIST-IMPLANTACAO.md) | Validação fase a fase |
| [agent-rules/AGENT-CORE-PRINCIPLES.md](agent-rules/AGENT-CORE-PRINCIPLES.md) | Contrato de arquitetura |
| [docs/INSTALACAO-EM-OUTRO-PC.md](docs/INSTALACAO-EM-OUTRO-PC.md) | Clone e instalação em outra máquina |
| [LICENSE](LICENSE) | MIT — open source |
| [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) | Licenças de terceiros |
