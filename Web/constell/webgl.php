<!DOCTYPE html>
<html lang="en-GB">
<head>
<title>Sky sphere - Lemizh grammar and dictionary</title>
<meta charset="utf-8">
<meta name="author" content="Anypodetos">
<meta name="description" content="Sky sphere with the Lemizh constellations">
<meta name="viewport" content="width=device-width, initial-scale=1">

<link rel="stylesheet" href="../../main.css">
<link rel="icon" href="../../images/favicon.png" sizes="44x44">
<link rel="icon" href="../../images/favicon2.png" sizes="85x85">
</head>

<body onKeyDown="keyDown()" style="margin: 0; overflow: hidden">
<canvas id="canvas" style="margin: 0; transition: border-radius 0.5s">(Can’t display sky sphere: either JavaScript is turned off, or your browser doesn’t support 3D drawing with <a href="https://get.webgl.org/" rel="external">WebGL</a>. Or your video card’s drivers are out of date. Or something else. Sorry for the inconvenience.)</canvas><!-- TODO: link to page with static images (don’t include img tags here or they will always load) -->
<img id="compassrose" src="compassrose.svg" style="position: absolute; width: 0; z-index: -1" alt="North is up, east is left.">

<script>
document.write('<img id="loading" src="../../images/loading.svg" style="position: absolute; left: 0; margin: 3em" height="30" alt="Loading…">');

// Data
<?php
include 'constelllist.php';
include 'stardata.php';
include 'info.php';

echo "const constells = [\n";
foreach ($constells as $s) echo "'".$s[0]."',\n";
echo "];\n";

echo "const stars = [\n";
foreach ($stars as $s) echo str_replace('0.', '.', $s).",";
echo "];\n";

echo "const starColorsf = [\n";
foreach ($starColors as $s) echo ltrim(round($s/255, 2), '0').",";
echo "];\n";

echo "const starSizes = [\n";
foreach ($starSizes as $s) echo round(8.33227477-1.32877124*$s, 3).",";
echo "];\n";

echo "const starNames = [\n";
foreach ($starNames as $s) {
  $p = strpos($s, '/');
  if ($p===false) $name = $s; else $name = substr($s, 0, $p).substr($s, strpos($s, ' '), 1000);
  echo "'".$name."',";
}
echo "];\n";

echo "const starLemConstells = [\n";
foreach ($starLemConstells as $s) echo $s.",";
echo "];\n";

echo "const starLemNumbers = [\n";
foreach ($starLemNumbers as $s) echo $s.",";
echo "];\n";

echo "const constellLines = [\n";
foreach ($constellLines as $s) echo $s.",";
echo "];\n\n";

$mode = max(min((int)$_GET['mode'], 1), 0);
echo "const mode = ".$mode.";\n";
$width  = (int)$_GET['width'];
$height = (int)$_GET['height'];
if ($width <=1) $width = 800;
if ($height<=1) $height = $width;
echo "var width = ".$width.", height = ".$height.";\n";
echo "var alpha = ".(((float)$_GET['a'])/12*pi()).", delta = ".(((float)$_GET['d'])/180*pi()).", zoom = ".(isset($_GET['zoom']) ? (float)$_GET['zoom'] : '0.95').";\n";
$constellId = getConstellId($_GET['c']);
echo "var constellId = ".($mode==0 || $constellId>0 ? $constellId : 1).";\n";
if (!(isset($_GET['a']) || isset($_GET['d']))) echo "if (constellId!=0) [alpha, delta] = constellPos();\n";
echo "var marker = ".(isset($_GET['mark']) && $mode==1 ? (int)$_GET['mark'] : "-1").";\n";
?>

const milkyImage = new Image();
milkyImage.src = 'milkyway.png';
const numbersImage = new Image();
numbersImage.src = 'numbers.png';

const tilt = 3.550639;
var trafo;

// Utilities
function getPosition(event) {
  if (event.pageX) return event;
  if (event.changedTouches && event.changedTouches.length>0) return event.changedTouches[0];
  return {pageX: NaN, pageY: NaN};
}

