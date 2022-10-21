# Lemizh constellations
The folder _Web_ contains the code for the [celestial sphere](https://lemizh.conlang.org/appendix/constell/webgl.php) and [constellation list](https://lemizh.conlang.org/appendix/constell.php) in my conworld Lemizh.

The folder _LemStars_ contains the software used to create and edit the data files on which the web application relies. It is written in FreePascal on Lazarus.

Both parts of the software use OpenGL/WebGL for rendering a smoothly animated star sphere. Published in the hope that someone who wants to create a 3D interactive celestial sphere for web browsers or for a desktop application might find this useful.

* The data from which the celestial sphere was created are mainly from the [HYG Database by David Nash](https://github.com/astronexus/HYG-Database), which is available under a CC BY-SA 2.5 Licence. Additional star names are from the [IAU](https://www.iau.org/public/themes/naming_stars/), additional Bayer designations from [In-The-Sky.org](https://in-the-sky.org/data/catalogue.php?cat=Bayer).
* The Milky Way image (_Web/constell/milkyway.png_) is from the [Stellarium](https://stellarium.org/) software, which is available under a GNU General Public Licence.
* The compass rose (_Web/constell/compassrose.svg_) is modified from [Serg!o’s image](https://commons.wikimedia.org/wiki/File:Compass_Rose_English_North.svg), available under a CC BY-SA 3.0 Licence.