# UC02 — Envio automatizado de WhatsApp

## Ator

Bot de automação (processo Node.js gerenciado pelo PM2).

## Pré-condições

- Node.js LTS instalado via nvm no PC doméstico
- Biblioteca Baileys (ou whatsapp-web.js) configurada
- Sessão WhatsApp autenticada (QR code escaneado com número dedicado)
- PM2 rodando o bot com auto-restart

## Fluxo principal

1. Bot inicia no boot do PC (via PM2).
2. Bot restaura sessão WhatsApp persistida em disco.
3. Bot aguarda trigger (cron, webhook ou fila interna).
4. Bot envia mensagem para destinatário(s) configurado(s).
5. Bot registra resultado (sucesso/erro) em log.

## Fluxo alternativo — sessão expirada

1. Bot detecta desconexão da sessão WhatsApp.
2. Bot gera novo QR code e salva em arquivo ou exibe no log.
3. Administrador acessa via SSH (`ssh meupc`) e escaneia QR code.
4. Bot reconecta e retoma operação.

## Fluxo alternativo — banimento / bloqueio

1. WhatsApp retorna erro de conta banida ou limitada.
2. Bot para envios e registra alerta crítico no log.
3. Administrador investiga volume/frequência de envios.
4. Administrador reduz taxa ou pausa automação até resolução.

## Pós-condições

- Mensagem entregue ou erro registrado com timestamp.
- Sessão WhatsApp mantida para próximos envios.

## Regras de negócio

- Usar **número dedicado** — nunca o pessoal.
- Respeitar limites de envio para evitar banimento.
- Enviar apenas para contatos com opt-in (interação prévia com a marca).
- Preferir Baileys em PCs com pouca RAM.

## Referências

- [Plano — Etapa 5](../PLANO-IMPLEMENTACAO.md#etapa-5--automações-whatsapp--agendamento-de-posts)
- [Glossário — Baileys](../GLOSSARY.md#baileys)
- [Glossário — Número Dedicado](../GLOSSARY.md#número-dedicado-whatsapp)