var timeoutId;
function moveToStepper(aalpha, adelta, azoom, dalpha, ddelta, dzoom, step) {
  alpha = 2*dalpha*Math.pow(step/50, 3)-3*dalpha*Math.pow(step/50, 2)+aalpha;
  delta = 2*ddelta*Math.pow(step/50, 3)-3*ddelta*Math.pow(step/50, 2)+adelta;
  zoom  = 2*dzoom *Math.pow(step/50, 3)-3*dzoom *Math.pow(step/50, 2)+azoom ;
  draw();
  if (step>0) timeoutId = setTimeout(moveToStepper, 10, aalpha, adelta, azoom, dalpha, ddelta, dzoom, step-1);
}
function moveTo([aalpha, adelta], azoom = zoom) {
  if (aalpha>alpha+Math.PI) aalpha -= 2*Math.PI; else if (aalpha<alpha-Math.PI) aalpha += 2*Math.PI;
  clearTimeout(timeoutId);
  moveToStepper(aalpha, adelta, azoom, aalpha-alpha, adelta-delta, azoom-zoom, 50);
}

function starsAt(loc, radius) {
  const s = [];
  for (var i = 0; i<starSizes.length; i++) {
    var p =
      [stars[3*i]*trafo[0]+stars[3*i+1]*trafo[4]+stars[3*i+2]*trafo[8],
       stars[3*i]*trafo[1]+stars[3*i+1]*trafo[5]+stars[3*i+2]*trafo[9],
       stars[3*i]*trafo[2]+stars[3*i+1]*trafo[6]+stars[3*i+2]*trafo[10]];
    if ((Math.pow((1+p[0])/2*width-loc.pageX, 2)+Math.pow((1-p[1])/2*height-loc.pageY, 2)<Math.pow(radius, 2)) && (p[2]>0)) s.push(i);
  }
  s.sort(function(a, b) {return starSizes[b]-starSizes[a]});
  return s;
}

function constellPos(id = constellId) {
  var n = 0, calpha = 0, cdelta = 0, salpha;
  for (var i = 0; i<starLemConstells.length; i++) if (starLemConstells[i]==id) {
    n++;
    salpha = (stars[3*i+2]<0 ? Math.PI : 0)-Math.atan(stars[3*i]/stars[3*i+2]);
    calpha += salpha+(salpha-calpha/n>Math.PI ? -2*Math.PI : (salpha-calpha/n<-Math.PI ? 2*Math.PI : 0));
    cdelta += Math.asin(stars[3*i+1]);
  }
  if (n>0) return [calpha/n, cdelta/n]; else return [0, 0];
}

function changeConstell(constell, move = true) {
  constellId = constell;
  if (move && constellId!=0) moveTo(constellPos()); else draw();
}
function changeMarker(star) {
  marker = star;
  if (star!=-1) constellId = starLemConstells[star];
  draw();
}

function sizeSky(awidth, aheight = awidth) {
  width = awidth;
  height = aheight;
  canvas.style.width = width+'px';
  canvas.style.height = height+'px';
  compassrose.style.width = (width/6)+'px';
  compassrose.style.left = (5*width/6)+'px';
  updatePixelRatio();
}
function updatePixelRatio() {
  const pixelRatio = window.devicePixelRatio;
  canvas.width = Math.floor(width*pixelRatio);
  canvas.height = Math.floor(height*pixelRatio);
  draw();
  matchMedia('(resolution: '+pixelRatio+'dppx)').addEventListener('change', updatePixelRatio, {once: true})
}

// Events
function keyDown() {
  if (!event.shiftKey && !event.ctrlKey && !event.altKey && !event.metaKey) {
    if (event.keyCode==37) alpha += 0.03/zoom;
    if (event.keyCode==38) delta += 0.03/zoom;
    if (event.keyCode==39) alpha -= 0.03/zoom;
    if (event.keyCode==40) delta -= 0.03/zoom;
    if ([37,38,39,40].includes(event.keyCode)) event.preventDefault();
  }
  if (!event.ctrlKey && !event.altKey && !event.metaKey) {
    if (event.key=='+') zoom = zoom*1.1;
    if (event.key=='-') zoom = zoom/1.1;
    if (event.key=='0') moveTo([alpha, delta], 0.95);
  }
  draw();
}

var eventCache = [], oldX, oldY, oldPinchD;

function pointerDown() {
  if (event.type=='touchstart' || event.buttons==1) {
    canvas.style.cursor = 'grab';
    eventCache.push(event);
  }
}

