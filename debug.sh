#!/bin/bash

# Automation script by Mountain Interval

# CC_TEXT codes for output
CC_HEADER='\033[1;35;44m'   # Bold Magenta on Blue background - To mark sections or major steps in the script.
CC_TEXT='\033[1;34;40m'     # Bold Blue on Black background - For general text, prompts, and success messages.
CC_RESET='\033[0m'          # Reset CC_TEXT - To reset color coding.




# Clear screen
clear




# Script header
echo -e "${CC_HEADER}────── Debug  v0.02 ──────${CC_RESET}"
echo




echo
echo "Please choose which script to download and run:"
echo "0) 00--init.sh"
echo "1) 01--pre.sh"
echo "2) 02--install.sh"
echo "3) 03--chroot.sh"
echo "4) 04--post.sh"
echo "5) 05--soft.sh"

read -p "Enter the number corresponding to your choice: " choice

case $choice in
    0)
        rm -f *--*.sh && wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/00--init.sh && chmod +x 00--init.sh && ./00--init.sh
        ;;
    1)
        rm -f *--*.sh && wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/01--pre.sh && chmod +x 01--pre.sh && ./01--pre.sh
        ;;
    2)
        rm -f *--*.sh && wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/02--install.sh && chmod +x 02--install.sh && ./02--install.sh
        ;;
    3)
        rm -f *--*.sh && wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/03--chroot.sh && chmod +x 03--chroot.sh && ./03--chroot.sh
        ;;
    4)
        rm -f *--*.sh && wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/04--post.sh && chmod +x 04--post.sh && ./04--post.sh
        ;;
    5)
        rm -f *--*.sh && wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/05--soft.sh && chmod +x 05--soft.sh && ./05--soft.sh
        ;;
    *)
        echo "Invalid option. Exiting..."
        echo
        exit 1
        ;;
esac

