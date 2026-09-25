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

// Quelltextauszüge etwas kleiner setzen, damit die Zeilen nicht umbrechen
#show raw.where(block: true): set text(size: 9pt)

= Einleitung

// Worum es geht, wofür man Steinerbäume braucht, und ein Satz als Leitfaden durch die drei
// behandelten Varianten in der Reihenfolge der Taxonomie.
// Quellen: @gilbert1968 (Ursprung der Problemstellung), @rehfeldt2023 (aktueller Stand)

= Methodik

Den Einstieg in das Thema bildete eine breite Recherche in allgemeinen Webquellen und in
der Wikipedia. Ziel war dabei kein vollständiger Überblick, sondern eine erste Orientierung:
Welche Problemstellungen werden unter dem Begriff des Steinerbaums zusammengefasst, worin
unterscheiden sie sich und welche davon eignen sich für eine eigene Implementierung?

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

Im euklidischen Fall des Steinerbaumproblems liegen die Terminale in der Ebene,
und die Länge einer Kante entspricht dem euklidischen Abstand der verbundenen
Knoten. Es gibt keine vorgegebene Menge möglicher Steinerknoten: Sie dürfen an
beliebigen Stellen der Ebene platziert werden. Der Suchraum ist damit zunächst
kontinuierlich und lässt sich nicht direkt durch Ausprobieren von Kandidaten
durchsuchen.

Die Lösung wird daher in zwei Teilprobleme aufgeteilt. Zunächst wird die
_Topologie_ gewählt, also welche Knoten miteinander verbunden sind. Für eine Topologie lässt sich die optimale Lage der Steinerknoten anschließend
exakt konstruieren, etwa mit dem Algorithmus von Melzak #cite(<melzak1961>).
Die eigentliche Schwierigkeit liegt in der Wahl der Topologie: Ihre Anzahl
wächst superexponentiell mit der Zahl der Terminale. Obwohl das Problem
NP-schwer ist @garey1977euclidean, lösen spezialisierte Verfahren wie
GeoSteiner zufällige Instanzen mit über tausend Terminalen exakt, indem sie
aussichtslose Teilbäume früh verwerfen #cite(<juhl2018>).

Gleichzeitig ist der mögliche Vorteil gegenüber dem MST begrenzt. Nach der
Vermutung von Gilbert und Pollak @gilbert1968 ist ein minimaler Steinerbaum
mindestens #box[$sqrt(3)\/2$ ≈ 0,866-mal] so lang wie der MST. Die Ersparnis
beträgt demnach höchstens etwa 13,4 %. Auf zufälligen Instanzen liegt sie im
Mittel sogar nur bei rund 3 % #cite(<juhl2018>). Es stellt sich die frage wie nahe wir an die Optimale Lösung mit MST und einfachen Heuristiken kommen können und was bis welcher Terminal menge wir noch die Optimale Lösung finden können.

// Dieser Abschnitt untersucht daher, [wie weit eine exakte Lösung über die
// Aufzählung von Topologien reicht und wie nah MST und eine einfache Heuristik
// an das Optimum herankommen]. Dazu fasst @sec:eukl-grundlagen die benötigten
// Eigenschaften optimaler Bäume zusammen, @sec:eukl-implementierung beschreibt
// die Implementierung und @sec:eukl-experimente die Ergebnisse auf Instanzen der
// OR-Library @beasley1990 und auf zufällig erzeugten Instanzen.


== Grundlagen

=== Vollständige und unvollständige Steinerbäume

