# Gerenciador de Projetos de Arquitetura
Um aplicativo multimodal feito em Flutter para gerenciar projetos de arquitetura.

### 📖 Sobre o Projeto

Este projeto nasceu da necessidade de um sistema robusto e simples para o gerenciamento de múltiplos projetos de arquitetura. O aplicativo permite o controle detalhado de cada projeto através de uma estrutura hierárquica de etapas e tarefas, com um template base que pode ser customizado via JSON.

Futuramente terá métodos para quantificar o tempo que os colabores levaram para concluir cada etapa, sendo possível metrificar:
* A média que cada colaborador leva para realizar cada etapa (sendo possível gerir os colaboradores onde mais tenham resultados).

* a média de tempo por metro quadrado para realizar cada etapa.


### ✨ Funcionalidades
* Gerenciamento Completo de Projetos (CRUD): Crie, visualize, atualize o status (ativo/finalizado) e delete projetos.

* Estrutura Hierárquica: Cada projeto é composto por etapas, e cada etapa é composta por tarefas.

* Controle de Tarefas: Marque e desmarque tarefas com checkboxes, com atualização instantânea do progresso.

* Visualização de Progresso: Barras de progresso visuais para cada etapa e para o projeto como um todo.

* Ações em Lote: Menus contextuais para marcar/desmarcar todas as tarefas de uma etapa ou deletar etapas/projetos.

* Template de Projetos: Criação de novos projetos a partir de um template pré-definido em um arquivo JSON, facilitando a padronização.

* Persistência Local: Todos os dados são salvos em um banco de dados SQLite no dispositivo, graças ao framework Drift.

* Navegação Clara: Interface com NavigationRail para separar e organizar projetos "Ativos" e "Finalizados".


### 🛠️ Tecnologias Utilizadas
Este projeto foi construído utilizando as seguintes tecnologias e pacotes:

* Dart: Linguagem de programação. 

* Flutter: Framework principal para a construção da interface.


* Drift (SQLite): Framework de banco de dados local para persistência de dados de forma reativa e segura.


### 🚀 Como Executar o Projeto
Siga os passos abaixo para configurar e executar o ambiente de desenvolvimento.

Pré-requisitos
Antes de começar, você vai precisar ter instalado em sua máquina:

* Flutter/Dart (Instalação Padrão)

* Git

#### Instalação
Clone o repositório para sua máquina local e abra o terminal:

Bash

> flutter pub get


Execute o gerador de código do Drift (passo essencial):

Bash

> dart run build_runner build --delete-conflicting-outputs

Execute o aplicativo no seu dispositivo Windows:

Bash

> flutter run -d windows



### 📄 Licença
Este projeto está sob a licença MIT. Veja o arquivo LICENSE.md para mais detalhes.