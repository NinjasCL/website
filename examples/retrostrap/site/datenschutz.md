---
layout: base.njk
title: Datenschutz
mainClass: site-prose
description: "Datenschutzerklärung für retrostrap.dev und Retrospace. Privacy policy, with an English summary at the end."
---

# Datenschutzerklärung

Stand: 25. August 2026

## Der kurze Teil

Wir betreiben diese Seiten wie 1999, auch beim Datenschutz: keine Analyse-Tools, keine Werbenetzwerke, keine Tracking-Pixel, kein Fingerprinting, keine Weitergabe deiner Daten für fremde Zwecke. Wir erheben nur, was die jeweilige Funktion wirklich braucht, und löschen, was wir nicht mehr brauchen. Der Rest dieser Seite führt das im Detail aus.

## Verantwortlicher

<p><strong>vorausgedacht.at e.U.</strong><br>
Inhaber: Mag. Stefan Gündhör<br>
Steinfeld 7<br>
4213 Unterweitersdorf<br>
Österreich</p>

E-Mail: <a href="mailto:info@vorausgedacht.at">info@vorausgedacht.at</a>

Für jedes Datenschutzanliegen genügt eine formlose E-Mail an diese Adresse.

## Die Website (retrostrap.dev)

Die Dokumentationsseiten und Demos sind statische Dateien. Sie setzen keine Cookies, verlangen kein Konto und laden nichts von fremden Servern.

Wählst du auf der Seite ein Theme oder den Komfort-Modus, merkt sich dein Browser diese Einstellung im localStorage: auf deinem Gerät, nur dort. Sie wird an niemanden übertragen, auch nicht an uns.

Zum Hosting bei AWS siehe unten unter "Empfänger und Auftragsverarbeiter". Beim Betrieb fallen dort technische Diagnoseprotokolle der Serverless-Funktionen an (Start, Laufzeit, Fehlermeldungen). Unsere Software schreibt keine IP-Adressen und keine Nutzungsprofile in diese Protokolle, sie werden nach sieben Tagen automatisch gelöscht, und Zugriffsprotokolle des CDN haben wir nicht aktiviert.

## Gästebuch und Besucherzähler

Der Besucherzähler zählt Seitenaufrufe, keine Menschen: keine IP-Adresse, kein Browser-Merkmal, kein Identifikator, nur eine Zahl je Seite.

Ins Gästebuch schreibst du selbst, was erscheinen soll: einen Namen (oder keinen, dann steht dort "Guest"), optional einen Ort und eine Homepage-Adresse, und deine Nachricht; dazu speichern wir den Zeitpunkt des Eintrags. Einträge sind sofort öffentlich. Eine IP-Adresse wird nicht gespeichert. Rechtsgrundlage: Art 6 Abs 1 lit b DSGVO (du bittest um die Veröffentlichung deines Eintrags). Einträge bleiben stehen, bis du ihre Löschung verlangst; eine E-Mail genügt.

## Retrospace (das Verzeichnis)

Das Verzeichnis kommt ohne Personenbezug aus: Stöbern und Suchen laufen in deinem Browser über eine statische Liste, und die Toplist zählt Klicks, nicht Personen (keine IP, kein Identifikator).

Reichst du eine Website ein, übermittelst du: URL, Titel, Kurzbeschreibung, Kategorien, Sprachen und Schlagworte. Namen oder E-Mail-Adressen fragen wir nicht ab. Die Einreichung wird als öffentlich einsehbares Issue in unserem GitHub-Repository angelegt; dort prüft sie ein Mensch. Was du einreichst, wird damit öffentlich, reich also nur ein, was öffentlich sein darf. Rechtsgrundlage: Art 6 Abs 1 lit b DSGVO.

## Empfänger und Auftragsverarbeiter

Wir geben Daten nur an die Dienstleister weiter, ohne die der Betrieb nicht geht, jeweils auf Grundlage eines Auftragsverarbeitungsvertrags (Art 28 DSGVO):

- **Amazon Web Services EMEA SARL**, 38 Avenue John F. Kennedy, L-1855 Luxemburg: Hosting, Speicherung und Auslieferung (S3, CloudFront, Lambda, DynamoDB). Gespeichert und verarbeitet wird in einer EU-Region; die Auslieferung über das CDN nutzt Edge-Standorte in Europa und Nordamerika. Grundlage für Übermittlungen in die USA sind der AWS-Auftragsverarbeitungsvertrag mit EU-Standardvertragsklauseln sowie die Zertifizierung von Amazon unter dem EU-US Data Privacy Framework.
- **GitHub, Inc.**, 88 Colin P. Kelly Jr. Street, San Francisco, CA 94107, USA: nimmt Retrospace-Einreichungen als Issues entgegen (siehe oben). GitHub ist unter dem EU-US Data Privacy Framework zertifiziert.

Darüber hinaus geben wir Daten nur weiter, wenn uns ein Gesetz dazu verpflichtet.

## Deine Rechte

Du hast nach der DSGVO das Recht auf Auskunft (Art 15), Berichtigung (Art 16), Löschung (Art 17), Einschränkung der Verarbeitung (Art 18), Datenübertragbarkeit (Art 20) und Widerspruch (Art 21). Eine erteilte Einwilligung kannst du jederzeit widerrufen (Art 7 Abs 3). Eine formlose E-Mail an info@vorausgedacht.at genügt; wir antworten binnen eines Monats.

Wenn du meinst, dass wir deine Daten rechtswidrig verarbeiten, kannst du dich bei der Aufsichtsbehörde beschweren: Österreichische Datenschutzbehörde, Barichgasse 40-42, 1030 Wien, [dsb.gv.at](https://www.dsb.gv.at/).

## Was es hier nicht gibt

Keine Analyse- oder Statistik-Tools, keine Werbung, keine Tracking-Pixel, keine Social-Media-Einbettungen, keine Schriften von fremden Servern, kein Profiling, keine automatisierte Entscheidungsfindung. Unsere "Statistik" ist der Blick in die eigene Datenbank: Einträge pro Woche, mehr wissen wir nicht, und mehr wollen wir nicht wissen.

## Änderungen

Ändert sich etwas an dieser Erklärung, etwa weil ein neuer Dienst dazukommt, aktualisieren wir diese Seite und das Datum oben.

---

## English summary

The German text above is the operative privacy policy; this is a courtesy summary.

- The docs site is static: no cookies, no accounts, no trackers. Your theme choice lives in your browser's localStorage and never leaves your device. We enable no CDN access logs; the serverless diagnostics contain no IP addresses and are deleted after seven days.
- The guestbook stores only what you type plus a timestamp, no IP; the hit counter stores a number, never an identifier. Retrospace submissions (URL, title, blurb, categories, languages, tags) become a public GitHub issue; the toplist counts clicks, not people.
- Processors: AWS (EU storage region; DPA with standard contractual clauses; EU-US Data Privacy Framework) and GitHub. Supervisory authority: the Austrian Datenschutzbehörde, Barichgasse 40-42, 1030 Wien, dsb.gv.at. Contact: info@vorausgedacht.at.