Ein Steinerbaum ist _vollständig_, wenn alle Terminale Blätter sind (Grad 1).
Hat mindestens ein Terminal Grad 2 oder 3, ist der Baum _unvollständig_. Damit
ein unvollständiger Baum optimal sein kann, müssen alle Winkel an diesen
Terminalen mindestens 120° betragen; sonst könnte der Baum durch einen
zusätzlichen Steinerknoten verkürzt werden (siehe //eignschaften).

Jeder unvollständige Baum lässt sich an seinen Terminalen mit Grad 2 oder 3 in
vollständige Teilbäume zerlegen @hwang1992. Für exakte Verfahren genügt es
daher, vollständige Steinerbäume für Teilmengen der Terminale zu berechnen und
diese anschließend zu kombinieren.

Beim Berechnen einer vollständigen Topologie kann ein Steinerknoten auf ein
Terminal fallen, sodass die Kante zwischen beiden die Länge 0 hat. Der Baum ist
dann _degeneriert_: Für diese Topologie existiert damm kein echter vollständiger
Steinerbaum. Die Kante der Länge 0 lässt sich kontrahieren, und es entsteht ein
unvollständiger Baum gleicher Länge. Dieser ist der kürzeste Baum, der sich mit
der ursprünglichen Topologie erreichen lässt, muss aber nicht Global optimal sein.
Da er sich wiederum in vollständige Teilbäume kleinerer Teilmengen zerlegen lässt, die ohnehin betrachtet werden, können degenerierte Ergebnisse in exakten Verfahren verworfen werden.


=== Eigenschaften optimaler Lösungen <sec:eigenschaften>

// === Eigenschaften optimaler Lösungen    

//  Für die Optimale lösung einer Topologie müssen alle Winkel zwischen Kanten mindestens 120 grad haben, desweiteren sind alle Steinerknoten Grad 3. Falls es einen Vollständigen Optimalen Baum besitzt dieser für n Terminale = n - 2 Steinerknoten, für denn unvollständigen fall sinde es maximal n - 2 Steinerknoten

Ein minimaler Steinerbaum erfüllt die folgenden notwendigen Eigenschaften
@gilbert1968:

+ *Winkel:* An jedem Knoten schließen je zwei Kanten einen Winkel von
  mindestens 120° ein.
+ *Grad:* Jeder Steinerknoten hat genau Grad 3; die Winkel zwischen seinen
  Kanten betragen also genau 120°. Terminale haben höchstens Grad 3.
+ *Anzahl:* Bei $n$ Terminalen gibt es höchstens $n - 2$ Steinerknoten, in
  einem vollständigen Baum genau $n - 2$.

_Begründung._ (1) Schließen zwei Kanten $v a$ und $v b$ einen Winkel unter
120° ein, ist $v$ nicht der Fermat-Punkt des Dreiecks $v a b$. Ersetzt man die
beiden Kanten durch Verbindungen von $v$, $a$ und $b$ zum Fermat-Punkt, wird
der Baum echt kürzer. (2) Ein Steinerknoten mit Grad 1 kann entfernt werden,
einer mit Grad 2 lässt sich nach der Dreiecksungleichung durch eine gerade
Kante ersetzen. Ab Grad 4 summieren sich mindestens vier Winkel zu 360°,
sodass einer höchstens 90° beträgt, im Widerspruch zu (1). Dasselbe Argument
begrenzt den Grad der Terminale. (3) Ein Baum mit $n$ Terminalen und $s$
Steinerknoten hat $n + s - 1$ Kanten. Da jede Kante zwei Endpunkte hat, gilt
für die Gradsumme
$ sum_(t in R) deg(t) + 3s = 2(n + s - 1), quad "also" quad
  s = n - 2 - sum_(t in R) (deg(t) - 1). $
Da jedes Terminal mindestens Grad 1 hat, folgt $s <= n - 2$, mit Gleichheit
genau dann, wenn alle Terminale Blätter sind.

Diese Eigenschaften gelten für den global optimalen Baum. Für den kürzesten
Baum einer _festen_ Topologie gilt nur die 120°-Regel an den (nicht
degenerierten) Steinerknoten. Liegt dort an einem Terminal ein Winkel unter
120°, zeigt das, dass eine andere Topologie kürzer ist.

=== Anzahl der Topologien <sec:topologien>

// === Anzahl der Topologien 
// Zur veranschaulichung der vollen Topologien, wir starten mit Genau einer Topologie für 3 Terminale, wenn wir jetzt ein weiteres Terminal hinzufügen, trennen wir eine beliebige kante mit einem neuen Steinerknoten an denn wir das Terminal hängen. Das heißt in unserem fall sind das 3 möglichkeiten für einen weiteres Terminal schon die 3 möglichkeiten mal weiter 5 also schon 15. 
// (2n − 5)!! - superfakultät weil wir von 3 kanten direkt auf 5 kanten kommen etc. und superexponentiel

// Für unvollständige Topologien gibt es nochmal xy z .... 

Vollständige Topologien bauen wir schrittweise auf @hwang1992. Eine
vollständige Topologie mit $k - 1$ Terminalen hat $2k - 5$ Kanten. Um das
$k$-te Terminal hinzuzufügen, wird eine beliebige Kante durch einen neuen
Steinerknoten geteilt und das Terminal dort angehängt; dafür gibt es $2k - 5$
Möglichkeiten.
// Umgekehrt entsteht jede vollständige Topologie mit $k$
// Terminalen auf genau eine Weise, denn entfernt man das Terminal $k$ und seinen
// Steinerknoten, erhält man die Vorgänger-Topologie eindeutig zurück. 
Damit gibt
es
$ product_(k=4)^n (2k - 5) = 1 dot 3 dot 5 dot dots dot (2n - 5) = (2n - 5)!! $
vollständige Topologien (Doppelfakultät). Da jeder Schritt mit einem
wachsenden Faktor multipliziert, wächst die Anzahl schneller als jede
Exponentialfunktion $c^n$.

Lässt man auch unvollständige Topologien zu, steigt die Zahl nochmals deutlich
(@tab:topologien, eigene Berechnung). Exakte Verfahren zählen diese jedoch
nicht direkt auf: Da jeder unvollständige Baum in vollständige Teilbäume
zerfällt, genügt es, vollständige Topologien für alle Teilmengen der
Terminale zu betrachten und diese zu kombinieren. Die Zahl dieser Kandidaten
$sum_(k=2)^n binom(n, k) (2k - 5)!!$ (mit einer einzelnen Kante für $k = 2$)
ist um Größenordnungen kleiner.

#figure(
  table(
    columns: 4,
    align: right,
    table.header([$n$], [vollständig], [alle Topologien], [Teilbaum-Kandidaten]),
    [4], [3], [31], [13],
    [6], [105], [5.625], [275],
    [8], [10.395], [2.643.795], [22.029],
    [10], [2.027.025], [2.382.538.725], [3.986.175],
  ),
  caption: [Anzahl vollständiger Topologien, aller Topologien (Steinerknoten
    mit Grad 3, Terminale mit Grad höchstens 3) und vollständiger Teilbäume
    über alle Teilmengen der Terminale.],
) <tab:topologien>


