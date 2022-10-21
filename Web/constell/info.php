<?php
function lemtitle($str) {
  return str_replace(['Ì','O','Ò','Ó','U','Ù','Ú','h', 'j', 'c', 'v', 'q', 'n', 'R'],
                     ['ỳ','ö','ö̀','ö́','ü','ǜ','ǘ','sh','gh','zh','dh','th','ng','rh'], $str);
}
function dictEntry($constellId) {
  include 'constelllist.php';
  $dict = $constells[$constellId-1][2];
  if ($dict) return $dict; else return str_replace(['à', 'è', 'Ì', 'ì', 'ò', 'ù', 'Ò', 'Ù'], 'a', $constells[$constellId-1][1]);
}
function constellInfo($constellId, $fromMain) {
  include 'stardata.php';
  include 'constelllist.php';
  $c = $constells[$constellId-1];
  $s = str_replace('¶¶', '¶', $c[4]);

  do {
    $p = strpos($s, '[[');
    if ($p!==false) {
      $q = strpos($s, ']]', $p);
      $linkId = substr($s, $p+2, $q-$p-2);
      $linkNo = -1;
      for ($j = 0; $j<sizeof($constells); $j++) if ($linkId==$constells[$j][0]) $linkNo = $j;
      $s = substr($s, 0, $p).'<a href="?c='.($linkNo+1).($fromMain ? '#coinfo" onClick="changeConstell('.($linkNo+1).', true, true)' : '').'" title="Constellation '.$linkId.'">'.
        ($linkNo==-1 ? 'INVALID LINK ' : '').substr($s, $p+2);
    }
  } while ($p!==false);

  do {
    $p = strpos($s, '{{');
    $q = strpos($s, '|', $p);
    $i = substr($s, $p+2, $q-$p-2);
    if ($p!==false) $s = substr_replace($s, $fromMain ? '' : '<span onMouseOver="changeStar('.$i.')" title="'.strtoupper(dechex($starLemNumbers[$i])).' '.$c[0].'">', $p, $q-$p+1);
  } while ($p!==false);

  if (!$s && $c) $s = 'There is no information on the '.$c[0].' yet.';

  return ($fromMain ? '<h3>' : '<h2 id="top">Constellation ').$c[0].($c[1] ? ' (<span lang="x-lm" title="'.lemtitle($c[1]).'">'.$c[1].'</span>)' : '')
    .($fromMain ? '&emsp;<small><a href="constelln.php?c='.$constellId.'" title="Go to this constellation’s page">►</a></small>' : '').($fromMain ? "</h3>" : "</h2>\n").'<p>'
    .str_replace(['¶', ']]', '}}'], ['</p><p>', '</a>', $fromMain ? '' : '</span>'], $s)."</p>";
}

function getConstellId($id) {
  include 'constelllist.php';
  for ($i = 0; $i<sizeof($constells); $i++) {
    if (strtolower($id)==strtolower(str_replace([' ', '-'], '', $constells[$i][0]))) return $i+1;
  }
  $id = (int)$id;
  if ($id>0 && $id<=sizeof($constells)) return $id; else return 0;
}
?>