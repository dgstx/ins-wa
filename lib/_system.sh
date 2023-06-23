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
    sleep 2
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
  printf "${WHITE} 🌐 Instalando PHPMYADMIN...${GRAY_LIGHT}"
  printf "\n\n"

  # Instalando o PHP para o phpMyAdmin
  sudo apt-get install php -y

  # Baixando o phpMyAdmin e configurando a instalação não interativa
  sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
  sudo tar xzf phpMyAdmin-latest-all-languages.tar.gz
  sudo mv phpMyAdmin-*-all-languages /usr/share/phpmyadmin
  sudo mkdir /usr/share/phpmyadmin/tmp
  sudo chown -R www-data:www-data /usr/share/phpmyadmin
  sudo chmod 777 /usr/share/phpmyadmin/tmp
  sudo cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
  sudo sed -i "s/localhost/phpmyadmin/g" /usr/share/phpmyadmin/config.inc.php
  sudo sed -i "s/\(\$cfg\['blowfish_secret'\] = \).*/\1'f98h3q4hg4hgj4';/" /usr/share/phpmyadmin/config.inc.php
  sudo echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${mysql_root_password}" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/mysql/app-pass password ${mysql_root_password}" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/app-password-confirm password ${mysql_root_password}" | sudo debconf-set-selections

  # Alterando a porta do Apache para 8080
  sudo sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf
  sudo sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:8080>/" /etc/apache2/sites-available/000-default.conf

  # Reiniciando o Apache
  sudo service apache2 restart

  sleep 2
  print_banner
  printf "${WHITE} ✅ Instalação do PHPMYADMIN realizada com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"
  sleep 2
}


