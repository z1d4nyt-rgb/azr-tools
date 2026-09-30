#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  AZR TOOLS - All-in-One Termux Toolkit
#  by Zidan
# ============================================================

# ---------- WARNA (Cyan - Biru terang) ----------
C1='\033[38;5;51m'   # cyan terang (banner, judul kategori)
C2='\033[38;5;39m'   # biru terang (border, nomor menu)
C3='\033[38;5;87m'   # cyan muda (kembali/keluar)
C4='\033[38;5;45m'   # turquoise (judul tiap fitur)
C5='\033[38;5;33m'   # biru aksen (prompt)
WHITE='\033[97m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'
GREEN='\033[38;5;46m'
RED='\033[38;5;196m'
YELLOW='\033[38;5;220m'
declare -A CAT_COLOR_MAP=(
    [PREM]='\033[38;5;220m\033[1m'
    [SYS]='\033[38;5;51m'
    [NET]='\033[38;5;39m'
    [FILE]='\033[38;5;44m'
    [DEV]='\033[38;5;43m'
    [API]='\033[38;5;75m'
    [PROD]='\033[38;5;48m'
    [UTIL]='\033[97m'
    [FUN]='\033[38;5;50m'
)

BASE_DIR="$HOME/.azrtools"
BACKUP_DIR="$BASE_DIR/backups"
LOG_FILE="$BASE_DIR/azrtools.log"
mkdir -p "$BASE_DIR" "$BACKUP_DIR"

VERSION="1.4.1"
SETTINGS_FILE="$BASE_DIR/settings.conf"

# ---------- AUTO-UPDATE DARI GITHUB ----------
# Ganti UPDATE_USER & UPDATE_REPO sesuai akun/repo GitHub kamu sendiri.
# Repo harus punya 3 file di branch ini: azrtools.sh, VERSION, CHANGELOG.md
UPDATE_USER="z1d4nyt-rgb"
UPDATE_REPO="azr-tools"
UPDATE_BRANCH="main"
UPDATE_RAW_BASE="https://raw.githubusercontent.com/${UPDATE_USER}/${UPDATE_REPO}/${UPDATE_BRANCH}"
SNIPPET_FILE="$BASE_DIR/snippets.txt"

# ---------- KONFIGURASI PREMIUM (Alight Motion) ----------
PREM_ENDPOINT="https://hyerls.my.id/api/amprem.php"
PREM_KEY_DEFAULT="ITDYDKXKGZITSTSTKSTKSKTSTKSDJD"
PREM_CONF="$BASE_DIR/premium.conf"
PREM_HISTORY="$BASE_DIR/premium_history.log"
PREM_KEY="$PREM_KEY_DEFAULT"
if [[ -f "$PREM_CONF" ]]; then
    _k=$(grep -m1 '^KEY=' "$PREM_CONF" | cut -d= -f2-)
    [[ -n "$_k" ]] && PREM_KEY="$_k"
fi

# ---------- ANIMASI MENU (bisa dimatikan lewat Pengaturan Animasi) ----------
ANIM=1
if [[ -f "$SETTINGS_FILE" ]]; then
    ANIM=$(grep -m1 '^ANIM=' "$SETTINGS_FILE" | cut -d= -f2)
fi
[[ "$ANIM" == "0" ]] || ANIM=1

anim_pause() {
    [[ "$ANIM" == "1" ]] && sleep "${1:-0.012}"
    return 0
}

# ---------- UTIL ----------
pause() {
    echo ""
    printf "${DIM}${WHITE}Tekan ENTER untuk kembali ke menu...${NC}"
    read -r
}