function pointerMove() {
  for (var i = 0; i<eventCache.length; i++) if (event.pointerId==eventCache[i].pointerId) {
    eventCache[i] = event;
    break;
  }
  switch (eventCache.length) {
  case 0:
    const s = starsAt(getPosition(event), 5);
    var title = '';
    for (var i of s) title += ((starLemNumbers[i]>0) ? starLemNumbers[i].toString(16).toUpperCase()+' '+constells[starLemConstells[i]-1]+' • ' : '')+starNames[i]+'\n';
    canvas.title = title;
    break;
  case 1:
    const pos = getPosition(eventCache[0]);
    if (oldX>0) alpha += (pos.pageX-oldX)*2.4/height/zoom;
    if (oldY>0) delta += (pos.pageY-oldY)*2.4/height/zoom;
    oldX = pos.pageX;
    oldY = pos.pageY;
    break;
  case 2:  // TODO: fine-tune pinch zoom (speed, jumpiness)
    const pos0 = getPosition(eventCache[0]), pos1 = getPosition(eventCache[1]);
    const newPinchD = Math.sqrt(Math.pow(pos0.pageX-pos1.pageX, 2)+Math.pow(pos0.pageY-pos1.pageY, 2));
    if (oldPinchD>0) zoom *= Math.min(Math.max(newPinchD/oldPinchD, 0.9), 1.1);
    oldPinchD = newPinchD;
    break;
  }
  event.preventDefault();
  if ([1,2].includes(eventCache.length)) draw();
}

function cleanUp() {
  for (var i = 0; i<eventCache.length; i++) if (eventCache[i].pointerId==event.pointerId) {
    eventCache.splice(i, 1);
    break;
  }
  if (eventCache.length==0) canvas.style.cursor = mode==0 ? 'crosshair' : 'pointer';
  oldX = eventCache.length>0 ? -2 : -1;
  oldY = oldX;
  oldPinchD = -1;
}

function pointerUp() {
  if (eventCache.length==1 && oldX==-1) {
    const s = starsAt(getPosition(event), mode==0 ? 15*zoom : 5);
    if (s.length>0) {
      const c = starLemConstells[s[0]];
      if (mode==0) {
        changeConstell(c==constellId ? 0 : c, false);
        if (window.parent!=window && typeof window.parent.changeConstell=='function') window.parent.changeConstell(constellId, false, true);
      } else {
        const change = c==constellId ? 0 : c;
        changeMarker(s[0]==marker ? -1 : s[0]);
        if (window.parent!=window && typeof window.parent.changeStar=='function') window.parent.changeStar(marker, true, change);
      }
    } else if (mode==1) changeMarker(-1);
  }
  event.preventDefault();
  cleanUp();
}

function mouseWheel() {
  zoom = event.deltaY<0 ? zoom*1.05 : zoom/1.05;
  event.preventDefault();
  draw();
}

// Canvas
const canvas = document.getElementById('canvas'), compassrose = document.getElementById('compassrose');
cleanUp();

new IntersectionObserver(function (entries) {if (entries[0].isIntersecting) draw()}, {threshold: 0.02}).observe(canvas);

canvas.addEventListener('mousedown', pointerDown);
canvas.addEventListener('touchstart', pointerDown);
canvas.addEventListener('mousemove', pointerMove);
canvas.addEventListener('touchmove', pointerMove);
canvas.addEventListener('mouseup', pointerUp);
canvas.addEventListener('touchend', pointerUp);
canvas.addEventListener('mouseleave', cleanUp);
canvas.addEventListener('touchcancel', cleanUp);
canvas.addEventListener('wheel', mouseWheel);

// WebGL
const gl = canvas.getContext('webgl', {alpha: false});
gl.getExtension('OES_standard_derivatives');
gl.clearColor(0, 0, 0, 1);
gl.enable(gl.BLEND);
gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

function makeShader(program, type, code) {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, code);
  gl.compileShader(shader);
  gl.attachShader(program, shader);
}
function makeAttribute(data) {
  var buffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data), gl.STATIC_DRAW);
  return buffer;
}
function enableAttribute(program, id, buffer, length) {
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
  const loc = gl.getAttribLocation(program, id);
  gl.vertexAttribPointer(loc, length, gl.FLOAT, false, 0, 0);
  gl.enableVertexAttribArray(loc);
}

