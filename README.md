# Odorik application for iPhone, iPod
This is snapshot of a source code of v1.0.1 of
[Odorik](https://itunes.apple.com/us/app/odorik/id682721789?ls=1&mt=8) app,
written in RubyMotion.

You can find screenshots and basic info on it's
[support website](http://wejn.com/ios/odorik/).

## Building
Please note that in order to produce the exact same app as uploaded
to appstore will have to supply Glyphish3 Pro icons, app icon and other
assets that are copied to this repo in encrypted form (see `resources_enc`
and other occurences of `*.gpg` files).

Also, you will have to supply your own `config.yaml` deployment config
file (there's an example in the repo).

The reason is two-fold:
* I'm not allowed to distribute Glyphish3 Pro icons to general public
* While I'm fine with releasing the source, I actually don't want you to replicate the exact same app on the AppStore (how shocking)

## License
A little clarification first:

This repo is a *snapshot* of the source code of `v1.0` that I've chosen
to opensource under GPLv2 license (with exception of `app/lib` which is
under MIT license).

The application that is available on the AppStore (and possible future
versions) do not bear this cross, as I'm the copyright holder and I'm
free to choose the license for that build.

With that out of the way ---


```
Odorik application for iPhone, iPod
Copyright (C) 2013 Michal Jirku

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
(version 2) as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program (file gpl-2.0.txt); if not, write to the
Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
Boston, MA  02110-1301, USA.



EXCEPTION:

Contents of app/lib directory is distributed under MIT license:

Copyright (c) 2013 Michal Jirku

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
