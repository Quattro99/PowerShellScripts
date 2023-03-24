# set_language_timezone_mailboxes.ps1

Nach dem Erstellen von neuen Benutzern auf Office 365 haben diese weder eine Sprache noch eine Zeitzone festgelegt. Erst beim ersten Login in OWA werden sie danach gefragt. Verwendet man kein OWA, kann es sein, dass die Postfachordner falsch benannt sind, also "Inbox" statt "Posteingang" etc.

Mittels PowerShell kann man diese Einstellungen für alle Benutzer festlegen.

Beim ersten Login eines Benutzers in OWA erscheint der Einrichtungsassistent trotzdem noch. Habe noch keine Möglichkeit gefunden, diesen zu deaktivieren. Aber so stimmen im Outlook nun die Ordnernamen, auch ohne vorheriges OWA-Login.

Die Kommandos lassen sich auch bei einem Exchange-Server verwenden. Da kann dann die Verbindungsherstellung weg gelassen werden.

Weitere Infos unter: https://nexcon.ch/2017/01/23/office-365-zeitzone-und-sprache-fuer-alle-benutzer-festlegen/
