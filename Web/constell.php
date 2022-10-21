<!DOCTYPE html>
<html lang="en-GB">
<head>
<title>Constellations - Lemizh grammar and dictionary</title>
<meta charset="utf-8">
<meta name="author" content="Anypodetos">
<meta name="description" content="Astronomical constellations in Lemizh">
<meta name="viewport" content="width=device-width, initial-scale=1">

<link rel="stylesheet" href="../main.css">
<style>
#starmachine2000 iframe {max-width: 100%; border-width: 0}

#constells {display: flex}

@media screen {
  .large #cotable-wrapper {display: none}
  #cotable {overflow-y: auto; height: 40em; border: 1px solid silver; border-left: none}
  #cotable table {width: 100%; margin: 0}
  #cotable th {position: sticky; top: 0; border-top: none; border-bottom: none; background-image: linear-gradient(to top, silver 2px, white 1px, #f1faf6)}
  #cotable tr:nth-child(2) td {border-top: none}
  #cotable tr:last-child td {border-bottom: none}
}
#cotable-wrapper>p {margin-top: 0}
#cotable {margin-right: 2em}
#cotable tr>:nth-child(2) {color: #006137}
#cotable tr>:nth-child(4) a {text-decoration: none; cursor: pointer}

#coinfo {width: 50%; margin-top: 4em}
.large #coinfo {width: 100%; margin-top: 0}

#sky {border: none}
#enlarge {position: absolute; padding: 0.5em; cursor: pointer}
#enlarge::before {content: '⇱'}
.large #enlarge::before {content: '⇲'}

@media (max-width: 72em) {
  #constells {flex-direction: column}
  #coinfo {width: 100%; margin-left: 0; margin-top: 1em}
}
@media print {
  #cotable tr>:last-child {display: none}
}
</style>
<link rel="icon" href="../images/favicon.png" sizes="44x44">
<link rel="icon" href="../images/favicon2.png" sizes="85x85">
<link rel="index" href="..">
<link rel="prev" href="maths.html">
<link rel="next" href="pragmatics.php">
<script src="../ajax.js"></script>
<script>
<?php
include 'constell/constelllist.php';
include 'constell/info.php';

$constellId = getConstellId($_GET['c']);

echo "const constellDescr = [\n";
$constellDescr = '';
for ($n = 0; $n<count($constells); $n++) {
  $descr = constellInfo($n+1, true);
  if ($n==$constellId-1) $constellDescr = $descr;
  echo "'".$descr."',\n";
}
echo "];\n";
?>

function showStarMachine() {
  event.preventDefault();
  const starmachine2000 = document.getElementById('starmachine2000');
  starmachine2000.firstElementChild.innerHTML = '<iframe width="840" height="472" src="https://www.youtube-nocookie.com/embed/rEeiRXOlWUE?autoplay=1" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
  starmachine2000.style.background = "#ede8d0";
}

function scrollToConstell(constell, smooth) {
  if (constell>0) {
    const cotable = document.getElementById('cotable');
    const cotableRect = cotable.getBoundingClientRect();
    cotable.scrollBy({top: document.getElementById('c'+constell).getBoundingClientRect().top-(cotableRect.top+cotableRect.height/2), behavior: smooth ? 'smooth' : 'instant'});
  }
}

function changeConstell(constell, rot = true, scroll = false) {
  if (rot) {
    event.preventDefault();
    const sky = document.getElementById('sky');
    (sky.contentWindow || sky).changeConstell(constell);
  }
  for (i = 1; i<=constellDescr.length; i++) document.getElementById('c'+i).style.boxShadow = i==constell ? 'inset 0 0 2px 3px gray' : '';
  if (scroll) scrollToConstell(constell, true);
  if (constell>0) document.getElementById('coentry').innerHTML = constellDescr[constell-1];
}

function sizeSky(changeSizing = false) {
  sizeConstellSky(document.getElementById('constells'), 500, changeSizing);
}
</script>
</head>

