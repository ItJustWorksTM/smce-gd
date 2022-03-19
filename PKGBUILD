pkgname=smce_gd-bin
pkgver=1.3.3_rc2
pkgrel=1
license=('APACHE')
pkgdesc="SMCE Frontend"
arch=('x86_64')
url="https://github.com/ItJustWorksTM/smce-gd"
install=$pkgname.install

depends=('cmake' 'openssl' 'arduino-cli' 'gcc')

source=("$pkgname-$pkgver.sh::https://github.com/ItJustWorksTM/smce-gd/releases/download/v$pkgver/smce_gd-$pkgver-Linux-x86_64-GNU-GodotDebug.sh")
options=("!strip")

sha256sums=("SKIP")

package() {
    cd "$srcdir"
    mkdir ${pkgdir}/usr
    chmod +x $pkgname-$pkgver.sh
    ./$pkgname-$pkgver.sh --prefix=${pkgdir}/usr --skip-license --exclude-subdir
    chown root:root ${pkgdir}/usr/share/applications/smce_gd.desktop
}

