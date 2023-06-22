#!/bin/bash
# 
# system management

#######################################
# creates user
# Arguments:
#   None
#######################################
system_create_user() {
  print_banner
  printf "${WHITE} 💻 Agora, vamos criar o usuário 'deploy' utilizado para as instancias...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  useradd -m -p $(openssl passwd -crypt $mysql_root_password) -s /bin/bash -G sudo deploy
  usermod -aG sudo deploy
EOF

  sleep 2
}

#######################################
# clones repostories using git
# Arguments:
#   None
#######################################
system_git_clone() {
  print_banner
  printf "${WHITE} 💻 Fazendo download do Wasap de ${repo_wasap}...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
    git clone ${repo_wasap} /home/deploy/${instancia_add}/
EOF

  sleep 2
}


#######################################
# updates system
# Arguments:
#   None
#######################################
system_update() {
  print_banner
  printf "${WHITE} 💻 Vamos atualizar o sistema Wasap...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt -y update
EOF

  sleep 2
}

#######################################
# installs node
# Arguments:
#   None
#######################################
system_node_install() {
  print_banner
  printf "${WHITE} 💻 Instalando nodejs...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
  apt-get install -y nodejs
EOF

  sleep 2
}

#######################################
# installs mysql
# Arguments:
#   None
#######################################
system_mysql_install() {
  print_banner
  printf "${WHITE} 💻 Instalando MySQL...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  sudo apt update
  sudo apt install mysql-server -y
  sudo mysql
  ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_root_password}';
  FLUSH PRIVILEGES;
  exit
EOF

  sleep 2
}

#######################################
# Ask for file location containing
# multiple URL for streaming.
# Globals:
#   WHITE
#   GRAY_LIGHT
#   BATCH_DIR
#   PROJECT_ROOT
# Arguments:
#   None
#######################################
system_puppeteer_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando Dependencias do Puppeteer...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt-get install -y libxshmfence-dev \
                      libgbm-dev \
                      wget \
                      unzip \
                      fontconfig \
                      locales \
                      gconf-service \
                      libasound2 \
                      libatk1.0-0 \
                      libc6 \
                      libcairo2 \
                      libcups2 \
                      libdbus-1-3 \
                      libexpat1 \
                      libfontconfig1 \
                      libgcc1 \
                      libgconf-2-4 \
                      libgdk-pixbuf2.0-0 \
                      libglib2.0-0 \
                      libgtk-3-0 \
                      libnspr4 \
                      libpango-1.0-0 \
                      libpangocairo-1.0-0 \
                      libstdc++6 \
                      libx11-6 \
                      libx11-xcb1 \
                      libxcb1 \
                      libxcomposite1 \
                      libxcursor1 \
                      libxdamage1 \
                      libxext6 \
                      libxfixes3 \
                      libxi6 \
                      libxrandr2 \
                      libxrender1 \
                      libxss1 \
                      libxtst6 \
                      ca-certificates \
                      fonts-liberation \
                      libappindicator1 \
                      libnss3 \
                      lsb-release \
                      xdg-utils
EOF

  sleep 2
}

#######################################
# installs pm2
# Arguments:
#   None
#######################################
system_pm2_install() {
  print_banner
  printf "${WHITE} 💻 Instalando pm2...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  npm install -g pm2
  pm2 startup ubuntu -u deploy
  env PATH=\$PATH:/usr/bin pm2 startup ubuntu -u deploy --hp /home/deploy/${instancia_add}
  pm2 save -f
EOF

  sleep 2
}

#######################################
# installs snapd
# Arguments:
#   None
#######################################
system_snapd_install() {
  print_banner
  printf "${WHITE} 💻 Instalando snapd...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt install -y snapd
  snap install core
  snap refresh core
EOF

  sleep 2
}

#######################################
# installs certbot
# Arguments:
#   None
#######################################
system_certbot_install() {
  print_banner
  printf "${WHITE} 💻 Instalando certbot...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt-get remove certbot
  snap install --classic certbot
  ln -s /snap/bin/certbot /usr/bin/certbot
EOF

  sleep 2
}

#######################################
# installs nginx
# Arguments:
#   None
#######################################
system_nginx_install() {
  print_banner
  printf "${WHITE} 💻 Instalando nginx...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt install -y nginx
  rm /etc/nginx/sites-enabled/default
EOF

  sleep 2
}

#######################################
# restarts nginx
# Arguments:
#   None
#######################################
system_nginx_restart() {
  print_banner
  printf "${WHITE} 💻 Reiniciando nginx...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  service nginx restart
EOF

  sleep 2
}

#######################################
# setup for nginx.conf
# Arguments:
#   None
#######################################
system_nginx_conf() {
  print_banner
  printf "${WHITE} 💻 configurando nginx...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - root << EOF

cat > /etc/nginx/conf.d/system.conf << 'END'
client_max_body_size 100M;
END

EOF

  sleep 2
}

