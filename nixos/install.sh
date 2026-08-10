#!/usr/bin/env bash
# ==============================================================================
# SCRIPT DE INSTALAÇÃO DO NIXOS (DEN SYSTEM)
# ==============================================================================

set -e

# Cores e Estilos
BOLD="\e[1m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
   _  ___       ____  ____   _____         _ 
  / |/ (_)_  __/ __ \/ __/  / ___/ _  ____/ /____  _____
 /    / /| |/_/ / / /\ \    \__ \ / |/ / / __/ _ \/ ___/
/ /| / / _>  </ /_/ /___/ /  ___/ //    / /_/  __/ /    
/_/ |_/_/_/|_|\____//____/  /____//_/|_/\__/\___/_/     
EOF
    echo -e "${RESET}"
    echo -e "${BLUE}=== Instalador Automatizado & Personalizado do NixOS (Den) ===${RESET}\n"
}

info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

success() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[AVISO]${RESET} $1"
}

error() {
    echo -e "${RED}[ERRO]${RESET} $1"
    exit 1
}

# ------------------------------------------------------------------------------
# 1. Verificações Pré-Instalação
# ------------------------------------------------------------------------------
banner

if [ "$EUID" -ne 0 ]; then
    error "Este script deve ser executado como root! Use: sudo ./install.sh"
fi

if [ ! -d "/sys/firmware/efi/efivars" ]; then
    error "Este sistema não foi inicializado no modo UEFI. O instalador requer UEFI!"
fi

info "Verificando conexão com a internet..."
if ! ping -c 1 1.1.1.1 &>/dev/null; then
    warn "Não foi possível conectar à internet via IP. Verificando DNS..."
    if ! ping -c 1 nixos.org &>/dev/null; then
        error "Sem conexão com a internet! Conecte-se à rede (ex: nmtui / nmtui-connect ou iwctl) e rode o script novamente."
    fi
fi
success "Conexão de rede ativa."

# ------------------------------------------------------------------------------
# 2. Coleta de Informações do Usuário e Hostname
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}--- 1. Identificação do Sistema ---${RESET}"

read -rp "$(echo -e "${CYAN}Digite o Hostname (Nome da máquina) [padrão: casita]: ${RESET}")" HOSTNAME
HOSTNAME=${HOSTNAME:-casita}

read -rp "$(echo -e "${CYAN}Digite o Nome de Usuário (Username) [padrão: asaph]: ${RESET}")" USERNAME
USERNAME=${USERNAME:-asaph}

read -rp "$(echo -e "${CYAN}Digite o Nome Completo do Usuário [padrão: Usuário NixOS]: ${RESET}")" FULLNAME
FULLNAME=${FULLNAME:-"Usuário NixOS"}

while true; do
    read -rsp "$(echo -e "${CYAN}Digite a Senha do Usuário ($USERNAME): ${RESET}")" USER_PASS
    echo
    read -rsp "$(echo -e "${CYAN}Confirme a Senha do Usuário ($USERNAME): ${RESET}")" USER_PASS_CONFIRM
    echo
    if [ "$USER_PASS" = "$USER_PASS_CONFIRM" ] && [ -n "$USER_PASS" ]; then
        break
    else
        warn "As senhas não coincidem ou estão vazias. Tente novamente."
    fi
done

while true; do
    read -rsp "$(echo -e "${CYAN}Digite a Senha do Root (Administrador): ${RESET}")" ROOT_PASS
    echo
    read -rsp "$(echo -e "${CYAN}Confirme a Senha do Root: ${RESET}")" ROOT_PASS_CONFIRM
    echo
    if [ "$ROOT_PASS" = "$ROOT_PASS_CONFIRM" ] && [ -n "$ROOT_PASS" ]; then
        break
    else
        warn "As senhas não coincidem ou estão vazias. Tente novamente."
    fi
done

# ------------------------------------------------------------------------------
# 3. Gerenciador de Arquivos
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}--- 2. Gerenciador de Arquivos ---${RESET}"
echo "1) Thunar (XFCE - Leve, suporte a plugins de compressão e automount) [Recomendado]"
echo "2) Nautilus (GNOME - Moderno e integrado)"
echo "3) Yazi (Terminal TUI ultra-rápido)"
echo "4) Dolphin (KDE - Completo e cheio de recursos)"
read -rp "$(echo -e "${CYAN}Escolha o Gerenciador de Arquivos [1-4, padrão: 1]: ${RESET}")" FILE_MANAGER_CHOICE
FILE_MANAGER_CHOICE=${FILE_MANAGER_CHOICE:-1}

