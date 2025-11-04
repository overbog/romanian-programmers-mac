#!/usr/bin/env bash

# make the users aware that there are multiple layouts
echo "Trebuie sa alegi aranjamentul potrivit pentru tastatura ta."
echo
echo "Aranjamentele mapeaza tasta \"\` si ~\" in pozitia uzuala, inainte de tasta 1."
echo "Apple furnizeaza cel putin 3 aranjamente diferite din punct de vedere vizual."
echo "Acele aranjamente sunt de fapt vreo doua din punct de vedere functional."
echo
echo "» Primul aranjament are tasta inscriptionata cu \"\` si ~\" inainte de 1"
echo "» Al doilea aranjament are tasta inscriptionata cu \"§ si ±\" inainte de 1"
echo 
echo "Cel de-al doilea aranjament se poate intalni si in cazul tastaturilor care"
echo "au inscriptionate diacritice pentru limba Romana fabricate de Apple, dar "
echo "nu in pozitiile definite de SR 13392:2004. Acest tip de aranjament are o "
echo "tasta suplimentara intre Shift si Z."
echo
read -p "Alege tipul de aranjament (1 = Programmers, 2 = Accountants): " kind

if [ "${kind}" != "1" ] && [ "${kind}" != "2" ]
then
    echo "Tipul ales este invalid. Valori acceptate: 1 sau 2."
    exit 1
fi

read -p "Alege varianta aranjamentului (1 sau 2): " layout

if [ "${layout}" != "1" ] && [ "${layout}" != "2" ]
then
	echo "Aranjamentul ales este invalid. Valori acceptate: 1 sau 2."
	exit 1
fi

# the directory may not exist
sudo mkdir -p "/Library/Keyboard Layouts"

# removing the previous version
sudo rm -fv "/Library/Keyboard Layouts/Romanian Programmers Mac.keylayout"
sudo rm -fv "/Library/Keyboard Layouts/Romanian Programmers Mac.icns"
sudo rm -fv "/Library/Keyboard Layouts/Romanian - Programmers.keylayout"
sudo rm -fv "/Library/Keyboard Layouts/Romanian - Programmers.icns"
sudo rm -fv "/Library/Keyboard Layouts/Romanian - Accountants.keylayout"
sudo rm -fv "/Library/Keyboard Layouts/Romanian - Accountants.icns"

# helper to transform a Programmers keylayout into Accountants variant (decimal comma)
transform_accountants() {
    # $1 = source path, $2 = dest path
    local src="$1" dest="$2"
    # Change name, id, and keypad decimal (code=65) from '.' to ',' across all maps
    sed -E \
        -e 's/(name=")Romanian - Programmers(\")/\1Romanian - Accountants\2/' \
        -e 's/(id=")-6009(\")/\1-5320\2/' \
        -e 's/(<key[[:space:]]+code=\"65\"[[:space:]]+output=\")\.(\"\/?>)/\1,\2/g' \
        "$src" > "$dest"
}

# install / update the current version
if [ "$1" == "local" ]
then
	if [ "${kind}" == "1" ]; then
		echo "» Instalez Romanian - Programmers folosind depozitul curent"
		echo "» Instalez Romanian - Programmers.icns"
		sudo cp "Romanian - Programmers.icns" "/Library/Keyboard Layouts/"
		echo "» Instalez Romanian - Programmers ${layout}.keylayout"
		sudo cp "Romanian - Programmers ${layout}.keylayout" \
"/Library/Keyboard Layouts/Romanian - Programmers.keylayout"
	else
		echo "» Instalez Romanian - Accountants (derivat din Romanian - Programmers) folosind depozitul curent"
		# Icon: reutilizez icon-ul "Romanian - Programmers.icns" sub nume nou
		if [ -f "Romanian - Programmers.icns" ]; then
		  echo "» Instalez Romanian - Accountants.icns"
		  sudo cp "Romanian - Programmers.icns" "/Library/Keyboard Layouts/Romanian - Accountants.icns"
		fi
		echo "» Generez Romanian - Accountants ${layout}.keylayout (punct zecimal -> virgula)"
		tmpfile=$(mktemp -t roacct)
		transform_accountants "Romanian - Programmers ${layout}.keylayout" "$tmpfile"
		sudo cp "$tmpfile" "/Library/Keyboard Layouts/Romanian - Accountants.keylayout"
		rm -f "$tmpfile"
	fi
else
	if [ "${kind}" == "1" ]; then
		echo "» Instalez Romanian - Programmers folosind GitHub"
		echo "» Instalez Romanian - Programmers.icns"
		sudo curl --silent --location --max-redirs 10 \
"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers.icns" \
--output "/Library/Keyboard Layouts/Romanian - Programmers.icns"
		echo "» Instalez Romanian - Programmers ${layout}.keylayout"
		sudo curl --silent --location --max-redirs 10 \
"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers%20${layout}.keylayout" \
--output "/Library/Keyboard Layouts/Romanian - Programmers.keylayout"
	else
		echo "» Instalez Romanian - Accountants (derivat din Romanian - Programmers) folosind GitHub"
		# Icon: reutilizez icon-ul existent, salvat sub noul nume
		sudo curl --silent --location --max-redirs 10 \
"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers.icns" \
--output "/Library/Keyboard Layouts/Romanian - Accountants.icns"
		echo "» Generez Romanian - Accountants ${layout}.keylayout (punct zecimal -> virgula)"
		tmpfile=$(mktemp -t roacct)
		curl --silent --location --max-redirs 10 \
"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers%20${layout}.keylayout" \
--output "$tmpfile"
		transformed=$(mktemp -t roacct2)
		transform_accountants "$tmpfile" "$transformed"
		sudo cp "$transformed" "/Library/Keyboard Layouts/Romanian - Accountants.keylayout"
		rm -f "$tmpfile" "$transformed"
	fi
fi

# clear the OS intl caches
sudo find /System/Library/Caches -name "*IntlDataCache*" 2>/dev/null | sudo xargs rm -v
sudo find /var -name "*IntlDataCache*" 2>/dev/null | sudo xargs rm -v

# in case of update ...
echo -e "\n\033[1mAtentie: pentru ca schimbarile sa fie vizibile dupa actualizare, este nevoie de logout + login\033[0m"
