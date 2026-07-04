# PC Antigo como Servidor Remoto de Automação

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Projeto 100% open source** — código, documentação e stack inteira são software livre (MIT). Qualquer pessoa pode clonar, instalar e operar em **qualquer computador**, sem licenças pagas, contas proprietárias ou vendor lock-in.

Transformar um PC doméstico em uma máquina acessível remotamente (via VPS), sem IP público e sem cabo de rede, para rodar automações 24/7 — agendamento de posts, disparo de mensagens no WhatsApp e rotinas similares.

> **Vai instalar em outro PC?** Siga [Instalação em outro computador](docs/INSTALACAO-EM-OUTRO-PC.md) — o repositório foi pensado para ser clonado e reproduzido em qualquer máquina.

## O que este projeto faz

Um PC de casa fica conectado à internet por Wi-Fi, atrás de CGNAT (sem IP público). Em vez de expor portas no roteador — o que não funciona nesse cenário — o PC **inicia** uma conexão permanente com uma VPS que possui IP fixo. A VPS age como hub: você acessa o PC de qualquer lugar via SSH, e os bots de automação rodam localmente no hardware de casa.

```
[Você — celular/notebook] ──SSH──► [VPS — IP público] ◄──WireGuard──► [PC de casa — Wi-Fi]
```

## Open source — o que isso garante

- **Código aberto:** repositório público no GitHub, licença MIT
- **Stack livre:** WireGuard, OpenSSH, PM2, Node.js, Baileys — zero dependência proprietária obrigatória
- **Reproduzível:** clone em outro PC e siga a documentação; cada instalação é independente
- **Segredos locais:** chaves VPN, tokens e senhas ficam no computador (`.env`, arquivos locais) — **nunca** no git
- **Único custo:** a VPS que você escolher (~€3–5/mês ou tier gratuito em alguns provedores)

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [**Instalação em outro PC**](docs/INSTALACAO-EM-OUTRO-PC.md) | **Clone, migração e segunda máquina** |
| [Plano de implementação](docs/PLANO-IMPLEMENTACAO.md) | Guia completo, etapa a etapa |
| [Checklist de implantação](docs/CHECKLIST-IMPLANTACAO.md) | Acompanhamento da instalação e testes |
| [Glossário](docs/GLOSSARY.md) | Termos técnicos e de domínio |
| [Casos de uso](docs/use-cases/) | Cenários operacionais do sistema |
| [AGENTS.md](AGENTS.md) | Ponto de entrada para agentes de IA |

## Stack principal

| Componente | Função |
|------------|--------|
| Debian 12 / Ubuntu Server | SO do PC (sem interface gráfica) |
| WireGuard | VPN privada PC ↔ VPS |
| SSH + ProxyJump | Acesso remoto seguro |
| PM2 / systemd | Bots sempre ativos e auto-restart |
| Node.js (nvm) | Runtime das automações |
| Baileys / n8n | WhatsApp e agendamento de posts |

## Requisitos mínimos

- 1 PC (pode ser antigo — 1 vCPU e 1–2 GB RAM bastam para os bots)
- Wi-Fi doméstico estável
- 1 VPS barata (Contabo, Hetzner, Oracle Free Tier, DigitalOcean etc.)
- Pendrive para instalar Linux
- Número de WhatsApp **dedicado** para automações

## Início rápido

```bash
# Clonar (inclui submódulo do Agent Harness)
git clone --recurse-submodules https://github.com/SEU_USUARIO/PC-ANTIGO-SERVIDOR.git
cd PC-ANTIGO-SERVIDOR
```

1. **Primeira instalação:** [Plano de implementação](docs/PLANO-IMPLEMENTACAO.md) — etapas 1–8
2. **Outro computador / migração:** [Instalação em outro PC](docs/INSTALACAO-EM-OUTRO-PC.md)
3. **Acompanhar progresso:** [Checklist](docs/CHECKLIST-IMPLANTACAO.md)

## Agent Harness

Este repositório usa o [Agent Harness](https://github.com/AlexandreZanata/GoodPraticesForLLMSandAgents) para orientar agentes de IA durante o desenvolvimento. Regras em `agent-rules/` e `.cursor/rules/`.

## Avisos legais

- Envio de mensagens em massa no WhatsApp sem opt-in viola os Termos de Uso e pode resultar em banimento.
- Este projeto usa ferramentas open-source; o único custo recorrente é a VPS.
- A documentação é orientação técnica, não assessoria jurídica sobre dados ou marketing.

## Licença

[MIT](LICENSE) — use, modifique e redistribua livremente. Atribuições de terceiros em [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Contribuir

Issues e pull requests são bem-vindos. Este projeto existe para ser usado por qualquer pessoa com um PC antigo e uma VPS — mantenha documentação clara para quem instalar do zero em outra máquina.
