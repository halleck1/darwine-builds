#!/usr/bin/env bash



#export CC=gcc-4.2



#TODO:
#libcomposite
#libhal
#libcapi


check_err()
{
  if [ "${1}" -ne "0" ]; then
    echo "***** Error: ${2}"
    cat ../build.log
    exit ${1}
  fi
}



download_and_expand()
{
    #download
    filename=$(basename ${1})
    echo -n "##### buildDarwine => "$filename": downloading ... "
    curl -s -O ${1}
    check_err $? "Can't download "$filename
    echo "OK"

    #unpack
    echo -n "##### buildDarwine => "$filename": unpacking... "
    tar xfz $filename
    if test $(echo $filename | grep ".tar.bz2"); then
        tar xjf $filename &> ../build.log
        check_err $? "Can't unpack "$filename
    else
        tar xfz $filename
        check_err $? "Can't unpack "$filename
    fi
    rm $filename
    echo "OK"
}



configure_and_make()
{
    echo -n "##### buildDarwine => $1: building... "
    cd "$1"
    ./configure $2 &> ../build.log
    check_err $? "Can't configure "$1
    make --silent &> ../build.log
    check_err $? "Can't make "$1
    make --silent install &> ../build.log
    check_err $? "Can't make install "$1
    echo "OK"
    cd ..
}



export BUILDDIRECTORY=$(PWD)

#check here
#http://pkgconfig.freedesktop.org/releases/
#http://www.littlecms.com/downloads.htm
#ftp://xmlsoft.org/libxml2/
#http://www.zlib.net/
#http://www.libpng.org/pub/png/libpng.html
#http://www.ijg.org/files/
#http://www.freetype.org/index2.html
#http://fontconfig.org/wiki/
#http://libusb.wiki.sourceforge.net/
#http://www.sane-project.org/
#http://www.gphoto.org/download/
#http://fontforge.sourceforge.net/



#versions
export PKG_CONFIG_VERSION=0.23
export LCMS_VERSION=1.17
#export LIBXML2_VERSION=2.6.32
export LIBXML2_VERSION=2.7.3
export LIBXSLT_VERSION=1.1.24
export ZLIB_VERSION=1.2.3
#export LIBPNG_VERSION=1.2.29
export LIBPNG_VERSION=1.2.35
export LIBJPEG_VERSION=6b
export FREETYPE_VERSION=2.3.7
export FONTCONFIG_VERSION=2.6.0
export LIBUSB_VERSION=0.1.12
export LIBSANE_VERSION=1.0.18
#export LIBSANE_VERSION=1.0.19
#export LIBGPHOTO2_VERSION=2.4.1
export LIBGPHOTO2_VERSION=2.4.2
#export FONTFORGE_VERSION=20080607
export FONTFORGE_VERSION=20080828
export DARWINE_VERSION=1.1.16



export CPPFLAGS="-I$BUILDDIRECTORY/usr/include -I$BUILDDIRECTORY/usr/include/libxml2 -I$BUILDDIRECTORY/usr/include/libxslt -I$BUILDDIRECTORY/usr/include/libpng12 -I$BUILDDIRECTORY/usr/include/gphoto2 -I$BUILDDIRECTORY/usr/include/sane"
export CFLAGS="-I$BUILDDIRECTORY/usr/include"
export LDFLAGS="-L$BUILDDIRECTORY/usr/lib"
export PATH=$PATH:"$BUILDDIRECTORY/usr/bin"
export DYLD_LIBRARY_PATH="$BUILDDIRECTORY/usr/lib":$DYLD_LIBRARY_PATH
export DYLD_FALLBACK_LIBRARY_PATH="$BUILDDIRECTORY/usr/lib"

export PKG_CONFIG_PATH="$BUILDDIRECTORY/usr/lib/pkgconfig"

if test $(echo $OSTYPE | grep darwin8); then
    export MACOSX_DEPLOYMENT_TARGET=10.4
else
    export MACOSX_DEPLOYMENT_TARGET=10.5
fi



echo "" > build.log
mkdir -p "$BUILDDIRECTORY/usr/include"
mkdir -p "$BUILDDIRECTORY/usr/lib"
mkdir -p "$BUILDDIRECTORY/usr/bin"
mkdir -p "$BUILDDIRECTORY/usr/etc"
mkdir -p "$BUILDDIRECTORY/usr/man/man1"
mkdir -p "$BUILDDIRECTORY/src"



