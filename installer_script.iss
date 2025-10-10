; installer_script.iss

[Setup]
; NOTA: AppId é um ID único global. Gere um novo para seu app.
; Você pode usar a ferramenta "Tools -> Generate GUID" no editor do Inno Setup.
AppId={{E9E3D5D6-3687-4041-BA8D-7B49A5646D5B}}
AppName=Gerenciador de Projetos
; IMPORTANTE: Esta versão DEVE ser a mesma do seu pubspec.yaml
AppVersion=1.1.1
AppPublisher=David Dias
DefaultDirName={autopf}\Gerenciador de Projetos
DefaultGroupName=Gerenciador de Projetos
AllowNoIcons=yes
; O nome do arquivo .exe gerado pelo Inno Setup
OutputBaseFilename=Setup-Gerenciador-de-Projetos
Compression=lzma
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\gerenciador_de_projetos.exe
; Garante que apenas uma instância do app/instalador rode por vez (evita corrupção na atualização)
AppMutex=GerenciadorDeProjetosMutex

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; IMPORTANTE: Esta é a linha principal.
; Ela copia TUDO da pasta de release do seu build Flutter para a pasta de instalação.
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTA: O "{app}" é uma constante do Inno Setup para o diretório de instalação (ex: C:\Program Files\...).

[Icons]
Name: "{group}\Gerenciador de Projetos"; Filename: "{app}\gerenciador_de_projetos.exe"
Name: "{autodesktop}\Gerenciador de Projetos"; Filename: "{app}\gerenciador_de_projetos.exe"; Tasks: desktopicon

[Run]
; Executa o aplicativo automaticamente após a instalação...
Filename: "{app}\gerenciador_de_projetos.exe"; Description: "{cm:LaunchProgram,Gerenciador de Projetos}"; Flags: nowait postinstall skipifsilent