<body onScroll="scrollMain()" onResize="sizeSky()">
<form id="search" method="get" action="../search.php" title="Search the Lemizh website" onFocusin="focusSearch()">
<input type="text" name="q" placeholder="Search site">
<button>🔎</button>
</form>
<header><a href=".." rel="index" title="Home"><span lang="x-lm">lemÌc.</span> Lemizh grammar and dictionary</a></header>
<nav><div id="skip"><a href="#main">Skip to content</a></div>
<ul id="tabs">
<li><a href=".." accesskey="h"><kbd>H</kbd>ome</a></li>
<li><a href="../tutorial/index.html" accesskey="t"><kbd>T</kbd>utorial</a></li>
<li><a href="../nutshell/index.html" accesskey="n">in <kbd>N</kbd>utshells</a></li>
<li><a href="../lemeng/index.php" accesskey="l"><span lang="x-lm"><kbd>l</kbd>emÌc.</span>/English</a></li>
<li><a href="../englem/index.php" accesskey="e"><kbd>E</kbd>nglish/<span lang="x-lm">lemÌc.</span></a></li>
<li><a href="index.html" accesskey="a" class="this"><kbd>A</kbd>ppendix</a></li>
</ul>
<ul id="left">
<li><a href="index.html">Overview</a></li>
<li><a href="time.php">Time</a></li>
<li><a href="date.php">Date</a></li>
<li><a href="measures.html">Measures</a></li>
<li><a href="maths.html">Mathematics</a></li>
<li><span>Constellations</span></li>
<li><a href="pragmatics.php" class="prag" title="A sketch of pragmatics I. Relevance">Pragmatics I</a></li>
<li><a href="pragmatics2.php" class="prag" title="A sketch of pragmatics II. Triggers">Pragmatics II</a></li>
<li><a href="pragmatics3.php" class="prag" title="A sketch of pragmatics III. Discourse">Pragmatics III</a></li>
<li><a href="texts.html">Texts</a></li>
</ul>
</nav>

<main id="main" onScroll="scrollMain()">
<h1 id="top">Constellations</h1>
<blockquote id="starmachine2000" class="center">
<p><a rel="external" href="https://www.youtube.com/watch?v=rEeiRXOlWUE" onClick="showStarMachine()">☆</a></p>
<footer>(Wintergatan. <cite>Starmachine2000</cite>)</footer>
</blockquote>

<div class="float"><img src="../images/construct.png" width="147" alt="Under construction"><br>
The constellation descriptions are under construction.<br><!-- ALSO REMOVE FROM CONSTELLN.PHP ! -->
Please have patience!</div>

<p>The constellations used in the Lemizh world are ultimately based on the ancient Greek ones, resulting in overlaps with ours. Some, however, including the ones too far south to be visible from the Mediterranean, were named in the 13<sup>th</sup> and 14<sup>th</sup> centuries (of our calendar) and are unrelated to our tradition.</p>
<p>The stars in each constellation are numbered, with the brightest stars (brighter than an apparent magnitude of about 4, which corresponds to a Lemizh star brightness of 3) having mostly one-digit numbers, and stars visible to the naked eye under very good conditions (magnitude ~6.3, Lemizh brightness zero) having at most two digits.</p>

<p class="rem"><span title="Remark."></span> Lemizh star brightness is defined as the binary logarithm of a star’s illuminance in Lemizh units (<span lang="x-lm" title="gomüsdmỳt.">gomUsdmÌt.</span>, <span title="gᵒ" lang="x-lm">g<sup class="power">o</sup></span>, see <a href="measures.html" title="Units of measurement">Units of measurement</a>), plus 35. It equals 8.332&nbsp;−&nbsp;1.329&nbsp;×&nbsp;<i>m</i>, where <i>m</i> is the apparent magnitude in our system.</p>

