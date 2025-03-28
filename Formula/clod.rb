class Clod < Formula
  desc "Claude Loader for preparing files for Claude AI's Project Knowledge"
  homepage "https://github.com/fuzz/clod"
  url "https://github.com/fuzz/clod/archive/refs/tags/v0.1.0.tar.gz"
  # After creating the GitHub release, calculate the SHA256 with:
  # curl -L https://github.com/fuzz/clod/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
  sha256 "REPLACE_WITH_ACTUAL_SHA256_AFTER_RELEASE"
  license "MIT"
  
  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "pandoc" => :recommended

  def install
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
    
    # Generate man pages if pandoc is available
    if build.with? "pandoc"
      mkdir "man"
      system "bin/generate-man-pages.sh"
      man1.install "man/clod.1"
      man7.install "man/clod.7"
      man8.install "man/clod.8"
    end
    
    # The wrapper script 'cld' is installed automatically by cabal
  end

  def caveats
    <<~EOS
      Clod includes two executables:
      
      - clod: The main program
      - cld:  A wrapper that automatically opens the staging directory in your file browser
      
      To use the wrapper:
        cld [options]
        
      To disable auto-opening (but still run clod):
        cld --no-open [options]
    EOS
  end

  test do
    assert_match "Clod - Claude Loader", shell_output("#{bin}/clod --help")
  end
end