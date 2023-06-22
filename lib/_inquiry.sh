#!/bin/bash

get_instancia_add() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da instancia a ser instalada (Utilizar Letras minusculas):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_add
}
get_mysql_password() {
  
  print_banner
  printf "${WHITE} 🔐 Insira senha padrão para o sistema (senha mysql, deve ser a mesma em todos):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " mysql_root_password
}

get_frontend_url() {
  
  print_banner
  printf "${WHITE} 🌐 Digite o domínio do FRONT:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_url
}

get_frontend_port() {
  
  print_banner
  printf "${WHITE} 🚪 Digite a porta para o FRONTEND desta instancia (3200 a 3299):  ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_port
}

get_backend_url() {
  
  print_banner
  printf "${WHITE} 🌐 Digite o domínio do BACK:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_url
}

get_backend_port() {
  
  print_banner
  printf "${WHITE} 🚪 Digite a porta para o BACKEND desta instancia (4200 a 4299) ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_port
}

get_instancia_delete() {
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia que deseja excluir:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_delete
}

get_instancia_suspend() {
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia que deseja suspender:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_suspend
}

get_instancia_resume() {
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia que deseja retomar da suspensão:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_resume
}

get_max_whats() {
  
  print_banner
  printf "${WHITE} 🔢 Digite a quantidade de WhatsApps que ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_whats
}

get_max_user() {
  
  print_banner
  printf "${WHITE} 🔢 Informe a quantidade de atendentes que ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_user
}

get_instancia_up() {
  
  print_banner
  printf "${WHITE} 🔄️ Digite o nome da instancia a ser atualizada (Utilizar Letras minusculas):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_up
}

get_repo_wasap() {
  print_banner
  printf "${WHITE} Repo do sistema Wasap (deixe em branco para usar o padrão: https://github.com/rafaelbok/press.git): ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " repo_wasap

  # Verifica se o user deixo em branco
  if [[ -z "$repo_wasap" ]]; then
    repo_wasap="https://github.com/rafaelbok/press.git"
  fi
}

get_sub_phpmy() {
  print_banner
  printf "${WHITE} Digite o inicio do subdominio para o phpmyadmin (Se for exemplo.wasap.com.br digite apenas examplo): ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " sub_phpmy
}

get_restart() {
  print_banner
  printf "${WHITE} 🔄️ Digite o nome da instancia a ser reiniciada: ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " sub_restart
}

get_exit() {
  print_banner
  printf "${WHITE} Saindo do script...${GRAY_LIGHT}"
  printf "\n\n"
  printf "${WHITE} tchaaaaaaaau...${GRAY_LIGHT}"
  printf "\n\n"
  printf "${RED} scritp por dgstx & rafaelbok ${GRAY_LIGHT}"
  printf "\n\n"
  cd
sleep 2
  exit
}


get_urls() {
  get_instancia_add
  get_repo_wasap
  get_mysql_password
  get_frontend_url
  get_backend_url
  get_frontend_port
  get_backend_port
  get_max_whats
  get_max_user
}

software_update() {
  get_instancia_up
  get_repo_wasap
  frontend_update
  backend_update
  inquiry_options
}

delete_system() {
  get_instancia_delete
  system_delete
  inquiry_options
}

suspend_system() {
  get_instancia_suspend
  system_suspend
  inquiry_options
}

resume_system() {
  get_instancia_resume
  system_resume
  inquiry_options
}
install_phpmyadmin() {
  get_sub_phpmy
  phpmyadmin_install
}
restart_system() {
  get_restart
  system_restart
  inquiry_options
}

e_exit() {
  get_exit
}

inquiry_options() {

    print_banner
    printf "${WHITE} 💻 Escolha uma das opções!${GRAY_LIGHT}"
    printf "\n\n"
    printf "   [1] Instalar Instancia\n"
    printf "   [2] Atualizar Instancia\n"   
    printf "   [3] Excluir Instancia\n"
    printf "   [4] Suspender Instancia\n"
    printf "   [5] Retomar Instancia\n"
    printf "   [6] Instalar phpmyadmin\n"
    printf "   [7] Reiniciar Instancia\n"
    printf "\n"
    printf "   [0] Sair\n"
    printf "\n"
    read -p "> " option

    case "${option}" in
      1) 
      get_urls
      ;;       
      2)
      software_update
      ;;       
      3) 
      delete_system
      ;;       
      4) 
      suspend_system
      ;;       
      5) 
      resume_system
      ;; 
      6)
      install_phpmyadmin
      ;;
      7)
      restart_system
      ;;
      0)
      e_exit
      ;;
        
    esac
}