case $FILE_MANAGER_CHOICE in
    1) FILE_MANAGER_PKG="pkgs.thunar"; FILE_MANAGER_NAME="Thunar" ;;
    2) FILE_MANAGER_PKG="pkgs.nautilus"; FILE_MANAGER_NAME="Nautilus" ;;
    3) FILE_MANAGER_PKG="pkgs.yazi"; FILE_MANAGER_NAME="Yazi" ;;
    4) FILE_MANAGER_PKG="pkgs.kdePackages.dolphin"; FILE_MANAGER_NAME="Dolphin" ;;
    *) FILE_MANAGER_PKG="pkgs.thunar"; FILE_MANAGER_NAME="Thunar" ;;
esac

# ------------------------------------------------------------------------------
# 4. Greeter Inicial / Gerenciador de Login
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}--- 3. Greeter Inicial (Tela de Login) ---${RESET}"
echo "1) Tuigreet (Greetd TUI rápido e minimalista em terminal) [Recomendado]"
echo "2) Regreet (Greetd GTK gráfico e elegante)"
echo "3) SDDM (Gerenciador de login Qt completo)"
echo "4) Autologin (Login automático direto na sessão Niri)"
read -rp "$(echo -e "${CYAN}Escolha o Greeter [1-4, padrão: 1]: ${RESET}")" GREETER_CHOICE
GREETER_CHOICE=${GREETER_CHOICE:-1}

case $GREETER_CHOICE in
    1) GREETER_NAME="tuigreet" ;;
    2) GREETER_NAME="regreet" ;;
    3) GREETER_NAME="sddm" ;;
    4) GREETER_NAME="autologin" ;;
    *) GREETER_NAME="tuigreet" ;;
esac

# ------------------------------------------------------------------------------
# 5. Opções Vitais Adicionais (GPU, Swap, FS, Teclado)
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}--- 4. Configurações de Hardware & Sistema ---${RESET}"

# Driver de Vídeo
HAS_NVIDIA=$(lspci 2>/dev/null | grep -i nvidia || true)
if [ -n "$HAS_NVIDIA" ]; then
    info "Placa gráfica NVIDIA detectada!"
    DEFAULT_GPU=1
else
    DEFAULT_GPU=2
fi

echo "1) NVIDIA proprietário (Recomendado para GPUs Nvidia)"
echo "2) Mesa / Open Source (AMD / Intel / Genérico)"
read -rp "$(echo -e "${CYAN}Escolha o driver de GPU [1-2, padrão: $DEFAULT_GPU]: ${RESET}")" GPU_CHOICE
GPU_CHOICE=${GPU_CHOICE:-$DEFAULT_GPU}

# Swap
echo -e "\nEstratégia de SWAP:"
echo "1) ZRAM (RAM comprimida em memória - Economiza SSD e melhora performance) [Recomendado]"
echo "2) Partição SWAP física dedicada (8GB)"
echo "3) Sem SWAP"
read -rp "$(echo -e "${CYAN}Escolha a estratégia de SWAP [1-3, padrão: 1]: ${RESET}")" SWAP_CHOICE
SWAP_CHOICE=${SWAP_CHOICE:-1}

# Sistema de Arquivos
echo -e "\nSistema de Arquivos para a Partição Raiz:"
echo "1) Ext4 (Estável e tradicional) [Recomendado]"
echo "2) Btrfs (Moderno, com suporte a snapshots)"
read -rp "$(echo -e "${CYAN}Escolha o Sistema de Arquivos [1-2, padrão: 1]: ${RESET}")" FS_CHOICE
FS_CHOICE=${FS_CHOICE:-1}

if [ "$FS_CHOICE" -eq 2 ]; then
    ROOT_FS_TYPE="btrfs"
else
    ROOT_FS_TYPE="ext4"
fi