// Milky Way shaders
const milkyTexture = gl.createTexture();
gl.bindTexture(gl.TEXTURE_2D, milkyTexture);
const pixel = new Uint8Array([0, 0, 0, 0]);
gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, pixel);
milkyImage.onload = function() {
  gl.bindTexture(gl.TEXTURE_2D, milkyTexture);
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, milkyImage);
  gl.generateMipmap(gl.TEXTURE_2D);
  draw();
}

const milkyProgram = gl.createProgram();
makeShader(milkyProgram, gl.VERTEX_SHADER, `
  attribute vec4 tile;
  attribute vec2 texture;
  uniform mat4 trafoMatrix;
  varying vec2 vTexture;
  void main(void) {
    gl_Position = trafoMatrix*tile;
    vTexture = texture;
  }
`);
makeShader(milkyProgram, gl.FRAGMENT_SHADER, `
  precision mediump float;
  uniform sampler2D uSampler;
  varying vec2 vTexture;
  void main(void) {
    gl_FragColor = texture2D(uSampler, vTexture)*vec4(0.65, 0.65, 0.65, 1);
  }
`);
gl.linkProgram(milkyProgram);

// Grid and Star marker shaders
const gridProgram = gl.createProgram();
makeShader(gridProgram, gl.VERTEX_SHADER, `
  attribute vec3 line;
  uniform mat4 trafoMatrix;
  uniform mat4 angleMatrix;
  uniform vec4 color;
  varying vec4 vColor;
  void main(void) {
    gl_Position = trafoMatrix*angleMatrix*vec4(line, 1.0);
    vColor = color;
  }
`);
makeShader(gridProgram, gl.FRAGMENT_SHADER, `
  precision mediump float;
  varying vec4 vColor;
  void main(void) {
    gl_FragColor = vColor;
  }`
);
gl.linkProgram(gridProgram);

// Constell line shaders
const linesProgram = gl.createProgram();
makeShader(linesProgram, gl.VERTEX_SHADER, `
  attribute vec3 star;
  attribute float constell;
  uniform mat4 trafoMatrix;
  uniform int constellId;
  varying vec4 vColor;
  void main(void) {
    gl_Position = trafoMatrix*vec4(star, 1.0);
    vColor = vec4(0.13, 0.51, 0.34, (constellId==0 || constellId==int(constell)) ? 1.0 : 0.4);
  }
`);
makeShader(linesProgram, gl.FRAGMENT_SHADER, `
  precision mediump float;
  varying vec4 vColor;
  void main(void) {
    gl_FragColor = vColor;
  }`
);
gl.linkProgram(linesProgram);

// Star shaders
const starsProgram = gl.createProgram();
makeShader(starsProgram, gl.VERTEX_SHADER, `
  attribute vec3 star;
  attribute vec3 color;
  attribute float size;
  attribute float constell;
  uniform mat4 trafoMatrix;
  uniform float sqrtZoom;
  uniform int constellId;
  varying vec4 vColor;
  void main(void) {
    gl_Position = trafoMatrix*vec4(star, 1.0);
    gl_PointSize = size*sqrtZoom;
    vColor = vec4(color, (constellId==0 || constellId==int(constell)) ? 1.0 : 0.4);
  }
`);
makeShader(starsProgram, gl.FRAGMENT_SHADER, `
 #ifdef GL_OES_standard_derivatives
 #extension GL_OES_standard_derivatives: enable
 #endif
  precision mediump float;
  varying vec4 vColor;
  void main(void) {
    float r = 0.0, delta = 0.0, alpha = 1.0;
    vec2 cxy = 2.0*gl_PointCoord-1.0;
    r = dot(cxy, cxy);
   #ifdef GL_OES_standard_derivatives
    delta = fwidth(r);
    alpha = 1.0-smoothstep(0.9-delta, 0.9+delta, r);
   #endif
    gl_FragColor = vec4(vColor.rgb, vColor.a*alpha);
  }
`);
gl.linkProgram(starsProgram);