typing() {
    local text="$1"
    local delay="${2:-0.015}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

spinner() {
    local pid=$1
    local msg="$2"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${C4}${frames[$i]}${NC} ${WHITE}%s${NC}" "$msg"
        sleep 0.08
    done
    printf "\r${GREEN}✔${NC} ${WHITE}%s${NC}\n" "$msg"
}

run_with_spinner() {
    local msg="$1"; shift
    ("$@" >> "$LOG_FILE" 2>&1) &
    local pid=$!
    spinner "$pid" "$msg"
    wait "$pid"
}

hr() {
    printf "${C3}"
    printf '─%.0s' $(seq 1 "${TERM_COLS:-${COLUMNS:-40}}")
    printf "${NC}\n"
}

# ---------- KOTAK UI (border ganda, hampir penuh layar) ----------
box_w() {
    local w=$(( ${TERM_COLS:-40} - 2 ))
    (( w > 90 )) && w=90
    (( w < 24 )) && w=24
    echo "$w"
}

box_top() {
    local w="$1" title="$2"
    if [[ -n "$title" ]]; then
        local t=" $title "
        local rest=$(( w - 3 - ${#t} )); (( rest < 0 )) && rest=0
        printf '%b╔═%b%s%b%s╗%b\n' "$C2" "${C4}${BOLD}" "$t" "$NC$C2" "$(printf '═%.0s' $(seq 1 $rest))" "$NC"
    else
        printf '%b╔%s╗%b\n' "$C2" "$(printf '═%.0s' $(seq 1 $((w-2))))" "$NC"
    fi
}

box_bottom() {
    local w="$1"
    printf '%b╚%s╝%b\n' "$C2" "$(printf '═%.0s' $(seq 1 $((w-2))))" "$NC"
}

# pembatas tebal di tengah panel (ganti sub-bagian)
box_div() {
    local w="$1" title="$2"
    anim_pause 0.02
    if [[ -n "$title" ]]; then
        local t=" $title "
        local rest=$(( w - 3 - ${#t} )); (( rest < 0 )) && rest=0
        printf '%b╠═%b%s%b%s╣%b\n' "$C2" "${C4}${BOLD}" "$t" "$NC$C2" "$(printf '═%.0s' $(seq 1 $rest))" "$NC"
    else
        printf '%b╠%s╣%b\n' "$C2" "$(printf '═%.0s' $(seq 1 $((w-2))))" "$NC"
    fi
}

# pembatas tipis (aksen kecil di dalam panel, mis. sebelum TIPS)
box_div_thin() {
    local w="$1" title="$2"
    anim_pause 0.02
    if [[ -n "$title" ]]; then
        local t=" $title "
        local rest=$(( w - 3 - ${#t} )); (( rest < 0 )) && rest=0
        printf '%b╟─%b%s%b%s╢%b\n' "$C3" "${C4}" "$t" "$NC$C3" "$(printf '─%.0s' $(seq 1 $rest))" "$NC"
    else
        printf '%b╟%s╢%b\n' "$C3" "$(printf '─%.0s' $(seq 1 $((w-2))))" "$NC"
    fi
}

box_line() {
    local w="$1" text="$2" color="${3:-$WHITE}"
    local inner=$((w - 4))
    if (( ${#text} > inner )) && (( inner > 1 )); then
        text="${text:0:$((inner-1))}…"
    fi
    local pad=$(( inner - ${#text} )); (( pad < 0 )) && pad=0
    local sp; printf -v sp '%*s' "$pad" ''
    printf '%b║%b %b%s%s %b║%b\n' "$C2" "$NC" "$color" "$text" "$sp" "$C2" "$NC"
    anim_pause 0.008
}

# baris khusus ASCII art di dalam panel: center, tanpa truncate/hitung-lebar-teks biasa
frame_art_line() {
    local w="$1" text="$2" color="$3" artw="$4"
    local inner=$((w - 4))
    local padtotal=$(( inner - artw )); (( padtotal < 0 )) && padtotal=0
    local lp=$(( padtotal / 2 )) rp=$(( padtotal - padtotal/2 ))
    local lsp rsp; printf -v lsp '%*s' "$lp" ''; printf -v rsp '%*s' "$rp" ''
    printf '%b║%b %s%b%s%b%s %b║%b\n' "$C2" "$NC" "$lsp" "$color" "$text" "$NC" "$rsp" "$C2" "$NC"
    anim_pause 0.02
}

open_anim() {
    [[ "$ANIM" == "1" ]] || return 0
    local bar=$(( ${TERM_COLS:-40} - 6 )) i fill empty
    (( bar > 40 )) && bar=40
    (( bar < 10 )) && bar=10
    echo ""
    echo -e " ${C4}${BOLD}Membuka: $1${NC}"
    for ((i = 0; i <= bar; i++)); do
        printf -v fill '%*s' "$i" ''; fill=${fill// /█}
        printf -v empty '%*s' "$((bar - i))" ''; empty=${empty// /░}
        printf '\r %b[%b%s%b%s%b]%b' "$C2" "$C1" "$fill" "$DIM" "$empty" "$C2" "$NC"
        sleep 0.008
    done
    printf '\r%*s\r' "$((bar + 6))" ''
}

log_msg() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

need_pkg() {
    # $1 = perintah, $2 = nama paket
    if ! command -v "$1" >/dev/null 2>&1; then
        echo -e "${YELLOW}Paket '$2' belum terpasang.${NC}"
        read -rp "Install sekarang? (y/n): " ans
        if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
            run_with_spinner "Menginstall $2..." pkg install -y "$2"
        else
            return 1
        fi
    fi
    return 0
}

show_category_list() {
    local w; w=$(box_w)
    local i n=1 count line total=0 lc
    box_div "$w" "MENU KATEGORI"
    for ((i = 0; i < ${#CAT_TITLES[@]}; i++)); do
        count="${CAT_COUNT[$i]}"
        total=$((total + count))
        printf -v line "%2d | %s %s (%d fitur)" "$n" "${CAT_ICONS[$i]}" "${CAT_TITLES[$i]}" "$count"
        local _tag="${CAT_ICONS[$i]//[\[\]]/}"
        lc="${CAT_COLOR_MAP[$_tag]:-$WHITE}"
        box_line "$w" "$line" "$lc"
        ((n++))
    done
    box_line "$w" "" ""
    printf -v line "%2d | [CARI] Cari Fitur" "$n"; box_line "$w" "$line" "$C4"; search_num=$n; ((n++))
    printf -v line "%2d | [EXIT] Keluar" "$n"; box_line "$w" "$line" "$C3"; exit_num=$n
    box_bottom "$w"
    printf ' %b%s | Azr Tools v%s | %d Fitur | Enjoy Bro!%b\n' "${DIM}${C5}" "$(date '+%d-%m-%Y')" "$VERSION" "$total" "$NC"
}

show_submenu() {
    local idx="$1"
    local items="${CAT_ITEMS[$idx]}"
    local w; w=$(box_w)
    local tag="${CAT_ICONS[$idx]//[\[\]]/}"
    local accent="${CAT_COLOR_MAP[$tag]:-$WHITE}"
    clear
    box_top "$w" "${CAT_ICONS[$idx]} ${CAT_TITLES[$idx]}"
    local n=1 line label lineout
    SUB_FUNCS=()
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        label="${line%%|*}"
        SUB_FUNCS+=("${line##*|}")
        printf -v lineout "%2d | %s" "$n" "$label"
        box_line "$w" "$lineout" "$accent"
        ((n++))
    done <<< "$items"
    box_line "$w" "" ""
    box_line "$w" " 0 | <- Kembali" "$C3"
    box_bottom "$w"
}

do_search() {
    local w; w=$(box_w)
    clear
    box_top "$w" "CARI FITUR"
    box_line "$w" "Ketik kata kunci fitur yang kamu cari" "$WHITE"
    box_bottom "$w"
    read -rp "$(echo -e "${C5}${BOLD}➜ Kata kunci: ${NC}")" kw
    [[ -z "$kw" ]] && return
    local i line label func results_label=() results_func=()
    for ((i = 0; i < ${#CAT_TITLES[@]}; i++)); do
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            label="${line%%|*}"; func="${line##*|}"
            if [[ "${label,,}" == *"${kw,,}"* ]]; then
                results_label+=("$label"); results_func+=("$func")
            fi
        done <<< "${CAT_ITEMS[$i]}"
    done
    clear
    if (( ${#results_label[@]} == 0 )); then
        box_top "$w" "CARI FITUR"
        box_line "$w" "Tidak ada fitur yang cocok dengan \"$kw\"." "$YELLOW"
        box_bottom "$w"
        pause
        return
    fi
    box_top "$w" "HASIL: $kw"
    local n lineout
    for ((n = 0; n < ${#results_label[@]}; n++)); do
        printf -v lineout "%2d | %s" "$((n+1))" "${results_label[$n]}"
        box_line "$w" "$lineout" "$WHITE"
    done
    box_line "$w" "" ""
    box_line "$w" " 0 | <- Batal" "$C3"
    box_bottom "$w"
    read -rp "$(echo -e ${C5}${BOLD}"➜ Jalankan nomor: "${NC})" pick
    if [[ "$pick" =~ ^[0-9]+$ ]] && (( pick >= 1 && pick <= ${#results_func[@]} )); then
        "${results_func[$((pick-1))]}"
    fi
}

# ---------- BANNER (adaptif lebar terminal, selalu center, anti pecah) ----------
center_text() {
    local text="$1" color="$2" width="$3"
    local pad=$(( (TERM_COLS - width) / 2 ))
    (( pad < 0 )) && pad=0
    local sp; printf -v sp '%*s' "$pad" ''
    printf "%b%s%s%b\n" "$color" "$sp" "$text" "$NC"
}

banner() {
    clear
    TERM_COLS=$(tput cols 2>/dev/null); TERM_COLS=${TERM_COLS:-${COLUMNS:-40}}
    local w; w=$(box_w)

    box_top "$w" ""

    if (( TERM_COLS >= 49 )); then
        local big_lines=(
            ' █████╗ ███████╗██████╗ '
            '██╔══██╗╚══███╔╝██╔══██╗'
            '███████║  ███╔╝ ██████╔╝'
            '██╔══██║ ███╔╝  ██╔══██╗'
            '██║  ██║███████╗██║  ██║'
            '╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝'
            ''
            '████████╗ ██████╗  ██████╗ ██╗     ███████╗'
            '╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝'
            '   ██║   ██║   ██║██║   ██║██║     ███████╗'
            '   ██║   ██║   ██║██║   ██║██║     ╚════██║'
            '   ██║   ╚██████╔╝╚██████╔╝███████╗███████║'
            '   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝'
        )
        local big_cols=(
            "$C1" "$C1" "$C2" "$C2" "$C3" "$C3" "$NC"
            "$C3" "$C3" "$C4" "$C4" "$C2" "$C2"
        )
        local big_w=(24 24 24 24 24 24 0 43 43 43 43 43 43)
        local li
        for li in "${!big_lines[@]}"; do
            frame_art_line "$w" "${big_lines[$li]}" "${big_cols[$li]}" "${big_w[$li]}"
        done
    elif (( TERM_COLS >= 30 )); then
        local med_lines=('▄▀█ ▀█ █▀█' '█▀█ █▄ █▀▄' '' 'T O O L S')
        local med_cols=("$C1" "$C2" "$NC" "$C4")
        local med_w=(10 10 0 9)
        local li
        for li in "${!med_lines[@]}"; do
            frame_art_line "$w" "${med_lines[$li]}" "${med_cols[$li]}" "${med_w[$li]}"
        done
    else
        frame_art_line "$w" "AZR TOOLS" "${C1}${BOLD}" 9
    fi

    local tips=(
        "Ketik nomor kategori, 0 = kembali."
        "Lupa fitur ada di mana? Pakai Cari Fitur."
        "Log aktivitas ada di ~/.azrtools/azrtools.log"
        "Backup Home rutin biar data tetap aman."
        "Fitur Termux:API butuh app Termux:API."
        "Kategori Premium: daftar dulu, baru login."
        "Animasi menu bisa dimatikan di Utilitas Lain."
    )
    local tip="${tips[$((RANDOM % ${#tips[@]}))]}"
    local total=0 ci
    for ci in "${CAT_COUNT[@]}"; do total=$((total + ci)); done

    box_div "$w" ""
    box_line "$w" "Author : Zidan"      "$WHITE"
    box_line "$w" "Versi  : v${VERSION}"    "$WHITE"
    box_line "$w" "Fitur  : ${total}+"  "$WHITE"
    box_line "$w" "Waktu  : $(date '+%d-%m-%Y %H:%M')" "$WHITE"

    box_div_thin "$w" ""
    box_line "$w" "Device : $(getprop ro.product.model 2>/dev/null || echo 'Termux')" "$C4"
    box_line "$w" "User   : $(whoami 2>/dev/null)" "$C4"

    box_div_thin "$w" "TIPS"
    box_line "$w" "$tip" "$WHITE"
}

# ================= FUNGSI-FUNGSI (jumlah dihitung otomatis di menu) =================

f_system_info() {
    echo -e "${C4}${BOLD}INFORMASI SISTEM${NC}"; hr
    echo -e "${WHITE}Device   :${NC} $(getprop ro.product.model 2>/dev/null || echo 'N/A')"
    echo -e "${WHITE}Android  :${NC} $(getprop ro.build.version.release 2>/dev/null || echo 'N/A')"
    echo -e "${WHITE}Arch     :${NC} $(uname -m)"
    echo -e "${WHITE}Kernel   :${NC} $(uname -r)"
    echo -e "${WHITE}Termux   :${NC} $(pkg --version 2>/dev/null | head -1)"
    echo -e "${WHITE}Shell    :${NC} $SHELL"
    hr
    echo -e "${C5}${BOLD}RAM:${NC}"; free -h 2>/dev/null | sed 's/^/  /'
    echo -e "${C5}${BOLD}Storage:${NC}"; df -h "$HOME" 2>/dev/null | sed 's/^/  /'
    pause
}

f_update_upgrade() {
    echo -e "${C4}${BOLD}UPDATE & UPGRADE${NC}"; hr
    run_with_spinner "Update daftar paket..." pkg update -y
    run_with_spinner "Upgrade paket terpasang..." pkg upgrade -y
    echo -e "${GREEN}Selesai!${NC}"
    pause
}

f_install_essentials() {
    echo -e "${C4}${BOLD}INSTALL PAKET ESENSIAL${NC}"; hr
    pkgs=(git curl wget python nodejs vim openssh unzip zip)
    for p in "${pkgs[@]}"; do
        run_with_spinner "Install $p..." pkg install -y "$p"
    done
    echo -e "${GREEN}Semua paket esensial siap.${NC}"
    pause
}

f_setup_storage() {
    echo -e "${C4}${BOLD}SETUP STORAGE${NC}"; hr
    termux-setup-storage
    echo -e "${GREEN}Cek popup izin di layar HP kamu.${NC}"
    pause
}

f_network_info() {
    echo -e "${C4}${BOLD}INFO JARINGAN${NC}"; hr
    echo -e "${WHITE}IP Lokal:${NC}"
    ip addr show 2>/dev/null | grep -E "inet " | sed 's/^/  /'
    echo -e "${WHITE}IP Publik:${NC}"
    curl -s ifconfig.me && echo ""
    pause
}

f_speedtest() {
    echo -e "${C4}${BOLD}SPEED TEST${NC}"; hr
    if need_pkg speedtest-cli speedtest-cli; then
        speedtest-cli --simple
    fi
    pause
}

f_battery() {
    echo -e "${C4}${BOLD}STATUS BATERAI${NC}"; hr
    if command -v termux-battery-status >/dev/null 2>&1; then
        termux-battery-status
    else
        echo -e "${YELLOW}Butuh Termux:API (pkg install termux-api + app Termux:API dari Play Store/F-Droid).${NC}"
    fi
    pause
}

f_clean_cache() {
    echo -e "${C4}${BOLD}BERSIHKAN CACHE${NC}"; hr
    run_with_spinner "Membersihkan cache apt..." pkg clean
    echo -e "${GREEN}Cache dibersihkan.${NC}"
    pause
}

f_backup_home() {
    echo -e "${C4}${BOLD}BACKUP HOME${NC}"; hr
    fname="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar czf "$BACKUP_DIR/$fname" -C "$HOME" --exclude='.azrtools' . 2>/dev/null &
    spinner $! "Membuat backup..."
    wait
    echo -e "${GREEN}Backup tersimpan di: $BACKUP_DIR/$fname${NC}"
    pause
}

f_restore_backup() {
    echo -e "${C4}${BOLD}RESTORE BACKUP${NC}"; hr
    ls "$BACKUP_DIR" 2>/dev/null
    read -rp "Masukkan nama file backup: " bf
    if [[ -f "$BACKUP_DIR/$bf" ]]; then
        tar xzf "$BACKUP_DIR/$bf" -C "$HOME"
        echo -e "${GREEN}Restore selesai.${NC}"
    else
        echo -e "${RED}File tidak ditemukan.${NC}"
    fi
    pause
}

f_file_browser() {
    echo -e "${C4}${BOLD}FILE BROWSER${NC}"; hr
    dir="${1:-$HOME}"
    while true; do
        clear
        echo -e "${C4}${BOLD}Direktori: $dir${NC}"; hr
        ls -la --color=auto "$dir" 2>/dev/null | sed 's/^/  /'
        hr
        echo -e "${WHITE}[masuk:nama] [k:kembali] [q:keluar]${NC}"
        read -rp "> " cmd
        case "$cmd" in
            q) break ;;
            k) dir=$(dirname "$dir") ;;
            masuk:*) sub="${cmd#masuk:}"; [[ -d "$dir/$sub" ]] && dir="$dir/$sub" ;;
            *) echo "Perintah tidak dikenal"; sleep 1 ;;
        esac
    done
}

f_search_file() {
    echo -e "${C4}${BOLD}CARI FILE${NC}"; hr
    read -rp "Nama file yang dicari (boleh sebagian): " q
    echo -e "${YELLOW}Mencari di $HOME ...${NC}"
    find "$HOME" -iname "*$q*" 2>/dev/null | sed 's/^/  /'
    pause
}

f_compress_extract() {
    echo -e "${C4}${BOLD}KOMPRES / EKSTRAK${NC}"; hr
    echo "1) Kompres folder ke .zip"
    echo "2) Ekstrak file .zip"
    echo "3) Kompres ke .tar.gz"
    echo "4) Ekstrak .tar.gz"
    read -rp "Pilih: " op
    case "$op" in
        1) read -rp "Folder sumber: " s; read -rp "Nama output.zip: " o
           need_pkg zip zip && zip -r "$o" "$s" ;;
        2) read -rp "File .zip: " s; need_pkg unzip unzip && unzip "$s" ;;
        3) read -rp "Folder sumber: " s; read -rp "Nama output.tar.gz: " o
           tar czf "$o" "$s" ;;
        4) read -rp "File .tar.gz: " s; tar xzf "$s" ;;
        *) echo "Pilihan tidak valid" ;;
    esac
    pause
}

f_theme() {
    echo -e "${C4}${BOLD}GANTI TEMA WARNA TERMUX${NC}"; hr
    echo "Termux menyimpan tema di ~/.termux/colors.properties dan font.ttf"
    echo "1) Set skema Cyan Terang (Azr Tools default)"
    echo "2) Buka folder .termux untuk edit manual"
    read -rp "Pilih: " op
    mkdir -p "$HOME/.termux"
    if [[ "$op" == "1" ]]; then
        cat > "$HOME/.termux/colors.properties" << 'EOF'
background=#001014
foreground=#d0faff
cursor=#22d3ee
color0=#001014
color1=#ff5e78
color2=#39e5c5
color3=#ffd166
color4=#2dd4ff
color5=#38bdf8
color6=#22d3ee
color7=#d0faff
EOF
        termux-reload-settings 2>/dev/null
        echo -e "${GREEN}Tema Cyan Terang diterapkan! Restart Termux untuk melihat perubahan penuh.${NC}"
    else
        echo "Edit manual file: $HOME/.termux/colors.properties"
    fi
    pause
}

f_clone_repo() {
    echo -e "${C4}${BOLD}CLONE REPO GITHUB${NC}"; hr
    need_pkg git git
    read -rp "URL repo: " url
    git clone "$url"
    pause
}

f_python_venv() {
    echo -e "${C4}${BOLD}BUAT VIRTUALENV PYTHON${NC}"; hr
    need_pkg python python
    read -rp "Nama folder venv: " vn
    python -m venv "$vn"
    echo -e "${GREEN}Venv dibuat. Aktifkan dengan: source $vn/bin/activate${NC}"
    pause
}

f_node_project() {
    echo -e "${C4}${BOLD}INIT PROJECT NODE.JS${NC}"; hr
    need_pkg npm nodejs
    read -rp "Nama folder project: " pn
    mkdir -p "$pn" && cd "$pn" || return
    npm init -y >/dev/null 2>&1
    echo -e "${GREEN}Project Node.js dibuat di ./$pn${NC}"
    cd .. || return
    pause
}

f_password_gen() {
    echo -e "${C4}${BOLD}GENERATOR PASSWORD${NC}"; hr
    read -rp "Panjang password (default 16): " len
    len=${len:-16}
    pw=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c "$len")
    echo -e "${GREEN}${BOLD}Password: ${WHITE}$pw${NC}"
    pause
}

f_qr_gen() {
    echo -e "${C4}${BOLD}GENERATOR QR CODE${NC}"; hr
    if need_pkg qrencode qrencode; then
        read -rp "Teks/URL untuk QR: " txt
        qrencode -t ANSIUTF8 "$txt"
    fi
    pause
}

f_termux_api_menu() {
    while true; do
        clear
        echo -e "${C4}${BOLD}TERMUX:API MENU${NC}"; hr
        echo "1) Getar HP (vibrate)"
        echo "2) Kirim notifikasi"
        echo "3) Lihat clipboard"
        echo "4) Set clipboard"
        echo "5) Nyalakan/matikan flash"
        echo "6) Kembali"
        read -rp "Pilih: " op
        case "$op" in
            1) termux-vibrate -d 500 ;;
            2) read -rp "Isi notifikasi: " n; termux-notification -t "Azr Tools" -c "$n" ;;
            3) termux-clipboard-get ;;
            4) read -rp "Teks untuk clipboard: " c; echo "$c" | termux-clipboard-set ;;
            5) read -rp "on/off: " f; termux-torch "$f" ;;
            6) break ;;
            *) echo "Pilihan tidak valid" ;;
        esac
        [[ "$op" != "6" ]] && pause
    done
}

f_weather() {
    echo -e "${C4}${BOLD}CEK CUACA${NC}"; hr
    read -rp "Nama kota: " kota
    curl -s "wttr.in/${kota// /+}?lang=id"
    pause
}

f_ip_lookup() {
    echo -e "${C4}${BOLD}IP LOOKUP${NC}"; hr
    read -rp "Masukkan IP (kosongkan untuk IP sendiri): " ip
    curl -s "http://ip-api.com/json/$ip?lang=id" | sed 's/,/,\n/g'
    pause
}

f_port_check() {
    echo -e "${C4}${BOLD}CEK PORT${NC}"; hr
    read -rp "Host (contoh: google.com): " host
    read -rp "Port (contoh: 443): " port
    if timeout 3 bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null; then
        echo -e "${GREEN}Port $port di $host TERBUKA${NC}"
    else
        echo -e "${RED}Port $port di $host TERTUTUP / tidak terjangkau${NC}"
    fi
    pause
}

f_motd() {
    echo -e "${C4}${BOLD}EDIT MOTD (PESAN SAAT TERMUX DIBUKA)${NC}"; hr
    read -rp "Isi pesan MOTD baru: " msg
    echo "$msg" > "$HOME/../usr/etc/motd" 2>/dev/null || echo "$msg" > "$HOME/.motd"
    echo -e "${GREEN}MOTD diperbarui (jika berhasil ditulis).${NC}"
    pause
}

f_wakelock() {
    echo -e "${C4}${BOLD}WAKE LOCK (CEGAH TERMUX TERTIDUR)${NC}"; hr
    echo "1) Aktifkan wake-lock"
    echo "2) Matikan wake-lock"
    read -rp "Pilih: " op
    [[ "$op" == "1" ]] && termux-wake-lock && echo -e "${GREEN}Wake-lock aktif.${NC}"
    [[ "$op" == "2" ]] && termux-wake-unlock && echo -e "${GREEN}Wake-lock nonaktif.${NC}"
    pause
}

f_view_log() {
    echo -e "${C4}${BOLD}LIHAT LOG AZR TOOLS${NC}"; hr
    tail -n 40 "$LOG_FILE" 2>/dev/null | sed 's/^/  /'
    pause
}

f_wifi_scan() {
    echo -e "${C4}${BOLD}SCAN WIFI SEKITAR${NC}"; hr
    if command -v termux-wifi-scaninfo >/dev/null 2>&1; then
        termux-wifi-scaninfo | sed 's/,/,\n/g'
    else
        echo -e "${YELLOW}Butuh Termux:API (pkg install termux-api + app Termux:API + izin lokasi aktif).${NC}"
    fi
    pause
}

f_wifi_info() {
    echo -e "${C4}${BOLD}INFO KONEKSI WIFI SAAT INI${NC}"; hr
    if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then
        termux-wifi-connectioninfo | sed 's/,/,\n/g'
    else
        echo -e "${YELLOW}Butuh Termux:API terpasang.${NC}"
    fi
    pause
}

f_location() {
    echo -e "${C4}${BOLD}LOKASI GPS${NC}"; hr
    if command -v termux-location >/dev/null 2>&1; then
        echo -e "${YELLOW}Mengambil lokasi (pastikan GPS aktif)...${NC}"
        termux-location -p gps -r once | sed 's/,/,\n/g'
    else
        echo -e "${YELLOW}Butuh Termux:API terpasang.${NC}"
    fi
    pause
}

f_camera_photo() {
    echo -e "${C4}${BOLD}AMBIL FOTO KAMERA${NC}"; hr
    if command -v termux-camera-photo >/dev/null 2>&1; then
        read -rp "Nama file output (contoh: foto.jpg): " fn
        fn="${fn:-foto.jpg}"
        termux-camera-photo -c 0 "$fn" && echo -e "${GREEN}Foto tersimpan: $fn${NC}"
    else
        echo -e "${YELLOW}Butuh Termux:API terpasang.${NC}"
    fi
    pause
}

f_tts() {
    echo -e "${C4}${BOLD}TEXT TO SPEECH${NC}"; hr
    if command -v termux-tts-speak >/dev/null 2>&1; then
        read -rp "Teks yang mau diucapkan: " txt
        termux-tts-speak "$txt"
    else
        echo -e "${YELLOW}Butuh Termux:API terpasang.${NC}"
    fi
    pause
}

f_volume() {
    echo -e "${C4}${BOLD}KONTROL VOLUME${NC}"; hr
    if command -v termux-volume >/dev/null 2>&1; then
        echo -e "${WHITE}Status volume saat ini:${NC}"
        termux-volume | sed 's/,/,\n/g'
        echo ""
        read -rp "Stream (music/notification/ring/alarm), kosongkan untuk lewati: " stream
        if [[ -n "$stream" ]]; then
            read -rp "Level volume: " lvl
            termux-volume "$stream" "$lvl"
        fi
    else
        echo -e "${YELLOW}Butuh Termux:API terpasang.${NC}"
    fi
    pause
}

f_dialog() {
    echo -e "${C4}${BOLD}DIALOG INPUT INTERAKTIF${NC}"; hr
    if command -v termux-dialog >/dev/null 2>&1; then
        read -rp "Judul dialog: " judul
        hasil=$(termux-dialog text -t "$judul")
        echo -e "${WHITE}Hasil input:${NC} $hasil"
    else
        echo -e "${YELLOW}Butuh Termux:API terpasang.${NC}"
    fi
    pause
}

f_sensor_list() {
    echo -e "${C4}${BOLD}INFO SENSOR HP${NC}"; hr
    if command -v termux-sensor >/dev/null 2>&1; then
        termux-sensor -l
    else
        echo -e "${YELLOW}Butuh Termux:API terpasang.${NC}"
    fi
    pause
}

f_ssh_setup() {
    echo -e "${C4}${BOLD}SETUP SSH SERVER${NC}"; hr
    need_pkg sshd openssh
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        mkdir -p "$HOME/.ssh"
        ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
    fi
    sshd
    echo -e "${GREEN}SSH server jalan di port 8022.${NC}"
    echo -e "${WHITE}User:${NC} $(whoami)"
    echo -e "${WHITE}IP lokal:${NC} $(ip addr show 2>/dev/null | grep -oE 'inet [0-9.]+' | grep -v '127.0.0.1' | head -1 | cut -d' ' -f2)"
    echo -e "${WHITE}Contoh koneksi:${NC} ssh -p 8022 $(whoami)@<ip-diatas>"
    pause
}

f_disk_usage() {
    echo -e "${C4}${BOLD}ANALISIS PENGGUNAAN DISK${NC}"; hr
    echo -e "${WHITE}Folder terbesar di \$HOME:${NC}"
    du -h --max-depth=1 "$HOME" 2>/dev/null | sort -rh | head -15 | sed 's/^/  /'
    pause
}

f_process_manager() {
    echo -e "${C4}${BOLD}PROCESS MANAGER${NC}"; hr
    ps -A 2>/dev/null | sed 's/^/  /' | head -30
    echo ""
    read -rp "Masukkan PID untuk kill (kosongkan untuk lewati): " pid
    if [[ -n "$pid" ]]; then
        kill -9 "$pid" 2>/dev/null && echo -e "${GREEN}Proses $pid dihentikan.${NC}" || echo -e "${RED}Gagal menghentikan proses.${NC}"
    fi
    pause
}

f_dns_lookup() {
    echo -e "${C4}${BOLD}DNS LOOKUP${NC}"; hr
    read -rp "Domain (contoh: google.com): " domain
    if command -v host >/dev/null 2>&1; then
        host "$domain"
    elif need_pkg host dnsutils; then
        host "$domain"
    fi
    pause
}

f_ping() {
    echo -e "${C4}${BOLD}PING HOST${NC}"; hr
    read -rp "Host/IP: " h
    read -rp "Jumlah paket (default 4): " c; c=${c:-4}
    ping -c "$c" "$h"
    pause
}

f_calculator() {
    echo -e "${C4}${BOLD}KALKULATOR${NC}"; hr
    echo -e "${WHITE}Contoh: 5*3+2, (10/2)-1, sqrt(16)${NC}"
    read -rp "Ekspresi: " expr
    if command -v bc >/dev/null 2>&1; then
        result=$(echo "$expr" | bc -l 2>/dev/null)
        echo -e "${GREEN}Hasil: $result${NC}"
    else
        echo -e "${YELLOW}Menggunakan python...${NC}"
        python3 -c "from math import *; print($expr)" 2>/dev/null || echo -e "${RED}Ekspresi tidak valid.${NC}"
    fi
    pause
}

f_unit_convert() {
    echo -e "${C4}${BOLD}KONVERSI SATUAN${NC}"; hr
    echo "1) Celsius -> Fahrenheit"
    echo "2) Fahrenheit -> Celsius"
    echo "3) KM -> Mil"
    echo "4) Mil -> KM"
    echo "5) KG -> Lbs"
    echo "6) Lbs -> KG"
    read -rp "Pilih: " op
    read -rp "Nilai: " v
    case "$op" in
        1) awk -v v="$v" 'BEGIN{printf "%.2f F\n", v*9/5+32}' ;;
        2) awk -v v="$v" 'BEGIN{printf "%.2f C\n", (v-32)*5/9}' ;;
        3) awk -v v="$v" 'BEGIN{printf "%.2f mil\n", v*0.621371}' ;;
        4) awk -v v="$v" 'BEGIN{printf "%.2f km\n", v/0.621371}' ;;
        5) awk -v v="$v" 'BEGIN{printf "%.2f lbs\n", v*2.20462}' ;;
        6) awk -v v="$v" 'BEGIN{printf "%.2f kg\n", v/2.20462}' ;;
        *) echo -e "${RED}Pilihan tidak valid${NC}" ;;
    esac
    pause
}

f_notes() {
    local notefile="$BASE_DIR/notes.txt"
    echo -e "${C4}${BOLD}CATATAN CEPAT${NC}"; hr
    echo "1) Tambah catatan"
    echo "2) Lihat semua catatan"
    echo "3) Hapus semua catatan"
    read -rp "Pilih: " op
    case "$op" in
        1) read -rp "Isi catatan: " nt; echo "[$(date '+%Y-%m-%d %H:%M')] $nt" >> "$notefile"; echo -e "${GREEN}Tersimpan.${NC}" ;;
        2) [[ -f "$notefile" ]] && cat -n "$notefile" || echo "Belum ada catatan." ;;
        3) rm -f "$notefile"; echo -e "${GREEN}Semua catatan dihapus.${NC}" ;;
        *) echo -e "${RED}Pilihan tidak valid${NC}" ;;
    esac
    pause
}

f_todo() {
    local todofile="$BASE_DIR/todo.txt"
    touch "$todofile"
    echo -e "${C4}${BOLD}TO-DO LIST${NC}"; hr
    echo "1) Tambah tugas"
    echo "2) Lihat daftar tugas"
    echo "3) Tandai selesai (hapus dari daftar)"
    read -rp "Pilih: " op
    case "$op" in
        1) read -rp "Tugas baru: " t; echo "[ ] $t" >> "$todofile"; echo -e "${GREEN}Ditambahkan.${NC}" ;;
        2) cat -n "$todofile" 2>/dev/null ;;
        3) cat -n "$todofile"; read -rp "Nomor baris yang selesai: " ln
           sed -i "${ln}d" "$todofile" 2>/dev/null && echo -e "${GREEN}Selesai & dihapus dari daftar.${NC}" ;;
        *) echo -e "${RED}Pilihan tidak valid${NC}" ;;
    esac
    pause
}

f_base64() {
    echo -e "${C4}${BOLD}BASE64 ENCODE / DECODE${NC}"; hr
    echo "1) Encode teks"
    echo "2) Decode teks"
    read -rp "Pilih: " op
    read -rp "Teks: " t
    case "$op" in
        1) echo -n "$t" | base64 ;;
        2) echo -n "$t" | base64 -d 2>/dev/null || echo -e "${RED}Format base64 tidak valid.${NC}" ;;
        *) echo -e "${RED}Pilihan tidak valid${NC}" ;;
    esac
    pause
}