== Exakte Lösung <sec:eukl-exakt>  


=== Algorithmus von Melzak <sec:melzak>

Melzak zeigte als Erster, dass sich das euklidische Steinerbaumproblem in
endlich vielen Schritten exakt lösen lässt @melzak1961. Sein Verfahren besteht
aus zwei Teilen: einer geometrischen Konstruktion, die für eine feste
vollständige Topologie den optimalen Baum liefert, und einer Suche über alle
Topologien.

==== Konstruktion für eine feste Topologie

_Vorwärts._ Hat ein Steinerknoten $s$ zwei Nachbarn $a$ und $b$ mit bekannter
Position, wird über der Strecke $a b$ ein gleichseitiges Dreieck errichtet.
Seine dritte Ecke $e$ ersetzt $a$, $b$ und $s$ und wird mit dem dritten
Nachbarn $c$ von $s$ verbunden. Die Länge bleibt dabei erhalten: Für jeden
Punkt $s$ auf dem Kreisbogen über $a b$ gegenüber von $e$ gilt
$|s a| + |s b| = |s e|$. Die Ecke $e$ muss auf der vom Rest des Baums
abgewandten Seite von $a b$ liegen. Da diese Seite ohne die Positionen der
übrigen Steinerknoten nicht bekannt ist, werden beide Seiten getestet. Nach
$k - 2$ Schritten bleibt eine einzige Kante übrig, deren Länge der Länge des
gesamten Baums entspricht.