// Number shaders
const numbersTexture = gl.createTexture();
gl.bindTexture(gl.TEXTURE_2D, numbersTexture);
gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, pixel);
numbersImage.onload = function() {
  gl.bindTexture(gl.TEXTURE_2D, numbersTexture);
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, numbersImage);
  gl.generateMipmap(gl.TEXTURE_2D);
  draw();
}

const numbersProgram = gl.createProgram();
makeShader(numbersProgram, gl.VERTEX_SHADER, `
  attribute vec4 tile;
  attribute vec2 texture;
  uniform mat4 trafoMatrix;
  uniform vec3 star;
  uniform float offset;
  uniform vec4 invSize;
  varying vec2 vTexture;
  void main(void) {
    gl_Position = trafoMatrix*vec4(star, 1.0) + (tile+vec4(offset, 0.0, 0.0, 0.0))*invSize;
    vTexture = texture;
  }
`);
makeShader(numbersProgram, gl.FRAGMENT_SHADER, `
  precision mediump float;
  uniform sampler2D uSampler;
  varying vec2 vTexture;
  void main(void) {
    gl_FragColor = texture2D(uSampler, vTexture);
  }`
);
gl.linkProgram(numbersProgram);

// Buffer objects
var milkyTiles = [], milkyTexCoords = [];
for (var i = 7; i>=-8; i--) for (var j = 0; j<=64; j++) {
  var sinJ = Math.sin(j/32*Math.PI), cosJ = Math.cos(j/32*Math.PI), cosI = Math.cos(i/16*Math.PI), cosI1 = Math.cos((i+1)/16*Math.PI);
  milkyTiles.push(
    sinJ*cosI1, Math.sin((i+1)/16*Math.PI), cosJ*cosI1, 1,
    sinJ*cosI,  Math.sin( i   /16*Math.PI), cosJ*cosI,  1);
  milkyTexCoords.push(j/64+0.25, (7-i)/16, j/64+0.25, (8-i)/16);
}
const milkyTilesAttrib = makeAttribute(milkyTiles),
  milkyTexCoordsAttrib = makeAttribute(milkyTexCoords);

var gridLines = [], lineVertices = 384;
for (var i = 0; i<lineVertices; i++) {
  gridLines.push(Math.cos(2*i/lineVertices*Math.PI), 0, Math.sin(2*i/lineVertices*Math.PI));
}
const gridLinesAttrib = makeAttribute(gridLines);

var constellPoints = [], constellIds = [];
for (var i = 0; i<Math.floor(constellLines.length/2)-1; i++) if (constellLines[2*i+3]==1) {
  constellPoints.push(
    stars[constellLines[2*i  ]*3], stars[constellLines[2*i  ]*3+1], stars[constellLines[2*i  ]*3+2],
    stars[constellLines[2*i+2]*3], stars[constellLines[2*i+2]*3+1], stars[constellLines[2*i+2]*3+2]);
  constellIds.push(starLemConstells[constellLines[2*i]], starLemConstells[constellLines[2*i+2]]);
}
const constellPointsAttrib = makeAttribute(constellPoints),
  constellIdsAttrib = makeAttribute(constellIds);

const starsAttrib = makeAttribute(stars),
  starColorsfAttrib = makeAttribute(starColorsf),
  starSizesAttrib = makeAttribute(starSizes),
  starLemConstellsAttrib = makeAttribute(starLemConstells);

const numbersTilesAttrib = makeAttribute([0,0,0,0, 0,-50,0,0, 25,0,0,0, 25,-50,0,0]), numbersTexCoordsAttrib = [];
for (var i = 0; i<16; i++) numbersTexCoordsAttrib[i] = makeAttribute(
    [25*(i<10 ? i : i-10)/256,        (i<10 ? 0 : 61)/256, 25*(i<10 ? i : i-10)/256,        (i<10 ? 0 : 61)/256+22/128,
     25*(i<10 ? i : i-10)/256+11/128, (i<10 ? 0 : 61)/256, 25*(i<10 ? i : i-10)/256+11/128, (i<10 ? 0 : 61)/256+22/128]);

gl.bindBuffer(gl.ARRAY_BUFFER, null);

// DRAW

