# 🏛️ Gerenciador de Projetos de Arquitetura

![Status](https://img.shields.io/badge/status-em_desenvolvimento-yellow)
![Flutter](https://img.shields.io/badge/Flutter-3.x.x-blue)
![Licença](https://img.shields.io/badge/licen%C3%A7a-Privado-red)

Um aplicativo mobile robusto e simples, construído em Flutter, para o gerenciamento de múltiplos projetos de arquitetura.

---

## Tabela de Conteúdos
* [📖 Sobre o Projeto](#-sobre-o-projeto)
* [✨ Funcionalidades](#-funcionalidades)
* [🖼️ Screenshots](#-screenshots)
* [🛠️ Tecnologias Utilizadas](#-tecnologias-utilizadas)
* [🚀 Configuração e Execução](#-configuração-e-execução)
  * [Pré-requisitos](#pré-requisitos)
  * [1. Configuração (Desenvolvedor)](#1-configuração-desenvolvedor)
  * [2. Pipeline de Dados (Administrador)](#2-pipeline-de-dados-administrador)
  * [3. Instalação (Usuário Final)](#3-instalação-usuário-final)
* [📄 Template de Projetos](#-template-de-projetos)
* [⚠️ Nota Importante](#️-nota-importante)
* [📜 Licença](#-licença)

---

### 📖 Sobre o Projeto

Este projeto nasceu da necessidade de um sistema eficiente para o gerenciamento de múltiplos projetos de arquitetura. O aplicativo permite o controle detalhado de cada projeto através de uma estrutura hierárquica (projetos > etapas > tarefas) e inclui métodos para quantificar o tempo gasto pelos colaboradores em cada etapa.

A aplicação utiliza um template base (customizável via JSON) para padronizar a criação de novos projetos, garantindo consistência e agilidade.

---

### ✨ Funcionalidades

* **Gerenciamento Completo (CRUD):** Crie, visualize, atualize (ativo/finalizado) e delete projetos.
* **Estrutura Hierárquica:** Organize projetos em Etapas e Etapas em Tarefas.
* **Controle de Tarefas:** Marque/desmarque tarefas com checkboxes, atualizando o progresso instantaneamente.
* **Quantificação de Tempo:** Registre o tempo gasto por colaboradores em cada etapa.
* **Visualização de Progresso:** Barras de progresso visuais para cada etapa e para o projeto como um todo.
* **Ações em Lote:** Menus contextuais para marcar/desmarcar todas as tarefas de uma etapa ou deletar itens.
* **Template de Projetos:** Crie novos projetos a partir de um template JSON pré-definido.
* **Sincronização em Tempo Real:** Os dados são salvos e sincronizados com o Firebase, permitindo cache offline.
* **Navegação Clara:** Interface com `NavigationRail` para separar projetos "Ativos" e "Finalizados".

---

### 🛠️ Tecnologias Utilizadas

Este projeto é dividido em dois componentes principais: o aplicativo mobile e o pipeline de análise de dados.

#### Aplicativo Mobile (Flutter)
* **Dart:** Linguagem de programação principal.
* **Flutter:** Framework para construção da interface de usuário (UI).
* **Firebase Authentication:** Para gerenciamento de login e usuários.
* **Firestore Database:** Banco de dados NoSQL para armazenamento e sincronização dos dados dos projetos.

#### Backend e Análise de Dados (BI)
* **Python:** Utilizado para criar scripts de extração e transformação dos dados.
* **Google Sheets:** Usado como intermediário para a importação de dados antes do BI.
* **Looker Studio (antigo Data Studio):** Ferramenta de Business Intelligence para tratamento e visualização dos dados.

---

### 🚀 Configuração e Execução

Esta seção é dividida com base no nível de acesso: Administrador, Usuário Final e Desenvolvedor.


#### 1. Instalação (Usuário Final)

Usuários finais (colaboradores) devem instalar o aplicativo através do arquivo APK fornecido pelo administrador.

1.  Baixe o arquivo `.apk` disponibilizado pelos administradores.
2.  Abra o arquivo no seu dispositivo Android.
3.  O sistema pode notificá-lo de que "o arquivo pode ser prejudicial". Isso é um aviso padrão para aplicativos instalados fora da Play Store.
4.  Siga as instruções do seu dispositivo para autorizar a instalação de fontes desconhecidas e confirme a instalação.

---

#### 2. Uso do Administrador
Para ter acesso aos Dashboards no Looker, o administrador deve primeiro extrair e processar os dados do Firestore.

> **Nota:** Esta etapa requer arquivos de configuração privados (como chaves de serviço do Google Cloud) que são disponibilizados apenas aos administradores.

O processo envolve dois scripts Python:

1.  **Exportar dados do Firestore:**
    Este script baixa os dados relevantes do Firestore e os salva localmente.
    ```bash
    py export_firestore_manual.py
    ```

2.  **Enviar dados para o Google Sheets:**
    Este script pega os arquivos gerados e os envia para a planilha do Google Sheets que serve de fonte para o Looker.
    ```bash
    py upload_csv_to_sheets.py
    ```

3.  **Atualizar o Looker:**
    * Após a execução bem-sucedida dos scripts, abra o Dashboard no Looker Studio.
    * Clique em: *Mais Opções -> Atualizar Dados*.
    * O Looker buscará os novos dados do Google Sheets e atualizará os gráficos.

---


#### Desenvolvedor

##### Pré-requisitos
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 3.x.x ou superior)
* Uma conta [Firebase](https://firebase.google.com/)
* [Python 3](https://www.python.org/downloads/) (para os scripts de BI)
* Acesso ao [Google Cloud Console](https://console.cloud.google.com/) com APIs do Sheets habilitadas.

---

#### 1. Configuração (Desenvolvedor)
Para rodar o projeto localmente para desenvolvimento ou de forma independente.

1.  **Clone o repositório:**
    Em uma basta pré-definida execute
    ```bash
    git clone https://github.com/DavidDias1999/gerenciador_de_projetos
    ```

2.  **Crie seu projeto Firebase:**
    * Acesse o console do Firebase e crie um novo projeto.
    * Adicione um aplicativo Flutter (Android/iOS).
    * Ative os serviços **Firebase Authentication** (ex: E-mail/Senha) e **Firestore Database**.

3.  **Configure o FlutterFire:**
    * Instale o Firebase CLI: `dart pub global activate flutterfire_cli`
    * Faça login: `firebase login`
    * Configure o app: `flutterfire configure`
    * Isso irá gerar o arquivo `lib/firebase_options.dart` automaticamente.

4.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

5.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

---




