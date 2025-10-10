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


## 🚀 Instalação

Você pode baixar a versão mais recente do Gerenciador de Projetos para Windows diretamente da nossa página de Releases.

**[➡️ Baixar a Última Versão](https://github.com/DavidDias1999/gerenciador_de_projetos/releases/latest)**

Basta baixar o arquivo `Setup-Gerenciador-de-Projetos.exe` do release mais recente e executá-lo para instalar o aplicativo. O sistema de atualização automática irá notificá-lo sobre novas versões no futuro!

### OBS: O aplicativo irá gerar um arquivo db.sqlite na pasta Documentos responsavel por armazenar todos os Projetos e Usuários locais. 
 ***Posteriormente um serviço de nuvem será implementado.***
 ## NÃO EXCLUA!!

