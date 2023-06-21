#!/bin/bash

get_instancia_add() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da instancia a ser instalada (Utilizar Letras minusculas):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_add
}
get_mysql_password() {
  
  print_banner
  printf "${WHITE} 💻 Insira senha padrão para o sistema (senha mysql, deve ser a mesma em todos):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " mysql_password

get_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o domínio da interface FRONTEND:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_url
}

get_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do FRONTEND para esta instancia; Ex: 3333 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_port
}

get_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o domínio do BACKEND:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_url
}

get_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do BACKEND para esta instancia; Ex: 8080 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_port
}

get_instancia_add_delete() {
  print_banner
  printf "${WHITE} 💻 Digite o nome da instância que deseja excluir:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_add
}

get_instancia_add_suspend() {
  print_banner
  printf "${WHITE} 💻 Digite o nome da instância que deseja suspender:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_add
}

get_instancia_add_suspend() {
  print_banner
  printf "${WHITE} 💻 Digite o nome da instância que deseja retomar da suspensão:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_add
}

get_max_whats() {
  
  print_banner
  printf "${WHITE} 💻 Digite a quantidade de WhatsApps que ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_whats
}

get_max_user() {
  
  print_banner
  printf "${WHITE} 💻 Informe a quantidade de atendentes que ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_user
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
  
  frontend_update
  backend_update
}

delete_system() {
  get_instancia_add_delete
  system_delete
}

suspend_system() {
  get_instancia_add_suspend
  system_suspend
}

resume_system() {
  get_instancia_add_resume
  system_resume
}

inquiry_options() {
  while true; do
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
      1) get_urls ;;
      2) software_update ;;
      3) delete_system ;;
      4) suspend_system ;;
      5) resume_system ;;
      *) break ;;
    esac
  done
}


