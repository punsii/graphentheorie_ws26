#import "@preview/supercharged-hm:1.1.0": *

#show: hm-template.with(
  title: "Steinerbäume",
  subtitle: [Modularbeit Graphentheorie],
  authors: authors("Julius Greppmair", "Paul Menhart"),
  doc-type: "Modularbeit",
  language: "de",
  bibliography: bibliography("sources.bib"),
  toc-depth: 2,
  //version: "1",
)

#pagebreak()

= Einleitung

// Worum es geht, wofür man Steinerbäume braucht, und ein Satz als Leitfaden durch die drei
// behandelten Varianten in der Reihenfolge der Taxonomie.
// Quellen: @gilbert1968 (Ursprung der Problemstellung), @rehfeldt2023 (aktueller Stand)

= Methodik

Den Einstieg in das Thema bildete eine breite Recherche in allgemeinen Webquellen und in
der Wikipedia. Ziel war dabei kein vollständiger Überblick, sondern eine erste Orientierung:
Welche Problemstellungen werden unter dem Begriff des Steinerbaums zusammengefasst, worin
unterscheiden sie sich, und welche davon eignen sich für eine eigene Implementierung?

Als fachlicher Ausgangspunkt diente anschließend die Arbeit „Implications, conflicts, and
reductions for Steiner trees“ von Rehfeldt und Koch @rehfeldt2023. Der Beitrag selbst
behandelt Reduktionstechniken für exakte Löser und geht damit über den Umfang dieser Arbeit
hinaus. Nützlich war für uns vor allem seine Einleitung: Sie definiert das
Steinerbaum-Problem in Graphen, ordnet den Stand der Technik ein und verweist auf relevante
Wettbewerbe der letzten Jahre, über die sich aktuelle Fragestellungen erschließen lassen.

Zwei dieser Wettbewerbe haben wir näher betrachtet: die 11. DIMACS Implementation Challenge
von 2014 @dimacs11 und die PACE Challenge 2018 @pace2018web @bonnet2018. Aus den
Wettbewerbsunterlagen ergab sich der nächste Schritt: eine Sichtung der verschiedenen
Problemdefinitionen und ihrer Beziehungen zueinander. Entscheidend war dabei die
Beobachtung, dass sich die geometrischen Varianten unter geeigneten Voraussetzungen auf das
Problem in Graphen zurückführen lassen. Diese Erkenntnis bildete die Basis für die Wahl der
behandelten Themen: Das euklidische und das rektilineare Problem werden theoretisch
behandelt und über diese Reduktion mit dem Graphenproblem verbunden.

Auf dieser Grundlage wurde festgelegt, was selbst umgesetzt wird. Für das Problem in Graphen
haben wir uns für eine eigene Implementierung eines exakten Verfahrens entschieden, um
dessen theoretisches Laufzeitverhalten nicht nur zitieren, sondern auch messen zu können.
Als Vorlage dient Algorithmus 4.6.3 aus Jungnickel, „Graphs, Networks and Algorithms“
@jungnickel1999, der zugleich Grundlage der Lehrveranstaltung ist und das Verfahren
einschließlich seiner Teilalgorithmen vollständig beschreibt.

= Problemtaxonomie

// Kurz halten. Der Hauptteil folgt der hier gesetzten Reihenfolge: euklidisch,
// rektilinear, Graphen.
// Hier einmalig die Notation einführen, sie gilt für alle drei Varianten: Netzwerk (G, w)
// mit positiver Gewichtsfunktion, Terminalknoten R, Steiner-Knoten S = V \ R, r = |R| sowie
// S' ⊆ S für die aufgezählten Teilmengen.
// Quellen: @gilbert1968 (euklidisch), @hanan1966 (rektilinear), @jungnickel1999 (Graphen)

