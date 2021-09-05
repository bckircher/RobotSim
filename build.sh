#!/bin/bash
#******************************************************************************
#
# Copyright (c) 2020 RoboSaders - All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#
#******************************************************************************

function getTag
{
    echo ${1} | sed -E 's/.*'${2}'="([^"]*)".*/\1/'
}

mkdir -p rel

inScript=0

cat RobotSim.html | while read a
do
    if [ "x`echo ${a} | cut -c1-21`" == 'x<link rel="stylesheet' ]
    then
        sheet=`getTag "${a}" href`;
        echo '<style>'`java -jar tools/yuicompressor-2.4.8.jar ${sheet}`'</style>'
    elif [ "x`echo ${a} | cut -c1-19`" == 'x<link rel="shortcut' ]
    then
        icon=`getTag "${a}" href`;
        echo '<link rel="shortcut icon" type="image/png" href="data:image/png;base64,'`base64 -w0 ${icon}`'"/>'
    elif [ "x`echo ${a} | cut -c1-12`" == 'x<script src=' ]
    then
        if [ ${inScript} == 0 ]
        then
            echo '<script>'
            inScript=1
        fi
        src=`getTag "${a}" src`
        if [ `echo ${src} | cut -c1-7` == "extern/" ]
        then
            cat ${src}
        else
            scripts="${scripts} ${src}"
        fi
    else
        if [ ${inScript} == 1 ]
        then
            cat ${scripts} | java -jar tools/yuicompressor-2.4.8.jar --type js
            echo '</script>'
            inScript=0
        fi
        echo ${a}
    fi
done > rel/RobotSim.html