# Timezone e Layout de Teclado
read -rp "$(echo -e "${CYAN}Fuso Horário [padrão: America/Sao_Paulo]: ${RESET}")" TIMEZONE
TIMEZONE=${TIMEZONE:-America/Sao_Paulo}

read -rp "$(echo -e "${CYAN}Layout de Teclado no Console/X11 [padrão: br]: ${RESET}")" KEYBOARD_LAYOUT
KEYBOARD_LAYOUT=${KEYBOARD_LAYOUT:-br}

# ------------------------------------------------------------------------------
# 6. Seleção de Disco & Particionamento
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}--- 5. Seleção de Disco ---${RESET}"
echo -e "${YELLOW}Discos disponíveis no sistema:${RESET}\n"
lsblk -d -n -o NAME,SIZE,MODEL,TYPE | grep -E "disk" || true

echo
read -rp "$(echo -e "${CYAN}Digite o dispositivo de destino (ex: /dev/sda ou /dev/nvme0n1): ${RESET}")" TARGET_DISK

if [ ! -b "$TARGET_DISK" ]; then
    error "O dispositivo '$TARGET_DISK' não existe ou não é um bloco válido!"
fi

echo -e "\nModo de Particionamento para $TARGET_DISK:"
echo "1) Automático (FORMATAR TODO O DISCO com EFI + Root + Swap se escolhido) [DESTRUTIVO]"
echo "2) Manual / Selecionar partições existentes"
read -rp "$(echo -e "${CYAN}Escolha a opção de particionamento [1-2, padrão: 1]: ${RESET}")" PART_MODE
PART_MODE=${PART_MODE:-1}

# ------------------------------------------------------------------------------
# 7. Resumo e Confirmação de Segurança
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}================================================================${RESET}"
echo -e "${BOLD}${RED}                RESUMO DA INSTALAÇÃO E CONFIGURAÇÃO             ${RESET}"
echo -e "${BOLD}================================================================${RESET}"
echo -e "${CYAN}Hostname:${RESET}            $HOSTNAME"
echo -e "${CYAN}Usuário Principal:${RESET}   $USERNAME ($FULLNAME)"
echo -e "${CYAN}Gerenciador Arquivos:${RESET}$FILE_MANAGER_NAME"
echo -e "${CYAN}Greeter / Display:${RESET}   $GREETER_NAME"
echo -e "${CYAN}Driver de GPU:${RESET}       $([ "$GPU_CHOICE" -eq 1 ] && echo "Nvidia Proprietário" || echo "Mesa / OpenSource")"
echo -e "${CYAN}Estratégia Swap:${RESET}     $([ "$SWAP_CHOICE" -eq 1 ] && echo "ZRAM (RAM Comprimida)" || ([ "$SWAP_CHOICE" -eq 2 ] && echo "Partição SWAP Física" || echo "Desativado"))"
echo -e "${CYAN}Sistema de Arquivos:${RESET} $ROOT_FS_TYPE"
echo -e "${CYAN}Disco de Destino:${RESET}    $TARGET_DISK"
echo -e "${CYAN}Modo Particionamento:${RESET}$([ "$PART_MODE" -eq 1 ] && echo "Automático (Formatando $TARGET_DISK)" || echo "Manual")"
echo -e "${BOLD}================================================================${RESET}"

if [ "$PART_MODE" -eq 1 ]; then
    echo -e "${RED}${BOLD}ATENÇÃO: TODOS OS DADOS EM $TARGET_DISK SERÃO APAGADOS PERMANENTEMENTE!${RESET}"
fi

read -rp "$(echo -e "${RED}${BOLD}Tem certeza de que deseja continuar? Digite 'SIM' para confirmar: ${RESET}")" CONFIRM
if [ "$CONFIRM" != "SIM" ] && [ "$CONFIRM" != "sim" ]; then
    warn "Instalação cancelada pelo usuário."
    exit 0
fi

# ------------------------------------------------------------------------------
# 8. Execução do Particionamento e Formatação
# ------------------------------------------------------------------------------
info "Iniciando particionamento e preparação do disco..."

if [[ "$TARGET_DISK" == *"nvme"* ]] || [[ "$TARGET_DISK" == *"mmcblk"* ]]; then
    PART_PREFIX="${TARGET_DISK}p"
else
    PART_PREFIX="${TARGET_DISK}"
