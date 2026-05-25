# GUSTOSX

## Introdução

Uma mini live distro linux personalizada para trazer o "sabor" da experiência MSX para PCs antigos e modernos (PCs, laptops, mini pcs etc), voltado para arquitetura 32 bits inicialmente.

Gusto em esperanto é sabor, SX ficou por questões de copyright, então entenda como projeto sabor MSX. 

A ideia nasceu de uma postagem no facebook no grupo [MSX BRASIL OFICIAL](https://www.facebook.com/groups/msxbrasiloficial/?locale=pt_BR) onde alguns amantes da plataforma (fudebas) perguntaram como dar uma nova vida a netbooks que estão encostados e outros encontrados a custo baixo em plataformas de vendas famosas tranformando em um MSX BOOK de baixo custo?

Eu já tinha criado o projeto que transformava um Raspberry PI em uma experiência MSX [uosxpi](https://github.com/CleversonSA/uosxpi), então fiz o port da arquitetura ARM para x86 32bits. Não foi uma simples cópia e ajuste de scripts, o projeto de distro nasceu do zero, com ajudas da IA como pair proogramming (sem agentes, sem vibe coding).

O coração do projeto é o emulador [OpenMSX 21](https://openmsx.org), a versão mais recente e estável do ano de 2026. Esse emulador em especial tem suporte a várias máquinas MSX assim como plataformas, como um port não oficial que fiz para [Android](https://github.com/CleversonSA/openmsx4android). Como sistema host está o Debian 12 bookwork, o último com suporte a 32bits e kernel 6.x.

O intuito dessa distro não é, inicialmente, ser uma distro de uso genérico e sim, diversão e experimentos voltados para a plataforma MSX, criado pelo mestre Kazuhiro Nish, nos anos 80.

Por isso, não utilize dados sensíveis e críticos nessa distribuição, para sua própria segurança digital.

---

# Instalação

## Requisitos

### Hardware mínimo recomendado

- Processador Atom x86 32 bits
- 2GB RAM (1GB pode ocorrer instabilidades, mas somente testando)
- Pendrive ou cartão de memória com leitor USB de 4GB
- GPU não é obrigatoria
- Compatível com BIOS legacy
- Rede e Wifi não utilizados

### Software necessário

- Windows: Etcher ou qualquer outro aplicativo que grave imagem em SD/USB
- Linux: Etcher ou comando dd

---

## Preparando o pendrive completo

- 1. Baixe a última versão da imagem disponível: [live-gustosx-pendrive-052026.img](https://drive.google.com/file/d/1-pYJ5grBfbdWLAesO51pAhxDK8NwOCv8/view?usp=drive_link)

- 2. Inicie o seu programa gravador de USB, selecione a imagem e grave no pendrive

- 3. Reinicie a máquina e faça boot pelo pendrive

- 4. Escolha a ISO do gustosx e pressione ENTER

- 5. Escolha boot menu e pressione ENTER

- 6. Aguarde alguns bons momentos e ao final irá surgir a tela do CBIOs do emulador OpenMSX

---


## Estrutura do pendrive

```
partições
|-- Partição 1 - imagens ISO da distro
|-- Partição 2 - EFI
|-- Partição 3 - GUSTOSX - Persistência dos dados do usuário
```

### Partição 1 - Imagens ISO da distro

- Aqui contém a ISO mais recente da distro. Novas atualizações da distro basta somente apagar a ISO anterior dessa pasta e baixar a nova, simples assim, sem precisar reescrever todo o pendrive e perder seus dados.

### Partição 2 - EFI

- Utilizado pelo [Ventoy](https://www.ventoy.net) - Não mexer

### Partição 3 - GUSTOSX

- Partição FAT32 para peristência de dados do usuário que tem essa estrutura:
```
/
|-- hd.dsk
|-- extensions/
|-- systemroms/
|-- msxhd/

```
### Arquivo hd.dsk

- É um arquivo que corresponde a imagem FAT16 de um HD gerado pelo Nextor. Ele não é compatível com o Disk Manipulator do OpenMSX! 

- O HD tem 256MB de tamanho, expansíveis até 4GB. Você pode formatar ele utilizando a rom do Nextor e chamando o comando CALL FDISK no BASIC, usando uma máquina Expert ou Hotbit.

- O HD vem instalado: MSX-DOS 2, SOFARUN, Alguns programas de exemplo em MSX-BASIC e os utilitários BASIC que criei para essa distro. Veja [Utilitários BASIC](#Utilitários BASIC)

- Esse HD virtual ficará armazenado todos os arquivos e ROMs importadas


### extensions

- Corresponde a pasta extensions do OpenMSX, pode deixar vazia, ainda será implementada

### systemroms

- Aqui irão as ROMs das máquinas, suporte a disco e o Nextor, que serão copiados direto para a pasta systemroms do OpenMSX

### msxhd

- Aqui são os arquivos que serão transferidos para o HD virtual ao iniciar o emulador.

---

# Experimentando o sabor MSX

- Ao iniciar a imagem pela primera vez, o emulador é inicializado com a CBIOS padrão do OpenMSX. Ele permite rodar jogos de MSX1 e MSX2, mas não tem o BASIC embutido.

- INFELIZMENTE, devido a motivos óbvios, o projeto não contém nenhuma ROM proprietária, seja de jogo ou de máquina. Tem somente os perfis e setups pronto para serem acionados quando as ROMs forem encontradas. Veja a sessão [Temperando o sabor MSX](#Temperando o sabor MSX).

- O core da live roda na memória RAM, mas a persistência dos dados criados e modificados no MSX virtual são gravados no pendrive na partição entitulada "GUSTOSX". Veja a sessão [Estrutura do pendrive](#Estrutura do pendrive)

- Encerrando o emulador com ALT+F4, o sistema é desligado, inclusive a máquina.

- Ainda náo é possível criar scripts de inicialização do OpenMSX com parâmetros personalizados. O projeto tem como foco as máquinas brasileiras MSX Expert Gradiente, Sharp Hotbit e MSX3 criado por Carchano.

- Disquetes físicos ainda não são suportados, somente DSKs e Dir as Disk. Já teve pesquisa e questionamentos sobre isso. Nas minhas pesquisas a limitação está no core do OpenMSX, que pela filosofia de ser Agnóstico em sua plataforma, não se atrela a leitura de nenhum dispositivo físico. Talvez uma implementação futura permita isso.


---

# Temperando o sabor MSX

## Pré-requisitos

### 1. O projeto não tem nenhuma ROM de máquina, então você precisará localizar e baixar as seguintes ROMS de máquina para ativar os recursos principais da distro:

- Expert Gradiente XP800 (obrigatório no primeiro uso)
- Hotbit Sharp HB-8000 (opcional)
- DDX 3.0 (obrigatório no primeiro uso)
- Nextor (obrigatório para o suporte a HD e no primeiro uso)

### 2. Você pode encontrar referências nesses sites indicados:

- [Nextor](https://github.com/Konamiman/Nextor/releases)
- [Hardware e software relacionado a MSX](https://www.msxpro.com)
- [Jogos MSX](https://www.file-hunter.com)

---

## Adicionando ROMS e programas

- 1. Baixe as ROMs do item 1 necessárias e coloque elas dentro da pasta **systemroms** do volume GUSTOSX. NÃO COLOQUE AS ROMS DE JOGOS NESTA PASTA!

- 2. Crie uma pasta chamada GAMES dentro pasta **msxhd** e nesta pasta coloque as ROMs que baixar. É essa pasta que o SofaRun irá procurar no início da distro.

- 3. Retire o pendrive e ligue no computador. Inicie a distro. Se estiver com as ROMs corretas, será iniciado o emulador com um programa em basic chamado AVISO DE SISTEMA, que copiará TODOS os arquivos que estiverem na pasta **msxhd** para o hd virtual **hd.dsk**.

---

## Adicionando DSKs

- 1. DSKs que formem baixados devem ou ficar na pasta raiz do volume GUSTOSX ou em um nível de pasta, exemplo de estrutura:
```
/
|-- amazonia.dsk
|-- Aleste 2/
   |-- aleste2-disk1.dsk
   |-- aleste2-disk2.dsk
...
```

---

# DSKs e simulação da Go-Tek

- O recurso que simula a Go-Teck permite a troca de DSKs enquanto o emulador OpenMSX estiver em execução, sem precisar acessar menus, operando somente via teclado, como toda boa experiência do MSX exige.

- A troca de pastas e dsks pode levar alguns segundos, dependendo da velocidade do equipamento, por isso, percorrer um grande volume de DSKs pode demorar um pouco. Tenha um pouco de paciência :)

- A leitura de pastas é feita no volume GUSTOSX, dentro da live a pasta de sistema é **/mnt/storage1**

- A leitura de pastas e arquivos é feita em **ordem alfábetica e numérica**

- **O RECURSO NÃO FUNCIONA NO PERFIL CBIOS PADRÃO**

## Atalhos para movimentar o cursor nas pastas

| Teclas | Ação      |
|--------|-----------|
| CTRL+CIMA | Movimenta o cursor para *primeira* pasta da lista |
| CTRL+ESQUERDA | Movimenta o cursor para pasta *anterior* da lista |
| CTRL+DIREITA | Movimenta o cursor para *próxima* pasta da lista |
| CTRL+BAIXO | Seleciona a pasta para escolher os arquivos |

## Atalhos para movimentar o cursor dos arquivos

| Teclas | Ação     |
|--------|----------|
| ALT+CIMA | Movimenta o cursor para o *primeiro* arquivo da lista |
| ALT+ESQUERDA | Movimenta o cursor para o arquivo DSK *anterior* da lista |
| ALT+DIREITA | Movimenta o cursor para o *próximo* arquivo dsk da lista |
| ALT+BAIXO | Seleciona o dsk e o insere no drive virtual do OpenMSX |


---

# Atalhos gerais

| Teclas | Ação     |
|--------|----------|
| ALT+F4 | Fecha o emulador e em alguns segundos desliga o aparelho, permitindo remover o pendrive com segurança |
| F10 | Inicia o console do OpenMSX para enviar comandos direto para o emulador (ex: reset) |
| CTRL+SHIFT+BAIXO | Ejeta um DSK inserido no drive virtual do OpenMSX. Mesmo reiniciando o emulador, o disco permanece inserido até que você o ejete com esse comando |
| CTRL+SHIFT+CIMA | Insere o disco virtual contendo os utilitários em BASIC para, por exemplo, troca de máquina |
| CTRL+ALT+F3 | Entra no modo shell do linux (avançado) |

---

# Utilitários BASIC

## CHMSX.BAS

- Permite a troca de perfil de máquina virtual. As opções variam do MSX1 (Expert e Hotbit) com ou sem HD assim como o MSX2+ (Expert 3) com HD.

- Para que funcione é necessário que as ROMs das máquinas estejam disponíveis na pasta **systemroms** do volume GUSTOSX


## CHMSX.BAS - Trocando a máquina (caso esteja usando o HD virtual)

- No MSX-DOS vá para a raiz do HD - ```CD C:\```
- Entre na pasta BASIC - ```CD BASIC```
- Digite ```BASIC``` e pressione ENTER
- Digite ```LOAD "CHMSX.BAS"``` e pressione ENTER
- Pressione F5 ou digite o comando ```RUN```
- Escolha uma das opções e aguarde o reinício do emulador.
- Se não escolheu nenhuma das opções, basta digitar ```CALL SYSTEM``` e voltar a MSX-DOS

## CHMSX.BAS - Trocando a máquina (caso esteja no BASIC e disquete virtual)

- Pressione CTRL+SHIFT+DOWN para ejetar qualquer disco inserido
- Pressione CTRL+SHIFT+UP para inserir o disco de sistema
- Digite ```FILES``` e pressione ENTER, deve exibir o CHMSX.BAS
- Digite ```LOAD "CHMSX.BAS"``` e pressione ENTER
- Pressione F5 ou digite o comando ```RUN```
- Escolha uma das opções e aguarde o reinício do emulador.

---


# Limitações em Netbooks antigos

- Processadores Atom/Celerom costumam a ter desempenho ruim mesmo com sistemas otimizados, então o tempo de boot pode variar de 30s a até 2 minutos, ou travar. Infelizmente não teve muito o que fazer nesse sentido, pois vários pacotes e módulos foram retirados do kernel, mas cheguei a um limite para tentar reduzir o tempo de inicialização.

- Nos meus testes, em alguns momentos, o boot trava devido a conflito com o gerenciamento de energia. Não é sempre, mas depende do modelo do Netbook em si. Somente com testes adicionais para saber.

- Máquinas Dual Core, Core2Duo, que já são antigas também, o boot ficou mais rápido e não tive dor de cabeça no uso da imagem. Os jogos fluiram muito bem, assim como a movimentação de DSKs pelo recurso que simula uma gotek.

- Processadores Atom/Celerom antigos podem engargalar em alguns jogos de MSX2 ou MSX1, pela experiência de uso.

- Faça um teste, qualquer coisa, notifique-me sobre o modelo que está utilizando, assim podemos manter uma lista de modelo e compatibilidade da imagem. :)

- O modo de hibernação pode não funcionar corretamente em alguns modelos de Netbook mais antigos, fazendo o sistema travar e ficar em tela escura. Nesse caso, desligue e ligue novamente o computador.


---

# Instalando em um HD a live

- Já coloquei esse tópico antes que surjam perguntas. Até o momento *NÃO HÁ INSTALADOR* para a live, pelo motivo de que ela ainda não está madura e não foi testada em mais dispositivos.

- Ainda que você copie o conteúdo do pendrive para um HD, poderá não ter a experiÊncia desejada, pois os scripts dependem do volume GUSTOSX para ler ROMs, persistÊncia, etc.

- Nessa fase de ajustes, até a versão beta 1.0, não haverá instalador. Quando estiver mais estabilizado e testado, aí sim, podemos ativar a live para o modo de instalador. Por isso, peço compreensão.

- Mesmo em modo live, novas ISOs com melhorias poderão ser colocadas na partição do ventoy, sem danificar o volume de persistência do usuário, com suas ROMs, HD, etc.

---

# Arquitetura e desenvolvimento da Distro

## Estrutura base:

- Linux Kernel 6.x
- Debian 12 bookworm 32 bits
- Xfce limitado
- GCC 12 e binários do GCC 13, necessário para rodar o OpenMSX
- Python 3
- OpenMSX 21 (versão da master de abril/2026)
- Shell scripts

## Building:

- 1. Instale os pacotes necessários:

```
sudo apt update
   
sudo apt install build-essential git live-build gcc g++ make cmake
```

- 2. Clone este repositório

```
git clone https://github.com/CleversonSA/gustosx live-gustosx
```

- 3. Compile. Dependendo de onde estiver fazendo o build, irá demorar em torno de 2h (sério)

```
cd live-gustosx
   sudo build dev
```

- 4. Se tudo estiver OK, um arquivo ISO será gerado:

```
cd dist
   
ls
```

- 5. Copie a ISO gerada para a pasta principal do Ventoy para testar.


---

## Pegadinha do BUILD! *ATENÇÃO**

- 1. Mesmo sendo uma versão 32 bits, o kernel costuma a mudar a versão minor, aí, após 2h de compilação você pode se deparar com um erro frustante do GRUB (e que me fez passar raiva várias vezes). Parece que a cada duas semanas muda, eu já peguei caso que mudou de uma semana para outra e só descobri depois de perder umas boas horas

- 2. Verifique qual a última minor dos seguintes arquivos:

```
vmlinuz-6.1.0-*
initrd.img-6.1.0-*-686-pae
```

- 3. Altere o arquivo ```config/includes.binary/boot/grub/grub.cfg```

- 4. Refaça o procedimento de build
  
---

# Detalhes do Linux

- Caso precise acessar o terminal pressione CTRL+F3

- As credenciais padrões da imagem são usuário **gustosx** e senha **gustosx**

---

# Licença

- Esse projeto é distribuído sob a licença GNU GPLv2.

```
This program is free software; you can redistribute it and/or
modify it under the terms os the GNU General Public License
version 2 as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

- Use por sua conta em risco, faça sempre backup de seus dados e não utilize/armazene/distribua informações sigilosas ou sensíveis nesta distribuição.

---

# Considerações finais

Divirtam-se **fudebas**!

---

# CHANGELOG

## [0.6.2] - 05/2026

- Primeira versão distribuível

