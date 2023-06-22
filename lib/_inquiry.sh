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
  printf "${WHITE} 💻 Digite o nome da instância que deseja excluir:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_delete
}

get_instancia_suspend() {
  print_banner
  printf "${WHITE} 💻 Digite o nome da instância que deseja suspender:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_suspend
}

get_instancia_resume() {
  print_banner
  printf "${WHITE} 💻 Digite o nome da instância que deseja retomar da suspensão:${GRAY_LIGHT}"
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


get_urls() {
  get_instancia_add
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
  frontend_update
  backend_update
}

delete_system() {
  get_instancia_delete
  system_delete
}

suspend_system() {
  get_instancia_suspend
  system_suspend
}

resume_system() {
  get_instancia_resume
  system_resume
}

inquiry_options() {

    print_banner
    printf "${WHITE} 💻 Escolha uma das opções!${GRAY_LIGHT}"
    printf "\n\n"
    printf "   [1] Instalar Instância\n"
    printf "   [2] Atualizar Instância\n"   
    printf "   [3] Excluir Instância\n"
    printf "   [4] Suspender Instância\n"
    printf "   [5] Retomar Instância\n"
    printf "\n"
    read -p "> " option

    case "${option}" in
      1) 
      get_urls 
      exit
      ;;       
      2)
      software_update 
      exit
      ;;       
      3) 
      delete_system 
      exit
      ;;       
      4) 
      suspend_system 
      exit
      ;;       
      5) 
      resume_system 
      exit
      ;; 
      
      *) exit ;;

    esac
}


