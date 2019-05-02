# slutprojektvt19webbserver

# Projektplan - Secure Vault Meme generator and Storage 

## 1. Projektbeskrivning
Projektet är en säker lösenordskyddad hemsida vars uppgift är att förvara memes av den högsta kvaliten. Applikationen skall kunna säkert skydda mot majoriteten av de "hot" som togs upp i webbapplikationssäkerhets PP. Den ska bestå av ett inloggningssystem som verifierar vem du är, vid misslyckad inloggning skall en ruta komma upp som säger att fel lösenord har skrivits in. Vid lyckad verifiering och inloggning skall sidan hämta upp databasen och visa de memes som lagras på en säkrad databas. Man skall ha alterantivet att söka efter memes baserat på ett "tag" system. Varje meme accosierars med tre stycken tags. Alla memes har tre tags och alla tags kan ha fler memes.

Det skall även gå att lägga upp memes, på "vault" sidan skall det finnas en länk som tar en till meme uppladdningsisdan, där ska man kunna välja en fil från sin egen dator och kunna ladda upp den i databasen. Det skall även gå att lägga till fler taggar om man anser att en tagg saknas. Vid varje uppladdning av en meme väljs tre stycken taggar som beskriver memen.

EN loggut funktion skall eliminera sessionen och logga ut dig. 

## 2. Vyer (sidor)
1 - Inloggning, (en sida med textrutor för användarnamn, lösenord och en knapp för att logga in, det skall även finns en länk för att skapa ett konto)
2 - Skapa konto, (en sida textrutor för nya användarnamnet, lösenordet och bekräfta lösenordet.)
3 - Översikt, (en översikt av alla memes upplagt av alla personer som finns registererade på sidan. Det går även att ta bort memes som du själv har lagt upp)
4 - Ladda upp meme, (en sida som möjligör uppladdning av memes, en knapp som öppnar filsökaren och låter dig välja en meme, tre dropdownmenyer som låter dig välja tre olika tags, en textruta och knapp som låter dig lägga till egna taggar.)
4 - Sökfunktion, (en sökfunktion som låter dig söka efter memes med specifika taggar, sökfunktionen söker enbart efter taggar)

## 3. Funktionalitet (med sekvensdiagram)
se ./Diagrams/Sekvens

## 4. Arkitektur (Beskriv filer och mappar)
-Database
--database.db
-Diagram
--Sekvens
--ER
-Public
--css
---vault.css
--Img
---massa bilder
-Views
--create_vault.slim
--index.slim
--layout.slim
--login.slim
--upload_meme.slim
--vault_search.slim
--vault.slim
-.byebug_history
-controller.rb
-modell.rb
-README.md

## 5. (Databas med ER-diagram)
se ./Diagrams/ER-diagram