f_hash_gen() {
    echo -e "${C4}${BOLD}HASH GENERATOR${NC}"; hr
    echo "1) Hash dari teks"
    echo "2) Hash dari file"
    read -rp "Pilih: " op
    if [[ "$op" == "1" ]]; then
        read -rp "Teks: " t
        echo -e "${WHITE}MD5   :${NC} $(echo -n "$t" | md5sum | cut -d' ' -f1)"
        echo -e "${WHITE}SHA256:${NC} $(echo -n "$t" | sha256sum | cut -d' ' -f1)"
    elif [[ "$op" == "2" ]]; then
        read -rp "Path file: " f
        if [[ -f "$f" ]]; then
            echo -e "${WHITE}MD5   :${NC} $(md5sum "$f" | cut -d' ' -f1)"
            echo -e "${WHITE}SHA256:${NC} $(sha256sum "$f" | cut -d' ' -f1)"
        else
            echo -e "${RED}File tidak ditemukan.${NC}"
        fi
    fi
    pause
}

f_sim_info() {
    echo -e "${C4}${BOLD}INFO SIM & SINYAL${NC}"; hr
    if command -v termux-telephony-deviceinfo >/dev/null 2>&1; then
        termux-telephony-deviceinfo | sed 's/,/,\n/g'
    else
        echo -e "${YELLOW}Butuh Termux:API terpasang.${NC}"
    fi
    pause
}

f_calendar() {
    echo -e "${C4}${BOLD}KALENDER BULAN INI${NC}"; hr
    cal
    pause
}

f_timer_stopwatch() {
    echo -e "${C4}${BOLD}TIMER / STOPWATCH${NC}"; hr
    echo "1) Timer mundur (countdown)"
    echo "2) Stopwatch (tekan ENTER untuk berhenti)"
    read -rp "Pilih: " op
    if [[ "$op" == "1" ]]; then
        read -rp "Durasi (detik): " d
        for ((t=d; t>=0; t--)); do
            printf "\r${C4}⏳ Sisa waktu: %02d:%02d ${NC}" $((t/60)) $((t%60))
            sleep 1
        done
        echo -e "\n${GREEN}Waktu habis!${NC}"
        termux-vibrate -d 800 2>/dev/null
    else
        echo -e "${YELLOW}Stopwatch dimulai, tekan ENTER untuk berhenti...${NC}"
        st=$(date +%s)
        read -rs -N1
        et=$(date +%s)
        echo -e "${GREEN}Waktu berlalu: $((et-st)) detik${NC}"
    fi
    pause
}

f_pkg_manage() {
    echo -e "${C4}${BOLD}LIST & UNINSTALL PAKET${NC}"; hr
    echo -e "${WHITE}Paket terinstall:${NC}"
    pkg list-installed 2>/dev/null | sed 's/^/  /'
    echo ""
    read -rp "Nama paket untuk uninstall (kosongkan untuk lewati): " pkgname
    if [[ -n "$pkgname" ]]; then
        run_with_spinner "Uninstall $pkgname..." pkg uninstall -y "$pkgname"
    fi
    pause
}

f_stats() {
    echo -e "${C4}${BOLD}STATISTIK PEMAKAIAN AZR TOOLS${NC}"; hr
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${WHITE}Total aksi tercatat:${NC} $(grep -c 'Menu dipilih' "$LOG_FILE" 2>/dev/null)"
        echo -e "${WHITE}5 aksi terakhir:${NC}"
        grep 'Menu dipilih' "$LOG_FILE" | tail -5 | sed 's/^/  /'
    else
        echo "Belum ada data statistik."
    fi
    pause
}

display_paged() {
    # $1 = path file teks, $2 = jumlah baris per halaman (default 18)
    local file="$1" per="${2:-18}"
    local total; total=$(wc -l < "$file" 2>/dev/null); total="${total:-0}"
    local start=1 k
    while (( start <= total )); do
        sed -n "${start},$((start + per - 1))p" "$file"
        start=$((start + per))
        if (( start <= total )); then
            read -rp "$(echo -e "${DIM}${WHITE}-- lanjut: ENTER, berhenti: q --${NC} ")" k
            [[ "$k" == "q" || "$k" == "Q" ]] && break
        fi
    done
}

f_view_changelog() {
    echo -e "${C4}${BOLD}RIWAYAT VERSI (CHANGELOG)${NC}"; hr
    echo -e "${WHITE}Versi terpasang saat ini:${NC} v${VERSION}"
    hr
    local cache="$BASE_DIR/CHANGELOG.md"
    if command -v curl >/dev/null 2>&1; then
        local tmp; tmp=$(mktemp "$BASE_DIR/chg.XXXXXX")
        ( curl -s --max-time 15 -o "$tmp" "$UPDATE_RAW_BASE/CHANGELOG.md" ) &
        local pid=$!
        spinner "$pid" "Mengambil changelog dari GitHub..."
        wait "$pid"
        if [[ -s "$tmp" ]]; then
            cp "$tmp" "$cache"
        fi
        rm -f "$tmp"
    fi
    if [[ -s "$cache" ]]; then
        display_paged "$cache" 18
    else
        echo -e "${YELLOW}Belum ada changelog tersimpan dan gagal ambil dari GitHub.${NC}"
        echo -e "${DIM}Cek koneksi internet, atau pastikan repo/branch di UPDATE_USER sudah benar.${NC}"
    fi
    pause
}

ver_gt() {
    # true kalau $1 > $2 (perbandingan versi semver-ish pakai sort -V)
    [[ "$1" == "$2" ]] && return 1
    [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)" == "$1" ]]
}

