class Webkitgtk < Formula
  desc "Full-featured Gtk+ port of the WebKit rendering engine"
  homepage "http://webkitgtk.org"
  url "http://webkitgtk.org/releases/webkitgtk-2.42.1.tar.xz"
  sha256 "6f41fac9989d3ee51c08c48de1d439cdeddecbc757e34b6180987d99b16d2499"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "enchant"
  depends_on "gtk+3"
  depends_on "libsecret"
  depends_on "libnotify"
  depends_on "libpng"
  depends_on "libsoup"
  depends_on "openjpeg"
  depends_on "webp"
  depends_on "woff2"
  depends_on "zlib"

  # hide WebKitWebProcess in the macOS Dock
  patch do
    url "https://raw.githubusercontent.com/midchildan/nixpkgs/f08fcc9c26b84e77516ed2bc92c07376dc4fa0ee/pkgs/development/libraries/webkitgtk/0001-Prevent-WebKitWebProcess-from-being-in-the-dock-or-p.patch"
  end

  patch :DATA

  def install
    extra_args = %w[
      -GNinja
      -DPORT=GTK
      -DENABLE_X11_TARGET=OFF
      -DENABLE_WAYLAND_TARGET=OFF
      -DENABLE_QUARTZ_TARGET=ON
      -DENABLE_GLES2=OFF
      -DUSE_OPENGL_OR_ES=OFF
      -DENABLE_TOOLS=ON
      -DENABLE_MINIBROWSER=OFF
      -DENABLE_PLUGIN_PROCESS_GTK2=OFF
      -DENABLE_VIDEO=OFF
      -DENABLE_WEB_AUDIO=OFF
      -DENABLE_GEOLOCATION=OFF
      -DENABLE_WEBGL=OFF
      -DUSE_LIBNOTIFY=ON
      -DUSE_LIBHYPHEN=OFF
      -DENABLE_GAMEPAD=OFF
      -DUSE_SYSTEMD=OFF
      -DUSE_APPLE_ICU=OFF
      -DUSE_SOUP2=OFF
    ]

    system "cmake", ".", *(std_cmake_args + extra_args)
    system "cmake", "--build", "."
    system "cmake", "--build", ".", "--", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <webkit2/webkit2.h>

      int main(int argc, char *argv[]) {
        fprintf(stdout, "%d.%d.%d\\n",
          webkit_get_major_version(),
          webkit_get_minor_version(),
          webkit_get_micro_version());
        return 0;
      }
    EOS
    ENV.libxml2
    atk = Formula["atk"]
    cairo = Formula["cairo"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gdk_pixbuf = Formula["gdk-pixbuf"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    gtkx3 = Formula["gtk+3"]
    harfbuzz = Formula["harfbuzz"]
    libepoxy = Formula["libepoxy"]
    libpng = Formula["libpng"]
    libsoup = Formula["libsoup"]
    pango = Formula["pango"]
    pixman = Formula["pixman"]
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{atk.opt_include}/atk-1.0
      -I#{cairo.opt_include}/cairo
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gdk_pixbuf.opt_include}/gdk-pixbuf-2.0
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/gio-unix-2.0/
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{gtkx3.opt_include}/gtk-3.0
      -I#{harfbuzz.opt_include}/harfbuzz
      -I#{include}/webkitgtk-4.0
      -I#{libepoxy.opt_include}
      -I#{libpng.opt_include}/libpng16
      -I#{libsoup.opt_include}/libsoup-3.0
      -I#{pango.opt_include}/pango-1.0
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{atk.opt_lib}
      -L#{cairo.opt_lib}
      -L#{gdk_pixbuf.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{gtkx3.opt_lib}
      -L#{libsoup.opt_lib}
      -L#{lib}
      -L#{pango.opt_lib}
      -latk-1.0
      -lcairo
      -lcairo-gobject
      -lgdk-3
      -lgdk_pixbuf-2.0
      -lgio-2.0
      -lglib-2.0
      -lgobject-2.0
      -lgtk-3
      -lintl
      -ljavascriptcoregtk-4.0
      -lpango-1.0
      -lpangocairo-1.0
      -lsoup-2.4
      -lwebkit2gtk-4.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    assert_match version.to_s, shell_output("./test")
  end
end
