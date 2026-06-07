# 🏛️ Gerenciador de Projetos de Arquitetura

![Status](https://img.shields.io/badge/status-em_desenvolvimento-yellow)
![Flutter](https://img.shields.io/badge/Flutter-3.x.x-blue)
![Arquitetura](https://img.shields.io/badge/Arquitetura-MVVM-orange)
![Deploy](https://img.shields.io/badge/Deploy-Firebase_Hosting-FFCA28)
![Licença](https://img.shields.io/badge/licen%C3%A7a-Privado-red)

Um sistema multimodal robusto e responsivo, construído com Flutter, focado no gerenciamento completo de múltiplos projetos de arquitetura e análise de produtividade da equipe.

---

## Tabela de Conteúdos
* [📖 Sobre o Projeto](#-sobre-o-projeto)
* [✨ Funcionalidades](#-funcionalidades)
* [🛠️ Tecnologias Utilizadas](#-tecnologias-utilizadas)
* [🏗️ Arquitetura do Projeto](#️-arquitetura-do-projeto)
* [🚀 Configuração e Execução](#-configuração-e-execução)
  * [1. Usuário Final e Administradores](#1-usuário-final-e-administradores)
  * [2. Ambiente de Desenvolvimento](#2-ambiente-de-desenvolvimento)
* [📄 Template de Projetos](#-template-de-projetos)
* [📜 Licença](#-licença)

---

### 📖 Sobre o Projeto

Este projeto nasceu da necessidade de um sistema eficiente para o controle detalhado e padronizado de múltiplos projetos de arquitetura. O aplicativo opera prioritariamente em ambiente **Web** (com suporte à Desktop e Mobile), utilizando uma estrutura hierárquica profunda (Projetos > Etapas > Subetapas > Tarefas).

Além do acompanhamento visual, o sistema conta com métricas de rastreamento de tempo (Time Tracking) integradas, painel de relatórios nativo para análises de produtividade e um sistema de aprovação e gerenciamento de equipe. 

A criação de novos projetos é orientada por um template base (`JSON`), garantindo consistência técnica em todos os novos fluxos de trabalho.

---

### ✨ Funcionalidades

* **Gerenciamento Completo (CRUD):** Crie, visualize, atualize prazos, arquive e exclua projetos.
* **Estrutura Hierárquica Profunda:** Organização minuciosa através de Etapas, Subetapas e Tarefas.
* **Time Tracking (Cronômetro):** Registro automático do tempo gasto pelos colaboradores por etapa e subetapa ao expandir os itens.
* **Gestão de Equipe e Permissões:**
  * Divisão clara entre `Administrador` e `Colaborador`.
  * Autorização manual de novos cadastros (Usuários pendentes ficam em uma fila de aprovação).
  * Atribuição de colaboradores a projetos, etapas ou subetapas específicas.
* **Relatórios e BI In-App:** Dashboards nativos para visualizar a volumetria de projetos, projetos em atraso e o cálculo de produtividade baseada na complexidade e metragem (min/m²).
* **Ações em Lote e Lixeira:** Marque/desmarque todas as tarefas, ou exclua etapas/subetapas mantendo a opção de restauração (Soft Delete).
* **Sincronização em Tempo Real:** Banco de dados reativo via Firestore. Alterações feitas por um usuário refletem instantaneamente para a equipe.
* **UX/UI Otimizada:** Suporte a Tema Claro/Escuro e layout responsivo com `NavigationRail` para telas maiores.

---

### 🛠️ Tecnologias Utilizadas

#### Frontend (Aplicação)
* **Dart & Flutter:** Framework de UI focado na compilação Web/Desktop.
* **Provider:** Gerenciamento de estado reativo.
* **Shared Preferences:** Persistência de configurações locais (ex: Tema Claro/Escuro).

#### Backend (BaaS) & Integrações
* **Firebase Authentication:** Autenticação de usuários.
* **Cloud Firestore:** Banco de dados NoSQL estruturado em tempo real.
* **Firebase Hosting:** Hospedagem da aplicação Web.

#### CI/CD & Dados
* **GitHub Actions:** Pipeline automatizado para deploy no Firebase Hosting a cada push/merge na branch `main`.

---

### 🏗️ Arquitetura do Projeto

O código-fonte segue o padrão **MVVM (Model-View-ViewModel)**, promovendo forte separação de responsabilidades:

* **UI (Views):** Widgets organizados por features (Auth, Projects, Reports, Users).
* **ViewModels:** Cérebros da interface gerenciando os fluxos e comandos via `ChangeNotifier`.
* **Domain (Models):** Entidades com regras de negócio encapsuladas (ex: cálculo autônomo de progresso de `Project` e `Step`).
* **Data:** Dividida em **Repositories** (ponto único de verdade para os ViewModels) e **Services** (comunicação direta e conversão de DTOs do Firestore).

---

### 🚀 Configuração e Execução

#### 1. Usuário Final e Administradores

Sendo uma aplicação **Web-First**, não há necessidade de instalação de APKs ou executáveis.
1. Acesse a URL web fornecida pela equipe (via Firebase Hosting).
2. Na primeira vez, clique em **Registre-se** e crie uma conta.
3. Aguarde um **Administrador** aprovar seu acesso. A tela recarregará automaticamente assim que a autorização for concedida.

---

#### 2. Ambiente de Desenvolvimento

Para garantir a integridade dos dados, **nunca utilize o Firebase de Produção para testes locais**. Siga o guia abaixo para criar um ambiente de desenvolvimento (Sandbox) isolado.

##### Pré-requisitos
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 3.2.0 ou superior)
* Node.js (necessário para instalar o Firebase CLI)
* Uma conta Google para criar o projeto no Firebase.

##### Passo a Passo: Clonando e Isolando o Ambiente

1. **Clone o repositório e baixe as dependências:**
   ```bash
   git clone [https://github.com/DavidDias1999/gerenciador_de_projetos.git](https://github.com/DavidDias1999/gerenciador_de_projetos.git)
   cd gerenciador_de_projetos
   flutter pub get
   ```

2. **Crie seu próprio projeto Firebase (Sandbox):**
   * Acesse o [Console do Firebase](https://console.firebase.google.com/).
   * Clique em **Adicionar projeto** e dê um nome (ex: `gerenciador-projetos-dev`).
   * Desative o Google Analytics (não é necessário para testes locais) e clique em **Criar projeto**.

3. **Habilite os serviços no seu novo Firebase:**
   * Vá em **Build > Authentication**, clique em "Vamos começar" e ative o provedor de **E-mail/Senha**.
   * Vá em **Build > Firestore Database**, clique em "Criar banco de dados" e inicie no **Modo de teste** para facilitar o desenvolvimento inicial.

4. **Instale as ferramentas de linha de comando (CLI):**
   Se você ainda não tem o Firebase CLI instalado, execute no terminal:
   ```bash
   npm install -g firebase-tools
   ```
   Em seguida, instale o FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

5. **Vincule o projeto local ao seu Firebase Dev:**
   Faça login no Firebase com a conta Google que você usou para criar o projeto:
   ```bash
   firebase login
   ```
   Agora, configure o FlutterFire para conectar o código ao seu Firebase. Na raiz do projeto Flutter, rode:
   ```bash
   flutterfire configure
   ```
   * *Selecione o projeto Firebase que você acabou de criar.*
   * *Escolha as plataformas (Web, Android, iOS).*
   * *Isso irá gerar o arquivo `lib/firebase_options.dart` com as chaves do **seu** ambiente de testes.*

6. **Execute o aplicativo localmente:**
   Tudo pronto! Seu ambiente de desenvolvimento está completamente isolado da produção.
   ```bash
   flutter run -d chrome
   ```
   *(Nota: O primeiro usuário a se registrar no seu banco recém-criado será promovido a Administrador e Autorizado automaticamente pelas regras do `AuthRepository`).*

---

### 📄 Template de Projetos

O aplicativo utiliza um arquivo de configuração central localizado em `assets/project_template.json`. Esse arquivo rege a estrutura padrão que todos os novos projetos irão herdar (Etapas de `REF`, `LTA`, `PIA` etc., e suas respectivas Tarefas/Subetapas).
Qualquer alteração na padronização dos processos da empresa deve ser refletida atualizando este JSON.

---

### 📜 Licença

Projeto Privado. O uso, distribuição ou modificação sem autorização expressa dos mantenedores é estritamente proibido.