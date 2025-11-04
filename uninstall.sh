#!/usr/bin/env bash

echo "Dezinstalare layout-uri Romanian Programmers și Accountants"
echo "============================================================"
echo
echo "Vor fi șterse următoarele fișiere din /Library/Keyboard Layouts/:"
echo "  • Romanian - Programmers.keylayout"
echo "  • Romanian - Programmers.icns"
echo "  • Romanian - Accountants.keylayout"
echo "  • Romanian - Accountants.icns"
echo "  • Romanian Programmers Mac.* (versiuni vechi, dacă există)"
echo

read -p "Confirmi dezinstalarea? (y/n): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
	echo "Dezinstalare anulată."
	exit 0
fi

echo
echo "» Șterg Romanian - Programmers.keylayout"
sudo rm -fv "/Library/Keyboard Layouts/Romanian - Programmers.keylayout"
echo "» Șterg Romanian - Programmers.icns"
sudo rm -fv "/Library/Keyboard Layouts/Romanian - Programmers.icns"
echo "» Șterg Romanian - Accountants.keylayout"
sudo rm -fv "/Library/Keyboard Layouts/Romanian - Accountants.keylayout"
echo "» Șterg Romanian - Accountants.icns"
sudo rm -fv "/Library/Keyboard Layouts/Romanian - Accountants.icns"

# Clean up old versions
echo "» Curăț versiuni vechi (Romanian Programmers Mac.*)"
sudo rm -fv "/Library/Keyboard Layouts/Romanian Programmers Mac.keylayout" 2>/dev/null || true
sudo rm -fv "/Library/Keyboard Layouts/Romanian Programmers Mac.icns" 2>/dev/null || true

# Clear caches
echo "» Curăț cache-urile internaționale (IntlDataCache)"
sudo find /System/Library/Caches -name "*IntlDataCache*" -maxdepth 1 2>/dev/null | sudo xargs rm -fv 2>/dev/null || true
sudo find /var -name "*IntlDataCache*" -maxdepth 2 2>/dev/null | sudo xargs rm -fv 2>/dev/null || true

echo
echo "✓ Dezinstalare finalizată."
echo
echo -e "\033[1mAtentie: pentru ca schimbarile sa fie vizibile, este nevoie de logout + login\033[0m"
echo "Apoi elimină layout-urile din System Settings → Keyboard → Input Sources."
