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
  sudo mysql -e "DROP DATABASE ${instancia_delete};"
  sudo mysql -e "DROP USER '${instancia_delete}'@'localhost';"
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
# instalar phpmyadmin no servidor
# Arguments:
#   None
#######################################
phpmyadmin_install() {
  #verifica se o phpmyadmin já está instalado se estiver cancela e volta para o menu do inquiry
if [ -d "/usr/share/phpmyadmin" ]; then
	printf "${RED} ❌ O phpmyadmin já está instalado${GRAY_LIGHT}"
	printf "\n\n"
	sleep 2
    exit
  fi
print_banner
printf "${WHITE} 💻 Instalando o phpmyadmin...${GRAY_LIGHT}"
printf "\n\n"
sleep 2

  # Instalando o Apache e o PHP
  sudo apt-get install apache2 php -y

  # Baixando o phpMyAdmin e configurando a instalação não interativa
  sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
  sudo tar xzf phpMyAdmin-latest-all-languages.tar.gz
  sudo rm -rf /usr/share/phpmyadmin
  sudo mv phpMyAdmin-*-all-languages /usr/share/phpmyadmin
  sudo mkdir -p /usr/share/phpmyadmin/tmp
  sudo chown -R www-data:www-data /usr/share/phpmyadmin
  sudo chmod 755 /usr/share/phpmyadmin/tmp
  sudo echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${mysql_root_password}" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/mysql/app-pass password ${mysql_root_password}" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/app-password-confirm password ${mysql_root_password}" | sudo debconf-set-selections

# Configuração do arquivo config.inc.php
sudo bash -c "cat > /usr/share/phpmyadmin/config.inc.php <<EOF
<?php
declare(strict_types=1);
\\\$i = 0;
\\\$i++;
\\\$cfg['blowfish_secret'] = '7627cb9027e713e301e83a8f13057055';
\\\$cfg['Servers'][\\\$i]['auth_type'] = 'cookie';
\\\$cfg['Servers'][\\\$i]['host'] = 'localhost';
\\\$cfg['Servers'][\\\$i]['compress'] = false;
\\\$cfg['Servers'][\\\$i]['AllowNoPassword'] = false;
\\\$cfg['Servers'][\\\$i]['pmadb'] = 'phpmyadmin';
\\\$cfg['Servers'][\\\$i]['bookmarktable'] = 'pma__bookmark';
\\\$cfg['Servers'][\\\$i]['relation'] = 'pma__relation';
\\\$cfg['Servers'][\\\$i]['table_info'] = 'pma__table_info';
\\\$cfg['Servers'][\\\$i]['table_coords'] = 'pma__table_coords';
\\\$cfg['Servers'][\\\$i]['pdf_pages'] = 'pma__pdf_pages';
\\\$cfg['Servers'][\\\$i]['column_info'] = 'pma__column_info';
\\\$cfg['Servers'][\\\$i]['history'] = 'pma__history';
\\\$cfg['Servers'][\\\$i]['table_uiprefs'] = 'pma__table_uiprefs';
\\\$cfg['Servers'][\\\$i]['tracking'] = 'pma__tracking';
\\\$cfg['Servers'][\\\$i]['userconfig'] = 'pma__userconfig';
\\\$cfg['Servers'][\\\$i]['recent'] = 'pma__recent';
\\\$cfg['Servers'][\\\$i]['favorite'] = 'pma__favorite';
\\\$cfg['Servers'][\\\$i]['users'] = 'pma__users';
\\\$cfg['Servers'][\\\$i]['usergroups'] = 'pma__usergroups';
\\\$cfg['Servers'][\\\$i]['navigationhiding'] = 'pma__navigationhiding';
\\\$cfg['Servers'][\\\$i]['savedsearches'] = 'pma__savedsearches';
\\\$cfg['Servers'][\\\$i]['central_columns'] = 'pma__central_columns';
\\\$cfg['Servers'][\\\$i]['designer_settings'] = 'pma__designer_settings';
\\\$cfg['Servers'][\\\$i]['export_templates'] = 'pma__export_templates';
\\\$cfg['UploadDir'] = '/home/deploy/phpm/upload';
\\\$cfg['SaveDir'] = '/home/deploy/phpm/upload';
EOF"


  # Configuração do Apache
  sudo sed -i 's/^DocumentRoot \/var\/www\/html/# DocumentRoot \/var\/www\/html/g' /etc/apache2/sites-available/000-default.conf
  sudo sed -i '$a DocumentRoot \/usr\/share\/phpmyadmin' /etc/apache2/sites-available/000-default.conf

  # Instalação de extensões PHP
  sudo apt-get install php-mysqli php-mbstring -y

  # Alterando a porta do Apache para 8080 para evitar conflitos
  sudo sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf
  sudo sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:8080>/" /etc/apache2/sites-available/000-default.conf

  # Reinicia o Apache
  sudo systemctl restart apache2
  sudo systemctl status apache2

  sleep 1
  print_banner
  printf "${WHITE} ✅ Finalizando.${GRAY_LIGHT}"
  printf "\n\n"

  sleep 1
  print_banner
  printf "${WHITE} ✅ Finalizando..${GRAY_LIGHT}"
  printf "\n\n"

  sleep 1
  print_banner
  printf "${WHITE} ✅ Finalizando...${GRAY_LIGHT}"
  printf "\n\n"
  sleep 1

  # Criação de pastas
  sudo -u deploy mkdir -p /home/deploy/phpm/upload
  sudo -u deploy mkdir -p /home/deploy/phpm/download
  sudo chown -R deploy:deploy /home/deploy/phpm
  sudo chmod -R 777 /home/deploy/phpm

  sleep 3
  print_banner
  printf "${WHITE} ✅ Instalação do PHPMYADMIN realizada com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
  exit
}

#######################################
# listar processos pm2
# Arguments:
#   None
#######################################
pm2_list() {
  print_banner
  printf "${WHITE} 🌐 Listando processos PM2...${GRAY_LIGHT}"
  printf "\n"
  printf "${WHITE} ✅ Listagem de processos PM2 realizada com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"
  sudo -u deploy pm2 list
  #parar até usuario pressionar enter
  read -p "Pressione [Enter] para continuar..."
  sleep 1
  exit
}

#######################################
# entrar no monitor do pm2  
# Arguments:
#   None
#######################################
pm2_logs() {
  print_banner
  printf "${WHITE} 🌐 Monitorando processos PM2...${GRAY_LIGHT}"
  printf "\n"
  printf "${WHITE} ✅ Monitoramento de processos PM2 realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"
  sudo -u deploy pm2 logs
  #parar até usuario pressionar enter
  read -p "Pressione [Enter] para continuar..."
  sleep 1
  exit
}