fi

EFI_PART="${PART_PREFIX}1"

if [ "$PART_MODE" -eq 1 ]; then
    info "Criando nova tabela de partições GPT em $TARGET_DISK..."
    umount -R /mnt 2>/dev/null || true
    swapoff -a 2>/dev/null || true
    
    # Limpa tabela de partições antiga
    parted -s "$TARGET_DISK" mklabel gpt

    # Partição 1: EFI Boot (1GiB)
    parted -s "$TARGET_DISK" mkpart ESP fat32 1MiB 1025MiB
    parted -s "$TARGET_DISK" set 1 esp on

    if [ "$SWAP_CHOICE" -eq 2 ]; then
        # Partição 2: SWAP (8GiB)
        parted -s "$TARGET_DISK" mkpart primary linux-swap 1025MiB 9217MiB
        SWAP_PART="${PART_PREFIX}2"
        ROOT_PART="${PART_PREFIX}3"
        parted -s "$TARGET_DISK" mkpart primary $ROOT_FS_TYPE 9217MiB 100%
    else
        ROOT_PART="${PART_PREFIX}2"
        parted -s "$TARGET_DISK" mkpart primary $ROOT_FS_TYPE 1025MiB 100%
    fi

    # Atualiza tabela de partições do kernel
    udevadm settle || sleep 2

    info "Formatando partição EFI ($EFI_PART)..."
    mkfs.fat -F32 -n BOOT "$EFI_PART"

    if [ "$SWAP_CHOICE" -eq 2 ]; then
        info "Formatando partição SWAP ($SWAP_PART)..."
        mkswap -L SWAP "$SWAP_PART"
        swapon "$SWAP_PART"
    fi

    info "Formatando partição Raiz ($ROOT_PART)..."
    if [ "$ROOT_FS_TYPE" = "btrfs" ]; then
        mkfs.btrfs -f -L NIXOS "$ROOT_PART"
    else
        mkfs.ext4 -F -L NIXOS "$ROOT_PART"
    fi
else
    read -rp "$(echo -e "${CYAN}Digite a partição EFI (ex: ${PART_PREFIX}1): ${RESET}")" EFI_PART
    read -rp "$(echo -e "${CYAN}Digite a partição RAIZ (ex: ${PART_PREFIX}2): ${RESET}")" ROOT_PART
fi

# ------------------------------------------------------------------------------
# 9. Montagem dos Pontos de Montagem
# ------------------------------------------------------------------------------
info "Montando partições em /mnt..."
umount -R /mnt 2>/dev/null || true
mount "$ROOT_PART" /mnt

mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot

success "Partições montadas com sucesso em /mnt."