_Rückwärts._ Die Schritte werden in umgekehrter Reihenfolge rückgängig
gemacht. Der Steinerknoten $s$ liegt jeweils im Schnittpunkt der Strecke $e c$
mit dem Umkreis des Dreiecks $a b e$. Liegt dieser Schnittpunkt nicht auf der
Strecke oder nicht auf dem Bogen zwischen $a$ und $b$, existiert für diese
Seitenwahl kein gültiger Baum. Scheitern alle Seitenwahlen, ist die Topologie
nicht realisierbar und wird verworfen.

==== Vom vollständigen Teilbaum zum optimalen Baum

Da jeder Steinerbaum in vollständige Teilbäume zerfällt
(TODO), wird zunächst für jede Teilmenge $X$ der Terminale der
beste vollständige Teilbaum $"FST"(X)$ bestimmt. Der optimale Baum für $X$ ist
dann entweder dieser vollständige Teilbaum oder die Vereinigung zweier optimaler
Bäume, die sich genau ein Terminal teilen:
$ "Best"(X) = min lr({ "FST"(X), min_(t in X, A union B = X, A inter B = {t})
  "Best"(A) + "Best"(B) }). $
Die Implementierung berechnet dies als dynamische Programmierung von kleinen
zu großen Teilmengen, sodass jedes Ergebnis nur einmal berechnet wird.

==== Laufzeit

Für eine Topologie mit $k$ Terminalen sind $k - 2$ Reduktionsschritte nötig,
mit dem Testen beider Seiten also $O(k dot 2^(k-2))$ Operationen. Ist die
zyklische Reihenfolge der Terminale im Baum bekannt, legt sie die Seiten
eindeutig fest, und die Konstruktion gelingt in $O(k)$ @hwang1986. Über alle
Teilmengen ergeben sich
$ sum_(k=2)^n binom(n, k) (2k - 5)!! dot 2^(k-2) $
Konstruktionen. Die anschließende Kombination betrachtet
$sum_k binom(n, k) dot k dot 2^(k-1) = n dot 3^(n-1)$ Aufteilungen und ist
damit vergleichsweise günstig. Die Laufzeit wird also von der
superexponentiellen Zahl der Topologien dominiert.






=== Optimale Lösung
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

Beim rektilinearen Problem dürfen Verbindungen nur waagerecht und senkrecht verlaufen.
Diese Einschränkung wirkt zunächst willkürlich, ist
aber die Geometrie, in der häufig Leiterbahnen auf Platinen und in integrierten Schaltungen
verlegt werden.

== Hanan-Gitter und Reduktion auf das Graphenproblem

Legt man durch jeden
Terminalknoten je eine waagerechte und eine senkrechte Gerade, so entsteht ein Gitter,
von dem gezeigt werden kann, dass ein optimaler rektilinearer Steinerbaum darauf existiert.
Diese Konstruktion geht auf Hanan zurück @hanan1966.

Damit wird aus einem Problem mit unendlich vielen Kandidatenpunkten eines mit endlich
vielen. Bei $r$ Terminalknoten hat das Gitter höchstens $r^2$ Schnittpunkte.
Relevant ist dabei, dass sich diese Kandidatenpunkte allein aus der Lage der Terminalknoten
ergeben und nicht davon abhängen, wie der Baum am Ende verläuft.

