# Tetracyclin-Toxikogenomik — Ausführliche Anleitung & Dokumentation für Einsteiger

RNA-Sequenzierungs-Analyse von Rattenleber nach 4-tägiger Hochdosis-Tetracyclin-Behandlung.
Datensatz: **GSE144219** (Rx-TGx, Merck & Co., 2020), Han Wistar Männchen, 600 mg/kg pro Tag, 3 behandelte vs. 3 Kontrolltiere.

---

# Teil 0: Was machen wir hier eigentlich?

Bevor wir auf irgendeinen Knopf in Galaxy drücken, lohnt es sich, das große Bild zu verstehen. Wenn dieser Teil zu langsam ist, überspring ihn und komm später zurück.

## 0.1 Worum geht es in dieser Studie?

Tetracyclin ist ein Antibiotikum, das seit den 1950er-Jahren im Einsatz ist. Es tötet Bakterien, indem es deren Proteinfabriken (die Ribosomen) blockiert — die Bakterien können keine neuen Proteine mehr bauen und vermehren sich nicht mehr.

Das Problem: Unsere Mitochondrien — die Energiekraftwerke jeder Körperzelle — stammen evolutionär gesehen von eingewanderten Bakterien ab. Ihre Ribosomen sind den bakteriellen Ribosomen so ähnlich, dass Tetracyclin sie ebenfalls trifft, wenn es in hoher Konzentration vorliegt. Das führt zu einer ganzen Kaskade von Problemen, vor allem in der Leber, weil die Leber alle Medikamente filtert und entgiftet.

Diese Studie wurde 2020 von Merck als Teil ihres internen Toxikologie-Programms durchgeführt. Sie haben Ratten 4 Tage lang eine sehr hohe Dosis Tetracyclin (600 mg pro Kilogramm Körpergewicht) verabreicht und danach analysiert, welche Gene in der Leber an- und ausgeschaltet wurden. Unsere Aufgabe ist es, diese Rohdaten neu zu analysieren und biologisch zu interpretieren.

**Wichtige Quellenangabe**: Der Datensatz `GSE144219`, den wir verwenden, gehört zu einer viel größeren publizierten Studie:

> Podtelezhnikov A.A., Monroe J.J., Aslamkhan A.G., Pearson K., Qin C., Tamburino A.M., Loboda A.P., Glaab W.E., Sistare F.D., Tanis K.Q. (2020). **Quantitative Transcriptional Biomarkers of Xenobiotic Receptor Activation in Rat Liver for the Early Assessment of Drug Safety Liabilities.** *Toxicological Sciences* 175(1):98–112. DOI: [10.1093/toxsci/kfaa026](https://doi.org/10.1093/toxsci/kfaa026)

In dieser Publikation hat Merck **120 verschiedene pharmazeutische Wirkstoffe** in Rattenleber-RNA-seq getestet und daraus ein interpretatives Framework von **9 kanonischen transkriptionellen Signaturen** abgeleitet (siehe Abschnitt 2.2.9 und 2.3.3 dieses Dokuments). Wir analysieren nur einen kleinen Ausschnitt dieser Daten (die Tetracyclin-Gruppe + Kontrollen), nutzen aber das publizierte Framework, um unsere Befunde mechanistisch einzuordnen. Diese Referenz solltest du in Methoden und Diskussion deines Reports prominent zitieren — sie ist deine wichtigste methodische Bezugsquelle.

## 0.2 Was ist Toxikogenomik?

**Toxikogenomik** ist die Kombination aus Toxikologie (wie wirken Gifte und Medikamente auf den Körper?) und Genomik (wie verhalten sich die Gene in einer Zelle?).

Die zentrale Idee: Statt zu warten, bis ein Tier krank wird oder ein Organ sichtbar geschädigt ist, schauen wir uns an, **welche Gene** in den Zellen plötzlich anders aktiv sind. Lange bevor die Leber pathologisch verändert aussieht, schaltet sie Notfall-, Reparatur- und Stressantwort-Gene an. Diese frühen molekularen Signale verraten uns:

- **Welcher Mechanismus** hinter der Wirkung steckt (warum macht dieses Medikament Probleme?),
- **Welche Organfunktionen** gestört werden (Energiestoffwechsel? Entgiftung? Entzündung?),
- **Wie schwer** die Schädigung ist (wenige veränderte Gene = mild, viele veränderte Gene = drastisch).

Das ist gerade für die Pharmaindustrie wichtig: bevor ein neues Medikament an Menschen getestet wird, will man wissen, welche Risiken es birgt.

## 0.3 Das zentrale Dogma: DNA → RNA → Protein

Damit die ganze Analyse Sinn ergibt, hier kurz die molekularbiologischen Grundlagen:

**DNA** ist der genetische Bauplan. Jede Zelle deines Körpers hat in ihrem Kern eine vollständige Kopie aller ~20.000 menschlichen Gene (bei Ratten sind es ähnlich viele). Die DNA ist wie eine Bibliothek, in der **alle** Bücher (= Gene) stehen — auch die, die du gerade nicht brauchst.

**RNA** ist die Arbeitskopie. Wenn eine Zelle ein bestimmtes Gen "benutzen" will, kopiert sie es vom DNA-Original in viele kleine RNA-Moleküle (genauer: **messenger RNA**, mRNA). Diese mRNAs sind also die "Auflage" eines Gens — wie oft wird das Buch gerade gelesen?

**Protein** ist das Endprodukt. mRNAs werden in den Ribosomen in Proteine übersetzt, und Proteine machen die eigentliche Arbeit in der Zelle: Enzyme, Strukturen, Signalmoleküle, Transporter.

**Genexpression** = wie viele mRNA-Kopien eines Gens es gerade gibt. Ein Gen, das stark "exprimiert" ist, hat viele mRNAs; ein Gen, das "ausgeschaltet" ist, hat fast keine.

**Wenn Tetracyclin in eine Leberzelle gelangt**, ändert sich nicht die DNA — die Bibliothek bleibt gleich. Aber die Zelle reagiert, indem sie bestimmte Gene plötzlich öfter kopiert (mehr mRNA) und andere weniger. Diese Veränderung im mRNA-Pool **ist** das Signal, das wir messen.

## 0.4 Was ist RNA-Sequenzierung (RNA-seq)?

RNA-seq ist die Technologie, mit der wir messen, **wie viele mRNAs jeder Sorte** gerade in einer Probe vorliegen. Stell es dir so vor:

1. **Probennahme**: Aus einem Stück Leber wird die gesamte RNA extrahiert. Das sind Milliarden mRNA-Moleküle, alle gemischt.
2. **Library-Prep**: Die mRNAs werden in kleine Fragmente zerlegt (~150 Basenpaare), an den Enden mit Adaptern versehen und in **cDNA** (komplementäre DNA, weil DNA stabiler ist als RNA) umgeschrieben. Das Ergebnis heißt **Library** — eine Sammlung von Millionen kurzer DNA-Stücke, die alle die ursprünglichen mRNAs widerspiegeln.
3. **Sequenzierung**: Die Library wird auf einen Sequencer geladen (hier: Illumina HiSeq 2000). Der Sequencer liest pro Stück die Buchstabenabfolge — also die genetischen Buchstaben A, T, G, C. Jede solche gelesene Sequenz heißt ein **Read**.
4. **Output**: Pro Probe entstehen typisch 20–50 Millionen Reads. Jeder Read ist ~100–150 Buchstaben lang. Diese Reads werden in einer Textdatei abgelegt: dem **FASTQ-Format**.

**Eine wichtige Analogie**: Stell dir vor, du willst herausfinden, welche Themen in einer Bibliothek gerade besonders gefragt sind. Du gehst hinein, reißt aus jedem ausgeliehenen Buch einen zufälligen Absatz, schneidest die Absätze in kleine Schnipsel, mischst alles in einem Eimer und ziehst dann 30 Millionen Schnipsel heraus. Wenn du am Ende auswertest, von welchem Buch jeder Schnipsel stammt, weißt du, welche Bücher (= Gene) gerade häufig gelesen wurden.

RNA-seq ist genau das.

## 0.5 Der Gesamtablauf: was vor uns liegt

Die Rohdaten sind diese 30 Millionen Schnipsel pro Probe — als FASTQ-Dateien. Wir müssen jetzt:

1. **Schnipsel zurück ins Buch einsortieren** (= Reads aufs Genom mappen, "Alignment").
2. **Pro Buch zählen, wie viele Schnipsel reingehören** (= Reads pro Gen zählen, "Counting").
3. **Vergleichen, welche Bücher in den behandelten Bibliotheken anders oft gelesen werden als in den Kontroll-Bibliotheken** (= Differential Expression Analysis, DEA).
4. **Themen statt einzelner Bücher anschauen** (= Gene Set Enrichment, GSEA) — zum Beispiel "alle Bücher über Mitochondrien" oder "alle Bücher über Fettsäure-Abbau".
5. **Mit dem Vorwissen über Tetracyclin abgleichen**: Passen die Ergebnisse zu dem, was wir aus der Pharmakologie wissen?

**Warum zwei Tools (Galaxy und R)?**
Die Schritte 1 und 2 (Alignment und Counting) sind sehr rechenintensiv: Jede FASTQ-Datei ist mehrere Gigabyte groß. Galaxy ist ein webbasiertes System, das große Rechenserver bereitstellt — du musst nichts auf deinem eigenen Rechner installieren oder ausführen, alles läuft in der Cloud.

Die Schritte 3–5 (statistische Analyse, Visualisierung, Interpretation) arbeiten mit der viel kleineren Count-Tabelle (ein paar Megabyte). Hier wird R verwendet — die Standard-Sprache für statistische Genomanalyse. Die spezialisierten Pakete (edgeR, RUVSeq, multiGSEA) gibt es nur dort in der nötigen Qualität.

## 0.6 GEO und SRA: woher die Daten kommen

**GEO** (Gene Expression Omnibus, https://www.ncbi.nlm.nih.gov/geo/) ist eine öffentliche Datenbank der amerikanischen National Institutes of Health (NIH). Jede publizierte Genexpressions-Studie muss ihre Daten dort hinterlegen — das ist Pflicht für die meisten wissenschaftlichen Zeitschriften. Eine Studie heißt **GSE** (z. B. GSE144219), eine einzelne Probe innerhalb der Studie heißt **GSM**.

**SRA** (Sequence Read Archive, https://www.ncbi.nlm.nih.gov/sra/) ist die zugehörige Datenbank für die Rohdaten — also die FASTQ-Dateien selbst. Jede sequenzierte Probe in SRA hat:
- einen **SRX**-Identifier (Experiment, also was wurde gemacht),
- einen oder mehrere **SRR**-Identifier (Run, also die tatsächliche Sequenzierungs-Ausführung).

Die Zuordnung sieht so aus:
```
GSE144219 (= ganze Studie)
   |
   ├── GSM4283621 (= Probe 1 in GEO)
   |       └── SRX7678943 (= zugehöriges SRA-Experiment)
   |               └── SRR... (= die FASTQ-Datei, die wir wirklich brauchen)
   |
   ├── GSM4283622 ...
   └── ...
```

Galaxy spricht direkt mit SRA — wir geben ihm die SRR-Nummern, und es lädt die FASTQ-Dateien herunter.

---

# Teil 1: Galaxy — Klick für Klick

In diesem Abschnitt klären wir konkret, wo du in Galaxy was anklickst. Galaxy ist eine Web-Oberfläche; du brauchst nichts zu installieren.

## 1.1 Die Galaxy-Oberfläche verstehen

Wenn du **https://usegalaxy.eu** öffnest und eingeloggt bist, siehst du drei Hauptbereiche:

- **Links**: das **Tool-Panel**. Hier sind alle bioinformatischen Werkzeuge alphabetisch und nach Kategorie sortiert. Oben gibt es eine Suchleiste. Tipp: einfach Stichwörter wie "fastqc" oder "hisat" eintippen, dann erscheint das passende Tool sofort.
- **Mitte**: die **Arbeitsfläche**. Hier öffnet sich das aktuell ausgewählte Tool mit seinen Eingabefeldern. Hier siehst du auch Vorschauen von Ergebnissen, Reports und Plots.
- **Rechts**: die **History**. Das ist die Sammlung aller Daten und Analyse-Ergebnisse, die zu deinem aktuellen Projekt gehören. Jeder Schritt erzeugt einen neuen Eintrag in der History.

**Farb-Code der History-Einträge**:
- **Grau** = noch in der Warteschlange
- **Gelb** = wird gerade berechnet
- **Grün** = fertig, Erfolg
- **Rot** = fehlgeschlagen (klick draufklick → "Bug Report" oder Logs anschauen)

Wenn ein Schritt grün ist, kannst du auf ihn klicken, um die Daten anzusehen, herunterzuladen oder als Input für den nächsten Schritt zu verwenden.

## 1.2 Schritt 1: Account anlegen

1. **https://usegalaxy.eu** im Browser öffnen.
2. Oben rechts auf **Login or Register** klicken.
3. **Register here** wählen.
4. Eine E-Mail-Adresse eintragen (am besten eine, die du regelmäßig liest, denn ein Bestätigungslink kommt). Passwort vergeben.
5. In der Bestätigungsmail auf den Link klicken — fertig.
6. Wieder auf usegalaxy.eu gehen und einloggen.

Du hast jetzt ein kostenloses Konto mit **250 GB Speicher**. Für unsere sechs Proben (jede FASTQ ist ~2–5 GB groß) reicht das locker.

## 1.3 Schritt 2: Eine History anlegen

Galaxy organisiert deine Arbeit in **Histories** — eine History ist eine Art Projektordner. Für dieses Projekt legen wir eine eigene an.

1. Rechts oben über der History-Liste das **Zahnrad-Symbol** suchen.
2. **Create new** klicken.
3. Die neue History erscheint mit dem Titel "Unnamed history". Auf den Titel klicken und in `tetracycline_TGx` umbenennen.

Wenn du später zwischen Histories wechseln willst: Zahnrad → **Switch to history**.

## 1.4 Schritt 3: Die SRR-IDs heraussuchen

Bevor wir Daten herunterladen, brauchen wir die Run-Accession-Nummern (SRR-IDs). Die einfachste Methode:

1. Im Browser öffnen: **https://www.ncbi.nlm.nih.gov/Traces/study/?acc=GSE144219**
2. Du siehst eine Tabelle aller Sequenzierungs-Runs in der Rx-TGx-Studie.
3. Im Filter-Panel links findest du den Filter **compound** oder **treatment**. Wähle `tetracycline`.
4. Du solltest jetzt deutlich weniger Zeilen sehen. Suche die, die zu deinen sechs GSM-Nummern gehören. Die Spalte **GEO_Accession** oder **Sample Name** hilft beim Mapping.
5. Hake die richtigen Zeilen ab.
6. Oben gibt es einen Button **Accession List**. Klick darauf — eine Textdatei `SRR_Acc_List.txt` wird heruntergeladen.

Falls der Sample-Filter nicht funktioniert oder zu unübersichtlich ist, kannst du auch einzeln klicken: Auf jede GSM-Seite (z. B. https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM4283625), dort unter "Relations" auf den SRA-Link, und auf der SRA-Seite die SRR-Nummer notieren.

**Notiere dir auf jeden Fall** eine kleine Tabelle wie:

| GSM | SRX | SRR | Treatment |
|---|---|---|---|
| GSM4283621 | SRX7678943 | SRR(...) | control |
| GSM4283622 | SRX7678944 | SRR(...) | control |
| GSM4283623 | SRX7678945 | SRR(...) | control |
| GSM4283625 | SRX7678947 | SRR(...) | tetracycline |
| GSM4283626 | SRX7678948 | SRR(...) | tetracycline |
| GSM4283627 | SRX7678949 | SRR(...) | tetracycline |

Diese Tabelle ist **kritisch**. Galaxy benennt die Dateien später nach SRR-Nummern, aber du musst in der R-Analyse die Zuordnung "welche SRR ist welche Behandlungsbedingung?" kennen. Eine Verwechslung hier macht alle weiteren Ergebnisse falsch.

## 1.5 Schritt 4: FASTQ-Dateien aus SRA herunterladen

1. Im Tool-Panel links in die Suchleiste tippen: `Faster Download and Extract Reads`.
2. Das Tool **"Faster Download and Extract Reads in FASTQ format from NCBI SRA"** anklicken.
3. In der Mitte erscheint die Tool-Konfiguration. Bei **select input type** "list of SRA accession, one per line" wählen.
4. In das Eingabefeld die sechs SRR-IDs schreiben (jede in eine eigene Zeile). Alternativ: die heruntergeladene `SRR_Acc_List.txt` über **Upload data** (oben links, Wolken-Symbol) hochladen und als Dataset auswählen.
5. Auf **Run Tool** klicken.

In der History rechts erscheinen jetzt mehrere neue Einträge — anfangs grau, dann gelb, dann (hoffentlich) grün. Pro Probe dauert das **20 Minuten bis 1 Stunde**, manchmal länger bei Server-Auslastung. Du musst nicht warten — du kannst den Browser schließen, einkaufen gehen, am nächsten Tag wiederkommen. Galaxy rechnet im Hintergrund weiter.

**Was du am Ende hast**: pro Probe eine FASTQ-Datei. Wenn die Sequenzierung **paired-end** war (was bei TruSeq Stranded mRNA üblich ist), bekommst du **zwei** FASTQ-Dateien pro Probe — eine mit dem Suffix `_1` (Forward Reads) und eine mit `_2` (Reverse Reads). Das liegt daran, dass beim paired-end Sequencing jedes Fragment von beiden Enden gelesen wird. Bei single-end gibt es nur eine Datei.

## 1.6 Schritt 5: Eine "Dataset Collection" anlegen

Mit 6–12 Dateien wird die History schnell unübersichtlich. Außerdem müsstest du jedes Tool sechsmal manuell starten. **Collections** sind die Lösung: sie bündeln Dateien, so dass Tools automatisch über alle iterieren.

1. Rechts in der History, oben über der Liste, gibt es eine kleine **Checkbox-Schaltfläche** (manchmal "Operations on multiple datasets" genannt).
2. Anklicken. Jetzt erscheinen Checkboxen neben jedem Eintrag.
3. Alle FASTQ-Dateien anhaken.
4. Oben **For all selected...** klicken → bei paired-end: **Build List of Dataset Pairs**, bei single-end: **Build Dataset List**.
5. Bei Pairs öffnet sich ein Dialog, der versucht, `_1` und `_2` automatisch zu paaren. Wenn die Erkennung sauber ist, siehst du sechs Paare. Notfalls per Hand zuordnen.
6. Der Collection einen Namen geben, z. B. `raw_fastq_pairs`.
7. **Create list** klicken.

In der History erscheint jetzt **ein** Eintrag (statt zwölf), der die ganze Collection repräsentiert. Du kannst ihn aufklappen, um die einzelnen Proben zu sehen.

## 1.7 Schritt 6: Qualitätskontrolle mit FastQC

Bevor wir alignieren, müssen wir prüfen, ob die Rohdaten überhaupt gut genug sind. **FastQC** liest jede FASTQ-Datei und erzeugt einen Bericht mit etwa einem Dutzend Kennzahlen über die Daten-Qualität.

1. Tool-Panel: `FastQC` suchen → **FastQC Read Quality reports**.
2. **Raw read data from your current history**: hier deine Collection `raw_fastq_pairs` wählen.
3. Auf **Run Tool** klicken.

Pro Probe (bzw. pro Read in einem Paar) entstehen zwei Outputs: ein **HTML-Report** (zum Anschauen im Browser) und ein **RawData**-Output (für die spätere Aggregation). Bei paired-end-Daten entsteht also pro Probe vier mal Output (2 Files × 2 Outputs).

Du kannst auf einen HTML-Eintrag in der History klicken und dann auf das **Auge** (View data), um den Report direkt im Browser zu sehen.

## 1.8 Schritt 7: MultiQC — alle Reports aggregieren

Sechs FastQC-Reports einzeln anzuschauen ist mühsam. **MultiQC** fasst sie zu einem einzigen Übersichts-Report zusammen.

1. Tool-Panel: `MultiQC` suchen → **MultiQC**.
2. **Which tool was used generate logs?** → `FastQC` auswählen.
3. **FastQC output**: hier die **RawData**-Outputs aus dem FastQC-Schritt einspielen (nicht die HTML-Files!).
4. **Run Tool** klicken.

Wenige Sekunden später hast du einen einzelnen HTML-Report mit allen Proben in einer Übersicht.

### Was du im MultiQC-Report siehst und wie du es interpretierst

Klick im Report die wichtigsten Abschnitte durch:

**Sequence Quality Histograms**: Eine Kurve pro Probe, X-Achse = Position im Read (1 bis ~150), Y-Achse = mittlerer Quality Score. Die Linie sollte überwiegend im **grünen Bereich** (Phred ≥ 28) liegen. Am Read-Ende fällt sie meist etwas ab — normal. Wenn sie schon nach Position 30 unter 20 abstürzt: Probe ist defekt.

**Per Sequence GC Content**: Häufigkeit der GC-Gehalte über alle Reads. Sollte eine **einzige Glockenkurve** sein, beim Erwartungswert für Rattenleber (ca. 42–45 %). **Doppelgipfel** sind ein Warnsignal — bedeutet, dass die Probe mit einem anderen Organismus (Bakterien, Hefen) kontaminiert ist oder zwei sehr unterschiedliche RNA-Populationen enthält.

**Sequence Duplication Levels**: Wie oft tauchen identische Reads mehrfach auf? Bei RNA-seq ist **hohe Duplikation normal** und sogar erwünscht — sie kommt von hochexprimierten Genen wie ribosomalen Proteinen. FastQC markiert das oft rot, aber bei RNA-seq darf man das ignorieren.

**Overrepresented Sequences**: Liste der häufigsten exakten Sequenzen. Wenn hier Adapter-Sequenzen auftauchen → Trimming nötig. Wenn rRNA-Sequenzen dominieren → die mRNA-Anreicherung im Library-Prep hat nicht geklappt.

**Adapter Content**: Kurve, die zeigt, ab welcher Position im Read der Sequenzer in den Adapter "hineingelesen" hat. Wenn die Kurve nach Position 100 stark ansteigt: Trimming aktivieren.

**Per Base N Content**: "N" bedeutet, der Sequenzer konnte die Base nicht eindeutig bestimmen. Sollte nahe 0 % bleiben.

**Allgemein**: Wenn die Mehrheit der Metriken grün ist und keine systematischen Probleme auftauchen, sind die Daten gut genug für die Analyse.

## 1.9 Schritt 8: (Optional) Trimming

**Wenn** der MultiQC-Report Adapter oder schlechte Tail-Qualität anzeigt: Adapter-Sequenzen entfernen und schlechte Read-Enden abschneiden. **Trim Galore!** ist eines der einfachsten Tools dafür.

1. Tool-Panel: `Trim Galore` suchen.
2. **Is this paired-end?** entsprechend einstellen.
3. **Input**: die Raw-FASTQ-Collection.
4. **Adapter sequence to be trimmed**: bei TruSeq automatisch erkannt; sonst manuell `AGATCGGAAGAGC` eingeben.
5. **Quality trimming**: Default-Wert (20) ist okay.
6. **Minimum length**: 20 (Reads kürzer als 20 bp werden verworfen).
7. **Run Tool**.

Output: eine neue Collection mit getrimmten FASTQ-Dateien.

**Falls** der MultiQC-Report sauber war, kannst du diesen Schritt überspringen und mit den ungetrimmten Daten weiterarbeiten.

## 1.10 Schritt 9: Alignment mit HISAT2

Jetzt der eigentlich rechenintensive Schritt: jeden Read auf das Rattengenom mappen, also herausfinden, **wo im Genom** dieser Read herkommt.

1. Tool-Panel: `HISAT2` suchen → **HISAT2 — A fast and sensitive alignment program**.
2. **Source for the reference genome**: `Use a built-in genome index` wählen.
3. **Select a reference genome**: in der Dropdown-Liste suchen: `Rat (Rattus norvegicus): rn6` — **rn6** ist eine andere Bezeichnung für **Rnor_6.0**, also genau das Genom, das in der Originalstudie verwendet wurde.
4. **Is this single or paired library**:
   - Bei paired-end: "Paired-end Dataset Collection" → deine getrimmte (oder Raw-) Collection wählen.
   - Bei single-end: entsprechend.
5. **Spliced alignment options**: Die Defaults sind in Ordnung.
6. **Summary Options** → **Output alignment summary**: aktivieren. Diese Datei brauchen wir gleich für die zweite MultiQC-Runde.
7. **Run Tool**.

**Erwartete Laufzeit**: 30 Minuten bis ein paar Stunden pro Probe, abhängig von Server-Last. Du musst nicht zuschauen.

**Output**: pro Probe eine **BAM-Datei**. BAM ist das binäre Speicherformat für alignierte Reads. Es enthält pro Read die Information: wo im Genom, auf welchem Strang, mit welcher Übereinstimmung. Außerdem eine **Alignment-Summary** mit Statistiken (wie viele Reads konnten aligniert werden? wie viele Multi-Mapper?).

## 1.11 Schritt 10: Alignment-Qualität nochmal prüfen

Bevor wir die alignierten Reads zählen, lassen wir MultiQC nochmal über die Alignment-Summaries laufen:

1. Tool **MultiQC** öffnen.
2. **Which tool was used** → `HISAT2`.
3. **HISAT2 alignment log**: die Summary-Outputs aus dem HISAT2-Schritt einspielen.
4. **Run Tool**.

Im Report siehst du pro Probe die **Overall Alignment Rate**. Bei sauberen Rattenleber-Daten erwarten wir **80–95 %**. Wenn eine Probe deutlich darunter liegt (z. B. 60 %): genauer hinschauen. Mögliche Ursachen:
- Kontamination mit anderem Organismus,
- viele rRNA-Reads (die mappen woanders hin als erwartet),
- falsche Genom-Version.

Wenn alle Proben über 80 % liegen: weitermachen.

## 1.12 Schritt 11: Reads pro Gen zählen mit featureCounts

Wir haben jetzt BAMs, in denen jeder Read auf eine Genom-Position aligniert ist. Aber wir wollen ja **Gen-Zählungen**: "Gen X hat 5.000 Reads, Gen Y hat 23 Reads". Dafür braucht featureCounts zusätzlich eine **Gen-Annotation** (eine GTF-Datei), die sagt, wo welches Gen im Genom liegt.

1. Tool-Panel: `featureCounts` suchen → **featureCounts**.
2. **Alignment file**: deine HISAT2-BAM-Collection.
3. **Gene annotation file**: hier hast du zwei Optionen:
   - **Built-in**: für `rn6` gibt es eine eingebaute GTF. Schneller Weg, gut genug für den Einstieg.
   - **Eigene GTF**: von Ensembl die R94-GTF herunterladen (https://ftp.ensembl.org/pub/release-94/gtf/rattus_norvegicus/), in Galaxy hochladen und auswählen. Das wäre exakt die GTF, mit der Merck im Original gearbeitet hat. Empfohlen, wenn man genau die gleichen Gen-IDs haben möchte.
4. **Output format**: tabular.
5. **Specify strand information**: **Stranded (Reverse)**. Das ist die korrekte Einstellung für TruSeq Stranded mRNA. **Diese Einstellung ist kritisch!** Falsche Strandedness führt dazu, dass etwa die Hälfte der Reads nicht gezählt wird — das Signal wird verwässert, und die DE-Analyse wird sinnlos.
6. **Paired-end data**: bei paired-end "yes" und **Count fragments instead of reads** aktivieren (sonst zählst du jedes Fragment doppelt).
7. **Run Tool**.

**Output pro Probe**: eine Tabelle mit Spalten `Geneid` und dem Sample-Namen (mit Count-Werten). Außerdem eine Summary mit Zähl-Statistiken.

## 1.13 Schritt 12: Counts-Tabellen zu einer Matrix kombinieren

Wir haben jetzt sechs einzelne Count-Tabellen — wir wollen eine einzige Matrix mit Genen als Zeilen und Proben als Spalten.

1. Tool-Panel: `Column Join` suchen → **Column Join on Collections** (oder ähnlich heißend).
2. **Identifier column**: 1 (die GeneID-Spalte).
3. **Number of header lines**: 1 oder 2 (in featureCounts-Output stehen oben ein paar Kommentar-Zeilen mit "#" — diese ausklammern).
4. **Run Tool**.

Output: eine kombinierte Datei mit:
```
Geneid  SRR123  SRR124  SRR125  SRR126  SRR127  SRR128
ENSRNOG00000000001  450  380  410  395  402  421
ENSRNOG00000000007  12   8    15   1    3    2
...
```

## 1.14 Schritt 13: Datei herunterladen

1. Auf die kombinierte Count-Tabelle in der History klicken.
2. Das **Disketten-Symbol** (Download) anklicken.
3. Datei lokal speichern. Empfohlener Name: `galaxy_featureCounts.tabular`. Sie wird später vom R-Skript geladen.

**Wichtig**: **Bevor du Galaxy schließt**, schau dir die Spaltennamen der Tabelle an (in Galaxy auf das **Auge** klicken zum Anzeigen). Sie sehen wahrscheinlich so aus wie `SRR12345678.bam` oder `SRR12345678`. **Notiere dir die Reihenfolge der Spalten** — du musst sie im R-Skript zur richtigen Behandlungsbedingung (control/tetracycline) zuordnen.

---

Damit ist die Galaxy-Phase abgeschlossen. Du hast aus 6 × 30 Millionen Roh-Reads eine Tabelle mit ~30.000 Zeilen (Genen) und 6 Spalten (Proben). Diese Tabelle ist der Input für die R-Analyse.

---

# Teil 2: Detaillierte Doku — was passiert in jedem Schritt?

In diesem Teil gehen wir alle Schritte nochmal durch — diesmal mit dem Fokus, **was technisch und biologisch passiert** und **warum**. Wenn du Stellen unklar findest, ist Nachfragen ausdrücklich erlaubt.

## 2.1 Die Galaxy-Phase im Detail

### A. SRA-Download — Rohdaten beschaffen

**Wofür ist das gut?** Die Rohdaten — also die FASTQ-Dateien — sind das Fundament jeder reproduzierbaren Analyse. Die in GEO hinterlegten "verarbeiteten" Count-Tabellen wurden mit OmicSoft Array Studio erzeugt, einer kommerziellen Software. Wir wissen nicht genau, mit welchen Parametern Merck damals gearbeitet hat. Wenn wir den FASTQ-Datensatz selbst alignieren und zählen, haben wir die volle Kontrolle und können später jeden Schritt reproduzieren.

**Was passiert technisch?** Die SRA-Datenbank speichert Reads in einem komprimierten, proprietären `.sra`-Format. Galaxy nutzt das Programm **fasterq-dump**, das diese Container in das Standard-FASTQ-Format umwandelt.

**Wie sieht FASTQ aus?** Jede Probe besteht aus Millionen Read-Einträgen mit jeweils vier Zeilen:
```
@SRR12345.1 HWI-ST123:1:1:1234:5678/1
ATCGGAATGCTAGCTGATCGATCAGCTAGCTAGCATCGATCGATCGATCG...
+
@@@FFDFFDFHJJHHHGIIJJJIJJJIJJIIIIJ@AABBBCCCCCD>:&;...
```
Zeile 1 ist ein eindeutiger Identifier. Zeile 2 ist die gelesene DNA-Sequenz (in Wirklichkeit cDNA aus mRNA). Zeile 3 ist nur ein Trennzeichen "+". Zeile 4 enthält den **Quality-Score** pro Base, kodiert als ASCII-Zeichen.

**Quality-Scores (Phred)** werden so übersetzt:
- Zeichen `!` (= Code 33) → Qualität 0 → Wahrscheinlichkeit für falsche Base = 1 (also 100 % Fehler — wertlos).
- Zeichen `?` (= Code 63) → Qualität 30 → Fehlerwahrscheinlichkeit = 0,001 (1 in 1000).
- Zeichen `I` (= Code 73) → Qualität 40 → Fehlerwahrscheinlichkeit = 0,0001 (1 in 10.000).

Formel: P(Fehler) = 10^(-Q/10). Moderne Illumina-Sequencer liefern Q30–Q40 für den Großteil der Reads.

### B. FastQC — die erste Qualitätssicherung

**Wofür ist das gut?** Bevor wir Stunden ins Alignment investieren, wollen wir wissen, ob die Daten überhaupt brauchbar sind. FastQC erkennt typische Probleme:
- defekte Sequenzierungs-Runs (Quality-Absturz),
- Kontamination (z. B. mit anderen Organismen),
- übrig gebliebene Adapter,
- Library-Prep-Probleme (z. B. fehlgeschlagene mRNA-Anreicherung).

**Was tut FastQC technisch?** Es liest die FASTQ-Datei sequentiell und führt etwa ein Dutzend statistische Tests durch:
- mittlere Qualität pro Position,
- GC-Verteilung,
- Adapter-Detektion durch Suche nach bekannten Adapter-Motiven,
- Detektion ungewöhnlich häufiger k-mere (kurze Sequenz-Bausteine),
- Schätzung der Library-Komplexität.

Für jeden Test gibt es eine grüne/gelbe/rote Ampel.

**Vorsicht bei RNA-seq**: Manche FastQC-"Warnungen" sind bei RNA-seq normal und kein Grund zur Sorge:
- **Hohe Sequence Duplication** ist erwartet — sie kommt von hochexprimierten Genen, die im Library-Prep dominant sind.
- **Verzerrte Per-Base Sequence Content** in den ersten 9–12 Basen kommt durch das "Random Hexamer Priming" im TruSeq-Protokoll — kein Defekt.

Was du wirklich vermeiden willst:
- Quality-Absturz in der Mitte des Reads (Probe war defekt),
- starke GC-Verzerrungen (Kontamination),
- viele Overrepresented Sequences, die rRNA sind (mRNA-Anreicherung fehlgeschlagen),
- hoher N-Anteil (Sequencer hatte Probleme).

### C. (Optional) Trimming — Adapter und schlechte Enden abschneiden

**Wofür?** Wenn das Insert (das mRNA-Fragment in der Library) kürzer war als die Read-Länge, liest der Sequencer in den Adapter hinein — die Read-Enden enthalten dann nicht mehr cDNA, sondern Adapter-Sequenz. Diese Reads alignieren schlechter (oder gar nicht). Außerdem fällt die Sequencing-Qualität am Read-Ende oft ab, weil die chemischen Reagenzien verbraucht sind.

**Was passiert technisch?** Programme wie **Cutadapt** oder **Trim Galore!** (das im Hintergrund Cutadapt benutzt):
1. Suchen am Read-Ende nach bekannten Adapter-Motiven (z. B. `AGATCGGAAGAGC` für TruSeq).
2. Schneiden alles ab dem Adapter weg.
3. Schneiden zusätzlich Bereiche mit Qualität unter einer Schwelle ab (Sliding-Window über z. B. 4 Basen, Mittelwert ≥ Q20).
4. Verwerfen Reads, die nach dem Trimming zu kurz sind (< 20 bp).

**Wann nötig?** Wenn die MultiQC-Berichte deutliche Adapter-Kontamination (>5 % am Read-Ende) zeigen. Bei modernen, sauberen Libraries oft entbehrlich.

### D. Alignment mit HISAT2 — Reads aufs Genom abbilden

**Wofür?** Wir wollen wissen, **woher** jeder Read kommt. Nur wenn wir die Position im Genom kennen, können wir später zählen, wie viele Reads zu jedem Gen gehören.

**Das Problem**: Das Rattengenom hat ~2,8 Milliarden Basenpaare. Pro Probe haben wir 20–50 Millionen Reads mit je ~150 bp. Das Ganze naiv durch brute force zu lösen wäre völlig undenkbar — wir bräuchten dafür Wochen pro Probe.

**Die Lösung — Indexstrukturen**: HISAT2 baut vorab einen **graph-FM-Index** des Genoms. Das ist eine clevere Datenstruktur, die ermöglicht, jeden Read in Millisekunden im Genom zu lokalisieren. Galaxy stellt diese vorgebauten Indizes für gängige Genome wie rn6 bereit, sodass wir nicht selbst basteln müssen.

**Wichtig bei RNA-seq — Spliced Alignment**: Eukaryotische Gene bestehen aus **Exons** (kodierende Abschnitte) und **Introns** (Bereiche, die in der reifen mRNA fehlen). Ein RNA-seq-Read, der über eine Exon-Exon-Grenze reicht, lässt sich nicht direkt aufs Genom mappen — er hat eine "Lücke" in der Mitte (wo das Intron weggespleißt wurde). HISAT2 kann solche **gespleißten Reads** korrekt platzieren — das ist sein Hauptvorteil gegenüber rein-genomischen Alignern wie BWA.

**Output: BAM-Datei**. BAM ist das binäre, komprimierte Format für Alignments. Pro Read enthält es:
- Position im Genom (Chromosom + Koordinate),
- Strang (Plus oder Minus),
- **CIGAR-String** — eine kompakte Beschreibung des Alignments (z. B. `75M2I73M` heißt: 75 Basen matchen, dann 2 Insertions, dann 73 weitere Matches),
- Mapping-Qualität (wie sicher ist die Zuordnung?),
- bei paired-end: Position des Partners.

**Typische Alignment-Rate für gute rat-liver-Daten**: 80–95 %. Wenn der Wert deutlich darunter liegt:
- Falsche Genom-Version? (z. B. Maus statt Ratte hochgeladen)
- Probe kontaminiert?
- rRNA dominiert (mRNA-Anreicherung im Library-Prep gescheitert)?
- Sehr stark degradiert?

### E. featureCounts — Reads pro Gen zählen

**Wofür?** Aus der Position jedes Reads im Genom + der Gen-Annotation (GTF) lässt sich ableiten, zu welchem Gen jeder Read gehört. featureCounts zählt diese Zuordnungen.

**Wie funktioniert es?** Pro Read prüft featureCounts:
1. Liegt der Read innerhalb der Koordinaten eines annotierten Gens?
2. Ist die Strand-Information konsistent? (Bei einer **stranded** Library muss der Read auf dem korrekten Strang liegen, sonst stammt er nicht von der mRNA dieses Gens.)
3. Überlappt der Read mit mehreren Genen? Wenn ja, wird er per Default verworfen ("ambiguous").

**Strandedness — der gefährlichste Parameter**:
- **Unstranded**: Sequencer weiß nicht, von welchem Strang die mRNA kam. Reads werden auf beiden Strängen gezählt. Üblich bei alten TruSeq-Kits.
- **Stranded (Forward)** = "fr-secondstrand": Erstellt z. B. mit dRNA-seq.
- **Stranded (Reverse)** = "fr-firststrand": **TruSeq Stranded mRNA** — das ist unser Fall.

Wenn du die falsche Strandedness wählst, ignorierst du ~50 % aller Reads. Das halbiert die Statistik und macht das Signal viel schwächer. **Bei Zweifel kannst du das mit dem Tool `infer_experiment.py` aus RSeQC empirisch checken**.

**Output**: eine Tabelle Gene × Sample mit ganzzahligen Counts. Das ist das Grundgerüst der gesamten R-Analyse.

## 2.2 Die R-Phase im Detail

Jetzt geht's um die Bioconductor-Pipeline. Bioconductor ist eine R-Erweiterung speziell für die Genomik — mit über 2.000 Paketen, von denen wir eine Handvoll nutzen.

### 1. Import in SummarizedExperiment

**Was ist ein SummarizedExperiment?** Das ist eine spezielle Datenstruktur, die alle Bestandteile eines Genomik-Experiments **gemeinsam und konsistent** verwaltet:
- `assays`: die eigentlichen Daten-Matrizen — bei uns: die Counts. Später kommen normalisierte Werte dazu.
- `colData`: die **Spalten-Metadaten**, also Informationen pro Probe: Sample-Name, Behandlung, Tier-ID, vielleicht Sex, RIN-Wert, usw.
- `rowData`: die **Zeilen-Metadaten**, also Informationen pro Gen: Symbol, Entrez-ID, Genname, Chromosom.

**Warum ist das wichtig?** Stell dir vor, du hast eine Count-Matrix und nebenher eine Excel-Tabelle mit Sample-Metadaten. Wenn du in der Matrix die Spalten umsortierst, vergisst du vielleicht, in der Excel-Tabelle auch umzusortieren — und schon hast du Sample-Vertauschungen. **SummarizedExperiment koppelt diese Datenebenen physikalisch**: wenn du Spalten subsettest, bewegen sich die Metadaten automatisch mit.

Sample-Vertauschungen sind die häufigste Fehlerquelle in der RNA-seq-Analyse. Sie sind nahezu unmöglich zu erkennen, wenn sie einmal passieren — die ganze Analyse läuft sauber durch und produziert falsche Ergebnisse. Die SE-Struktur ist die wichtigste vorbeugende Maßnahme.

**Konkrete Konstruktion in R**:
```r
se <- SummarizedExperiment(
  assays  = list(counts = counts_matrix),
  colData = sample_metadata,
  rowData = gene_metadata
)
```
Hinterher kannst du mit `se[, se$treatment == "control"]` auf alle Kontroll-Proben zugreifen, und die Counts-Matrix UND die Metadaten werden synchron gefiltert.

### 2. Gen-Annotation (Ensembl → Symbol → Entrez)

**Das Problem**: Die Galaxy-Gen-IDs sehen so aus: `ENSRNOG00000007897`. Das ist die **Ensembl-Gen-ID** — stabil, eindeutig, aber für Menschen unlesbar. Ein Plot mit ENSEMBL-IDs ist nutzlos.

**Was wir wollen**:
- **Symbol** (z. B. `Cyp1a1`) — für Heatmaps, Volcano-Plot-Labels, Reports.
- **Entrez-ID** (z. B. `24296`) — die andere große ID-Sammlung, die viele Pathway-Datenbanken (vor allem KEGG) verwenden.
- **Gen-Name** (volle Bezeichnung, z. B. `cytochrome P450 family 1 subfamily A member 1`) — für die Diskussion.

**Wie das Mapping funktioniert**: Das Paket `org.Rn.eg.db` ist eine SQLite-Datenbank für die Ratte, die diese ID-Übersetzungen speichert. Die Funktion `AnnotationDbi::select()` führt einen JOIN aus:
```r
annot <- AnnotationDbi::select(
  org.Rn.eg.db,
  keys     = ensembl_ids,
  keytype  = "ENSEMBL",
  columns  = c("SYMBOL", "ENTREZID", "GENENAME")
)
```

**Caveat**: Die Galaxy-Annotation basiert auf Ensembl Release 94 (von 2018). `org.Rn.eg.db` wird laufend aktualisiert. Manche Gen-IDs aus 2018 wurden seitdem verändert, zusammengelegt, oder zurückgezogen. Erwarte: **10–20 % der Gene haben kein Mapping**. Das ist okay — die wirklich wichtigen Gene (Cyps, Mrps, Hsps usw.) sind alle stabil annotiert.

### 3. Pre-Filtering — schwach exprimierte Gene rauswerfen

**Das Problem**: Im Genom sind ~30.000 Gene annotiert. Aber in einer bestimmten Probe sind vielleicht nur 14.000–17.000 davon nennenswert exprimiert. Die anderen sind aus oder so schwach an, dass sie nur 0–5 Reads pro Probe haben.

**Warum diese rauswerfen?** Drei Gründe:

1. **Statistische Power**. Wir machen am Ende einen statistischen Test pro Gen und müssen die p-Werte für Multiple Testing korrigieren (Benjamini-Hochberg). Je mehr Tests, desto strenger die Schwelle. Wenn 50 % der Tests sowieso keine Chance haben, signifikant zu werden, ziehen sie alle anderen mit nach unten. **Filtere die "toten" Gene raus, und die übrigen werden empfindlicher**.

2. **Statistische Annahmen**. edgeR/limma modellieren die Varianz als Funktion der mittleren Expression. Lowly-expressed Gene haben aber extreme relative Varianz (Poisson-Rauschen dominiert) und verzerren diese Modellierung.

3. **Biologische Plausibilität**. Ein Gen mit 0/0/1 in Kontrolle und 0/1/0 in Behandlung kann statistisch nicht von Zufall unterschieden werden. Solche Gene haben keine Aussagekraft.

**Wie funktioniert `filterByExpr`?** Die Funktion behält Gene, die in einer "ausreichenden" Anzahl Proben (mindestens die kleinste Gruppe, also 3) mindestens ~10 Reads haben. Die exakte Schwelle wird automatisch aus den Library-Größen abgeleitet. Bei rat-liver-Daten erwarten wir, dass ~14.000–17.000 Gene den Filter passieren.

### 4. Normalisierung mit TMM

**Das Problem mit naiven Counts**: Library-Größen variieren. Probe A hat 30 Mio. Reads, Probe B nur 18 Mio. Wenn ein Gen in beiden Proben 1.000 Reads hat, ist es relativ in B höher exprimiert (1000/18 vs. 1000/30). Wir müssen also normalisieren.

**Naive Lösung — einfach durch Library-Größe teilen**: das ergibt CPM (Counts per Million). Funktioniert in einfachen Fällen, hat aber eine fundamentale Schwäche bei **Composition Bias**.

**Was ist Composition Bias?** Stell dir vor, in der behandelten Gruppe ist ein einzelnes Gen extrem hochreguliert — sagen wir, ein Stress-Gen verbraucht plötzlich 30 % aller Reads. Alle anderen Gene haben dann in absoluter mRNA-Menge gleich viel Material wie in Kontrolle, aber durch das eine dominante Gen werden sie relativ "weggedrückt". Ihre CPM-Werte sinken künstlich, obwohl ihre wahre Expression unverändert ist.

**Die TMM-Lösung** (Trimmed Mean of M-values, Robinson & Oshlack 2010):
1. Vergleiche jede Probe mit einer Referenz-Probe (z. B. der "mittelmäßigsten").
2. Berechne pro Gen den log-Ratio (M-Wert) zwischen den beiden.
3. Schneide die extremsten M-Werte oben und unten weg (das sind genau die wirklich hoch- oder runter-regulierten Gene).
4. Der getrimmte Mittelwert der verbleibenden M-Werte ist der Skalierungsfaktor für diese Probe.

**Das Resultat**: Pro Probe ein `norm.factor` um 1 herum. Werte deutlich abweichend (z. B. 0,5 oder 2,0) sind ein Warnsignal — die Probe hat starke Composition Bias oder ist anders kaputt.

### 5. Exploratorische Datenanalyse — die vier Standard-Plots

Vor jeder formalen DE-Analyse: anschauen, ob die Daten überhaupt sinnvoll aussehen.

**Library-Sizes-Barplot**: Sechs Balken, einer pro Probe. Sind sie vergleichbar? Eine Probe mit halber Tiefe ist nicht automatisch tot, aber verdächtig. Eine Probe mit nur 1 Mio. Reads (vs. den anderen mit 30 Mio.) ist ein Problem.

**RLE-Plot (Relative Log Expression)**: Sechs Boxplots, einer pro Probe. Pro Gen berechnen wir den log-Wert relativ zum Median über alle Proben. Bei einer gut normalisierten Probe streuen diese log-Ratios eng um Null (= Median-IQR-Boxplot zentriert auf 0, schmal). Wenn eine Box deutlich verschoben ist (Median bei +0,5 oder -0,5): unwanted variation oder Normalisierungsproblem. Wenn eine Box stark verbreitert ist: Probe sehr verrauscht oder enthält viele Outlier-Gene.

**PCA-Plot**: Die Hauptkomponenten-Analyse reduziert ~16.000 Gene auf zwei zusammengefasste Achsen (PC1, PC2). Optimal: die drei Kontrollen clustern, die drei behandelten Tiere clustern, und beide Cluster sind klar voneinander getrennt (idealerweise entlang PC1). 

Was wir nicht sehen wollen: Mischung von Gruppen entlang PC1, oder klare Trennung entlang einer Achse, die nicht der Behandlung folgt (das wäre ein **Confounder**, z. B. Batch-Effekt). Wenn PC1 nicht die Behandlung repräsentiert, sondern z. B. die Sequencing-Reihenfolge, hat unwanted variation einen größeren Einfluss als die Behandlung.

**Sample-Distance-Heatmap**: Eine 6×6-Matrix der paarweisen Euklid-Distanzen zwischen Proben in log-CPM-Raum. Dunkle Felder = ähnliche Proben. Optimal: zwei dunkle 3×3-Blöcke auf der Diagonale (Kontrollen ähneln sich, Behandelte ähneln sich), heller dazwischen. Wenn diese Block-Struktur fehlt: schwacher Effekt oder Confounder.

### 6. RUVSeq — versteckte Störfaktoren entfernen

**Das Problem**: Selbst nach TMM-Normalisierung gibt es systematische Variation, die **nicht** von der Behandlung kommt. Quellen:
- Batch-Effekte (an verschiedenen Tagen sequenziert, andere Labortechnik-Charge, ...),
- RNA-Qualität (RIN-Werte unterscheiden sich; siehe GEO-Metadaten),
- Tier-zu-Tier-Variation in Stoffwechsel, Alter, ...,
- subtile Library-Prep-Unterschiede.

Wenn wir diese ignorieren, kommen sie als "biologisches" Signal in unsere DE-Analyse — falsche Positive.

**Die RUVSeq-Idee** (Risso et al. 2014): Modelliere unerwünschte Variation als **latente Faktoren** `W = (W_1, W_2, ..., W_k)`. Diese sind nicht direkt beobachtbar, aber durch ein cleveres statistisches Verfahren rekonstruierbar — wenn wir "Gene mit konstanter Expression" zur Hand haben (Negativkontrollen).

**Drei RUVSeq-Varianten**:
- **RUVg**: braucht Negativkontroll-Gene (Spike-Ins wie ERCCs oder Housekeeping-Gene).
- **RUVs**: braucht Replikat-Information (welche Proben sollten biologisch identisch sein).
- **RUVr**: nutzt Residuen einer ersten Regression.

**Unser Fall — RUVg mit empirischen Kontrollen**: Wir haben keine Spike-Ins. Die Lösung:
1. Erste, naive DE-Analyse durchführen.
2. Die Gene, die **am wenigsten** Unterschied zwischen den Gruppen zeigen (höchste p-Werte), sind in unseren Proben de facto konstant. Wir definieren die unteren 30 % als "empirische Negativkontrollen".
3. RUVg analysiert die Variation **innerhalb dieser konstanten Gene** — alle Variation, die wir dort sehen, muss unerwünscht sein. Sie wird via Singulärwertzerlegung in `k` latente Faktoren zerlegt.

**Wahl von k**: Bei nur 6 Proben sind wir limitiert. Jeder zusätzliche Faktor frisst Freiheitsgrade, und ab einem bestimmten Punkt absorbiert RUVg echte Biologie. **k = 1 ist konservativ und meist optimal** für n = 6. k = 2 ist ein Versuch wert, wenn der Effekt nach RUV (k=1) immer noch verschwommen ist; k ≥ 3 ist riskant.

**Sanity-Check**: Nach RUV muss man prüfen: `cor(W_1, treatment)`. Wenn das stark korreliert (sagen wir, > 0,7), dann saugt der latente Faktor genau das Signal weg, das wir messen wollen. Dann müssen wir die Kontrollgen-Auswahl überdenken oder k auf 0 setzen.

**Visualizing das Vorher/Nachher**: RLE-Plot und PCA werden vor und nach RUV gezeigt. Der gewünschte Effekt:
- RLE: Boxen werden enger und zentrierter auf 0.
- PCA: Behandlungsgruppen separieren klarer; Replikate clustern enger.

### 7. Differential Expression Analysis mit edgeR

**Das statistische Modell**: Counts folgen einer **negativen Binomialverteilung**. Warum nicht Poisson? Poisson nimmt an, dass Mittelwert = Varianz. In realen RNA-seq-Daten gibt es immer **Überdispersion** — die Varianz ist größer als der Mittelwert. Negative Binomial fügt einen zusätzlichen **Dispersions-Parameter** φ hinzu, der diese Extra-Varianz modelliert.

**Pro Gen wird geschätzt**:
- Mittlere Expression μ als Funktion der Design-Variablen (Intercept + W_1 + Treatment).
- Dispersion φ.

**edgeR's Quasi-Likelihood Framework (`glmQLFit` + `glmQLFTest`)**:
- Klassische Likelihood-basierte Tests (LRT = Likelihood Ratio Test) ignorieren, dass die Dispersion φ selbst nur geschätzt ist und Unsicherheit trägt. Bei kleinen Stichproben (n = 3) ist das ein echtes Problem.
- Quasi-Likelihood (QL) modelliert diese Unsicherheit explizit. Der QL-F-Test ist konservativer als LRT, produziert weniger falsche Positive, ist aber bei großen Effekten genauso empfindlich.
- `robust = TRUE` lässt einzelne Gene mit extremen Dispersionen aus dem gemeinsamen Pool herausfallen — wichtig, weil sonst einige stark verrauschte Gene die Schätzung für alle verzerren.

**Die Design-Matrix**:
```r
design <- model.matrix(~ W$W_1 + treatment)
```
Spalten: `Intercept`, `W_1`, `treatment_tet`.
Die Reihenfolge ist wichtig: erst werden Störfaktoren regrediert, **dann** wird der Treatment-Effekt geschätzt. Das `~` bedeutet "modelliere log(mean expression) als lineare Kombination dieser Faktoren". `glmQLFTest(coef = "treatment_tet")` testet, ob dieser eine Koeffizient von 0 verschieden ist, unter Kontrolle der anderen Variablen.

**Multiple-Testing-Korrektur**: Bei 16.000 Genen würden bei einem Alpha von 0,05 zufällig ~800 Gene "signifikant" werden. Wir korrigieren mit **Benjamini-Hochberg** (FDR — False Discovery Rate). FDR < 0,05 bedeutet: unter den so klassifizierten "signifikanten" Genen sind im Mittel ≤ 5 % falsche Positive.

**Was wir kriegen — die Top-Tabelle**:
| Symbol | logFC | logCPM | F | PValue | FDR |
|---|---|---|---|---|---|
| Cyp1a1 | 6,2 | 8,4 | 245 | 1e-12 | 1e-08 |
| Hmox1 | 4,1 | 7,1 | 178 | 5e-10 | 2e-06 |
| ... | ... | ... | ... | ... | ... |

`logFC` = log₂-Fold-Change. Wert 1 bedeutet 2-fache Hochregulation, 2 bedeutet 4-fach, 3 bedeutet 8-fach. Negative Werte: Runterregulation.

**Plots**:
- **Volcano-Plot**: X = logFC, Y = -log10(p-Wert). Gene weit rechts und oben (hochreguliert + signifikant) und weit links und oben (runterreguliert + signifikant) sind die interessanten. Punkte ohne Signal liegen in der Mitte unten.
- **MD-Plot**: X = mittlere Expression, Y = logFC. Sollte symmetrisch um 0 streuen. Wenn die Punktwolke schief liegt: Normalisierung war nicht perfekt.
- **Top-DE-Heatmap**: Die 50 signifikantesten Gene werden als Heatmap geplottet. Sind die Werte zwischen Replikaten konsistent? Wenn ja, ist der Effekt robust.

### 8. Gene Set Enrichment Analysis mit multiGSEA

**Warum nicht einzelne Gene anschauen?** Probleme bei der Einzelgen-Analyse:
- Bei n = 3 pro Gruppe haben wir wenig Power; viele wahre Effekte werden nicht signifikant.
- Einzelne Gene sind biologisch schwer zu interpretieren. "Gen X ist hoch" sagt wenig.
- Reproduzierbarkeit über Studien hinweg ist auf Einzelgen-Ebene schlecht.

**Pathway-Ebene löst das**: Wenn 20 Gene aus dem **gleichen Pathway** alle moderat in die gleiche Richtung gehen, ist das viel aussagekräftiger als ein einzelnes Gen mit FDR=10⁻¹⁰.

**Was ist ein Pathway?** Eine kuratierte Liste von Genen, die gemeinsam eine biologische Funktion ausüben. Beispiele:
- KEGG-Pathway "Oxidative phosphorylation" (~130 Gene): alle Komponenten der Atmungskette.
- Reactome-Pathway "Fatty acid beta-oxidation" (~30 Gene).
- WikiPathways-Pathway "Nrf2 pathway" (~40 Gene).

**Was tut multiGSEA?**
1. Alle Gene werden nach einem **kombinierten Score** aus logFC und p-Wert sortiert (`rankFeatures()` macht das in einer cleveren Weise). Stark hochregulierte signifikante Gene oben, stark runterregulierte unten.
2. Für jeden Pathway: wie geclustert sind die Gene dieses Pathways in der Rangliste? Wenn sie alle oben stehen → Pathway ist hochreguliert. Wenn alle unten → runterreguliert. Wenn gleichmäßig verteilt → kein Effekt. Diese Berechnung ist ähnlich zum klassischen **GSEA** (Subramanian et al. 2005) und nutzt eine Kolmogorov-Smirnov-artige Statistik.
3. multiGSEA macht das **gleichzeitig über mehrere Datenbanken** (KEGG, Reactome, WikiPathways). Das ist wichtig, weil verschiedene Datenbanken oft komplementäre Pathways annotieren.
4. Für jeden Pathway-Namen werden die p-Werte aus den verschiedenen Datenbanken mit **Stouffer's Methode** zu einem kombinierten p-Wert verschmolzen.
5. Multiple-Testing-Korrektur über alle getesteten Pathways (FDR).

**Output**: pro Pathway: Datenbank-spezifische p-Werte, kombinierter p-Wert, FDR. Sortiert nach kombiniertem p-Wert sieht man die robustesten Hits oben.

**Vorteile gegenüber Einzeldatenbank-GSEA**:
- Robuster: ein Pathway, der in nur einer Datenbank auftaucht und dort schwach enriched ist, fällt nicht raus.
- Stabiler: wenn ein Pathway in mehreren Datenbanken konsistent enriched ist, ist die Evidenz stärker.

### 9. Das Podtelezhnikov-Signatur-Framework — gezielte mechanistische Auswertung

**Warum ein zweites Auswertungs-Verfahren?** multiGSEA testet **tausende** vorhandene Pathways gegen unsere Daten — das ist breit und exploratorisch. Aber wir haben den großen Vorteil, dass unser Datensatz aus einer publizierten Studie stammt, deren Autoren bereits einen **kompakten, kuratierten Interpretations-Rahmen** definiert haben. Diesen Rahmen direkt anzuwenden ist methodisch sauberer und macht den Report deutlich stärker.

**Was Podtelezhnikov et al. 2020 vorschlagen**: Sie haben aus 120 Wirkstoffen × Rattenleber-RNA-seq systematisch herausgearbeitet, dass praktisch jede frühe transkriptionelle Antwort der Leber auf Xenobiotika sich auf **9 kanonische Signaturen** abbilden lässt:

**5 Xenobiotic Nuclear Receptors** (also Rezeptoren, die Fremdstoffe erkennen und Entgiftungs-Programme aktivieren):
- **AHR** (Aryl-Hydrocarbon-Rezeptor): aktiviert vor allem Cyp1a1/1a2 — typisch für polyzyklische Substanzen.
- **CAR** (Constitutive Androstane Receptor): aktiviert Cyp2b — wichtig für viele Medikamente.
- **PXR** (Pregnane X Receptor): aktiviert Cyp3a-Familie — die wichtigsten Arzneimittel-metabolisierenden Enzyme.
- **PPARα** (Peroxisome Proliferator-Activated Receptor α): reguliert Fettsäure-Oxidation und Lipid-Stoffwechsel.
- **ER** (Estrogen Receptor): hormonelle Achse.

**3 Mediatoren reaktiver Metaboliten / Stress**:
- **NRF2** (NFE2L2): die "Master-Schalter"-Antwort auf oxidativen Stress.
- **NRF1** (NFE2L1): Proteasom- und Proteostase-Antwort.
- **P53** (Trp53): DNA-Schaden und Apoptose.

**1 Innate-Immunity-Antwort**: akute-Phase-Reaktion und Entzündung — der Marker, dass die Leber tatsächlich geschädigt wird, nicht nur adaptiert.

**Wie wir das in unseren Daten messen**: Für jede der 9 Signaturen ist eine kompakte Liste von **Paradigma-Marker-Genen** definiert (typische, gut etablierte Zielgene des jeweiligen Rezeptors oder Stress-Pfads). Beispiele aus unserem Skript:

- AHR: Cyp1a1, Cyp1a2, Cyp1b1, Nqo1, Aldh3a1, Tiparp, Ahrr
- CAR: Cyp2b1, Cyp2b2, Cyp2b3, Cyp2c6, Cyp2c11, Sult2a1
- PXR: Cyp3a1, Cyp3a2, Cyp3a9, Cyp3a23, Ugt1a1, Abcc2, Abcb1a/b, Gstp1
- PPARα: Cyp4a1, Cyp4a3, Acox1, Ehhadh, Hadha, Cpt1a, Cpt2, Acaa1, Hmgcs2, Fabp1, Pdk4
- NRF2: Nqo1, Hmox1, Gclc, Gclm, Txnrd1, Gsr, Srxn1, Gsta1, Gsta2, Gpx2
- ... und so weiter für NRF1, P53, ER und Innate Immunity.

**Statistik pro Signatur** (das macht Sektion 8 des R-Skripts):
1. Wie viele der Marker-Gene findet man in der DE-Tabelle?
2. Wie ist der **mittlere log2-Fold-Change** dieser Gene? (positiver Wert = Signatur ist aktiviert, negativer = unterdrückt.)
3. Ein **einseitiger Wilcoxon-Test** prüft: ist die Verteilung der logFC-Werte signifikant von Null verschoben? Das gibt einen p-Wert pro Signatur — eine "ist die Signatur statistisch belastbar aktiviert"-Aussage.
4. Wieviele Gene der Signatur sind individuell signifikant (FDR < 0.05) hoch- oder runterreguliert?

**Visualisierung**:
- **Bar-Plot** (`11_Podtelezhnikov_signatures.pdf`): mittlerer logFC pro Signatur, mit Sternchen für signifikante Aktivierung. Auf einen Blick siehst du, welche Signaturen "an" sind und welche nicht.
- **Heatmap** (`12_signature_heatmap.pdf`): pro Probe und pro Signatur ein Z-Score. Hier sieht man, ob die Aktivierung in allen drei Tetracyclin-Replikaten konsistent ist (Voraussetzung für eine stabile Aussage).

**Was das für deinen Report bedeutet**: Statt nur generischer Aussagen wie "Pathway X ist enriched" kannst du jetzt sehr präzise sagen: "Von den 9 kanonischen Signaturen, die Podtelezhnikov et al. (2020) für die Rx-TGx-Studie definierten, sehen wir bei Tetracyclin folgendes Aktivierungs-Muster: PXR ↑↑ (FDR < 0.001), CAR ↑ (FDR < 0.05), NRF2 ↑↑ (FDR < 0.001), PPARα ↓ (FDR < 0.01), ...". Das ist ein **methodisch sauberer, direkt mit der Primärliteratur abgeglichener Befund** — genau das, was bei der Bewertung deiner Arbeit zählt.

## 2.3 Biologische Interpretation — der eigentliche Punkt

Hier wird's spannend, denn jetzt verbinden wir unsere statistischen Resultate mit dem, was Pharmakologen über Tetracyclin wissen.

### 2.3.1 Was tut Tetracyclin im Körper?

**Primärwirkung (warum es ein Antibiotikum ist)**: Tetracyclin diffundiert in Bakterienzellen und bindet dort an die **16S-rRNA in der 30S-Untereinheit des Ribosoms**. Diese 30S-Untereinheit ist die kleine der beiden Ribosomen-Komponenten in Bakterien. Durch die Bindung blockiert Tetracyclin die A-Stelle des Ribosoms, an der normalerweise neu eingeführte Aminosäure-tRNAs andocken. Resultat: das Bakterium kann keine Proteine mehr produzieren → bakteriostatisch (es wächst nicht weiter, stirbt aber nicht direkt).

**Aber Säugetierzellen haben Ribosomen — werden die nicht auch betroffen?** Im Cytosol haben Eukaryoten 80S-Ribosomen mit 40S/60S-Untereinheiten. Die unterscheiden sich strukturell genug, dass Tetracyclin bei therapeutischen Dosen nicht stark bindet. Das ist die Basis der therapeutischen Selektivität.

**Aber unsere Mitochondrien — wo wird's interessant**: Mitochondrien stammen evolutionär von eingewanderten Bakterien ab (Endosymbionten-Theorie). Sie haben **eigene Ribosomen**, sogenannte Mito-Ribosomen oder Mitoribosomen, mit 55S-Gesamtgröße und Untereinheiten, die strukturell den bakteriellen 70S-Ribosomen ähneln. **Diese sind durch Tetracyclin angreifbar.**

Bei normalen Dosen ist der Effekt gering. Bei den **600 mg/kg pro Tag**, die in unserer Studie verwendet wurden, ist das eine massive Überdosierung — das ist Hepatotoxizitäts-Bereich, weit über jeder therapeutischen Konzentration.

### 2.3.2 Die toxikologische Kaskade

Wenn Tetracyclin in der Leber die Mito-Ribosomen blockiert, läuft Folgendes ab:

**Schritt 1 — Mitochondriale Translation ↓**

In jedem Mitochondrium gibt es eine kleine ringförmige DNA (mtDNA), die nur 13 Proteine kodiert. Aber das sind **alles Komponenten der OXPHOS-Komplexe** — der Atmungskette, also der Energieproduktion. Wenn die Mito-Translation gestört ist, fehlen diese 13 Untereinheiten.

**Schritt 2 — OXPHOS-Komplexe können nicht assembliert werden**

Die fünf Komplexe der Atmungskette (Komplex I bis V, einschließlich der ATP-Synthase) bestehen jeweils aus vielen Untereinheiten. Einige sind kernkodiert (werden im Cytosol gebaut und ins Mitochondrium importiert), andere sind mtDNA-kodiert. Wenn auch nur eine Untereinheit fehlt, funktioniert der Komplex nicht. → ATP-Produktion ↓.

**Schritt 3 — Energiemangel und gestauter Stoffwechsel**

ATP wird in der Zelle für alles gebraucht. In der Leber besonders viel für die Fettsäure-β-Oxidation. Ohne funktionierende Atmungskette akkumulieren NADH und FADH₂ in der Mitochondrien-Matrix; die β-Oxidation der Fettsäuren bleibt stehen. **Fettsäuren akkumulieren in den Hepatozyten → mikrovesikuläre Steatose**.

Dieser Befund — **Tetracyclin-induzierte mikrovesikuläre Leberverfettung** — ist klinisch dokumentiert, vor allem aus den 1960er-Jahren, als intravenöses Hochdosis-Tetracyclin bei Schwangeren mit Pyelonephritis zu Leberversagen führte (Whalley et al. 1964). Diese Fälle waren der Grund, warum Tetracyclin heute in der Schwangerschaft kontraindiziert ist.

**Schritt 4 — Sekundäre Stress-Antworten**

- **Mitochondriale UPR** (Unfolded Protein Response). Wenn falsch zusammengebaute oder ungebrauchte Untereinheiten im Mitochondrium ansammeln, wird die Mito-UPR aktiviert. Marker-Gene: `Hspd1` (HSP60), `Hspe1` (HSP10), `Clpp`, `Lonp1`, `Atf5`.
- **Oxidativer Stress / Nrf2-Pfad**. Eine kaputte Atmungskette produziert mehr ROS (reactive oxygen species). Die Zelle aktiviert das Nrf2-System mit Genen wie `Nqo1`, `Hmox1`, `Gclc`, `Gclm`, `Txnrd1`.
- **Xenobiotic Metabolism**. Tetracyclin ist eine Fremdsubstanz, die abgebaut werden muss. Phase-I-Enzyme (Cytochrome P450, vor allem Cyp1a-, Cyp2b-, Cyp3a-Familien) und Phase-II-Enzyme (GSTs, UGTs, SULTs) werden hochreguliert.
- **Akute-Phase-Antwort / Inflammation**. Bei dieser Dosis sind Hepatozyten geschädigt; das löst eine akute-Phase-Reaktion aus. Marker: `Saa1`, `Lcn2`, `Cxcl1`, `Il6`.

### 2.3.3 Was im GSEA-Output stehen muss — gekoppelt an das 9-Signatur-Framework

Damit deine Analyse glaubwürdig ist, solltest du die folgenden biologischen Signaturen finden. In der rechten Spalte ist angegeben, **welcher der 9 Podtelezhnikov-Signaturen** der jeweilige Effekt entspricht — so kannst du deinen multiGSEA-Output direkt mit den Resultaten der Signatur-Auswertung (Sektion 8 im R-Skript, Output `Podtelezhnikov_signatures.csv`) gegenchecken.

| Erwartete Richtung | Pathway-Bereich | Wichtige Gene | Entspricht Signatur |
|---|---|---|---|
| ↓ | Oxidative Phosphorylierung (KEGG/Reactome) | Ndufa-, Ndufb-, Sdha–d, Uqcr-, Cox-, Atp5-Familien | nicht in 9-Set — direkter Tetracyclin-Mechanismus |
| ↓ | Mitochondriale Translation / Mito-Ribosom | Mrpl-, Mrps-Familien, Aars2, Lars2 | nicht in 9-Set — direkter Tetracyclin-Mechanismus |
| ↓ (oder gemischt!) | Fettsäure-β-Oxidation, PPARα-Targets | Cpt1a, Cpt2, Acox1, Acaa2, Ehhadh, Hadha, Cyp4a-Familie | **PPARα** |
| ↑ | Drug Metabolism Phase I — Cyp1a-Familie | Cyp1a1, Cyp1a2, Cyp1b1 | **AHR** |
| ↑ | Drug Metabolism Phase I — Cyp2b-Familie | Cyp2b1, Cyp2b2, Cyp2b3, Cyp2c11 | **CAR** |
| ↑ | Drug Metabolism Phase I — Cyp3a-Familie | Cyp3a1, Cyp3a2, Cyp3a9, Cyp3a23 + Abcc2 (Mrp2), Abcb1a/b | **PXR** (am stärksten zu erwarten) |
| ↑ | Drug Metabolism Phase II / Glutathion | Gsta-, Gstm-, Gstp-Familien, Ugt1a, Ugt2b, Sult1a, Gpx1/2, Gsr | **PXR / NRF2** |
| ↑ | Nrf2 / Antioxidative Antwort | Nqo1, **Hmox1** (Heme Oxygenase 1), Gclc, Gclm, Txnrd1, Srxn1 | **NRF2** |
| ↑ | Mitochondriale UPR | Hspd1, Hspe1, Clpp, Lonp1, Atf5, Dnaja3 | nicht in 9-Set — Tetracyclin-spezifisch |
| ↑ | Proteasom-/Proteostase-Antwort | Psmb-, Psma-, Psmc-Familien | **NRF1** |
| ↑ | Akute-Phase-Antwort / Inflammation | Saa1, Saa2, Lcn2, Cxcl1, Il6, Hp, A2m | **Innate Immunity** |
| ggf. ↑ | DNA-Schaden-Antwort | Cdkn1a (p21), Bax, Gadd45a, Mdm2 | **P53** (eher schwach bei Tetracyclin) |
| neutral | Estrogen-Achse | Esr1, Pgr, Tff1, Igf1 | **ER** (keine Aktivierung erwartet) |

**Doppelter Check**: dieselben Marker tauchen sowohl im multiGSEA-Output (auf Pathway-Ebene) als auch im Signatur-Score-Plot (`11_Podtelezhnikov_signatures.pdf`) auf. Wenn z. B. PXR auf der Signatur-Ebene stark hoch ist (mittlerer logFC > 1, Wilcoxon-FDR < 0.05), sollte gleichzeitig der KEGG-Pathway "Drug metabolism — cytochrome P450" im multiGSEA-Output mit niedrigem p-Wert auftauchen. Wenn beide übereinstimmen, ist das ein robustes Resultat — wenn nicht, lohnt sich ein zweiter Blick auf die Daten.

**Wenn diese Signaturen weitgehend fehlen**, gibt es drei Erklärungen, die du ehrlich diskutieren solltest:
1. **Sample-Verwechslung**: Hat dein Mapping SRR→GSM gestimmt? Zurück zur Metadaten-Tabelle.
2. **Strandedness-Fehler**: Hat featureCounts den richtigen Strand-Modus verwendet? Bei falscher Einstellung halbiert sich die Count-Zahl.
3. **RUV hat den Effekt absorbiert**: `cor(W_1, treatment)` prüfen.

**Wenn die Signaturen vorhanden sind**, hast du:
- Eindeutige mechanistische Evidenz für die mitochondriale Toxizität (über die nicht-9-Signatur-Pathways).
- Eine direkte Anschluss-Aussage in das Merck-Framework (über die 9 Signaturen).
- Direkte Verbindung von in-vivo-Pathologie (Steatose) zum molekularen Mechanismus.
- Ein lehrbuchmäßiges toxikogenomisches Resultat, das du in Diskussion und Präsentation klar darstellen kannst.

**Das spannende Detail — PPARα**: Hier kann dein Ergebnis vom Standard-Xenobiotika-Modell abweichen. Im Podtelezhnikov-Framework gilt PPARα-Aktivierung als typische Antwort auf Xenobiotika (positiver logFC). Bei Tetracyclin **könnte** das Vorzeichen umkehren: weil die mitochondriale Dysfunktion die β-Oxidation hemmt, fallen die Substratwege für PPARα-Targets aus, und du siehst eine **Runter**-Regulation. Sollte das in deinen Daten so sein, ist das **kein Fehler in deiner Analyse**, sondern ein interessanter biologischer Befund, den du diskutieren solltest: Tetracyclin verhält sich nicht wie ein klassisches xenobiotic, sondern dominiert die Mitochondrien-Funktion. Das ist ein eigenständiger Reportpunkt.

### 2.3.4 Das narrative Argument für deinen Report

Der "rote Faden" deines Reports sollte sein:

> Tetracyclin bindet bei hohen Dosen nicht nur an bakterielle, sondern auch an mitochondriale Ribosomen. Unsere RNA-seq-Daten von Rattenleber nach 4-tägiger Hochdosis-Behandlung zeigen genau dieses Muster: die mitochondriale Translation ist transkriptionell herunterreguliert, ebenso die OXPHOS-Komplexe, was die ATP-Produktion einschränkt. Sekundär dazu sehen wir die Hemmung der Fettsäure-β-Oxidation (kein NAD+/FAD verfügbar), was klinisch zur bekannten mikrovesikulären Steatose passt. Parallel ist die Stressantwort der Zelle aktiviert: die mitochondriale Unfolded Protein Response (Hspd1, Clpp), der Nrf2-Antioxidant-Pfad (Hmox1, Nqo1) und die Phase-I/II-Entgiftung (Cyps, GSTs, UGTs).
>
> Im Rahmen des von Podtelezhnikov et al. (2020) für die Rx-TGx-Studie definierten 9-Signatur-Frameworks sehen wir konkret die Aktivierung der xenobiotischen Rezeptoren PXR und CAR (Phase-I/II-Antwort) sowie der reactive-metabolite-Stressantwort NRF2, ergänzt durch die innate-immunity-Achse. PPARα verhält sich erwartungsgemäß abweichend von klassischen Hepatika, was den mitochondrial-toxischen Charakter der Substanz unterstreicht.
>
> Diese Daten reproduzieren genau das Mechanismus-Modell, das aus der Tetracyclin-Hepatotoxizitäts-Literatur seit Jahrzehnten bekannt ist, und demonstrieren, wie Toxikogenomik die mechanistische Brücke von der molekularen Wirkung zur klinischen Pathologie schlägt.

Wenn du dieses Argument durch deine Daten belegen kannst, hast du genau das Lernziel des Projekts demonstriert.

---

# Anhang A: Häufige Stolperfallen

**1. Sample-Vertauschung.** Sobald du in der R-Analyse die Galaxy-Counts importierst, ist die wichtigste Frage: **welche Spalte gehört zu welcher GSM/Behandlung?** Galaxy liefert die Spalten oft mit SRR-Namen oder BAM-Pfaden — verwirrend. Lege die Metadaten-Tabelle (GSM → SRR → Treatment) gleich am Anfang sauber an, dann ist alles andere konsistent.

**2. Ensembl-Versionen.** Galaxy nutzt manchmal eine andere Ensembl-Version als `org.Rn.eg.db`. Das führt dazu, dass 10–20 % der Gene kein Mapping bekommen. Das ist normal — keine Panik, sondern dokumentieren.

**3. Strandedness falsch in featureCounts.** Schwer zu erkennen — die Pipeline läuft sauber durch, aber die Statistik ist um Faktor 2 verwässert. Im Zweifel: mit RSeQC `infer_experiment.py` empirisch prüfen.

**4. Bei n = 3: dispersion estimation kann fragil sein.** Immer `robust = TRUE` in edgeR setzen.

**5. RUV mit zu großem k.** k = 1 ist meist optimal. Bei k = 2 schon den `cor(W, treatment)`-Test machen.

**6. multiGSEA: Datenbank-Download.** Beim ersten Lauf zieht multiGSEA Pathway-Daten aus dem Netz. Wenn dein Netz das blockt oder langsam ist: cachen mit `useLocal = TRUE` nach erstem erfolgreichen Lauf.

**7. Falsche Genom-Version.** Wir benutzen rn6 / Rnor_6.0. Eine neuere Version `mRatBN7.2` (Rnor_7) ist mittlerweile verfügbar, aber die Galaxy-builtin GTF und die in GEO genutzte Annotation sind Rnor_6.0 — dabei bleiben.

---

# Anhang B: Repository-Struktur für GitHub/GitLab

Empfohlene Verzeichnisstruktur für deinen finalen Code:

```
tetracycline-toxicogenomics/
├── R/
│   └── tetracycline_analysis.R          # Hauptanalyse-Skript
├── data/
│   ├── galaxy_featureCounts.tabular     # Counts aus Galaxy (gitignored wenn zu groß)
│   └── sample_metadata.csv              # Metadaten-Tabelle GSM/SRR/Treatment
├── results/                              # gitignored
│   ├── DE_results.csv
│   ├── multiGSEA_results.csv
│   ├── Podtelezhnikov_signatures.csv
│   ├── pathways_of_interest.csv
│   ├── *.pdf (alle Plots)
│   └── sessionInfo.txt
├── docs/
│   ├── report.md                        # Schriftlicher Bericht
│   └── presentation.pdf                 # Slides
├── README.md                            # Projektübersicht
└── .gitignore                           # data/ und results/ ausschließen
```

**Release-Tag setzen** (für die finale Version):
```bash
git tag -a v1.0 -m "Finale Abgabe-Version"
git push --tags
```

# Anhang C: Output-Dateien im Überblick

Nach erfolgreichem Lauf des R-Skripts liegen folgende Dateien in `results/`:

| Datei | Inhalt | Erzeugt in Sektion |
|---|---|---|
| `01_library_sizes.pdf` | Balken pro Probe — Sequencing-Tiefe | 4 (EDA) |
| `02_RLE_pre_RUV.pdf` | Unwanted Variation vor Korrektur | 4 (EDA) |
| `03_PCA_pre_RUV.pdf` | Sample-Separation vor RUV | 4 (EDA) |
| `04_sample_distance_heatmap.pdf` | Paarweise Sample-Ähnlichkeit | 4 (EDA) |
| `05_RLE_post_RUV.pdf` | RLE nach RUV — sollte enger sein als (02) | 5 (RUV) |
| `06_PCA_post_RUV.pdf` | PCA nach RUV — sollte klarere Gruppentrennung zeigen | 5 (RUV) |
| `07_volcano.pdf` | DE-Übersicht mit Top-Genen | 6 (DEA) |
| `08_MDplot.pdf` | Mean-Difference-Plot | 6 (DEA) |
| `09_top_DE_heatmap.pdf` | Top 50 DE-Gene als Heatmap | 6 (DEA) |
| `10_top_pathways.pdf` | Top angereicherte Pathways (multiGSEA) | 7 (GSEA) |
| **`11_Podtelezhnikov_signatures.pdf`** | **Bar-Plot: mittlerer logFC pro 9-Signatur, mit Signifikanz** | **8 (NEU)** |
| **`12_signature_heatmap.pdf`** | **Per-Sample Z-Score-Heatmap der 9 Signaturen** | **8 (NEU)** |
| `DE_results.csv` | Komplette DE-Tabelle | 6 (DEA) |
| `multiGSEA_results.csv` | Komplette Pathway-Anreicherungs-Tabelle | 7 (GSEA) |
| **`Podtelezhnikov_signatures.csv`** | **Tabelle: n_genes, mean_logFC, Wilcoxon-p-Wert pro Signatur** | **8 (NEU)** |
| `pathways_of_interest.csv` | Auf Tetracyclin-relevante Pathways gefilterte multiGSEA-Treffer | 9 (Interpretation) |
| `sessionInfo.txt` | R-/Paket-Versionen für Reproduzierbarkeit | 10 |

---

Damit hast du das Material für Galaxy-Bedienung, R-Analyse, biologische Interpretation und Report-Struktur in einem Dokument. Wenn beim Durchführen Fragen auftauchen, sind sie willkommen — RNA-seq hat genug Eigenheiten, dass man auch beim zehnten Lauf noch über neue Stolperfallen stolpern kann.