cd src



#pkg-config
echo ""
echo -n "##### buildDarwine => pkg-config: checking version... "
if [ ! -d "pkg-config-$PKG_CONFIG_VERSION" ]; then
    echo "updating to $PKG_CONFIG_VERSION"
    rm -rf pkg-config*
    download_and_expand "http://pkgconfig.freedesktop.org/releases/pkg-config-"$PKG_CONFIG_VERSION".tar.gz"
    configure_and_make "pkg-config-$PKG_CONFIG_VERSION" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr'
else
    echo "OK ($PKG_CONFIG_VERSION)"
fi



#lcms
echo ""
echo -n "##### buildDarwine => lcms: checking version... "
if [ ! -d "lcms-$LCMS_VERSION" ]; then
    echo "updating to $LCMS_VERSION"
    rm -rf lcms*
    download_and_expand "http://www.littlecms.com/lcms-"$LCMS_VERSION".tar.gz"
    configure_and_make "lcms-$LCMS_VERSION" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr'
else
    echo "OK ($LCMS_VERSION)"
fi



#libjpeg
echo ""
echo -n "##### buildDarwine => libjpeg: checking version... "
if [ ! -d "jpeg-$LIBJPEG_VERSION" ]; then
    echo "updating to $LIBJPEG_VERSION"
    rm -rf jpeg*
    download_and_expand "http://www.ijg.org/files/jpegsrc.v"$LIBJPEG_VERSION".tar.gz"
    ln -s `which glibtool` "jpeg-$LIBJPEG_VERSION/libtool"
    configure_and_make "jpeg-$LIBJPEG_VERSION" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr'
else
    echo "OK ($LIBJPEG_VERSION)"
fi



#zlib
echo ""
echo -n "##### buildDarwine => zlib: checking version... "
if [ ! -d "zlib-$ZLIB_VERSION" ]; then
    echo "updating to $ZLIB_VERSION"
    rm -rf zlib*
    #download_and_expand "http://www.zlib.net/zlib-"$ZLIB_VERSION".tar.gz"
    #download_and_expand "http://dfn.dl.sourceforge.net/sourceforge/libpng/zlib-1.2.3.tar.gz"
    download_and_expand  "ftp://ftp.simplesystems.org/pub/png/src/zlib-"$ZLIB_VERSION".tar.gz"
    configure_and_make "zlib-$ZLIB_VERSION" '--shared --prefix='$BUILDDIRECTORY'/usr'
else
    echo "OK ($ZLIB_VERSION)"
fi



#libpng
echo ""
echo -n "##### buildDarwine => libpng: checking version... "
if [ ! -d "libpng-$LIBPNG_VERSION" ]; then
    echo "updating to $LIBPNG_VERSION"
    rm -rf libpng*
    download_and_expand "ftp://ftp.simplesystems.org/pub/png/src/libpng-"$LIBPNG_VERSION".tar.gz"
    configure_and_make "libpng-$LIBPNG_VERSION" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr'
else
    echo "OK ($LIBPNG_VERSION)"
fi



#freetype
echo ""
echo -n "##### buildDarwine => freetype: checking version..."
if [ ! -d "freetype-$FREETYPE_VERSION" ]; then
    echo "updating to $FREETYPE_VERSION"
    rm -rf freetype*
    download_and_expand "http://mirror.publicns.net/pub/nongnu/freetype/freetype-"$FREETYPE_VERSION".tar.gz"
    configure_and_make "freetype-$FREETYPE_VERSION" '--silent --prefix='$BUILDDIRECTORY'/usr'
else
    echo "OK ($FREETYPE_VERSION)"
fi