f_self_update() {
    echo -e "${C4}${BOLD}CEK UPDATE AZR TOOLS${NC}"; hr
    echo -e "${WHITE}Versi saat ini :${NC} v${VERSION}"
    echo -e "${WHITE}Sumber update  :${NC} github.com/${UPDATE_USER}/${UPDATE_REPO} (${UPDATE_BRANCH})"
    need_pkg curl curl || { pause; return; }

    local tmp_ver; tmp_ver=$(mktemp "$BASE_DIR/ver.XXXXXX")
    ( curl -s --max-time 20 -o "$tmp_ver" "$UPDATE_RAW_BASE/VERSION" ) &
    local pid=$!
    spinner "$pid" "Mengecek versi terbaru di GitHub..."
    wait "$pid"
    local remote_ver; remote_ver=$(tr -d ' \t\r\n' < "$tmp_ver" 2>/dev/null)
    rm -f "$tmp_ver"

    if [[ -z "$remote_ver" ]]; then
        echo -e "${RED}Gagal mengambil info versi dari GitHub.${NC}"
        echo -e "${DIM}Cek koneksi internet, atau pastikan UPDATE_USER/UPDATE_REPO di awal script sudah benar dan repo publik.${NC}"
        pause; return
    fi

    echo -e "${WHITE}Versi di GitHub:${NC} v${remote_ver}"
    echo ""

    if ! ver_gt "$remote_ver" "$VERSION"; then
        echo -e "${GREEN}Azr Tools kamu sudah versi terbaru.${NC}"
        pause; return
    fi

    echo -e "${YELLOW}${BOLD}Update tersedia: v${VERSION} -> v${remote_ver}${NC}"
    echo ""

    local tmp_log; tmp_log=$(mktemp "$BASE_DIR/log.XXXXXX")
    curl -s --max-time 20 -o "$tmp_log" "$UPDATE_RAW_BASE/CHANGELOG.md" 2>/dev/null
    if [[ -s "$tmp_log" ]]; then
        echo -e "${C4}${BOLD}Catatan perubahan v${remote_ver}:${NC}"
        awk -v v="$remote_ver" '
            $0 ~ "^## v" v {found=1; next}
            found && /^## v/ {exit}
            found {print}
        ' "$tmp_log" | sed '/^[[:space:]]*$/d' | sed 's/^/  /'
    else
        echo -e "${DIM}(CHANGELOG.md tidak ditemukan di repo, lanjut tanpa catatan perubahan)${NC}"
    fi
    rm -f "$tmp_log"

    echo ""
    read -rp "Update sekarang? (y/n): " go
    if [[ "$go" != "y" && "$go" != "Y" ]]; then
        echo "Dibatalkan."; pause; return
    fi

    local tmp_sh; tmp_sh=$(mktemp "$BASE_DIR/new.XXXXXX")
    ( curl -sL --max-time 30 -o "$tmp_sh" "$UPDATE_RAW_BASE/azrtools.sh" ) &
    pid=$!
    spinner "$pid" "Mengunduh versi baru..."
    wait "$pid"

    if [[ ! -s "$tmp_sh" ]] || ! bash -n "$tmp_sh" 2>/dev/null; then
        echo -e "${RED}File hasil unduhan tidak valid, update dibatalkan.${NC}"
        rm -f "$tmp_sh"; pause; return
    fi

    local self_path; self_path=$(realpath "$0" 2>/dev/null || echo "$0")
    local backup="$BASE_DIR/backup_v${VERSION}_$(date +%Y%m%d_%H%M%S).sh"
    cp "$self_path" "$backup" 2>/dev/null
    cp "$tmp_sh" "$self_path" && chmod +x "$self_path"
    rm -f "$tmp_sh"

    echo -e "${GREEN}${BOLD}Berhasil update ke v${remote_ver}!${NC}"
    echo -e "${DIM}Backup versi lama: $backup${NC}"
    log_msg "Update otomatis: v${VERSION} -> v${remote_ver}"
    echo ""
    read -rp "Restart Azr Tools sekarang buat pakai versi baru? (y/n): " rs
    if [[ "$rs" == "y" || "$rs" == "Y" ]]; then
        exec bash "$self_path"
    fi
    pause
}

f_android_info() {
    echo -e "${C4}${BOLD}INFO ANDROID & ROOT${NC}"; hr
    echo -e "${WHITE}Versi Android :${NC} $(getprop ro.build.version.release 2>/dev/null)"
    echo -e "${WHITE}Patch Keamanan:${NC} $(getprop ro.build.version.security_patch 2>/dev/null)"
    echo -e "${WHITE}Manufacturer  :${NC} $(getprop ro.product.manufacturer 2>/dev/null)"
    echo -e "${WHITE}Build ID      :${NC} $(getprop ro.build.id 2>/dev/null)"
    if command -v su >/dev/null 2>&1; then
        echo -e "${WHITE}Root          :${NC} ${GREEN}Terdeteksi (su ada)${NC}"
    else
        echo -e "${WHITE}Root          :${NC} ${YELLOW}Tidak terdeteksi${NC}"
    fi
    pause
}

f_case_convert() {
    echo -e "${C4}${BOLD}TEXT CASE CONVERTER${NC}"; hr
    read -rp "Teks: " t
    echo "1) UPPERCASE"
    echo "2) lowercase"
    echo "3) Title Case"
    read -rp "Pilih: " op
    case "$op" in
        1) echo "${t^^}" ;;
        2) echo "${t,,}" ;;
        3) echo "$t" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}' ;;
        *) echo -e "${RED}Pilihan tidak valid${NC}" ;;
    esac
    pause
}

f_word_counter() {
    echo -e "${C4}${BOLD}WORD & CHARACTER COUNTER${NC}"; hr
    read -rp "Teks: " t
    echo -e "${WHITE}Jumlah kata :${NC} $(echo -n "$t" | wc -w)"
    echo -e "${WHITE}Jumlah huruf:${NC} $(echo -n "$t" | wc -m)"
    pause
}

f_quote() {
    echo -e "${C4}${BOLD}QUOTE MOTIVASI${NC}"; hr
    local quotes=(
        "Konsisten kecil setiap hari ngalahin usaha besar sesekali."
        "Kode yang jalan hari ini lebih baik dari kode sempurna besok."
        "Error itu petunjuk, bukan penghalang."
        "Bug hari ini adalah pelajaran besok."
        "Selesai itu lebih baik dari sempurna."
        "Rehat sebentar, lanjut lagi lebih kuat."
    )
    echo -e "${WHITE}\"${quotes[$((RANDOM % ${#quotes[@]}))]}\"${NC}"
    pause
}

f_currency() {
    echo -e "${C4}${BOLD}KURS MATA UANG${NC}"; hr
    read -rp "Dari kode mata uang (contoh: USD): " from
    read -rp "Ke kode mata uang (contoh: IDR): " to
    from="${from^^}"; to="${to^^}"
    if command -v curl >/dev/null 2>&1; then
        result=$(curl -s "https://api.exchangerate-api.com/v4/latest/$from" 2>/dev/null)
        rate=$(echo "$result" | grep -o "\"$to\":[0-9.]*" | cut -d':' -f2)
        if [[ -n "$rate" ]]; then
            echo -e "${GREEN}1 $from = $rate $to${NC}"
        else
            echo -e "${RED}Gagal ambil data kurs (cek koneksi/kode mata uang).${NC}"
        fi
    fi
    pause
}

f_shorten_url() {
    echo -e "${C4}${BOLD}SHORTEN URL${NC}"; hr
    read -rp "URL panjang: " url
    if command -v curl >/dev/null 2>&1; then
        short=$(curl -s "https://tinyurl.com/api-create.php?url=$url")
        [[ -n "$short" ]] && echo -e "${GREEN}$short${NC}" || echo -e "${RED}Gagal memendekkan URL.${NC}"
    fi
    pause
}

f_countdown_date() {
    echo -e "${C4}${BOLD}COUNTDOWN HARI PENTING${NC}"; hr
    read -rp "Tanggal target (YYYY-MM-DD): " target
    target_s=$(date -d "$target" +%s 2>/dev/null)
    now_s=$(date +%s)
    if [[ -z "$target_s" ]]; then
        echo -e "${RED}Format tanggal tidak valid.${NC}"
    else
        diff=$(( (target_s - now_s) / 86400 ))
        if (( diff >= 0 )); then
            echo -e "${GREEN}Tinggal $diff hari lagi menuju $target${NC}"
        else
            echo -e "${YELLOW}Tanggal $target sudah lewat $(( -diff )) hari yang lalu${NC}"
        fi
    fi
    pause
}

f_dummy_data() {
    echo -e "${C4}${BOLD}GENERATE DATA DUMMY${NC}"; hr
    local names=("Andi" "Budi" "Citra" "Dewi" "Eka" "Fajar" "Gita" "Hadi")
    local nm="${names[$((RANDOM % ${#names[@]}))]}$((RANDOM % 90 + 10))"
    echo -e "${WHITE}Nama :${NC} $nm"
    echo -e "${WHITE}Email:${NC} ${nm,,}@mail.com"
    echo -e "${WHITE}HP   :${NC} 08$(( RANDOM % 900000000 + 100000000 ))"
    pause
}

f_screen_info() {
    echo -e "${C4}${BOLD}RESOLUSI & KEPADATAN LAYAR${NC}"; hr
    if command -v termux-info >/dev/null 2>&1; then
        wm_size=$(dumpsys window displays 2>/dev/null | grep -m1 "cur=" )
        [[ -n "$wm_size" ]] && echo -e "${WHITE}$wm_size${NC}" || echo -e "${YELLOW}Info tidak tersedia di device ini.${NC}"
    else
        echo -e "${YELLOW}Tidak dapat mengakses info layar.${NC}"
    fi
    pause
}

f_ascii_art() {
    echo -e "${C4}${BOLD}ASCII ART TEXT${NC}"; hr
    read -rp "Teks: " t
    if need_pkg figlet figlet; then
        figlet "$t"
    fi
    pause
}

f_backup_termux_config() {
    echo -e "${C4}${BOLD}BACKUP KONFIGURASI TERMUX${NC}"; hr
    fname="termux_config_$(date +%Y%m%d_%H%M%S).tar.gz"
    if [[ -d "$HOME/.termux" ]]; then
        tar czf "$BACKUP_DIR/$fname" -C "$HOME" .termux
        echo -e "${GREEN}Konfigurasi tersimpan: $BACKUP_DIR/$fname${NC}"
    else
        echo -e "${YELLOW}Folder .termux tidak ditemukan.${NC}"
    fi
    pause
}

f_hash_compare() {
    echo -e "${C4}${BOLD}BANDINGKAN HASH 2 FILE${NC}"; hr
    read -rp "File pertama: " f1
    read -rp "File kedua: " f2
    if [[ -f "$f1" && -f "$f2" ]]; then
        h1=$(sha256sum "$f1" | cut -d' ' -f1)
        h2=$(sha256sum "$f2" | cut -d' ' -f1)
        echo -e "${WHITE}Hash 1:${NC} $h1"
        echo -e "${WHITE}Hash 2:${NC} $h2"
        if [[ "$h1" == "$h2" ]]; then
            echo -e "${GREEN}IDENTIK - kedua file sama persis.${NC}"
        else
            echo -e "${RED}BERBEDA - isi kedua file tidak sama.${NC}"
        fi
    else
        echo -e "${RED}Salah satu file tidak ditemukan.${NC}"
    fi
    pause
}

f_image_convert() {
    echo -e "${C4}${BOLD}CONVERT & RESIZE GAMBAR${NC}"; hr
    if need_pkg convert imagemagick; then
        read -rp "Path file gambar sumber: " src
        if [[ -f "$src" ]]; then
            read -rp "Lebar baru (px, kosongkan = tidak diubah): " w
            read -rp "Format output (jpg/png/webp, default jpg): " fmt; fmt="${fmt:-jpg}"
            out="${src%.*}_konversi.${fmt}"
            if [[ -n "$w" ]]; then
                convert "$src" -resize "${w}x" "$out"
            else
                convert "$src" "$out"
            fi
            echo -e "${GREEN}Tersimpan: $out${NC}"
        else
            echo -e "${RED}File tidak ditemukan.${NC}"
        fi
    fi
    pause
}

f_text_diff() {
    echo -e "${C4}${BOLD}BANDINGKAN TEKS (DIFF)${NC}"; hr
    read -rp "File pertama: " f1
    read -rp "File kedua: " f2
    if [[ -f "$f1" && -f "$f2" ]]; then
        diff --color=always -u "$f1" "$f2" || echo -e "${YELLOW}(tidak ada perbedaan jika kosong di atas)${NC}"
    else
        echo -e "${RED}Salah satu file tidak ditemukan.${NC}"
    fi
    pause
}

f_wifi_qr() {
    echo -e "${C4}${BOLD}GENERATE QR WIFI${NC}"; hr
    read -rp "Nama WiFi (SSID): " ssid
    read -rsp "Password WiFi: " pass; echo ""
    read -rp "Jenis keamanan (WPA/WEP/nopass, default WPA): " sec; sec="${sec:-WPA}"
    if need_pkg qrencode qrencode; then
        qrencode -t ANSIUTF8 "WIFI:T:${sec};S:${ssid};P:${pass};;"
        echo -e "${GREEN}Scan QR di atas pakai kamera HP lain buat konek otomatis.${NC}"
    fi
    pause
}

f_password_strength() {
    echo -e "${C4}${BOLD}CEK KEKUATAN PASSWORD${NC}"; hr
    read -rsp "Masukkan password (tidak ditampilkan): " pw; echo ""
    local len=${#pw} score=0
    (( len >= 8 )) && ((score++))
    (( len >= 12 )) && ((score++))
    [[ "$pw" =~ [A-Z] ]] && ((score++))
    [[ "$pw" =~ [a-z] ]] && ((score++))
    [[ "$pw" =~ [0-9] ]] && ((score++))
    [[ "$pw" =~ [^a-zA-Z0-9] ]] && ((score++))
    echo -e "${WHITE}Panjang:${NC} $len karakter"
    case $score in
        0|1|2) echo -e "${RED}Lemah - tambah panjang & variasi karakter.${NC}" ;;
        3|4)   echo -e "${YELLOW}Sedang - lumayan, bisa lebih kuat lagi.${NC}" ;;
        5|6)   echo -e "${GREEN}Kuat - password bagus!${NC}" ;;
    esac
    pause
}

f_disk_free_all() {
    echo -e "${C4}${BOLD}RUANG KOSONG SEMUA PARTISI${NC}"; hr
    df -h 2>/dev/null | sed 's/^/  /'
    pause
}

f_uptime() {
    echo -e "${C4}${BOLD}UPTIME SISTEM${NC}"; hr
    if command -v uptime >/dev/null 2>&1; then
        uptime -p 2>/dev/null || uptime
    else
        echo -e "${YELLOW}Perintah uptime tidak tersedia.${NC}"
    fi
    pause
}