= Euklidisches Steinerbaum-Problem
// Das Euklidische SBP ist eine Besondere variante des SBP. In dieser können die steinerknoten frei platziert werden. Die kantenlänge ist die Euklidische distanz zwischen zwei Terminalen. Um die Optimale lösung für einen Baum zu finden müssen wir die Topologien durchprobieren, da theoretisch jede Topologie die optimale lösung beinhalten könnte. Das bauen/ platzieren des Baums für eine gewählte Topologie ist dann relativ einfach (Melzak oder ..) genauso wie die minimale länge für diesen zu finden.

// durch die nutzung des eukl. raums einer Plane ergeben sich interessante geometische vorrausetzung dafür das ein Baum optimal sein kann (damit ist erstmal der optimale Baum für eine Topologie gemeint und nicht der gesamt optimale Baum für eine Menge an Terminalen). Durch kluges pruning (Geosteiner) können im Bestenfall viele der Topologien ausgeschlossen werden ohne sie komplett zu kennen, das problem bleibt aber natürlich N(p) schwer.

//um die N(p) laufzeit zu umgehen können wir Aproximationen über effizientere algortihmen nutzen

//Die vermutung das der Steinerbaum maximal wurzel 3/2 besser ist als der MST macht das anwenden der Optimalen Steinerbaum lösung eher unattraktiv, Bewissen wurde aber  erst (0,82 bzw. 0,86)


== Optimale Lösung
//für die optimale lösung kann es sein das alle topologien überprüft werden müssen
// die topologien können dann durch melzak oder .. analysiert werden
// 

=== Voraussetzungen und Beweis der optimalen Lösung

// Gegebenenfalls Beweis der 120-Grad-Regel bzw. dass Steiner-Punkte drei Verbindungen haben. 
//Regel für unvollst. bzw. vollständige Bäume
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
// heuristik mit MST und dann 120 grad rgel

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
// und senkrechten Geraden durch die Terminalknoten aufspannen. Damit wird aus einem
// geometrischen Problem mit unendlich vielen Kandidatenpunkten ein endliches
// Graphenproblem.
// Quelle: @hanan1966

= Steinerbaum-Problem in Graphen

== NP-Vollständigkeit

// Entscheidungsvariante NP-vollständig (Karp 1972), Optimierungsvariante NP-schwer.
// Quelle: @karp1972

== Einfache Approximation über den minimalen Spannbaum

// Minimaler Spannbaum über alle Terminalknoten, danach Entfernen der überflüssigen
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

// O(3^r · n + 2^r · n² + n³), also polynomiell, wenn die Anzahl der Terminalknoten
// logarithmisch in n ist. Der Gegensatz ist der interessante Teil: das hier implementierte
// Verfahren ist exponentiell in |S| = n − r, Dreyfus-Wagner dagegen in r. Daraus erklärt
// sich die Form der gemessenen Laufzeitkurve.
// Quelle: @dreyfus1971

= Ausblick: Approximationsverfahren in der Praxis

= Eigenimplementierung und Vergleich mit Standardbibliothek

In der Praxis kommen selten exakte Verfahren zum Einsatz, sondern ausgefeiltere
Approximationen, oft in Verbindung mit Reduktionstechniken, die eine Instanz vor der
eigentlichen Rechnung verkleinern @rehfeldt2023. Diese Verfahren werden hier nicht im Detail
behandelt.

Als Vergleichswert in den Messungen dient eine Approximation aus der Python-Bibliothek
networkx @hagberg2008. Sie liefert einen zulässigen Baum, dessen Gewicht das Optimum nie um
mehr als den Faktor zwei übersteigt und dient als Bezugsgröße für Laufzeit und Güte.

= Experimenteller Aufbau

== Technischer Aufbau

Die Implementierung ist in Python geschrieben und kommt ohne Graphenbibliothek aus. Knoten
sind ganze Zahlen, eine Kante ist ein Tripel aus ihren beiden Endknoten und ihrem Gewicht,
normalisiert, so dass die kleinere Knotennummer zuerst aufgeführt wird.
Ein Graph besteht aus einer Knotenmenge und einer Kantenmenge:

#figure(
  ```python
  class Edge(_Edge):
      u: int
      v: int
      weight: float

  class Graph:
      vertices: set[int]
      edges: set[Edge]
  ```,
  caption: [Die Datentypen, auf denen die Algorithmen arbeiten.],
) <lst:typen>

Darauf aufbauend sind die drei Bestandteile des Verfahrens einzeln implementiert:
`floyd()` für die kürzesten Wege einschließlich Vorgängertabelle, `prim()` für die
Spannbäume und `steiner()` für die Aufzählung samt Rückübersetzung der Wege. Die
Vergleichsnäherung stammt aus networkx. Unsere eigenen Graphen werden dafür konvertiert.

Um den Aufbau herum liegen drei weitere Bausteine: ein Generator für Zufallsinstanzen, ein
Script zur Messung der Laufzeiten und Abspeichern der Ergebnisse als CSV-Datei, sowie Code der die Messtdaten Grafiken weiterverarbeitet.

== Instanzgenerator und Parameter

Die Messinstanzen sind zufällige zusammenhängende Graphen. Erzeugt werden sie in zwei
Schritten: Zuerst entsteht ein zufälliger Spannbaum, indem jeder neue Knoten an einen
bereits verbundenen angehängt wird. Anschließend wird jedes weitere Knotenpaar mit
Wahrscheinlichkeit $p$ zusätzlich verbunden. Der Umweg über den Spannbaum stellt den
Zusammenhang sicher, ohne Graphen zu verwerfen und neu zu ziehen. Die Kantengewichte sind
ganze Zahlen zwischen 1 und 10, die Terminalknoten werden zufällig aus den Knoten gezogen.

#figure(
  ```python
  random.seed(seed)
  instance = random_steiner_graph(vertex_count, edge_probability, terminal_count)
  ```,
  caption: [Eine Instanz ist durch ihre Parameter und den Startwert vollständig bestimmt.],
) <lst:generator>

Damit hat jede Instanz drei Parameter: die Knotenzahl $n$, die Kantenwahrscheinlichkeit $p$
und die Anzahl der Terminalknoten $r$. Der verwendete Startwert des Zufallsgenerators wird
abgespeichert, sodass sich jede einzelne Messung aus ihrer Zeile in der Ergebnisdatei
reproduzieren lässt.

Gemessen wird in drei Reihen, in denen jeweils ein Parameter variiert und die übrigen fest
bleiben: über die Anzahl der Terminalknoten bei $n = 30$ und $p = 0{,}3$, über die
Knotenzahl bei $r = 6$ und $p = 0{,}3$ sowie über die Kantenwahrscheinlichkeit bei $n = 20$
und $r = 5$. Jeder Parameterpunkt wird mit fünf verschiedenen Startwerten wiederholt,
von denen jeweils der Median angegeben wird.

== Ergebnisse

=== Laufzeit über der Anzahl der Terminalknoten

#figure(
  image("images/benchmarks/runtime_by_terminals.png", width: 90%),
  caption: [
    Laufzeit des exakten Verfahrens und der 2-Approximation in Abhängigkeit von der Anzahl
    der Terminalknoten $r$. Zufällige Graphen mit $n = 30$ Knoten und Kantenwahrscheinlichkeit
    $p = 0{,}3$; jeder Punkt ist der Median aus fünf Graphen. Im grau hinterlegten Bereich
    fehlen Messwerte des exakten Verfahrens, weil dort mehr als 60.000 Knotenteilmengen
    aufgezählt werden müssten. Beide Achsen des Laufzeitwerts sind logarithmisch.
  ],
) <fig:laufzeit-terminale>

=== Laufzeit über der Knotenzahl

