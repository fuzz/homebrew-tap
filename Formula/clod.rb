# frozen_string_literal: true

class Clod < Formula
  desc 'Project file manager for Claude AI integrations'
  homepage 'https://github.com/fuzz/clod'
  url "https://hackage.haskell.org/package/clod-0.1.27/clod-0.1.27.tar.gz" # TARBALL_URL_MARKER
  sha256 "355b98e07dbcd788392b431a10abd24b58b6d0b934e141eb53414642edf6a002" # TARBALL_SHA256_MARKER
  license 'MIT'

  # Bottle specification - will be filled in after bottle creation
  bottle do
    root_url "https://github.com/fuzz/clod/releases/download/v0.1.27" # BOTTLE_ROOT_URL_MARKER
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a50b99c94d368f20c109f8747c62007836f777fa4d2634f92bdb058f95d09628" # BOTTLE_SHA256_MARKER
    # Add other platform/OS combinations as needed
    # sha256 cellar: :any, sequoia: "INTEL_SHA_PLACEHOLDER"
  end

  depends_on 'cabal-install' => :build
  depends_on 'ghc' => :build
  depends_on 'libmagic'
  depends_on 'xxhash' => :build
  depends_on 'pandoc' => :recommended

  def install
    system 'cabal', 'update'

    # Use allow-newer flag to work around template-haskell version incompatibility
    system 'cabal', 'install', '--disable-tests', '--allow-newer=template-haskell',
           '--program-suffix=', "--installdir=#{bin}", 'exe:clod'

    # Install man pages directly from source
    return unless build.with? 'pandoc'

    # Generate man pages directly with pandoc
    if File.exist?("#{buildpath}/man/clod.1.md")
      system 'pandoc', '-s', '-t', 'man', "#{buildpath}/man/clod.1.md", '-o', "#{buildpath}/clod.1"
      man1.install "#{buildpath}/clod.1" if File.exist?("#{buildpath}/clod.1")
    end

    if File.exist?("#{buildpath}/man/clod.7.md")
      system 'pandoc', '-s', '-t', 'man', "#{buildpath}/man/clod.7.md", '-o', "#{buildpath}/clod.7"
      man7.install "#{buildpath}/clod.7" if File.exist?("#{buildpath}/clod.7")
    end

    return unless File.exist?("#{buildpath}/man/clod.8.md")

    system 'pandoc', '-s', '-t', 'man', "#{buildpath}/man/clod.8.md", '-o', "#{buildpath}/clod.8"
    man8.install "#{buildpath}/clod.8" if File.exist?("#{buildpath}/clod.8")
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
    assert_match 'Clod - Project file manager for Claude AI', shell_output("#{bin}/clod --help")

    # Only test man pages if they should be installed
    if build.with? 'pandoc'
      begin
        system 'man', '-w', 'clod'
      rescue StandardError
        nil
      end
    end
  end
end