f_reminder_once() {
    echo -e "${C4}${BOLD}REMINDER SEKALI${NC}"; hr
    read -rp "Pesan reminder: " msg
    read -rp "Dalam berapa menit lagi?: " mnt
    if [[ "$mnt" =~ ^[0-9]+$ ]]; then
        (sleep "$((mnt*60))" && termux-notification -t "Azr Tools Reminder" -c "$msg" 2>/dev/null) &
        disown
        echo -e "${GREEN}Reminder diset, notifikasi akan muncul dalam $mnt menit.${NC}"
        echo -e "${YELLOW}Catatan: Termux harus tetap berjalan di background (pakai Wake Lock).${NC}"
    else
        echo -e "${RED}Input tidak valid.${NC}"
    fi
    pause
}

f_storage_benchmark() {
    echo -e "${C4}${BOLD}BENCHMARK KECEPATAN STORAGE${NC}"; hr
    echo -e "${YELLOW}Menulis file uji 50MB ke $HOME...${NC}"
    local testfile="$HOME/.azrtools/speedtest.tmp"
    local start end
    start=$(date +%s.%N)
    dd if=/dev/zero of="$testfile" bs=1M count=50 2>/dev/null
    end=$(date +%s.%N)
    write_speed=$(awk -v s="$start" -v e="$end" 'BEGIN{printf "%.1f", 50/(e-s)}')
    start=$(date +%s.%N)
    dd if="$testfile" of=/dev/null bs=1M 2>/dev/null
    end=$(date +%s.%N)
    read_speed=$(awk -v s="$start" -v e="$end" 'BEGIN{printf "%.1f", 50/(e-s)}')
    rm -f "$testfile"
    echo -e "${WHITE}Kecepatan tulis:${NC} ${write_speed} MB/s"
    echo -e "${WHITE}Kecepatan baca :${NC} ${read_speed} MB/s"
    pause
}

f_json_pretty() {
    echo -e "${C4}${BOLD}FORMAT & VALIDASI JSON${NC}"; hr
    read -rp "Path file JSON: " f
    if [[ -f "$f" ]]; then
        if command -v python3 >/dev/null 2>&1; then
            python3 -m json.tool "$f" 2>&1 || echo -e "${RED}JSON tidak valid.${NC}"
        else
            cat "$f"
        fi
    else
        echo -e "${RED}File tidak ditemukan.${NC}"
    fi
    pause
}

f_extract_audio() {
    echo -e "${C4}${BOLD}EXTRACT AUDIO DARI VIDEO${NC}"; hr
    if need_pkg ffmpeg ffmpeg; then
        read -rp "Path file video: " src
        if [[ -f "$src" ]]; then
            out="${src%.*}.mp3"
            ffmpeg -y -i "$src" -q:a 0 -map a "$out" -loglevel error
            echo -e "${GREEN}Audio tersimpan: $out${NC}"
        else
            echo -e "${RED}File tidak ditemukan.${NC}"
        fi
    fi
    pause
}

f_image_compress() {
    echo -e "${C4}${BOLD}KOMPRES UKURAN GAMBAR${NC}"; hr
    if need_pkg convert imagemagick; then
        read -rp "Path file gambar: " src
        if [[ -f "$src" ]]; then
            read -rp "Kualitas (1-100, default 60): " q; q="${q:-60}"
            out="${src%.*}_kompres.jpg"
            convert "$src" -quality "$q" "$out"
            echo -e "${GREEN}Tersimpan: $out${NC}"
            echo -e "${WHITE}Ukuran asli :${NC} $(du -h "$src" | cut -f1)"
            echo -e "${WHITE}Ukuran baru :${NC} $(du -h "$out" | cut -f1)"
        else
            echo -e "${RED}File tidak ditemukan.${NC}"
        fi
    fi
    pause
}

