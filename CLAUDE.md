# SmartTube Sala

Patch sobre o SmartTube (yuliskov/SmartTube, MIT) para a box da sala. Ver o README para o funcionamento. O launcher da box é o FLauncher Sala (`~/code/flauncher`), que mostra esta app como «YouTube».

## Regras

- O código do SmartTube nunca entra neste repositório; só `patches/sala.patch`. Trabalhar em `/opt/dev/smarttube-src` (a home é eCryptfs e não aceita nomes longos).
- Os ficheiros do SmartTube misturam fins de linha CRLF e LF. Ao editar com scripts, manter os fins de linha originais, senão o patch fica com o ficheiro inteiro.
- Manter o patch pequeno e concentrado no aspeto, para encaixar nas versões novas sem conflitos.
- Depois de mudar o patch, subir o `REVISAO` e fazer push: o GitHub Actions publica e a box recebe o aviso de atualização.
- Não incluir logótipos do YouTube neste repositório (é público). O ícone «YouTube» vem do launcher, a partir da app oficial instalada na box.
- Chave de assinatura: `~/.local/share/smarttube-sala/` e segredos do repositório (`SALA_KEYSTORE_B64`, `SALA_KEYSTORE_PASSWORD`, `SALA_KEY_ALIAS`). Sem ela, a box não aceita atualizações por cima da versão instalada.
- Box: `~/.local/bin/adb -s 192.168.1.78:5555`. Está em uso na sala; depois de testar, voltar à app que estava no ecrã.
- O Claude pode fazer commits e push para este repositório (`danifstech/smarttube-sala`).