# ------------------------------------------------------------------------------
# 10. Copia e Customização da Configuração do NixOS
# ------------------------------------------------------------------------------
info "Copiando a configuração do repositório para /mnt/etc/nixos..."
mkdir -p /mnt/etc/nixos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -r "$SCRIPT_DIR"/* /mnt/etc/nixos/
rm -f /mnt/etc/nixos/install.sh 2>/dev/null || true

info "Aplicando personalizações nos módulos do Den e NixOS..."

# 1. Substituir "asaph" e "casita" no den.nix
sed -i "s/casita/$HOSTNAME/g" /mnt/etc/nixos/modules/den.nix
sed -i "s/asaph/$USERNAME/g" /mnt/etc/nixos/modules/den.nix
sed -i "s/Fortinho de Jesus/$FULLNAME/g" /mnt/etc/nixos/modules/den.nix
sed -i "s/name=Asaph/name=$USERNAME/g" /mnt/etc/nixos/modules/den.nix

# 2. Substituir no configuration.nix
sed -i "s/casita/$HOSTNAME/g" /mnt/etc/nixos/modules/_nixos/configuration.nix
sed -i "s/asaph/$USERNAME/g" /mnt/etc/nixos/modules/_nixos/configuration.nix
sed -i "s/America\/Sao_Paulo/$TIMEZONE/g" /mnt/etc/nixos/modules/_nixos/configuration.nix
sed -i "s/services.xserver.xkb.layout = \"br\";/services.xserver.xkb.layout = \"$KEYBOARD_LAYOUT\";/g" /mnt/etc/nixos/modules/_nixos/configuration.nix

# Comentar eventual montagem estática de /mnt/dados
sed -i 's|fileSystems."/mnt/dados"|# fileSystems."/mnt/dados"|g' /mnt/etc/nixos/modules/_nixos/configuration.nix

# Configuração do Gerenciador de Arquivos escolhido
if [ "$FILE_MANAGER_CHOICE" -ne 1 ]; then
    sed -i "s/pkgs.nautilus/$FILE_MANAGER_PKG/g" /mnt/etc/nixos/modules/desktop/niri/niri.nix
fi

# Configuração do Greeter
if [ "$GREETER_NAME" = "regreet" ]; then
    sed -i "s/tuigreet --time --cmd niri-session/regreet/g" /mnt/etc/nixos/modules/_nixos/configuration.nix
elif [ "$GREETER_NAME" = "sddm" ]; then
    sed -i "s/services.greetd = {/services.displayManager.sddm.enable = true;\n  # services.greetd = {/g" /mnt/etc/nixos/modules/_nixos/configuration.nix
elif [ "$GREETER_NAME" = "autologin" ]; then
    sed -i "s/command = \".*tuigreet.*\";//g" /mnt/etc/nixos/modules/_nixos/configuration.nix
    sed -i "s/user = \"greeter\";/command = \"\${pkgs.niri}\/bin\/niri-session\";\n        user = \"$USERNAME\";/g" /mnt/etc/nixos/modules/_nixos/configuration.nix
fi

# Configuração de GPU
if [ "$GPU_CHOICE" -eq 2 ]; then
    sed -i 's/services.xserver.videoDrivers = \["nvidia"\];/services.xserver.videoDrivers = \["modesetting"\];/g' /mnt/etc/nixos/modules/_nixos/configuration.nix
fi

# Configuração de ZRAM Swap
if [ "$SWAP_CHOICE" -eq 1 ]; then
    echo "  zramSwap.enable = true;" >> /mnt/etc/nixos/modules/_nixos/configuration.nix
fi

# Substituição global de usuário em todos os arquivos dentro de modules/
find /mnt/etc/nixos/modules -type f -exec sed -i "s/asaph/$USERNAME/g" {} +

# ------------------------------------------------------------------------------
# 11. Geração do hardware-configuration.nix do Sistema Alvo
# ------------------------------------------------------------------------------
info "Gerando hardware-configuration.nix com a detecção de discos da máquina..."
nixos-generate-config --root /mnt

if [ -f /mnt/etc/nixos/hardware-configuration.nix ]; then
    mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/modules/_nixos/hardware-configuration.nix
fi

success "hardware-configuration.nix gerado e integrado ao ecossistema Den."

# ------------------------------------------------------------------------------
# 12. Execução do nixos-install
# ------------------------------------------------------------------------------
info "Iniciando o nixos-install (compilando e baixando pacotes no /mnt)..."
nixos-install --root /mnt --no-channel-copy

# ------------------------------------------------------------------------------
# 13. Definição de Senhas dos Usuários no Chroot
# ------------------------------------------------------------------------------
info "Configurando senhas do usuário $USERNAME e root..."

nixos-enter --root /mnt -c "echo '$USERNAME:$USER_PASS' | chpasswd"
nixos-enter --root /mnt -c "echo 'root:$ROOT_PASS' | chpasswd"

success "Senhas atualizadas com sucesso!"

# ------------------------------------------------------------------------------
# 14. Finalização
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}${BOLD}================================================================${RESET}"
echo -e "${GREEN}${BOLD}      PARABÉNS! A INSTALAÇÃO DO NIXOS FOI CONCLUÍDA COM SUCESSO! ${RESET}"
echo -e "${GREEN}${BOLD}================================================================${RESET}"
echo -e "Você já pode reiniciar o computador e remover o pendrive de instalação.\n"

read -rp "$(echo -e "${CYAN}Deseja reiniciar a máquina agora? [s/N]: ${RESET}")" REBOOT_NOW
if [[ "$REBOOT_NOW" =~ ^[Ss]$ ]]; then
    info "Reiniciando em 5 segundos..."
    sleep 5
    reboot
else
    info "Instalação concluída. Você pode rodar 'reboot' quando estiver pronto."
fi