#######################################
# installs nginx
# Arguments:
#   None
#######################################
system_certbot_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando certbot...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  backend_domain=$(echo "${backend_url/https:\/\/}")
  frontend_domain=$(echo "${frontend_url/https:\/\/}")

  sudo su - root <<EOF
  certbot -m $deploy_email \
          --nginx \
          --agree-tos \
          --non-interactive \
          --domains $backend_domain,$frontend_domain
EOF

  sleep 2
}

#######################################
# Delete system
# Arguments:
#   None
#######################################
system_delete() {
  print_banner

  printf "Tem certeza de que deseja excluir a instância ${instancia_delete}? Digite o nome da instância para confirmar: "
  read confirmation

  if [ "$confirmation" != "$instancia_delete" ]; then
    printf "${RED} ❌ Confirmação inválida. Cancelando a exclusão da instância...${GRAY_LIGHT}"
    printf "\n\n"
    return
  fi

  printf "${WHITE} 🚮 Excluindo o sistema Wasap de ${instancia_delete}...${GRAY_LIGHT}"
  printf "\n\n"

  # Lógica para excluir a Instancia, usuário do db, db e processo do pm2
  sudo rm -rf /home/deploy/${instancia_delete}
  sudo mysql -e "DROP DATABASE IF EXISTS ${instancia_delete};"
  sudo mysql -e "DROP USER IF EXISTS '${instancia_delete}'@'localhost';"
  cd && sudo rm -rf /etc/nginx/sites-enabled/${instancia_delete}-frontend
  cd && sudo rm -rf /etc/nginx/sites-enabled/${instancia_delete}-backend  
  cd && sudo rm -rf /etc/nginx/sites-available/${instancia_delete}-frontend
  cd && sudo rm -rf /etc/nginx/sites-available/${instancia_delete}-backend
  cd
  sudo su - deploy <<EOF
  pm2 delete ${instancia_delete}-frontend
  pm2 delete ${instancia_delete}-backend
  pm2 save -f
EOF
  sleep 2

  print_banner
  printf "${WHITE} ✅ Remoção da instância ${instancia_delete} realizada com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# Suspend system
# Arguments:
#   None
#######################################
system_suspend() {
  print_banner
  printf "${WHITE} ⛔ Suspendendo Instancia...${GRAY_LIGHT}"
  printf "\n\n"

  # Lógica para suspender a Instancia específica no pm2
  sudo su - deploy <<EOF
  pm2 stop ${instancia_suspend}-backend
  pm2 save -f
EOF

  sleep 2

  print_banner
  printf "${WHITE} ✅ Bloqueio da Instancia ${instancia_suspend} realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# Resume system
# Arguments:
#   None
#######################################
system_resume() {
  print_banner
  printf "${WHITE} ▶️ Retomando o sistema...${GRAY_LIGHT}"
  printf "\n\n"

  # Lógica para retomar a execução do sistema no PM2
  sudo su - deploy <<EOF
  pm2 start ${instancia_resume}-backend
  pm2 save -f
EOF

  sleep 2

  print_banner
  printf "${WHITE} ✅ Desbloqueio da Instancia ${instancia_resume} realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# Restart system
# Arguments:
#   None
#######################################
system_restart() {
  print_banner
  printf "${WHITE} ♻️ Reiniciando o sistema...${GRAY_LIGHT}"
  printf "\n\n"
  # Lógica para reiniciar a Instancia específica no pm2
  sudo su - deploy <<EOF
  pm2 restart ${sub_restart}-backend
  pm2 restart ${sub_restart}-frontend
  pm2 save -f
EOF
sleep 2
  print_banner
  printf "${WHITE} ✅ Reinicio da Instancia ${sub_restart} realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"
  sleep 2
}


#######################################
# install phpmyadmin
# Arguments:
#   None
#######################################
phpmyadmin_install() {
  print_banner
  printf "${WHITE} 🌐 Instalando PHPMYADMIN em ${sub_phpmy}.wasap.com.br...${GRAY_LIGHT}"
  printf "\n\n"

  # Lógica para instalação do phpMyAdmin no servidor
  sudo apt install -y phpmyadmin php-mbstring php-gettext

  # Criar link simbólico para o diretório do phpMyAdmin no diretório do Nginx
  sudo ln -s /usr/share/phpmyadmin /var/www/html/${sub_phpmy}
  # Configurar o arquivo de host do Nginx para o subdomínio do phpMyAdmin
  sudo tee /etc/nginx/sites-available/${sub_phpmy} << EOF
    server {
    listen 80;
    server_name ${sub_phpmy}.wasap.com.br;

    location / {
        root /var/www/html/${sub_phpmy};
        index index.php index.html index.htm;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

  # Ativar o arquivo de host do phpMyAdmin no Nginx
  sudo ln -s /etc/nginx/sites-available/${sub_phpmy} /etc/nginx/sites-enabled/

  # Reiniciar o serviço do Nginx para aplicar as alterações
  sudo systemctl restart nginx

  sleep 2
  print_banner
  printf "${WHITE} ✅ Instalação do PHPMYADMIN realizada com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"
  sleep 2
}