Die Konstruktion lässt sich noch verkleinern, da ein Gitterknoten,
in dessen einem Quadranten kein Terminalknoten liegt, von keinem optimalen Baum als
Verzweigung benötigt wird und daher entfernt werden kann.

Aus dem verbleibenden Gitter wird schließlich ein Graph. Die Schnittpunkte werden zu Knoten,
die Gitterstrecken zwischen benachbarten Schnittpunkten zu Kanten und als Kantengewicht
dient der Abstand der beiden Endpunkte. Die ursprünglichen Terminalknoten bleiben
Terminalknoten. Ab diesem Punkt wird keine geometrische Information mehr benötigt und übrig
bleibt genau das Steinerbaum-Problem in Graphen, um das es im Folgenden geht.

= Steinerbaum-Problem in Graphen

Gegeben ist ein Netzwerk $(G, w)$ mit zusammenhängendem Graphen $G = (V, E)$ und positiver
Gewichtsfunktion $w$, dazu eine Menge $R subset.eq V$ von Terminalknoten. Gesucht ist ein
Baum $T subset.eq E$ minimalen Gewichts $w(T)$, der alle Knoten aus $R$ verbindet. Die
übrigen Knoten $S = V without R$ dürfen dabei verwendet werden, müssen es aber nicht.

Sind alle Knoten Terminalknoten, gilt also $R = V$,
so ist der gesuchte Baum ein minimaler Spannbaum und mit den bekannten Verfahren in
polynomieller Zeit zu bestimmen. Besteht $R$ dagegen nur aus zwei Knoten, so ist die Lösung
ein kürzester Weg. Schwierig wird erst der Bereich dazwischen, in dem
auszuwählen ist, welche der Steiner-Knoten tatsächlich gebraucht werden.

== NP-Vollständigkeit

Genau diese Auswahl macht das Problem schwer. Die Entscheidungsvariante, also die Frage, ob
ein Baum mit Gewicht höchstens $L$ existiert, gehört zu den ursprünglichen 21 Problemen, für
die Karp die NP-Vollständigkeit gezeigt hat @karp1972. Das hier behandelte Optimierungsproblem,
das nach dem tatsächlich minimalen Gewicht fragt, ist daher NP-schwer.

== Einfache Approximation über den minimalen Spannbaum

Eine Näherungslösung kann in polynomieller Zeit gefunden werden, indem man die kürzesten Wege
zwischen allen Terminalknoten sucht und auf diesen Abständen einen minimalen Spannbaum
über $R$ allein definiert. Anschließend ersetzt man jede seiner Kanten durch den zugehörigen kürzesten Weg.
Das Ergebnis ist ein zulässiger Steinerbaum und sein Gewicht überschreitet das Optimum nie um mehr als den Faktor zwei.

In vielen Fällen ignoriert diese Konstruktion allerdings Steinerknoten, die zwar auf keinem direkten kürzesten Pfad
zwischen zwei Terminalknoten liegen, aber effiziente Knotenpunkte für die Verbindung mehrerer Teilgraphen darstellen können.

= Implementierter Algorithmus

Umgesetzt wurde Algorithmus 4.6.3 aus Jungnickel @jungnickel1999. Er bestimmt den
minimalen Steinerbaum exakt und beruht auf einer einfachen Überlegung: Stünde bereits fest,
welche Steiner-Knoten im optimalen Baum vorkommen, so wäre nur noch ein minimaler Spannbaum
über diese Knoten und die Terminalknoten zu bestimmen. Da das nicht feststeht, werden alle
in Frage kommenden Teilmengen durchprobiert.

Der Ablauf besteht aus vier Schritten:

+ Berechne die kürzesten Wege zwischen allen Knotenpaaren.
+ Zähle alle Teilmengen $S' subset.eq S$ mit $|S'| <= r - 2$ auf.
+ Bestimme für jede davon einen minimalen Spannbaum über $R union S'$, wobei als
  Kantengewicht der kürzeste Abstand zwischen zwei Knoten dient und merke dir den
  mit der niedrigsten Summer von Kantengewichten.
+ Ersetze die Kanten dieses Spannbaums durch die kürzesten Wege, für die sie stehen.

Der dritte Schritt arbeitet nicht auf dem ursprünglichen Graphen, sondern auf der
_metrischen Hülle_: dem vollständigen Graphen über die ausgewählten Knoten, in dem das Gewicht
einer Kante der kürzeste Abstand ihrer Endknoten im Originalgraphen ist. In dieser Hülle ist jede
Kante vorhanden, weshalb jede Knotenteilmenge zusammenhängend ist und immer ein Spannbaum existiert.

#figure(
  ```python
  max_steiner_count = min(len(terminals) - 2, len(steiner_vertices))
  for i in range(0, max_steiner_count + 1):
      for selected_steiner_vertices in itertools.combinations(steiner_vertices, i):
          vertex_subset = terminals | set(selected_steiner_vertices)
          tree_edges, cost = prim(vertex_subset, distances)

          if cost < best_weight:
              best_weight = cost
              best_tree_edges = tree_edges
  ```,
  caption: [Kern des Verfahrens: Aufzählung der Teilmengen und Auswahl des minimalen
    Spannbaums.],
) <lst:steiner>

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
Script zur Messung der Laufzeiten und Abspeichern der Ergebnisse als CSV-Datei, sowie
Code, der die Messdaten zu Grafiken weiterverarbeitet.

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
bleiben: über die Anzahl der Terminalknoten bei $n = 30$ und $p$ = 0,3, über die
Knotenzahl bei $r = 6$ und $p$ = 0,3 sowie über die Kantenwahrscheinlichkeit bei $n = 20$
und $r = 5$. Jeder Parameterpunkt wird mit fünf verschiedenen Startwerten wiederholt,
von denen jeweils der Median angegeben wird.

== Ergebnisse

Alle Messungen verwenden zufällige zusammenhängende Graphen mit $n$ Knoten,
Kantenwahrscheinlichkeit $p$ und $r$ Terminalknoten. $|S| = n - r$ ergibt die übrigen
Knoten.

Um abzuschätzen, ob die Implementierung plausibel ist, wird zunächst überprüft,
ob die Laufzeit dem entspricht, was die theoretische Laufzeitkomplexität erwarten lässt.
@fig:messung-vorhersage trägt die gemessene Laufzeit gegen den vorhergesagten Aufwand auf,
also gegen $n^3$ für die kürzesten Wege zwischen allen Knotenpaaren zuzüglich eines
Spannbaums je aufgezählter Teilmenge. Über 270 Läufe und vier Größenordnungen hinweg ergibt
sich ein Exponent von 0,94 bei $R^2$ = 0,99. Die Messwerte folgen der Vorhersage also
über den gesamten Bereich, wachsen aber etwas langsamer. Der Unterschied geht
vermutlich auf einen konstanten Anteil zurück, der bei kleinen Instanzen überwiegt.

#figure(
  image("images/benchmarks/measured_against_prediction.png", width: 90%),
  caption: [Gemessene Laufzeit des exakten Verfahrens gegenüber dem vorhergesagten Aufwand.],
) <fig:messung-vorhersage>

Wächst nur der Graph, während die Zahl der Terminalknoten fest bleibt, so bleibt die
Laufzeit polynomiell, denn die Aufzählung ist durch $|S'| <= r - 2$ beschränkt, sodass kein
exponentieller Anteil entsteht. @fig:laufzeit-knoten zeigt das für $r = 6$ mit einem
gemessenen Exponenten von 5,5.
#figure(
  image("images/benchmarks/runtime_by_vertices.png", width: 90%),
  caption: [
    Laufzeit über der Knotenzahl bei sechs Terminalknoten, mit angepassten Exponenten.
  ],
) <fig:laufzeit-knoten>