#things we only need on Tiger
#if test $(echo $OSTYPE | grep darwin8); then



    #libxml2
    echo ""
    echo -n "##### buildDarwine => libxml2: checking version... "
    if [ ! -d "libxml2-$LIBXML2_VERSION" ]; then
        echo "updating to $LIBXML2_VERSION"
        rm -rf libxml2*
        download_and_expand "ftp://xmlsoft.org/libxml2/libxml2-"$LIBXML2_VERSION".tar.gz"
        configure_and_make "libxml2-$LIBXML2_VERSION" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr'
    else
        echo "OK ($LIBXML2_VERSION)"
    fi



    #libxslt
    echo ""
    echo -n "##### buildDarwine => libxslt: checking version... "
    if [ ! -d "libxslt-$LIBXSLT_VERSION" ]; then
        echo "updating to $LIBXSLT_VERSION"
        rm -rf libxslt*
        download_and_expand "ftp://xmlsoft.org/libxml2/libxslt-"$LIBXSLT_VERSION".tar.gz"
        configure_and_make "libxslt-$LIBXSLT_VERSION" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr --with-libxml-src='$BUILDDIRECTORY'/src/libxml2-'$LIBXML2_VERSION
    else
        echo "OK ($LIBXSLT_VERSION)"
    fi



#things we only need on Tiger
if test $(echo $OSTYPE | grep darwin8); then

    #fontconfig
    echo ""
    echo -n "##### buildDarwine => fontconfig: checking version... "
    #export FONTCONFIGINCL="fontconfig-$FONTCONFIG_VERSION"
    if [ ! -d "fontconfig-$FONTCONFIG_VERSION" ]; then
        echo "updating to $FONTCONFIG_VERSION"
        rm -rf fontconfig*
        download_and_expand "http://fontconfig.org/release/fontconfig-"$FONTCONFIG_VERSION".tar.gz"
        configure_and_make "fontconfig-$FONTCONFIG_VERSION" '--silent --prefix='$BUILDDIRECTORY'/usr'
    else
        echo "OK ($FONTCONFIG_VERSION)"
    fi



fi



#libusb
echo ""
echo -n "##### buildDarwine => libusb: checking version..."
if [ ! -d "libusb-$LIBUSB_VERSION" ]; then
    echo "updating to $LIBUSB_VERSION"
    rm -rf libusb*
    download_and_expand "http://heanet.dl.sourceforge.net/sourceforge/libusb/libusb-"$LIBUSB_VERSION".tar.gz"
    configure_and_make "libusb-$LIBUSB_VERSION" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr'
else
    echo "OK ($LIBUSB_VERSION)"
fi



#libgphoto2
echo ""
echo -n "##### buildDarwine => libgphoto2: checking version... "
if [ ! -d "libgphoto2-$LIBGPHOTO2_VERSION" ]; then
    echo "updating to $LIBGPHOTO2_VERSION"
    rm -rf libgphoto2*
    download_and_expand "http://dfn.dl.sourceforge.net/sourceforge/gphoto/libgphoto2-"$LIBGPHOTO2_VERSION".tar.gz"
#    echo -n "##### buildDarwine => libgphoto2: patching... " #fix OS X Bug
#    mv libgphoto2-$LIBGPHOTO2_VERSION/libgphoto2_port/serial/unix.c libgphoto2-$LIBGPHOTO2_VERSION/libgphoto2_port/serial/unix.c.orig
#    sed 's/O_NDELAY/O_NONBLOCK/g' libgphoto2-$LIBGPHOTO2_VERSION/libgphoto2_port/serial/unix.c.orig > libgphoto2-$LIBGPHOTO2_VERSION/libgphoto2_port/serial/unix.c
#    echo "OK"
    # casio_qv, sony_dscf1 is not working
    configure_and_make libgphoto2-$LIBGPHOTO2_VERSION '--with-drivers=adc65,agfa_cl20,aox,barbie,canon,clicksmart310,digigr8,digita,dimera3500,directory,enigma13,fuji,gsmart300,hp215,iclick,jamcam,jd11,kodak_dc120,kodak_dc210,kodak_dc240,kodak_dc3200,kodak_ez200,konica,konica_qm150,largan,lg_gsm,mars,dimagev,mustek,panasonic_coolshot,panasonic_l859,panasonic_dc1000,panasonic_dc1580,pccam300,pccam600,polaroid_pdc320,polaroid_pdc640,polaroid_pdc700,ptp2,ricoh,ricoh_g3,samsung,sierra,sipix_blink2,sipix_web2,smal,sonix,sony_dscf55,soundvision,spca50x,sq905,stv0674,stv0680,sx330z,toshiba_pdrm11 --silent --enable-shared --prefix='$BUILDDIRECTORY'/usr'
else
    echo "OK ($LIBGPHOTO2_VERSION)"
fi



