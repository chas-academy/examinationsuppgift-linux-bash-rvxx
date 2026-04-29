#!/bin/bash

# Script för att skapa användare, mappar och en välkomstfil

# Kontrollera att scriptet körs som root
if [[ "$EUID" -ne 0 ]]; then
    echo "Fel: Scriptet måste köras som root"
    exit 1
fi

# Kontrollera att minst ett användarnamn skickas in
if [[ "$#" -eq 0 ]]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

# Loopa igenom alla användarnamn som skickas in
for USERNAME in "$@"; do

    # Kontrollera om användaren redan finns
    if id "$USERNAME" &>/dev/null; then
        echo "Användaren $USERNAME finns redan, hoppar över..."
        continue
    fi

    # Skapa användare med hemkatalog och bash som standard-shell
    useradd -m -s /bin/bash "$USERNAME"

    # Sätt sökvägen till användarens hemkatalog
    HOME_DIR="/home/$USERNAME"

    # Skapa nödvändiga mappar
    mkdir -p "$HOME_DIR"/{Documents,Downloads,Work}

    # Sätt ägare på hemkatalogen och dess innehåll
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR"

    # Sätt rättigheter (endast ägaren har tillgång)
    chmod 700 "$HOME_DIR"/{Documents,Downloads,Work}

    # Skapa välkomstfil
    WELCOME_FILE="$HOME_DIR/welcome.txt"

    {
        echo "Välkommen $USERNAME"
        cut -d: -f1 /etc/passwd | grep -v "^$USERNAME$"
    } > "$WELCOME_FILE"

    # Sätt rätt ägare och rättigheter på välkomstfilen
    chown "$USERNAME:$USERNAME" "$WELCOME_FILE"
    chmod 600 "$WELCOME_FILE"

    echo "Användare $USERNAME skapades"

done 
