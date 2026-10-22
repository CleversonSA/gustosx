# UOSXPI

Imagem de cartão SD completa para Raspberry PI que transforma o SBC em um "clone" de MSX 1 e MSX 2 baseado no emulador OpenMSX.

O projeto é um hobby que tem como filosofia trazer a experiência mais próxima possível do uso de máquinas reais MSX para o Raspberry PI, assim como preservação e divulgação de conhecimento de como era usar essas máquinas criadas nos anos 80 e que tem adeptos e fãs até os dias atuais.

Basta queimar a imagem em um cartão SD e inserir no aparelho. Não precisa aguardar carregar a tela do Raspberry PI OS, logs, comandos, etc. É colocar o cartão SD, aguardar alguns segundos e já iniciar em uma máquinas MSX pré-configuradas. Simples e direto ao assunto.

---

# ANTES DE COMEÇAR #

Primeiro, atente-se que o projeto é por sua conta em risco, por isso, não me responsabilizo por danos ou perca de dados que a utilização das imagens possa proporcionar.

Além disso, como nesse projeto uso o OpenMSX como emulador, *NÃO HÁ* o suporte a placa RPMC, que é um projeto criado pelo desenvolvedor Meeso Kim(https://github.com/meesokim/msxslot) e que permite o Raspberry "conversar" com cartuchos reais, com diversas limitações. Eu até criei uma imagem que permite o uso do RPMC, dentro de suas limitações, mas para não confundir, vou colocar em repositório separado.

---
# PRÉ-REQUISITOS #

Você irá precisar de:

- Raspberry PI 2 ou superior
- Teclado USB qualquer
- Monitor HDMI
- Cartão SD (mínimo 8GB)
- Fonte 5V de no mínimo 3A
- Leitor de cartão SD para gravar a imagem baixada no PC
- (Opcional) Pendrive para importar ROMs

---
# IMAGENS PARA DOWNLOAD

A versão mais recente e estável da imagem, disponível para download, é essa abaixo. Independente de seu modelo de Raspberry PI, baixe esta:

| Data de lancamento | Arquivo | Tamanho estimado | Link para download |
| :---: | :---: | :---: | :---: |
| 09/10/2025 | umsxpi-rpi32-openmsx18-1.1.0.img | 5.47GB |https://drive.google.com/file/d/1CgXYqz3FWKDRIX2jsybpgL1BD3Kf9fIN/view?usp=drive_link|

**HISTÓRICO DE VERSÕES**

Caso, por algum motivo em particular, queira usar alguma versão anterior, seguem as imagens disponíveis abaixo:

| Data de lancamento | Arquivo | Tamanho estimado | Link para download |
| :---: | :---: | :---: | :---: |
| 22/07/2025 | uosxpi-rpi32-openmsx-1.0.1.img | 5.42GB |https://drive.google.com/file/d/1u877i-Nh13IshybfbvdMw5NoP5Hb05cP/view?usp=drivesdk|

---
# INSTRUÇÕES DE INSTALAÇÃO

Baixe a imagem desejada e queime em um cartão SD utilizando o programa de preferência. Se for o Windows, por exemplo, existe o Balena Etcher (https://etcher.balena.io/) que pode fazer esse trabalho. No linux, pode ser usado o comando dd ou o app Disks (distribuições baseadas no Ubuntu). 

Após queimar a imagem do uosxpi no cartão no PC, coloque-o no Raspberry PI, ligue o teclado conecte o Raspberry PI no monitor HDMI. Por último, a fonte no RPi, logo será inicializado.

O primeiro boot pode demorar até 20-30 segundos e a tela do MSX aparecerá para uso com o MSX-DOS carregado. 

---
# NOTA SOBRE A VERSÃO 1.1.0 OU SUPERIOR

Ao inicializar a imagem pela primeria vez, a máquina inicial é a Sharp Hotbit (MSX1). Esta versão contém 3 máquinas nacionais famosas pré-configuradas no OpenMSX: 

**Expert Gradiente XP800 (MSX1)**
 - Baseado no Expert 1.1
 - Suporte a drive DDX incluso
 - DSK virtual pré-montado contendo o MSX-DOS 1.3
 - EXECROM pré-instalado para rodar algumas ROMs
 - Utilitário BASIC CHMSX.BAS para mudar de perfis, pré-instalado
 - **SEM SUPORTE** a HDs, devido a limitação da ROM do Nextor/Sunrise precisar de mapper (talvez em versões futuras possa corrigir isso, se souber, por favor, contacte-me!)

**Sharp Hotbit HB8000 (MSX1)**
  - Baseado no HotBit 1.2
  - Suporte a drive DDX incluso
  - DSK virtual pré-montado contendo o MSX-DOS 1.3
  - EXECROM pré-instalado para rodar algumas ROMs
  - Utilitário BASIC CHMSX.BAS para mudar de perfis, pré-instalado
  - **SEM SUPORTE** a HDs, devido a limitação da ROM do Nextor/Sunrise precisar de mapper (talvez em versões futuras possa corrigir isso, se souber, por favor, contacte-me!)
 
**Expert 3 criada pelo Adriano Carchano (MSX2)**
  - Baseado no Expert 3 com mapper
  - 1MB de RAM
  - Suporte a drive DDX incluso
  - Suporte a Nextor/Sunrise IDE para gerenciamento de HD incluso
  - HD virtual pré-configurado com 1GB de armazenamento
  - SofaRun e outros utilitários pré-instalados
  - Utilitário BASIC CHMSX.BAS para mudar de perfis, pré-instalado
  - MSX-DOS 2 com suporte a diretórios e Nextor

---
# O UTILITÁRIO CHMSX.BAS (VERSÃO 1.1.0 OU SUPERIOR)

Esse utilitário partiu da seguinte provocação: ao contrário de outros gerenciadores de emuladores, o objetivo de meu projeto é trazer o máximo possível da experiência de usar as máquinas MSX, dentro de suas limitações, sem precisar ficar "saindo para o linux". Por isso, para trocar o perfil das máquinas, não implementei um menu no linux, ou uma interface gráfica que seja.

Ao invés disso, criei um programa em BASIC que envia comandos em uma área da memória do MSX (a partir do endereço 0xFF00) e o SO linux faz as leituras e realiza o gerenciamento da troca dos perfis. 

Coloquei esse programa em BASIC mesmo para quem quiser modificar, copiar, estender, quebrar, enfim, brincar mesmo com programação em BASIC, aí sim fechando a experiência. Se eu colocasse um menu externo, seria fácil de usar, mas fugiria da experiência que quero proporcionar e a filosofia do projeto.

Uma vez uma máquina selecionada e ativa, ao reiniciar o Raspberry PI ela continuará ativa, até que seja chamado novamente o utilitário e feito sua troca.

**EXECUTANDO (MSX1)**
- Caso você esteja utilizando o HotBit ou Expert 1, certifique-se que não tenha nenhum leitor de cartão ou pendrive conectados no Raspberry PI, para utilizar o disquete virtual pré-montado da imagem
- No MSX-DOS digite BASIC e pressione ENTER
- Digite LOAD "CHMSX.BAS" e pressione ENTER
- Digite RUN e pressione ENTER
- Escolha no menu as máquinas disponíveis
- Aguarde em torno de 10s para o reinício.

**EXECUTANDO (MSX2)**
- Caso você esteja utilizando o Expert 3:
- No MSX-DOS digite CD C:\BASIC e pressione ENTER
- Digite BASIC e pressione ENTER
- Digite LOAD "CHMSX.BAS" e pressione ENTER
- Digite RUN e pressione ENTER
- Escolha no menu as máquinas disponíveis
- Aguarde em torno de 10s para o reinício.
  
---
# GUIA RÁPIDO DE USO

**Reiniciando o MSX dentro do OpenMSX sem precisar reiniciar o Raspberry PI (útil quando está jogando)**

  - Pressione a tecla F10 para abrir o Console
  - Digite o comando "reset" e pressione ENTER
  - Pressione a tecla F10 para fechar o Console.

**Desligando de maneira correta o Raspberry para evitar corrompimento do SD**

  - Pressione a tecla F10 para abrir o Console
  - Digite o comando "quit" e pressione ENTER
  - Aguarde o encerramento do linux e desligue o Raspberry PI com segurança


**Acessando modo administrador (linux, para manutenções avançadas)**

  - Pressione as teclas CTRL+ALT+F3 depois ENTER
  - No prompt do console entre com o usuário "umsxpi" pressione ENTER
  - Entre com a senha "umsxpi"
  - Todos os scripts e atalhos estão na pasta /home/umsxpi. Altere com cautela.


**Problemas no Som ou sem áudio HDMI (RPi 4/RPi 400)**

  - Entre no modo administrador do linux, passos no parágrafo anterior
  - Digite o comando "sudo raspi-config" e pressione ENTER
  - Entre no menu "System Options"
  - Escolha a opção "Audio"
  - Escolha a opção "HDMI" ou "bcm2835 HDMI" e pressione ENTER
  - Aperte TAB até o botão FINISH estar selecionado, pressione ENTER
  - Digite o comando "sudo reboot" e pressione ENTER

  O aúdio deve funcionar, use esse mesmo menu se quiser trocar por outras saídas, como placa de som USB por exemplo.


**Montando um DSK - MODO AUTOMATIZADO (versão 1.1.0 ou superior)**
  - Você precisará de um PENDRIVE ou cartão SD com leitor formatado em FAT ou exFat, não importa o tamanho (você só usará alguns kilobytes)
  - Conecte o pendrive ou cartão SD com leitor no PC
  - Renomeie seu DSK para o arquivo "diska.dsk" na pasta raiz do pendrive ou cartão SD com leitor
  - Ejete o pendrive
  - Com o Raspberry iniciado com o MSX desejado, coloque o pendrive
  - Aguarde alguns segundos, o led FDD na tela do emulador piscará 3 vezes, isso indicará que a unidade está montada
  - Digite A: e pressione ENTER no MSX-DOS
  - Digite o comando "DIR" e pressione ENTER, os arquivos estarão lá.


**Montando qualquer DSK (versão 1.1.0 ou superior)**
  - Você precisará de um PENDRIVE ou cartão SD com leitor formatado em FAT ou exFat, não importa o tamanho (você só usará alguns kilobytes)
  - Conecte o pendrive ou cartão SD com leitor no PC
  - Copie na pasta raiz do pendrive ou cartão SD com leitor o DSK que precisa
  - Ejete o pendrive
  - Com o Raspberry iniciado com o MSX desejado, coloque o pendrive
  - Aguarde alguns segundos, o led FDD na tela do emulador piscará 3 vezes, isso indicará que a unidade está montada
  - Pressione F10 para entrar no console do emulador.
  - Digite o comando "diska eject" e pressione ENTER
  - Digite o comando "diska /mnt/storage1/ARQUIVODSKQUEPRECISA.dsk" e pressione ENTER
  - O arquivo está montado e pronto para uso.
  - Caso não queria usar mais o pendrive, basta removê-lo. Ele será desmontado e o led FDD irá piscar 3x indicando que o disco foi desmontado no emulador.
  

**Montando uma pasta como disquete - MODO AUTOMATIZADO (versão 1.1.0 ou superior)**
  - Você precisará de um PENDRIVE ou cartão SD com leitor formatado em FAT ou exFat, não importa o tamanho (você só usará alguns kilobytes)
  - Conecte o pendrive ou cartão SD com leitor no PC
  - Crie uma pasta chamada "diska" na pasta raiz do pendrive ou cartão SD com leitor
  - Coloque os arquivos que precisa, lembrando que o emulador limita a 720kb de tamanho máximo por vez (o emulador lançará erro e ignorará o resto dos arquivos)
  - Ejete o pendrive
  - Com o Raspberry iniciado com o MSX desejado, coloque o pendrive
  - Aguarde alguns segundos, o led FDD na tela do emulador piscará 3 vezes, isso indicará que a unidade está montada
  - Digite A: e pressione ENTER no MSX-DOS
  - Digite o comando "DIR" e pressione ENTER, os arquivos estarão lá.
  - Caso não queria usar mais o pendrive, basta removê-lo. Ele será desmontado e o led FDD irá piscar 3x indicando que o disco foi desmontado no emulador.
  

**Adicionando arquivos à imagem do OpenMSX (ROMs, jogos, utilitários) - MODO AUTOMATIZADO (versão 1.1.0 ou superior)**
  - Lembre-se que esses passos somente funcionarão na máquina MSX2 Expert 3, pois não consegui, até o momento, fazer o Nextor funcionar nos MSX1, ou seja, não existe unidade C. 
  - Você precisará de um PENDRIVE ou cartão SD com leitor formatado em FAT ou exFat, não importa o tamanho (você só usará alguns kilobytes)
  - Conecte o pendrive ou cartão SD com leitor no PC
  - Crie uma pasta chamada "diska" na pasta raiz do pendrive ou cartão SD com leitor
  - Coloque os arquivos que precisa, lembrando que o emulador limita a 720kb de tamanho máximo por vez (o emulador lançará erro e ignorará o resto dos arquivos)
  - Ejete o pendrive
  - Com o Raspberry iniciado com o MSX desejado, coloque o pendrive
  - Aguarde alguns segundos, o led FDD na tela do emulador piscará 3 vezes, isso indicará que a unidade está montada
  - Digite A: e pressione ENTER no MSX-DOS
  - Digite o comando "DIR" e pressione ENTER, os arquivos estarão lá.
  - Você pode usar o comando copy para copiar os arquivos para a unidade C:, deixei uma pasta criada em C:\GAMES:
    ```- Digite A: e pressione ENTER
    	- Digite COPY *.* C:\GAMES e pressione ENTER
       	- Digite C: e pressione ENTER
       	- Digite CD C:\SR8 e pressione ENTER
       	- Digite SR e pressione ENTER.
       	- Com a setas, escolha a opção ".." e pressione ENTER
       	- Acesse a pasta GAMES e pressione ENTER
       	- Boa diversão.```
  - Caso não queria usar mais o pendrive, basta removê-lo. Ele será desmontado e o led FDD irá piscar 3x indicando que o disco foi desmontado no emulador.
  

**Adicionando arquivos à imagem do OpenMSX (ROMs, jogos, utilitários) - MODO RAIZ**

  - Desligue o Raspberry
  - Insira o cartão no computador PC
  - Crie uma pasta chamada diskA na raiz da partição de boot do cartão
  - Coloque os arquivos a copiar para imagem
  - Ejete o cartão, coloque no Raspberry Pi e o inicie
  - Aguarde a inicialização completa do MSX-DOS2
  - Pressione F10 para abrir o Console
  - digite o comando "diska /boot/firmware/diskA" e pressione ENTER
  - No MSX-DOS2 digite A: e pressione ENTER
  - Digite o comando "DIR" e pressione ENTER, os arquivos estarão lá.
  - Você pode usar o comando copy para copiar os arquivos para a unidade C:, deixei uma pasta criada em C:\GAMES:
    ```- Digite A: e pressione ENTER
    	- Digite COPY *.* C:\GAMES e pressione ENTER
       	- Digite C: e pressione ENTER
       	- Digite CD C:\SR8 e pressione ENTER
       	- Digite SR e pressione ENTER.
       	- Com a setas, escolha a opção ".." e pressione ENTER
       	- Acesse a pasta GAMES e pressione ENTER
       	- Boa diversão.```

**Ativando modo 80 colunas**

  - No MSX-DOS2 digite o comando "mode 80" e pressione ENTER
  - Para voltar a 40 colunas (default), digite o comando "mode 40" e pressione ENTER

**Desabilitando os avisos de low-voltage (LEIA COM ATENÇÃO)**

  Já não coloquei esse recurso como default por que seria como se o marcador de gasolina do carro estivesse piscando e marcando pouco combustível e você colocasse uma fita cobrindo o marcador e seguindo adiante. Entretanto, dependendo do projeto que você utilize para o seu Raspberry PI, pode acontecer de não ter nenhum problema na alimentação e queira desativar o "low-voltage warning".

  Primeiro, entenda que essa mensagem acontece por que a voltagem suprida para o Raspberry PI (em especial o 3b) está abaixo da mínima recomendada pelo fabricante. Tem fontes que indicam 5v/3A, mas na hora de uma carga, caem a tensão para 4.9v, 4.8v, fazendo o RPI funcionar, mas esse aviso virá a tela. Pelo fabricante, podem ocorrer problemas de corrompimento de SD, etc. O RPI 3b quando está em pico de consumo, especialmente com Wifi e Emulador ativos, consome os limites de uma fonte, que um carregador de celular, por exemplo, não é capaz de suprir. O meu RPI3 já tem quase 10 anos, nunca deu problema e já sofreu com fontes ruins e powebanks.
  
  Então, se as mensagens incomodam e se se estiver CIENTE dos riscos, essa alteração é por SUA CONTA EM RISCO SE CASO OCORRA ALGUMA FALHA, DEFEITO DO RPI, PERCA DE DADOS, ETC...ASSIM COMO QUALQUER PROJETO OPEN SOURCE:

  - Certifique-se que esteja no modo administrador do linux
  - Digite "sudo nano /boot/firmware/config.txt"
  - Adicione a seguinte linha ao final do arquivo:
    ```
    avoid_warnings=2
    ```
  - Aperte CTRL+O (tecla ó) e pressione ENTER para salvar o arquivo
  - Aperte CTRL+X e pressione ENTER para sair
  - Digite o comando "sudo reboot"


**Aproveitando o espaço livre do cartão SD(Realmente opcional)**

Por motivos de otimização de armazenamento na nuvem e download, monto cartão SD com o mínimo de tamanho necessário para copiar alguns arquivos e operar o sistema. Eu costumo utilizar cartões de 16/32GB, seria inviável o armazemento e disponibilidade da imagem. No entanto, se precisar de espaço adicional para personalizações no linux, ajustes no projeto que seja, siga os seguintes passos:

  - Pressione as teclas CTRL+ALT+F3 depois ENTER
  - No prompt do console entre com o usuário "umsxpi" pressione ENTER
  - Entre com a senha "umsxpi"
  - Digite "sudo raspi-config" e pressione ENTER
  - Escolha a opção "6 - Advanced Options" e pressione ENTER
  - Escolha a opção "A1 - Expand Filesystem" e pressione ENTER
  - Uma mensagem informando que o espaço foi redimensionado e será atualizado no próximo boot. Pressione TAB e vá até FINISH e pressione ENTER
  - Se vier uma mensagem informando se deseja reiniciar o sistema, escolha REBOOT e pressione ENTER.
  - Todavia, o reinício do Raspberry PI é obrigatório.
  - Quando reiniciar o sistema, pressione as teclas CTRL+ALT+F3 depois ENTER
  - Entre com o usuário "umsxpi" e senha "umsxpi" e pressione ENTER
  - Digite o comando "df -H"
  - Verifique a coluna "avail." ou "disp.", verá que o espaço livre aumentou.

---
# FAQ

**Eu posso usar meu cartão SD que uso no cartucho da SD Mapper em um MSX real para ser lido no OpenMSX?**

Infelizmente, até o momento, a resposta é não. Eu pesquisei alternativas no fórum MSX Resource Center, mas até o momento, o OpenMSX não suporta SD Mapper (somente mapper de memória, o que não é o caso). Na verdade, o HD virtual que é utilizado pelo EXPERT3 tem 1GB, pode ser montado direto pelo Linux via comando mount (modo administração), e aí pelo prendrive copiar para o HD. Só que quebra um pouco a filosofia de experiência do projeto. Estou aberto a sugestões de como montar uma automação para simular o uso do SD no OpenMSX :)

---
# Known issues

- Versão 1.1.0
  * Existe um problema no OpenMSX 18, que intermitentemente, talvez depois de 1h de uso, pode desligar o raspberry, devido a um crash no socket de leitura dos comandos remotos. Não achei solução plausível para isso. Talvez fazendo um upgrade para a versão 20+ tenha melhorias em relação a isso. Peço desculpas sobre esse problema.

---
# Changelog

- Versão 1.1.0
  * Adicionado mais dois perfis de máquinas brasileiras famosas: Expert GPC 800 (MSX1) e HotBit (MSX1)
  * Adicionado suporte a montagem automática de pendrive como disquetes
  * Adicionada interface linux-openmsx via protocolo de comunicação do emulador (OpenMSX remote control)
  * Corrigido problema de necessitar de mouse adicional para iniciar a imagem no Raspberry PI 3 - Problema com um módulo do Wayland que ficava verificando inputs
  * Adicionado script em BASIC para troca e persistência dos emuladores
  * Remodelada engine de scripts para novos projetos
  * Montagem automática de DSKs e pastas virtuais no emulador
  * Adicionado MSX-DOS 1.3 e EXECROM nas imagens MSX1, com suporte a drive DDX.
  * Melhorado recurso de iniciar sem teclado e adicionar depois do sistema iniciado.

- Versão 1.0.1
  * Para deixar mais complaince, eu removi as ROMs da versão anterior. Desculpe, mas a vida é assim mesmo, mas elas podem ser facilmente encontrada nas Interwebs da vida =//
  * Removi aplicações que usei de exemplo, mas podem ser encontradas nas interwebs da vida
  * Deixei mais espaço na imagem para a próxima feature que estou finalizando, a integração com IA e o MCP-Server criado por Natalia-PC
    
- Versão 1.0
  * Imagem voltada para o OpenMSX sem suporte ao MSX-Hat ainda
  * Criada com a versão mais recente do Raspberry PI OS Lite (2024)
    
- Versão 0.9
  * Imagem inicial voltada para versão 32bits do Raspiberry PI OS
  * Suporte a RPMC
  * Atalhos somente para o MSX Expert e MSX 2
  * Desligamento ainda não implementado
    
---
# Licença

GNU Public License (GPL)
