# SmartTube Sala

Versão pessoal do [SmartTube](https://github.com/yuliskov/SmartTube) (licença MIT) para a box Android da sala, com um aspeto mais próximo do YouTube para TV e atualizações automáticas próprias.

Este repositório não guarda o código do SmartTube. Guarda só as nossas alterações (`patches/sala.patch`) e os scripts que as aplicam a cada versão estável do original.

## O que muda em relação ao SmartTube

- Pacote `pt.daniel.smarttube` e nome «SmartTube Sala»: instala-se ao lado do SmartTube original.
- Cartões ao estilo do YouTube TV: sem caixa à volta do título, miniaturas com cantos arredondados e contorno branco no cartão selecionado.
- O atualizador da app procura versões neste repositório (release `latest`).
- Sem Firebase/Crashlytics: os relatórios de erros iam para o projeto do autor original.

## Como funciona a atualização

Todos os dias às 03:30 UTC, o GitHub Actions (`.github/workflows/compilar.yml`):

1. vê qual é a última versão estável do SmartTube (tags acabadas em `s`, por exemplo `32.68s`);
2. se ainda não houver a release `sala-<versão>-<revisão>`, descarrega essa versão e aplica `patches/sala.patch`;
3. compila, assina com a chave do SmartTube Sala (segredos do repositório) e publica.

Se o patch deixar de encaixar numa versão nova, ou se a compilação falhar, nada é publicado. A box fica com a versão anterior e o GitHub manda um email. Na app, a atualização aparece como aviso, como no SmartTube original.

Número de versão: `versionCode` do SmartTube × 100 + `REVISAO`. Mudar o patch implica subir o `REVISAO`, para a box ver a versão nova.

## Trabalhar localmente

```bash
scripts/preparar.sh            # descarrega a última estável para /opt/dev/smarttube-src e aplica o patch
# ... alterar o código em /opt/dev/smarttube-src ...
scripts/guardar_patch.sh       # guarda as alterações em patches/sala.patch
scripts/compilar.sh --instalar # compila e instala na box por ADB
```

A chave de assinatura local fica em `~/.local/share/smarttube-sala/` (com cópia em `~/Backups/tv-box/chaves/`). Nunca vai para o repositório.