<table class="x exa"><!-- Examples: Stars -->
<tr><th rowspan="2" title="Example."></th>
<td lang="x-lm" title="‘D’ǜ fxỳzhor.">&lt;D&gt;Ù fxÌcor.</td><td class="literal">[star] <a href="../tutorial/8.html#numbering" title="Numbering">number</a> 13 in the Dragon</td><td>Beta Ursae Minoris (Kochab)</td></tr>
<tr><td colspan="3" class="igloss">‘13’-<abbr class="gloss" title="benefactive">ben</abbr><sup>1</sup> dragon-<abbr class="gloss" title="accusative">acc</abbr>-<abbr class="gloss" title="scenic">sce</abbr><sup>2</sup>.</td></tr>
</table>

<p>Designations for fainter stars have three or more digits, and those for nonstellar objects include a letter for the object type plus one or more digits, again depending on brightness.</p>
<p>The Milky Way is called <span lang="x-lm" title="rhizwsngỳw.">RizwsnÌw.</span> ‘street of snow’. The word is a popular test of foreigners’ pronunciation skills.</p>

<h2 id="sphere">Sky sphere</h2>
<div id="constells">
<div id="cotable-wrapper">
<p>The sky sphere depicts the <?php echo count($constells).' constellations with '.$starCount ?> naked-eye stars. The links in the following table lead to the relevant entries in the dictionary.</p>
<div id="cotable"><table>
<tr><th>Lemizh</th><th>Translation</th><th>(Roughly) corresponds to&nbsp;/ overlaps with</th><th><a onClick="changeConstell(0)" title="Light up all constellations">🔎</a></th></tr>
<?php
asort($constells);
foreach ($constells as $i => $cdata)
  echo '<tr id="c'.($i+1).'"'.($i+1==$constellId ? ' style="box-shadow: inset 0 0 2px 3px gray"' : '').'><td lang="x-lm" title="'.lemtitle($cdata[1]).'"><a href="../le.php?'.dictEntry($i+1).'">'.
    $cdata[1].'</a></td><td>'.$cdata[0].'</td><td>'.str_replace('&', '&amp;', $cdata[3]).'</td><td><a href="?c='.($i+1).'#coinfo" onClick="changeConstell('.($i+1).')" title="Show the '.$cdata[0].
    '">🔎</a></td>'."</tr>\n";
?>
</table></div></div>

<div id="coinfo">
<script>
document.write('<a id="enlarge" onClick="sizeSky(true)"></a>');
</script>
<iframe id="sky" src="constell/webgl.php?width=500&amp;<?php echo ($constellId>0 ? 'c='.$constellId : 'a=18.15&amp;d=46') ?>" width="500" height="100"></iframe>
<div id="coentry"><?php
if ($constellId>0) {
  echo "\n".$constellDescr."\n";
  echo "<script>\nscrollToConstell(".$constellId.", false);\n</script>\n";
}
?></div></div>
</div>

<p id="forward"><a href="pragmatics.php" rel="next" title="A sketch of pragmatics I. Relevance">A sketch of pragmatics I</a></p>
<a href="#top" onClick="scrollToTop()" id="totop" title="Go to top"></a>
<footer>
<p>Last significant change to this page: 18 Apr 2022<br>
Last change to the database: <?php echo $modified ?></p>
<div><a href="https://creativecommons.org/licenses/by-sa/4.0/" class="linkimage" rel="external license" title="Available under a Creative Commons licence"><img src="../images/cc.svg" width="88" height="31" alt="Creative Commons BY-SA License"></a>&emsp;<a href="https://validator.w3.org/check/referer" referrerpolicy="no-referrer-when-downgrade" class="linkimage" rel="external" title="Check HTML 5"><img src="../images/html5.svg" width="27" height="38" alt="Check HTML 5"></a>&nbsp;<a href="https://jigsaw.w3.org/css-validator/check/referer" referrerpolicy="no-referrer-when-downgrade" class="linkimage" rel="external" title="Check CSS 3"><img src="../images/css3.svg" width="27" height="38" alt="Check CSS 3"></a><br>
See <a href="../home/terms.html">Terms of use</a> for details on copyright and licensing.</div>
</footer>
</main>

</body>
</html>