# UC03 — Agendamento de posts em redes sociais

## Ator

Agendador de posts (script Node.js/Python + cron, ou workflow n8n).

## Pré-condições

- PC doméstico online com túnel WireGuard ativo
- Credenciais/API tokens das redes sociais configurados (variáveis de ambiente)
- Agendador registrado no PM2 (ou n8n rodando via Docker/systemd)

## Fluxo principal (script + cron)

1. Administrador define posts e horários em arquivo de configuração ou banco local.
2. Cron dispara o script no horário agendado.
3. Script valida conteúdo (texto, mídia, rede destino).
4. Script publica via API da rede social.
5. Script registra resultado (post ID, timestamp, erros) em log.

## Fluxo principal (n8n)

1. Administrador cria workflow visual no n8n com trigger de agendamento.
2. n8n executa nós de publicação no horário definido.
3. n8n registra execução no histórico interno.
4. Falhas disparam notificação (email, webhook ou log).

## Fluxo alternativo — falha de publicação

1. API da rede social retorna erro (token expirado, rate limit, mídia inválida).
2. Agendador registra falha com detalhes.
3. Agendador tenta retry configurado (ex.: 3 tentativas com backoff).
4. Se persistir, administrador é alertado para intervenção manual.

## Pós-condições

- Post publicado na rede social ou falha documentada.
- Log de execução disponível para auditoria.

## Regras de negócio

- Tokens/credenciais nunca commitados no git — usar `.env` (gitignored).
- Validar mídia (tamanho, formato) antes de tentar publicar.
- Respeitar rate limits de cada plataforma.

## Referências

- [Plano — Etapa 5](../PLANO-IMPLEMENTACAO.md#etapa-5--automações-whatsapp--agendamento-de-posts)
- [Glossário — n8n](../GLOSSARY.md#n8n)
