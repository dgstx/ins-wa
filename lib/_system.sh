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


phpmyadmin_install() {
  print_banner
  printf "${WHITE} 🌐 Instalando PHPMYADMIN...${GRAY_LIGHT}"
  printf "\n\n"

  #pasta
  sudo -u deploy mkdir /home/deploy/phpm/upload
  sudo -u deploy mkdir /home/deploy/phpm/download
  sudo chmod -R 777 /home/deploy/phpm

  # Instalando o Apache e o PHP
  sudo apt-get install apache2 php -y

  # Baixando o phpMyAdmin e configurando a instalação não interativa
  sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
  sudo tar xzf phpMyAdmin-latest-all-languages.tar.gz
  sudo rm -rf /usr/share/phpmyadmin
  sudo mv phpMyAdmin-*-all-languages /usr/share/phpmyadmin
  sudo mkdir -p /usr/share/phpmyadmin/tmp
  sudo chown -R www-data:www-data /usr/share/phpmyadmin
  sudo chmod 777 /usr/share/phpmyadmin/tmp
  sudo echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${mysql_root_password}" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/mysql/app-pass password ${mysql_root_password}" | sudo debconf-set-selections
  sudo echo "phpmyadmin phpmyadmin/app-password-confirm password ${mysql_root_password}" | sudo debconf-set-selections

  # Injetando as informações no arquivo de configuração do phpMyAdmin
sudo bash -c "cat > /usr/share/phpmyadmin/config.inc.php <<EOF
<?php
/**
 * phpMyAdmin sample configuration, you can use it as base for
 * manual configuration. For easier setup you can use setup/
 *
 * All directives are explained in documentation in the doc/ folder
 * or at <https://docs.phpmyadmin.net/>.
 */

declare(strict_types=1);

/**
 * This is needed for cookie based authentication to encrypt the cookie.
 * Needs to be a 32-bytes long string of random bytes. See FAQ 2.10.
 */
\$cfg['blowfish_secret'] = '7627cb9027e713e301e83a8f13057055';

/**
 * Servers configuration
 */
\$i = 0;

/**
 * First server
 */
\$i++;
/* Authentication type */
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
/* Server parameters */
\$cfg['Servers'][\$i]['host'] = 'localhost';
\$cfg['Servers'][\$i]['compress'] = false;
//\$cfg['Servers'][\$i]['compress'] = false;
\$cfg['Servers'][\$i]['AllowNoPassword'] = false;

/**
 * phpMyAdmin configuration storage settings.
 */

/* User used to manipulate with storage */
// \$cfg['Servers'][\$i]['controlhost'] = '';
// \$cfg['Servers'][\$i]['controlport'] = '';
// \$cfg['Servers'][\$i]['controluser'] = 'pma';
// \$cfg['Servers'][\$i]['controlpass'] = 'pmapass';

/* Storage database and tables */
 \$cfg['Servers'][\$i]['pmadb'] = 'phpmyadmin';
 \$cfg['Servers'][\$i]['bookmarktable'] = 'pma__bookmark';
 \$cfg['Servers'][\$i]['relation'] = 'pma__relation';
 \$cfg['Servers'][\$i]['table_info'] = 'pma__table_info';
 \$cfg['Servers'][\$i]['table_coords'] = 'pma__table_coords';
 \$cfg['Servers'][\$i]['pdf_pages'] = 'pma__pdf_pages';
 \$cfg['Servers'][\$i]['column_info'] = 'pma__column_info';
 \$cfg['Servers'][\$i]['history'] = 'pma__history';
 \$cfg['Servers'][\$i]['table_uiprefs'] = 'pma__table_uiprefs';
 \$cfg['Servers'][\$i]['tracking'] = 'pma__tracking';
 \$cfg['Servers'][\$i]['userconfig'] = 'pma__userconfig';
 \$cfg['Servers'][\$i]['recent'] = 'pma__recent';
 \$cfg['Servers'][\$i]['favorite'] = 'pma__favorite';
 \$cfg['Servers'][\$i]['users'] = 'pma__users';
 \$cfg['Servers'][\$i]['usergroups'] = 'pma__usergroups';
 \$cfg['Servers'][\$i]['navigationhiding'] = 'pma__navigationhiding';
 \$cfg['Servers'][\$i]['savedsearches'] = 'pma__savedsearches';
 \$cfg['Servers'][\$i]['central_columns'] = 'pma__central_columns';
 \$cfg['Servers'][\$i]['designer_settings'] = 'pma__designer_settings';
 \$cfg['Servers'][\$i]['export_templates'] = 'pma__export_templates';

/**
 * End of servers configuration
 */

/**
 * Directories for saving/loading files from server
 */
\$cfg['UploadDir'] = '/home/deploy/phpm/upload';
\$cfg['SaveDir'] = '/home/deploy/phpm/upload';

/**
 * Whether to display icons or text or both icons and text in table row
 * action segment. Value can be either of 'icons', 'text' or 'both'.
 * default = 'both'
 */
//\$cfg['RowActionType'] = 'icons';

/**
 * Defines whether a user should be displayed a "show all (records)"
 * button in browse mode or not.
 * default = false
 */
//\$cfg['ShowAll'] = true;

/**
 * Number of rows displayed when browsing a result set. If the result
 * set contains more rows, "Previous" and "Next".
 * Possible values: 25, 50, 100, 250, 500
 * default = 25
 */
//\$cfg['MaxRows'] = 50;

/**
 * Disallow editing of binary fields
 * valid values are:
 *   false    allow editing
 *   'blob'   allow editing except for BLOB fields
 *   'noblob' disallow editing except for BLOB fields
 *   'all'    disallow editing
 * default = 'blob'
 */
//\$cfg['ProtectBinary'] = false;

/**
 * Default language to use, if not browser-defined or user-defined
 * (you find all languages in the locale folder)
 * uncomment the desired line:
 * default = 'en'
 */
//\$cfg['DefaultLang'] = 'en';
//\$cfg['DefaultLang'] = 'de';

/**
 * How many columns should be used for table display of a database?
 * (a value larger than 1 results in some information being hidden)
 * default = 1
 */
//\$cfg['PropertiesNumColumns'] = 2;

/**
 * Set to true if you want DB-based query history.If false, this utilizes
 * JS-routines to display query history (lost by window close)
 *
 * This requires configuration storage enabled, see above.
 * default = false
 */
//\$cfg['QueryHistoryDB'] = true;

/**
 * When using DB-based query history, how many entries should be kept?
 * default = 25
 */
//\$cfg['QueryHistoryMax'] = 100;

/**
 * Whether or not to query the user before sending the error report to
 * the phpMyAdmin team when a JavaScript error occurs
 *
 * Available options
 * ('ask' | 'always' | 'never')
 * default = 'ask'
 */
//\$cfg['SendErrorReports'] = 'always';

/**
 * 'URLQueryEncryption' defines whether phpMyAdmin will encrypt sensitive data from the URL query string.
 * 'URLQueryEncryptionSecretKey' is a 32 bytes long secret key used to encrypt/decrypt the URL query string.
 */
//\$cfg['URLQueryEncryption'] = true;
//\$cfg['URLQueryEncryptionSecretKey'] = '';

/**
 * You can find more configuration options in the documentation
 * in the doc/ folder or at <https://docs.phpmyadmin.net/>.
 */
EOF"


  #cofgi do apache pt2
  sudo sed -i 's/^DocumentRoot \/var\/www\/html/# DocumentRoot \/var\/www\/html/g' /etc/apache2/sites-available/000-default.conf
  sudo sed -i '$a DocumentRoot \/usr\/share\/phpmyadmin' /etc/apache2/sites-available/000-default.conf

  #extenção que falto no php
  sudo apt-get install php-mysqli -y
  sudo apt-get install php-mbstring -y


  # alterando a porta do Apache para 8080 pra para de da cobflito
  sudo sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf
  sudo sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:8080>/" /etc/apache2/sites-available/000-default.conf

  # reinicia apache
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
  
  

  sleep 3
  print_banner
  printf "${WHITE} ✅ Instalação do PHPMYADMIN realizada com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"
  sleep 2
  exit
}



