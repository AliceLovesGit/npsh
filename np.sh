#!/usr/bin/env bash

# --- 修改区域 ---
# 1. 请把下面的 YOUR_GITHUB_USERNAME 替换成你的 GitHub 用户名
MY_USER="AliceLovesGit"
MY_REPO="npsh"
# 2. 强制指定版本号（因为原作者 API 已失效）
FIXED_VERSION="v1.14.3"
FIXED_VERSION_NUM="1.14.3"
# ----------------

# 当前脚本版本号
SCRIPT_VERSION='0.0.6-mod'

# 环境变量
export DEBIAN_FRONTEND=noninteractive

# Github 反代加速代理
GITHUB_PROXY=('https://v6.gh-proxy.org/' 'https://gh-proxy.com/' 'https://hub.glowp.xyz/' 'https://proxy.vvvv.ee/')

# 工作目录和临时目录
TEMP_DIR='/tmp/nodepass'
WORK_DIR='/etc/nodepass'

trap "rm -rf $TEMP_DIR >/dev/null 2>&1 ; echo -e '\n' ;exit" INT QUIT TERM EXIT
mkdir -p $TEMP_DIR

# [此处省略了中间几百行 E[0], C[0] 等文本定义，保持与原版一致...]
# ... (请在实际操作时保留原脚本中的所有 E[] 和 C[] 数组定义) ...
# 为了篇幅，下面直接展示修改了逻辑的关键函数

# ---------------------------------------------------------
# 以下为被修改的关键功能函数
# ---------------------------------------------------------

# 检测是否需要启用 Github CDN
check_cdn() {
  # 修改：指向你自己的仓库 README 来测试连接
  for PROXY_URL in "${GITHUB_PROXY[@]}"; do
    if [ "$DOWNLOAD_TOOL" = "curl" ]; then
      REMOTE_VERSION=$(curl -ksL --connect-timeout 3 --max-time 3 ${PROXY_URL}https://raw.githubusercontent.com/${MY_USER}/${MY_REPO}/main/README.md 2>/dev/null)
    else
      REMOTE_VERSION=$(wget -qO- --no-check-certificate --tries=2 --timeout=3 ${PROXY_URL}https://raw.githubusercontent.com/${MY_USER}/${MY_REPO}/main/README.md 2>/dev/null)
    fi
    [ -n "$REMOTE_VERSION" ] && GH_PROXY="$PROXY_URL" && break
  done
}

# 获取最新版本 - 修改：全部改为硬编码 v1.14.3
get_latest_version() {
  STABLE_LATEST_VERSION="$FIXED_VERSION"
  DEV_LATEST_VERSION="$FIXED_VERSION"
  LTS_LATEST_VERSION="$FIXED_VERSION"

  STABLE_VERSION_NUM="$FIXED_VERSION_NUM"
  DEV_VERSION_NUM="$FIXED_VERSION_NUM"
  LTS_VERSION_NUM="$FIXED_VERSION_NUM"
}

# 升级 NodePass - 修改：下载地址指向你的 Release
upgrade_nodepass() {
  get_local_version all
  get_latest_version
  
  # ... (省略中间 UI 逻辑) ...

  # 下载地址全部指向你的仓库
  # 注意：请确保你 Release 里的文件名符合以下格式，或者根据你上传的文件名修改此处
  if [ "$DOWNLOAD_TOOL" = "curl" ]; then
    # 下载稳定版 (假设你上传的文件名是 nodepass_1.14.3_linux_amd64.tar.gz)
    curl -sL "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${STABLE_LATEST_VERSION}/nodepass_${STABLE_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"
    # 下载开发版
    curl -sL "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${DEV_LATEST_VERSION}/nodepass-core_${DEV_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"
    # 下载经典版
    curl -sL "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${LTS_LATEST_VERSION}/nodepass-apt_${LTS_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"
  else
    wget "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${STABLE_LATEST_VERSION}/nodepass_${STABLE_VERSION_NUM}_linux_${ARCH}.tar.gz" -qO- | tar -xz -C "$TEMP_DIR"
    # ... 其他版本同理 ...
  fi
  # ... (后续安装逻辑) ...
}

# 安装函数核心下载部分 - 修改：下载地址指向你的 Release
install() {
  # ... (省略 IP 获取等逻辑) ...

  get_latest_version

  # 后台下载
  if [ "$DOWNLOAD_TOOL" = "curl" ]; then
    { curl -sL "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${DEV_LATEST_VERSION}/nodepass-core_${DEV_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"; } &
    { curl -sL "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${STABLE_LATEST_VERSION}/nodepass_${STABLE_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"; } &
    { curl -sL "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${LTS_LATEST_VERSION}/nodepass-apt_${LTS_VERSION_NUM}_linux_${ARCH}.tar.gz" | tar -xz -C "$TEMP_DIR"; } &
    { curl -sL -o "$TEMP_DIR/qrencode" "${GH_PROXY}https://github.com/fscarmen/client_template/raw/main/qrencode-go/qrencode-go-linux-$ARCH" && chmod +x "$TEMP_DIR/qrencode"; } &
  else
    { wget "${GH_PROXY}https://github.com/${MY_USER}/${MY_REPO}/releases/download/${DEV_LATEST_VERSION}/nodepass-core_${DEV_VERSION_NUM}_linux_${ARCH}.tar.gz" -qO- | tar -xz -C "$TEMP_DIR"; } &
    # ... 其他版本同理 ...
  fi
  
  # ... (后续安装逻辑) ...
}

# 创建快捷方式 - 修改：指向你自己的 Raw 脚本地址
create_shortcut() {
  local DOWNLOAD_COMMAND
  if [ "$DOWNLOAD_TOOL" = "curl" ]; then
    DOWNLOAD_COMMAND="curl -ksSL"
  else
    DOWNLOAD_COMMAND="wget --no-check-certificate -qO-"
  fi

  cat > ${WORK_DIR}/np.sh << EOF
#!/usr/bin/env bash
bash <($DOWNLOAD_COMMAND https://raw.githubusercontent.com/${MY_USER}/${MY_REPO}/main/np.sh) \$1
EOF
  chmod +x ${WORK_DIR}/np.sh
  ln -sf ${WORK_DIR}/np.sh /usr/bin/np
  ln -sf ${WORK_DIR}/nodepass /usr/bin/nodepass
}

# [下接原脚本 main 函数等部分...]
