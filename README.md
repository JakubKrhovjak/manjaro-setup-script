# Dev Tools Installation Script for Manjaro

Automatizovaný instalační skript pro nastavení vývojového prostředí na Manjaro Linuxu.

## Přehled

Tento skript automaticky nainstaluje a nakonfiguruje kompletní sadu vývojářských nástrojů pro práci s různými technologiemi včetně Java, Node.js, Go, Docker, Kubernetes a cloud nástroji.

## Nainstalované nástroje

### Základní nástroje
- **Git** - systém pro správu verzí
- **Base Development Tools** - `base-devel`, curl, wget, zip, unzip

### Kontejnerizace
- **Docker** - platforma pro kontejnerizaci aplikací
- **Docker Compose** - nástroj pro definování multi-container Docker aplikací

### Programovací jazyky a runtime
- **Go** - programovací jazyk
- **Java 21** - nainstalováno přes SDKMAN (Temurin distribuce)
- **Node.js 21** - nainstalováno přes NVM

### Build nástroje a package managery
- **Maven** - build nástroj pro Java projekty (přes SDKMAN)
- **npm** - package manager pro Node.js (součást Node.js)
- **SDKMAN** - SDK manager pro Java ekosystém
- **NVM** - Node Version Manager

### Infrastructure as Code
- **Terraform** - nástroj pro správu infrastruktury jako kódu

### Kubernetes
- **kubectl** - CLI pro práci s Kubernetes clustery
- **Kind** - Kubernetes in Docker (lokální Kubernetes clustery)

### Cloud nástroje
- **Google Cloud SDK (gcloud)** - CLI pro Google Cloud Platform
- **GKE gcloud auth plugin** - plugin pro autentizaci kubectl s GKE clustery

## Požadavky

- Manjaro Linux nebo Arch-based distribuce
- Sudo oprávnění
- Internetové připojení

## Instalace

1. Stáhněte skript:
```bash
git clone <repository-url>
cd setup-script
```

2. Nastavte práva ke spuštění:
```bash
chmod +x setup-script.sh
```

3. Spusťte skript:
```bash
./setup-script.sh
```

## Po instalaci

### Restart shellu
Pro načtení všech změn v prostředí spusťte:
```bash
source ~/.bashrc
```

Pokud používáte zsh:
```bash
source ~/.zshrc
```

Případně restartujte terminál.

### Docker oprávnění
Pro aktivaci Docker oprávnění se odhlaste a znovu přihlaste do systému.

### Ověření instalace
Zkontrolujte verze nainstalovaných nástrojů:
```bash
git --version
docker --version
go version
terraform --version
java -version
mvn --version
node --version
npm --version
kubectl version --client
kind --version
gcloud --version
```

## Konfigurace SDKMAN a NVM

### SDKMAN
SDKMAN je nainstalován v `~/.sdkman/`. Pro správu Java verzí:
```bash
sdk list java          # Seznam dostupných Java verzí
sdk install java <version>
sdk use java <version>
sdk default java <version>
```

### NVM
NVM je nainstalován v `~/.nvm/`. Pro správu Node.js verzí:
```bash
nvm list               # Seznam nainstalovaných verzí
nvm install <version>  # Instalace další verze
nvm use <version>      # Použití konkrétní verze
nvm alias default <version>
```

## Google Cloud SDK

Po instalaci je potřeba provést inicializaci:
```bash
gcloud init
```

Pro přihlášení k GCP:
```bash
gcloud auth login
```

Pro konfiguraci kubectl s GKE:
```bash
gcloud container clusters get-credentials <cluster-name> --region=<region>
```

## Poznámky

- Skript kontroluje, zda nástroje již nejsou nainstalovány, a přeskočí jejich instalaci
- Všechny nástroje jsou instalovány s nejnovějšími stabilními verzemi
- Skript používá `set -e`, což znamená, že se zastaví při první chybě
- Docker vyžaduje sudo oprávnění pro správu služeb
- Uživatel je automaticky přidán do Docker skupiny

## Odinstalace

Pro odinstalaci jednotlivých nástrojů:

```bash
# SDKMAN
rm -rf ~/.sdkman

# NVM
rm -rf ~/.nvm

# Google Cloud SDK
rm -rf ~/google-cloud-sdk

# Ostatní nástroje přes pacman
sudo pacman -R git docker docker-compose go terraform kubectl
```

## Podpora

Pokud narazíte na problémy:
1. Zkontrolujte, že máte aktuální Manjaro Linux
2. Ověřte internetové připojení
3. Zkontrolujte sudo oprávnění
4. Podívejte se na výstup skriptu pro detaily chyb