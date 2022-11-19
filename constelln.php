<!DOCTYPE html>
<html lang="en-GB">
<head>
<?php
include 'constell/constelllist.php';
include 'constell/stardata.php';
include 'constell/info.php';
$constellId = getConstellId($_GET['c']);
echo "<title>Constellation ".($constellId>0 ? $constells[$constellId-1][0]: 'doesn’t exist')." - Lemizh grammar and dictionary</title>\n";
?>
<meta charset="utf-8">
<meta name="author" content="Anypodetos">
<meta name="description" content="Astronomical constellations in Lemizh">
<meta name="viewport" content="width=device-width, initial-scale=1">

<link rel="stylesheet" href="../main.css">
<style>
span[onMouseOver] {text-shadow: 1px 1px 1px rgba(0,97,55,0.6)}

#sky-wrapper {float: right; position: sticky; top: 2em; margin-left: 2em}
#sky-wrapper.large {float: none; position: static; margin-left: 0}
#sky {border: none}
#enlarge {position: absolute; padding: 0.5em; cursor: pointer}
#enlarge::before {content: '⇱'}
.large #enlarge::before {content: '⇲'}

#startable tr td:nth-child(4) {text-align: right}
#startable tr :nth-child(5) {text-align: right; font-weight: bold}

@media (max-width: 70em) {
  #sky-wrapper {float: none; position: static; margin-left: 0}
}
</style>
<link rel="icon" href="../images/favicon.png" sizes="44x44">
<link rel="icon" href="../images/favicon2.png" sizes="85x85">
<link rel="index" href="..">
<script src="../ajax.js"></script>
<script>
function changeStar(i, roll = false, constell = 0) {
  if (constell==0) {
    const starTable = document.getElementById('startable');
    if (starTable) {
      const starRows = starTable.children[0].children;
      const thisStarRow = document.getElementById('i'+i);
      const sky = document.getElementById('sky');
      for (n = 1; n<starRows.length; n++) starRows[n].style.boxShadow = starRows[n].id=='i'+i ? 'inset 0 0 2px 3px #444' : '';
      if (roll && thisStarRow && window.getComputedStyle(document.getElementById('sky-wrapper')).getPropertyValue('position')=='sticky')
        thisStarRow.scrollIntoView({behavior: 'smooth', block: 'center'});
      (sky.contentWindow || sky).changeMarker(i);
    }
  } else window.location.href = window.location.protocol+'//'+window.location.hostname+window.location.pathname+'?c='+constell+'&star='+i;
}

function sizeSky(changeSizing = false) {
  sizeConstellSky(document.getElementById('sky-wrapper'), 550, changeSizing);
}
</script>
</head>

<body <?php if (isset($_GET['star'])) echo 'onLoad="changeStar('.(int)$_GET['star'].', true)"' ?> onScroll="scrollMain()" onResize="sizeSky()">
<form id="search" method="get" action="../search.php" title="Search the Lemizh website">
<input type="text" name="q" placeholder="Search site" onFocus="focusSearch()">
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
<li><a href="constell.php?c=<?php echo $constellId ?>">Constellations</a></li>
<li><a href="pragmatics.php" class="prag" title="A sketch of pragmatics I. Relevance">Pragmatics I</a></li>
<li><a href="pragmatics2.php" class="prag" title="A sketch of pragmatics II. Triggers">Pragmatics II</a></li>
<li><a href="pragmatics3.php" class="prag" title="A sketch of pragmatics III. Discourse">Pragmatics III</a></li>
<li><a href="texts.html">Texts</a></li>
</ul>
</nav>

<main id="main" onScroll="scrollMain()">
<?php
$info = constellInfo($constellId, false);
if ($constellId>0) {
  echo $info[0]."\n\n";
  echo "<div id=\"sky-wrapper\">\n<script>\ndocument.write('<a id=\"enlarge\" onClick=\"sizeSky(true)\"></a>');\n</script>\n".'<iframe id="sky" src="constell/webgl.php?width=600&amp;c='.$constellId.'&amp;zoom=1.8&amp;mode=1" width="600" height="600"></iframe>'."\n</div>\n\n";
  echo $info[1];
} else echo '<h2 id="top">Constellation doesn’t exist</h2><p></p>'."\n\n";

$name = dictEntry($constellId);
$accentedName = substr_replace($name, 'à', strrpos($name, 'a'), 1);
if ($constellId>0) echo '<p>See also <a href="../le.php?'.$name.'" lang="x-lm" title="'.lemtitle($accentedName).'">'.$accentedName.'</a> in the dictionary.</p>'."\n\n";

$goBack = '<p style="margin-top: 2em"><a href="constell.php?c='.$constellId.'#coinfo" rel="prev">Back to the overview</a></p>'."\n";
echo $goBack;

