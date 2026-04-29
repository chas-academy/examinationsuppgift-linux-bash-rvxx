#!/bin/bash

# ============================================
# Script för att skapa användare och välkomstfiler
# ============================================

# Kontrollera att scriptet körs som root
if [[ "$EUID" -ne 0 ]]; then
    echo "Fel: Scriptet måste köras som root"
    exit 1
fi

#  Kontrollera att minst ett användarnamn skickas in
if [[ "$#" -eq 0 ]]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

# ============================================
# 	Skapa alla användare och mappar
# ============================================
for USERNAME in "$@"; do

    # Kontrollera om användaren redan finns
    if id "$USERNAME" &>/dev/null; then
        echo "Användaren $USERNAME finns redan, hoppar över..."
        continue
    fi

    # Skapa användare med hemkatalog och bash som shell
    useradd -m -s /bin/bash "$USERNAME"

    # Sätt hemkatalogens sökväg
    HOME_DIR="/home/$USERNAME"

    # Skapa standardmappar
    mkdir -p "$HOME_DIR"/{Documents,Downloads,Work}

    # Sätt ägare på hela hemkatalogen
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR"

    # Sätt rättigheter (endast ägaren har tillgång)
    chmod 700 "$HOME_DIR"/{Documents,Downloads,Work}

    echo "Användare $USERNAME skapades"

done

# ============================================
# 	     Skapa välkomstfiler
# ============================================
for USERNAME in "$@"; do

    # Sätt hemkatalogens sökväg
    HOME_DIR="/home/$USERNAME"

    # Sätt sökväg till välkomstfil
    WELCOME_FILE="$HOME_DIR/welcome.txt"

    # Skapa fil med välkomsttext + lista på andra användare
    {
        echo "Välkommen $USERNAME"
        cut -d: -f1 /etc/passwd | grep -v "^$USERNAME$"
    } > "$WELCOME_FILE"

    # Sätt ägare och rättigheter på filen
    chown "$USERNAME:$USERNAME" "$WELCOME_FILE"
    chmod 600 "$WELCOME_FILE"

done

# ============================================
# 		   Klart
# ============================================
echo "Alla användare har behandlats" 
