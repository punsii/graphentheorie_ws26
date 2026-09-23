#import "@preview/supercharged-hm:1.1.0": *
//#import "glossary.typ" : glossary

#show: hm-template.with(
  title: "Steinerbäume",
  subtitle: [Modularbeit Graphentheorie],
  authors: authors("Julius Greppmair", "Paul Menhart"),
  doc-type: "Modularbeit",
  language: "de",
  bibliography: bibliography("sources.bib"),
  toc-depth: 2,
)

#pagebreak()

= Einleitung

// Worum es geht, wofür man Steinerbäume braucht, und ein Satz als Leitfaden durch die drei
// behandelten Varianten in der Reihenfolge der Taxonomie.
// Quellen: @gilbert1968 (Ursprung der Problemstellung), @rehfeldt2023 (aktueller Stand)

= Methodik

//
// Quellen: @rehfeldt2023 (fachlicher Einstieg), @dimacs11 und @pace2018web (Wettbewerbe),
// @bonnet2018 (Aufgabenstellung der PACE-Kategorien), @jungnickel1999 (Grundlage der
// Implementierung)

= Problemtaxonomie

// Kurz halten. Der Hauptteil folgt der hier gesetzten Reihenfolge: euklidisch,
// rektilinear, Graphen.
// Hier einmalig die Notation einführen, sie gilt für alle drei Varianten: Netzwerk (G, w)
// mit positiver Gewichtsfunktion, Terminale R, Steiner-Knoten S = V \ R, r = |R| sowie
// S' ⊆ S für die aufgezählten Teilmengen.
// Quellen: @gilbert1968 (euklidisch), @hanan1966 (rektilinear), @jungnickel1999 (Graphen)

= Euklidisches Steinerbaum-Problem

== Optimale Lösung

=== Voraussetzungen und Beweis der optimalen Lösung

// Gegebenenfalls Beweis der 120-Grad-Regel bzw. dass Steiner-Punkte drei Verbindungen haben.
// Quelle: @gilbert1968

=== NP-Schwere

//NP-schwer, aber es ist nicht bekannt, ob die Entscheidungsvariante in NP liegt.
// Grund dafür ist dass floating point Präzision nicht ausreicht
// um Summen von Wurzeln zu vergleichen. (unklar ob SSR in NP liegt).
// Also gerade nicht als NP-vollständig belegt, anders als bei den beiden anderen Varianten.
// Unterscheidung in der Praxis aber weitgehend irrelevant.
// Quelle: @garey1977euclidean

=== Warum nur etwa 14 % besser als der minimale Spannbaum

// Steiner-Verhältnis √3/2 ≈ 0,866, Vermutung von Gilbert und Pollak. Der Beweis von Du und
// Hwang (1992) wird angezweifelt da nachträglich Lücken / Fehler gefunden wurden.
// Falls er sich tatsächlich als falsch herausstellt wäre der Beweis von Chung–Graham (1985)
// der nächstbeste Wert (Steiner-Verhältnis von ≈ 0,824)
// Quellen: @gilbert1968 (Vermutung), @du1992 (angezweifelter Beweis), @innami2010 und
// @ivanov2012 (Lücke im Beweis), @chung1985 (beste bewiesene Schranke),
// @pollak1978, @du1985fivepoints, @rubinstein1991sixpoints (bewiesene Fälle n = 4, 5, 6)

=== Vollständige und unvollständige Steinerbäume

// Quelle: @gilbert1968

== Approximierte Lösung

=== Aktuelle Entwicklungen

// Quelle: @llm2026gilbertpollak (Preprint, nicht begutachtet)

=== Approximation gegenüber optimaler Lösung

// Laufzeit und durchschnittliche Differenz in der Gesamtlänge.

=== Anwendungen in der Praxis

= Rektilineares Steinerbaum-Problem

// Kurz halten, dient als Übergang zum Graphenproblem.
// Quelle: @garey1977rectilinear (NP-Vollständigkeit)

== Bedeutung im Schaltungsentwurf

== Hanan-Gitter und Reduktion auf das Graphenproblem

// Ein optimaler rektilinearer Steinerbaum existiert auf dem Gitter, das die waagerechten
// und senkrechten Geraden durch die Terminale aufspannen. Damit wird aus einem
// geometrischen Problem mit unendlich vielen Kandidatenpunkten ein endliches
// Graphenproblem.
// Quelle: @hanan1966

= Steinerbaum-Problem in Graphen

== NP-Vollständigkeit

// Entscheidungsvariante NP-vollständig (Karp 1972), Optimierungsvariante NP-schwer.
// Quelle: @karp1972

== Einfache Approximation über den minimalen Spannbaum

// Minimaler Spannbaum über alle Terminale, danach Entfernen der überflüssigen
// Steiner-Knoten. Übergang: "Aber geht es besser?"

= Implementierter Algorithmus

// Algorithmus 4.6.3 aus Jungnickel.
// Quelle: @jungnickel1999

== Laufzeitanalyse