Die Kantenwahrscheinlichkeit kommt in der Komplexität nicht vor, was zunächst unintuitiv
wirkt. @fig:laufzeit-dichte bestätigt es. Zwischen $p$ = 0,1 und $p = 1$ bleibt das exakte
Verfahren bei rund neun Millisekunden, während sich die Kantenzahl verzehnfacht. Der
Grund ist, dass nach dem ersten Schritt nicht mehr der Graph selbst, sondern die
Distanzmatrix verarbeitet wird, was den Kanten in einem vollständigen Graphen entspricht.
Die Approximation reagiert leicht auf die Dichte, weil sie auf den tatsächlichen Kanten
arbeitet.

#figure(
  image("images/benchmarks/runtime_by_density.png", width: 90%),
  caption: [Laufzeit über der Kantenwahrscheinlichkeit bei fester Graphgröße.],
) <fig:laufzeit-dichte>

Der eigentliche Kostentreiber ist die Anzahl der Terminalknoten.
@fig:laufzeit-terminale zeigt keinen monotonen Anstieg, sondern
einen Buckel. Bei $r = 11$ steigt die Laufzeit des exakten Verfahrens bis auf etwa zwölf
Sekunden an, fällt danach aber wieder auf sechs Millisekunden bei $r = 30$.
Grund dafür ist, dass bei gleichbleibender Gesamtknotenzahl keine Steinerknoten mehr übrig bleiben
wenn $r = 30$ erreicht ist. Das Problem reduziert sich dann auf das Finden des minimalen Spannbaums.
Da der Suchalgorithmus Teilmengen von maximal $r -2$ Steinerknoten absucht,
ist auch bei niedrigen Werten von $r$ die Laufzeit gering.
Das Maximum liegt dort, wo das Produkt aus der Anzahl
dieser Teilmengen und ihrer Größe am größten wird, also bei etwa einem Drittel der Knoten
als Terminalknoten. Die Approximation bleibt über den gesamten Bereich im
Millisekundenbereich.

#figure(
  image("images/benchmarks/runtime_by_terminals.png", width: 90%),
  caption: [Laufzeit über der Anzahl der Terminalknoten bei 30 Knoten.],
) <fig:laufzeit-terminale>

Zuletzt wurde gemessen, was die Approximation an Güte kostet. @fig:guete-approximation zeigt für
dieselben Instanzen das Verhältnis aus approximiertem und optimalem Gewicht.
In 59 Prozent der 145 Fälle findet die Approximation den optimalen Baum, im
Mittel liegt sie 2,2 Prozent darüber, im schlechtesten Einzelfall 18 Prozent. Die
garantierte Schranke von 2 wird damit nie erreicht.

Interessant ist, dass die schlechtesten Einzelfälle dort gruppieren, wo auch die Laufzeit des
exakten Suchalgorithmus hoch ist. Die Erklärung ist dieselbe. Dort gibt es viele
Steiner-Knoten, die tatsächlich etwas beitragen können und genau deren Auswahl trifft die
Approximation nicht. Bei sehr wenigen Terminalknoten ist der gesuchte Baum nahezu ein
kürzester Weg, bei sehr vielen nahezu ein minimaler Spannbaum. In beiden Fällen bleibt wenig zu
entscheiden und die Näherung trifft das Optimum fast immer. Wie zu erwarten ist die Approximation
also gerade dort am ungenauesten, wo das exakte Verfahren am teuersten ist.

#figure(
  image("images/benchmarks/quality_by_terminals.png", width: 90%),
  caption: [
    Verhältnis aus approximiertem und optimalem Gewicht, ein Punkt je Instanz, bei 30
    Knoten. Für bessere Lesbarkeit sind die Punkte waagerecht leicht gestreut.
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
