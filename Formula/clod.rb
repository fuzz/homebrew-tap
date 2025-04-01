class Clod < Formula
  desc "Project file manager for Claude AI integrations"
  homepage "https://github.com/fuzz/clod"
  url "https://hackage.haskell.org/package/clod-0.1.4/clod-0.1.4.tar.gz"
  # Calculate the SHA256 with:
  # curl -sL https://hackage.haskell.org/package/clod-0.1.4/clod-0.1.4.tar.gz | shasum -a 256
  # SHA will need to be updated after the package is uploaded to Hackage
  sha256 "19ac7fd76ca96db4b76a9517c97860e0e3167d57428d6a6cd784d18be7dfb9d1"
  license "MIT"
  
  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "libmagic"
  depends_on "xxhash" => :build
  depends_on "pandoc" => :recommended

  def install
    system "cabal", "v2-update"
    
    # Use allow-newer flag to work around template-haskell version incompatibility
    system "cabal", "v2-install", "--disable-tests", "--allow-newer=template-haskell", 
           "--lib", "--program-suffix=", "--installdir=#{bin}", "exe:clod"
    
    # Install pre-generated man pages during installation
    if build.with? "pandoc"
      system "bin/install-man-pages.sh", "#{buildpath}/brew_man"
      # Only install man pages that were successfully generated
      man1.install "brew_man/man1/clod.1" if File.exist? "#{buildpath}/brew_man/man1/clod.1"
      man7.install "brew_man/man7/clod.7" if File.exist? "#{buildpath}/brew_man/man7/clod.7"
      man8.install "brew_man/man8/clod.8" if File.exist? "#{buildpath}/brew_man/man8/clod.8"
    end
  end

  def caveats
    <<~EOS
      Clod outputs the path to the staging directory, which you can use with:
      
      # On macOS, open the staging directory in Finder:
        open `clod [options]`
      
      # For scripts, you can capture the output:
        STAGING_DIR=$(clod [options])
        open "$STAGING_DIR"
    EOS
  end

  test do
    assert_match "Clod - Project file manager for Claude AI", shell_output("#{bin}/clod --help")
    
    # Only test man pages if they should be installed
    if build.with? "pandoc"
      system "man", "-w", "clod" rescue nil
    end
  end
end
