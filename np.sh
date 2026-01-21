#!/usr/bin/env bash

# --- 关键配置区 ---
MY_USER="AliceLovesGit"
MY_REPO="npsh"
FIXED_VERSION="v1.14.3"
FIXED_VERSION_NUM="1.14.3"
# ------------------

# 当前脚本版本号
SCRIPT_VERSION='0.0.6-fixed'

# 环境变量
export DEBIAN_FRONTEND=noninteractive

# Github 反代加速代理
GITHUB_PROXY=('https://v6.gh-proxy.org/' 'https://gh-proxy.com/' 'https://hub.glowp.xyz/' 'https://proxy.vvvv.ee/')

# 工作目录和临时目录
TEMP_DIR='/tmp/nodepass'
WORK_DIR='/etc/nodepass'

trap "rm -rf $TEMP_DIR >/dev/null 2>&1 ; echo -e '\n' ;exit" INT QUIT TERM EXIT
mkdir -p $TEMP_DIR

# [语言包部分保持不变]
E[0]="\n Language:\n 1. 简体中文 (Default)\n 2. English"
C[0]="${E[0]}"
E[1]="1. Supports three versions: stable, development, and classic; 2. Supports switching between the three versions (np -t); 3. Added GitHub proxy"
C[1]="1. 支持稳定版、开发版和经典版三个版本; 2. 支持三个版本间切换 (np -t); 3. 增加 Github 代理"
E[2]="The script must be run as root, you can enter sudo -i and then download and run again. Feedback: [https://github.com/${MY_USER}/${MY_REPO}/issues]"
C[2]="必须以 root 方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/${MY_USER}/${MY_REPO}/issues]"
# ... (其余 E/C 数组省略，实际使用时请保留你原来的定义) ...

# [此处补全你脚本中的所有 E[] 和 C[] 定义，直到 warning 函数]

# 自定义字体彩色，read 函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }
error() { echo -e "\033[31m\033[01m$*\033[0m" && exit 1; }
info() { echo -e "\033[32m\033[01m$*\033[0m"; }
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }
reading() { read -rp "$(info "$1")" "$2"; }
text() { grep -q '\$' <<< "${E[$*]}" && eval echo "\$(eval echo "\${${L}[$*]}")" || eval echo "\${${L}[$*]}"; }

# 修正：CDN 检查指向自己的仓库
check_cdn() {
  for PROXY_URL in "${GITHUB_PROXY[@]}"; do
    if [ "$DOWNLOAD_TOOL" = "curl" ]; then
      REMOTE_TEST=$(curl -ksL --connect-timeout 3 --max-time 3 ${PROXY_URL}https://raw.githubusercontent.com/${MY_USER}/${MY_REPO}/main/np.sh 2>/dev/null)
    else
      REMOTE_TEST=$(wget -qO- --no-check-certificate --tries=2 --timeout=3 ${PROXY_URL}https://raw.githubusercontent.com/${MY_USER}/${MY_REPO}/main/np.sh 2>/dev/null)
    fi
    [ -n "$REMOTE_TEST" ] && GH_PROXY="$PROXY_URL" && break
  done
}

# 修正：获取版本号直接使用硬编码
get_latest_version() {
  STABLE_LATEST_VERSION="${FIXED_VERSION}"
  DEV_LATEST_VERSION="${FIXED_VERSION}"
  LTS_LATEST_VERSION="${FIXED_VERSION}"
  STABLE_VERSION_NUM="${FIXED_VERSION_NUM}"
  DEV_VERSION_NUM="${FIXED_VERSION_NUM}"
  LTS_VERSION_NUM="${FIXED_VERSION_NUM}"
}

# 修正：安装下载逻辑
install() {
  # ... (IP 检查部分保留) ...

  get_latest_version

  # 关键修改：下载链接全部指向你的 npsh 仓库的 Release
  info "Downloading NodePass from ${MY_USER}/${MY_REPO}..."
  
  if [ "$DOWNLOAD_TOOL" = "curl" ]; then
    { curl -sL "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${STABLE_LATEST_VERSION}/nodepass_${STABLE_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"; } &
    { curl -sL "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${DEV_LATEST_VERSION}/nodepass-core_${DEV_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"; } &
    { curl -sL "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${LTS_LATEST_VERSION}/nodepass-apt_${LTS_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"; } &
    { curl -sL -o "$TEMP_DIR/qrencode" "${GH_PROXY}https://github.com/fscarmen/client_template/raw/main/qrencode-go/qrencode-go-linux-$ARCH" && chmod +x "$TEMP_DIR/qrencode"; } &
  else
    { wget -qO- "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${STABLE_LATEST_VERSION}/nodepass_${STABLE_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"; } &
    { wget -qO- "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${DEV_LATEST_VERSION}/nodepass-core_${DEV_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"; } &
    { wget -qO- "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${LTS_LATEST_VERSION}/nodepass-apt_${LTS_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"; } &
    { wget -qO "$TEMP_DIR/qrencode" "${GH_PROXY}https://github.com/fscarmen/client_template/raw/main/qrencode-go/qrencode-go-linux-$ARCH" && chmod +x "$TEMP_DIR/qrencode"; } &
  fi
  wait

  # ... (后续安装逻辑保留) ...
  # 注意：安装逻辑里会寻找 $TEMP_DIR/nodepass 等文件，请确保你解压出来的文件名正确
  
  # 修正二进制移动逻辑（针对解压后的文件名）
  [ -f "$TEMP_DIR/nodepass" ] && mv $TEMP_DIR/nodepass $WORK_DIR/np-stb
  [ -f "$TEMP_DIR/nodepass-core" ] && mv $TEMP_DIR/nodepass-core $WORK_DIR/np-dev
  [ -f "$TEMP_DIR/nodepass-apt" ] && mv $TEMP_DIR/nodepass-apt $WORK_DIR/np-lts
  # ...
}

# 修正：快捷方式指向你自己
create_shortcut() {
  local DOWNLOAD_COMMAND
  [ "$DOWNLOAD_TOOL" = "curl" ] && DOWNLOAD_COMMAND="curl -ksSL" || DOWNLOAD_COMMAND="wget --no-check-certificate -qO-"

  cat > ${WORK_DIR}/np.sh << EOF
#!/usr/bin/env bash
bash <($DOWNLOAD_COMMAND https://raw.githubusercontent.com/${MY_USER}/${MY_REPO}/main/np.sh) \$1
EOF
  chmod +x ${WORK_DIR}/np.sh
  ln -sf ${WORK_DIR}/np.sh /usr/bin/np
  ln -sf ${WORK_DIR}/nodepass /usr/bin/nodepass
}

# [其余函数如 main, check_system 等保持原样即可]