function draw() {

gl.viewport(0, 0, canvas.width, canvas.height);
gl.clear(gl.COLOR_BUFFER_BIT);

while (alpha>2*Math.PI) alpha -= 2*Math.PI;
while (alpha<0) alpha += 2*Math.PI;
delta = Math.max(Math.min(delta, Math.PI/2), -Math.PI/2);
zoom = Math.max(Math.min(zoom, 40), 0.1);
const zoomx = zoom*height/width;
const sqrtZoom = Math.sqrt(zoom), sqrtPixelR = Math.sqrt(window.devicePixelRatio);
canvas.style.borderRadius = (zoom>0.96 || width!=height) ? '0.5em' : '50%';

const sina = Math.sin(alpha), cosa = Math.cos(alpha), sind = Math.sin(delta), cosd = Math.cos(delta);
trafo = 
  [zoomx*cosa,  zoom*sind*sina, -cosd*sina, 0,
   0,           zoom*cosd,       sind,      0,
   zoomx*sina, -zoom*sind*cosa,  cosd*cosa, 0,
   0,           0,              -1,         1];
const trafoFloat = new Float32Array(trafo);

// Milky Way
gl.useProgram(milkyProgram);
enableAttribute(milkyProgram, 'tile', milkyTilesAttrib, 4);
enableAttribute(milkyProgram, 'texture', milkyTexCoordsAttrib, 2)
gl.uniformMatrix4fv(gl.getUniformLocation(milkyProgram, 'trafoMatrix'), false, trafoFloat);
gl.activeTexture(gl.TEXTURE0);
gl.bindTexture(gl.TEXTURE_2D, milkyTexture);
gl.drawArrays(gl.TRIANGLE_STRIP, 0, Math.floor(milkyTiles.length/4));

// Grid and Star marker
gl.useProgram(gridProgram);
enableAttribute(gridProgram, 'line', gridLinesAttrib, 3);
gl.uniformMatrix4fv(gl.getUniformLocation(gridProgram, 'trafoMatrix'), false, trafoFloat);
gl.uniformMatrix4fv(gl.getUniformLocation(gridProgram, 'angleMatrix'), false, new Float32Array(
  [Math.cos(tilt), -Math.sin(tilt), 0, 0,
   Math.sin(tilt),  Math.cos(tilt), 0, 0,
   0, 0, 1, 0,
   0, 0, 0, 1]));
gl.uniform4f(gl.getUniformLocation(gridProgram, 'color'), 0.6, 0.3, 0.15, 1);
gl.drawArrays(gl.LINES, 0, lineVertices);

for (var i = -3; i<=3; i++) {
  var z = Math.cos(i*Math.PI/8);
  gl.uniformMatrix4fv(gl.getUniformLocation(gridProgram, 'angleMatrix'), false, new Float32Array(
    [z, 0, 0, 0,
     0, 1, 0, 0,
     0, 0, z, 0,
     0, Math.sin(i*Math.PI/8), 0, 1]));
  var c = (i==0) ? 0.8 : 0.4;
  gl.uniform4f(gl.getUniformLocation(gridProgram, 'color'), c, c, c, 1);
  gl.drawArrays(gl.LINE_LOOP, 0, lineVertices);
}
for (var i = 1; i<=16; i++) {
  var z = Math.cos(i*Math.PI/8), y = Math.sin(i*Math.PI/8)
  gl.uniformMatrix4fv(gl.getUniformLocation(gridProgram, 'angleMatrix'), false, new Float32Array(
    [0, 1, 0, 0,
    -z, 0,-y, 0,
    -y, 0, z, 0,
     0, 0, 0, 1]));
  if (i==16) gl.uniform4f(gl.getUniformLocation(gridProgram, 'color'), 0.8, 0.8, 0.8, 1);
  gl.drawArrays(gl.LINE_STRIP, Math.floor(lineVertices/96), Math.floor(lineVertices*23/48)+1);
}

gl.uniform4f(gl.getUniformLocation(gridProgram, 'color'), 0.6, 0.6, 0.6, 1);
if (marker>=0 && marker<stars.length/3) {
  const s = 0.04/sqrtZoom;
  gl.uniformMatrix4fv(gl.getUniformLocation(gridProgram, 'angleMatrix'), false, new Float32Array(
    [s, 0, 0, 0,
     0, s, 0, 0,
     0, 0, s, 0,
     stars[3*marker], stars[3*marker+1], stars[3*marker+2], 1]));
  gl.drawArrays(gl.LINE_LOOP, 0, lineVertices);
  gl.uniformMatrix4fv(gl.getUniformLocation(gridProgram, 'angleMatrix'), false, new Float32Array(
    [s, 0, 0, 0,
     0, 0, s, 0,
     0, s, 0, 0,
     stars[3*marker], stars[3*marker+1], stars[3*marker+2], 1]));
  gl.drawArrays(gl.LINE_LOOP, 0, lineVertices);
  gl.uniformMatrix4fv(gl.getUniformLocation(gridProgram, 'angleMatrix'), false, new Float32Array(
    [0, s, 0, 0,
     s, 0, 0, 0,
     0, 0, s, 0,
     stars[3*marker], stars[3*marker+1], stars[3*marker+2], 1]));
  gl.drawArrays(gl.LINE_LOOP, 0, lineVertices);
}

// Constell lines
gl.useProgram(linesProgram);
enableAttribute(linesProgram, 'star', constellPointsAttrib, 3);
enableAttribute(linesProgram, 'constell', constellIdsAttrib, 1);
gl.uniformMatrix4fv(gl.getUniformLocation(linesProgram, 'trafoMatrix'), false, trafoFloat);
gl.uniform1i(gl.getUniformLocation(linesProgram, 'constellId'), constellId);
gl.drawArrays(gl.LINES, 0, Math.floor(constellPoints.length/3));

// Stars
gl.useProgram(starsProgram);
enableAttribute(starsProgram, 'star', starsAttrib, 3);
enableAttribute(starsProgram, 'color', starColorsfAttrib, 3);
enableAttribute(starsProgram, 'size', starSizesAttrib, 1);
enableAttribute(starsProgram, 'constell', starLemConstellsAttrib, 1);
gl.uniformMatrix4fv(gl.getUniformLocation(starsProgram, 'trafoMatrix'), false, trafoFloat);
gl.uniform1f(gl.getUniformLocation(starsProgram, 'sqrtZoom'), sqrtZoom*sqrtPixelR);
gl.uniform1i(gl.getUniformLocation(starsProgram, 'constellId'), constellId);
gl.drawArrays(gl.POINTS, 0, starSizes.length);

// Numbers
if (mode==1 && constellId>0) {
  gl.useProgram(numbersProgram);
  enableAttribute(numbersProgram, 'tile', numbersTilesAttrib, 4);
  gl.uniformMatrix4fv(gl.getUniformLocation(numbersProgram, 'trafoMatrix'), false, trafoFloat);
  gl.uniform4f(gl.getUniformLocation(numbersProgram, 'invSize'), 1/(width*sqrtPixelR), 1/(height*sqrtPixelR), 0, 0);
  gl.activeTexture(gl.TEXTURE0);
  gl.bindTexture(gl.TEXTURE_2D, numbersTexture);
  const limit = Math.min(5-zoom*height/600, 3);
  for (var j = 0; j<2; j++) for (var i = 0; i<starSizes.length; i++) if (starLemConstells[i]==constellId && starLemNumbers[i]>0 && starSizes[i]>=limit) {
    gl.uniform3f(gl.getUniformLocation(numbersProgram, 'star'), stars[3*i], stars[3*i+1], stars[3*i+2]);
    enableAttribute(numbersProgram, 'texture', numbersTexCoordsAttrib[starLemNumbers[i]>15 ? Math.floor(starLemNumbers[i]/16) : starLemNumbers[i]], 2);
    var sizeOffset = starSizes[i]*sqrtZoom-5;
    gl.uniform1f(gl.getUniformLocation(numbersProgram, 'offset'), sizeOffset);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    if (starLemNumbers[i]>15) {
      enableAttribute(numbersProgram, 'texture', numbersTexCoordsAttrib[starLemNumbers[i]%16], 2);
      gl.uniform1f(gl.getUniformLocation(numbersProgram, 'offset'), sizeOffset+17);
      gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    }
  }
}

gl.bindBuffer(gl.ARRAY_BUFFER, null);
}

if (window.parent!=window && typeof window.parent.sizeSky=='function') window.parent.sizeSky(); else sizeSky(width, height);
document.getElementById('loading').style.display = 'none';
</script>
</body>
</html>