=== Floyd-Warshall

// Quellen: @floyd1962, @warshall1962

=== Prim

// Quelle: @prim1957

=== Anzahl der aufgezählten Teilmengen

// Summe über C(|S|, i) für i ≤ r − 2.

=== Pfadrekonstruktion

// Von der metrischen Hülle zurück in den ursprünglichen Graphen.

=== Warum Prim und nicht Kruskal

// Die metrische Hülle ist vollständig. Array-Prim kostet dort O(k²), Kruskal zahlt
// zusätzlich einen Logarithmus für das Sortieren der k(k−1)/2 Kanten, und das einmal pro
// aufgezählter Teilmenge.
// Quellen: @prim1957, @kruskal1956

=== Metrische Hülle und der Zusammenhang der Teilmengen

// In der vollständigen metrischen Hülle induziert jede Knotenteilmenge einen
// zusammenhängenden Teilgraphen. Es existiert also immer ein Spannbaum und der
// Zusammenhang muss pro Teilmenge nicht geprüft werden, was das Aufzählen über S' erst
// einfach macht.

== Optimierung |S'| ≤ r − 2 und warum sie genügt

// In einem optimalen Baum dürfen Steiner-Knoten als mindestens dreifach verzweigt
// angenommen werden. Ein Baum mit r Blättern hat höchstens r − 2 solcher Knoten.
// Quelle: @jungnickel1999

== Die metrische Hülle als Abstraktion

// Die metrische Hülle muss nicht tatsächlich aufgebaut werden, sie ist eher eine
// Gedankenstütze. Für die Implementierung genügt Prim eine Teilmenge der Knoten plus die
// Distanztabelle aus floyd(). Das spart pro Teilmenge den Aufbau von k(k−1)/2
// Kantenobjekten und zusätzlich das Filtern der Distanztabelle, das mit Θ(n²) nicht mit
// der Teilmenge, sondern mit dem gesamten Graphen skaliert.

= Nebenbemerkung: Dreyfus-Wagner

// O(3^r · n + 2^r · n² + n³), also polynomiell, wenn die Anzahl der Terminale
// logarithmisch in n ist. Der Gegensatz ist der interessante Teil: das hier implementierte
// Verfahren ist exponentiell in |S| = n − r, Dreyfus-Wagner dagegen in r. Daraus erklärt
// sich die Form der gemessenen Laufzeitkurve.
// Quelle: @dreyfus1971

= Ausblick: Approximationsverfahren in der Praxis

// Werden hier nicht im Detail behandelt. Als Vergleichswert in den Messungen dient eine
// 2-Approximation aus networkx; ihr Verfahren wird bewusst nicht besprochen.

= Experimenteller Aufbau

== Technischer Aufbau

// Kurz: Sprache, eigene Graphentypen, die drei Algorithmen, Generator, Messaufbau,
// Erzeugung der Abbildungen.

== Instanzgenerator und Parameter

// Sehr kurz: zufällige zusammenhängende Graphen, Knotenzahl, Kantenwahrscheinlichkeit,
// Terminalzahl, maximales Kantengewicht, feste Startwerte, fünf Wiederholungen je
// Parameterpunkt, ausgewiesen wird der Median.

== Ergebnisse

=== Laufzeit über der Anzahl der Terminale

// results/runtime_by_terminals.png

=== Laufzeit über der Knotenzahl

// results/runtime_by_vertices.png, mit den angepassten Exponenten.

=== Laufzeit über der Kantenwahrscheinlichkeit

// results/runtime_by_density.png

=== Messung gegenüber Vorhersage

// results/measured_against_prediction.png

=== Güte der Approximation

// results/quality_by_terminals.png
// Die Schranke von 2 wird in den Messungen nie annähernd erreicht.

== Interpretation der Laufzeitkurve

// Warum die Kurve einen Buckel hat, wenn sich das Verhältnis von Terminalen zu
// Steiner-Knoten verschiebt.
// Quelle: @dreyfus1971 (Gegensatz: exponentiell in r statt in |S|)

= Fazit

// - Im Allgemeinen NP-vollständig (Entscheidungsvariante).
// - Approximationen liefern schnell brauchbare Ergebnisse.
// - Eigenes Ergebnis: die Laufzeit des exakten Verfahrens verläuft nicht monoton, sondern
//   mit einem Buckel über r. Klein für wenige Terminale, unbrauchbar im mittleren Bereich,
//   wieder klein, wenn r sich n nähert, weil über Teilmengen der n − r Steiner-Knoten
//   aufgezählt wird. Praktisch: das exakte Verfahren ist an beiden Enden einsetzbar.
// - Wann welches Verfahren angebracht ist, und dass das über die Reduktion ebenso für die
//   geometrischen Varianten gilt.
// - Ausblick: Dreyfus-Wagner sowie die Reduktionstechniken von Rehfeldt und Koch.
// Quellen: @karp1972, @dreyfus1971, @rehfeldt2023

= Anhang

== Repository

// Link auf das Git-Repository.
