require 'formula'

def libav?
  ARGV.include? '--with-libav'
end

class Mplayer2 < Formula
  head 'git://git.mplayer2.org/mplayer2.git', :using => :git

  homepage 'http://mplayer2.org'

  depends_on :x11
  depends_on 'pkg-config' => :build
  depends_on 'python3' => :build

  depends_on 'libbs2b' => :build
  depends_on 'libass' => :build
  depends_on 'mpg123' => :build
  depends_on 'libmad' => :build
  depends_on 'libdvdnav' => :build

  if libav?
    depends_on 'pigoz/mplayer2/libav' => :build
  else
    depends_on 'ffmpeg' => :build
  end

  unless libav?
    def caveats; <<-EOS.undent
      mplayer2 is designed to work best with HEAD versions of ffmpeg/libav.
      If you are noticing problems please try to install the HEAD version of
      ffmpeg with: `brew install --HEAD ffmpeg`
      EOS
    end
  end

  def options
    [
      ['--with-libav', 'Build against libav instead of ffmpeg.']
    ]
  end

  def install
    ENV.O1 if ENV.compiler == :llvm
    args = ["--prefix=#{prefix}",
            "--cc=#{ENV.cc}",
            "--enable-macosx-bundle",
            "--enable-macosx-finder",
            "--enable-apple-remote"]

    generate_version
    system "./configure", *args
    system "make install"

    mv bin/'mplayer', bin/binary_name
    mv man1/'mplayer.1', man1/(binary_name + '.1')
  end

  private
  def generate_version
    ohai "Generating VERSION from the Homebrew's git cache"
    File.open('VERSION', 'w') {|f| f.write(git_revision) }
  end

  def git_revision
    `cd #{git_cache} && git describe --match "v[0-9]*" --always`.strip
  end

  def git_cache
    @downloader.cached_location
  end

  def binary_name
    'mplayer2'
  end
end