#libssane-backendsane
echo ""
echo -n "##### buildDarwine => sane-backends: checking version... "
if [ ! -d "sane-backends-$LIBSANE_VERSION" ]; then
    echo "updating to $LIBSANE_VERSION"
    rm -rf sane-backends*
#    download_and_expand "ftp://ftp.sane-project.org/pub/sane/sane-backends-"$LIBSANE_VERSION".tar.gz"
#    download_and_expand "ftp://ftp.sane-project.org/pub/sane/sane-backends-"$LIBSANE_VERSION"/sane-backends-"$LIBSANE_VERSION".tar.gz"
    download_and_expand "ftp://ftp.sane-project.org/pub/sane/old-versions/sane-backends-"$LIBSANE_VERSION"/sane-backends-"$LIBSANE_VERSION".tar.gz"
    configure_and_make "sane-backends-$LIBSANE_VERSION" '--with-gphoto2 --silent --enable-shared --prefix='$BUILDDIRECTORY'/usr'
else
    echo "OK ($LIBSANE_VERSION)"
fi



#fontforge
echo ""
echo -n "##### buildDarwine => fontforge: checking version... "
#export PATH=$PATH:"$BUILDDIRECTORY/fontforge_$FONTFORGE_VERSION/bin"
if [ ! -d "fontforge-$FONTFORGE_VERSION" ]; then
    echo "updating to $FONTFORGE_VERSION"
    rm -rf fontforge*
    download_and_expand "http://kent.dl.sourceforge.net/sourceforge/fontforge/fontforge_full-$FONTFORGE_VERSION.tar.bz2"
    configure_and_make "fontforge-$FONTFORGE_VERSION" '--silent --enable-shared --prefix='$BUILDDIRECTORY'/usr --without-x --with-freetype-src=../freetype-'$FREETYPE_VERSION
else
    echo "OK ($FONTFORGE_VERSION)"
fi



#darwine and wine
echo ""
echo "##### buildDarwine => darwine: checking version..."
echo "##### buildDarwine => darwine: downloading... (we always start with a clean copy)"
sudo rm -rf distrib
cvs -q -z3 -d:pserver:anonymous:@darwine.cvs.sourceforge.net:/cvsroot/darwine co -P distrib

#patch darwine code to include freetype
echo "##### buildDarwine => darwine: patch distrib to include freetype, openGL, translations, mwine..."
cd distrib
if test $(echo $OSTYPE | grep darwin8); then
patch -p0 -u < ../../Tools/wine-1.1.5.tiger.diff
else
patch -p0 -u < ../../Tools/leopard.diff
fi
cd ..

#checkout latest wine code and decompress
echo "##### buildDarwine => darwine: checking wine version..."
if [ ! -d "wine-$DARWINE_VERSION" ]; then
    sudo rm -rf wine-*
    curl -s -O http://ibiblio.org/pub/linux/system/emulators/wine/wine-$DARWINE_VERSION.tar.bz2
    check_err $? "Can't download wine"
else
    sudo rm -rf wine-$DARWINE_VERSION
fi
echo "##### buildDarwine => darwine: unpacking wine..."
tar xjf wine-$DARWINE_VERSION.tar.bz2

#patch wine OpenGL
echo "##### buildDarwine => patching openGL..."
cd wine-$DARWINE_VERSION/dlls/winex11.drv/
patch -p0 -u < $BUILDDIRECTORY/Tools/OpenGL.diff
cd -

#patch wine wandering windows
echo "##### buildDarwine => patching wandering windows..."
cd wine-$DARWINE_VERSION/
patch -p0 -u < $BUILDDIRECTORY/Tools/wine-1.1.5.winfix.diff
cd -

#patch wine ie 100% CPU bug
echo "##### buildDarwine => patching ie 100% CPU bug..."
cd wine-$DARWINE_VERSION/
patch -p0 -u -R < $BUILDDIRECTORY/Tools/ie100percent.diff
cd -

#build darwine
echo "##### buildDarwine => darwine: building..."
cd distrib
sudo ./create_darwine_distrib.sh $DARWINE_VERSION $BUILDDIRECTORY/src/wine-$DARWINE_VERSION/
echo "##### buildDarwine => darwine: up to date ($DARWINE_VERSION)"



#cleanup
echo "##### buildDarwine => cleaning up..."
mv "Darwine $DARWINE_VERSION.dmg" ../../Darwine-x86-$DARWINE_VERSION.dmg
cd ..
cd ..