#figure(
  image("images/benchmarks/runtime_by_vertices.png", width: 90%),
  caption: [
    Laufzeit in Abhängigkeit von der Knotenzahl $n$ bei festen vier Terminalknotenn und
    $p = 0{,}3$. Punkte sind Mediane aus fünf zufälligen Graphen je Größe, die gestrichelten
    Linien sind Ausgleichsgeraden im doppelt logarithmischen Maßstab; der angegebene Exponent
    ist deren Steigung. Die Analyse sagt für das exakte Verfahren den Exponenten 3 voraus,
    da es alle kürzesten Wege zwischen allen Knotenpaaren berechnet.
  ],
) <fig:laufzeit-knoten>

=== Laufzeit über der Kantenwahrscheinlichkeit

#figure(
  image("images/benchmarks/runtime_by_density.png", width: 90%),
  caption: [
    Laufzeit in Abhängigkeit von der Kantenwahrscheinlichkeit $p$, also der
    Wahrscheinlichkeit, mit der ein Knotenpaar durch eine Kante verbunden ist; $p = 1$
    entspricht dem vollständigen Graphen. Zufällige Graphen mit $n = 20$ Knoten und
    $r = 5$ Terminalknotenn, Mediane aus je fünf Graphen. Das exakte Verfahren verläuft flach,
    weil es auf der Distanzmatrix arbeitet, deren Größe allein von der Knotenzahl abhängt.
  ],
) <fig:laufzeit-dichte>

=== Messung gegenüber Vorhersage

#figure(
  image("images/benchmarks/measured_against_prediction.png", width: 90%),
  caption: [
    Gemessene Laufzeit des exakten Verfahrens gegenüber dem Aufwand, den die Analyse
    vorhersagt. Ein Punkt je Messung über alle Messreihen hinweg. Der vorhergesagte Aufwand
    ist $n^3$ für die kürzesten Wege zwischen allen Knotenpaaren zuzüglich eines Spannbaums
    je aufgezählter Teilmenge, mit $n$ Knoten, $r$ Terminalknotenn, $|S| = n - r$ Steiner-Knoten,
    Teilmengengröße $i$ und $k = r + i$ Knoten je Spannbaum. Ein Exponent von 1 würde
    bedeuten, dass die Analyse die Messwerte vollständig erklärt.
  ],
) <fig:messung-vorhersage>

=== Güte der Approximation

#figure(
  image("images/benchmarks/quality_by_terminals.png", width: 90%),
  caption: [
    Gewicht der 2-Approximation geteilt durch das Gewicht des optimalen Steinerbaums, ein
    Punkt je Instanz über alle Messreihen hinweg, waagerecht leicht gestreut, damit gleiche
    Werte sichtbar bleiben. Ein Verhältnis von 1{,}0 bedeutet, dass die Approximation einen
    optimalen Baum gefunden hat. Die garantierte Schranke von 2 wird in keiner Messung auch
    nur annähernd erreicht.
  ],
) <fig:guete-approximation>

== Interpretation der Laufzeitkurve

// Warum die Kurve einen Buckel hat, wenn sich das Verhältnis von Terminalknotenn zu
// Steiner-Knoten verschiebt.
// Quelle: @dreyfus1971 (Gegensatz: exponentiell in r statt in |S|)

= Fazit

// - Im Allgemeinen NP-vollständig (Entscheidungsvariante).
// - Approximationen liefern schnell brauchbare Ergebnisse.
// - Eigenes Ergebnis: die Laufzeit des exakten Verfahrens verläuft nicht monoton, sondern
//   mit einem Buckel über r. Klein für wenige Terminalknoten, unbrauchbar im mittleren Bereich,
//   wieder klein, wenn r sich n nähert, weil über Teilmengen der n − r Steiner-Knoten
//   aufgezählt wird. Praktisch: das exakte Verfahren ist an beiden Enden einsetzbar.
// - Wann welches Verfahren angebracht ist, und dass das über die Reduktion ebenso für die
//   geometrischen Varianten gilt.
// - Ausblick: Dreyfus-Wagner sowie die Reduktionstechniken von Rehfeldt und Koch.
// Quellen: @karp1972, @dreyfus1971, @rehfeldt2023

= Anhang

== Repository

// Link auf das Git-Repository.
