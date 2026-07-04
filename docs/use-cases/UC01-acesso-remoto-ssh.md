# UC01 — Acesso remoto ao PC via SSH

## Ator

Administrador do sistema (você), a partir de celular ou notebook fora de casa.

## Pré-condições

- Túnel WireGuard ativo entre PC (`10.8.0.2`) e VPS (`10.8.0.1`)
- Chave SSH Ed25519 configurada na máquina do administrador
- `~/.ssh/config` com Host `meupc` e ProxyJump para a VPS

## Fluxo principal

1. Administrador executa `ssh meupc` em qualquer rede (4G, Wi-Fi externo etc.).
2. SSH conecta na VPS via IP público.
3. VPS encaminha a sessão pelo túnel WireGuard até `10.8.0.2`.
4. Administrador obtém shell no PC doméstico.
5. Administrador gerencia bots, logs, configs e atualizações.

## Fluxo alternativo — túnel down

1. `ssh meupc` falha com timeout.
2. Administrador conecta na VPS: `ssh usuario@IP_DA_VPS`.
3. Testa conectividade: `ping 10.8.0.2`.
4. Se ping falhar, verifica WireGuard: `sudo wg show`.
5. Se necessário, reinicia WireGuard no PC (acesso físico ou aguarda watchdog).

## Pós-condições

- Sessão SSH ativa no PC doméstico.
- Nenhuma porta do PC exposta à internet pública.

## Regras de negócio

- Login por senha desabilitado (`PasswordAuthentication no`).
- Apenas chaves Ed25519 aceitas.
- SSH do PC acessível **somente** via túnel WireGuard.

## Referências

- [Plano — Etapa 4](../PLANO-IMPLEMENTACAO.md#etapa-4--acesso-remoto-via-ssh)
- [Glossário — ProxyJump](../GLOSSARY.md#proxyjump)