function simbadName($name) {
  $name = str_replace(['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'], ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], $name);
  $p = strpos($name, '/');
  $q = strpos($name, '(');
  return (in_array(strtolower($name[1]), range('a', 'z')) ? '' : '*').str_replace(' ', '%20', substr(substr($name, 0, $q===false ? 1000 : $q-1), $p===false ? 0 : $p+1, 1000));
}
$rows = [];
$oldNo = 0;
$unnumbered = 0;
$dimStars = 0;
if ($constellId>0) for ($i = 0; $i<sizeof($starLemNumbers); $i++) if ($starLemConstells[$i]==$constellId) {
  if ($starLemNumbers[$i]>0) {
    $no = strtoupper(dechex($starLemNumbers[$i]));
    $lemSize = number_format(8.33227477-$starSizes[$i]*1.32877124, 2);
    if ($lemSize<0) $dimStars++;
    $rows['n'.$no] = '<tr id="i'.$i.'" style="background-color: #'.dechex(($starColors[3*$i]+256)/2).dechex(($starColors[3*$i+1]+256)/2).dechex(($starColors[3*$i+2]+256)/2).
      '" onMouseOver="changeStar('.$i.')"><td lang="x-lm" title="'.$no.'">'.$no.'</td><td>'.$no.'</td><td><a rel="external" href="http://simbad.u-strasbg.fr/simbad/sim-basic?Ident='.
      simbadName($starNames[$i]).'">'.$starNames[$i].'</a></td><td>'.str_replace('-', '−', $lemSize).'</td><td>'.number_format($starSizes[$i], 2)."</td></tr>\n";
    $oldNo = $no;
  } else ++$unnumbered;
}
ksort($rows);

if ($constellId>0) {
  echo '<h3 id="stars">The '.sizeof($rows).($unnumbered>0 ? ' numbered' : '').' naked-eye stars</h3>'."\n";
  echo '<p>In the ‘Our designation’ column, letters (sometimes with superscript numbers) in front of constellation symbols refer to Bayer’s catalogue or to <a href="https://en.wikipedia.org/wiki/Variable_star_designation" title="Wikipedia: Variable star designation" rel="external">variable star designations</a>, and numbers to Flamsteed’s catalogue. Row colours roughly approximate the stars’ colours. The links lead to the stars’ entries in the <abbr title="Set of Identifications, Measurements and Bibliography for Astronomical Data">SIMBAD</abbr> Astronomical Database.</p>'."\n";
  if ($dimStars==1) echo "<p>The star with negative Lemizh brightness is a variable that is visible to the naked eye when at its brightest, but invisible on average.</p>\n";
  if ($dimStars>1) echo "<p>Stars with negative Lemizh brightnesses are variables that are visible to the naked eye when at their brightest, but invisible on average.</p>\n";

  echo '<table id="startable">'."\n";
  echo '<tr><th colspan="2">Designation (<abbr title="hexadecimal">hex</abbr>)</th><th>Our designation</th><th><abbr title="Lemizh brightness (decimal)"><span lang="x-lm">l</span>br</abbr></th><th><abbr title="apparent magnitude"><i>m</i></abbr></th></tr>'."\n";
  foreach ($rows as $row) echo $row;
  echo '</table>'."\n";
  if ($unnumbered>0) echo '<p>'.$unnumbered.' naked-eye star'.($unnumbered==1 ? ' is' : 's are')." currently unnumbered.<p>\n";
  echo $goBack;
}
?>

<a href="#top" onClick="scrollToTop()" id="totop" title="Go to top"></a>
<footer>
<p>Last significant change to this page: 17 Nov 2022<br>
Last change to the database: <?php echo $modified ?></p>
<div><a href="https://creativecommons.org/licenses/by-sa/4.0/" class="linkimage" rel="external license" title="Available under a Creative Commons licence"><img src="../images/cc.svg" width="88" height="31" alt="Creative Commons BY-SA License"></a>&emsp;<a href="https://validator.w3.org/check/referer" referrerpolicy="no-referrer-when-downgrade" class="linkimage" rel="external" title="Check HTML 5"><img src="../images/html5.svg" width="27" height="38" alt="Check HTML 5"></a>&nbsp;<a href="https://jigsaw.w3.org/css-validator/check/referer" referrerpolicy="no-referrer-when-downgrade" class="linkimage" rel="external" title="Check CSS 3"><img src="../images/css3.svg" width="27" height="38" alt="Check CSS 3"></a><br>
See <a href="../home/terms.html">Terms of use</a> for details on copyright and licensing.</div>
</footer>
</main>

</body>
</html>