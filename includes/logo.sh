#!/bin/bash

show_logo() {
  echo -e "
${CGRAY}   SSSSSSSSSSSSSSS ${CEND}${CBLUE}EEEEEEEEEEEEEEEEEEEEEE${CEND}${CGRAY}EEEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDD      DDDDDDDDDDDDD             OOOOOOOOO   ${CEND}${CGRAY}        CCCCCCCCCCCCC${CEND}${CBLUE}KKKKKKKKK    KKKKKKK${CEND}
${CGRAY} SS:::::::::::::::S${CEND}${CBLUE}E::::::::::::::::::::E${CEND}${CGRAY}::::::::::::::::::::ED::::::::::::DDD   D::::::::::::DDD        OO:::::::::OO   ${CEND}${CGRAY}     CCC::::::::::::C${CEND}${CBLUE}K:::::::K    K:::::K${CEND}
${CGRAY}S:::::SSSSSS::::::S${CEND}${CBLUE}E::::::::::::::::::::E${CEND}${CGRAY}::::::::::::::::::::ED:::::::::::::::DD D:::::::::::::::DD    OO:::::::::::::OO ${CEND}${CGRAY}   CC:::::::::::::::C${CEND}${CBLUE}K:::::::K    K:::::K${CEND}
${CGRAY}S:::::S     SSSSSSS${CEND}${CBLUE}E::::::EEEEEEEEE::::EE${CEND}${CGRAY}E::::::EEEEEEEEE::::EDDD:::::DDDDD:::::DDDD:::::DDDDD:::::D  O:::::::OOO:::::::O${CEND}${CGRAY}  C:::::CCCCCCCC::::C${CEND}${CBLUE}K:::::::K   K::::::K${CEND}
${CGRAY}S:::::S            ${CEND}${CBLUE}E:::::E       EEEEEE  ${CEND}${CGRAY}E:::::E       EEEEEE  D:::::D    D:::::D D:::::D    D:::::D O::::::O   O::::::O ${CEND}${CGRAY}C:::::C        CCCCCC${CEND}${CBLUE}K:::::::K  K:::::KKK${CEND}
${CGRAY}S:::::S            ${CEND}${CBLUE}E:::::E               ${CEND}${CGRAY}E:::::E               D:::::D     D:::::DD:::::D     D:::::DO:::::O     O:::::OC${CEND}${CGRAY}:::::C               ${CEND}${CBLUE}K:::::::K K:::::K   ${CEND}
${CGRAY} S::::SSSS         ${CEND}${CBLUE}E::::::EEEEEEEEEE     ${CEND}${CGRAY}E::::::EEEEEEEEEE     D:::::D     D:::::DD:::::D     D:::::DO:::::O     O:::::OC${CEND}${CGRAY}:::::C               ${CEND}${CBLUE}K:::::::K:::::K    ${CEND}
${CGRAY}  SS::::::SSSSS    ${CEND}${CBLUE}E:::::::::::::::E     ${CEND}${CGRAY}E:::::::::::::::E     D:::::D     D:::::DD:::::D     D:::::DO:::::O     O:::::OC${CEND}${CGRAY}:::::C               ${CEND}${CBLUE}K:::::::::::K     ${CEND}
${CGRAY}    SSS::::::::SS  ${CEND}${CBLUE}E:::::::::::::::E     ${CEND}${CGRAY}E:::::::::::::::E     D:::::D     D:::::DD:::::D     D:::::DO:::::O     O:::::OC${CEND}${CGRAY}:::::C               ${CEND}${CBLUE}K:::::::::::K     ${CEND}
${CGRAY}       SSSSSS::::S ${CEND}${CBLUE}E::::::EEEEEEEEEE     ${CEND}${CGRAY}E::::::EEEEEEEEEE     D:::::D     D:::::DD:::::D     D:::::DO:::::O     O:::::OC${CEND}${CGRAY}:::::C               ${CEND}${CBLUE}K:::::::K:::::K    ${CEND}
${CGRAY}            S:::::S${CEND}${CBLUE}E:::::E               ${CEND}${CGRAY}E:::::E               D:::::D     D:::::DD:::::D     D:::::DO:::::O     O:::::OC${CEND}${CGRAY}:::::C               ${CEND}${CBLUE}K:::::::K K:::::K   ${CEND}
${CGRAY}            S:::::S${CEND}${CBLUE}E:::::E       EEEEEE  ${CEND}${CGRAY}E:::::E       EEEEEE  D:::::D    D:::::D D:::::D    D:::::D O::::::O   O::::::O ${CEND}${CGRAY}C:::::C        CCCCCC${CEND}${CBLUE}K:::::::K  K:::::KKK${CEND}
${CGRAY}SSSSSSS     S:::::S${CEND}${CBLUE}E::::::EEEEEEEE:::::EE${CEND}${CGRAY}E::::::EEEEEEEE:::::EDDD:::::DDDDD:::::DDDD:::::DDDDD:::::D  O:::::::OOO:::::::O${CEND}${CGRAY}  C:::::CCCCCCCC::::C${CEND}${CBLUE}K:::::::K   K::::::K${CEND}
${CGRAY}S::::::SSSSSS:::::S${CEND}${CBLUE}E::::::::::::::::::::E${CEND}${CGRAY}::::::::::::::::::::ED:::::::::::::::DD D:::::::::::::::DD    OO:::::::::::::OO ${CEND}${CGRAY}   CC:::::::::::::::C${CEND}${CBLUE}K:::::::K    K:::::K${CEND}
${CGRAY}S:::::::::::::::SS ${CEND}${CBLUE}E::::::::::::::::::::E${CEND}${CGRAY}::::::::::::::::::::ED::::::::::::DDD   D::::::::::::DDD        OO:::::::::OO   ${CEND}${CGRAY}     CCC::::::::::::C${CEND}${CBLUE}K:::::::K    K:::::K${CEND}
${CGRAY} SSSSSSSSSSSSSSS   ${CEND}${CBLUE}EEEEEEEEEEEEEEEEEEEEEE${CEND}${CGRAY}EEEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDD      DDDDDDDDDDDDD             OOOOOOOOO    ${CEND}${CGRAY}        CCCCCCCCCCCCC${CEND}${CBLUE}KKKKKKKKKK    KKKKKKK${CEND}
"

  echo ""
  echo -e "${CGREEN}Version : v${VERSION}${CEND}   ${CYELLOW}$(date '+%Y-%m-%d %H:%M:%S')${CEND}"
  echo -e "${CGRAY}OS    : $(lsb_release -ds 2>/dev/null || grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')${CEND}"
  echo -e "${CGRAY}IPv4  : $(curl -s -4 ifconfig.co)${CEND}"
  echo -e "${CGRAY}IPv6  : $(curl -s -6 ifconfig.co)${CEND}"
  echo -e "${CBLUE}For {MONDEDIE}/SSD communities${CEND}"
  echo -e "${CMAGENTA}Powered by Matt 💙${CEND}"
  echo ""
}
