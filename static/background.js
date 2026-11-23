// Pick a random tile from /patterns on every page load. The tiles live in
// three themed sets under /patterns: the numbered macOS set, the named
// Windows 3.1 set, and the custom set for owner-added tiles; each list
// entry carries its set's subdirectory.
(() => {
  const patterns = ["custom/blossom.png", "macos9/10042.png", "macos9/1111.png", "macos9/11703.png", "macos9/12484.png", "macos9/12593.png", "macos9/128.png", "macos9/12821.png", "macos9/129.png", "macos9/130.png", "macos9/13096.png", "macos9/131.png", "macos9/132.png", "macos9/133.png", "macos9/134.png", "macos9/136.png", "macos9/13665.png", "macos9/137.png", "macos9/139.png", "macos9/141.png", "macos9/142.png", "macos9/144.png", "macos9/145.png", "macos9/146.png", "macos9/147.png", "macos9/148.png", "macos9/149.png", "macos9/150.png", "macos9/151.png", "macos9/16825.png", "macos9/16974.png", "macos9/17803.png", "macos9/18078.png", "macos9/19688.png", "macos9/1969.png", "macos9/1970.png", "macos9/1971.png", "macos9/1972.png", "macos9/1973.png", "macos9/1974.png", "macos9/1975.png", "macos9/1976.png", "macos9/1977.png", "macos9/1978.png", "macos9/20318.png", "macos9/20446.png", "macos9/21225.png", "macos9/22348.png", "macos9/23295.png", "macos9/24517.png", "macos9/24642.png", "macos9/24817.png", "macos9/2767.png", "macos9/28851.png", "macos9/28920.png", "macos9/29907.png", "macos9/30711.png", "macos9/30930.png", "macos9/31689.png", "macos9/32307.png", "macos9/32623.png", "macos9/3727.png", "macos9/4193.png", "macos9/547.png", "macos9/6006.png", "macos9/6741.png", "macos9/7041.png", "macos9/7321.png", "macos9/7344.png", "macos9/7527.png", "macos9/8388.png", "macos9/8448.png", "macos9/870.png", "macos9/9695.png", "macos9/987.png", "win3.1/256color.png", "win3.1/arcade.png", "win3.1/arches.png", "win3.1/argyle.png", "win3.1/cars.png", "win3.1/castle.png", "win3.1/chitz.png", "win3.1/egypt.png", "win3.1/flock.png", "win3.1/honey.png", "win3.1/leaves.png", "win3.1/marble.png", "win3.1/redbrick.png", "win3.1/rivets.png", "win3.1/squares.png", "win3.1/tartan.png", "win3.1/thatch.png", "win3.1/zigzag.png"];

  const pattern = patterns[Math.floor(Math.random() * patterns.length)];
  document.documentElement.style.setProperty(
    "--random-pattern",
    `url("/patterns/${pattern}")`,
  );
})();