f_morse_code() {
    echo -e "${C4}${BOLD}TEXT TO MORSE CODE${NC}"; hr
    read -rp "Teks: " t
    declare -A morse=( [a]=".-" [b]="-..." [c]="-.-." [d]="-.." [e]="." [f]="..-." [g]="--." [h]="...." [i]=".." [j]=".---" [k]="-.-" [l]=".-.." [m]="--" [n]="-." [o]="---" [p]=".--." [q]="--.-" [r]=".-." [s]="..." [t]="-" [u]="..-" [v]="...-" [w]=".--" [x]="-..-" [y]="-.--" [z]="--.." [0]="-----" [1]=".----" [2]="..---" [3]="...--" [4]="....-" [5]="....." [6]="-...." [7]="--..." [8]="---.." [9]="----." )
    local out="" i c
    for ((i=0; i<${#t}; i++)); do
        c="${t:$i:1}"; c="${c,,}"
        if [[ "$c" == " " ]]; then out+="   "
        else out+="${morse[$c]:-?} "
        fi
    done
    echo -e "${GREEN}$out${NC}"
    pause
}

f_uuid_gen() {
    echo -e "${C4}${BOLD}GENERATE UUID${NC}"; hr
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen
    else
        python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null || cat /proc/sys/kernel/random/uuid
    fi
    pause
}

f_file_split_join() {
    echo -e "${C4}${BOLD}FILE SPLITTER & JOINER${NC}"; hr
    echo "1) Pecah file jadi beberapa bagian"
    echo "2) Gabung kembali file yang sudah dipecah"
    read -rp "Pilih: " op
    if [[ "$op" == "1" ]]; then
        read -rp "Path file: " f
        read -rp "Ukuran per bagian (mis: 10M, 500K): " sz
        if [[ -f "$f" ]]; then
            split -b "$sz" "$f" "${f}.part_"
            echo -e "${GREEN}Selesai dipecah, cek file ${f}.part_*${NC}"
        else
            echo -e "${RED}File tidak ditemukan.${NC}"
        fi
    elif [[ "$op" == "2" ]]; then
        read -rp "Prefix bagian (mis: video.mp4.part_): " pfx
        read -rp "Nama file output hasil gabungan: " out
        cat ${pfx}* > "$out" 2>/dev/null && echo -e "${GREEN}Digabung jadi: $out${NC}" || echo -e "${RED}Gagal, cek nama prefix.${NC}"
    fi
    pause
}

f_file_type() {
    echo -e "${C4}${BOLD}CEK FORMAT / JENIS FILE${NC}"; hr
    read -rp "Path file: " f
    if [[ -f "$f" ]]; then
        if command -v file >/dev/null 2>&1; then
            file "$f"
        else
            echo -e "${WHITE}Ekstensi:${NC} .${f##*.}"
        fi
        echo -e "${WHITE}Ukuran   :${NC} $(du -h "$f" | cut -f1)"
    else
        echo -e "${RED}File tidak ditemukan.${NC}"
    fi
    pause
}

f_encrypt_file() {
    echo -e "${C4}${BOLD}ENCRYPT / DECRYPT FILE${NC}"; hr
    echo "1) Enkripsi file (pakai password)"
    echo "2) Dekripsi file"
    read -rp "Pilih: " op
    read -rp "Path file: " f
    if [[ ! -f "$f" ]]; then echo -e "${RED}File tidak ditemukan.${NC}"; pause; return; fi
    read -rsp "Password: " pw; echo ""
    if [[ "$op" == "1" ]]; then
        openssl enc -aes-256-cbc -salt -pbkdf2 -in "$f" -out "${f}.enc" -pass pass:"$pw" 2>/dev/null \
            && echo -e "${GREEN}Terenkripsi: ${f}.enc${NC}" || echo -e "${RED}Gagal enkripsi.${NC}"
    elif [[ "$op" == "2" ]]; then
        out="${f%.enc}"
        openssl enc -aes-256-cbc -d -pbkdf2 -in "$f" -out "$out" -pass pass:"$pw" 2>/dev/null \
            && echo -e "${GREEN}Terdekripsi: $out${NC}" || echo -e "${RED}Gagal dekripsi (password salah?).${NC}"
    fi
    pause
}

f_random_number() {
    echo -e "${C4}${BOLD}RANDOM NUMBER GENERATOR${NC}"; hr
    read -rp "Angka minimum: " lo
    read -rp "Angka maksimum: " hi
    if [[ "$lo" =~ ^-?[0-9]+$ && "$hi" =~ ^-?[0-9]+$ ]] && (( hi >= lo )); then
        echo -e "${GREEN}Hasil: $(( RANDOM % (hi - lo + 1) + lo ))${NC}"
    else
        echo -e "${RED}Input tidak valid.${NC}"
    fi
    pause
}

f_installed_apps() {
    echo -e "${C4}${BOLD}CEK APLIKASI TERINSTALL${NC}"; hr
    if command -v pm >/dev/null 2>&1; then
        read -rp "Filter nama paket (kosongkan = semua): " kw
        if [[ -n "$kw" ]]; then
            pm list packages | grep -i "$kw"
        else
            pm list packages | head -40
            echo -e "${YELLOW}(menampilkan 40 pertama, gunakan filter buat cari spesifik)${NC}"
        fi
    else
        echo -e "${YELLOW}Perintah pm tidak tersedia.${NC}"
    fi
    pause
}

f_open_app() {
    echo -e "${C4}${BOLD}BUKA APLIKASI LAIN${NC}"; hr
    read -rp "Nama package (mis: com.whatsapp): " pkg
    if command -v monkey >/dev/null 2>&1; then
        monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 \
            && echo -e "${GREEN}Membuka $pkg...${NC}" \
            || echo -e "${RED}Gagal, pastikan nama package benar.${NC}"
    else
        echo -e "${YELLOW}Perintah monkey tidak tersedia di device ini.${NC}"
    fi
    pause
}

# ================= PREMIUM: ALIGHT MOTION =================

prem_mask_key() {
    local k="$PREM_KEY"
    if (( ${#k} > 8 )); then echo "${k:0:4}****${k: -3}"; else echo "****"; fi
}

prem_valid_email() {
    [[ "$1" =~ ^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$ ]]
}

prem_last_email() {
    [[ -f "$PREM_HISTORY" ]] && awk -F' \\| ' '{print $3}' "$PREM_HISTORY" | tail -1
}

prem_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1 | $2 | HTTP $3" >> "$PREM_HISTORY"
}

prem_wait_anim() {
    local pid="$1" msg="$2" i=0
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local cols=("$C1" "$C4" "$C2" "$C4")
    while kill -0 "$pid" 2>/dev/null; do
        printf '\r %b%s%b %s   ' "${cols[$((i % 4))]}" "${frames[$((i % 10))]}" "$NC" "$msg"
        sleep 0.08
        ((i++))
    done
    printf '\r%*s\r' 60 ''
}

prem_request() {
    need_pkg curl curl || return 1
    PREM_BODY=""; PREM_CODE=""
    local tmp; tmp=$(mktemp "$BASE_DIR/prem.XXXXXX") || return 1
    ( curl -sG --max-time 45 -o "$tmp" -w '%{http_code}' "$PREM_ENDPOINT" \
        --data-urlencode "key=$PREM_KEY" "$@" > "$tmp.code" 2>/dev/null ) &
    local pid=$!
    prem_wait_anim "$pid" "Menghubungi server premium"
    wait "$pid"
    PREM_CODE=$(cat "$tmp.code" 2>/dev/null); PREM_CODE="${PREM_CODE:-000}"
    PREM_BODY=$(cat "$tmp" 2>/dev/null)
    rm -f "$tmp" "$tmp.code"
    return 0
}

prem_show_result() {
    echo ""
    if [[ "$PREM_CODE" == "000" ]]; then
        echo -e "${RED}Gagal terhubung ke server (cek internet atau endpoint).${NC}"
    else
        local col="$YELLOW"; [[ "$PREM_CODE" == 2* ]] && col="$GREEN"
        echo -e "${WHITE}Status HTTP :${NC} ${col}${PREM_CODE}${NC}"
        echo -e "${C4}${BOLD}Respons server:${NC}"
        if command -v python3 >/dev/null 2>&1 && echo "$PREM_BODY" | python3 -m json.tool >/dev/null 2>&1; then
            echo "$PREM_BODY" | python3 -m json.tool | sed 's/^/  /'
        else
            echo "$PREM_BODY" | head -c 1500 | sed 's/^/  /'
            echo ""
        fi
    fi
    prem_log "$1" "$2" "$PREM_CODE"
}

prem_do_register() {
    local email="$1"
    prem_request --data-urlencode "action=register" --data-urlencode "email=$email" || return 1
    prem_show_result "register" "$email"
}

prem_do_login() {
    local email="$1" link="$2"
    prem_request --data-urlencode "action=login" --data-urlencode "email=$email" --data-urlencode "link=$link" || return 1
    prem_show_result "login" "$email"
}

prem_ask_email() {
    local last; last=$(prem_last_email)
    local email
    if [[ -n "$last" ]]; then
        read -rp "Email Alight Motion [$last]: " email
        email="${email:-$last}"
    else
        read -rp "Email Alight Motion: " email
    fi
    PREM_EMAIL="$email"
    prem_valid_email "$email"
}

prem_ask_link() {
    local link
    read -rp "Link login (ketik p = tempel dari clipboard): " link
    if [[ "$link" == "p" || "$link" == "P" ]]; then
        if command -v termux-clipboard-get >/dev/null 2>&1; then
            link=$(termux-clipboard-get 2>/dev/null)
            echo -e "${WHITE}Terambil:${NC} ${link:0:60}"
        else
            echo -e "${YELLOW}Clipboard butuh Termux:API terpasang.${NC}"
            link=""
        fi
    fi
    PREM_LINK="$link"
    [[ "$link" == https://* ]]
}

f_prem_register() {
    echo -e "${YELLOW}${BOLD}PREMIUM - DAFTAR AKUN${NC}"; hr
    if ! prem_ask_email; then echo -e "${RED}Format email tidak valid.${NC}"; pause; return; fi
    prem_do_register "$PREM_EMAIL"
    pause
}

f_prem_login() {
    echo -e "${YELLOW}${BOLD}PREMIUM - LOGIN AKUN${NC}"; hr
    if ! prem_ask_email; then echo -e "${RED}Format email tidak valid.${NC}"; pause; return; fi
    if ! prem_ask_link; then echo -e "${RED}Link harus diawali https://${NC}"; pause; return; fi
    prem_do_login "$PREM_EMAIL" "$PREM_LINK"
    pause
}

f_prem_flow() {
    echo -e "${YELLOW}${BOLD}PREMIUM - DAFTAR + LOGIN (PANDU)${NC}"; hr
    echo -e "${WHITE}Langkah 1/2: daftar email${NC}"
    if ! prem_ask_email; then echo -e "${RED}Format email tidak valid.${NC}"; pause; return; fi
    local email="$PREM_EMAIL"
    prem_do_register "$email" || { pause; return; }
    echo ""
    echo -e "${WHITE}Langkah 2/2: login${NC}"
    read -rp "Lanjut login sekarang? (y/n): " go
    if [[ "$go" == "y" || "$go" == "Y" ]]; then
        if prem_ask_link; then
            prem_do_login "$email" "$PREM_LINK"
        else
            echo -e "${RED}Link harus diawali https://${NC}"
        fi
    fi
    pause
}

f_prem_history() {
    echo -e "${YELLOW}${BOLD}PREMIUM - RIWAYAT AKTIVITAS${NC}"; hr
    if [[ -s "$PREM_HISTORY" ]]; then
        echo -e "${WHITE}Total aktivitas :${NC} $(wc -l < "$PREM_HISTORY")"
        echo -e "${WHITE}Daftar          :${NC} $(grep -c '| register |' "$PREM_HISTORY")"
        echo -e "${WHITE}Login           :${NC} $(grep -c '| login |' "$PREM_HISTORY")"
        echo ""
        echo -e "${C4}${BOLD}20 aktivitas terakhir:${NC}"
        tail -20 "$PREM_HISTORY" | sed 's/^/  /'
    else
        echo -e "${YELLOW}Belum ada riwayat.${NC}"
    fi
    pause
}

f_prem_ping() {
    echo -e "${YELLOW}${BOLD}PREMIUM - CEK KONEKSI SERVER${NC}"; hr
    need_pkg curl curl || { pause; return; }
    echo -e "${WHITE}Endpoint:${NC} $PREM_ENDPOINT"
    local res
    res=$(curl -s -o /dev/null --max-time 15 -w '%{http_code} %{time_total}' "$PREM_ENDPOINT" 2>/dev/null)
    if [[ -z "$res" || "${res%% *}" == "000" ]]; then
        echo -e "${RED}Server tidak terjangkau.${NC}"
    else
        echo -e "${GREEN}Server merespons${NC} - HTTP ${res%% *}, waktu ${res##* } detik"
    fi
    echo -e "${WHITE}API key aktif:${NC} $(prem_mask_key)"
    pause
}

f_prem_setkey() {
    echo -e "${YELLOW}${BOLD}PREMIUM - GANTI API KEY${NC}"; hr
    echo -e "${WHITE}Key saat ini:${NC} $(prem_mask_key)"
    echo -e "${DIM}Ketik key baru, atau 'reset' untuk kembali ke bawaan, kosong = batal.${NC}"
    local nk; read -rsp "Key baru: " nk; echo ""
    if [[ -z "$nk" ]]; then
        echo "Dibatalkan."
    elif [[ "$nk" == "reset" ]]; then
        rm -f "$PREM_CONF"; PREM_KEY="$PREM_KEY_DEFAULT"
        echo -e "${GREEN}Key dikembalikan ke bawaan.${NC}"
    else
        echo "KEY=$nk" > "$PREM_CONF"; chmod 600 "$PREM_CONF"
        PREM_KEY="$nk"
        echo -e "${GREEN}Key disimpan di $PREM_CONF${NC}"
    fi
    pause
}

f_prem_clear() {
    echo -e "${YELLOW}${BOLD}PREMIUM - HAPUS RIWAYAT${NC}"; hr
    read -rp "Hapus semua riwayat premium? (y/n): " a
    if [[ "$a" == "y" || "$a" == "Y" ]]; then
        rm -f "$PREM_HISTORY"; echo -e "${GREEN}Riwayat dihapus.${NC}"
    else
        echo "Dibatalkan."
    fi
    pause
}

f_prem_guide() {
    echo -e "${YELLOW}${BOLD}PREMIUM - PANDUAN MENU${NC}"; hr
    echo -e "${WHITE}1. Daftar Akun${NC}      isi email, kirim ke server"
    echo -e "${WHITE}2. Login Akun${NC}       isi email + link (https://...)"
    echo -e "${WHITE}3. Daftar + Login${NC}   dua langkah berurutan sekaligus"
    echo -e "${WHITE}4. Riwayat${NC}          catatan aktivitas (tanpa isi respons)"
    echo -e "${WHITE}5. Cek Koneksi${NC}      tes server & lihat key aktif"
    echo -e "${WHITE}6. Ganti API Key${NC}    simpan key sendiri di premium.conf"
    echo ""
    echo -e "${DIM}Tips: salin link dulu, lalu di kolom link ketik 'p' untuk menempel${NC}"
    echo -e "${DIM}otomatis dari clipboard (butuh Termux:API).${NC}"
    pause
}

# ================= FITUR TAMBAHAN =================

f_download_url() {
    echo -e "${C4}${BOLD}DOWNLOAD FILE DARI URL${NC}"; hr
    need_pkg curl curl || { pause; return; }
    read -rp "URL file (http/https): " url
    if [[ ! "$url" =~ ^https?:// ]]; then echo -e "${RED}URL harus diawali http:// atau https://${NC}"; pause; return; fi
    local dest="$HOME"; [[ -d "$HOME/storage/downloads" ]] && dest="$HOME/storage/downloads"
    local def="${url##*/}"; def="${def%%\?*}"; def="${def:-unduhan.bin}"
    read -rp "Nama file [$def]: " fn; fn="${fn:-$def}"
    curl -L --progress-bar -o "$dest/$fn" "$url" && echo -e "${GREEN}Tersimpan: $dest/$fn${NC}" || echo -e "${RED}Unduhan gagal.${NC}"
    pause
}

f_site_status() {
    echo -e "${C4}${BOLD}CEK STATUS WEBSITE${NC}"; hr
    need_pkg curl curl || { pause; return; }
    read -rp "Alamat website: " url
    [[ "$url" =~ ^https?:// ]] || url="https://$url"
    local res
    res=$(curl -sL -o /dev/null --max-time 15 -w '%{http_code} %{time_total} %{size_download}' "$url" 2>/dev/null)
    if [[ -z "$res" || "${res%% *}" == "000" ]]; then
        echo -e "${RED}Website tidak dapat dijangkau.${NC}"
    else
        set -- $res
        echo -e "${WHITE}Alamat :${NC} $url"
        echo -e "${WHITE}Status :${NC} HTTP $1"
        echo -e "${WHITE}Waktu  :${NC} $2 detik"
        echo -e "${WHITE}Ukuran :${NC} $3 byte"
    fi
    pause
}

f_file_share_server() {
    echo -e "${C4}${BOLD}WEB SERVER BERBAGI FILE (WiFi)${NC}"; hr
    need_pkg python3 python || { pause; return; }
    read -rp "Folder yang dibagikan [$HOME]: " dir; dir="${dir:-$HOME}"
    if [[ ! -d "$dir" ]]; then echo -e "${RED}Folder tidak ditemukan.${NC}"; pause; return; fi
    local port=8000
    local ip
    ip=$(ip -4 addr 2>/dev/null | grep -oE 'inet [0-9.]+' | cut -d' ' -f2 | grep -v '^127\.' | head -1)
    [[ -z "$ip" ]] && ip=$(ifconfig 2>/dev/null | grep -oE 'inet [0-9.]+' | cut -d' ' -f2 | grep -v '^127\.' | head -1)
    if [[ -n "$ip" ]]; then
        echo -e "${GREEN}Buka dari HP/PC lain (satu WiFi):${NC} http://$ip:$port"
        command -v qrencode >/dev/null 2>&1 && qrencode -t ANSIUTF8 "http://$ip:$port"
    else
        echo -e "${YELLOW}IP tidak terdeteksi, cek di menu Info Jaringan.${NC}"
    fi
    echo -e "${YELLOW}Tekan CTRL+C untuk menghentikan server.${NC}"
    trap ':' INT
    ( cd "$dir" && python3 -m http.server "$port" --bind 0.0.0.0 2>&1 )
    trap - INT
    echo ""
    echo -e "${GREEN}Server dihentikan.${NC}"
    pause
}

f_clipboard_manager() {
    echo -e "${C4}${BOLD}CLIPBOARD MANAGER${NC}"; hr
    if ! command -v termux-clipboard-get >/dev/null 2>&1; then
        echo -e "${YELLOW}Butuh Termux:API terpasang.${NC}"; pause; return
    fi
    echo "1) Lihat isi clipboard"
    echo "2) Salin teks ke clipboard"
    echo "3) Kosongkan clipboard"
    read -rp "Pilih: " op
    case "$op" in
        1) echo -e "${WHITE}Isi:${NC} $(termux-clipboard-get)" ;;
        2) read -rp "Teks: " t; printf '%s' "$t" | termux-clipboard-set; echo -e "${GREEN}Tersalin.${NC}" ;;
        3) printf '' | termux-clipboard-set; echo -e "${GREEN}Clipboard dikosongkan.${NC}" ;;
        *) echo -e "${RED}Pilihan tidak valid${NC}" ;;
    esac
    pause
}

f_snippets() {
    touch "$SNIPPET_FILE"
    echo -e "${C4}${BOLD}PERINTAH FAVORIT${NC}"; hr
    echo "1) Tambah perintah"
    echo "2) Lihat daftar"
    echo "3) Jalankan perintah"
    echo "4) Hapus perintah"
    read -rp "Pilih: " op
    case "$op" in
        1) read -rp "Nama singkat: " nm; read -rp "Perintah: " cm
           [[ -n "$nm" && -n "$cm" ]] && echo "$nm|$cm" >> "$SNIPPET_FILE" && echo -e "${GREEN}Tersimpan.${NC}" ;;
        2) [[ -s "$SNIPPET_FILE" ]] && awk -F'|' '{printf "  %d) %s  ->  %s\n", NR, $1, substr($0, length($1)+2)}' "$SNIPPET_FILE" || echo "Belum ada perintah." ;;
        3) awk -F'|' '{printf "  %d) %s\n", NR, $1}' "$SNIPPET_FILE"
           read -rp "Nomor yang dijalankan: " n
           if [[ "$n" =~ ^[0-9]+$ ]]; then
               cm=$(sed -n "${n}p" "$SNIPPET_FILE" | cut -d'|' -f2-)
               if [[ -n "$cm" ]]; then echo -e "${YELLOW}\$ $cm${NC}"; bash -c "$cm"; fi
           fi ;;
        4) awk -F'|' '{printf "  %d) %s\n", NR, $1}' "$SNIPPET_FILE"
           read -rp "Nomor yang dihapus: " n
           [[ "$n" =~ ^[0-9]+$ ]] && sed -i "${n}d" "$SNIPPET_FILE" && echo -e "${GREEN}Dihapus.${NC}" ;;
        *) echo -e "${RED}Pilihan tidak valid${NC}" ;;
    esac
    pause
}

f_outdated_pkgs() {
    echo -e "${C4}${BOLD}CEK PAKET BISA DIUPDATE${NC}"; hr
    run_with_spinner "Sinkronisasi daftar paket..." pkg update -y
    local out; out=$(apt list --upgradable 2>/dev/null | tail -n +2)
    if [[ -n "$out" ]]; then
        echo -e "${WHITE}Jumlah:${NC} $(echo "$out" | wc -l)"
        echo "$out" | head -30 | sed 's/^/  /'
    else
        echo -e "${GREEN}Semua paket sudah terbaru.${NC}"
    fi
    pause
}

f_toggle_anim() {
    echo -e "${C4}${BOLD}PENGATURAN ANIMASI MENU${NC}"; hr
    if [[ "$ANIM" == "1" ]]; then
        ANIM=0; echo "ANIM=0" > "$SETTINGS_FILE"
        echo -e "${YELLOW}Animasi menu: MATI${NC}"
    else
        ANIM=1; echo "ANIM=1" > "$SETTINGS_FILE"
        echo -e "${GREEN}Animasi menu: HIDUP${NC}"
    fi
    pause
}

# ================= HIBURAN & FUN =================

f_game_guess() {
    echo -e "${C4}${BOLD}TEBAK ANGKA${NC}"; hr
    local target=$((RANDOM % 100 + 1)) tries=0 guess maxtry=7
    echo -e "${WHITE}Aku pikirkan angka 1-100. Tebak dalam $maxtry kali.${NC}"
    while (( tries < maxtry )); do
        read -rp "Tebakan ke-$((tries+1)): " guess
        [[ "$guess" =~ ^[0-9]+$ ]] || { echo -e "${RED}Masukkan angka.${NC}"; continue; }
        ((tries++))
        if (( guess == target )); then
            echo -e "${GREEN}${BOLD}Benar! Angkanya $target (dalam $tries tebakan)${NC}"
            pause; return
        elif (( guess < target )); then
            echo -e "${YELLOW}Lebih besar dari itu...${NC}"
        else
            echo -e "${YELLOW}Lebih kecil dari itu...${NC}"
        fi
    done
    echo -e "${RED}Kesempatan habis! Angkanya adalah $target${NC}"
    pause
}

f_game_suit() {
    echo -e "${C4}${BOLD}SUIT - BATU GUNTING KERTAS${NC}"; hr
    local opts=("batu" "gunting" "kertas")
    read -rp "Pilih (batu/gunting/kertas): " you
    you="${you,,}"
    if [[ ! " ${opts[*]} " == *" $you "* ]]; then echo -e "${RED}Pilihan tidak valid.${NC}"; pause; return; fi
    local cpu="${opts[$((RANDOM % 3))]}"
    echo -e "${WHITE}Kamu:${NC} $you   ${WHITE}CPU:${NC} $cpu"
    if [[ "$you" == "$cpu" ]]; then
        echo -e "${YELLOW}Seri!${NC}"
    elif [[ "$you-$cpu" == "batu-gunting" || "$you-$cpu" == "gunting-kertas" || "$you-$cpu" == "kertas-batu" ]]; then
        echo -e "${GREEN}${BOLD}Kamu menang!${NC}"
    else
        echo -e "${RED}${BOLD}CPU menang!${NC}"
    fi
    pause
}

f_game_dice() {
    echo -e "${C4}${BOLD}LEMPAR DADU${NC}"; hr
    read -rp "Jumlah dadu (default 1): " n; n="${n:-1}"
    [[ "$n" =~ ^[0-9]+$ ]] || n=1
    echo -ne "${YELLOW}Mengocok"
    for _ in 1 2 3; do sleep 0.2; echo -ne "."; done
    echo -e "${NC}"
    local total=0 i r
    for ((i=1; i<=n; i++)); do
        r=$((RANDOM % 6 + 1)); total=$((total + r))
        echo -e "${WHITE}Dadu $i:${NC} ${GREEN}${BOLD}$r${NC}"
    done
    (( n > 1 )) && echo -e "${WHITE}Total:${NC} $total"
    pause
}

f_game_coin() {
    echo -e "${C4}${BOLD}LEMPAR KOIN${NC}"; hr
    echo -ne "${YELLOW}Melempar"
    for _ in 1 2 3; do sleep 0.2; echo -ne "."; done
    if (( RANDOM % 2 == 0 )); then
        echo -e "\n${GREEN}${BOLD}Hasilnya: ANGKA${NC}"
    else
        echo -e "\n${GREEN}${BOLD}Hasilnya: GAMBAR${NC}"
    fi
    pause
}

f_game_tictactoe() {
    echo -e "${C4}${BOLD}TIC TAC TOE VS CPU${NC}"; hr
    local b=(1 2 3 4 5 6 7 8 9)
    draw_board() {
        echo -e "${WHITE} ${b[0]} | ${b[1]} | ${b[2]}"
        echo    "-----------"
        echo    " ${b[3]} | ${b[4]} | ${b[5]}"
        echo    "-----------"
        echo -e " ${b[6]} | ${b[7]} | ${b[8]}${NC}"
    }
    check_win() {
        local p="$1"
        local w=(0,1,2 3,4,5 6,7,8 0,3,6 1,4,7 2,5,8 0,4,8 2,4,6)
        local combo a c d
        for combo in "${w[@]}"; do
            IFS=',' read -r a c d <<< "$combo"
            if [[ "${b[$a]}" == "$p" && "${b[$c]}" == "$p" && "${b[$d]}" == "$p" ]]; then return 0; fi
        done
        return 1
    }
    local turn=1 pos
    while true; do
        draw_board
        if (( turn % 2 == 1 )); then
            read -rp "Giliranmu (1-9): " pos
            [[ "$pos" =~ ^[1-9]$ ]] || { echo -e "${RED}Masukkan 1-9.${NC}"; continue; }
            if [[ "${b[$((pos-1))]}" == "X" || "${b[$((pos-1))]}" == "O" ]]; then
                echo -e "${RED}Sudah terisi.${NC}"; continue
            fi
            b[$((pos-1))]="X"
            check_win "X" && { draw_board; echo -e "${GREEN}${BOLD}Kamu menang!${NC}"; break; }
        else
            local empties=() k
            for k in "${!b[@]}"; do [[ "${b[$k]}" != "X" && "${b[$k]}" != "O" ]] && empties+=("$k"); done
            if (( ${#empties[@]} == 0 )); then echo -e "${YELLOW}Seri!${NC}"; break; fi
            b[${empties[$((RANDOM % ${#empties[@]}))]}]="O"
            check_win "O" && { draw_board; echo -e "${RED}${BOLD}CPU menang!${NC}"; break; }
        fi
        local full=1 k2
        for k2 in "${b[@]}"; do [[ "$k2" != "X" && "$k2" != "O" ]] && full=0; done
        (( full == 1 )) && { draw_board; echo -e "${YELLOW}Seri!${NC}"; break; }
        ((turn++))
    done
    pause
}

f_game_trivia() {
    echo -e "${C4}${BOLD}TRIVIA KUIS SINGKAT${NC}"; hr
    local qs=(
        "Ibu kota Indonesia?|jakarta"
        "Planet terdekat dari matahari?|merkurius"
        "Hasil dari 9 x 9?|81"
        "Bahasa pemrograman yang dibuat Guido van Rossum?|python"
        "Benua terbesar di dunia?|asia"
        "Perintah buat lihat isi folder di Linux?|ls"
    )
    local pick="${qs[$((RANDOM % ${#qs[@]}))]}"
    local q="${pick%%|*}" a="${pick##*|}"
    read -rp "$q  -> " ans
    if [[ "${ans,,}" == "${a,,}" ]]; then
        echo -e "${GREEN}${BOLD}Benar!${NC}"
    else
        echo -e "${RED}Salah, jawabannya: $a${NC}"
    fi
    pause
}

f_fortune_cookie() {
    echo -e "${C4}${BOLD}FORTUNE COOKIE${NC}"; hr
    local fortunes=(
        "Bug yang kamu kejar hari ini akan jadi cerita lucu besok."
        "Kopi habis bukan alasan berhenti ngoding."
        "Server down bukan kiamat, cuma butuh restart."
        "Hari ini cocok buat commit yang rapi."
        "Jangan lupa push sebelum HP mati."
        "Rejeki nomplok: fitur baru jalan tanpa error di percobaan pertama."
    )
    echo -e "${YELLOW}🥠 ${fortunes[$((RANDOM % ${#fortunes[@]}))]}${NC}"
    pause
}

f_typing_test() {
    echo -e "${C4}${BOLD}TES KECEPATAN MENGETIK${NC}"; hr
    local sentences=(
        "kecepatan bukan segalanya tapi ketepatan itu penting"
        "azr tools bikin termux jadi makin berguna"
        "koding santai sambil ngopi di malam hari"
        "latihan mengetik rutin bikin jari makin lincah"
    )
    local s="${sentences[$((RANDOM % ${#sentences[@]}))]}"
    echo -e "${WHITE}Ketik kalimat ini secepat mungkin:${NC}"
    echo -e "${YELLOW}$s${NC}"
    read -rp "> " typed
    local start end
    start=$SECONDS
    if [[ "$typed" == "$s" ]]; then
        local words=$(echo "$s" | wc -w)
        echo -e "${GREEN}${BOLD}Tepat!${NC} ${WHITE}($words kata)${NC}"
    else
        echo -e "${YELLOW}Ada yang beda dari teks aslinya, tapi tetap keren nyoba!${NC}"
    fi
    pause
}

# ================= TAMBAHAN SISTEM / JARINGAN / DEV =================

f_quick_monitor() {
    echo -e "${C4}${BOLD}MONITOR SISTEM CEPAT${NC}"; hr
    if command -v top >/dev/null 2>&1; then
        top -bn1 2>/dev/null | head -15
    else
        echo -e "${YELLOW}Perintah top tidak tersedia.${NC}"
    fi
    pause
}

f_top_processes() {
    echo -e "${C4}${BOLD}PROSES PALING BERAT (CPU)${NC}"; hr
    if ps -eo pid,pcpu,pmem,comm >/dev/null 2>&1; then
        ps -eo pid,pcpu,pmem,comm --sort=-pcpu 2>/dev/null | head -11
    else
        ps 2>/dev/null | head -15
    fi
    pause
}

f_whois_lookup() {
    echo -e "${C4}${BOLD}WHOIS DOMAIN${NC}"; hr
    read -rp "Nama domain (mis: google.com): " dom
    if need_pkg whois whois; then
        whois "$dom" 2>/dev/null | head -30
    fi
    pause
}

f_project_scaffold() {
    echo -e "${C4}${BOLD}BUAT STRUKTUR FOLDER PROJECT${NC}"; hr
    read -rp "Nama project: " pn
    [[ -z "$pn" ]] && { echo -e "${RED}Nama tidak boleh kosong.${NC}"; pause; return; }
    echo "1) Generic (src, docs, tests)"
    echo "2) Node.js (src, public, .gitignore)"
    echo "3) Python (src, tests, requirements.txt)"
    read -rp "Pilih tipe: " tp
    mkdir -p "$pn"
    case "$tp" in
        2) mkdir -p "$pn/src" "$pn/public"
           echo "node_modules/" > "$pn/.gitignore" ;;
        3) mkdir -p "$pn/src" "$pn/tests"
           touch "$pn/requirements.txt" ;;
        *) mkdir -p "$pn/src" "$pn/docs" "$pn/tests" ;;
    esac
    echo "# $pn" > "$pn/README.md"
    echo -e "${GREEN}Struktur project dibuat di ./$pn${NC}"
    find "$pn" | sed 's/^/  /'
    pause
}

f_duplicate_finder() {
    echo -e "${C4}${BOLD}FILE DUPLICATE FINDER${NC}"; hr
    read -rp "Folder yang dicek [$HOME]: " dir; dir="${dir:-$HOME}"
    if [[ ! -d "$dir" ]]; then echo -e "${RED}Folder tidak ditemukan.${NC}"; pause; return; fi
    echo -e "${YELLOW}Menghitung hash semua file, mohon tunggu...${NC}"
    local tmp; tmp=$(mktemp "$BASE_DIR/dup.XXXXXX")
    find "$dir" -type f -exec md5sum {} + 2>/dev/null | sort > "$tmp"
    local found=0 prevhash="" prevfile=""
    while IFS= read -r line; do
        local h="${line%% *}" f="${line#* }"
        if [[ "$h" == "$prevhash" ]]; then
            if (( found == 0 )); then echo -e "${YELLOW}${BOLD}Duplikat ditemukan:${NC}"; fi
            echo -e "  ${WHITE}$prevfile${NC}"
            echo -e "  ${WHITE}$f${NC}  ${DIM}(sama dengan di atas)${NC}"
            found=1
        fi
        prevhash="$h"; prevfile="$f"
    done < "$tmp"
    rm -f "$tmp"
    (( found == 0 )) && echo -e "${GREEN}Tidak ada file duplikat.${NC}"
    pause
}

f_cleanup_old_files() {
    echo -e "${C4}${BOLD}AUTO CLEANUP FILE LAMA${NC}"; hr
    read -rp "Folder target: " dir
    if [[ ! -d "$dir" ]]; then echo -e "${RED}Folder tidak ditemukan.${NC}"; pause; return; fi
    read -rp "Hapus file lebih tua dari berapa hari?: " days
    [[ "$days" =~ ^[0-9]+$ ]] || { echo -e "${RED}Input tidak valid.${NC}"; pause; return; }
    local list; list=$(find "$dir" -maxdepth 1 -type f -mtime +"$days" 2>/dev/null)
    if [[ -z "$list" ]]; then
        echo -e "${GREEN}Tidak ada file yang lebih tua dari $days hari.${NC}"
        pause; return
    fi
    echo -e "${WHITE}File yang akan dihapus:${NC}"
    echo "$list" | sed 's/^/  /'
    read -rp "Yakin hapus semua file di atas? (y/n): " a
    if [[ "$a" == "y" || "$a" == "Y" ]]; then
        echo "$list" | while IFS= read -r f; do rm -f "$f"; done
        echo -e "${GREEN}Selesai dihapus.${NC}"
    else
        echo "Dibatalkan."
    fi
    pause
}

f_caesar_cipher() {
    echo -e "${C4}${BOLD}CAESAR CIPHER / ROT13${NC}"; hr
    read -rp "Teks: " t
    read -rp "Geser berapa huruf (13 = ROT13): " s
    [[ "$s" =~ ^-?[0-9]+$ ]] || s=13
    if command -v python3 >/dev/null 2>&1; then
        local tmp; tmp=$(mktemp "$BASE_DIR/caesar.XXXXXX")
        printf '%s' "$t" > "$tmp"
        python3 -c "
import sys
s = int(sys.argv[2])
t = open(sys.argv[1], encoding='utf-8').read()
out = ''
for c in t:
    if c.isalpha():
        base = 65 if c.isupper() else 97
        out += chr((ord(c) - base + s) % 26 + base)
    else:
        out += c
print(out)
" "$tmp" "$s"
        rm -f "$tmp"
    else
        echo -e "${YELLOW}Butuh python3 buat fitur ini.${NC}"
    fi
    pause
}

f_json_to_csv() {
    echo -e "${C4}${BOLD}JSON <-> CSV CONVERTER${NC}"; hr
    echo "1) JSON ke CSV"
    echo "2) CSV ke JSON"
    read -rp "Pilih: " op
    read -rp "Path file input: " fin
    [[ -f "$fin" ]] || { echo -e "${RED}File tidak ditemukan.${NC}"; pause; return; }
    read -rp "Path file output: " fout
    if ! command -v python3 >/dev/null 2>&1; then echo -e "${YELLOW}Butuh python3.${NC}"; pause; return; fi
    if [[ "$op" == "1" ]]; then
        python3 -c "
import json, csv
data = json.load(open('$fin'))
if isinstance(data, dict): data=[data]
with open('$fout','w',newline='') as f:
    w = csv.DictWriter(f, fieldnames=list(data[0].keys()))
    w.writeheader()
    w.writerows(data)
" && echo -e "${GREEN}Tersimpan: $fout${NC}" || echo -e "${RED}Gagal konversi, cek format JSON.${NC}"
    elif [[ "$op" == "2" ]]; then
        python3 -c "
import json, csv
with open('$fin', newline='') as f:
    rows = list(csv.DictReader(f))
json.dump(rows, open('$fout','w'), indent=2, ensure_ascii=False)
" && echo -e "${GREEN}Tersimpan: $fout${NC}" || echo -e "${RED}Gagal konversi, cek format CSV.${NC}"
    fi
    pause
}

f_batch_rename() {
    echo -e "${C4}${BOLD}BATCH RENAME FILE${NC}"; hr
    read -rp "Folder: " dir
    [[ -d "$dir" ]] || { echo -e "${RED}Folder tidak ditemukan.${NC}"; pause; return; }
    read -rp "Prefix nama baru (mis: liburan): " prefix
    read -rp "Filter ekstensi (mis: jpg, kosongkan=semua): " ext
    local i=1 f pattern="$dir"/*
    [[ -n "$ext" ]] && pattern="$dir"/*."$ext"
    for f in $pattern; do
        [[ -f "$f" ]] || continue
        mv -- "$f" "$dir/${prefix}_$(printf '%03d' "$i").${f##*.}"
        ((i++))
    done
    echo -e "${GREEN}Selesai, $((i-1)) file diganti nama.${NC}"
    pause
}

f_lan_scan() {
    echo -e "${C4}${BOLD}SCAN PERANGKAT DI JARINGAN LOKAL${NC}"; hr
    local myip; myip=$(ip -4 addr show 2>/dev/null | grep -oE 'inet [0-9.]+' | grep -v '127\.' | head -1 | cut -d' ' -f2)
    if [[ -z "$myip" ]]; then echo -e "${RED}IP lokal tidak terdeteksi (cek WiFi aktif?).${NC}"; pause; return; fi
    local prefix="${myip%.*}"
    echo -e "${WHITE}IP kamu:${NC} $myip   ${WHITE}Subnet:${NC} ${prefix}.0/24"
    echo -e "${YELLOW}Memindai ${prefix}.1 - ${prefix}.254, tunggu sebentar...${NC}"
    local tmp; tmp=$(mktemp "$BASE_DIR/lan.XXXXXX")
    local i
    for i in $(seq 1 254); do
        ( ping -c1 -W1 "${prefix}.${i}" &>/dev/null && echo "${prefix}.${i}" >> "$tmp" ) &
        (( i % 40 == 0 )) && wait
    done
    wait
    if [[ -s "$tmp" ]]; then
        echo -e "${GREEN}${BOLD}Perangkat aktif ditemukan:${NC}"
        sort -t. -k4 -n "$tmp" | sed 's/^/  /'
    else
        echo -e "${YELLOW}Tidak ada perangkat lain yang terdeteksi.${NC}"
    fi
    rm -f "$tmp"
    pause
}

f_word_frequency() {
    echo -e "${C4}${BOLD}ANALISIS KATA TERBANYAK${NC}"; hr
    echo "1) Dari teks langsung"
    echo "2) Dari file"
    read -rp "Pilih: " op
    local src
    if [[ "$op" == "2" ]]; then
        read -rp "Path file: " f
        [[ -f "$f" ]] || { echo -e "${RED}File tidak ditemukan.${NC}"; pause; return; }
        src=$(cat "$f")
    else
        read -rp "Teks: " src
    fi
    echo -e "${WHITE}Top 10 kata terbanyak:${NC}"
    tr -cs 'A-Za-z0-9' '\n' <<< "$src" | tr 'A-Z' 'a-z' | grep -v '^$' | sort | uniq -c | sort -rn | head -10 | sed 's/^/  /'
    pause
}

f_qr_reader() {
    echo -e "${C4}${BOLD}BACA QR CODE DARI GAMBAR${NC}"; hr
    if need_pkg zbarimg zbar-tools; then
        read -rp "Path file gambar QR: " img
        if [[ -f "$img" ]]; then
            local hasil; hasil=$(zbarimg -q --raw "$img" 2>/dev/null)
            if [[ -n "$hasil" ]]; then
                echo -e "${GREEN}Isi QR:${NC} $hasil"
            else
                echo -e "${RED}Tidak terbaca, pastikan gambar jelas.${NC}"
            fi
        else
            echo -e "${RED}File tidak ditemukan.${NC}"
        fi
    fi
    pause
}

f_prayer_times() {
    echo -e "${C4}${BOLD}JADWAL SHOLAT${NC}"; hr
    need_pkg curl curl || { pause; return; }
    read -rp "Nama kota (mis: Jakarta): " kota
    local tmp; tmp=$(mktemp "$BASE_DIR/prayer.XXXXXX")
    curl -sG --max-time 15 -o "$tmp" \
        --data-urlencode "city=$kota" \
        --data-urlencode "country=Indonesia" \
        --data-urlencode "method=11" \
        "https://api.aladhan.com/v1/timingsByCity" 2>/dev/null
    if command -v python3 >/dev/null 2>&1 && [[ -s "$tmp" ]]; then
        python3 -c "
import json, sys
try:
    d = json.load(open(sys.argv[1], encoding='utf-8'))
    t = d['data']['timings']
    for k in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']:
        print(f'  {k:8s}: {t[k]}')
except Exception:
    print('  Gagal membaca data, cek nama kota.')
" "$tmp"
    else
        echo -e "${RED}Gagal ambil data jadwal sholat.${NC}"
    fi
    rm -f "$tmp"
    pause
}

f_crypto_price() {
    echo -e "${C4}${BOLD}CEK HARGA BITCOIN / CRYPTO${NC}"; hr
    need_pkg curl curl || { pause; return; }
    local tmp; tmp=$(mktemp "$BASE_DIR/crypto.XXXXXX")
    curl -s --max-time 15 -o "$tmp" \
        "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd,idr" 2>/dev/null
    if command -v python3 >/dev/null 2>&1 && [[ -s "$tmp" ]]; then
        python3 -c "
import json, sys
try:
    d = json.load(open(sys.argv[1], encoding='utf-8'))
    for coin, vals in d.items():
        print(f'  {coin.upper()}: \${vals[\"usd\"]:,}  |  Rp{vals[\"idr\"]:,}')
except Exception:
    print('  Gagal membaca data harga.')
" "$tmp"
    else
        echo -e "${RED}Gagal ambil data harga crypto.${NC}"
    fi
    rm -f "$tmp"
    pause
}

f_about() {
    clear
    echo -e "${C1}${BOLD}"
    typing "  ╔══════════════════════════════════╗" 0.005
    typing "  ║          AZR TOOLS v${VERSION}           ║" 0.005
    typing "  ╚══════════════════════════════════╝" 0.005
    echo -e "${NC}"
    echo -e "${C5}  Dibuat oleh: ${WHITE}Zidan${NC}"
    local _t=0 _x
    for _x in "${CAT_COUNT[@]}"; do _t=$((_t + _x)); done
    echo -e "${C5}  Toolkit Termux serbaguna dengan ${_t} fitur${NC}"
    echo -e "${C5}  Tema: Cyan Terang${NC}"
    pause
}

# ================= MENU UTAMA (kategori dulu, isi belakangan - hemat ruang) =================
main_menu() {
    # setiap baris: "CAT:ikon|Judul Kategori"  atau  "Label Menu|nama_fungsi"
    menu_defs=(
        "CAT:[PREM]|Premium - Alight Motion"
        "Daftar Akun Premium|f_prem_register"
        "Login Akun Premium|f_prem_login"
        "Daftar + Login (Pandu)|f_prem_flow"
        "Riwayat Aktivitas Premium|f_prem_history"
        "Cek Koneksi Server API|f_prem_ping"
        "Ganti API Key|f_prem_setkey"
        "Hapus Riwayat Premium|f_prem_clear"
        "Panduan Menu Premium|f_prem_guide"
        "CAT:[SYS]|Sistem & Perangkat"
        "Informasi Sistem|f_system_info"
        "Update & Upgrade|f_update_upgrade"
        "Install Paket Esensial|f_install_essentials"
        "Setup Storage|f_setup_storage"
        "Status Baterai|f_battery"
        "Bersihkan Cache|f_clean_cache"
        "Info Sensor HP|f_sensor_list"
        "Analisis Disk|f_disk_usage"
        "Process Manager|f_process_manager"
        "Wake Lock|f_wakelock"
        "Kelola Paket (List/Uninstall)|f_pkg_manage"
        "Info SIM & Sinyal|f_sim_info"
        "Info Android & Root|f_android_info"
        "Resolusi Layar|f_screen_info"
        "Ruang Kosong Semua Partisi|f_disk_free_all"
        "Uptime Sistem|f_uptime"
        "Benchmark Kecepatan Storage|f_storage_benchmark"
        "Cek Aplikasi Terinstall|f_installed_apps"
        "Buka Aplikasi Lain|f_open_app"
        "Cek Paket Bisa Diupdate|f_outdated_pkgs"
        "Monitor Sistem Cepat|f_quick_monitor"
        "Proses Paling Berat (CPU)|f_top_processes"
        "Jadwal Sholat|f_prayer_times"
        "Cek Harga Bitcoin / Crypto|f_crypto_price"
        "CAT:[NET]|Jaringan & Internet"
        "Info Jaringan|f_network_info"
        "Speed Test|f_speedtest"
        "Cek Cuaca|f_weather"
        "IP Lookup|f_ip_lookup"
        "Cek Port|f_port_check"
        "DNS Lookup|f_dns_lookup"
        "Ping Host|f_ping"
        "Scan WiFi Sekitar|f_wifi_scan"
        "Info Koneksi WiFi|f_wifi_info"
        "Setup SSH Server|f_ssh_setup"
        "Kurs Mata Uang|f_currency"
        "Shorten URL|f_shorten_url"
        "Generate QR WiFi|f_wifi_qr"
        "Cek Status Website|f_site_status"
        "Download File dari URL|f_download_url"
        "Web Server Berbagi File|f_file_share_server"
        "WHOIS Domain|f_whois_lookup"
        "Scan Perangkat di Jaringan Lokal|f_lan_scan"
        "CAT:[FILE]|File & Backup"
        "Backup Home|f_backup_home"
        "Restore Backup|f_restore_backup"
        "File Browser|f_file_browser"
        "Cari File|f_search_file"
        "Kompres / Ekstrak|f_compress_extract"
        "Backup Konfigurasi Termux|f_backup_termux_config"
        "Bandingkan Hash 2 File|f_hash_compare"
        "Bandingkan Teks (Diff)|f_text_diff"
        "File Splitter & Joiner|f_file_split_join"
        "File Duplicate Finder|f_duplicate_finder"
        "Auto Cleanup File Lama|f_cleanup_old_files"
        "Cek Format / Jenis File|f_file_type"
        "Encrypt / Decrypt File|f_encrypt_file"
        "CAT:[DEV]|Developer Tools"
        "Clone Repo GitHub|f_clone_repo"
        "Buat Virtualenv Python|f_python_venv"
        "Init Project Node.js|f_node_project"
        "Base64 Encode/Decode|f_base64"
        "Hash Generator|f_hash_gen"
        "ASCII Art Text|f_ascii_art"
        "Format & Validasi JSON|f_json_pretty"
        "Convert & Resize Gambar|f_image_convert"
        "Generate UUID|f_uuid_gen"
        "Buat Struktur Folder Project|f_project_scaffold"
        "Batch Rename File|f_batch_rename"
        "Baca QR Code dari Gambar|f_qr_reader"
        "JSON <-> CSV Converter|f_json_to_csv"
        "CAT:[API]|Termux:API & Multimedia"
        "Termux:API Menu|f_termux_api_menu"
        "Lokasi GPS|f_location"
        "Ambil Foto Kamera|f_camera_photo"
        "Text to Speech|f_tts"
        "Kontrol Volume|f_volume"
        "Dialog Input Interaktif|f_dialog"
        "Extract Audio dari Video|f_extract_audio"
        "Kompres Ukuran Gambar|f_image_compress"
        "CAT:[PROD]|Produktivitas"
        "Catatan Cepat|f_notes"
        "To-Do List|f_todo"
        "Kalender Bulan Ini|f_calendar"
        "Timer / Stopwatch|f_timer_stopwatch"
        "Kalkulator|f_calculator"
        "Konversi Satuan|f_unit_convert"
        "Countdown Hari Penting|f_countdown_date"
        "Reminder Sekali|f_reminder_once"
        "Perintah Favorit|f_snippets"
        "Clipboard Manager|f_clipboard_manager"
        "CAT:[FUN]|Hiburan & Fun"
        "Tebak Angka|f_game_guess"
        "Suit (Batu Gunting Kertas)|f_game_suit"
        "Lempar Dadu|f_game_dice"
        "Lempar Koin|f_game_coin"
        "Tic Tac Toe vs CPU|f_game_tictactoe"
        "Trivia Kuis Singkat|f_game_trivia"
        "Fortune Cookie|f_fortune_cookie"
        "Tes Kecepatan Mengetik|f_typing_test"
        "CAT:[UTIL]|Utilitas Lain"
        "Ganti Tema Warna|f_theme"
        "Generator Password|f_password_gen"
        "Generator QR Code|f_qr_gen"
        "Edit MOTD|f_motd"
        "Lihat Log|f_view_log"
        "Statistik Pemakaian|f_stats"
        "Cek Update Azr Tools|f_self_update"
        "Text Case Converter|f_case_convert"
        "Word & Character Counter|f_word_counter"
        "Quote Motivasi|f_quote"
        "Generate Data Dummy|f_dummy_data"
        "Cek Kekuatan Password|f_password_strength"
        "Text to Morse Code|f_morse_code"
        "Random Number Generator|f_random_number"
        "Caesar Cipher / ROT13|f_caesar_cipher"
        "Analisis Kata Terbanyak|f_word_frequency"
        "Riwayat Versi (Changelog)|f_view_changelog"
        "Pengaturan Animasi Menu|f_toggle_anim"
        "Tentang Azr Tools|f_about"
    )

    # --- parse menu_defs jadi kategori (item tidak diberi nomor global lagi, cukup per-kategori) ---
    CAT_TITLES=(); CAT_ICONS=(); CAT_ITEMS=(); CAT_COUNT=()
    local cur_icon="" cur_title="" cur_items=() def rest

    for def in "${menu_defs[@]}"; do
        if [[ "$def" == CAT:* ]]; then
            if [[ -n "$cur_title" ]]; then
                CAT_TITLES+=("$cur_title"); CAT_ICONS+=("$cur_icon")
                CAT_ITEMS+=("$(printf '%s\n' "${cur_items[@]}")")
                CAT_COUNT+=("${#cur_items[@]}")
            fi
            rest="${def#CAT:}"
            cur_icon="${rest%%|*}"; cur_title="${rest#*|}"
            cur_items=()
        else
            cur_items+=("$def")
        fi
    done
    if [[ -n "$cur_title" ]]; then
        CAT_TITLES+=("$cur_title"); CAT_ICONS+=("$cur_icon")
        CAT_ITEMS+=("$(printf '%s\n' "${cur_items[@]}")")
        CAT_COUNT+=("${#cur_items[@]}")
    fi

    while true; do
        banner
        show_category_list
        hr
        read -rp "$(echo -e ${C5}${BOLD}"➜ Pilih kategori (1-${exit_num}): "${NC})" choice
        log_msg "Kategori dipilih: $choice"

        if [[ "$choice" == "$exit_num" ]]; then
            clear
            echo -e "${C3}${BOLD}Sampai jumpa lagi! 👋${NC}"
            exit 0
        elif [[ "$choice" == "$search_num" ]]; then
            do_search
        elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#CAT_TITLES[@]} )); then
            local cat_idx=$((choice-1))
            open_anim "${CAT_TITLES[$cat_idx]}"
            while true; do
                show_submenu "$cat_idx"
                read -rp "$(echo -e ${C5}${BOLD}"➜ Pilih fitur: "${NC})" sub
                if [[ "$sub" == "0" ]]; then
                    break
                elif [[ "$sub" =~ ^[0-9]+$ ]] && (( sub >= 1 && sub <= ${#SUB_FUNCS[@]} )); then
                    "${SUB_FUNCS[$((sub-1))]}"
                else
                    echo -e "${RED}Pilihan tidak valid!${NC}"
                    sleep 1
                fi
            done
        else
            echo -e "${RED}Pilihan tidak valid!${NC}"
            sleep 1
        fi
    done
}

# ---------- ANIMASI BOOT (sekali saat script dijalankan) ----------
boot_sequence() {
    clear
    TERM_COLS=$(tput cols 2>/dev/null); TERM_COLS=${TERM_COLS:-40}
    center_text "A Z R   T O O L S" "${C1}${BOLD}" 13
    echo ""

    if [[ "$ANIM" != "1" ]]; then
        echo -e "  ${GREEN}[✔]${NC} Siap dipakai."
        sleep 0.2
        return
    fi

    local steps=("Menyiapkan sistem" "Memuat modul jaringan" "Mengaktifkan Termux:API" "Merapikan menu kategori" "Menyalakan animasi")
    local s
    for s in "${steps[@]}"; do
        printf "  ${C4}[${C2}•${C4}]${NC} %s" "$s"
        sleep 0.12; printf "."
        sleep 0.12; printf "."
        sleep 0.12; printf ".\n"
        printf "\033[1A\r  ${GREEN}[✔]${NC} %s   \n" "$s"
    done
    echo ""
    local width=28 p pct
    printf "  ${WHITE}["
    for ((p=1; p<=width; p++)); do
        printf "${C2}█"
        pct=$(( p*100/width ))
    done
    printf "${NC}${WHITE}] 100%%${NC}\n"
    sleep 0.3
}

boot_sequence
main_menu
